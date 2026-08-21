document.addEventListener("DOMContentLoaded", function() {
    
    // Reloj dinámico superior (Con protección contra nulos)
    setInterval(() => {
        const reloj = document.getElementById('reloj-sistema');
        if (reloj) {
            reloj.innerText = new Date().toLocaleTimeString();
        }
    }, 1000);

    // Sistema de Login Inteligente
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
                const pantallaLogin = document.getElementById('pantalla-login');
                const sistemaContenido = document.getElementById('sistema-contenido');
                
                if (pantallaLogin) pantallaLogin.style.display = 'none';
                if (sistemaContenido) sistemaContenido.style.display = 'flex';
                
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
                if (errorP) errorP.style.display = 'block';
            }
        });
    }

    // Tecla Enter para el login rápido
    const passInput = document.getElementById('p-login');
    if (passInput) {
        passInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter' && btnEntrar) {
                btnEntrar.click();
            }
        });
    }

    // Botón Salir / Cerrar Sesión
    const btnLogout = document.getElementById('btnLogout');
    if (btnLogout) {
        btnLogout.addEventListener('click', () => location.reload());
    }
});

// Estado global de la aplicación
let currentTab = 'pos';
let currentUserRole = 'cajero';
let appState = {
  products: [
    { id: 1, name: 'Laptop Pro 14', category: 'Tecnología', price: 1200, stock: 16 },
    { id: 2, name: 'Impresora Fiscal', category: 'POS', price: 620, stock: 9 },
    { id: 3, name: 'Caja Registradora', category: 'POS', price: 310, stock: 21 },
  ],
  cart: [],
  sales: [
    { id: 1, customer: 'Ana Gómez', total: 420, status: 'Pagado' }
  ],
  customers: [
    { id: 1, name: 'Ana Gómez', email: 'ana@demo.com', phone: '0412-1111111', segment: 'Retail' }
  ]
};

function safeText(value) {
  return String(value ?? '').replace(/[&<>"']/g, function(m) {
    return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' }[m];
  });
}

function formatCurrency(value) {
  const num = Number(value || 0);
  return new Intl.NumberFormat('es-VE', { style: 'currency', currency: 'USD', maximumFractionDigits: 2 }).format(num);
}

// Renderizador principal del menú lateral
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
    const pageTitle = document.getElementById('pageTitle');
    const app = document.getElementById('app');
    if (pageTitle) pageTitle.textContent = 'Terminal POS de Ventas';
    if (!app) return;

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
            const id = Number(e.currentTarget.dataset.add-product || e.currentTarget.getAttribute('data-add-product'));
            const prod = appState.products.find(p => p.id === id);
            if (!prod || prod.stock <= 0) return;
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

    const checkoutBtn = document.getElementById('checkoutBtn');
    if (checkoutBtn) {
        checkoutBtn.addEventListener('click', () => {
            if (!appState.cart.length) return alert('El carrito está vacío.');
            appState.sales.unshift({ id: Date.now(), customer: 'Cliente Mostrador', total: totalCart, status: 'Pagado' });
            appState.cart = [];
            alert('¡Factura emitida e impresa con éxito!');
            renderPos();
        });
    }

    const clearCartBtn = document.getElementById('clearCartBtn');
    if (clearCartBtn) {
        clearCartBtn.addEventListener('click', () => {
            appState.cart = [];
            renderPos();
        });
    }
}

// 2. REPORTES FISCALES X/Z
function renderReportes() {
    const pageTitle = document.getElementById('pageTitle');
    const app = document.getElementById('app');
    if (pageTitle) pageTitle.textContent = 'Reportes Fiscales (X / Z)';
    if (!app) return;
    
    app.innerHTML = `
      <div style="background: #1e293b; padding: 25px; border-radius: 8px; border: 1px solid #334155; max-width: 700px;">
        <h3 style="color: #38bdf8; margin-top: 0;">Módulo de Cierres y Auditoría Fiscal</h3>
        <p style="color: #94a3b8; font-size: 13px;">Seleccione el tipo de reporte fiscal requerido para la impresora:</p>
        <div style="display: flex; gap: 15px; margin-top: 20px;">
          <button style="padding: 15px 20px; background: #0284c7; color: white; border: none; border-radius: 6px; font-weight: bold; cursor: pointer;" onclick="alert('Generando Reporte X: Lectura diaria sin reinicio.')">Generar Reporte X (Lectura)</button>
          <button style="padding: 15px 20px; background: #dc2626; color: white; border: none; border-radius: 6px; font-weight: bold; cursor: pointer;" onclick="alert('Generando Reporte Z: Cierre diario ejecutado con reinicio.')">Generar Reporte Z (Cierre Caja)</button>
        </div>
      </div>
    `;
}

// 3. INVENTARIO
function renderInventory() {
    const pageTitle = document.getElementById('pageTitle');
    const app = document.getElementById('app');
    if (pageTitle) pageTitle.textContent = 'Inventario y PLU';
    if (!app) return;
    
    app.innerHTML = `<div style="background: #1e293b; padding: 25px; border-radius: 8px; border: 1px solid #334155;"><h3 style="color: #38bdf8; margin-top: 0;">Inventario Activo</h3><p>Módulo en línea.</p></div>`;
}

// 4. CLIENTES
function renderCustomers() {
    const pageTitle = document.getElementById('pageTitle');
    const app = document.getElementById('app');
    if (pageTitle) pageTitle.textContent = 'Clientes';
    if (!app) return;
    
    app.innerHTML = `<div style="background: #1e293b; padding: 25px; border-radius: 8px; border: 1px solid #334155;"><h3 style="color: #38bdf8; margin-top: 0;">Directorio de Clientes</h3><p>Módulo en línea.</p></div>`;
}

// 5. VENTAS
function renderSales() {
    const pageTitle = document.getElementById('pageTitle');
    const app = document.getElementById('app');
    if (pageTitle) pageTitle.textContent = 'Historial de Ventas';
    if (!app) return;
    
    app.innerHTML = `<div style="background: #1e293b; padding: 25px; border-radius: 8px; border: 1px solid #334155;"><h3 style="color: #38bdf8; margin-top: 0;">Transacciones Registradas</h3><p>Módulo en línea.</p></div>`;
}

// 6. MODO SET
function renderConfig() {
    const pageTitle = document.getElementById('pageTitle');
    const app = document.getElementById('app');
    if (pageTitle) pageTitle.textContent = 'Modo Set (Configuración)';
    if (!app) return;
    
    app.innerHTML = `<div style="background: #1e293b; padding: 25px; border-radius: 8px; border: 1px solid #334155;"><h3 style="color: #38bdf8; margin-top: 0;">Configuración del Sistema</h3><p>Acceso administrativo autorizado.</p></div>`;
}
