@echo off
cd /d "%~dp0"
where npm >nul 2>nul
if errorlevel 1 (
  echo Error: npm no esta instalado o no esta en PATH.
  echo Instala Node.js desde https://nodejs.org/ y vuelve a ejecutar este archivo.
  pause
  exit /b 1
)

call npm install
if errorlevel 1 (
  echo Error al instalar dependencias.
  pause
  exit /b 1
)

call npm run dist:win
if errorlevel 1 (
  echo Error al generar el instalador de Windows.
  pause
  exit /b 1
)

echo.
echo Instalador generado en la carpeta dist\
pause
