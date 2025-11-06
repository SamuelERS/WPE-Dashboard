@echo off
title Paradise-SystemLabs - Dashboard IT

:: Verificar permisos de administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Solicitando permisos de administrador...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Ya tenemos permisos admin, continuar
color 0B
cls

:: Detectar ubicacion del script automaticamente (PORTABLE)
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

echo.
echo ============================================
echo   DASHBOARD PARADISE-SYSTEMLABS - ADMIN MODE
echo ============================================
echo.
echo [OK] Ejecutando con permisos administrativos
echo [INFO] Ubicacion detectada: %SCRIPT_DIR%
echo.

:: Cambiar a directorio del dashboard
cd /d "%SCRIPT_DIR%"

:: Verificar que estamos en el directorio correcto
if not exist "Dashboard.ps1" (
    echo [ERROR] No se encuentra Dashboard.ps1 en el directorio actual
    echo [ERROR] Directorio actual: %CD%
    pause
    exit /b 1
)

echo [INFO] Iniciando dashboard...
echo [INFO] URL: http://localhost:10000
echo [INFO] Abriendo navegador automaticamente...
echo.
echo Presiona Ctrl+C para detener el dashboard
echo ============================================
echo.

:: Abrir navegador en segundo plano despues de 8 segundos
start "" cmd /c "timeout /t 8 /nobreak >nul && start http://localhost:10000"

:: Ejecutar dashboard
powershell.exe -ExecutionPolicy Bypass -NoExit -NoProfile -Command "& {cd '%SCRIPT_DIR%'; Import-Module UniversalDashboard.Community; . '.\Dashboard.ps1'}"
