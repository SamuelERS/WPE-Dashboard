# Test específico de creación de dashboard
cd C:\ProgramData\WPE-Dashboard

Write-Host "=== TEST CREACION DASHBOARD ===" -ForegroundColor Cyan

# Cargar módulos
. .\Utils\Logging-Utils.ps1
. .\Core\Dashboard-Init.ps1
. .\Core\ScriptLoader.ps1
. .\UI\Dashboard-UI.ps1

# Cargar configuración
$dashConfig = Initialize-DashboardConfig
$scriptsByCategory = Get-ScriptsByCategory
$categoriesConfig = Get-CategoriesConfig

Write-Host "`n[TEST 1] Verificar tipos de variables..." -ForegroundColor Yellow
Write-Host "scriptsByCategory: $($scriptsByCategory.GetType().Name) - es hashtable: $($scriptsByCategory -is [hashtable])"
Write-Host "categoriesConfig: $($categoriesConfig.GetType().Name) - es array: $($categoriesConfig -is [array])"
Write-Host "dashConfig: $($dashConfig.GetType().Name) - es hashtable: $($dashConfig -is [hashtable])"

Write-Host "`n[TEST 2] Llamar New-DashboardContent directamente..." -ForegroundColor Yellow
try {
    $testContent = New-DashboardContent -ScriptsByCategory $scriptsByCategory -CategoriesConfig $categoriesConfig -Config $dashConfig
    Write-Host "[OK] New-DashboardContent funciona directamente" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] New-DashboardContent falla: $_" -ForegroundColor Red
    Write-Host "Detalles: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n[TEST 3] Probar con Cache: scope..." -ForegroundColor Yellow
$Cache:ScriptsByCategory = $scriptsByCategory
$Cache:CategoriesConfig  = $categoriesConfig
$Cache:Config            = $dashConfig

try {
    $testContent2 = New-DashboardContent -ScriptsByCategory $Cache:ScriptsByCategory -CategoriesConfig $Cache:CategoriesConfig -Config $Cache:Config
    Write-Host "[OK] New-DashboardContent funciona con Cache:" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] New-DashboardContent falla con Cache:: $_" -ForegroundColor Red
}

Write-Host "`n[TEST 4] Importar UniversalDashboard..." -ForegroundColor Yellow
$udReady = Initialize-UniversalDashboard
if ($udReady) {
    Write-Host "[OK] UniversalDashboard cargado" -ForegroundColor Green
} else {
    Write-Host "[ERROR] UniversalDashboard no cargado" -ForegroundColor Red
    exit 1
}

Write-Host "`n[TEST 5] Crear dashboard con scriptblock simple..." -ForegroundColor Yellow
try {
    $testDash = New-UDDashboard -Title "Test Simple" -Content {
        New-UDCard -Title "Test" -Content { "Funciona" }
    }
    Write-Host "[OK] Dashboard simple creado" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Dashboard simple falla: $_" -ForegroundColor Red
    Write-Host "Detalles: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n[TEST 6] Crear dashboard con New-DashboardContent en scriptblock..." -ForegroundColor Yellow
try {
    $testDash2 = New-UDDashboard -Title "Test Con Funcion" -Content {
        New-DashboardContent -ScriptsByCategory $Cache:ScriptsByCategory `
                            -CategoriesConfig $Cache:CategoriesConfig `
                            -Config $Cache:Config
    }
    Write-Host "[OK] Dashboard con New-DashboardContent creado" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Dashboard con New-DashboardContent falla: $_" -ForegroundColor Red
    Write-Host "Tipo de error: $($_.CategoryInfo.Category)" -ForegroundColor Red
    Write-Host "Detalles completos: $($_.Exception)" -ForegroundColor Red
    Write-Host "InnerException: $($_.Exception.InnerException)" -ForegroundColor Red
}

Write-Host "`n=== FIN DEL TEST ===" -ForegroundColor Cyan
