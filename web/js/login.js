// --- MÓDULO DE LOGIN (login.js) - Estilo Glassmorphism Neón ---
export function renderLogin(onLoginSuccess) {
    const container = document.getElementById('login-container');
    if (!container) return;

    container.innerHTML = `
        <div class="fixed inset-0 z-50 flex items-center justify-center bg-[#070b12] bg-gradient-to-br from-[#070b12] via-[#0b192c] to-[#04111e] overflow-hidden">
            <!-- Efectos de luz ambiental de fondo -->
            <div class="absolute w-96 h-96 bg-cyan-500/10 rounded-full blur-3xl -top-20 -left-20 pointer-events-none"></div>
            <div class="absolute w-96 h-96 bg-teal-500/10 rounded-full blur-3xl -bottom-20 -right-20 pointer-events-none"></div>

            <!-- Tarjeta con efecto Glassmorphic y bordes neón -->
            <div class="relative w-full max-w-md p-8 sm:p-10 bg-[#0f172a]/40 backdrop-blur-2xl border border-cyan-500/30 rounded-3xl shadow-[0_0_50px_rgba(6,182,212,0.15)] text-center">
                
                <!-- Título minimalista estilo Space -->
                <div class="tracking-[0.3em] font-black text-2xl text-white mb-2">
                  NEXUS
                </div>
                <h2 class="text-xl font-medium text-slate-300 tracking-wide mb-8">Welcome Back</h2>
                
                <div class="space-y-5 text-left">
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1.5 ml-1">Email address / Usuario</label>
                        <input type="text" id="u-login" placeholder="example@gmail.com" class="w-full px-4 py-3.5 bg-slate-950/50 border border-cyan-500/20 rounded-2xl text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-cyan-400 focus:border-cyan-400 transition-all text-sm shadow-inner">
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1.5 ml-1">Password</label>
                        <input type="password" id="p-login" placeholder="••••••••••••" class="w-full px-4 py-3.5 bg-slate-950/50 border border-cyan-500/20 rounded-2xl text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-cyan-400 focus:border-cyan-400 transition-all text-sm shadow-inner">
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1.5 ml-1">Modo de Ingreso</label>
                        <select id="modo-selector" class="w-full px-4 py-3.5 bg-slate-950/60 border border-cyan-500/20 rounded-2xl text-white focus:outline-none focus:ring-2 focus:ring-cyan-400 focus:border-cyan-400 transition-all text-sm cursor-pointer">
                            <option value="pos" class="bg-slate-900">🛒 Modo Fiscal / Ventas (POS)</option>
                            <option value="reporte" class="bg-slate-900">📊 Modo Reporte (Fiscal X/Z)</option>
                            <option value="set" class="bg-slate-900">⚙️ Modo Set (Administrativo)</option>
                        </select>
                    </div>
                </div>

                <div class="text-right mt-2 mb-2">
                    <a href="#" onclick="alert('Clave maestra por defecto: 1234'); return false;" class="text-xs text-slate-400 hover:text-cyan-300 transition-colors">Forget Password ?</a>
                </div>

                <!-- Botón de Login Neón -->
                <button id="btn-entrar-sistema" class="w-full mt-4 py-4 px-4 bg-gradient-to-r from-cyan-500 to-teal-400 hover:from-cyan-400 hover:to-teal-300 active:scale-[0.98] text-slate-950 font-bold rounded-2xl transition-all cursor-pointer shadow-[0_0_20px_rgba(6,182,212,0.4)] text-base tracking-wide">
                    Login
                </button>

                <div class="mt-6 text-xs text-slate-400">
                    Are You New Member ? <span class="text-cyan-400 font-semibold cursor-pointer hover:underline" onclick="alert('Módulo de registro exclusivo para administradores.')">Sign UP</span>
                </div>

                <p id="error-login" class="hidden text-rose-400 text-xs mt-3 font-medium">Credenciales incorrectas (Usa la clave 1234).</p>
            </div>
        </div>
    `;

    const btnEntrar = document.getElementById('btn-entrar-sistema');
    const passInput = document.getElementById('p-login');

    const ejecutarLogin = () => {
        const u = document.getElementById('u-login').value.trim();
        const p = passInput.value.trim();
        const modo = document.getElementById('modo-selector').value;

        if (p === "1234" && u) {
            container.style.display = 'none';
            document.getElementById('sistema-contenido').style.display = 'flex';
            onLoginSuccess(u, modo);
        } else {
            document.getElementById('error-login').classList.remove('hidden');
        }
    };

    btnEntrar.addEventListener('click', ejecutarLogin);
    passInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') ejecutarLogin();
    });
}
