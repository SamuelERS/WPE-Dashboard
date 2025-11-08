# ============================================
# TEST PARADISE RESTORATION v1.0.1-LTS
# ============================================
# Proposito: Validar que la restauracion Paradise funciona correctamente

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  TEST PARADISE RESTORATION v1.0.1-LTS" -ForegroundColor Green
Write-Host "============================================`n" -ForegroundColor Cyan

$testsPassed = 0
$testsFailed = 0

# ============================================
# TEST 1: Verificar archivo de configuracion
# ============================================
Write-Host "[TEST 1] Verificar dashboard-config.json..." -ForegroundColor Yellow

try {
    $configPath = "C:\ProgramData\WPE-Dashboard\Config\dashboard-config.json"
    $config = Get-Content $configPath -Raw | ConvertFrom-Json

    # Verificar colores Paradise
    if ($config.ui.colorsParadise) {
        Write-Host "  [OK] colorsParadise presente" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "  [FAIL] colorsParadise NO encontrado" -ForegroundColor Red
        $testsFailed++
    }

    # Verificar tipografia
    if ($config.ui.typography) {
        Write-Host "  [OK] typography presente" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "  [FAIL] typography NO encontrado" -ForegroundColor Red
        $testsFailed++
    }

} catch {
    Write-Host "  [FAIL] Error al leer config: $_" -ForegroundColor Red
    $testsFailed += 2
}

# ============================================
# TEST 2: Verificar funcion ConvertTo-Hashtable
# ============================================
Write-Host "`n[TEST 2] Verificar ConvertTo-Hashtable..." -ForegroundColor Yellow

try {
    # Cargar Dashboard-Init
    $ScriptRoot = "C:\ProgramData\WPE-Dashboard"
    . (Join-Path $ScriptRoot "Utils\Logging-Utils.ps1")
    . (Join-Path $ScriptRoot "Core\Dashboard-Init.ps1")

    # Verificar que la funcion existe
    $functionExists = Get-Command ConvertTo-Hashtable -ErrorAction SilentlyContinue

    if ($functionExists) {
        Write-Host "  [OK] ConvertTo-Hashtable existe" -ForegroundColor Green
        $testsPassed++

        # Test de conversion
        $testObj = @{
            test = "value"
            nested = @{
                key = "data"
            }
        } | ConvertTo-Json | ConvertFrom-Json

        $converted = ConvertTo-Hashtable $testObj

        if ($converted -is [hashtable]) {
            Write-Host "  [OK] Conversion PSCustomObject -> Hashtable funciona" -ForegroundColor Green
            $testsPassed++
        } else {
            Write-Host "  [FAIL] Conversion retorna tipo incorrecto: $($converted.GetType().Name)" -ForegroundColor Red
            $testsFailed++
        }

    } else {
        Write-Host "  [FAIL] ConvertTo-Hashtable NO existe" -ForegroundColor Red
        $testsFailed += 2
    }

} catch {
    Write-Host "  [FAIL] Error: $_" -ForegroundColor Red
    $testsFailed += 2
}

# ============================================
# TEST 3: Verificar Initialize-DashboardConfig
# ============================================
Write-Host "`n[TEST 3] Verificar Initialize-DashboardConfig..." -ForegroundColor Yellow

try {
    $Global:DashboardRoot = "C:\ProgramData\WPE-Dashboard"

    $dashConfig = Initialize-DashboardConfig

    if ($dashConfig -is [hashtable]) {
        Write-Host "  [OK] Initialize-DashboardConfig retorna Hashtable" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "  [FAIL] Initialize-DashboardConfig retorna: $($dashConfig.GetType().Name)" -ForegroundColor Red
        $testsFailed++
    }

    # Verificar estructura
    if ($dashConfig.ui.colorsParadise) {
        Write-Host "  [OK] colorsParadise accesible en Hashtable" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "  [FAIL] colorsParadise NO accesible" -ForegroundColor Red
        $testsFailed++
    }

    if ($dashConfig.ui.typography) {
        Write-Host "  [OK] typography accesible en Hashtable" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "  [FAIL] typography NO accesible" -ForegroundColor Red
        $testsFailed++
    }

} catch {
    Write-Host "  [FAIL] Error: $_" -ForegroundColor Red
    $testsFailed += 3
}

# ============================================
# TEST 4: Verificar Dashboard-UI.ps1
# ============================================
Write-Host "`n[TEST 4] Verificar Dashboard-UI.ps1..." -ForegroundColor Yellow

try {
    . (Join-Path $ScriptRoot "UI\Dashboard-UI.ps1")

    # Verificar funciones Paradise
    $paradiseFunctions = @(
        "New-SystemInfoCard",
        "New-SectionSeparator",
        "New-CriticalActionsSection",
        "New-DashboardFooter",
        "New-CodeBlock",
        "New-SuccessBox",
        "New-WarningBox",
        "New-DangerBox",
        "Get-ParadiseGlobalCSS"
    )

    $functionsMissing = 0

    foreach ($funcName in $paradiseFunctions) {
        $exists = Get-Command $funcName -ErrorAction SilentlyContinue
        if ($exists) {
            Write-Host "  [OK] $funcName existe" -ForegroundColor Green
            $testsPassed++
        } else {
            Write-Host "  [FAIL] $funcName NO existe" -ForegroundColor Red
            $testsFailed++
            $functionsMissing++
        }
    }

    if ($functionsMissing -eq 0) {
        Write-Host "  [OK] Todas las funciones Paradise implementadas (9/9)" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] Faltan $functionsMissing funciones Paradise" -ForegroundColor Yellow
    }

} catch {
    Write-Host "  [FAIL] Error al cargar Dashboard-UI: $_" -ForegroundColor Red
    $testsFailed += 9
}

# ============================================
# RESUMEN
# ============================================
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  RESUMEN DE PRUEBAS" -ForegroundColor White
Write-Host "============================================" -ForegroundColor Cyan

$totalTests = $testsPassed + $testsFailed
$successRate = if ($totalTests -gt 0) { [math]::Round(($testsPassed / $totalTests) * 100, 2) } else { 0 }

Write-Host "Tests ejecutados: $totalTests" -ForegroundColor White
Write-Host "Tests exitosos: $testsPassed" -ForegroundColor Green
Write-Host "Tests fallidos: $testsFailed" -ForegroundColor $(if ($testsFailed -eq 0) { "Green" } else { "Red" })
Write-Host "Tasa de exito: $successRate%" -ForegroundColor $(if ($successRate -eq 100) { "Green" } elseif ($successRate -ge 80) { "Yellow" } else { "Red" })

Write-Host "`n============================================" -ForegroundColor Cyan

if ($testsFailed -eq 0) {
    Write-Host "  RESTAURACION PARADISE: OK" -ForegroundColor Green
    Write-Host "  Dashboard listo para iniciarse" -ForegroundColor Green
    Write-Host "============================================`n" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "  RESTAURACION PARADISE: ERRORES DETECTADOS" -ForegroundColor Red
    Write-Host "  Revisa los errores antes de iniciar dashboard" -ForegroundColor Yellow
    Write-Host "============================================`n" -ForegroundColor Cyan
    exit 1
}
