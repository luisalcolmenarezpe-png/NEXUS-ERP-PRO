// --- MÓDULO DE GESTIÓN DE CLIENTES (customers.js) ---
import { safeText, saveState } from './state.js';

export function renderCustomers(appState) {
    const app = document.getElementById('app');
    if (!app) return;

    app.innerHTML = `
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 animate-fadeIn pb-10">
        <!-- FORMULARIO DE REGISTRO DE CLIENTE -->
        <div class="bg-[#161b26] border border-[#212a3b] rounded-2xl p-5 shadow-xl h-fit">
          <h3 class="text-base font-bold text-white mb-4 flex items-center gap-2">👥 Registrar Nuevo Cliente</h3>
          <form id="customerForm" class="space-y-4">
            <div>
              <label class="block text-xs font-medium text-slate-400 mb-1">Nombre / Razón Social</label>
              <input type="text" name="name" required class="w-full px-3.5 py-3 bg-[#0b0f15] border border-[#212a3b] rounded-xl text-white text-sm focus:ring-2 focus:ring-[#2dd4bf] focus:outline-none placeholder-slate-600">
            </div>
            <div>
              <label class="block text-xs font-medium text-slate-400 mb-1">Segmento Comercial</label>
              <select name="segment" class="w-full px-3.5 py-3 bg-[#0b0f15] border border-[#212a3b] rounded-xl text-white text-sm focus:ring-2 focus:ring-[#2dd4bf] focus:outline-none cursor-pointer">
                <option value="Retail">Retail (Detal)</option>
                <option value="Mayorista">Mayorista</option>
                <option value="VIP">Cliente VIP</option>
              </select>
            </div>
            <div>
              <label class="block text-xs font-medium text-slate-400 mb-1">Correo Electrónico</label>
              <input type="email" name="email" class="w-full px-3.5 py-3 bg-[#0b0f15] border border-[#212a3b] rounded-xl text-white text-sm focus:ring-2 focus:ring-[#2dd4bf] focus:outline-none placeholder-slate-600">
            </div>
            <div>
              <label class="block text-xs font-medium text-slate-400 mb-1">Teléfono de Contacto</label>
              <input type="text" name="phone" placeholder="0412-1234567" class="w-full px-3.5 py-3 bg-[#0b0f15] border border-[#212a3b] rounded-xl text-white text-sm focus:ring-2 focus:ring-[#2dd4bf] focus:outline-none placeholder-slate-600">
            </div>
            <button type="submit" class="w-full py-3.5 bg-gradient-to-r from-teal-500 to-[#2dd4bf] hover:from-teal-400 hover:to-teal-300 text-slate-950 font-bold rounded-xl text-sm transition-all cursor-pointer shadow-lg shadow-teal-500/20">Guardar Cliente</button>
          </form>
        </div>

        <!-- LISTADO DE CLIENTES REGISTRADOS -->
        <div class="lg:col-span-2 bg-[#161b26] border border-[#212a3b] rounded-2xl p-5 shadow-xl">
          <h3 class="text-base font-bold text-white mb-4 flex items-center gap-2">📋 Directorio Activo de Clientes</h3>
          <div class="max-h-[480px] overflow-y-auto pr-1">
            <table class="w-full text-left border-collapse">
              <thead>
                <tr class="border-b border-[#212a3b] text-[11px] font-bold text-slate-400 uppercase tracking-wider">
                  <th class="py-3 px-3">Cliente</th>
                  <th class="py-3 px-3">Segmento</th>
                  <th class="py-3 px-3">Email</th>
                  <th class="py-3 px-3">Teléfono</th>
                  <th class="py-3 px-3 text-right">Acción</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-[#212a3b]/60 text-sm">
                ${appState.customers.map(customer => `
                  <tr class="hover:bg-slate-800/30 transition-colors">
                    <td class="py-3.5 px-3 font-medium text-white">${safeText(customer.name)}</td>
                    <td class="py-3.5 px-3 text-[#2dd4bf] text-xs font-semibold">${safeText(customer.segment)}</td>
                    <td class="py-3.5 px-3 text-slate-400 text-xs">${safeText(customer.email || '-')}</td>
                    <td class="py-3.5 px-3 text-slate-400 text-xs">${safeText(customer.phone || '-')}</td>
                    <td class="py-3.5 px-3 text-right">
                      <button data-delete-cust="${customer.id}" class="px-2.5 py-1 bg-rose-500/10 hover:bg-rose-500/20 text-rose-400 border border-rose-500/20 rounded-lg text-xs font-bold transition-all cursor-pointer">Eliminar</button>
                    </td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    `;

    document.getElementById('customerForm').addEventListener('submit', (e) => {
        e.preventDefault();
        const form = e.currentTarget;
        appState.customers.push({
            id: Date.now(),
            name: form.name.value.trim(),
            segment: form.segment.value,
            email: form.email.value.trim(),
            phone: form.phone.value.trim()
        });
        saveState(appState);
        renderCustomers(appState);
    });

    app.querySelectorAll('[data-delete-cust]').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const id = Number(e.currentTarget.dataset.deleteCust);
            appState.customers = appState.customers.filter(item => item.id !== id);
            saveState(appState);
            renderCustomers(appState);
        });
    });
}
