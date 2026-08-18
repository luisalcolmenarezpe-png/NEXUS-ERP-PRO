const STORAGE_KEY = 'nexus-erp-pro-state-v2';
const USERS_KEY = 'nexus-erp-pro-users-v1';

const defaultState = {
  products: [
    { id: 1, name: 'Laptop Pro 14', category: 'Tecnología', price: 1200, stock: 16 },
    { id: 2, name: 'Impresora Zebra', category: 'Oficina', price: 620, stock: 9 },
    { id: 3, name: 'Caja Registradora', category: 'POS', price: 310, stock: 21 },
    { id: 4, name: 'Scanner USB', category: 'Tecnología', price: 180, stock: 32 },
    { id: 5, name: 'Silla Ejecutiva', category: 'Mobiliario', price: 240, stock: 12 },
  ],
  cart: [],
  sales: [
    { id: 1, customer: 'Ana Gómez', total: 420, status: 'Pagado' },
    { id: 2, customer: 'Luis Ortega', total: 980, status: 'Pendiente' },
    { id: 3, customer: 'María Salas', total: 640, status: 'Pagado' },
  ],
  customers: [
    { id: 1, name: 'Ana Gómez', email: 'ana@demo.com', phone: '0412-1111111', segment: 'Retail' },
    { id: 2, name: 'Luis Ortega', email: 'luis@demo.com', phone: '0414-2222222', segment: 'Mayorista' },
    { id: 3, name: 'María Salas', email: 'maria@demo.com', phone: '0416-3333333', segment: 'Distribución' },
  ],
};

const navItems = [
  { id: 'dashboard', label: 'Dashboard' },
  { id: 'pos', label: 'POS / Caja' },
  { id: 'inventory', label: 'Inventario' },
  { id: 'customers', label: 'Clientes' },
  { id: 'sales', label: 'Ventas' },
  { id: 'finance', label: 'Finanzas' },
];

let currentTab = 'dashboard';
let appState = loadState();
let authUser = null;
let supabaseClient = null;
const demoUsers = [
  { email: 'admin@empresa.com', password: 'admin123' },
  { email: 'ventas@empresa.com', password: 'ventas123' },
];

const app = document.getElementById('app');
const nav = document.getElementById('nav');
const pageTitle = document.getElementById('pageTitle');
const authScreen = document.getElementById('authScreen');
const appShell = document.getElementById('appShell');
const authForm = document.getElementById('authForm');
const authError = document.getElementById('authError');
const btnCreateAccount = document.getElementById('btnCreateAccount');
const btnLogout = document.getElementById('btnLogout');
const btnSync = document.getElementById('btnSync');
const btnExportCsv = document.getElementById('btnExportCsv');

function clone(data) {
  return JSON.parse(JSON.stringify(data));
}

function loadState() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return clone(defaultState);
    const parsed = JSON.parse(raw);
    return {
      products: Array.isArray(parsed.products) && parsed.products.length ? parsed.products : clone(defaultState.products),
      cart: Array.isArray(parsed.cart) ? parsed.cart : [],
      sales: Array.isArray(parsed.sales) && parsed.sales.length ? parsed.sales : clone(defaultState.sales),
      customers: Array.isArray(parsed.customers) && parsed.customers.length ? parsed.customers : clone(defaultState.customers),
    };
  } catch (err) {
    console.warn('No se pudo cargar estado local:', err);
    return clone(defaultState);
  }
}

function saveState() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(appState));
}

function getLocalUsers() {
  try {
    const raw = localStorage.getItem(USERS_KEY);
    if (!raw) return [...demoUsers];
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) && parsed.length ? parsed : [...demoUsers];
  } catch (error) {
    console.warn('No se pudieron cargar usuarios locales:', error);
    return [...demoUsers];
  }
}

function saveLocalUsers(users) {
  localStorage.setItem(USERS_KEY, JSON.stringify(users));
}

function authenticateLocalUser(email, password) {
  const users = getLocalUsers();
  const user = users.find((item) => item.email.toLowerCase() === email.toLowerCase() && item.password === password);
  if (!user) {
    throw new Error('Credenciales incorrectas. Prueba admin@empresa.com / admin123');
  }
  return { email: user.email };
}

