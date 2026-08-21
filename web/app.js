const STORAGE_KEY = 'nexus-erp-pro-state-v3';

const defaultState = {
  products: [
    { id: 1, name: 'Laptop Pro 14', category: 'Tecnología', price: 1200, stock: 16 },
    { id: 2, name: 'Impresora Fiscal', category: 'POS', price: 620, stock: 9 },
    { id: 3, name: 'Caja Registradora', category: 'POS', price: 310, stock: 21 },
    { id: 4, name: 'Scanner USB', category: 'Tecnología', price: 180, stock: 32 },
  ],
  cart: [],
  sales: [
    { id: 1, customer: 'Ana Gómez', total: 420, status: 'Pagado' },
    { id: 2, customer: 'Luis Ortega', total: 980, status: 'Pendiente' },
  ],
  customers: [
    { id: 1, name: 'Ana Gómez', email: 'ana@demo.com', phone: '0412-1111111', segment: 'Retail' },
    { id: 2, name: 'Luis Ortega', email: 'luis@demo.com', phone: '0414-2222222', segment: 'Mayorista' },
  ],
};

let currentTab = 'pos';
let appState = loadState();
let currentUserRole = 'cajero'; // 'admin' o 'cajero'

const app = document.getElementById('app');
const nav = document.getElementById('nav');
const pageTitle = document.getElementById('pageTitle');

function clone(data) {
  return JSON.parse(JSON.stringify(data));
}

function safeText(value) {
  return String(value ?? '').replace(/[&<>"']/g, function(m) {
    return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' }[m];
  });
}

function loadState() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return clone(defaultState);
    const parsed = JSON.parse(raw);
    return {
      products: Array.isArray(parsed.products) && parsed.products.length ? parsed.products : clone(defaultState.products),
      cart: Array.isArray(parsed.cart) ? parsed.cart : [],
      sales: Array.isArray(parsed.sales) && parsed.sales.length ? parsed.sales : clone(defaultState.sales),
      customers: Array.isArray(parsed.customers) && parsed.customers.length ? parsed.customers : clone(defaultState.customers),
    };
  } catch (err) {
    console.warn('Error cargando estado local:', err);
    return clone(defaultState);
  }
}

function saveState() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(appState));
}

function formatCurrency(value) {
  const num = Number(value || 0);
  return new Intl.NumberFormat('es-VE', { style: 'currency', currency: 'USD', maximumFractionDigits: 2 }).format(num);
}

// Inicialización general al cargar el DOM
document.addEventListener("DOMContentLoaded", function() {
    
    // Reloj dinámico superior
    setInterval(() => {
        const reloj = document.getElementById('reloj-sistema');
        if (reloj) reloj.innerText = new Date().toLocaleTimeString();
    }, 1000);

    // Sistema de Login Inteligente
    const btnEntrar = document.getElementById('btn-entrar-sistema');
    if (btnEntrar) {
        btnEntrar.addEventListener('click', function() {
            const uInput = document.getElementById('u-login').value.trim();
            const pInput = document.getElementById('p-login').value.trim();
            const modo = document.getElementById('modo-selector').value;
            const errorP = document.getElementById('error-login');
            
            if (!uInput || !pInput) {
                alert("Por favor ingrese su código y contraseña.");
                return;
            }

            if (pInput === "1234") {
                document.getElementById('pantalla-login').style.display = 'none';
                document.getElementById('sistema-contenido').style.display = 'flex';
                
                currentUserRole = uInput.toLowerCase().includes("admin") ? 'admin' : 'cajero';
                
                // Configurar vistas según el modo seleccionado en el login
                if (modo === 'set' && currentUserRole === 'admin') {
                    currentTab = 'config';
                } else if (modo === 'reporte') {
                    currentTab = 'reportes';
                } else {
                    currentTab = 'pos';
                }

                renderApp();
            } else {
                if (errorP) errorP.style.display = 'block';
            }
        });
    }

    // Tecla Enter para el login rápido
    const passInput = document.getElementById('p-login');
    if (passInput) {
        passInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') btnEntrar.click();
        });
    }

    // Botón Salir / Cerrar Sesión
    const btnLogout = document.getElementById('btnLogout');
    if (btnLogout) {
        btnLogout.addEventListener('click', () => location.reload());
    }
});

