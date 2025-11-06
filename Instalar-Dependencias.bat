@echo off
:: ============================================
:: INSTALADOR DE DEPENDENCIAS - WPE Dashboard
:: ============================================
:: Ejecutar UNA SOLA VEZ en cada PC nueva

title Instalador de Dependencias - WPE Dashboard

:: Verificar permisos de administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo ============================================
    echo   REQUIERE PERMISOS DE ADMINISTRADOR
    echo ============================================
    echo.
    echo Solicitando permisos administrativos...
    echo.

    :: Relanzar con permisos de admin
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Ejecutar script de PowerShell
powershell.exe -ExecutionPolicy Bypass -NoExit -File "%~dp0Instalar-Dependencias.ps1"
