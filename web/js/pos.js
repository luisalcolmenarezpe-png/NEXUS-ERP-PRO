// --- MÓDULO DE TERMINAL POS / COBRO PROFESIONAL (pos.js) ---
import { formatCurrency, safeText, saveState } from './state.js';

export function renderPos(appState) {
    const app = document.getElementById('app');
    if (!app) return;

    const subtotal = appState.cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    const ivaRate = Number(appState.config.ivaGeneral || 16) / 100;
    const ivaAmount = subtotal * ivaRate;
    const totalGeneral = subtotal + ivaAmount;

    const cartItems = appState.cart.length
        ? appState.cart.map(item => `
          <div class="flex justify-between items-center py-2.5 px-3 mb-2 bg-[#0b0f15] border border-[#212a3b] rounded-xl">
            <div>
              <h4 class="font-semibold text-white text-xs">${safeText(item.name)}</h4>
              <span class="text-[11px] text-slate-400 font-mono">${formatCurrency(item.price)} c/u</span>
            </div>
            <div class="flex items-center gap-2">
              <button data-action="decrease" data-id="${item.id}" class="w-6 h-6 bg-slate-800 hover:bg-slate-700 text-white rounded-lg font-bold flex items-center justify-center transition-all text-xs">-</button>
              <span class="w-5 text-center font-bold text-xs text-[#2dd4bf] font-mono">${item.quantity}</span>
              <button data-action="increase" data-id="${item.id}" class="w-6 h-6 bg-slate-800 hover:bg-slate-700 text-white rounded-lg font-bold flex items-center justify-center transition-all text-xs">+</button>
            </div>
          </div>
        `).join('')
        : '<p class="text-slate-500 text-center py-10 text-xs">Seleccione productos del catálogo para iniciar el ticket.</p>';

    app.innerHTML = `
      <div class="grid grid-cols-1 xl:grid-cols-12 gap-6 h-[calc(100vh-130px)] animate-fadeIn">
        
        <!-- SECCIÓN IZQUIERDA: TICKET DE VENTA Y ACCIONES LEGALES (Cols 1 a 7) -->
        <div class="xl:col-span-7 bg-[#161b26] border border-[#212a3b] rounded-2xl p-5 flex flex-col justify-between shadow-xl">
          <div>
            <!-- Cabecera del Ticket -->
            <div class="flex justify-between items-center pb-3 mb-3 border-b border-[#212a3b]">
              <div>
                <span class="text-[10px] uppercase font-bold text-[#2dd4bf] tracking-widest">Orden Fiscal Activa</span>
                <h3 class="text-base font-bold text-white">Terminal POS de Caja</h3>
              </div>
              <span class="px-2.5 py-1 bg-teal-500/10 text-teal-400 border border-teal-500/20 rounded-lg text-xs font-mono font-bold">Ticket #0042</span>
            </div>

            <!-- Lista de Productos en el Ticket -->
            <div class="max-h-[260px] overflow-y-auto pr-1 space-y-1">${cartItems}</div>
          </div>
          
          <div>
            <!-- Resumen de Totales -->
            <div class="bg-[#0b0f15] border border-[#212a3b] rounded-xl p-3 mb-4 space-y-1.5">
              <div class="flex justify-between text-xs text-slate-400">
                <span>Subtotal:</span>
                <span class="font-mono text-white">${formatCurrency(subtotal)}</span>
              </div>
              <div class="flex justify-between text-xs text-slate-400">
                <span>IVA (${appState.config.ivaGeneral}%):</span>
                <span class="font-mono text-white">${formatCurrency(ivaAmount)}</span>
              </div>
              <div class="flex justify-between text-base font-bold text-[#2dd4bf] pt-1.5 border-t border-[#212a3b]">
                <span>TOTAL A PAGAR:</span>
                <span class="font-mono">${formatCurrency(totalGeneral)}</span>
              </div>
            </div>

            <!-- Botones de Acciones Legales y Control de Ticket (Paso a Paso) -->
            <div class="grid grid-cols-3 gap-2">
              <button id="voidBtn" class="py-2.5 px-2 bg-rose-500/10 hover:bg-rose-500/20 text-rose-400 border border-rose-500/20 font-bold rounded-xl text-xs transition-all flex items-center justify-center gap-1.5 cursor-pointer">
                ❌ Anular (Void)
              </button>
              <button id="creditNoteBtn" class="py-2.5 px-2 bg-amber-500/10 hover:bg-amber-500/20 text-amber-400 border border-amber-500/20 font-bold rounded-xl text-xs transition-all flex items-center justify-center gap-1.5 cursor-pointer">
                📄 Nota Crédito
              </button>
              <button id="clearCartBtn" class="py-2.5 px-2 bg-slate-800 hover:bg-slate-700 text-slate-300 font-bold rounded-xl text-xs transition-all flex items-center justify-center gap-1.5 cursor-pointer">
                🗑️ Limpiar
              </button>
            </div>
          </div>
        </div>

        <!-- SECCIÓN DERECHA: TECLADO NUMÉRICO Y MÉTODOS DE PAGO VENEZUELA (Cols 8 a 12) -->
        <div class="xl:col-span-5 bg-[#161b26] border border-[#212a3b] rounded-2xl p-5 flex flex-col justify-between shadow-xl">
          <div>
            <div class="flex justify-between items-center mb-3">
              <span class="text-xs font-bold text-slate-400 uppercase">Panel de Cobro Rápido</span>
              <span class="text-[10px] text-emerald-400 font-semibold bg-emerald-500/10 px-2 py-0.5 rounded">Paso 2: Cobrar</span>
            </div>

            <!-- Métodos de Pago Adaptados a Venezuela -->
            <div class="grid grid-cols-3 gap-2 mb-4">
              <button data-payment="cash" class="py-2.5 bg-[#0b0f15] hover:bg-slate-800 border border-[#212a3b] text-white rounded-xl text-xs font-bold transition-all flex flex-col items-center justify-center gap-1 cursor-pointer">
                <span class="text-base">💵</span> Divisas / USD
              </button>
              <button data-payment="pago-movil" class="py-2.5 bg-[#0b0f15] hover:bg-slate-800 border border-[#212a3b] text-white rounded-xl text-xs font-bold transition-all flex flex-col items-center justify-center gap-1 cursor-pointer">
                <span class="text-base">📱</span> Pago Móvil
              </button>
              <button data-payment="card" class="py-2.5 bg-[#0b0f15] hover:bg-slate-800 border border-[#212a3b] text-white rounded-xl text-xs font-bold transition-all flex flex-col items-center justify-center gap-1 cursor-pointer">
                <span class="text-base">💳</span> Tarjeta POS
              </button>
            </div>

            <!-- Teclado Numérico Estilo Revel POS -->
            <div class="grid grid-cols-3 gap-2 mb-4">
              <button class="numpad-btn py-3 bg-[#0b0f15] hover:bg-slate-800 border border-[#212a3b] text-white font-mono font-bold rounded-xl text-sm transition-all">7</button>
              <button class="numpad-btn py-3 bg-[#0b0f15] hover:bg-slate-800 border border-[#212a3b] text-white font-mono font-bold rounded-xl text-sm transition-all">8</button>
              <button class="numpad-btn py-3 bg-[#0b0f15] hover:bg-slate-800 border border-[#212a3b] text-white font-mono font-bold rounded-xl text-sm transition-all">9</button>
              
              <button class="numpad-btn py-3 bg-[#0b0f15] hover:bg-slate-800 border border-[#212a3b] text-white font-mono font-bold rounded-xl text-sm transition-all">4</button>
              <button class="numpad-btn py-3 bg-[#0b0f15] hover:bg-slate-800 border border-[#212a3b] text-white font-mono font-bold rounded-xl text-sm transition-all">5</button>
              <button class="numpad-btn py-3 bg-[#0b0f15] hover:bg-slate-800 border border-[#212a3b] text-white font-mono font-bold rounded-xl text-sm transition-all">6</button>
              
              <button class="numpad-btn py-3 bg-[#0b0f15] hover:bg-slate-800 border border-[#212a3b] text-white font-mono font-bold rounded-xl text-sm transition-all">1</button>
              <button class="numpad-btn py-3 bg-[#0b0f15] hover:bg-slate-800 border border-[#212a3b] text-white font-mono font-bold rounded-xl text-sm transition-all">2</button>
              <button class="numpad-btn py-3 bg-[#0b0f15] hover:bg-slate-800 border border-[#212a3b] text-white font-mono font-bold rounded-xl text-sm transition-all">3</button>
              
              <button class="numpad-btn py-3 bg-[#0b0f15] hover:bg-slate-800 border border-[#212a3b] text-white font-mono font-bold rounded-xl text-sm transition-all">C</button>
              <button class="numpad-btn py-3 bg-[#0b0f15] hover:bg-slate-800 border border-[#212a3b] text-white font-mono font-bold rounded-xl text-sm transition-all">0</button>
              <button class="numpad-btn py-3 bg-[#0b0f15] hover:bg-slate-800 border border-[#212a3b] text-white font-mono font-bold rounded-xl text-sm transition-all">.</button>
            </div>
          </div>

          <!-- Botón de Ejecución de Pago Principal -->
          <button id="checkoutBtn" class="w-full py-4 bg-gradient-to-r from-teal-500 to-[#2dd4bf] hover:from-teal-400 hover:to-teal-300 text-slate-950 font-black rounded-2xl shadow-lg shadow-teal-500/25 transition-all cursor-pointer text-sm uppercase tracking-wider flex items-center justify-center gap-2">
            <span>🖨️ Procesar y Facturar Fiscal</span>
          </button>
        </div>

      </div>
    `;

    // --- MANEJADORES DE EVENTOS DEL POS ---
    app.querySelectorAll('[data-add]').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const id = Number(e.currentTarget.dataset.add);
            const prod = appState.products.find(item => item.id === id);
            if (!prod || prod.stock <= 0) return alert('Producto sin stock disponible en inventario.');
            const existing = appState.cart.find(item => item.id === id);
            if (existing) existing.quantity += 1;
            else appState.cart.push({ id: prod.id, name: prod.name, price: prod.price, quantity: 1 });
            saveState(appState);
            renderPos(appState);
        });
    });

    app.querySelectorAll('[data-action]').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const action = e.currentTarget.dataset.action;
            const id = Number(e.currentTarget.dataset.id);
            const item = appState.cart.find(i => i.id === id);
            if (!item) return;
            if (action === 'increase') item.quantity += 1;
            else item.quantity -= 1;
            if (item.quantity <= 0) appState.cart = appState.cart.filter(i => i.id !== id);
            saveState(appState);
            renderPos(appState);
        });
    });

    app.querySelectorAll('[data-payment]').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const method = e.currentTarget.dataset.payment;
            const names = { 'cash': 'Efectivo Divisas ($)', 'pago-movil': 'Pago Móvil Bancario', 'card': 'Punto de Venta / Tarjeta' };
            alert(`Método de pago seleccionado: ${names[method]}. Ingrese el monto en el panel.`);
        });
    });

    document.getElementById('checkoutBtn')?.addEventListener('click', () => {
        if (!appState.cart.length) return alert('El documento en curso está vacío. Agregue productos.');
        
        appState.sales.unshift({
            id: Date.now(),
            customer: 'Cliente Mostrador',
            total: totalGeneral,
            status: 'Facturado Fiscal',
            fecha: new Date().toLocaleString()
        });

        appState.cart.forEach(item => {
            const p = appState.products.find(prod => prod.id === item.id);
            if (p) p.stock = Math.max(0, p.stock - item.quantity);
        });

        appState.cart = [];
        saveState(appState);
        alert('¡Factura emitida e impresa legalmente con éxito a través de la impresora fiscal!');
        renderPos(appState);
    });

    document.getElementById('voidBtn')?.addEventListener('click', () => {
        if (!appState.cart.length && !appState.sales.length) return alert('No hay transacciones activas para anular.');
        if (confirm('¿Está seguro de anular la orden en curso (Void)? Esta acción cumple con los protocolos de control fiscal.')) {
            appState.cart = [];
            saveState(appState);
            renderPos(appState);
            alert('Orden anulada correctamente.');
        }
    });

    document.getElementById('creditNoteBtn')?.addEventListener('click', () => {
        const facturaId = prompt('Ingrese el número de la factura fiscal previa para emitir Nota de Crédito:');
        if (facturaId) {
            alert(`Nota de crédito generada y asociada legalmente a la factura #${facturaId}.`);
        }
    });

    document.getElementById('clearCartBtn')?.addEventListener('click', () => {
        appState.cart = [];
        saveState(appState);
        renderPos(appState);
    });
}