function formatCurrency(value) {
  const num = Number(value || 0);
  return new Intl.NumberFormat('es-VE', {
    style: 'currency',
    currency: 'VES',
    maximumFractionDigits: 2,
  }).format(num);
}

function getTotalSales() {
  return appState.sales.reduce((sum, item) => sum + Number(item.total || 0), 0);
}

function getInventoryValue() {
  return appState.products.reduce((sum, item) => sum + Number(item.price || 0) * Number(item.stock || 0), 0);
}

function getLowStockCount() {
  return appState.products.filter((item) => Number(item.stock || 0) < 10).length;
}

function getCartTotal() {
  return appState.cart.reduce((sum, item) => sum + Number(item.price || 0) * Number(item.quantity || 0), 0);
}

function addToCart(productId) {
  const product = appState.products.find((item) => Number(item.id) === Number(productId));
  if (!product || Number(product.stock || 0) <= 0) return;

  const existing = appState.cart.find((item) => Number(item.id) === Number(productId));
  if (existing) {
    existing.quantity += 1;
  } else {
    appState.cart.push({ id: Number(productId), name: product.name, price: Number(product.price), quantity: 1 });
  }

  saveState();
  renderPage();
}

function updateCart(productId, change) {
  const item = appState.cart.find((entry) => Number(entry.id) === Number(productId));
  if (!item) return;

  item.quantity += change;
  if (item.quantity <= 0) {
    appState.cart = appState.cart.filter((entry) => Number(entry.id) !== Number(productId));
  }

  saveState();
  renderPage();
}

function addProductFromForm(event) {
  event.preventDefault();
  const form = event.currentTarget;
  const name = form.productName.value.trim();
  const category = form.productCategory.value.trim();
  const price = Number(form.productPrice.value || 0);
  const stock = Number(form.productStock.value || 0);

  if (!name || !category || price <= 0) return;

  const nextId = appState.products.length ? Math.max(...appState.products.map((item) => Number(item.id || 0))) + 1 : 1;

  appState.products.unshift({ id: nextId, name, category, price, stock });
  saveState();
  renderPage();
}

function deleteProduct(productId) {
  appState.products = appState.products.filter((item) => Number(item.id) !== Number(productId));
  appState.cart = appState.cart.filter((item) => Number(item.id) !== Number(productId));
  saveState();
  renderPage();
}

function saveCustomerFromForm(event) {
  event.preventDefault();
  const form = event.currentTarget;
  const id = Number(form.dataset.customerId || 0);
  const payload = {
    id: id || Date.now(),
    name: form.customerName.value.trim(),
    email: form.customerEmail.value.trim(),
    phone: form.customerPhone.value.trim(),
    segment: form.customerSegment.value.trim(),
  };

  if (!payload.name) return;

  const existingIndex = appState.customers.findIndex((item) => Number(item.id) === Number(payload.id));
  if (existingIndex >= 0) {
    appState.customers[existingIndex] = payload;
  } else {
    appState.customers.unshift(payload);
  }

  saveState();
  renderPage();
}

function deleteCustomer(customerId) {
  appState.customers = appState.customers.filter((item) => Number(item.id) !== Number(customerId));
  saveState();
  renderPage();
}

function renderNav() {
  nav.innerHTML = navItems.map((item) => `
    <button class="nav-item ${currentTab === item.id ? 'active' : ''}" data-tab="${item.id}">
      ${item.label}
    </button>
  `).join('');

  nav.querySelectorAll('.nav-item').forEach((button) => {
    button.addEventListener('click', () => {
      currentTab = button.dataset.tab;
      renderNav();
      renderPage();
    });
  });
}

