document.addEventListener("DOMContentLoaded", function() {
    
    // Función Login mejorada con roles
    document.getElementById('btn-entrar-sistema').addEventListener('click', function() {
        const u = document.getElementById('u-login').value.toLowerCase().trim();
        const p = document.getElementById('p-login').value.trim();
        
        if (p === "1234" && (u === "admin" || u === "cajero")) {
            document.getElementById('pantalla-login').style.display = 'none';
            document.getElementById('sistema-contenido').style.display = 'block';
            
            // Lógica de visibilidad de menús
            if (u === "cajero") {
                // El cajero solo ve Caja y Cierre
                document.getElementById('menu-inventario').style.display = 'none';
                document.getElementById('menu-finanzas').style.display = 'none';
                document.getElementById('menu-clientes').style.display = 'none';
                document.getElementById('pageTitle').innerText = "CAJA / POS";
            } else {
                // El admin ve todo
                document.getElementById('menu-inventario').style.display = 'block';
                document.getElementById('menu-finanzas').style.display = 'block';
                document.getElementById('menu-clientes').style.display = 'block';
                document.getElementById('pageTitle').innerText = "DASHBOARD ADMIN";
            }
        } else {
            alert("Usuario o contraseña incorrectos");
        }
    });

    // Delegación de eventos para navegación
    document.querySelector('.nav').addEventListener('click', function(e) {
        const target = e.target.closest('li');
        if (!target) return;
        
        e.preventDefault();
        const seccion = target.id.replace('menu-', '');
        document.getElementById('pageTitle').innerText = seccion.toUpperCase();
        document.getElementById('app').innerHTML = `<h3>Módulo: ${seccion.toUpperCase()}</h3><p>Contenido del módulo ${seccion} en desarrollo...</p>`;
    });

    // Cerrar sesión
    document.getElementById('btnLogout').addEventListener('click', () => location.reload());
});
