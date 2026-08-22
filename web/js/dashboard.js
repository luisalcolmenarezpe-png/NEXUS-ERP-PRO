// --- MÓDULO DE DASHBOARD / VISTA GENERAL (dashboard.js) ---
import { formatCurrency } from './state.js';

export function renderDashboard(appState) {
    const totalSalesToday = appState.sales.reduce((acc, s) => acc + (s.total || 0), 0);
    const totalProducts = appState.products.length;
    const totalCustomers = appState.customers.length;

    return `
      <div class="space-y-6 animate-fadeIn pb-10">
        
        <!-- TARJETAS SUPERIORES (KPIs) -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
          <div class="bg-[#161b26] border border-[#212a3b] rounded-2xl p-5 shadow-lg">
            <div class="flex justify-between items-start mb-3">
              <span class="text-xs font-semibold text-slate-400 uppercase tracking-wider">Total Headcount / Ventas</span>
              <div class="p-2 rounded-xl bg-teal-500/10 text-teal-400">📊</div>
            </div>
            <div class="text-2xl font-black text-white font-mono mb-1">${formatCurrency(totalSalesToday + 1245.00)}</div>
            <div class="text-[11px] text-[#2dd4bf] font-medium flex items-center gap-1">↑ +1.1% <span class="text-slate-500">from last month</span></div>
          </div>

          <div class="bg-[#161b26] border border-[#212a3b] rounded-2xl p-5 shadow-lg">
            <div class="flex justify-between items-start mb-3">
              <span class="text-xs font-semibold text-slate-400 uppercase tracking-wider">Retention Rate</span>
              <div class="p-2 rounded-xl bg-teal-500/10 text-teal-400">📈</div>
            </div>
            <div class="text-2xl font-black text-white font-mono mb-1">94.3%</div>
            <div class="text-[11px] text-[#2dd4bf] font-medium flex items-center gap-1">↑ +0.8% <span class="text-slate-500">from last month</span></div>
          </div>

          <div class="bg-[#161b26] border border-[#212a3b] rounded-2xl p-5 shadow-lg">
            <div class="flex justify-between items-start mb-3">
              <span class="text-xs font-semibold text-slate-400 uppercase tracking-wider">Productos PLU</span>
              <div class="p-2 rounded-xl bg-teal-500/10 text-teal-400">📦</div>
            </div>
            <div class="text-2xl font-black text-white font-mono mb-1">${totalProducts} ítems</div>
            <div class="text-[11px] text-slate-400 font-medium">Sincronizados en POS</div>
          </div>

          <div class="bg-[#161b26] border border-[#212a3b] rounded-2xl p-5 shadow-lg">
            <div class="flex justify-between items-start mb-3">
              <span class="text-xs font-semibold text-slate-400 uppercase tracking-wider">Directorio Clientes</span>
              <div class="p-2 rounded-xl bg-teal-500/10 text-teal-400">👥</div>
            </div>
            <div class="text-2xl font-black text-white font-mono mb-1">${totalCustomers} activos</div>
            <div class="text-[11px] text-[#2dd4bf] font-medium">Base de datos lista</div>
          </div>
        </div>

        <!-- SECCIÓN INFERIOR: TENDENCIAS Y GRÁFICOS -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
          
          <!-- Gráfico de Tendencias simulado con barras en verde menta -->
          <div class="lg:col-span-2 bg-[#161b26] border border-[#212a3b] rounded-2xl p-6 shadow-xl flex flex-col justify-between">
            <div class="flex justify-between items-center mb-4">
              <div>
                <span class="text-xs font-bold text-slate-400 uppercase tracking-wider">Headcount Trends</span>
                <h4 class="text-base font-bold text-white">Rendimiento Operativo Anual</h4>
              </div>
              <span class="text-xs font-mono text-slate-400 bg-[#0b0f15] px-3 py-1.5 rounded-xl border border-[#212a3b]">This Year ▾</span>
            </div>
            
            <div class="flex items-end gap-3 h-32 pt-4 px-2 border-b border-[#212a3b] pb-2">
              <div class="flex-1 bg-slate-800/50 rounded-t-md h-[40%] hover:bg-[#2dd4bf]/50 transition-all"></div>
              <div class="flex-1 bg-slate-800/50 rounded-t-md h-[55%] hover:bg-[#2dd4bf]/50 transition-all"></div>
              <div class="flex-1 bg-slate-800/50 rounded-t-md h-[50%] hover:bg-[#2dd4bf]/50 transition-all"></div>
              <div class="flex-1 bg-slate-800/50 rounded-t-md h-[70%] hover:bg-[#2dd4bf]/50 transition-all"></div>
              <div class="flex-1 bg-slate-800/50 rounded-t-md h-[65%] hover:bg-[#2dd4bf]/50 transition-all"></div>
              <div class="flex-1 bg-[#2dd4bf] rounded-t-md h-[95%] shadow-[0_0_15px_rgba(45,212,191,0.4)]"></div>
              <div class="flex-1 bg-slate-800/50 rounded-t-md h-[80%] hover:bg-[#2dd4bf]/50 transition-all"></div>
            </div>
            <div class="flex justify-between text-[10px] text-slate-500 uppercase font-bold pt-2 px-1">
              <span>Jan</span><span>Mar</span><span>May</span><span>Jul</span><span>Sep</span><span>Nov</span>
            </div>
          </div>

          <!-- Panel lateral fiscal -->
          <div class="bg-[#161b26] border border-[#212a3b] rounded-2xl p-6 shadow-xl flex flex-col justify-between">
            <div>
              <span class="text-xs font-bold text-slate-400 uppercase tracking-wider">Sistema Fiscal</span>
              <h4 class="text-base font-bold text-white mb-2">${appState.config.razonSocial}</h4>
              <p class="text-xs text-slate-400 leading-relaxed mb-4">RIF: <span class="text-white font-mono">${appState.config.rif}</span></p>
              <div class="p-3 bg-[#0b0f15] border border-[#212a3b] rounded-xl text-xs text-slate-300 space-y-1">
                <div>IVA General: <span class="text-[#2dd4bf] font-bold">${appState.config.ivaGeneral}%</span></div>
                <div>Estado: <span class="text-emerald-400 font-bold">Conectado</span></div>
              </div>
            </div>
            <div class="mt-6 pt-4 border-t border-[#212a3b] text-xs text-slate-500 text-center">
              Nexus ERP Pro Enterprise Core
            </div>
          </div>

        </div>

      </div>
    `;
}
