document.addEventListener("DOMContentLoaded", function() {
    const btn = document.getElementById('btn-entrar-sistema');
    const passInput = document.getElementById('p-login');

    function ejecutarLogin() {
        const u = document.getElementById('u-login').value.toLowerCase().trim();
        const p = document.getElementById('p-login').value.trim();
        const errorP = document.getElementById('error-login');
        
        if (errorP) errorP.style.display = 'none';

        if (p === "1234" && (u === "admin" || u === "cajero")) {
            document.getElementById('pantalla-login').style.display = 'none';
            document.getElementById('contenido-erp').style.display = 'block';
            
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

    if (btn) {
        btn.addEventListener('click', ejecutarLogin);
    }

    if (passInput) {
        passInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                ejecutarLogin();
            }
        });
    }
});
