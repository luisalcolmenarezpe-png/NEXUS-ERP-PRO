// --- MÓDULO DE GESTIÓN DE INVENTARIO Y PLU (inventory.js) ---
import { formatCurrency, safeText, saveState } from './state.js';

export function renderInventory(appState) {
    const app = document.getElementById('app');
    if (!app) return;

    app.innerHTML = `
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 animate-fadeIn pb-10">
        <!-- FORMULARIO DE REGISTRO PLU -->
        <div class="bg-[#161b26] border border-[#212a3b] rounded-2xl p-5 shadow-xl h-fit">
          <h3 class="text-base font-bold text-white mb-4 flex items-center gap-2">📦 Registrar Nuevo PLU</h3>
          <form id="productForm" class="space-y-4">
            <div>
              <label class="block text-xs font-medium text-slate-400 mb-1">Nombre del Producto</label>
              <input type="text" name="name" required class="w-full px-3.5 py-3 bg-[#0b0f15] border border-[#212a3b] rounded-xl text-white text-sm focus:ring-2 focus:ring-[#2dd4bf] focus:outline-none placeholder-slate-600">
            </div>
            <div>
              <label class="block text-xs font-medium text-slate-400 mb-1">Categoría</label>
              <input type="text" name="category" required class="w-full px-3.5 py-3 bg-[#0b0f15] border border-[#212a3b] rounded-xl text-white text-sm focus:ring-2 focus:ring-[#2dd4bf] focus:outline-none placeholder-slate-600">
            </div>
            <div>
              <label class="block text-xs font-medium text-slate-400 mb-1">Precio (USD)</label>
              <input type="number" step="0.01" name="price" required class="w-full px-3.5 py-3 bg-[#0b0f15] border border-[#212a3b] rounded-xl text-white text-sm focus:ring-2 focus:ring-[#2dd4bf] focus:outline-none placeholder-slate-600">
            </div>
            <div>
              <label class="block text-xs font-medium text-slate-400 mb-1">Stock Inicial</label>
              <input type="number" name="stock" required class="w-full px-3.5 py-3 bg-[#0b0f15] border border-[#212a3b] rounded-xl text-white text-sm focus:ring-2 focus:ring-[#2dd4bf] focus:outline-none placeholder-slate-600">
            </div>
            <button type="submit" class="w-full py-3.5 bg-gradient-to-r from-teal-500 to-[#2dd4bf] hover:from-teal-400 hover:to-teal-300 text-slate-950 font-bold rounded-xl text-sm transition-all cursor-pointer shadow-lg shadow-teal-500/20">Guardar Producto PLU</button>
          </form>
        </div>

        <!-- LISTADO DE PRODUCTOS -->
        <div class="lg:col-span-2 bg-[#161b26] border border-[#212a3b] rounded-2xl p-5 shadow-xl">
          <h3 class="text-base font-bold text-white mb-4 flex items-center gap-2">📋 Listado de Productos Registrados</h3>
          <div class="max-h-[480px] overflow-y-auto pr-1">
            <table class="w-full text-left border-collapse">
              <thead>
                <tr class="border-b border-[#212a3b] text-[11px] font-bold text-slate-400 uppercase tracking-wider">
                  <th class="py-3 px-3">ID</th>
                  <th class="py-3 px-3">Nombre</th>
                  <th class="py-3 px-3">Categoría</th>
                  <th class="py-3 px-3">Precio</th>
                  <th class="py-3 px-3">Stock</th>
                  <th class="py-3 px-3 text-right">Acción</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-[#212a3b]/60 text-sm">
                ${appState.products.map(product => `
                  <tr class="hover:bg-slate-800/30 transition-colors">
                    <td class="py-3.5 px-3 text-slate-500 text-xs font-mono">${product.id}</td>
                    <td class="py-3.5 px-3 font-medium text-white">${safeText(product.name)}</td>
                    <td class="py-3.5 px-3 text-slate-400 text-xs">${safeText(product.category)}</td>
                    <td class="py-3.5 px-3 text-[#2dd4bf] font-semibold font-mono">${formatCurrency(product.price)}</td>
                    <td class="py-3.5 px-3 text-slate-300 font-mono">${product.stock}</td>
                    <td class="py-3.5 px-3 text-right">
                      <button data-delete-prod="${product.id}" class="px-2.5 py-1 bg-rose-500/10 hover:bg-rose-500/20 text-rose-400 border border-rose-500/20 rounded-lg text-xs font-bold transition-all cursor-pointer">Eliminar</button>
                    </td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    `;

    document.getElementById('productForm').addEventListener('submit', (e) => {
        e.preventDefault();
        const form = e.currentTarget;
        const newProd = {
            id: Date.now(),
            name: form.name.value.trim(),
            category: form.category.value.trim(),
            price: Number(form.price.value),
            stock: Number(form.stock.value)
        };
        appState.products.push(newProd);
        saveState(appState);
        renderInventory(appState);
    });

    app.querySelectorAll('[data-delete-prod]').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const id = Number(e.currentTarget.dataset.deleteProd);
            appState.products = appState.products.filter(item => item.id !== id);
            saveState(appState);
            renderInventory(appState);
        });
    });
}
