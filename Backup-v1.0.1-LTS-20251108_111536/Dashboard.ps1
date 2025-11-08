# ============================================
# DASHBOARD PARADISE-SYSTEMLABS v1.0.1-LTS
# ============================================
# Version: 1.0.1-LTS - PARADISE DESIGN RESTORATION
# Arquitectura: Modular v2.0
# Estado: CERTIFICADO PARA PRODUCCION
# Fecha: 2025-11-08

<#
.SYNOPSIS
    Dashboard IT modular para gestion de sistemas Windows

.DESCRIPTION
    Dashboard web con arquitectura modular que carga scripts
    dinamicamente desde la carpeta Scripts/ y genera UI automaticamente

.PARAMETER Version
    Muestra la version del dashboard y sale

.EXAMPLE
    .\Dashboard.ps1
    .\Dashboard.ps1 -Version

.NOTES
    Version: 1.0.1-LTS
    Requiere: UniversalDashboard.Community 2.9.0
    Puerto: 10000
    Estado: PARADISE DESIGN RESTORATION
#>

param(
    [switch]$Version
)

# ============================================
# INICIALIZACION BASICA
# ============================================

# Detectar ubicacion del script (PORTABLE)
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Global:DashboardRoot = $ScriptRoot
$Global:DashboardVersion = "1.0.1-LTS"
$Global:DashboardState = "PARADISE DESIGN RESTORATION"

# Manejar parametro -Version
if ($Version) {
    Write-Host "`n============================================" -ForegroundColor Cyan
    Write-Host "  DASHBOARD PARADISE-SYSTEMLABS" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "Version: $Global:DashboardVersion" -ForegroundColor White
    Write-Host "Estado: $Global:DashboardState" -ForegroundColor Green
    Write-Host "Arquitectura: Modular v2.0" -ForegroundColor White
    Write-Host "Fecha Release: 2025-11-07" -ForegroundColor White
    Write-Host "Certificacion: APROBADO PARA PRODUCCION" -ForegroundColor Green
    Write-Host "Ubicacion: $ScriptRoot" -ForegroundColor Gray
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    exit 0
}

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  DASHBOARD PARADISE-SYSTEMLABS v$Global:DashboardVersion" -ForegroundColor Green
Write-Host "  Arquitectura Modular - $Global:DashboardState" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Ubicacion: $ScriptRoot" -ForegroundColor Gray

# ============================================
# IMPORTAR MODULOS CORE
# ============================================

Write-Host "`n[INFO] Cargando modulos core..." -ForegroundColor Cyan

# Logging (requerido primero)
. (Join-Path $ScriptRoot "Utils\Logging-Utils.ps1")
Write-Host "[OK] Logging-Utils cargado" -ForegroundColor Green

# Inicializacion
. (Join-Path $ScriptRoot "Core\Dashboard-Init.ps1")
Write-Host "[OK] Dashboard-Init cargado" -ForegroundColor Green

# ScriptLoader
. (Join-Path $ScriptRoot "Core\ScriptLoader.ps1")
Write-Host "[OK] ScriptLoader cargado" -ForegroundColor Green

# UI
. (Join-Path $ScriptRoot "UI\Dashboard-UI.ps1")
Write-Host "[OK] Dashboard-UI cargado" -ForegroundColor Green

# ============================================
# INICIALIZACION Y VALIDACION
# ============================================

# Validar y cargar configuracion
$dashConfig = Initialize-DashboardConfig

# Extraer colores y espaciado
$Colors = Get-DashboardColors -Config $dashConfig
$Spacing = Get-DashboardSpacing -Config $dashConfig

# Verificar e instalar UniversalDashboard
$udReady = Initialize-UniversalDashboard

# ============================================
# CARGAR SCRIPTS Y CATEGORIAS
# ============================================

Write-Host "`n[INFO] Cargando scripts y categorias..." -ForegroundColor Cyan

# Cargar scripts con metadata
$scriptsByCategory = Get-ScriptsByCategory
Write-Host "[OK] Scripts cargados: $($scriptsByCategory.Keys.Count) categorias" -ForegroundColor Green

