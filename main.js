const { app, BrowserWindow, session, ipcMain } = require('electron');
const path = require('path');
const keytar = require('keytar');

const allowedSupabaseHosts = ['*.supabase.co'];
const allowedJsdelivrHosts = ['cdn.jsdelivr.net'];

function applySecurityHeaders() {
  const filter = {
    urls: ['*://*/*'],
  };

  session.defaultSession.webRequest.onHeadersReceived(filter, (details, callback) => {
    const responseHeaders = {
      ...(details.responseHeaders || {}),
      'Content-Security-Policy': [
        "default-src 'self';",
        "script-src 'self';",
        "style-src 'self' 'unsafe-inline';",
        "img-src 'self' data: blob:;",
        "font-src 'self' data:;",
        "connect-src 'self' https://*.supabase.co https://cdn.jsdelivr.net;",
        "object-src 'none';",
        "base-uri 'none';",
        "form-action 'self';",
        "frame-ancestors 'none';",
        "upgrade-insecure-requests",
      ].join(' '),
      'X-Content-Type-Options': ['nosniff'],
      'X-Frame-Options': ['DENY'],
      'Referrer-Policy': ['no-referrer'],
      'Cross-Origin-Opener-Policy': ['same-origin'],
    };

    callback({ responseHeaders });
  });
}

function createWindow() {
  const win = new BrowserWindow({
    width: 1366,
    height: 900,
    minWidth: 1100,
    minHeight: 700,
    title: 'Nexus ERP Pro',
    backgroundColor: '#0f172a',
    autoHideMenuBar: true,
    show: false,
    titleBarStyle: 'hiddenInset',
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true,
      webSecurity: true,
      allowRunningInsecureContent: false,
      enableRemoteModule: false,
      disableBlinkFeatures: 'AutomationControlled',
    },
  });

  win.webContents.setWindowOpenHandler(({ url }) => {
    const parsed = new URL(url);
    const isAllowed = parsed.origin === 'file://' || allowedSupabaseHosts.some((host) => parsed.hostname.endsWith(host.replace('*.', '')) || host.includes('*')) || allowedJsdelivrHosts.includes(parsed.hostname);
    if (!isAllowed) {
      return { action: 'deny' };
    }
    return { action: 'allow' };
  });

  win.webContents.on('will-navigate', (event, url) => {
    const parsed = new URL(url);
    const isAllowed = parsed.origin === 'file://' || allowedSupabaseHosts.some((host) => parsed.hostname.endsWith(host.replace('*.', '')) || host.includes('*')) || allowedJsdelivrHosts.includes(parsed.hostname);
    if (!isAllowed) {
      event.preventDefault();
    }
  });

  win.once('ready-to-show', () => win.show());
  win.loadFile(path.join(__dirname, 'web', 'index.html'));
}

app.disableHardwareAcceleration();
app.on('web-contents-created', (event, contents) => {
  contents.on('will-attach-webview', (attachEvent) => {
    attachEvent.preventDefault();
  });
  contents.on('new-window', (newWindowEvent, url) => {
    const parsed = new URL(url);
    const isAllowed = parsed.origin === 'file://' || allowedSupabaseHosts.some((host) => parsed.hostname.endsWith(host.replace('*.', '')) || host.includes('*')) || allowedJsdelivrHosts.includes(parsed.hostname);
    if (!isAllowed) {
      newWindowEvent.preventDefault();
    }
  });
});

// Secure IPC handlers for credential storage using system keychain
ipcMain.handle('secure-store-get', async (event, service, account) => {
  try {
    const val = await keytar.getPassword(service, account);
    return val || null;
  } catch (err) {
    console.warn('secure-store-get error:', err);
    return null;
  }
});

ipcMain.handle('secure-store-set', async (event, service, account, password) => {
  try {
    await keytar.setPassword(service, account, password);
    return true;
  } catch (err) {
    console.warn('secure-store-set error:', err);
    return false;
  }
});

ipcMain.handle('secure-store-delete', async (event, service, account) => {
  try {
    return await keytar.deletePassword(service, account);
  } catch (err) {
    console.warn('secure-store-delete error:', err);
    return false;
  }
});

app.whenReady().then(() => {
  applySecurityHeaders();
  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});
