#!/usr/bin/env bash
set -e

echo "Este script creará/actualizará archivos necesarios para Nexus ERP Pro."
read -p "¿Continuar y crear/actualizar archivos en este repo? (s/n): " CONF
if [ "$CONF" != "s" ]; then
  echo "Abortado."
  exit 1
fi

mkdir -p web/js functions/report e2e .github/workflows

# 1) supabase schema + policies (extended)
cat > supabase_schema_and_policies.sql <<'SQL'
-- Supabase schema and RLS policies for Nexus ERP Pro (extended with inventory movements)
-- Run this in the SQL editor of your Supabase project.

-- Enable extensions
create extension if not exists pgcrypto;

-- Customers
create table if not exists customers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email text,
  owner uuid not null,
  created_at timestamptz default now()
);

-- Products
create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  sku text,
  name text not null,
  price numeric(12,2) default 0,
  stock integer default 0,
  owner uuid not null,
  created_at timestamptz default now()
);

-- Inventory movements (stock history)
create table if not exists stock_movements (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references products(id) on delete cascade,
  delta integer not null,
  reason text,
  owner uuid not null,
  created_at timestamptz default now()
);

-- Invoices and items
create table if not exists invoices (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references customers(id) on delete set null,
  total numeric(12,2) default 0,
  status text default 'draft',
  owner uuid not null,
  created_at timestamptz default now()
);

create table if not exists invoice_items (
  id uuid primary key default gen_random_uuid(),
  invoice_id uuid references invoices(id) on delete cascade,
  product_id uuid references products(id),
  quantity integer default 1,
  price numeric(12,2) default 0
);

-- RLS helper: function to get current user id from JWT
create or replace function public.current_user_id()
returns uuid language sql stable as $$
  select (current_setting('request.jwt.claims', true)::json ->> 'sub')::uuid;
$$;

-- Trigger to set owner if missing
create or replace function public.set_owner_if_missing()
returns trigger language plpgsql as $$
begin
  if new.owner is null then
    new.owner := public.current_user_id();
  end if;
  return new;
end;
$$;

-- Attach trigger to tables
drop trigger if exists set_owner_customers on customers;
create trigger set_owner_customers
before insert on customers
for each row execute function public.set_owner_if_missing();

drop trigger if exists set_owner_products on products;
create trigger set_owner_products
before insert on products
for each row execute function public.set_owner_if_missing();

drop trigger if exists set_owner_invoices on invoices;
create trigger set_owner_invoices
before insert on invoices
for each row execute function public.set_owner_if_missing();

drop trigger if exists set_owner_stock_movements on stock_movements;
create trigger set_owner_stock_movements
before insert on stock_movements
for each row execute function public.set_owner_if_missing();

-- Trigger to insert stock_movements when product stock changes (audit)
create or replace function public.log_stock_change()
returns trigger language plpgsql as $$
begin
  if tg_op = 'UPDATE' then
    if new.stock is distinct from old.stock then
      insert into stock_movements(product_id, delta, reason, owner)
      values (new.id, (new.stock - old.stock), 'stock_update', public.current_user_id());
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists stock_change_trigger on products;
create trigger stock_change_trigger
after update on products
for each row execute function public.log_stock_change();

-- === RLS policies ===

-- Customers
alter table customers enable row level security;
create policy "customers_select" on customers for select using (owner = auth.uid());
create policy "customers_insert" on customers for insert with check (owner = auth.uid());
create policy "customers_update" on customers for update using (owner = auth.uid()) with check (owner = auth.uid());
create policy "customers_delete" on customers for delete using (owner = auth.uid());

-- Products
alter table products enable row level security;
create policy "products_select" on products for select using (owner = auth.uid());
create policy "products_insert" on products for insert with check (owner = auth.uid());
create policy "products_update" on products for update using (owner = auth.uid()) with check (owner = auth.uid());
create policy "products_delete" on products for delete using (owner = auth.uid());

-- Stock movements
alter table stock_movements enable row level security;
create policy "stock_movements_select" on stock_movements for select using (owner = auth.uid());
create policy "stock_movements_insert" on stock_movements for insert with check (owner = auth.uid());
create policy "stock_movements_delete" on stock_movements for delete using (owner = auth.uid());

