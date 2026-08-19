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

## Acceso demo

La app incluye acceso local para pruebas rápidas:

- `admin@empresa.com` / `admin123`
- `ventas@empresa.com` / `ventas123`

También puedes crear nuevas cuentas en la pantalla de login y se guardarán localmente en el navegador.

## Estructura principal

- `index.html`: redirección para GitHub Pages
- `main.js`: arranque de Electron
- `preload.js`: API segura para el renderer
- `web/index.html`: interfaz principal
- `web/styles.css`: estilos de la aplicación
- `web/app.js`: lógica de ERP/POS, login, exportación CSV y sincronización opcional

---

## Firma digital y CI para Windows

Para firmar automáticamente el instalador en GitHub Actions se necesitan dos secretos en tu repositorio:

- CERT_BASE64: el contenido del archivo .pfx codificado en Base64 (sin saltos de línea)
- CERT_PASSWORD: la contraseña del .pfx

Cómo crear CERT_BASE64 en Windows:

1. Abre PowerShell:
   [Convert]::ToBase64String([IO.File]::ReadAllBytes('C:\path\to\cert.pfx')) | Out-File cert.base64 -Encoding ascii
   Copia el contenido de cert.base64 y pégalo en el secreto CERT_BASE64.

2. En GitHub → Repository → Settings → Secrets and variables → Actions, crea CERT_BASE64 y CERT_PASSWORD.

3. Ejecuta el workflow manualmente desde Actions → Build and Sign Windows o empuja a la rama principal.

El workflow construirá, firmará (si el secreto está disponible) y creará una Release con el instalador firmado.

## Almacenamiento seguro en escritorio

La app de escritorio usa Keytar (sistema keychain) para guardar tokens de forma segura. No guardes claves en config.json ni en localStorage para la versión de escritorio.

## Recomendaciones

- Proporciona el certificado .pfx sólo en el entorno seguro de GitHub Secrets.
- Habilita Dependabot y ejecuta `npm audit` regularmente.
- Añade pruebas E2E y escaneo SCA antes de habilitar despliegues automáticos.