# Cargar configuracion de categorias
$categoriesConfig = Get-CategoriesConfig
Write-Host "[OK] Configuracion de categorias cargada" -ForegroundColor Green

# ============================================
# CREAR Y LANZAR DASHBOARD
# ============================================

Write-Host "`n[INFO] Iniciando dashboard..." -ForegroundColor Cyan
Write-Host "PC ACTUAL: $env:COMPUTERNAME" -ForegroundColor Yellow
Write-Host "IMPORTANTE: Los usuarios se crearan en este PC" -ForegroundColor Yellow

# Obtener IP local
try {
    $ipAddress = (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop | 
                  Where-Object {$_.IPAddress -notlike '169.*' -and $_.IPAddress -notlike '127.*'} | 
                  Select-Object -First 1).IPAddress
    Write-Host "URL Local: http://localhost:10000" -ForegroundColor Cyan
    Write-Host "URL Red: http://${ipAddress}:10000" -ForegroundColor Cyan
} catch {
    Write-Host "URL Local: http://localhost:10000" -ForegroundColor Cyan
}

Write-Host "`n[INFO] Generando interfaz dinamica..." -ForegroundColor Cyan

# =====================================================
# DASHBOARD CREATION - COMMUNITY v2.9.0 COMPATIBILITY
# =====================================================
# NOTA: UniversalDashboard.Community NO soporta -ArgumentList
# Usamos $Cache: scope para pasar variables al scriptblock

# Guardar variables en cache global (compatible con Community v2.9.0)
$Cache:ScriptsByCategory = $scriptsByCategory
$Cache:CategoriesConfig  = $categoriesConfig
$Cache:Config            = $dashConfig

# Crear dashboard con UI dinamica
$dashboard = New-UDDashboard -Title "Dashboard IT Paradise-SystemLabs" -Content {
    # Usar variables de cache dentro del scriptblock
    New-DashboardContent -ScriptsByCategory $Cache:ScriptsByCategory `
                        -CategoriesConfig $Cache:CategoriesConfig `
                        -Config $Cache:Config
}

# Iniciar servidor
try {
    Write-Host "`n[INFO] Iniciando servidor en puerto 10000..." -ForegroundColor Cyan
    
    Start-UDDashboard -Dashboard $dashboard -Port 10000 -Force
    
    Write-Host "`n============================================" -ForegroundColor Green
    Write-Host "  DASHBOARD INICIADO EXITOSAMENTE" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "`nAbre tu navegador en: http://localhost:10000" -ForegroundColor White
    Write-Host "`nPresiona Ctrl+C para detener el dashboard" -ForegroundColor Gray
    Write-Host "============================================`n" -ForegroundColor Cyan
    
    Write-DashboardLog -Message "Dashboard v2.0 iniciado en puerto 10000" -Level "Info" -Component "Dashboard"
    
    # Abrir navegador automaticamente despues de 3 segundos
    Start-Job -ScriptBlock {
        Start-Sleep -Seconds 3
        try {
            # Intentar abrir con navegador predeterminado
            Start-Process "http://localhost:10000"
        } catch {
            # Fallback: intentar con Edge o Chrome
            try {
                Start-Process "msedge.exe" "http://localhost:10000"
            } catch {
                try {
                    Start-Process "chrome.exe" "http://localhost:10000"
                } catch {
                    # Silencioso si falla
                }
            }
        }
    } | Out-Null
    
    # Mantener el proceso activo
    while ($true) {
        Start-Sleep -Seconds 1
    }
    
} catch {
    Write-Host "`n[ERROR] Error al iniciar dashboard: $_" -ForegroundColor Red
    Write-Host "`nPosibles soluciones:" -ForegroundColor Yellow
    Write-Host "  1. Verifica que el puerto 10000 este libre" -ForegroundColor White
    Write-Host "  2. Ejecuta: .\Tools\Limpiar-Puerto-10000.ps1" -ForegroundColor White
    Write-Host "  3. Reinicia el equipo si el problema persiste" -ForegroundColor White
    
    Write-DashboardLog -Message "Error al iniciar dashboard: $_" -Level "Error" -Component "Dashboard"
    
    pause
    exit 1
}
