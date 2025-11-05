@echo off
title Acuarios Paradise - Dashboard IT

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
echo.
echo ============================================
echo   DASHBOARD ACUARIOS PARADISE - ADMIN MODE
echo ============================================
echo.
echo [OK] Ejecutando con permisos administrativos
echo [INFO] Cambiando a directorio: C:\WPE-Dashboard
echo.

:: Cambiar a directorio del dashboard
cd /d "C:\WPE-Dashboard"

:: Verificar que estamos en el directorio correcto
if not exist "Dashboard.ps1" (
    echo [ERROR] No se encuentra Dashboard.ps1 en el directorio actual
    echo [ERROR] Directorio actual: %CD%
    pause
    exit /b 1
)

echo [INFO] Iniciando dashboard...
echo [INFO] URL: http://localhost:10000
echo.
echo Presiona Ctrl+C para detener el dashboard
echo ============================================
echo.

:: Ejecutar dashboard
powershell.exe -ExecutionPolicy Bypass -NoExit -NoProfile -Command "& {cd 'C:\WPE-Dashboard'; Import-Module UniversalDashboard.Community; . '.\Dashboard.ps1'}"
