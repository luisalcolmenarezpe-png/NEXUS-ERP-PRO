// --- MÓDULO DE LOGIN (login.js) ---
export function renderLogin(onLoginSuccess) {
    const container = document.getElementById('login-container');
    if (!container) return;

    container.innerHTML = `
      <div class="h-full w-full flex items-center justify-center bg-[#0b0f15] absolute inset-0 z-50">
        <div class="bg-[#161b26] border border-[#212a3b] p-8 rounded-3xl shadow-2xl w-full max-w-md text-center">
          <div class="w-14 h-14 bg-[#2dd4bf] rounded-2xl mx-auto flex items-center justify-center font-black text-slate-950 text-2xl mb-4 shadow-[0_0_25px_rgba(45,212,191,0.4)]">
            N
          </div>
          <h2 class="text-xl font-bold text-white mb-1">Nexus ERP Pro</h2>
          <p class="text-xs text-slate-400 mb-6">Sistema Fiscal & POS Venezuela</p>
          
          <form id="loginForm" class="space-y-4 text-left">
            <div>
              <label class="block text-xs font-medium text-slate-400 mb-1">Usuario / Operador</label>
              <input type="text" id="userInput" value="Administrador" required class="w-full px-4 py-3 bg-[#0b0f15] border border-[#212a3b] rounded-xl text-white text-sm focus:border-[#2dd4bf] focus:outline-none">
            </div>
            <div>
              <label class="block text-xs font-medium text-slate-400 mb-1">Contraseña (PIN)</label>
              <input type="password" id="passInput" value="1234" required class="w-full px-4 py-3 bg-[#0b0f15] border border-[#212a3b] rounded-xl text-white text-sm focus:border-[#2dd4bf] focus:outline-none">
            </div>
            <button type="submit" class="w-full py-3.5 bg-gradient-to-r from-teal-500 to-[#2dd4bf] text-slate-950 font-black rounded-xl text-sm transition-all cursor-pointer shadow-lg shadow-teal-500/20 uppercase tracking-wider">
              Ingresar al Sistema
            </button>
          </form>
        </div>
      </div>
    `;

    document.getElementById('loginForm').addEventListener('submit', (e) => {
        e.preventDefault();
        const user = document.getElementById('userInput').value;
        container.style.display = 'none';
        document.getElementById('sistema-contenido').classList.remove('hidden');
        onLoginSuccess(user, 'dashboard');
    });
}
