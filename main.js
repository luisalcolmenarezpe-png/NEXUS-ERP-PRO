const { app, BrowserWindow } = require('electron');
const path = require('path');

function createWindow () {
  const win = new BrowserWindow({
    width: 1280,
    height: 800,
    title: "Nexus ERP Pro",
    webPreferences: {
      // Seguridad: no activar nodeIntegration en renderer salvo que sea necesario.
      nodeIntegration: false,
      contextIsolation: true
      // Si necesitas APIs Node en renderer, usaremos preload.js para exponerlas.
    }
  });

  // Cargar el index.html desde la carpeta web/
  win.loadFile(path.join(__dirname, 'web', 'index.html'));
}

app.whenReady().then(createWindow);

// macOS behavior
app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) createWindow();
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});