// Renderizador principal del menú y vistas
function renderNav() {
    if (!nav) return;
    
    let items = [
        { id: 'pos', label: '🛒 POS / Ventas' },
        { id: 'reportes', label: '📊 Reportes Fiscales (X/Z)' },
        { id: 'inventory', label: '📦 Inventario / PLU' },
        { id: 'customers', label: '👥 Clientes' },
        { id: 'sales', label: '💰 Historial Ventas' }
    ];

    // Si es cajero, restringimos acceso a configuraciones profundas
    if (currentUserRole === 'cajero') {
        items = items.filter(item => item.id !== 'config');
    } else {
        items.push({ id: 'config', label: '⚙️ Modo Set (Admin)' });
    }

    nav.innerHTML = items.map(item => `
        <button class="nav-item ${currentTab === item.id ? 'active' : ''}" data-tab="${item.id}" style="width: 100%; text-align: left; padding: 12px 10px; margin-bottom: 6px; background: ${currentTab === item.id ? '#334155' : 'transparent'}; color: white; border: none; border-radius: 4px; cursor: pointer; font-weight: ${currentTab === item.id ? 'bold' : 'normal'};">
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

// 1. MÓDULO POS / CAJA
function renderPos() {
    if (pageTitle) pageTitle.textContent = 'Terminal POS de Ventas';
    const cartItems = appState.cart.length
        ? appState.cart.map(item => `
          <div style="display:flex; justify-content:space-between; align-items:center; padding:8px 0; border-bottom:1px solid #334155;">
            <div>
              <strong>${safeText(item.name)}</strong><br>
              <small>${formatCurrency(item.price)} c/u</small>
            </div>
            <div style="display:flex; align-items:center; gap:8px;">
              <button class="secondary-btn" data-action="decrease" data-id="${item.id}" style="padding:2px 8px; background:#334155; color:white; border:none; border-radius:4px; cursor:pointer;">-</button>
              <span>${item.quantity}</span>
              <button class="secondary-btn" data-action="increase" data-id="${item.id}" style="padding:2px 8px; background:#334155; color:white; border:none; border-radius:4px; cursor:pointer;">+</button>
            </div>
          </div>
        `).join('')
        : '<p style="color: #94a3b8; text-align:center; padding:20px;">No hay productos en la caja.</p>';

    const totalCart = appState.cart.reduce((sum, item) => sum + Number(item.price || 0) * Number(item.quantity || 0), 0);

    app.innerHTML = `
      <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 20px;">
        <div style="background: #1e293b; padding: 20px; border-radius: 8px; border: 1px solid #334155;">
          <h3 style="margin-top:0; color:#38bdf8;">Productos Disponibles (PLU)</h3>
          <div style="max-height: 400px; overflow-y: auto;">
            <table style="width: 100%; border-collapse: collapse; text-align: left;">
              <thead>
                <tr style="border-bottom: 1px solid #334155; color: #94a3b8; font-size: 13px;">
                  <th style="padding: 8px;">Producto</th>
                  <th style="padding: 8px;">Stock</th>
                  <th style="padding: 8px;">Precio</th>
                  <th style="padding: 8px;"></th>
                </tr>
              </thead>
              <tbody>
                ${appState.products.map(product => `
                  <tr style="border-bottom: 1px solid #334155;">
                    <td style="padding: 8px;">${safeText(product.name)}</td>
                    <td style="padding: 8px;">${product.stock}</td>
                    <td style="padding: 8px;">${formatCurrency(product.price)}</td>
                    <td style="padding: 8px;"><button style="padding: 6px 12px; background:#38bdf8; color:#0f172a; border:none; border-radius:4px; font-weight:bold; cursor:pointer;" data-add-product="${product.id}">Agregar</button></td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
          </div>
        </div>

        <div style="background: #1e293b; padding: 20px; border-radius: 8px; border: 1px solid #334155; display: flex; flex-direction: column; justify-content: space-between;">
          <div>
            <h3 style="margin-top:0; border-bottom:1px solid #334155; padding-bottom:10px; color:#38bdf8;">Documento en Curso</h3>
            <div style="max-height: 250px; overflow-y: auto;">${cartItems}</div>
          </div>
          <div>
            <div style="font-size: 20px; font-weight: bold; margin: 15px 0; text-align: right; color: #4ade80;">Total: ${formatCurrency(totalCart)}</div>
            <div style="display:flex; gap:10px;">
              <button id="checkoutBtn" style="flex:1; padding:12px; background:#22c55e; color:white; font-weight:bold; border:none; border-radius:6px; cursor:pointer;">PAGAR</button>
              <button id="clearCartBtn" style="padding:12px; background:#ef4444; color:white; font-weight:bold; border:none; border-radius:6px; cursor:pointer;">Vaciar</button>
            </div>
          </div>
        </div>
      </div>
    `;

    app.querySelectorAll('[data-add-product]').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const id = Number(e.currentTarget.dataset.addProduct);
            const prod = appState.products.find(p => p.id === id);
            if (!prod || prod.stock <= 0) return;
            const existing = appState.cart.find(item => item.id === id);
            if (existing) existing.quantity += 1;
            else appState.cart.push({ id: prod.id, name: prod.name, price: prod.price, quantity: 1 });
            saveState();
            renderPos();
        });
    });

    app.querySelectorAll('[data-action]').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const { action, id } = e.currentTarget.dataset;
            const item = appState.cart.find(i => i.id === Number(id));
            if (!item) return;
            if (action === 'increase') item.quantity += 1;
            else item.quantity -= 1;
            if (item.quantity <= 0) appState.cart = appState.cart.filter(i => i.id !== Number(id));
            saveState();
            renderPos();
        });
    });

    document.getElementById('checkoutBtn')?.addEventListener('click', () => {
        if (!appState.cart.length) return alert('El carrito está vacío.');
        appState.sales.unshift({ id: Date.now(), customer: 'Cliente Mostrador', total: totalCart, status: 'Pagado' });
        appState.cart.forEach(item => {
            const p = appState.products.find(prod => prod.id === item.id);
            if (p) p.stock = Math.max(0, p.stock - item.quantity);
        });
        appState.cart = [];
        saveState();
        alert('¡Factura emitida e impresa con éxito!');
        renderPos();
    });

    document.getElementById('clearCartBtn')?.addEventListener('click', () => {
        appState.cart = [];
        saveState();
        renderPos();
    });
}

