// --- CEREBRO CENTRAL DEL SISTEMA (app.js) ---
import { loadState } from './state.js';
import { renderLogin } from './login.js';
import { renderDashboard } from './dashboard.js';
import { renderPos } from './pos.js';
import { renderInventory } from './inventory.js';
import { renderCustomers } from './customers.js';
import { renderReportes } from './reports.js';
import { renderConfig } from './config.js';

let appState = loadState();
let currentTab = 'dashboard';
let currentUserRole = 'cajero';

document.addEventListener("DOMContentLoaded", function() {
    // Reloj del sistema en tiempo real
    setInterval(() => {
        const reloj = document.getElementById('reloj-sistema');
        if (reloj) reloj.innerText = new Date().toLocaleTimeString();
    }, 1000);

    // Arrancar mostrando el microarchivo de Login
    renderLogin((usuario, modo) => {
        currentUserRole = usuario.toLowerCase().includes("admin") ? 'admin' : 'cajero';
        currentTab = modo === 'set' ? 'config' : (modo === 'reporte' ? 'reportes' : 'dashboard');
        initApp();
    });

    // Botón de Cerrar Sesión
    document.getElementById('btnLogout')?.addEventListener('click', () => location.reload());
});

function initApp() {
    renderNav();
    router();
}

function renderNav() {
    const nav = document.getElementById('nav');
    if (!nav) return;

    let items = [
        { id: 'dashboard', label: '📊 Dashboard' },
        { id: 'pos', label: '🛒 Terminal POS' },
        { id: 'inventory', label: '📦 Inventario PLU' },
        { id: 'customers', label: '👥 Clientes' },
        { id: 'reportes', label: '📑 Reportes X/Z' }
    ];

    if (currentUserRole === 'admin') {
        items.push({ id: 'config', label: '⚙️ Modo Set' });
    }

    nav.innerHTML = items.map(item => `
        <button class="nav-item w-full flex items-center px-4 py-3 rounded-xl font-medium text-sm transition-all cursor-pointer ${currentTab === item.id ? 'bg-[#2dd4bf] text-slate-950 font-bold shadow-lg shadow-teal-500/20' : 'text-slate-400 hover:bg-slate-800/60 hover:text-white'}" data-tab="${item.id}">
          ${item.label}
        </button>
    `).join('');

    nav.querySelectorAll('.nav-item').forEach(btn => {
        btn.addEventListener('click', (e) => {
            currentTab = e.currentTarget.dataset.tab;
            renderNav();
            router();
        });
    });
}

function router() {
    if (currentTab === 'dashboard') {
        document.getElementById('pageTitle').innerText = "Dashboard General y Métricas";
        document.getElementById('app').innerHTML = renderDashboard(appState);
    } else if (currentTab === 'pos') {
        document.getElementById('pageTitle').innerText = "Terminal POS y Facturación Fiscal";
        renderPos(appState);
    } else if (currentTab === 'inventory') {
        document.getElementById('pageTitle').innerText = "Gestión de Inventario y PLU";
        renderInventory(appState);
    } else if (currentTab === 'customers') {
        document.getElementById('pageTitle').innerText = "Directorio de Clientes";
        renderCustomers(appState);
    } else if (currentTab === 'reportes') {
        document.getElementById('pageTitle').innerText = "Control Fiscal de Reportes X y Z";
        renderReportes(appState);
    } else if (currentTab === 'config') {
        document.getElementById('pageTitle').innerText = "Configuración Administrativa (Modo Set)";
        renderConfig(appState);
    }
}
