# ============================================
# TESTING AUTOMATIZADO - FASE 2
# ============================================
# Script para validar todas las mejoras de Fase 2

# Detectar ubicación
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
Write-Host "  TESTING AUTOMATIZADO - FASE 2" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Dashboard Root: $Global:DashboardRoot" -ForegroundColor Gray
Write-Host ""

# ============================================
# CATEGORIA 1: PORTABILIDAD
# ============================================

Test-Feature -Name "Tools/Verificar-Sistema.ps1 es portable" -Category "Portabilidad" -Test {
    $file = Join-Path $Global:DashboardRoot "Tools\Verificar-Sistema.ps1"
    $hardcoded = Select-String -Path $file -Pattern "C:\\WPE-Dashboard" -Quiet
    return (-not $hardcoded)
}

Test-Feature -Name "PLANTILLA-Script.ps1 es portable" -Category "Portabilidad" -Test {
    $file = Join-Path $Global:DashboardRoot "Scripts\PLANTILLA-Script.ps1"
    $hardcoded = Select-String -Path $file -Pattern "C:\\WPE-Dashboard" -Quiet
    return (-not $hardcoded)
}

Test-Feature -Name "Dashboard.ps1 usa DashboardRoot" -Category "Portabilidad" -Test {
    $file = Join-Path $Global:DashboardRoot "Dashboard.ps1"
    $hasDashboardRoot = Select-String -Path $file -Pattern "DashboardRoot" -Quiet
    return $hasDashboardRoot
}

# ============================================
# CATEGORIA 2: CONFIGURABILIDAD
# ============================================

Test-Feature -Name "dashboard-config.json existe" -Category "Configurabilidad" -Test {
    $configPath = Join-Path $Global:DashboardRoot "Config\dashboard-config.json"
    return (Test-Path $configPath)
}

Test-Feature -Name "dashboard-config.json es JSON valido" -Category "Configurabilidad" -Test {
    $configPath = Join-Path $Global:DashboardRoot "Config\dashboard-config.json"
    try {
        $json = Get-Content $configPath -Raw | ConvertFrom-Json
        return ($json -ne $null)
    } catch {
        return $false
    }
}

Test-Feature -Name "JSON tiene seccion ui.colors" -Category "Configurabilidad" -Test {
    $configPath = Join-Path $Global:DashboardRoot "Config\dashboard-config.json"
    $json = Get-Content $configPath -Raw | ConvertFrom-Json
    return ($json.ui.colors -ne $null)
}

Test-Feature -Name "JSON tiene seccion ui.spacing" -Category "Configurabilidad" -Test {
    $configPath = Join-Path $Global:DashboardRoot "Config\dashboard-config.json"
    $json = Get-Content $configPath -Raw | ConvertFrom-Json
    return ($json.ui.spacing -ne $null)
}

Test-Feature -Name "Dashboard.ps1 carga JSON" -Category "Configurabilidad" -Test {
    $file = Join-Path $Global:DashboardRoot "Dashboard.ps1"
    $loadsJson = Select-String -Path $file -Pattern "Test-JsonConfig" -Quiet
    return $loadsJson
}

# ============================================
# CATEGORIA 3: CODIGO MUERTO
# ============================================

Test-Feature -Name "ScriptLoader.ps1 eliminado" -Category "Codigo Muerto" -Test {
    $file = Join-Path $Global:DashboardRoot "Scripts\ScriptLoader.ps1"
    return (-not (Test-Path $file))
}

Test-Feature -Name "UI-Components.ps1 eliminado" -Category "Codigo Muerto" -Test {
    $file = Join-Path $Global:DashboardRoot "Components\UI-Components.ps1"
    return (-not (Test-Path $file))
}

Test-Feature -Name "Form-Components.ps1 eliminado" -Category "Codigo Muerto" -Test {
    $file = Join-Path $Global:DashboardRoot "Components\Form-Components.ps1"
    return (-not (Test-Path $file))
}

Test-Feature -Name "Tools/Eliminar-Usuario.ps1 eliminado (duplicado)" -Category "Codigo Muerto" -Test {
    $file = Join-Path $Global:DashboardRoot "Tools\Eliminar-Usuario.ps1"
    return (-not (Test-Path $file))
}

# ============================================
# CATEGORIA 4: LOGGING
# ============================================

Test-Feature -Name "Utils/Logging-Utils.ps1 existe" -Category "Logging" -Test {
    $file = Join-Path $Global:DashboardRoot "Utils\Logging-Utils.ps1"
    return (Test-Path $file)
}

Test-Feature -Name "Dashboard.ps1 importa Logging-Utils" -Category "Logging" -Test {
    $file = Join-Path $Global:DashboardRoot "Dashboard.ps1"
    $imports = Select-String -Path $file -Pattern "Logging-Utils.ps1" -Quiet
    return $imports
}

Test-Feature -Name "Carpeta Logs/ existe" -Category "Logging" -Test {
    $logsPath = Join-Path $Global:DashboardRoot "Logs"
    return (Test-Path $logsPath)
}

# ============================================
# CATEGORIA 5: VALIDACION JSON
# ============================================

Test-Feature -Name "Dashboard.ps1 tiene Test-JsonConfig" -Category "Validacion JSON" -Test {
    $file = Join-Path $Global:DashboardRoot "Dashboard.ps1"
    $hasFunction = Select-String -Path $file -Pattern "function Test-JsonConfig" -Quiet
    return $hasFunction
}

Test-Feature -Name "Validacion JSON detiene dashboard si falla" -Category "Validacion JSON" -Test {
    $file = Join-Path $Global:DashboardRoot "Dashboard.ps1"
    $hasExit = Select-String -Path $file -Pattern "exit 1" -Quiet
    return $hasExit
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
    Write-Host "[OK] Todos los tests pasaron exitosamente" -ForegroundColor Green
    exit 0
} else {
    Write-Host "[WARN] Algunos tests fallaron - revisar arriba" -ForegroundColor Yellow
    exit 1
}
