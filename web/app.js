// --- ESTADO GLOBAL Y PERSISTENCIA PROFESIONAL ---
const STORAGE_KEY = 'nexus-erp-pro-enterprise-final';

const defaultState = {
  products: [
    { id: 1, name: 'Laptop Pro 14', category: 'Tecnología', price: 1200, stock: 16 },
    { id: 2, name: 'Impresora Fiscal', category: 'POS', price: 620, stock: 9 },
    { id: 3, name: 'Caja Registradora', category: 'POS', price: 310, stock: 21 },
    { id: 4, name: 'Scanner USB de Códigos', category: 'Tecnología', price: 180, stock: 32 },
    { id: 5, name: 'Bobina de Papel Térmico', category: 'Consumibles', price: 15, stock: 120 },
  ],
  cart: [],
  sales: [
    { id: 1724001234, customer: 'Ana Gómez', total: 420.00, status: 'Pagado', fecha: '21/08/2026 14:20' },
    { id: 2724005678, customer: 'Luis Ortega', total: 980.00, status: 'Pagado', fecha: '21/08/2026 15:45' },
  ],
  customers: [
    { id: 1, name: 'Ana Gómez', email: 'ana@demo.com', phone: '0412-1111111', segment: 'Retail' },
    { id: 2, name: 'Luis Ortega', email: 'luis@demo.com', phone: '0414-2222222', segment: 'Mayorista' },
  ],
  config: {
    razonSocial: 'Comercial Nexus C.A.',
    rif: 'J-12345678-9',
    direccion: 'Av. Principal de Duaca, Lara State',
    ivaGeneral: 16
  }
};

let currentTab = 'pos';
let currentUserRole = 'cajero';
let appState = loadState();

function loadState() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return JSON.parse(JSON.stringify(defaultState));
    const parsed = JSON.parse(raw);
    return {
      products: Array.isArray(parsed.products) && parsed.products.length ? parsed.products : JSON.parse(JSON.stringify(defaultState.products)),
      cart: Array.isArray(parsed.cart) ? parsed.cart : [],
      sales: Array.isArray(parsed.sales) && parsed.sales.length ? parsed.sales : JSON.parse(JSON.stringify(defaultState.sales)),
      customers: Array.isArray(parsed.customers) && parsed.customers.length ? parsed.customers : JSON.parse(JSON.stringify(defaultState.customers)),
      config: parsed.config || defaultState.config
    };
  } catch (err) {
    return JSON.parse(JSON.stringify(defaultState));
  }
}

function saveState() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(appState));
}

function safeText(value) {
  return String(value ?? '').replace(/[&<>"']/g, function(m) {
    return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' }[m];
  });
}

function formatCurrency(value) {
  const num = Number(value || 0);
  return 'USD ' + num.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

// --- CONTROL DE ACCESO Y ARRANQUE ---
document.addEventListener("DOMContentLoaded", function() {
    setInterval(() => {
        const reloj = document.getElementById('reloj-sistema');
        if (reloj) reloj.innerText = new Date().toLocaleTimeString();
    }, 1000);

    const btnEntrar = document.getElementById('btn-entrar-sistema');
    if (btnEntrar) {
        btnEntrar.addEventListener('click', function() {
            const uInput = document.getElementById('u-login');
            const pInput = document.getElementById('p-login');
            const modoSelector = document.getElementById('modo-selector');
            const errorP = document.getElementById('error-login');
            
            const u = uInput ? uInput.value.trim() : "";
            const p = pInput ? pInput.value.trim() : "";
            const modo = modoSelector ? modoSelector.value : "pos";
            
            if (!u || !p) {
                alert("Por favor ingrese su código y contraseña.");
                return;
            }

            if (p === "1234") {
                document.getElementById('pantalla-login').style.display = 'none';
                document.getElementById('sistema-contenido').style.display = 'flex';
                
                currentUserRole = u.toLowerCase().includes("admin") ? 'admin' : 'cajero';
                
                if (modo === 'set' && currentUserRole === 'admin') {
                    currentTab = 'config';
                } else if (modo === 'reporte') {
                    currentTab = 'reportes';
                } else {
                    currentTab = 'pos';
                }

                renderApp();
            } else {
                if (errorP) errorP.classList.remove('hidden');
            }
        });
    }

    const passInput = document.getElementById('p-login');
    if (passInput) {
        passInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter' && btnEntrar) btnEntrar.click();
        });
    }

    const btnLogout = document.getElementById('btnLogout');
    if (btnLogout) {
        btnLogout.addEventListener('click', () => location.reload());
    }
});