// 2. MÓDULO REPORTES FISCALES X/Z
function renderReportes() {
    if (pageTitle) pageTitle.textContent = 'Reportes Fiscales (X / Z)';
    app.innerHTML = `
      <div style="background: #1e293b; padding: 25px; border-radius: 8px; border: 1px solid #334155; max-width: 700px;">
        <h3 style="color: #38bdf8; margin-top: 0;">Módulo de Cierres y Auditoría Fiscal</h3>
        <p style="color: #94a3b8; font-size: 13px;">Seleccione el tipo de reporte fiscal requerido para la impresora:</p>
        <div style="display: flex; gap: 15px; margin-top: 20px;">
          <button style="padding: 15px 20px; background: #0284c7; color: white; border: none; border-radius: 6px; font-weight: bold; cursor: pointer;" onclick="alert('Generando Reporte X: Lectura de ventas diarias sin reinicio de memoria.')">Generar Reporte X (Lectura)</button>
          <button style="padding: 15px 20px; background: #dc2626; color: white; border: none; border-radius: 6px; font-weight: bold; cursor: pointer;" onclick="alert('Generando Reporte Z: Cierre diario ejecutado con reinicio de contadores fiscales.')">Generar Reporte Z (Cierre Caja)</button>
        </div>
      </div>
    `;
}

