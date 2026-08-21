document.addEventListener("DOMContentLoaded", function() {
    const btn = document.getElementById('btn-entrar-sistema');
    const passInput = document.getElementById('p-login');

    // Función de Login
    function ejecutarLogin() {
        const uInput = document.getElementById('u-login');
        const pInput = document.getElementById('p-login');
        const pantallaLogin = document.getElementById('pantalla-login');
        const sistemaContenido = document.getElementById('sistema-contenido');
        const errorP = document.getElementById('error-login');
        
        if (!uInput || !pInput) return;

        const u = uInput.value.toLowerCase().trim();
        const p = pInput.value.trim();
        
        if (p === "1234" && (u === "admin" || u === "cajero")) {
            if (pantallaLogin) pantallaLogin.style.display = 'none';
            if (sistemaContenido) sistemaContenido.style.display = 'block';
            
            if (u === "cajero") {
                ['menu-inventario', 'menu-finanzas', 'menu-clientes'].forEach(id => {
                    const el = document.getElementById(id);
                    if (el) el.style.display = 'none';
                });
            }
        } else {
            if (errorP) errorP.style.display = 'block';
        }
    }

    // Lógica de Navegación (Aquí está lo que faltaba)
    function navegar(seccion) {
        const appView = document.getElementById('app');
        const pageTitle = document.getElementById('pageTitle');
        if (!appView) return;

        pageTitle.innerText = seccion.charAt(0).toUpperCase() + seccion.slice(1);
        appView.innerHTML = `<h3>Sección: ${seccion}</h3><p>Cargando módulo de ${seccion}...</p>`;
    }

    // Eventos de botones
    if (btn) btn.addEventListener('click', ejecutarLogin);
    if (passInput) passInput.addEventListener('keypress', function(e) { if (e.key === 'Enter') ejecutarLogin(); });

    // Eventos de menú
    ['menu-inicio', 'menu-inventario', 'menu-finanzas', 'menu-clientes'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.addEventListener('click', (e) => {
            e.preventDefault();
            navegar(id.replace('menu-', ''));
        });
    });
});
