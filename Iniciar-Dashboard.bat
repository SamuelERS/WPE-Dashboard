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
echo   DASHBOARD PARADISE-SYSTEMLABS v2.0
echo   Arquitectura Modular - ADMIN MODE
echo ============================================
echo.
echo ============================================
echo   INICIANDO DASHBOARD PARADISE-SYSTEMLABS
echo   Arquitectura Modular v2.0
echo ============================================
echo.

REM Ejecutar Dashboard.ps1 (v2.0 Modular) con PowerShell
powershell.exe -ExecutionPolicy Bypass -File "%~dp0Dashboard.ps1"

REM Si falla, intentar con version LEGACY como fallback
if errorlevel 1 (
    echo.
    echo [WARN] Error con Dashboard v2.0, intentando version LEGACY...
    powershell.exe -ExecutionPolicy Bypass -File "%~dp0Dashboard-LEGACY.ps1"
)

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

:: Abrir navegador moderno en segundo plano despues de 8 segundos
start "" cmd /c "timeout /t 8 /nobreak >nul && powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%SCRIPT_DIR%\Tools\Abrir-Navegador.ps1""

:: Ejecutar dashboard
powershell.exe -ExecutionPolicy Bypass -NoExit -NoProfile -Command "& {cd '%SCRIPT_DIR%'; Import-Module UniversalDashboard.Community; . '.\Dashboard.ps1'}"
