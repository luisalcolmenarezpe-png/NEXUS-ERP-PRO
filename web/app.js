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
            const u = document.getElementById('u-login').value.toLowerCase().trim();
            const p = document.getElementById('p-login').value.trim();
            const modo = document.getElementById('modo-selector').value;
            const errorP = document.getElementById('error-login');
            
            if (p === "1234" && (u === "admin" || u === "cajero")) {
                document.getElementById('pantalla-login').style.display = 'none';
                document.getElementById('sistema-contenido').style.display = 'flex';
                
                // Restricciones de Cajero vs Administrador
                if (u === "cajero") {
                    document.getElementById('rol-activo').innerText = "Cajero Autorizado";
                    document.getElementById('menu-config').style.display = 'none'; // Cajero no entra a Modo Set
                } else {
                    document.getElementById('rol-activo').innerText = "Administrador Master";
                    document.getElementById('menu-config').style.display = 'block';
                }

                // Abrir directamente según el selector escogido
                cambiarVista(modo === 'reporte' ? 'reportes' : (modo === 'set' ? 'config' : 'pos'));
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

// Función global de cambio de pantallas / vistas
function cambiarVista(vista) {
    // Ocultar todas las vistas
    document.querySelectorAll('.vista-app').forEach(el => el.style.display = 'none');
    document.querySelectorAll('aside nav li').forEach(li => li.style.background = 'transparent');

    // Mostrar la vista seleccionada
    if (vista === 'pos') {
        document.getElementById('vista-pos').style.display = 'block';
        document.getElementById('menu-pos').style.background = '#334155';
        document.getElementById('pageTitle').innerText = "Terminal POS de Ventas";
    } else if (vista === 'reportes') {
        document.getElementById('vista-reportes').style.display = 'block';
        document.getElementById('menu-reportes').style.background = '#334155';
        document.getElementById('pageTitle').innerText = "Reportes Fiscales (X / Z)";
    } else if (vista === 'config') {
        document.getElementById('vista-config').style.display = 'block';
        document.getElementById('menu-config').style.background = '#334155';
        document.getElementById('pageTitle').innerText = "Configuración del Sistema (Modo Set)";
    }
}
