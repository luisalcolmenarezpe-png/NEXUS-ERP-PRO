const { contextBridge } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  appName: 'Nexus ERP Pro',
  platform: process.platform,
  version: process.versions.electron,
});