// --- RENDERIZADOR DE NAVEGACIÓN ---
function renderNav() {
    const nav = document.getElementById('nav');
    if (!nav) return;
    
    let items = [
        { id: 'pos', label: '🛒 POS / Ventas' },
        { id: 'reportes', label: '📊 Reportes Fiscales (X/Z)' },
        { id: 'inventory', label: '📦 Inventario / PLU' },
        { id: 'customers', label: '👥 Clientes' },
        { id: 'sales', label: '💰 Historial Ventas' }
    ];

    if (currentUserRole === 'admin') {
        items.push({ id: 'config', label: '⚙️ Modo Set (Admin)' });
    }

    nav.innerHTML = items.map(item => `
        <button class="nav-item w-full flex items-center gap-3 px-4 py-3 rounded-xl font-medium text-sm transition-all duration-200 cursor-pointer ${currentTab === item.id ? 'bg-sky-500 text-slate-950 font-bold shadow-lg shadow-sky-500/20' : 'text-slate-400 hover:bg-slate-800/60 hover:text-white'}" data-tab="${item.id}">
          ${item.label}
        </button>
    `).join('');

    nav.querySelectorAll('.nav-item').forEach((button) => {
        button.addEventListener('click', () => {
            currentTab = button.dataset.tab;
            renderApp();
        });
    });
}

function renderApp() {
    renderNav();
    if (currentTab === 'pos') renderPos();
    else if (currentTab === 'reportes') renderReportes();
    else if (currentTab === 'inventory') renderInventory();
    else if (currentTab === 'customers') renderCustomers();
    else if (currentTab === 'sales') renderSales();
    else if (currentTab === 'config') renderConfig();
}

