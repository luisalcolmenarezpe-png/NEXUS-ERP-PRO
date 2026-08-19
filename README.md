# Nexus ERP Pro

Aplicación ERP/POS ligera construida con Electron + HTML/CSS/JavaScript.

## ¿Por qué esta alternativa?

Se eliminó Flutter por ser pesado para este tipo de app. La solución actual es más ligera, rápida de instalar y fácil de mantener.

## Requisitos

- Node.js 18+
- npm
- Windows 10/11 para generar el instalador `.exe`

## Ejecutar localmente

Para la versión web, basta con abrir `web/index.html` en un navegador o servir la carpeta con un servidor local.

```bash
python -m http.server 8000
```

Luego entra a `http://localhost:8000`.

Para la versión de escritorio con Electron:

```bash
npm install
npm start
```

## Generar el programa para Windows

Desde Windows puedes ejecutar el archivo:

```bat
build-win.bat
```

Esto instala dependencias y genera el instalador en la carpeta `dist/`.

## GitHub Pages

El archivo `index.html` en la raíz redirige automáticamente a la app disponible en `web/index.html`.
Si publicas el repositorio en GitHub Pages, la app queda accesible sin terminal ni backend.

## Estructura principal

- `index.html`: redirección para GitHub Pages
- `main.js`: arranque de Electron
- `preload.js`: API segura para el renderer
- `web/index.html`: interfaz principal
- `web/styles.css`: estilos de la aplicación
- `web/app.js`: lógica de ERP/POS, login, exportación CSV y sincronización opcional