function renderDashboard() {
  pageTitle.textContent = 'Dashboard';
  app.innerHTML = `
    <div class="metric-grid">
      <div class="card metric-card">
        <span class="metric-label">Ventas del mes</span>
        <p class="metric-value">${formatCurrency(getTotalSales())}</p>
        <div class="metric-trend">+12.4% vs. mes anterior</div>
      </div>
      <div class="card metric-card">
        <span class="metric-label">Inventario</span>
        <p class="metric-value">${formatCurrency(getInventoryValue())}</p>
        <div class="metric-trend">${appState.products.length} productos activos</div>
      </div>
      <div class="card metric-card">
        <span class="metric-label">Clientes</span>
        <p class="metric-value">${appState.customers.length}</p>
        <div class="metric-trend">${appState.customers.length > 0 ? 'Segmentos activos' : 'Sin clientes'}</div>
      </div>
      <div class="card metric-card">
        <span class="metric-label">Stock bajo</span>
        <p class="metric-value">${getLowStockCount()}</p>
        <div class="metric-trend">Revisar alertas</div>
      </div>
    </div>

    <div class="grid-2">
      <div class="card">
        <div class="panel-header"><h3>Últimas ventas</h3></div>
        <div class="table-wrap">
          <table>
            <thead><tr><th>Cliente</th><th>Monto</th><th>Estado</th></tr></thead>
            <tbody>
              ${appState.sales.slice(0, 5).map((sale) => `
                <tr>
                  <td>${sale.customer}</td>
                  <td>${formatCurrency(sale.total)}</td>
                  <td><span class="badge ${sale.status === 'Pagado' ? 'success' : 'warning'}">${sale.status}</span></td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        </div>
      </div>

      <div class="card">
        <div class="panel-header"><h3>Resumen</h3></div>
        <ul>
          <li>Ingresos estimados: <strong>${formatCurrency(getTotalSales())}</strong></li>
          <li>Productos en stock: <strong>${appState.products.reduce((sum, item) => sum + Number(item.stock || 0), 0)}</strong></li>
          <li>Margen operativo: <strong>18.2%</strong></li>
        </ul>
      </div>
    </div>
  `;
}

function renderPos() {
  pageTitle.textContent = 'POS / Caja';
  const cartItems = appState.cart.length
    ? appState.cart.map((item) => `
      <div class="cart-row">
        <div>
          <strong>${item.name}</strong><br>
          <small>${formatCurrency(item.price)} c/u</small>
        </div>
        <div style="display:flex;align-items:center;gap:8px;">
          <button class="secondary-btn" data-action="decrease" data-id="${item.id}">-</button>
          <span>${item.quantity}</span>
          <button class="secondary-btn" data-action="increase" data-id="${item.id}">+</button>
        </div>
      </div>
    `).join('')
    : '<p>No hay productos en la caja.</p>';

  app.innerHTML = `
    <div class="grid-2">
      <div class="card">
        <div class="panel-header"><h3>Productos</h3></div>
        <div class="table-wrap">
          <table>
            <thead><tr><th>Producto</th><th>Stock</th><th>Precio</th><th></th></tr></thead>
            <tbody>
              ${appState.products.map((product) => `
                <tr>
                  <td>${product.name}</td>
                  <td>${product.stock}</td>
                  <td>${formatCurrency(product.price)}</td>
                  <td><button class="primary-btn" data-add-product="${product.id}">Agregar</button></td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        </div>
      </div>

      <div class="card">
        <div class="panel-header"><h3>Caja</h3></div>
        ${cartItems}
        <div class="total-box">
          <span>Total</span><br>
          <strong>${formatCurrency(getCartTotal())}</strong>
        </div>
        <div style="margin-top:16px; display:flex; gap:10px;">
          <button class="primary-btn" id="checkoutBtn">Cobrar</button>
          <button class="danger-btn" id="clearCartBtn">Vaciar</button>
        </div>
      </div>
    </div>
  `;

  app.querySelectorAll('[data-add-product]').forEach((button) => {
    button.addEventListener('click', (event) => addToCart(event.currentTarget.dataset.addProduct));
  });

  app.querySelectorAll('[data-action]').forEach((button) => {
    button.addEventListener('click', (event) => {
      const { action, id } = event.currentTarget.dataset;
      updateCart(id, action === 'increase' ? 1 : -1);
    });
  });

  document.getElementById('checkoutBtn')?.addEventListener('click', () => {
    if (!appState.cart.length) return;

    const receiptItems = appState.cart.map((item) => ({ ...item }));
    const total = getCartTotal();
    const sale = { id: Date.now(), customer: 'Cliente local', total, status: 'Pagado' };

    appState.sales.unshift(sale);
    appState.cart.forEach((item) => {
      const product = appState.products.find((p) => Number(p.id) === Number(item.id));
      if (product) product.stock = Math.max(0, Number(product.stock) - Number(item.quantity));
    });

    appState.cart = [];
    saveState();
    openReceiptWindow(total, receiptItems);
    renderPage();
  });

  document.getElementById('clearCartBtn')?.addEventListener('click', () => {
    appState.cart = [];
    saveState();
    renderPage();
  });
}

function renderInventory() {
  pageTitle.textContent = 'Inventario';
  app.innerHTML = `
    <div class="grid-2">
      <div class="card">
        <div class="panel-header"><h3>Registrar producto</h3></div>
        <form id="productForm">
          <div class="form-grid">
            <label>
              Nombre
              <input name="productName" type="text" placeholder="Ej. Monitor 27''" required />
            </label>
            <label>
              Categoría
              <input name="productCategory" type="text" placeholder="Ej. Tecnología" required />
            </label>
            <label>
              Precio
              <input name="productPrice" type="number" min="0" step="0.01" placeholder="0.00" required />
            </label>
            <label>
              Stock
              <input name="productStock" type="number" min="0" step="1" placeholder="0" required />
            </label>
          </div>
          <div style="margin-top:16px; display:flex; gap:10px;">
            <button type="submit" class="primary-btn">Guardar</button>
          </div>
        </form>
      </div>

      <div class="card">
        <div class="panel-header"><h3>Productos registrados</h3></div>
        <div class="table-wrap">
          <table>
            <thead><tr><th>Nombre</th><th>Categoría</th><th>Precio</th><th>Stock</th><th>Estado</th><th></th></tr></thead>
            <tbody>
              ${appState.products.map((product) => `
                <tr>
                  <td>${product.name}</td>
                  <td>${product.category}</td>
                  <td>${formatCurrency(product.price)}</td>
                  <td>${product.stock}</td>
                  <td><span class="badge ${product.stock < 10 ? 'warning' : 'success'}">${product.stock < 10 ? 'Bajo' : 'OK'}</span></td>
                  <td><button class="danger-btn" data-delete-product="${product.id}">Eliminar</button></td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  `;

  document.getElementById('productForm').addEventListener('submit', addProductFromForm);

  app.querySelectorAll('[data-delete-product]').forEach((button) => {
    button.addEventListener('click', () => deleteProduct(button.dataset.deleteProduct));
  });
}

function renderCustomers() {
  pageTitle.textContent = 'Clientes';
  app.innerHTML = `
    <div class="grid-2">
      <div class="card">
        <div class="panel-header"><h3>Registrar cliente</h3></div>
        <form id="customerForm">
          <div class="form-grid">
            <label>
              Nombre
              <input name="customerName" type="text" required />
            </label>
            <label>
              Segmento
              <select name="customerSegment">
                <option value="Retail">Retail</option>
                <option value="Mayorista">Mayorista</option>
                <option value="Distribución">Distribución</option>
                <option value="VIP">VIP</option>
              </select>
            </label>
            <label>
              Email
              <input name="customerEmail" type="email" />
            </label>
            <label>
              Teléfono
              <input name="customerPhone" type="text" />
            </label>
          </div>
          <div style="margin-top:16px; display:flex; gap:10px;">
            <button type="submit" class="primary-btn">Guardar</button>
          </div>
        </form>
      </div>

      <div class="card">
        <div class="panel-header"><h3>Listado de clientes</h3></div>
        <div class="table-wrap">
          <table>
            <thead><tr><th>Nombre</th><th>Email</th><th>Teléfono</th><th>Segmento</th><th></th></tr></thead>
            <tbody>
              ${appState.customers.map((customer) => `
                <tr>
                  <td>${customer.name}</td>
                  <td>${customer.email || '-'}</td>
                  <td>${customer.phone || '-'}</td>
                  <td>${customer.segment || '-'}</td>
                  <td>
                    <div style="display:flex;gap:8px;">
                      <button class="secondary-btn" data-edit-customer="${customer.id}">Editar</button>
                      <button class="danger-btn" data-delete-customer="${customer.id}">Eliminar</button>
                    </div>
                  </td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  `;

  document.getElementById('customerForm').addEventListener('submit', saveCustomerFromForm);

  app.querySelectorAll('[data-delete-customer]').forEach((button) => {
    button.addEventListener('click', () => deleteCustomer(button.dataset.deleteCustomer));
  });

  app.querySelectorAll('[data-edit-customer]').forEach((button) => {
    button.addEventListener('click', () => {
      const id = Number(button.dataset.editCustomer);
      const customer = appState.customers.find((item) => Number(item.id) === id);
      if (!customer) return;

      const form = document.getElementById('customerForm');
      form.dataset.customerId = id;
      form.customerName.value = customer.name || '';
      form.customerEmail.value = customer.email || '';
      form.customerPhone.value = customer.phone || '';
      form.customerSegment.value = customer.segment || 'Retail';
      form.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
  });
}

function renderSales() {
  pageTitle.textContent = 'Ventas';
  app.innerHTML = `
    <div class="card">
      <div class="panel-header"><h3>Historial de ventas</h3></div>
      <div class="table-wrap">
        <table>
          <thead><tr><th>ID</th><th>Cliente</th><th>Monto</th><th>Estado</th></tr></thead>
          <tbody>
            ${appState.sales.map((sale) => `
              <tr>
                <td>${sale.id}</td>
                <td>${sale.customer}</td>
                <td>${formatCurrency(sale.total)}</td>
                <td><span class="badge ${sale.status === 'Pagado' ? 'success' : 'warning'}">${sale.status}</span></td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      </div>
    </div>
  `;
}

function renderFinance() {
  pageTitle.textContent = 'Finanzas';
  app.innerHTML = `
    <div class="grid-2">
      <div class="card">
        <div class="panel-header"><h3>Ingresos</h3></div>
        <p class="metric-value">${formatCurrency(getTotalSales())}</p>
      </div>
      <div class="card">
        <div class="panel-header"><h3>Gastos estimados</h3></div>
        <p class="metric-value">${formatCurrency(18500)}</p>
      </div>
    </div>
  `;
}

function renderPage() {
  switch (currentTab) {
    case 'pos': renderPos(); break;
    case 'inventory': renderInventory(); break;
    case 'customers': renderCustomers(); break;
    case 'sales': renderSales(); break;
    case 'finance': renderFinance(); break;
    case 'dashboard':
    default: renderDashboard(); break;
  }
}

function exportCsv() {
  const rows = [
    ['Tipo', 'Nombre', 'Precio', 'Stock', 'Total'],
    ...appState.products.map((p) => ['Producto', p.name, p.price, p.stock, '']),
    ...appState.customers.map((c) => ['Cliente', c.name, c.email || '', c.phone || '', c.segment || '']),
    ...appState.sales.map((s) => ['Venta', s.customer, '', '', s.total]),
  ];

  const csv = rows.map((r) => r.map((v) => `"${String(v ?? '').replace(/"/g, '""')}"`).join(',')).join('\n');
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = 'nexus-erp-export.csv';
  a.click();
  URL.revokeObjectURL(url);
}

function openReceiptWindow(total, receiptItems = []) {
  const items = receiptItems.length ? receiptItems : appState.cart;
  const receiptHtml = `
    <html>
      <head>
        <title>Recibo Nexus ERP</title>
        <style>
          body { font-family: Arial, sans-serif; padding: 24px; color: #111; }
          .box { max-width: 380px; margin: 0 auto; border: 1px solid #ccc; padding: 20px; }
          h2 { text-align: center; margin: 0 0 12px; }
          .row { display: flex; justify-content: space-between; margin: 6px 0; }
          .total { font-size: 26px; font-weight: 700; margin-top: 18px; }
        </style>
      </head>
      <body>
        <div class="box">
          <h2>Nexus ERP Pro</h2>
          <div class="row"><span>Fecha</span><span>${new Date().toLocaleString()}</span></div>
          <div class="row"><span>Cliente</span><span>Cliente local</span></div>
          <hr />
          ${items.map((item) => `
            <div class="row">
              <span>${item.name} x${item.quantity}</span>
              <span>${formatCurrency(Number(item.price || 0) * Number(item.quantity || 0))}</span>
            </div>
          `).join('')}
          <hr />
          <div class="row total"><span>Total</span><span>${formatCurrency(total)}</span></div>
        </div>
      </body>
    </html>
  `;

  const w = window.open('', '_blank', 'width=420,height=700');
  if (!w) return;
  w.document.write(receiptHtml);
  w.document.close();
  w.focus();
  setTimeout(() => w.print(), 300);
}

async function initSupabase() {
  try {
    const res = await fetch('./config.json', { cache: 'no-store' });
    if (!res.ok) return null;
    const config = await res.json();
    if (!config.supabaseUrl || !config.supabaseKey) return null;

    const { createClient } = await import('https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm');
    supabaseClient = createClient(config.supabaseUrl, config.supabaseKey);
    return supabaseClient;
  } catch (err) {
    console.warn('Supabase no configurado:', err);
    return null;
  }
}

async function loginUser(email, password) {
  const client = await initSupabase();
  if (!client) {
    authUser = authenticateLocalUser(email, password);
    showApp();
    return;
  }

  const { data, error } = await client.auth.signInWithPassword({ email, password });
  if (error) throw error;
  authUser = data.user;
  await syncFromSupabase(client);
  showApp();
}

async function createUser(email, password) {
  const client = await initSupabase();
  if (!client) {
    const users = getLocalUsers();
    const exists = users.some((user) => user.email.toLowerCase() === email.toLowerCase());
    if (exists) {
      throw new Error('Este usuario ya existe. Intenta iniciar sesión.');
    }
    users.push({ email, password });
    saveLocalUsers(users);
    authUser = { email };
    showApp();
    return;
  }

  const { data, error } = await client.auth.signUp({ email, password });
  if (error) throw error;
  authUser = data.user;
  showApp();
}

async function syncFromSupabase(client) {
  if (!client) return;

  const tables = [
    { table: 'products', data: appState.products },
    { table: 'customers', data: appState.customers },
    { table: 'sales', data: appState.sales },
  ];

  for (const item of tables) {
    try {
      const { data, error } = await client.from(item.table).select('*');
      if (!error && Array.isArray(data) && data.length) {
        if (item.table === 'products') appState.products = data;
        if (item.table === 'customers') appState.customers = data;
        if (item.table === 'sales') appState.sales = data;
        saveState();
      }
    } catch (e) {
      console.warn(`No se pudo cargar ${item.table}:`, e);
    }
  }
}

async function syncToSupabase() {
  if (!supabaseClient) return;
  try {
    await supabaseClient.from('products').upsert(appState.products.map((p) => ({ ...p, id: String(p.id) })));
    await supabaseClient.from('customers').upsert(appState.customers.map((c) => ({ ...c, id: String(c.id) })));
    await supabaseClient.from('sales').upsert(appState.sales.map((s) => ({ ...s, id: String(s.id) })));
    alert('Sincronización completada.');
  } catch (err) {
    console.error('Sync error:', err);
    alert('No se pudo sincronizar con Supabase.');
  }
}

function showApp() {
  authScreen.style.display = 'none';
  appShell.style.display = 'flex';
  renderNav();
  renderPage();
}

function showLogin() {
  authScreen.style.display = 'grid';
  appShell.style.display = 'none';
}

authForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  authError.textContent = '';
  const email = document.getElementById('email').value.trim();
  const password = document.getElementById('password').value;

  try {
    await loginUser(email, password);
  } catch (error) {
    authError.textContent = error?.message || 'Error al iniciar sesión.';
  }
});

btnCreateAccount.addEventListener('click', async () => {
  authError.textContent = '';
  const email = document.getElementById('email').value.trim();
  const password = document.getElementById('password').value;

  try {
    await createUser(email, password);
    authError.textContent = 'Cuenta creada. Revisa tu correo para confirmar.';
  } catch (error) {
    authError.textContent = error?.message || 'Error al crear la cuenta.';
  }
});

btnLogout.addEventListener('click', async () => {
  if (supabaseClient) {
    try {
      await supabaseClient.auth.signOut();
    } catch (err) {
      console.warn('Logout Supabase error:', err);
    }
  }
  authUser = null;
  showLogin();
});

btnSync.addEventListener('click', syncToSupabase);
btnExportCsv.addEventListener('click', exportCsv);

renderNav();
renderPage();
showLogin();
