@echo off
title WPE-Dashboard v1.0.0 - PRODUCCION ESTABLE

:: Cambiar al directorio del script
cd /d "%~dp0"

cls
echo.
echo ============================================
echo   DASHBOARD PARADISE-SYSTEMLABS v1.0.0
echo   Arquitectura Modular - PRODUCCION ESTABLE
echo ============================================
echo.
echo [INFO] Ubicacion: %CD%
echo [INFO] Verificando archivos...
echo.

:: Verificar que Dashboard.ps1 existe
if exist "Dashboard.ps1" (
    echo [OK] Dashboard.ps1 encontrado
    echo [INFO] Iniciando dashboard...
    echo [INFO] URL: http://localhost:10000
    echo.
    echo Presiona Ctrl+C para detener el dashboard
    echo ============================================
    echo.
    
    :: Ejecutar Dashboard v1.0.0
    powershell -ExecutionPolicy Bypass -File "Dashboard.ps1"
    
    :: Si falla, intentar fallback a LEGACY
    if %errorlevel% neq 0 (
        echo.
        echo ============================================
        echo   [WARN] Error al iniciar Dashboard v1.0.0
        echo   Intentando fallback a version LEGACY...
        echo ============================================
        echo.
        powershell -ExecutionPolicy Bypass -File "Dashboard-LEGACY.ps1"
    )
) else (
    echo [ERROR] No se encontro Dashboard.ps1 en el directorio actual
    echo [ERROR] Directorio: %CD%
    echo.
    echo Verifica que el archivo existe y vuelve a intentar.
    pause
    exit /b 1
)

echo.
echo ============================================
echo   Dashboard detenido
echo ============================================
pause
