const { spawnSync } = require('child_process');

const certFile = process.env.CERT_FILE;
const certPassword = process.env.CERT_PASSWORD;

if (!certFile || !certPassword) {
  console.warn('WARNING: No certificate configured for Windows signing. The installer will be unsigned. For production, set CERT_FILE and CERT_PASSWORD before building.');
}

const command = process.platform === 'win32' ? 'npx.cmd' : 'npx';
const result = spawnSync(command, ['electron-builder', '--win', 'nsis', '--x64'], {
  stdio: 'inherit',
  shell: false,
});

process.exit(result.status === null ? 1 : result.status);
