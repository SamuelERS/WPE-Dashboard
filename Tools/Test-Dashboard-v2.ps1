# ============================================
# TESTING AUTOMATIZADO - DASHBOARD v2.0
# ============================================
# Valida la arquitectura modular

if (-not $Global:DashboardRoot) {
    $Global:DashboardRoot = Split-Path -Parent $PSScriptRoot
}

$testsPassed = 0
$testsFailed = 0
$testsTotal = 0

function Test-Feature {
    param(
        [string]$Name,
        [scriptblock]$Test,
        [string]$Category = "General"
    )
    
    $script:testsTotal++
    Write-Host "`n[$Category] Test: $Name" -ForegroundColor Cyan
    
    try {
        $result = & $Test
        if ($result) {
            Write-Host "  [PASS] $Name" -ForegroundColor Green
            $script:testsPassed++
            return $true
        } else {
            Write-Host "  [FAIL] $Name" -ForegroundColor Red
            $script:testsFailed++
            return $false
        }
    } catch {
        Write-Host "  [ERROR] $Name : $_" -ForegroundColor Red
        $script:testsFailed++
        return $false
    }
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  TESTING DASHBOARD v2.0 - ARQUITECTURA MODULAR" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Dashboard Root: $Global:DashboardRoot" -ForegroundColor Gray
Write-Host ""

# ============================================
# CATEGORIA 1: ESTRUCTURA MODULAR
# ============================================

Test-Feature -Name "Carpeta Core/ existe" -Category "Estructura" -Test {
    Test-Path (Join-Path $Global:DashboardRoot "Core")
}

Test-Feature -Name "Carpeta Modules/ existe" -Category "Estructura" -Test {
    Test-Path (Join-Path $Global:DashboardRoot "Modules")
}

Test-Feature -Name "Carpeta UI/ existe" -Category "Estructura" -Test {
    Test-Path (Join-Path $Global:DashboardRoot "UI")
}

Test-Feature -Name "Carpeta Actions/ existe" -Category "Estructura" -Test {
    Test-Path (Join-Path $Global:DashboardRoot "Actions")
}

# ============================================
# CATEGORIA 2: MODULOS CORE
# ============================================

Test-Feature -Name "Core/ScriptLoader.ps1 existe" -Category "Modulos Core" -Test {
    Test-Path (Join-Path $Global:DashboardRoot "Core\ScriptLoader.ps1")
}

Test-Feature -Name "Core/Dashboard-Init.ps1 existe" -Category "Modulos Core" -Test {
    Test-Path (Join-Path $Global:DashboardRoot "Core\Dashboard-Init.ps1")
}

Test-Feature -Name "UI/Dashboard-UI.ps1 existe" -Category "Modulos Core" -Test {
    Test-Path (Join-Path $Global:DashboardRoot "UI\Dashboard-UI.ps1")
}

Test-Feature -Name "Dashboard-v2.ps1 existe" -Category "Modulos Core" -Test {
    Test-Path (Join-Path $Global:DashboardRoot "Dashboard-v2.ps1")
}

# ============================================
# CATEGORIA 3: METADATA DE SCRIPTS
# ============================================

Test-Feature -Name "Scripts tienen metadata v2.0" -Category "Metadata" -Test {
    $scriptsPath = Join-Path $Global:DashboardRoot "Scripts"
    $scripts = Get-ChildItem $scriptsPath -Recurse -Filter "*.ps1" | 
               Where-Object { $_.Name -ne "PLANTILLA-Script.ps1" }
    
    $withMetadata = 0
    foreach ($script in $scripts) {
        $content = Get-Content $script.FullName -Raw
        if ($content -match '<#\s*METADATA') {
            $withMetadata++
        }
    }
    
    return ($withMetadata -ge 5)  # Al menos 5 scripts con metadata
}

Test-Feature -Name "Metadata incluye campos requeridos" -Category "Metadata" -Test {
    $scriptPath = Join-Path $Global:DashboardRoot "Scripts\Mantenimiento\Limpiar-Archivos-Temporales.ps1"
    $content = Get-Content $scriptPath -Raw
    
    $hasName = $content -match 'Name:'
    $hasDesc = $content -match 'Description:'
    $hasCat = $content -match 'Category:'
    $hasAdmin = $content -match 'RequiresAdmin:'
    
    return ($hasName -and $hasDesc -and $hasCat -and $hasAdmin)
}

# ============================================
# CATEGORIA 4: FUNCIONES SCRIPTLOADER
# ============================================

Test-Feature -Name "ScriptLoader define Get-ScriptMetadata" -Category "ScriptLoader" -Test {
    $slPath = Join-Path $Global:DashboardRoot "Core\ScriptLoader.ps1"
    $content = Get-Content $slPath -Raw
    return ($content -match 'function Get-ScriptMetadata')
}

Test-Feature -Name "ScriptLoader define Get-AllScriptsWithMetadata" -Category "ScriptLoader" -Test {
    $slPath = Join-Path $Global:DashboardRoot "Core\ScriptLoader.ps1"
    $content = Get-Content $slPath -Raw
    return ($content -match 'function Get-AllScriptsWithMetadata')
}

Test-Feature -Name "ScriptLoader define Get-ScriptsByCategory" -Category "ScriptLoader" -Test {
    $slPath = Join-Path $Global:DashboardRoot "Core\ScriptLoader.ps1"
    $content = Get-Content $slPath -Raw
    return ($content -match 'function Get-ScriptsByCategory')
}

# ============================================
# CATEGORIA 5: FUNCIONES UI
# ============================================

Test-Feature -Name "Dashboard-UI define New-DashboardHeader" -Category "UI" -Test {
    $uiPath = Join-Path $Global:DashboardRoot "UI\Dashboard-UI.ps1"
    $content = Get-Content $uiPath -Raw
    return ($content -match 'function New-DashboardHeader')
}

Test-Feature -Name "Dashboard-UI define New-ScriptButton" -Category "UI" -Test {
    $uiPath = Join-Path $Global:DashboardRoot "UI\Dashboard-UI.ps1"
    $content = Get-Content $uiPath -Raw
    return ($content -match 'function New-ScriptButton')
}

Test-Feature -Name "Dashboard-UI define New-DashboardContent" -Category "UI" -Test {
    $uiPath = Join-Path $Global:DashboardRoot "UI\Dashboard-UI.ps1"
    $content = Get-Content $uiPath -Raw
    return ($content -match 'function New-DashboardContent')
}

# ============================================
# CATEGORIA 6: FUNCIONES INIT
# ============================================

Test-Feature -Name "Dashboard-Init define Test-JsonConfig" -Category "Init" -Test {
    $initPath = Join-Path $Global:DashboardRoot "Core\Dashboard-Init.ps1"
    $content = Get-Content $initPath -Raw
    return ($content -match 'function Test-JsonConfig')
}

Test-Feature -Name "Dashboard-Init define Initialize-DashboardConfig" -Category "Init" -Test {
    $initPath = Join-Path $Global:DashboardRoot "Core\Dashboard-Init.ps1"
    $content = Get-Content $initPath -Raw
    return ($content -match 'function Initialize-DashboardConfig')
}

Test-Feature -Name "Dashboard-Init define Initialize-UniversalDashboard" -Category "Init" -Test {
    $initPath = Join-Path $Global:DashboardRoot "Core\Dashboard-Init.ps1"
    $content = Get-Content $initPath -Raw
    return ($content -match 'function Initialize-UniversalDashboard')
}

# ============================================
# CATEGORIA 7: DASHBOARD v2.0
# ============================================

Test-Feature -Name "Dashboard-v2.ps1 importa Core/Dashboard-Init.ps1" -Category "Dashboard v2" -Test {
    $dashPath = Join-Path $Global:DashboardRoot "Dashboard-v2.ps1"
    $content = Get-Content $dashPath -Raw
    return ($content -match 'Core\\Dashboard-Init\.ps1')
}

Test-Feature -Name "Dashboard-v2.ps1 importa Core/ScriptLoader.ps1" -Category "Dashboard v2" -Test {
    $dashPath = Join-Path $Global:DashboardRoot "Dashboard-v2.ps1"
    $content = Get-Content $dashPath -Raw
    return ($content -match 'Core\\ScriptLoader\.ps1')
}

Test-Feature -Name "Dashboard-v2.ps1 importa UI/Dashboard-UI.ps1" -Category "Dashboard v2" -Test {
    $dashPath = Join-Path $Global:DashboardRoot "Dashboard-v2.ps1"
    $content = Get-Content $dashPath -Raw
    return ($content -match 'UI\\Dashboard-UI\.ps1')
}

Test-Feature -Name "Dashboard-v2.ps1 usa New-DashboardContent" -Category "Dashboard v2" -Test {
    $dashPath = Join-Path $Global:DashboardRoot "Dashboard-v2.ps1"
    $content = Get-Content $dashPath -Raw
    return ($content -match 'New-DashboardContent')
}

# ============================================
# CATEGORIA 8: REDUCCION DE LINEAS
# ============================================

Test-Feature -Name "Dashboard-v2.ps1 tiene menos de 200 lineas" -Category "Reduccion" -Test {
    $dashPath = Join-Path $Global:DashboardRoot "Dashboard-v2.ps1"
    $lines = (Get-Content $dashPath).Count
    Write-Host "    Lineas: $lines" -ForegroundColor Gray
    return ($lines -lt 200)
}

Test-Feature -Name "Reduccion significativa vs Dashboard.ps1" -Category "Reduccion" -Test {
    $oldPath = Join-Path $Global:DashboardRoot "Dashboard.ps1"
    $newPath = Join-Path $Global:DashboardRoot "Dashboard-v2.ps1"
    
    $oldLines = (Get-Content $oldPath).Count
    $newLines = (Get-Content $newPath).Count
    
    $reduction = [math]::Round((($oldLines - $newLines) / $oldLines) * 100, 2)
    Write-Host "    Dashboard.ps1: $oldLines lineas" -ForegroundColor Gray
    Write-Host "    Dashboard-v2.ps1: $newLines lineas" -ForegroundColor Gray
    Write-Host "    Reduccion: $reduction%" -ForegroundColor Gray
    
    return ($reduction -gt 70)  # Al menos 70% de reduccion
}

# ============================================
# RESUMEN
# ============================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  RESUMEN DE TESTING" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Tests totales:  $testsTotal" -ForegroundColor White
Write-Host "Tests pasados:  $testsPassed" -ForegroundColor Green
Write-Host "Tests fallidos: $testsFailed" -ForegroundColor $(if($testsFailed -gt 0){"Red"}else{"Green"})
Write-Host ""

$percentage = [math]::Round(($testsPassed / $testsTotal) * 100, 2)
Write-Host "Porcentaje de exito: $percentage%" -ForegroundColor $(if($percentage -eq 100){"Green"}elseif($percentage -ge 80){"Yellow"}else{"Red"})
Write-Host ""

if ($testsFailed -eq 0) {
    Write-Host "[OK] Todos los tests pasaron - Arquitectura v2.0 validada" -ForegroundColor Green
    exit 0
} else {
    Write-Host "[WARN] Algunos tests fallaron - revisar arriba" -ForegroundColor Yellow
    exit 1
}