// 1. MÓDULO POS / VENTAS (100% Funcional)
function renderPos() {
    const pageTitle = document.getElementById('pageTitle');
    const app = document.getElementById('app');
    if (pageTitle) pageTitle.textContent = 'Terminal POS de Ventas Fiscales';
    if (!app) return;

    const subtotal = appState.cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    const ivaRate = Number(appState.config.ivaGeneral || 16) / 100;
    const ivaAmount = subtotal * ivaRate;
    const totalGeneral = subtotal + ivaAmount;

    const cartItems = appState.cart.length
        ? appState.cart.map(item => `
          <div class="flex justify-between items-center py-3 border-b border-slate-800">
            <div>
              <h4 class="font-semibold text-white text-sm">${safeText(item.name)}</h4>
              <span class="text-xs text-slate-400">${formatCurrency(item.price)} c/u</span>
            </div>
            <div class="flex items-center gap-2">
              <button data-action="decrease" data-id="${item.id}" class="w-7 h-7 bg-slate-800 hover:bg-slate-700 text-white rounded-lg font-bold flex items-center justify-center transition-all">-</button>
              <span class="w-6 text-center font-bold text-sm text-sky-400">${item.quantity}</span>
              <button data-action="increase" data-id="${item.id}" class="w-7 h-7 bg-slate-800 hover:bg-slate-700 text-white rounded-lg font-bold flex items-center justify-center transition-all">+</button>
            </div>
          </div>
        `).join('')
        : '<p class="text-slate-500 text-center py-12 text-sm">No hay ítems en el documento actual.</p>';

    app.innerHTML = `
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 h-full">
        <!-- CATÁLOGO DE PRODUCTOS -->
        <div class="lg:col-span-2 bg-slate-900 border border-slate-800 rounded-2xl p-5 flex flex-col h-[calc(100vh-140px)]">
          <h3 class="text-base font-bold text-white mb-4 flex items-center gap-2">📦 Catálogo de Productos y PLU</h3>
          <div class="flex-1 overflow-y-auto pr-1">
            <table class="w-full text-left border-collapse">
              <thead>
                <tr class="border-b border-slate-800 text-[11px] font-bold text-slate-400 uppercase tracking-wider">
                  <th class="py-3 px-3">Producto</th>
                  <th class="py-3 px-3">Categoría</th>
                  <th class="py-3 px-3">Stock</th>
                  <th class="py-3 px-3">Precio</th>
                  <th class="py-3 px-3 text-right">Acción</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-slate-800/60 text-sm">
                ${appState.products.map(product => `
                  <tr class="hover:bg-slate-800/40 transition-colors">
                    <td class="py-3.5 px-3 font-medium text-white">${safeText(product.name)}</td>
                    <td class="py-3.5 px-3 text-slate-400 text-xs">${safeText(product.category)}</td>
                    <td class="py-3.5 px-3 text-slate-300 font-mono">${product.stock}</td>
                    <td class="py-3.5 px-3 text-emerald-400 font-semibold font-mono">${formatCurrency(product.price)}</td>
                    <td class="py-3.5 px-3 text-right">
                      <button data-add="${product.id}" class="px-3 py-1.5 bg-sky-500 hover:bg-sky-400 active:scale-95 text-slate-950 font-bold rounded-lg text-xs transition-all cursor-pointer shadow-md shadow-sky-500/20">Agregar</button>
                    </td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
          </div>
        </div>

        <!-- CARRITO Y TOTALES -->
        <div class="bg-slate-900 border border-slate-800 rounded-2xl p-5 flex flex-col justify-between h-[calc(100vh-140px)]">
          <div>
            <h3 class="text-base font-bold text-white mb-3 pb-3 border-b border-slate-800 flex items-center gap-2">🛒 Documento en Curso</h3>
            <div class="max-height-[320px] overflow-y-auto pr-1">${cartItems}</div>
          </div>
          
          <div class="pt-4 border-t border-slate-800 mt-4 space-y-2">
            <div class="flex justify-between text-xs text-slate-400">
              <span>Subtotal:</span>
              <span class="font-mono text-white">${formatCurrency(subtotal)}</span>
            </div>
            <div class="flex justify-between text-xs text-slate-400">
              <span>IVA (${appState.config.ivaGeneral}%):</span>
              <span class="font-mono text-white">${formatCurrency(ivaAmount)}</span>
            </div>
            <div class="flex justify-between text-lg font-bold text-emerald-400 pt-2 border-t border-slate-800">
              <span>TOTAL:</span>
              <span class="font-mono">${formatCurrency(totalGeneral)}</span>
            </div>
            <div class="flex gap-2 pt-3">
              <button id="checkoutBtn" class="flex-1 py-3 px-4 bg-emerald-600 hover:bg-emerald-500 active:scale-[0.98] text-white font-bold rounded-xl shadow-lg shadow-emerald-600/20 transition-all cursor-pointer text-sm">PAGAR / FACTURAR</button>
              <button id="clearCartBtn" class="py-3 px-4 bg-rose-500/10 hover:bg-rose-500/20 text-rose-400 border border-rose-500/20 font-bold rounded-xl transition-all cursor-pointer text-sm">Vaciar</button>
            </div>
          </div>
        </div>
      </div>
    `;

    // Eventos POS
    app.querySelectorAll('[data-add]').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const id = Number(e.currentTarget.dataset.add);
            const prod = appState.products.find(item => item.id === id);
            if (!prod || prod.stock <= 0) return alert('Producto sin stock disponible.');
            const existing = appState.cart.find(item => item.id === id);
            if (existing) existing.quantity += 1;
            else appState.cart.push({ id: prod.id, name: prod.name, price: prod.price, quantity: 1 });
            renderPos();
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
            renderPos();
        });
    });

    document.getElementById('checkoutBtn')?.addEventListener('click', () => {
        if (!appState.cart.length) return alert('El documento en curso está vacío.');
        
        appState.sales.unshift({
            id: Date.now(),
            customer: 'Cliente General (Mostrador)',
            total: totalGeneral,
            status: 'Pagado',
            fecha: new Date().toLocaleString()
        });

        appState.cart.forEach(item => {
            const p = appState.products.find(prod => prod.id === item.id);
            if (p) p.stock = Math.max(0, p.stock - item.quantity);
        });

        appState.cart = [];
        saveState();
        alert('¡Factura fiscal emitida con éxito por la impresora fiscal!');
        renderPos();
    });

    document.getElementById('clearCartBtn')?.addEventListener('click', () => {
        appState.cart = [];
        renderPos();
    });
}

// 2. REPORTES FISCALES X/Z
function renderReportes() {
    const pageTitle = document.getElementById('pageTitle');
    const app = document.getElementById('app');
    if (pageTitle) pageTitle.textContent = 'Reportes Fiscales Obligatorios';
    if (!app) return;
    
    app.innerHTML = `
      <div class="max-w-3xl bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl">
        <h3 class="text-lg font-bold text-white mb-2">Módulo de Cierres y Auditoría (Impresora Fiscal)</h3>
        <p class="text-slate-400 text-sm mb-6">Seleccione el tipo de reporte fiscal requerido según normativas legales vigentes:</p>
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div class="bg-slate-950 border border-slate-800 rounded-xl p-5 flex flex-col justify-between">
            <div>
              <h4 class="font-bold text-emerald-400 text-base mb-2">Reporte X (Lectura Diaria)</h4>
              <p class="text-slate-400 text-xs leading-relaxed">Muestra las ventas totales acumuladas del día sin reiniciar contadores ni memoria fiscal de la máquina.</p>
            </div>
            <button class="mt-5 w-full py-2.5 bg-sky-500 hover:bg-sky-400 text-slate-950 font-bold rounded-xl text-xs transition-all cursor-pointer shadow-md shadow-sky-500/20" onclick="alert('Imprimiendo Reporte X en impresora fiscal...')">Generar Reporte X</button>
          </div>

          <div class="bg-slate-950 border border-slate-800 rounded-xl p-5 flex flex-col justify-between">
            <div>
              <h4 class="font-bold text-rose-400 text-base mb-2">Reporte Z (Cierre Diario)</h4>
              <p class="text-slate-400 text-xs leading-relaxed">Ejecuta el cierre definitivo de caja, reinicia contadores diarios y descarga memoria de auditoría.</p>
            </div>
            <button class="mt-5 w-full py-2.5 bg-rose-600 hover:bg-rose-500 text-white font-bold rounded-xl text-xs transition-all cursor-pointer shadow-md shadow-rose-600/20" onclick="confirm('¿Está seguro de emitir el Cierre Z? Esta acción es irreversible.') && alert('¡Cierre Z emitido y caja cerrada con éxito!')">Generar Reporte Z</button>
          </div>
        </div>
      </div>
    `;
}

// 3. INVENTARIO Y PLU (100% Funcional)
function renderInventory() {
    const pageTitle = document.getElementById('pageTitle');
    const app = document.getElementById('app');
    if (pageTitle) pageTitle.textContent = 'Gestión de Inventario y PLU';
    if (!app) return;
    
    app.innerHTML = `
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div class="bg-slate-900 border border-slate-800 rounded-2xl p-5">
          <h3 class="text-base font-bold text-white mb-4">Registrar Nuevo PLU</h3>
          <form id="productForm" class="space-y-4">
            <div>
              <label class="block text-xs font-medium text-slate-400 mb-1">Nombre del Producto</label>
              <input type="text" name="name" required class="w-full px-3 py-2.5 bg-slate-950 border border-slate-800 rounded-xl text-white text-sm focus:ring-2 focus:ring-sky-500 focus:outline-none">
            </div>
            <div>
              <label class="block text-xs font-medium text-slate-400 mb-1">Categoría</label>
              <input type="text" name="category" required class="w-full px-3 py-2.5 bg-slate-950 border border-slate-800 rounded-xl text-white text-sm focus:ring-2 focus:ring-sky-500 focus:outline-none">
            </div>
            <div>
              <label class="block text-xs font-medium text-slate-400 mb-1">Precio (USD)</label>
              <input type="number" step="0.01" name="price" required class="w-full px-3 py-2.5 bg-slate-950 border border-slate-800 rounded-xl text-white text-sm focus:ring-2 focus:ring-sky-500 focus:outline-none">
            </div>
            <div>
              <label class="block text-xs font-medium text-slate-400 mb-1">Stock Inicial</label>
              <input type="number" name="stock" required class="w-full px-3 py-2.5 bg-slate-950 border border-slate-800 rounded-xl text-white text-sm focus:ring-2 focus:ring-sky-500 focus:outline-none">
            </div>
            <button type="submit" class="w-full py-3 bg-emerald-600 hover:bg-emerald-500 text-white font-bold rounded-xl text-sm transition-all cursor-pointer shadow-lg shadow-emerald-600/20">Guardar Producto</button>
          </form>
        </div>

        <div class="lg:col-span-2 bg-slate-900 border border-slate-800 rounded-2xl p-5">
          <h3 class="text-base font-bold text-white mb-4">Listado de Productos Registrados</h3>
          <div class="max-h-[450px] overflow-y-auto pr-1">
            <table class="w-full text-left border-collapse">
              <thead>
                <tr class="border-b border-slate-800 text-[11px] font-bold text-slate-400 uppercase">
                  <th class="py-3 px-3">ID</th>
                  <th class="py-3 px-3">Nombre</th>
                  <th class="py-3 px-3">Categoría</th>
                  <th class="py-3 px-3">Precio</th>
                  <th class="py-3 px-3">Stock</th>
                  <th class="py-3 px-3 text-right">Acción</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-slate-800/60 text-sm">
                ${appState.products.map(product => `
                  <tr class="hover:bg-slate-800/40">
                    <td class="py-3 px-3 text-slate-500 text-xs font-mono">${product.id}</td>
                    <td class="py-3 px-3 font-medium text-white">${safeText(product.name)}</td>
                    <td class="py-3 px-3 text-slate-400 text-xs">${safeText(product.category)}</td>
                    <td class="py-3 px-3 text-emerald-400 font-semibold font-mono">${formatCurrency(product.price)}</td>
                    <td class="py-3 px-3 text-slate-300 font-mono">${product.stock}</td>
                    <td class="py-3 px-3 text-right">
                      <button data-delete-prod="${product.id}" class="px-2.5 py-1 bg-rose-500/10 hover:bg-rose-500/20 text-rose-400 border border-rose-500/20 rounded-lg text-xs font-bold transition-all cursor-pointer">Eliminar</button>
                    </td>
                  </tr>
                `).join('')}
              </tbody>
