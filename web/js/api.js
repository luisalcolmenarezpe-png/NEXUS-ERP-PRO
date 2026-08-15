// web/js/api.js
import { initSupabase } from './supabaseClient.js';

async function getSupabase() {
  return await initSupabase();
}

// Helper to get current user id
async function getUserId(supabase) {
  const { data, error } = await supabase.auth.getUser();
  if (error) throw error;
  const user = data?.user;
  if (!user) throw new Error('Usuario no autenticado. Inicia sesión.');
  return user.id;
}

// Customers
export async function listCustomers(page = 1, perPage = 20) {
  const supabase = await getSupabase();
  const from = (page - 1) * perPage;
  const to = from + perPage - 1;
  const resp = await supabase
    .from('customers')
    .select('*', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(from, to);
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

// Products
export async function listProducts(page = 1, perPage = 20) {
  const supabase = await getSupabase();
  const from = (page - 1) * perPage;
  const to = from + perPage - 1;
  const resp = await supabase
    .from('products')
    .select('*', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(from, to);
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

// Invoices (basic)
export async function listInvoices(page = 1, perPage = 20) {
  const supabase = await getSupabase();
  const from = (page - 1) * perPage;
  const to = from + perPage - 1;
  const resp = await supabase
    .from('invoices')
    .select('*, invoice_items(*)', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(from, to);
  return { data: resp.data, error: resp.error, count: resp.count };
}

export async function createInvoice(payload, items) {
  const supabase = await getSupabase();
  const owner = await getUserId(supabase);
  // Insert invoice with owner
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
