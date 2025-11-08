# ============================================
# DETENER DASHBOARD - MODO AGRESIVO
# ============================================
# Script de utilidad para detener completamente el dashboard
# y liberar el puerto 10000

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  DETENIENDO DASHBOARD PARADISE-SYSTEMLABS" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$dashboardsStopped = $false
$portFreed = $false

# PASO 1: Intentar detener via UniversalDashboard
Write-Host "[1/3] Deteniendo dashboards via UniversalDashboard..." -ForegroundColor Cyan
try {
    Import-Module UniversalDashboard.Community -ErrorAction Stop

    $dashboards = Get-UDDashboard -ErrorAction SilentlyContinue

    if ($dashboards) {
        Write-Host "  Dashboards encontrados:" -ForegroundColor Yellow
        $dashboards | ForEach-Object {
            Write-Host "    - Puerto: $($_.Port)" -ForegroundColor Gray
        }

        Get-UDDashboard | Stop-UDDashboard -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 3

        $dashboardsStopped = $true
        Write-Host "  [OK] Dashboards detenidos" -ForegroundColor Green
    } else {
        Write-Host "  [INFO] No hay dashboards activos via Get-UDDashboard" -ForegroundColor Gray
    }

} catch {
    Write-Host "  [WARN] Error al usar UniversalDashboard: $_" -ForegroundColor Yellow
}

# PASO 2: Liberar puerto 10000 agresivamente
Write-Host ""
Write-Host "[2/3] Liberando puerto 10000..." -ForegroundColor Cyan

$portConnections = Get-NetTCPConnection -LocalPort 10000 -ErrorAction SilentlyContinue

if ($portConnections) {
    # Filtrar solo conexiones activas (Listen o Established)
    $activeConnections = $portConnections | Where-Object {
        $_.State -eq 'Listen' -or $_.State -eq 'Established'
    }

    if ($activeConnections) {
        Write-Host "  Puerto 10000 ocupado por:" -ForegroundColor Yellow

        # Obtener PIDs unicos
        $processIds = $activeConnections |
            Select-Object -ExpandProperty OwningProcess -Unique |
            Where-Object { $_ -gt 0 }

        foreach ($processId in $processIds) {
            try {
                $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
                if ($process) {
                    Write-Host "    - $($process.ProcessName) (PID: $processId)" -ForegroundColor Gray
                    Stop-Process -Id $processId -Force -ErrorAction Stop
                    Write-Host "      [OK] Proceso detenido" -ForegroundColor Green
                }
            } catch {
                Write-Host "      [ERROR] No se pudo detener: $_" -ForegroundColor Red
            }
        }

        # Esperar a que Windows libere el puerto
        Write-Host "  Esperando liberacion del puerto (10 segundos)..." -ForegroundColor Gray
        Start-Sleep -Seconds 10

        # Verificar nuevamente
        $recheckPort = Get-NetTCPConnection -LocalPort 10000 -ErrorAction SilentlyContinue
        $recheckActive = $recheckPort | Where-Object {
            $_.State -eq 'Listen' -or $_.State -eq 'Established'
        }

        if (-not $recheckActive) {
            $portFreed = $true
            Write-Host "  [OK] Puerto 10000 liberado" -ForegroundColor Green
        } else {
            Write-Host "  [WARN] Puerto 10000 aun ocupado (puede tener conexiones TimeWait residuales)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  [INFO] Puerto 10000 solo tiene conexiones TimeWait (residuales)" -ForegroundColor Gray
        $portFreed = $true
    }
} else {
    Write-Host "  [OK] Puerto 10000 ya estaba libre" -ForegroundColor Green
    $portFreed = $true
}

# PASO 3: Resumen
Write-Host ""
Write-Host "[3/3] Resumen:" -ForegroundColor Cyan

if ($dashboardsStopped -or $portFreed) {
    Write-Host "  [OK] Dashboard detenido correctamente" -ForegroundColor Green
    Write-Host "  Puedes reiniciar el dashboard con: .\Iniciar-Dashboard.bat" -ForegroundColor White
} else {
    Write-Host "  [WARN] No se detectaron dashboards activos ni puertos ocupados" -ForegroundColor Yellow
    Write-Host "  Si sigues teniendo problemas:" -ForegroundColor Yellow
    Write-Host "    1. Cierra todas las ventanas de PowerShell" -ForegroundColor White
    Write-Host "    2. Reinicia el equipo" -ForegroundColor White
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