-- Invoices
alter table invoices enable row level security;
create policy "invoices_select" on invoices for select using (owner = auth.uid());
create policy "invoices_insert" on invoices for insert with check (owner = auth.uid());
create policy "invoices_update" on invoices for update using (owner = auth.uid()) with check (owner = auth.uid());
create policy "invoices_delete" on invoices for delete using (owner = auth.uid());

-- Invoice items
alter table invoice_items enable row level security;
create policy "invoice_items_select" on invoice_items for select using (
  exists (select 1 from invoices where invoices.id = invoice_items.invoice_id and invoices.owner = auth.uid())
);
create policy "invoice_items_insert" on invoice_items for insert with check (
  exists (select 1 from invoices where invoices.id = invoice_items.invoice_id and invoices.owner = auth.uid())
);
create policy "invoice_items_delete" on invoice_items for delete using (
  exists (select 1 from invoices where invoices.id = invoice_items.invoice_id and invoices.owner = auth.uid())
);
SQL

# 2) Report server
cat > functions/report/index.js <<'JS'
/* Simple Express report server */
const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const app = express();
app.use(express.json());

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://awisqztvlifzreutlxif.supabase.co';
const SUPABASE_KEY = process.env.SUPABASE_KEY || 'sb_publishable_OAjQgoYfdWNxxeZD7TZWog_ITcMZ_Yh';
const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

function toCSV(rows) {
  if (!rows || rows.length === 0) return '';
  const cols = Object.keys(rows[0]);
  const header = cols.join(',');
  const lines = rows.map(r => cols.map(c => `"${String(r[c] ?? '')}"`).join(','));
  return [header, ...lines].join('\n');
}

