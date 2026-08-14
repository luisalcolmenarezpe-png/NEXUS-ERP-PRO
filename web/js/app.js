import { initSupabase } from './supabaseClient.js';

const root = document.getElementById('app');

function renderLogin() {
  root.innerHTML = `
    <div class="card" style="max-width:420px;">
      <h2>Iniciar sesión</h2>
      <div style="display:flex;flex-direction:column;gap:8px;">
        <input id="email" type="email" placeholder="email@example.com" />
        <input id="password" type="password" placeholder="Contraseña" />
        <div style="display:flex;gap:8px;">
          <button id="btnLogin">Entrar</button>
          <button id="btnRegister">Registrar</button>
        </div>
      </div>
      <div id="loginError" style="color:#c00;margin-top:8px"></div>
    </div>
  `;

  document.getElementById('btnLogin').addEventListener('click', onLogin);
  document.getElementById('btnRegister').addEventListener('click', onRegister);
}

async function onLogin() {
  const email = document.getElementById('email').value.trim();
  const password = document.getElementById('password').value;
  const errEl = document.getElementById('loginError');
  errEl.textContent = '';

  try {
    const supabase = await initSupabase();
    const resp = await supabase.auth.signInWithPassword({ email, password });
    if (resp.error) throw resp.error;
    await showDashboard(supabase, resp.data.user);
  } catch (err) {
    console.error(err);
    errEl.textContent = err.message || String(err);
  }
}

async function onRegister() {
  const email = document.getElementById('email').value.trim();
  const password = document.getElementById('password').value;
  const errEl = document.getElementById('loginError');
  errEl.textContent = '';

  try {
    const supabase = await initSupabase();
    const resp = await supabase.auth.signUp({ email, password });
    if (resp.error) throw resp.error;
    errEl.style.color = '#080';
    errEl.textContent = 'Registro realizado. Revisa tu correo para confirmar.';
  } catch (err) {
    console.error(err);
    errEl.style.color = '#c00';
    errEl.textContent = err.message || String(err);
  }
}

async function showDashboard(supabase, user) {
  root.innerHTML = `
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px">
      <h2>Panel - ${escapeHtml(user.email || 'Usuario')}</h2>
      <div>
        <button id="btnRefresh">Refrescar</button>
        <button id="btnLogout">Cerrar sesión</button>
      </div>
    </div>
    <div id="content"></div>
  `;

  document.getElementById('btnRefresh').addEventListener('click', () => loadCustomers(supabase));
  document.getElementById('btnLogout').addEventListener('click', async () => {
    await supabase.auth.signOut();
    renderLogin();
  });

  await loadCustomers(supabase);
}

async function loadCustomers(supabase) {
  const content = document.getElementById('content');
  content.innerHTML = '<div class="card">Cargando clientes...</div>';

  try {
    const { data, error } = await supabase.from('customers').select('*').limit(100);
    if (error) throw error;
    if (!data || data.length === 0) {
      content.innerHTML = '<div class="card">No hay clientes registrados.</div>';
      return;
    }

    const rows = data.map(c => `<tr><td>${c.id}</td><td>${escapeHtml(c.name)}</td><td>${escapeHtml(c.email || '')}</td></tr>`).join('');
    content.innerHTML = `
      <div class="card">
        <h3>Clientes</h3>
        <table>
          <thead><tr><th>ID</th><th>Nombre</th><th>Email</th></tr></thead>
          <tbody>${rows}</tbody>
        </table>
      </div>
    `;
  } catch (err) {
    console.error(err);
    content.innerHTML = `<div class="card" style="color:#c00">Error cargando clientes: ${err.message || err}</div>`;
  }
}

function escapeHtml(s) {
  if (!s) return '';
  return s.replace(/[&<>"']/g, (m) => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]));
}

// Arranque
(async function bootstrap() {
  try {
    await initSupabase();
    renderLogin();
  } catch (err) {
    root.innerHTML = `<div class="card" style="color:#c00">Error inicializando la app: ${err.message || err}</div>`;
    console.error(err);
  }
})();
