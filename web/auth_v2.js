document.addEventListener("DOMContentLoaded", function() {
    const btn = document.getElementById('btn-entrar-sistema');
    const passInput = document.getElementById('p-login');

    function ejecutarLogin() {
        const uInput = document.getElementById('u-login');
        const pInput = document.getElementById('p-login');
        const pantallaLogin = document.getElementById('pantalla-login');
        const sistemaContenido = document.getElementById('sistema-contenido');
        const errorP = document.getElementById('error-login');
        
        if (!uInput || !pInput) return;

        const u = uInput.value.toLowerCase().trim();
        const p = pInput.value.trim();
        
        if (errorP) errorP.style.display = 'none';

        if (p === "1234" && (u === "admin" || u === "cajero")) {
            if (pantallaLogin) pantallaLogin.style.display = 'none';
            if (sistemaContenido) sistemaContenido.style.display = 'block';
            
            if (u === "cajero") {
                const ocultarCajero = ['menu-inventario', 'menu-finanzas', 'menu-clientes'];
                ocultarCajero.forEach(id => {
                    const el = document.getElementById(id);
                    if (el) el.style.display = 'none';
                });
            }
        } else {
            if (errorP) errorP.style.display = 'block';
        }
    }

    if (btn) btn.addEventListener('click', ejecutarLogin);
    if (passInput) {
        passInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') ejecutarLogin();
        });
    }
});