app.get('/report/invoices', async (req, res) => {
  try {
    const from = req.query.from;
    const to = req.query.to;
    let query = supabase.from('invoices').select('id,customer_id,total,status,created_at');
    if (from) query = query.gte('created_at', from);
    if (to) query = query.lte('created_at', to);
    const { data, error } = await query.order('created_at', { ascending: true });
    if (error) return res.status(500).json({ error: error.message });
    const csv = toCSV(data || []);
    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename="invoices_report.csv"');
    res.send(csv);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const port = process.env.PORT || 4000;
app.listen(port, () => console.log(`Report server listening on ${port}`));
JS

# 3) API module
cat > web/js/api.js <<'JS'
import { initSupabase } from './supabaseClient.js';

async function getSupabase() {
  return await initSupabase();
}

async function getUserId(supabase) {
  const { data, error } = await supabase.auth.getUser();
  if (error) throw error;
  const user = data?.user;
  if (!user) throw new Error('Usuario no autenticado. Inicia sesión.');
  return user.id;
}

export async function listCustomers(page = 1, perPage = 20, search = '') {
  const supabase = await getSupabase();
  const from = (page - 1) * perPage;
  const to = from + perPage - 1;
  let query = supabase.from('customers').select('*', { count: 'exact' }).order('created_at', { ascending: false }).range(from, to);
  if (search && search.trim().length > 0) {
    query = query.ilike('name', `%${search}%`);
  }
  const resp = await query;
  return { data: resp.data, error: resp.error, count: resp.count };
}

export async function createCustomer(payload) {
  const supabase = await getSupabase();
  const owner = await getUserId(supabase);
  const resp = await supabase.from('customers').insert([{ ...payload, owner }]);
  return resp;
}

export async function updateCustomer(id, payload) {
  const supabase = await getSupabase();
  return await supabase.from('customers').update(payload).eq('id', id);
}

export async function deleteCustomer(id) {
  const supabase = await getSupabase();
  return await supabase.from('customers').delete().eq('id', id);
}

export async function listProducts(page = 1, perPage = 20, search = '') {
  const supabase = await getSupabase();
  const from = (page - 1) * perPage;
  const to = from + perPage - 1;
  let query = supabase.from('products').select('*', { count: 'exact' }).order('created_at', { ascending: false }).range(from, to);
  if (search && search.trim().length > 0) {
    query = query.or(`name.ilike.%${search}%,sku.ilike.%${search}%`);
  }
  const resp = await query;
  return { data: resp.data, error: resp.error, count: resp.count };
}

export async function createProduct(payload) {
  const supabase = await getSupabase();
  const owner = await getUserId(supabase);
  return await supabase.from('products').insert([{ ...payload, owner }]);
}

export async function updateProduct(id, payload) {
  const supabase = await getSupabase();
  return await supabase.from('products').update(payload).eq('id', id);
}

export async function deleteProduct(id) {
  const supabase = await getSupabase();
  return await supabase.from('products').delete().eq('id', id);
}

export async function listInvoices(page = 1, perPage = 20, search = '') {
  const supabase = await getSupabase();
  const from = (page - 1) * perPage;
  const to = from + perPage - 1;
  let query = supabase.from('invoices').select('*, invoice_items(*)', { count: 'exact' }).order('created_at', { ascending: false }).range(from, to);
  if (search && search.trim().length > 0) {
    query = query.or(`customer_id.eq.${search},id.eq.${search}`);
  }
  const resp = await query;
  return { data: resp.data, error: resp.error, count: resp.count };
}

export async function createInvoice(payload, items) {
  const supabase = await getSupabase();
  const owner = await getUserId(supabase);
  const { data: invoiceData, error: invoiceError } = await supabase.from('invoices').insert([{ ...payload, owner }]).select().single();
  if (invoiceError) return { error: invoiceError };
  const invoiceId = invoiceData.id;
  const itemsPayload = items.map(i => ({ invoice_id: invoiceId, product_id: i.product_id, quantity: i.quantity, price: i.price }));
  const { data: itemsData, error: itemsError } = await supabase.from('invoice_items').insert(itemsPayload);
  return { invoice: invoiceData, items: itemsData, error: itemsError };
}

export async function getInvoice(id) {
  const supabase = await getSupabase();
  const resp = await supabase.from('invoices').select('*, invoice_items(*)').eq('id', id).single();
  return resp;
}

export async function deleteInvoice(id) {
  const supabase = await getSupabase();
  return await supabase.from('invoices').delete().eq('id', id);
}
JS

# 4) Products module (full)
cat > web/js/products.js <<'JS'
import { listProducts, createProduct, updateProduct, deleteProduct } from './api.js';

let currentProductPage = 1;
const PRODUCTS_PER_PAGE = 20;
let currentProductSearch = '';

export async function renderProducts(container) {
  container.innerHTML = `<div class="card"><h3>Productos</h3><div id="productsContent">Cargando...</div></div>`;
  await loadProducts(container, currentProductPage);
  renderControls(container);
}

function renderControls(container) {
  const content = container.querySelector('#productsContent');
  content.innerHTML = `
    <div style="display:flex;gap:12px;align-items:center;">
      <button id="btnNewProduct">Nuevo producto</button>
      <div style="margin-left:auto;display:flex;gap:8px;align-items:center;">
        <input id="productSearch" placeholder="Buscar por nombre o SKU" />
        <button id="searchBtn">Buscar</button>
        <button id="prevPage">Prev</button>
        <span id="pageInfo">Página 1</span>
        <button id="nextPage">Next</button>
      </div>
    </div>
    <div id="productForm" class="hidden" style="margin-top:12px"></div>
    <div id="productList" style="margin-top:12px"></div>
  `;

  content.querySelector('#btnNewProduct').addEventListener('click', () => showProductForm(container));
  content.querySelector('#prevPage').addEventListener('click', async () => {
    if (currentProductPage <= 1) return;
    currentProductPage--;
    await loadProducts(container, currentProductPage);
  });
  content.querySelector('#nextPage').addEventListener('click', async () => {
    currentProductPage++;
    await loadProducts(container, currentProductPage);
  });
  content.querySelector('#searchBtn').addEventListener('click', async () => {
    const term = content.querySelector('#productSearch').value.trim();
    currentProductSearch = term;
    currentProductPage = 1;
    await loadProducts(container, currentProductPage);
  });
}

function showProductForm(container, existing = null) {
  const formWrap = container.querySelector('#productForm');
  formWrap.classList.remove('hidden');
  formWrap.innerHTML = `
    <div style="display:flex;flex-direction:column;gap:8px;max-width:480px">
      <input id="p_name" placeholder="Nombre" value="${existing ? escapeHtml(existing.name) : ''}" />
      <input id="p_sku" placeholder="SKU" value="${existing ? escapeHtml(existing.sku) : ''}" />
      <input id="p_price" placeholder="Precio" value="${existing ? existing.price : ''}" />
      <input id="p_stock" placeholder="Stock" value="${existing ? existing.stock : 0}" />
      <div style="display:flex;gap:8px">
        <button id="p_save">Guardar</button>
        <button id="p_cancel">Cancelar</button>
      </div>
      <div id="p_msg" style="color:#c00"></div>
    </div>
  `;

  formWrap.querySelector('#p_cancel').addEventListener('click', () => { formWrap.classList.add('hidden'); });
  formWrap.querySelector('#p_save').addEventListener('click', async () => {
    const name = formWrap.querySelector('#p_name').value.trim();
    const sku = formWrap.querySelector('#p_sku').value.trim();
    const price = parseFloat(formWrap.querySelector('#p_price').value);
    const stock = parseInt(formWrap.querySelector('#p_stock').value || '0', 10);
    const msg = formWrap.querySelector('#p_msg');
    msg.textContent = '';
    if (!name) { msg.textContent = 'Nombre obligatorio'; return; }
    if (isNaN(price)) { msg.textContent = 'Precio inválido'; return; }
    try {
      if (existing) {
        const { error } = await updateProduct(existing.id, { name, sku, price, stock });
        if (error) throw error;
      } else {
        const { error } = await createProduct({ name, sku, price, stock });
        if (error) throw error;
      }
      formWrap.classList.add('hidden');
      await loadProducts(container, 1);
    } catch (err) {
      console.error(err);
      msg.textContent = err.message || String(err);
    }
  });
}

async function loadProducts(container, page) {
  const { data, error, count } = await listProducts(page, PRODUCTS_PER_PAGE, currentProductSearch);
  const list = container.querySelector('#productList');
  const pageInfo = container.querySelector('#pageInfo');
  if (error) { list.innerHTML = `<div style="color:#c00">Error: ${error.message || error}</div>`; return; }
  if (!data || data.length === 0) { list.innerHTML = '<div>No hay productos.</div>'; pageInfo.textContent = `Página ${page}`; return; }
  const rows = data.map(p => `<tr><td>${p.id}</td><td>${escapeHtml(p.name)}</td><td>${escapeHtml(p.sku||'')}</td><td>${p.price}</td><td>${p.stock}</td><td><button data-id="${p.id}" class="edit">Editar</button> <button data-id="${p.id}" class="del">Eliminar</button></td></tr>`).join('');
  list.innerHTML = `<div style="margin-bottom:8px">Mostrando ${data.length} de ${count} productos</div><table><thead><tr><th>ID</th><th>Nombre</th><th>SKU</th><th>Precio</th><th>Stock</th><th>Acciones</th></tr></thead><tbody>${rows}</tbody></table>`;
  pageInfo.textContent = `Página ${page} (${Math.ceil((count||0)/PRODUCTS_PER_PAGE)} total)`;

  list.querySelectorAll('button.edit').forEach(b => b.addEventListener('click', async (e) => {
    const id = e.target.dataset.id;
    const prod = data.find(x => x.id === id);
    showProductForm(container, prod);
  }));
  list.querySelectorAll('button.del').forEach(b => b.addEventListener('click', async (e) => {
    const id = e.target.dataset.id;
    if (!confirm('Eliminar producto?')) return;
    const { error } = await deleteProduct(id);
    if (error) return alert('Error: ' + (error.message || error));
    await loadProducts(container, 1);
  }));
}

function escapeHtml(s) { if (!s) return ''; return s.replace(/[&<>"']/g, (m) => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m])); }
JS

# 5) Invoices module
cat > web/js/invoices.js <<'JS'
import { listInvoices, createInvoice, getInvoice, deleteInvoice } from './api.js';
import { listProducts } from './api.js';

let currentInvoicePage = 1;
const INVOICES_PER_PAGE = 20;
let currentInvoiceSearch = '';

export async function renderInvoices(container) {
  container.innerHTML = `<div class="card"><h3>Facturas</h3><div id="invoicesContent">Cargando...</div></div>`;
  await loadInvoices(container, currentInvoicePage);
}

function renderControls(container) {
  const content = container.querySelector('#invoicesContent');
  content.innerHTML = `
    <div style="display:flex;gap:12px;align-items:center;">
      <button id="btnNewInvoice">Nueva factura</button>
      <div style="margin-left:auto;display:flex;gap:8px;align-items:center;">
        <input id="invoiceSearch" placeholder="Buscar por cliente ID o factura ID" />
        <button id="searchBtn">Buscar</button>
        <button id="prevPage">Prev</button>
        <span id="pageInfo">Página 1</span>
        <button id="nextPage">Next</button>
      </div>
    </div>
    <div id="invoiceForm" class="hidden" style="margin-bottom:12px"></div>
    <div id="invoiceList"></div>
  `;
  document.getElementById('btnNewInvoice').addEventListener('click', () => showInvoiceForm(container));
  content.querySelector('#prevPage').addEventListener('click', async () => {
    if (currentInvoicePage <= 1) return;
    currentInvoicePage--;
    await loadInvoices(container, currentInvoicePage);
  });
  content.querySelector('#nextPage').addEventListener('click', async () => {
    currentInvoicePage++;
    await loadInvoices(container, currentInvoicePage);
  });
  content.querySelector('#searchBtn').addEventListener('click', async () => {
    const term = content.querySelector('#invoiceSearch').value.trim();
    currentInvoiceSearch = term;
    currentInvoicePage = 1;
    await loadInvoices(container, currentInvoicePage);
  });
}

async function loadInvoices(container, page = 1) {
  const content = container.querySelector('#invoicesContent');
  content.innerHTML = '';
  renderControls(container);
  const { data, error, count } = await listInvoices(page, INVOICES_PER_PAGE, currentInvoiceSearch);
  const list = container.querySelector('#invoiceList');
  const pageInfo = container.querySelector('#pageInfo');
  if (error) { list.innerHTML = `<div style="color:#c00">Error: ${error.message || error}</div>`; return; }
  if (!data || data.length === 0) { list.innerHTML = '<div>No hay facturas.</div>'; pageInfo.textContent = `Página ${page}`; return; }
  const rows = data.map(inv => `<tr><td>${inv.id}</td><td>${escapeHtml(inv.customer_id)}</td><td>${inv.total}</td><td>${new Date(inv.created_at).toLocaleString()}</td><td><button data-id="${inv.id}" class="view">Ver</button> <button data-id="${inv.id}" class="del">Eliminar</button></td></tr>`).join('');
  list.innerHTML = `<div style="margin-bottom:8px">Mostrando ${data.length} de ${count} facturas</div><table><thead><tr><th>ID</th><th>Cliente</th><th>Total</th><th>Fecha</th><th>Acciones</th></tr></thead><tbody>${rows}</tbody></table>`;
  pageInfo.textContent = `Página ${page} (${Math.ceil((count||0)/INVOICES_PER_PAGE)} total)`;

  list.querySelectorAll('button.view').forEach(b => b.addEventListener('click', async (e) => {
    const id = e.target.dataset.id;
    const resp = await getInvoice(id);
    if (resp.error) return alert('Error: ' + (resp.error.message || resp.error));
    alert(JSON.stringify(resp.data, null, 2));
  }));

  list.querySelectorAll('button.del').forEach(b => b.addEventListener('click', async (e) => {
    const id = e.target.dataset.id;
    if (!confirm('Eliminar factura?')) return;
    const { error } = await deleteInvoice(id);
    if (error) return alert('Error: ' + (error.message || error));
    await loadInvoices(container, 1);
  }));
}

async function showInvoiceForm(container) {
  const formWrap = container.querySelector('#invoiceForm');
  formWrap.classList.remove('hidden');
  const { data: products } = await listProducts(1, 100);
  formWrap.innerHTML = `
    <div style="display:flex;flex-direction:column;gap:8px;max-width:720px">
      <input id="inv_customer" placeholder="Customer ID" />
      <div id="itemsArea"></div>
      <button id="addItem">Agregar Item</button>
      <div style="display:flex;gap:8px"><button id="inv_save">Guardar</button> <button id="inv_cancel">Cancelar</button></div>
      <div id="inv_msg" style="color:#c00"></div>
    </div>
  `;

  const itemsArea = formWrap.querySelector('#itemsArea');
  function addItemRow() {
    const idx = itemsArea.children.length;
    const row = document.createElement('div');
    row.innerHTML = `
      <select class="prodSel">${products.map(p=>`<option value="${p.id}">${escapeHtml(p.name)} - ${p.price}</option>`).join('')}</select>
      <input class="qty" type="number" value="1" style="width:80px" />
      <input class="price" type="number" step="0.01" value="${products[0] ? products[0].price : 0}" style="width:120px" />
      <button class="remove">Eliminar</button>
    `;
    itemsArea.appendChild(row);
    row.querySelector('.remove').addEventListener('click', () => row.remove());
    row.querySelector('.prodSel').addEventListener('change', (e) => {
      const pid = e.target.value;
      const p = products.find(x=>x.id===pid);
      row.querySelector('.price').value = p ? p.price : 0;
    });
  }
  addItemRow();
  formWrap.querySelector('#addItem').addEventListener('click', addItemRow);
  formWrap.querySelector('#inv_cancel').addEventListener('click', () => formWrap.classList.add('hidden'));

  formWrap.querySelector('#inv_save').addEventListener('click', async () => {
    const customer_id = formWrap.querySelector('#inv_customer').value.trim();
    const msg = formWrap.querySelector('#inv_msg');
    if (!customer_id) { msg.textContent = 'Customer ID requerido'; return; }
    const items = Array.from(itemsArea.children).map(row => ({ product_id: row.querySelector('.prodSel').value, quantity: parseInt(row.querySelector('.qty').value||'1',10), price: parseFloat(row.querySelector('.price').value||'0') }));
    const total = items.reduce((s,i)=>s + (i.quantity * i.price), 0);
    try {
      const { invoice, items: createdItems, error } = await createInvoice({ customer_id, total }, items);
      if (error) throw error;
      formWrap.classList.add('hidden');
      await loadInvoices(container,1);
    } catch (err) {
      console.error(err);
      msg.textContent = err.message || String(err);
    }
  });
}

function escapeHtml(s) { if (!s) return ''; return s.replace(/[&<>"']/g, (m) => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m])); }

export async function loadInvoices(container) { await renderInvoices(container); }
JS

# 6) Playwright config + simple test + workflow
cat > playwright.config.js <<'CFG'
const config = {
  timeout: 30000,
  use: {
    headless: true,
    viewport: { width: 1280, height: 800 }
  },
  testDir: 'e2e'
};
module.exports = config;
CFG

cat > e2e/login.spec.js <<'SPEC'
const { test, expect } = require('@playwright/test');

test('load app and show login', async ({ page }) => {
  await page.goto('http://localhost:3000');
  await expect(page.locator('text=Iniciar sesión')).toBeVisible();
  await expect(page.locator('input[type="email"]')).toBeVisible();
});
SPEC

cat > .github/workflows/e2e.yml <<'YML'
name: E2E tests (Playwright)

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  e2e:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Start static server
        run: npx http-server web -p 3000 &

      - name: Install Playwright browsers
        run: npx playwright install --with-deps

      - name: Run Playwright tests
        run: npx playwright test --reporter=list
YML

# 7) Minimal package.json (if exists, you will overwrite scripts)
if [ -f package.json ]; then
  echo "package.json existe — no sobrescribiendo. Si quieres sobrescribirlo, elimina package.json y vuelve a ejecutar."
else
cat > package.json <<'PJ'
{
  "name": "nexus-erp-pro",
  "version": "1.0.0",
  "description": "Nexus ERP Pro",
  "main": "main.js",
  "scripts": {
    "start": "electron .",
    "dist": "electron-builder --win nsis --x64",
    "cap:init": "npx @capacitor/cli@latest init com.nexuserp.app \"Nexus ERP Pro\" --web-dir=web",
    "start-static": "npx http-server web -p 3000",
    "test:e2e": "npx playwright test"
  },
  "dependencies": {
    "@supabase/supabase-js": "^2.30.0",
    "express": "^4.18.2"
  },
  "devDependencies": {
    "@playwright/test": "^1.40.0",
    "http-server": "^14.1.1",
    "electron": "^30.0.0",
    "electron-builder": "^24.13.0"
  },
  "build": {
    "appId": "com.nexuserp.app",
    "productName": "Nexus ERP Pro",
    "files": [
      "**/*"
    ],
    "win": {
      "target": "nsis"
    }
  }
}
PJ
fi

# 8) Show a short completion message
echo "Archivos creados/actualizados. Revisa con 'git status' y 'git diff'."

# 9) Git add/commit suggestion (script will not auto-commit to avoid accidental pushes)
echo "Para commitear manualmente ejecuta los comandos que te proporcioné (ver instrucciones en la documentación)."
