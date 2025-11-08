# Check variable types
cd C:\ProgramData\WPE-Dashboard
. .\Utils\Logging-Utils.ps1
. .\Core\Dashboard-Init.ps1
. .\Core\ScriptLoader.ps1

$dashConfig = Initialize-DashboardConfig
$scriptsByCategory = Get-ScriptsByCategory
$categoriesConfig = Get-CategoriesConfig

Write-Host "=== TIPOS DE VARIABLES ===" -ForegroundColor Cyan
Write-Host "scriptsByCategory: $($scriptsByCategory.GetType().Name)" -ForegroundColor Yellow
Write-Host "categoriesConfig: $($categoriesConfig.GetType().Name)" -ForegroundColor Yellow
Write-Host "dashConfig: $($dashConfig.GetType().Name)" -ForegroundColor Yellow

Write-Host "`n=== VALORES ===" -ForegroundColor Cyan
Write-Host "scriptsByCategory es hashtable?: $($scriptsByCategory -is [hashtable])" -ForegroundColor $(if($scriptsByCategory -is [hashtable]){'Green'}else{'Red'})
Write-Host "categoriesConfig es array?: $($categoriesConfig -is [array])" -ForegroundColor $(if($categoriesConfig -is [array]){'Green'}else{'Red'})
Write-Host "dashConfig es hashtable?: $($dashConfig -is [hashtable])" -ForegroundColor $(if($dashConfig -is [hashtable]){'Green'}else{'Red'})