// 3. MÓDULO INVENTARIO
function renderInventory() {
    if (pageTitle) pageTitle.textContent = 'Inventario y PLU';
    app.innerHTML = `
      <div style="background: #1e293b; padding: 25px; border-radius: 8px; border: 1px solid #334155;">
        <h3 style="color: #38bdf8; margin-top: 0;">Gestión de Productos y PLU</h3>
        <table style="width: 100%; border-collapse: collapse; text-align: left; margin-top:15px;">
          <thead>
            <tr style="border-bottom: 1px solid #334155; color: #94a3b8; font-size: 13px;">
              <th style="padding: 10px;">Nombre</th>
              <th style="padding: 10px;">Categoría</th>
              <th style="padding: 10px;">Precio</th>
              <th style="padding: 10px;">Stock</th>
            </tr>
          </thead>
          <tbody>
            ${appState.products.map(p => `
              <tr style="border-bottom: 1px solid #334155;">
                <td style="padding: 10px;">${safeText(p.name)}</td>
                <td style="padding: 10px;">${safeText(p.category)}</td>
                <td style="padding: 10px;">${formatCurrency(p.price)}</td>
                <td style="padding: 10px;">${p.stock}</td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      </div>
    `;
}

// 4. MÓDULO CLIENTES
function renderCustomers() {
    if (pageTitle) pageTitle.textContent = 'Clientes';
    app.innerHTML = `
      <div style="background: #1e293b; padding: 25px; border-radius: 8px; border: 1px solid #334155;">
        <h3 style="color: #38bdf8; margin-top: 0;">Listado de Clientes Registrados</h3>
        <table style="width: 100%; border-collapse: collapse; text-align: left; margin-top:15px;">
          <thead>
            <tr style="border-bottom: 1px solid #334155; color: #94a3b8; font-size: 13px;">
              <th style="padding: 10px;">Nombre</th>
              <th style="padding: 10px;">Email</th>
              <th style="padding: 10px;">Teléfono</th>
              <th style="padding: 10px;">Segmento</th>
            </tr>
          </thead>
          <tbody>
            ${appState.customers.map(c => `
              <tr style="border-bottom: 1px solid #334155;">
                <td style="padding: 10px;">${safeText(c.name)}</td>
                <td style="padding: 10px;">${safeText(c.email)}</td>
                <td style="padding: 10px;">${safeText(c.phone)}</td>
                <td style="padding: 10px;">${safeText(c.segment)}</td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      </div>
    `;
}

// 5. MÓDULO VENTAS
function renderSales() {
    if (pageTitle) pageTitle.textContent = 'Historial de Ventas';
    app.innerHTML = `
      <div style="background: #1e293b; padding: 25px; border-radius: 8px; border: 1px solid #334155;">
        <h3 style="color: #38bdf8; margin-top: 0;">Registro de Transacciones</h3>
        <table style="width: 100%; border-collapse: collapse; text-align: left; margin-top:15px;">
          <thead>
            <tr style="border-bottom: 1px solid #334155; color: #94a3b8; font-size: 13px;">
              <th style="padding: 10px;">ID Venta</th>
              <th style="padding: 10px;">Cliente</th>
              <th style="padding: 10px;">Total</th>
              <th style="padding: 10px;">Estado</th>
            </tr>
          </thead>
          <tbody>
            ${appState.sales.map(s => `
              <tr style="border-bottom: 1px solid #334155;">
                <td style="padding: 10px;">${s.id}</td>
                <td style="padding: 10px;">${safeText(s.customer)}</td>
                <td style="padding: 10px;">${formatCurrency(s.total)}</td>
                <td style="padding: 10px;"><span style="padding: 4px 8px; background: #22c55e; color: white; border-radius: 4px; font-size: 11px;">${s.status}</span></td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      </div>
    `;
}

// 6. MODO SET / CONFIGURACIÓN (Solo Admin)
function renderConfig() {
    if (pageTitle) pageTitle.textContent = 'Modo Set (Configuración)';
    app.innerHTML = `
      <div style="background: #1e293b; padding: 25px; border-radius: 8px; border: 1px solid #334155; max-width: 700px;">
        <h3 style="color: #38bdf8; margin-top: 0;">Parámetros Fiscales y del Sistema</h3>
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-top: 15px;">
          <div>
            <label style="font-size: 12px; color: #94a3b8;">Razón Social</label>
            <input type="text" value="Comercial Nexus C.A." style="width:100%; padding:10px; background:#0f172a; border:1px solid #334155; color:white; border-radius:4px; margin-top:5px;">
          </div>
          <div>
            <label style="font-size: 12px; color: #94a3b8;">RIF Fiscal</label>
            <input type="text" value="J-12345678-9" style="width:100%; padding:10px; background:#0f172a; border:1px solid #334155; color:white; border-radius:4px; margin-top:5px;">
          </div>
        </div>
        <button style="margin-top: 20px; padding: 12px 20px; background: #38bdf8; color: #0f172a; font-weight: bold; border: none; border-radius: 4px; cursor: pointer;" onclick="alert('Configuración guardada con éxito.')">Guardar Cambios Set</button>
      </div>
    `;
}
