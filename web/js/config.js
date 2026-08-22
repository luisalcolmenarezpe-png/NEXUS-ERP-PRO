// --- MÓDULO DE CONFIGURACIÓN Y MODO SET (config.js) ---
import { saveState } from './state.js';

export function renderConfig(appState) {
    const app = document.getElementById('app');
    if (!app) return;

    app.innerHTML = `
      <div class="max-w-xl bg-[#161b26] border border-[#212a3b] rounded-2xl p-6 shadow-xl animate-fadeIn pb-10">
        <h3 class="text-base font-bold text-white mb-2 flex items-center gap-2">⚙️ Modo Set / Configuración Fiscal</h3>
        <p class="text-xs text-slate-400 mb-6">Modifique los parámetros legales de la empresa, datos del RIF y tasas tributarias del sistema.</p>
        
        <form id="configForm" class="space-y-4">
          <div>
            <label class="block text-xs font-medium text-slate-400 mb-1">Razón Social / Nombre Comercial</label>
            <input type="text" name="razonSocial" value="${appState.config.razonSocial || ''}" required class="w-full px-3.5 py-3 bg-[#0b0f15] border border-[#212a3b] rounded-xl text-white text-sm focus:ring-2 focus:ring-[#2dd4bf] focus:outline-none">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-400 mb-1">RIF (Registro de Información Fiscal)</label>
            <input type="text" name="rif" value="${appState.config.rif || ''}" required class="w-full px-3.5 py-3 bg-[#0b0f15] border border-[#212a3b] rounded-xl text-white text-sm focus:ring-2 focus:ring-[#2dd4bf] focus:outline-none">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-400 mb-1">Dirección Fiscal</label>
            <input type="text" name="direccion" value="${appState.config.direccion || ''}" required class="w-full px-3.5 py-3 bg-[#0b0f15] border border-[#212a3b] rounded-xl text-white text-sm focus:ring-2 focus:ring-[#2dd4bf] focus:outline-none">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-400 mb-1">Tasa IVA General (%)</label>
            <input type="number" step="0.1" name="ivaGeneral" value="${appState.config.ivaGeneral || 16}" required class="w-full px-3.5 py-3 bg-[#0b0f15] border border-[#212a3b] rounded-xl text-white text-sm focus:ring-2 focus:ring-[#2dd4bf] focus:outline-none">
          </div>
          <button type="submit" class="w-full py-3.5 bg-gradient-to-r from-teal-500 to-[#2dd4bf] hover:from-teal-400 hover:to-teal-300 text-slate-950 font-bold rounded-xl text-sm transition-all cursor-pointer shadow-lg shadow-teal-500/20">Guardar Configuración Fiscal</button>
        </form>
      </div>
    `;

    document.getElementById('configForm').addEventListener('submit', (e) => {
        e.preventDefault();
        const form = e.currentTarget;
        appState.config.razonSocial = form.razonSocial.value.trim();
        appState.config.rif = form.rif.value.trim();
        appState.config.direccion = form.direccion.value.trim();
        appState.config.ivaGeneral = Number(form.ivaGeneral.value);
        saveState(appState);
        alert('¡Configuración fiscal actualizada correctamente!');
    });
}
