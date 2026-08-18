import { initSupabase } from './supabaseClient.js';

async function getSupabase() {
  return await initSupabase();
}

async function getUserId(supabase) {
  const { data, error } = await supabase.auth.getUser();
  if (error) throw error;
  return data?.user?.id;
}

export async function listCustomers(page = 1, perPage = 20) {
  const supabase = await getSupabase();
  const from = (page - 1) * perPage;
  const to = from + perPage - 1;
  return await supabase.from('customers').select('*', { count: 'exact' }).range(from, to);
}

export async function listProducts(page = 1, perPage = 20) {
  const supabase = await getSupabase();
  const from = (page - 1) * perPage;
  const to = from + perPage - 1;
  return await supabase.from('products').select('*', { count: 'exact' }).range(from, to);
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
