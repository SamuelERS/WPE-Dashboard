# ============================================
# VERIFICACIÓN DEL SISTEMA
# ============================================
# Script para verificar que todo está correctamente configurado

# Detectar ubicación del dashboard para rutas relativas
if (-not $Global:DashboardRoot) {
    $Global:DashboardRoot = Split-Path -Parent $PSScriptRoot
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  VERIFICACION DEL SISTEMA - DASHBOARD IT" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Ubicación: $Global:DashboardRoot" -ForegroundColor Gray
Write-Host ""

$errores = 0
$advertencias = 0

# Función para mostrar resultados
function Show-Check {
    param(
        [string]$Nombre,
        [bool]$Resultado,
        [string]$Mensaje = "",
        [string]$Tipo = "Error"
    )
    
    if ($Resultado) {
        Write-Host "[OK] " -ForegroundColor Green -NoNewline
        Write-Host $Nombre
    } else {
        if ($Tipo -eq "Warning") {
            Write-Host "[WARN] " -ForegroundColor Yellow -NoNewline
            $script:advertencias++
        } else {
            Write-Host "[ERROR] " -ForegroundColor Red -NoNewline
            $script:errores++
        }
        Write-Host $Nombre
        if ($Mensaje) {
            Write-Host "       $Mensaje" -ForegroundColor Gray
        }
    }
}

Write-Host "1. VERIFICANDO PERMISOS" -ForegroundColor White
Write-Host "─────────────────────────────────────────" -ForegroundColor Gray

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Show-Check "Permisos de Administrador" $isAdmin "Ejecuta este script como Administrador"

Write-Host ""
Write-Host "2. VERIFICANDO MÓDULOS" -ForegroundColor White
Write-Host "─────────────────────────────────────────" -ForegroundColor Gray

$udModule = Get-Module -ListAvailable -Name "UniversalDashboard.Community"
Show-Check "Universal Dashboard Community instalado" ($null -ne $udModule) "Ejecuta: Install-Module UniversalDashboard.Community"

$psVersion = $PSVersionTable.PSVersion.Major -ge 5
Show-Check "PowerShell 5.1 o superior" $psVersion "Versión actual: $($PSVersionTable.PSVersion)"

Write-Host ""
Write-Host "3. VERIFICANDO ESTRUCTURA DE CARPETAS" -ForegroundColor White
Write-Host "─────────────────────────────────────────" -ForegroundColor Gray

$carpetas = @(
    "Scripts",
    "Scripts\Configuracion",
    "Scripts\Mantenimiento",
    "Scripts\POS",
    "Scripts\Diseno",
    "Scripts\Atencion-Al-Cliente",
    "Scripts\Auditoria",
    "Logs"
)

foreach ($carpeta in $carpetas) {
    $rutaCompleta = Join-Path $Global:DashboardRoot $carpeta
    $existe = Test-Path $rutaCompleta
    Show-Check $carpeta $existe "Crear carpeta: $rutaCompleta" "Warning"
}

Write-Host ""
Write-Host "4. VERIFICANDO ARCHIVOS PRINCIPALES" -ForegroundColor White
Write-Host "─────────────────────────────────────────" -ForegroundColor Gray

$archivos = @(
    "Dashboard.ps1",
    "Iniciar-Dashboard.bat",
    "README.md",
    ".gitignore",
    "Scripts\PLANTILLA-Script.ps1",
    "Scripts\ScriptLoader.ps1",
    "Docs\GUIA-AGREGAR-SCRIPTS.md",
    "Docs\REGLAS-DE-LA-CASA.md"
)

foreach ($archivo in $archivos) {
    $rutaCompleta = Join-Path $Global:DashboardRoot $archivo
    $existe = Test-Path $rutaCompleta
    $nombre = Split-Path $archivo -Leaf
    Show-Check $nombre $existe "Archivo faltante: $rutaCompleta"
}

Write-Host ""
Write-Host "5. VERIFICANDO RED" -ForegroundColor White
Write-Host "─────────────────────────────────────────" -ForegroundColor Gray

$puerto10000Libre = $null -eq (Get-NetTCPConnection -LocalPort 10000 -ErrorAction SilentlyContinue)
Show-Check "Puerto 10000 disponible" $puerto10000Libre "Puerto en uso. Detén el dashboard actual" "Warning"

$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"} | Select-Object -First 1).IPAddress
if ($ip) {
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host "IP del servidor: $ip"
} else {
    Write-Host "[WARN] " -ForegroundColor Yellow -NoNewline
    Write-Host "No se pudo detectar IP"
    $advertencias++
}

Write-Host ""
Write-Host "6. VERIFICANDO SCRIPTS" -ForegroundColor White
Write-Host "─────────────────────────────────────────" -ForegroundColor Gray

$scriptsPath = Join-Path $Global:DashboardRoot "Scripts"
$totalScripts = (Get-ChildItem $scriptsPath -Recurse -Filter "*.ps1" | 
                 Where-Object {$_.Name -ne "ScriptLoader.ps1" -and $_.Name -ne "PLANTILLA-Script.ps1"} | 
                 Measure-Object).Count

Write-Host "[INFO] Scripts implementados: $totalScripts" -ForegroundColor Cyan

# Verificar sintaxis de scripts
$scriptsConErrores = 0
Get-ChildItem $scriptsPath -Recurse -Filter "*.ps1" | 
    Where-Object {$_.Name -ne "ScriptLoader.ps1"} | 
    ForEach-Object {
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $_.FullName -Raw), [ref]$errors)
        if ($errors) {
            $scriptsConErrores++
        }
    }

Show-Check "Scripts sin errores de sintaxis" ($scriptsConErrores -eq 0) "$scriptsConErrores scripts con errores"

Write-Host ""
Write-Host "7. VERIFICANDO LOGS" -ForegroundColor White
Write-Host "─────────────────────────────────────────" -ForegroundColor Gray

$logActual = Join-Path $Global:DashboardRoot "Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
$logExiste = Test-Path $logActual
Show-Check "Log del mes actual" $logExiste "Se creará automáticamente al usar el dashboard" "Warning"

if ($logExiste) {
    $logSize = (Get-Item $logActual).Length / 1KB
    Write-Host "[INFO] Tamaño del log: $([math]::Round($logSize, 2)) KB" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  RESUMEN DE VERIFICACIÓN" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

if ($errores -eq 0 -and $advertencias -eq 0) {
    Write-Host "✓ SISTEMA COMPLETAMENTE OPERATIVO" -ForegroundColor Green
    Write-Host ""
    Write-Host "El dashboard está listo para usarse." -ForegroundColor White
    Write-Host "Ejecuta: .\Iniciar-Dashboard.bat" -ForegroundColor Cyan
} elseif ($errores -eq 0) {
    Write-Host "⚠ SISTEMA OPERATIVO CON ADVERTENCIAS" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Advertencias: $advertencias" -ForegroundColor Yellow
    Write-Host "El dashboard debería funcionar, pero revisa las advertencias." -ForegroundColor White
} else {
    Write-Host "✗ SISTEMA CON ERRORES" -ForegroundColor Red
    Write-Host ""
    Write-Host "Errores: $errores" -ForegroundColor Red
    Write-Host "Advertencias: $advertencias" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Corrige los errores antes de usar el dashboard." -ForegroundColor White
}

Write-Host ""
Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
