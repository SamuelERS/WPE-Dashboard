# ============================================
# INSTALADOR DE DEPENDENCIAS - WPE Dashboard
# ============================================
# Script para instalar todos los requisitos necesarios en una PC nueva
# Ejecutar UNA SOLA VEZ en cada PC donde se vaya a usar el dashboard

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  INSTALADOR DE DEPENDENCIAS" -ForegroundColor Green
Write-Host "  WPE-Dashboard - Paradise-SystemLabs" -ForegroundColor Green
Write-Host "============================================`n" -ForegroundColor Cyan

# Verificar permisos de administrador
Write-Host "[1/4] Verificando permisos administrativos..." -ForegroundColor Cyan
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[ERROR] Este script requiere permisos de administrador" -ForegroundColor Red
    Write-Host "`nPor favor:" -ForegroundColor Yellow
    Write-Host "1. Cierra esta ventana" -ForegroundColor Yellow
    Write-Host "2. Haz clic derecho en PowerShell" -ForegroundColor Yellow
    Write-Host "3. Selecciona 'Ejecutar como administrador'" -ForegroundColor Yellow
    Write-Host "4. Vuelve a ejecutar este script`n" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "[OK] Ejecutando con permisos administrativos`n" -ForegroundColor Green

# Verificar version de PowerShell
Write-Host "[2/4] Verificando version de PowerShell..." -ForegroundColor Cyan
$psVersion = $PSVersionTable.PSVersion.Major

if ($psVersion -lt 5) {
    Write-Host "[ERROR] PowerShell version $psVersion detectada" -ForegroundColor Red
    Write-Host "Se requiere PowerShell 5.1 o superior" -ForegroundColor Red
    Write-Host "Descarga desde: https://aka.ms/wmf5download`n" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "[OK] PowerShell version $($PSVersionTable.PSVersion) detectada`n" -ForegroundColor Green

# Verificar si el modulo ya esta instalado
Write-Host "[3/4] Verificando UniversalDashboard.Community..." -ForegroundColor Cyan
$moduloExiste = Get-Module -ListAvailable -Name UniversalDashboard.Community

if ($moduloExiste) {
    Write-Host "[INFO] El modulo ya esta instalado (version $($moduloExiste.Version))" -ForegroundColor Yellow
    $respuesta = Read-Host "Deseas reinstalarlo? (S/N)"

    if ($respuesta -ne "S" -and $respuesta -ne "s") {
        Write-Host "[SKIP] Manteniendo version actual`n" -ForegroundColor Gray
    } else {
        Write-Host "[INFO] Desinstalando version anterior..." -ForegroundColor Yellow
        try {
            Uninstall-Module -Name UniversalDashboard.Community -AllVersions -Force -ErrorAction Stop
            Write-Host "[OK] Modulo anterior desinstalado`n" -ForegroundColor Green
        } catch {
            Write-Host "[WARN] No se pudo desinstalar: $_" -ForegroundColor Yellow
            Write-Host "[INFO] Continuando con la instalacion...`n" -ForegroundColor Cyan
        }
    }
}

# Instalar el modulo
if (-not $moduloExiste -or ($respuesta -eq "S" -or $respuesta -eq "s")) {
    Write-Host "[4/4] Instalando UniversalDashboard.Community..." -ForegroundColor Cyan
    Write-Host "[INFO] Esto puede tardar varios minutos. Por favor espera...`n" -ForegroundColor Yellow

    try {
        # Configurar repositorio de PowerShell Gallery como confiable (temporalmente)
        $repoPolicy = Get-PSRepository -Name PSGallery | Select-Object -ExpandProperty InstallationPolicy
        if ($repoPolicy -ne "Trusted") {
            Write-Host "[INFO] Configurando PSGallery como confiable..." -ForegroundColor Gray
            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        }

        # Instalar el modulo (version especifica 2.9.0 para compatibilidad)
        Install-Module -Name UniversalDashboard.Community -RequiredVersion 2.9.0 -Scope AllUsers -Force -AllowClobber

        # Restaurar politica original
        if ($repoPolicy -ne "Trusted") {
            Set-PSRepository -Name PSGallery -InstallationPolicy $repoPolicy
        }

        Write-Host "`n[OK] UniversalDashboard.Community instalado exitosamente" -ForegroundColor Green

    } catch {
        Write-Host "`n[ERROR] Fallo la instalacion: $_" -ForegroundColor Red
        Write-Host "`nIntenta instalarlo manualmente:" -ForegroundColor Yellow
        Write-Host "Install-Module -Name UniversalDashboard.Community -Force`n" -ForegroundColor White
        pause
        exit 1
    }
} else {
    Write-Host "[4/4] Modulo ya instalado - omitiendo paso`n" -ForegroundColor Gray
}

# Verificar instalacion
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  VERIFICACION FINAL" -ForegroundColor Green
Write-Host "============================================`n" -ForegroundColor Cyan

try {
    Import-Module UniversalDashboard.Community -ErrorAction Stop
    $moduloInfo = Get-Module -Name UniversalDashboard.Community

    Write-Host "[OK] Modulo cargado exitosamente" -ForegroundColor Green
    Write-Host "[OK] Version: $($moduloInfo.Version)" -ForegroundColor Green
    Write-Host "[OK] Ubicacion: $($moduloInfo.Path)`n" -ForegroundColor Green

} catch {
    Write-Host "[ERROR] No se pudo cargar el modulo: $_" -ForegroundColor Red
    Write-Host "`nContacta al administrador del sistema`n" -ForegroundColor Yellow
    pause
    exit 1
}

# Crear carpetas necesarias
Write-Host "Verificando estructura de carpetas..." -ForegroundColor Cyan
$carpetas = @("Logs", "Backup", "Temp")
foreach ($carpeta in $carpetas) {
    $ruta = "C:\WPE-Dashboard\$carpeta"
    if (-not (Test-Path $ruta)) {
        New-Item -Path $ruta -ItemType Directory -Force | Out-Null
        Write-Host "[OK] Carpeta creada: $carpeta" -ForegroundColor Green
    } else {
        Write-Host "[OK] Carpeta existe: $carpeta" -ForegroundColor Gray
    }
}

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  INSTALACION COMPLETADA" -ForegroundColor Green
Write-Host "============================================`n" -ForegroundColor Cyan

Write-Host "Todos los requisitos estan instalados correctamente" -ForegroundColor Green
Write-Host "PC: $env:COMPUTERNAME" -ForegroundColor Yellow
Write-Host "`nPuedes iniciar el dashboard ejecutando:" -ForegroundColor Cyan
Write-Host ".\Iniciar-Dashboard.bat`n" -ForegroundColor White

Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
