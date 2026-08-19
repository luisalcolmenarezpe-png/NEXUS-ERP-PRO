const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  appName: 'Nexus ERP Pro',
  platform: process.platform,
  version: process.versions.electron,
  secureStore: {
    get: (service, account) => ipcRenderer.invoke('secure-store-get', service, account),
    set: (service, account, password) => ipcRenderer.invoke('secure-store-set', service, account, password),
    delete: (service, account) => ipcRenderer.invoke('secure-store-delete', service, account),
  }
});
