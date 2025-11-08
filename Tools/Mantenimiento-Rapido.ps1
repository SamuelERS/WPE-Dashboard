<#
===========================================================
  WPE-Dashboard v1.0.0-LTS - MANTENIMIENTO RÁPIDO
  Propósito:
  - Restablecer permisos de escritura en Cache/
  - Liberar puerto 10000 si está ocupado
  Autor: Paradise System Labs
  Fecha: 2025-11-07
===========================================================
#>

#Requires -Version 5.1

# ============================================
# CONFIGURACIÓN INICIAL
# ============================================

# Establecer DashboardRoot de forma portable
if (-not $Global:DashboardRoot) {
    $Global:DashboardRoot = Split-Path -Parent $PSScriptRoot
}

# Verificar privilegios de administrador
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# ============================================
# BANNER INICIAL
# ============================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  MANTENIMIENTO RÁPIDO - WPE-DASHBOARD v1.0.0-LTS" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

if (-not $isAdmin) {
    Write-Host "[WARNING] Este script funciona mejor con privilegios de administrador." -ForegroundColor Yellow
    Write-Host "          Algunas operaciones pueden fallar sin permisos elevados." -ForegroundColor Gray
    Write-Host ""
}

# ============================================
# OPERACIÓN 1: PERMISOS DE CACHE
# ============================================

Write-Host "[1/2] Verificando y reparando permisos en Cache..." -ForegroundColor Cyan
Write-Host ""

$cachePath = Join-Path $Global:DashboardRoot "Cache"

if (Test-Path $cachePath) {
    Write-Host "      Ruta: $cachePath" -ForegroundColor Gray

    try {
        # Otorgar permisos de modificación a Usuarios
        # (OI) = Object Inherit - archivos heredan permisos
        # (CI) = Container Inherit - subcarpetas heredan permisos
        # M = Modify (leer, escribir, ejecutar, eliminar)
        $icaclsOutput = icacls $cachePath /grant "Usuarios:(OI)(CI)M" /T 2>&1

        if ($LASTEXITCODE -eq 0) {
            Write-Host "      [OK] Permisos corregidos exitosamente." -ForegroundColor Green
            Write-Host "           Usuarios: Modificacion (M) con herencia (OI)(CI)" -ForegroundColor Gray
        } else {
            Write-Host "      [ERROR] icacls retorno codigo $LASTEXITCODE" -ForegroundColor Red
            Write-Host "              $icaclsOutput" -ForegroundColor Gray
        }
    } catch {
        Write-Host "      [ERROR] No se pudieron modificar los permisos: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "      [WARNING] La carpeta Cache no existe en:" -ForegroundColor Yellow
    Write-Host "                $cachePath" -ForegroundColor Gray
    Write-Host "                Se creara automaticamente al iniciar el dashboard." -ForegroundColor Gray
}

Write-Host ""

# ============================================
# OPERACIÓN 2: LIBERAR PUERTO 10000
# ============================================

Write-Host "[2/2] Verificando puerto 10000..." -ForegroundColor Cyan
Write-Host ""

try {
    # Obtener conexiones en puerto 10000
    $portConnections = Get-NetTCPConnection -LocalPort 10000 -ErrorAction SilentlyContinue

    if ($portConnections) {
        # Filtrar solo conexiones activas (Listen o Established)
        $activeConnections = $portConnections | Where-Object {
            $_.State -eq 'Listen' -or $_.State -eq 'Established'
        }

        if ($activeConnections) {
            Write-Host "      [WARNING] Puerto 10000 ocupado por procesos activos:" -ForegroundColor Yellow

            # Obtener procesos únicos
            $processIds = $activeConnections | Select-Object -ExpandProperty OwningProcess -Unique

            foreach ($processId in $processIds) {
                try {
                    $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
                    if ($process) {
                        Write-Host "                - PID $processId ($($process.ProcessName))" -ForegroundColor Gray
                    } else {
                        Write-Host "                - PID $processId (proceso desconocido)" -ForegroundColor Gray
                    }
                } catch {
                    Write-Host "                - PID $processId (no accesible)" -ForegroundColor Gray
                }
            }

            Write-Host ""
            Write-Host "      Intentando liberar puerto..." -ForegroundColor Cyan

            # Terminar procesos
            foreach ($processId in $processIds) {
                try {
                    Stop-Process -Id $processId -Force -ErrorAction Stop
                    Write-Host "      [OK] Proceso $processId terminado." -ForegroundColor Green
                } catch {
                    Write-Host "      [ERROR] No se pudo terminar proceso $processId : $($_.Exception.Message)" -ForegroundColor Red
                }
            }

            # Esperar 3 segundos para liberación
            Start-Sleep -Seconds 3

            # Verificar nuevamente
            $portCheck = Get-NetTCPConnection -LocalPort 10000 -ErrorAction SilentlyContinue | Where-Object {
                $_.State -eq 'Listen' -or $_.State -eq 'Established'
            }

            if (-not $portCheck) {
                Write-Host "      [OK] Puerto 10000 liberado exitosamente." -ForegroundColor Green
            } else {
                Write-Host "      [WARNING] Puerto 10000 aun ocupado. Puede requerir reinicio del sistema." -ForegroundColor Yellow
            }

        } else {
            Write-Host "      [INFO] Conexiones en TimeWait detectadas (normal, se liberaran automaticamente)." -ForegroundColor Cyan
            Write-Host "      [OK] Puerto 10000 disponible para uso." -ForegroundColor Green
        }
    } else {
        Write-Host "      [OK] Puerto 10000 libre." -ForegroundColor Green
    }

} catch {
    Write-Host "      [ERROR] No se pudo verificar el puerto: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# ============================================
# RESUMEN FINAL
# ============================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Mantenimiento completado." -ForegroundColor Green
Write-Host "  Listo para iniciar Dashboard." -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Siguiente paso: Ejecutar Iniciar-Dashboard.bat" -ForegroundColor Gray
Write-Host ""
Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
