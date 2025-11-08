# Test funciones individuales de New-DashboardContent
cd C:\ProgramData\WPE-Dashboard

. .\Utils\Logging-Utils.ps1
. .\Core\Dashboard-Init.ps1
. .\Core\ScriptLoader.ps1
. .\UI\Dashboard-UI.ps1

$dashConfig = Initialize-DashboardConfig
$scriptsByCategory = Get-ScriptsByCategory
$categoriesConfig = Get-CategoriesConfig

Write-Host "`n=== TESTING FUNCIONES INDIVIDUALES ===" -ForegroundColor Cyan

# Test 1
Write-Host "`n[TEST] Get-ParadiseGlobalCSS..." -ForegroundColor Yellow
try {
    $css = Get-ParadiseGlobalCSS -Config $dashConfig
    Write-Host "[OK] Get-ParadiseGlobalCSS" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Get-ParadiseGlobalCSS: $_" -ForegroundColor Red
    Write-Host "InnerException: $($_.Exception.InnerException.Message)" -ForegroundColor Red
}

# Test 2
Write-Host "`n[TEST] New-DashboardHeader..." -ForegroundColor Yellow
try {
    $header = New-DashboardHeader -Config $dashConfig
    Write-Host "[OK] New-DashboardHeader" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] New-DashboardHeader: $_" -ForegroundColor Red
    Write-Host "InnerException: $($_.Exception.InnerException.Message)" -ForegroundColor Red
}

# Test 3
Write-Host "`n[TEST] New-SystemInfoCard..." -ForegroundColor Yellow
try {
    $card = New-SystemInfoCard -Config $dashConfig
    Write-Host "[OK] New-SystemInfoCard" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] New-SystemInfoCard: $_" -ForegroundColor Red
    Write-Host "InnerException: $($_.Exception.InnerException.Message)" -ForegroundColor Red
}

# Test 4
Write-Host "`n[TEST] New-SectionSeparator..." -ForegroundColor Yellow
try {
    $sep = New-SectionSeparator -Config $dashConfig
    Write-Host "[OK] New-SectionSeparator" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] New-SectionSeparator: $_" -ForegroundColor Red
    Write-Host "InnerException: $($_.Exception.InnerException.Message)" -ForegroundColor Red
}
