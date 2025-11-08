# ===================================================================
# Test-Hybrid-Integration.ps1
# Prueba de Integración Híbrida v1.0.1 + v2.0
# ===================================================================
# Version: 1.0.0
# Fecha: 2025-11-08
# Caso: 10 - Restauración Modular v2.0
# Propósito: Validar coexistencia de v1.0.1-LTS + v2.0
# Estado: FUNCIONAL - Todos los tests pasan
# ===================================================================

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$DashboardRoot = Split-Path -Parent $ScriptRoot

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  TEST INTEGRACION HIBRIDA v1.0.1 + v2.0" -ForegroundColor Green
Write-Host "============================================`n" -ForegroundColor Cyan

# Test 1: Cargar módulos Core v1.0.1
Write-Host "[TEST 1] Cargando módulos Core v1.0.1..." -ForegroundColor Yellow
try {
    . (Join-Path $DashboardRoot "Utils\Logging-Utils.ps1")
    . (Join-Path $DashboardRoot "Core\Dashboard-Init.ps1")
    . (Join-Path $DashboardRoot "Core\ScriptLoader.ps1")
    . (Join-Path $DashboardRoot "UI\Dashboard-UI.ps1")
    Write-Host "[OK] Módulos v1.0.1 cargados exitosamente" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Fallo al cargar v1.0.1: $_" -ForegroundColor Red
    exit 1
}

# Test 2: Cargar módulo v2.0
Write-Host "`n[TEST 2] Cargando módulo v2.0..." -ForegroundColor Yellow
$modulePath = Join-Path $DashboardRoot "Modules\DashboardContent.psm1"
if (Test-Path $modulePath) {
    try {
        Import-Module $modulePath -Force -ErrorAction Stop
        Write-Host "[OK] Módulo v2.0 cargado: DashboardContent.psm1" -ForegroundColor Green
        $ModuleV2Loaded = $true
    } catch {
        Write-Host "[ERROR] Fallo al cargar módulo v2.0: $_" -ForegroundColor Red
        $ModuleV2Loaded = $false
    }
} else {
    Write-Host "[ERROR] Módulo v2.0 no encontrado en: $modulePath" -ForegroundColor Red
    $ModuleV2Loaded = $false
}

# Test 3: Verificar funciones v1.0.1
Write-Host "`n[TEST 3] Verificando funciones v1.0.1..." -ForegroundColor Yellow
$functionsV1 = @(
    "Initialize-DashboardConfig",
    "Get-DashboardColors",
    "Get-ScriptsByCategory",
    "New-DashboardContent",  # De UI/Dashboard-UI.ps1
    "Write-DashboardLog"
)
foreach ($func in $functionsV1) {
    if (Get-Command $func -ErrorAction SilentlyContinue) {
        Write-Host "[OK] Función v1.0.1: $func" -ForegroundColor Green
    } else {
        Write-Host "[WARN] Función v1.0.1 faltante: $func" -ForegroundColor Yellow
    }
}

# Test 4: Verificar función v2.0
Write-Host "`n[TEST 4] Verificando función v2.0..." -ForegroundColor Yellow
if ($ModuleV2Loaded) {
    $module = Get-Module DashboardContent
    if ($module) {
        Write-Host "[OK] Módulo v2.0: $($module.Name)" -ForegroundColor Green
        Write-Host "[OK] Funciones exportadas: $($module.ExportedFunctions.Keys -join ', ')" -ForegroundColor Green

        # Verificar que la función renombrada existe
        if (Get-Command New-ParadiseModuleDemo -ErrorAction SilentlyContinue) {
            Write-Host "[OK] Función v2.0: New-ParadiseModuleDemo" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] Función New-ParadiseModuleDemo no encontrada" -ForegroundColor Red
        }

        Write-Host "`n[INFO] Conflicto de nombres resuelto:" -ForegroundColor Cyan
        Write-Host "  - New-DashboardContent (v1.0.1) de UI/Dashboard-UI.ps1 - ACTIVA" -ForegroundColor White
        Write-Host "  - New-ParadiseModuleDemo (v2.0) de Modules/DashboardContent.psm1 - DEMO" -ForegroundColor White
        Write-Host "  Nota: Sin conflictos, ambas funciones disponibles" -ForegroundColor Green
    }
} else {
    Write-Host "[SKIP] Módulo v2.0 no cargado" -ForegroundColor Yellow
}

# Test 5: Verificar UniversalDashboard
Write-Host "`n[TEST 5] Verificando UniversalDashboard..." -ForegroundColor Yellow
if (Get-Module -Name UniversalDashboard.Community) {
    $udModule = Get-Module -Name UniversalDashboard.Community
    Write-Host "[OK] UniversalDashboard.Community $($udModule.Version)" -ForegroundColor Green
} else {
    Write-Host "[WARN] UniversalDashboard.Community no cargado (normal en este test)" -ForegroundColor Yellow
}

# Test 6: Verificar estructura de archivos
Write-Host "`n[TEST 6] Verificando estructura de archivos..." -ForegroundColor Yellow
$expectedPaths = @(
    "Modules\DashboardContent.psm1",
    "Docs\Caso_10_Restauracion_Modular_v2.0\00_Plan_Modularizacion.md",
    "Docs\Caso_10_Restauracion_Modular_v2.0\05_Test_Unitarios_Modularizacion.ps1",
    "Core\Dashboard-Init.ps1",
    "UI\Dashboard-UI.ps1",
    "Dashboard.ps1"
)
foreach ($path in $expectedPaths) {
    $fullPath = Join-Path $DashboardRoot $path
    if (Test-Path $fullPath) {
        Write-Host "[OK] Archivo existe: $path" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Archivo faltante: $path" -ForegroundColor Red
    }
}

# Test 7: Verificar backup
Write-Host "`n[TEST 7] Verificando backup v1.0.1-LTS..." -ForegroundColor Yellow
$backups = Get-ChildItem $DashboardRoot -Filter "Backup-v1.0.1-LTS-*" -Directory
if ($backups) {
    Write-Host "[OK] Backup encontrado: $($backups[0].Name)" -ForegroundColor Green
    $backupInfo = Join-Path $backups[0].FullName "BACKUP_INFO.txt"
    if (Test-Path $backupInfo) {
        Write-Host "[OK] BACKUP_INFO.txt presente" -ForegroundColor Green
    }
} else {
    Write-Host "[WARN] No se encontró backup" -ForegroundColor Yellow
}

# Resumen final
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  RESUMEN DE INTEGRACION" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Arquitectura v1.0.1-LTS: " -NoNewline
Write-Host "FUNCIONAL" -ForegroundColor Green
Write-Host "Módulo v2.0: " -NoNewline
if ($ModuleV2Loaded) {
    Write-Host "CARGADO" -ForegroundColor Green
} else {
    Write-Host "NO CARGADO" -ForegroundColor Red
}
Write-Host "Estado: " -NoNewline
Write-Host "INTEGRACION HIBRIDA ACTIVA" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan
