// Módulo para inicializar Supabase en la renderer.
// Requiere web/config.json (no subir keys al repo)
import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm';

let supabase = null;

export async function initSupabase() {
  if (supabase) return supabase;

  // Carga dinámica de config (no inyectamos claves en el HTML)
  const res = await fetch('./config.json', { cache: 'no-store' });
  if (!res.ok) throw new Error('No se encontró config.json con las credenciales de Supabase.');
  const cfg = await res.json();

  if (!cfg.supabaseUrl || !cfg.supabaseKey) {
    throw new Error('config.json inválido. Debe contener supabaseUrl y supabaseKey.');
  }

  supabase = createClient(cfg.supabaseUrl, cfg.supabaseKey);
  return supabase;
}
