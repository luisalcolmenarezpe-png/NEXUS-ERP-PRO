const STORAGE_KEY = 'nexus-erp-pro-enterprise-v2';

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
                if (errorP) errorP.style.display = 'block';
            }
        });
    }

    const passInput = document.getElementById('p-login');
    if (passInput) {
        passInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter' && btnEntrar) btnEntrar.click();
        });
    }
});

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
        <button class="nav-item" data-tab="${item.id}" style="width: 100%; text-align: left; padding: 12px 14px; margin-bottom: 6px; background: ${currentTab === item.id ? '#0284c7' : 'transparent'}; color: ${currentTab === item.id ? '#fff' : '#94a3b8'}; border: none; border-radius: 6px; cursor: pointer; font-weight: ${currentTab === item.id ? '600' : 'normal'}; transition: all 0.2s;">
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
          <div style="display:flex; justify-content:space-between; align-items:center; padding:10px 0; border-bottom:1px solid #334155;">
            <div>
              <strong style="color:#f8fafc; font-size:14px;">${safeText(item.name)}</strong><br>
              <span style="color:#94a3b8; font-size:12px;">${formatCurrency(item.price)} c/u</span>
            </div>
            <div style="display:flex; align-items:center; gap:10px;">
              <button data-action="decrease" data-id="${item.id}" style="padding:4px 10px; background:#334155; color:white; border:none; border-radius:4px; cursor:pointer;">-</button>
              <span style="font-weight:bold; min-width:20px; text-align:center;">${item.quantity}</span>
              <button data-action="increase" data-id="${item.id}" style="padding:4px 10px; background:#334155; color:white; border:none; border-radius:4px; cursor:pointer;">+</button>
            </div>
          </div>
        `).join('')
        : '<p style="color: #64748b; text-align:center; padding:40px 0;">No hay ítems en el documento actual.</p>';

    app.innerHTML = `
      <div style="display: grid; grid-template-columns: 1fr 380px; gap: 20px; height: 100%;">
        <div style="background: #1e293b; padding: 20px; border-radius: 10px; border: 1px solid #334155; display:flex; flex-direction:column;">
          <h3 style="margin-top:0; color:#38bdf8; font-size:16px; margin-bottom:15px;">Catálogo de Productos y PLU</h3>
          <div style="flex:1; overflow-y: auto;">
            <table style="width: 100%; border-collapse: collapse; text-align: left;">
              <thead>
                <tr style="border-bottom: 2px solid #334155; color: #94a3b8; font-size: 12px; text-transform:uppercase;">
                  <th style="padding: 10px;">Producto</th>
                  <th style="padding: 10px;">Categoría</th>
                  <th style="padding: 10px;">Stock</th>
                  <th style="padding: 10px;">Precio</th>
                  <th style="padding: 10px; text-align:right;">Acción</th>
                </tr>
              </thead>
              <tbody>
                ${appState.products.map(product => `
                  <tr style="border-bottom: 1px solid #334155;">
                    <td style="padding: 12px 10px; font-weight:500;">${safeText(product.name)}</td>
                    <td style="padding: 12px 10px; color:#94a3b8; font-size:13px;">${safeText(product.category)}</td>
                    <td style="padding: 12px 10px;">${product.stock}</td>
                    <td style="padding: 12px 10px; color:#4ade80; font-weight:600;">${formatCurrency(product.price)}</td>
                    <td style="padding: 12px 10px; text-align:right;">
                      <button data-add="${product.id}" style="padding: 6px 14px; background:#0284c7; color:#fff; border:none; border-radius:4px; font-weight:600; cursor:pointer; font-size:12px;">Agregar</button>
                    </td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
          </div>
        </div>

        <div style="background: #1e293b; padding: 20px; border-radius: 10px; border: 1px solid #334155; display: flex; flex-direction: column; justify-content: space-between;">
          <div>
            <h3 style="margin-top:0; border-bottom:1px solid #334155; padding-bottom:12px; color:#38bdf8; font-size:16px;">Documento en Curso</h3>
            <div style="max-height: 280px; overflow-y: auto;">${cartItems}</div>
          </div>
          
          <div style="border-top: 1px solid #334155; padding-top: 15px; margin-top: 15px;">
            <div style="display:flex; justify-content:space-between; font-size:13px; color:#94a3b8; margin-bottom:5px;">
              <span>Subtotal:</span><span>${formatCurrency(subtotal)}</span>
            </div>
            <div style="display:flex; justify-content:space-between; font-size:13px; color:#94a3b8; margin-bottom:10px;">
              <span>IVA (${appState.config.ivaGeneral}%):</span><span>${formatCurrency(ivaAmount)}</span>
            </div>
            <div style="display:flex; justify-content:space-between; font-size:20px; font-weight:bold; color: #4ade80; margin-bottom:15px;">
              <span>TOTAL:</span><span>${formatCurrency(totalGeneral)}</span>
            </div>
            <div style="display:flex; gap:10px;">
              <button id="checkoutBtn" style="flex:1; padding:12px; background:#16a34a; color:white; font-weight:bold; border:none; border-radius:6px; cursor:pointer; font-size:15px;">PAGAR / FACTURAR</button>
              <button id="clearCartBtn" style="padding:12px; background:#dc2626; color:white; font-weight:bold; border:none; border-radius:6px; cursor:pointer;">Vaciar</button>
            </div>
          </div>
        </div>
      </div>
    `;

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

function renderReportes() {
    const pageTitle = document.getElementById('pageTitle');
    const app = document.getElementById('app');
    if (pageTitle) pageTitle.textContent = 'Reportes Fiscales Obligatorios';
    if (!app) return;
    
    app.innerHTML = `
      <div style="background: #1e293b; padding: 25px; border-radius: 10px; border: 1px solid #334155; max-width: 750px;">
        <h3 style="color: #38bdf8; margin-top: 0; font-size: 18px;">Módulo de Cierres y Auditoría (Impresora Fiscal)</h3>
        <p style="color: #94a3b8; font-size: 14px; line-height: 1.5;">Seleccione el tipo de reporte fiscal requerido según normativas legales:</p>
        
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 25px;">
          <div style="background:#0f172a; padding:20px; border-radius:8px; border:1px solid #334155;">
            <h4 style="color:#4ade80; margin-top:0;">Reporte X (Lectura Diaria)</h4>
            <p style="color:#94a3b8; font-size:13px;">Muestra las ventas totales acumuladas del día sin reiniciar contadores ni memoria fiscal.</p>
            <button style="width:100%; padding: 12px; background: #0284c7; color: white; border: none; border-radius: 6px; font-weight: bold; cursor: pointer; margin-top:10px;" onclick="alert('Imprimiendo Reporte X en impresora fiscal...')">Generar Reporte X</button>
          </div>
          <div style="background:#0f172a; padding:20px; border-radius:8px; border:1px solid #334155;">
            <h4 style="color:#f87171; margin-top:0;">Reporte Z (Cierre Diario)</h4>
            <p style="color:#94a3b8; font-size:13px;">Ejecuta el cierre definitivo de caja, reinicia contadores diarios y descarga memoria fiscal.</p>
            <button style="width:100%; padding: 12px; background: #dc2626; color: white; border: none; border-radius: 6px; font-weight: bold; cursor: pointer; margin-top:10px;" onclick="confirm('¿Está seguro de emitir el Cierre Z? Esta acción es irreversible.') && alert('¡Cierre Z emitido y caja cerrada con éxito!')">Generar Reporte Z</button>
          </div>
        </div>
      </div>
    `;
}

function renderInventory() {
    const pageTitle = document.getElementById('pageTitle');
    const app = document.getElementById('app');
    if (pageTitle) pageTitle.textContent = 'Gestión de Inventario y PLU';
    if (!app) return;
    
    app.innerHTML = `
      <div style="display: grid; grid-template-columns: 350px 1fr; gap: 20px;">
        <div style="background: #1e293b; padding: 20px; border-radius: 10px; border: 1px solid #334155;">
          <h3 style="color: #38bdf8; margin-top: 0; font-size: 16px;">Registrar Nuevo PLU</h3>
          <form id="productForm" style="display:flex; flex-direction:column; gap:12px;">
            <label style="font-size:12px; color:#94a3b8;">Nombre del Producto
              <input type="text" name="name" required style="width:100%; padding:10px; background:#0f172a; border:1px solid #334155; color:#fff; border-radius:4px; margin-top:4px;">
            </label>
            <label style="font-size:12px; color:#94a3b8;">Categoría
              <input type="text" name="category" required style="width:100%; padding:10px; background:#0f172a; border:1px solid #334155; color:#fff; border-radius:4px; margin-top:4px;">
            </label>
            <label style="font-size:12px; color:#94a3b8;">Precio (USD)
              <input type="number" step="0.01" name="price" required style="width:100%; padding:10px; background:#0f172a; border:1px solid #334155; color:#fff; border-radius:4px; margin-top:4px;">
            </label>
            <label style="font-size:12px; color:#94a3b8;">Stock Inicial
              <input type="number" name="stock" required style="width:100%; padding:10px; background:#0f172a; border:1px solid #334155; color:#fff; border-radius:4px; margin-top:4px;">
            </label>
            <button type="submit" style="padding: 12px; background: #16a34a; color: white; font-weight: bold; border: none; border-radius: 6px; cursor: pointer; margin-top:10px;">Guardar Producto</button>
          </form>
        </div>

        <div style="background: #1e293b; padding: 20px; border-radius: 10px; border: 1px solid #334155;">
          <h3 style="color: #38bdf8; margin-top: 0; font-size: 16px;">Listado de Productos Registrados</h3>
          <div style="max-height: 450px; overflow-y:auto;">
            <table style="width: 100%; border-collapse: collapse; text-align: left;">
              <thead>
                <tr style="border-bottom: 2px solid #334155; color: #94a3b8; font-size: 12px;">
                  <th style="padding: 10px;">ID</th>
                  <th style="padding: 10px;">Nombre</th>
                  <th style="padding: 10px;">Categoría</th>
                  <th style="padding: 10px;">Precio</th>
                  <th style="padding: 10px;">Stock</th>
                  <th style="padding: 10px; text-align:right;">Acción</th>
                </tr>
              </thead>
              <tbody>
                ${appState.products.map(product => `
                  <tr style="border-bottom: 1px solid #334155;">
                    <td style="padding: 10px; color:#94a3b8;">${product.id}</td>
                    <td style="padding: 10px; font-weight:500;">${safeText(product.name)}</td>
                    <td style="padding: 10px; color:#94a3b8;">${safeText(product.category)}</td>
                    <td style="padding: 10px; color:#4ade80;">${formatCurrency(product.price)}</td>
                    <td style="padding: 10px;">${product.stock}</td>
                    <td style="padding: 10px; text-align:right;">
                      <button data-delete-prod="${product.id}" style="padding: 5px 10px; background:#dc2626; color:#fff; border:none; border-radius:4px; cursor:pointer; font-size:11px;">Eliminar</button>
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
        saveState();
