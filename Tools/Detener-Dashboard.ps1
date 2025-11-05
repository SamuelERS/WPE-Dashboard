# ============================================
# DETENER DASHBOARD
# ============================================
# Script de utilidad para detener el dashboard
# si necesitas hacer cambios o resolver problemas

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  DETENIENDO DASHBOARD ACUARIOS PARADISE" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

try {
    Import-Module UniversalDashboard.Community -ErrorAction Stop
    
    $dashboards = Get-UDDashboard -ErrorAction SilentlyContinue
    
    if ($dashboards) {
        Write-Host "[INFO] Dashboards activos encontrados:" -ForegroundColor Yellow
        $dashboards | ForEach-Object {
            Write-Host "  - Puerto: $($_.Port)" -ForegroundColor Gray
        }
        
        Write-Host ""
        Write-Host "[ACCION] Deteniendo dashboards..." -ForegroundColor Cyan
        
        Get-UDDashboard | Stop-UDDashboard
        
        Start-Sleep -Seconds 2
        
        Write-Host ""
        Write-Host "[OK] Dashboards detenidos correctamente" -ForegroundColor Green
        
    } else {
        Write-Host "[INFO] No hay dashboards activos" -ForegroundColor Gray
    }
    
} catch {
    Write-Host ""
    Write-Host "[ERROR] Error al detener dashboards: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
