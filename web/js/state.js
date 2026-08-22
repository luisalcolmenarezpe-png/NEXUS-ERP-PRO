// --- ESTADO GLOBAL Y PERSISTENCIA (state.js) ---
const STORAGE_KEY = 'nexus-erp-pro-enterprise-final';

export const defaultState = {
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

export function loadState() {
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

export function saveState(appState) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(appState));
}

export function safeText(value) {
  return String(value ?? '').replace(/[&<>"']/g, function(m) {
    return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' }[m];
  });
}

export function formatCurrency(value) {
  const num = Number(value || 0);
  return 'USD ' + num.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}
