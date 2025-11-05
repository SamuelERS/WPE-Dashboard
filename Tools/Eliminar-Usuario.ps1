# ============================================
# ELIMINAR USUARIO LOCAL
# ============================================
# Herramienta para eliminar usuarios locales de Windows
# Uso: .\Eliminar-Usuario.ps1 -nombreUsuario "NombreDelUsuario"

param(
    [Parameter(Mandatory=$false)]
    [string]$nombreUsuario
)

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  ELIMINAR USUARIO LOCAL DE WINDOWS" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Verificar permisos de administrador
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[ERROR] Este script requiere permisos de administrador" -ForegroundColor Red
    Write-Host ""
    Write-Host "Ejecuta PowerShell como Administrador y vuelve a intentar" -ForegroundColor Yellow
    Write-Host ""
    pause
    exit 1
}

# Si no se proporcionó nombre de usuario, solicitar
if ([string]::IsNullOrWhiteSpace($nombreUsuario)) {
    Write-Host "Usuarios locales disponibles:" -ForegroundColor Yellow
    Write-Host "─────────────────────────────────────────" -ForegroundColor Gray
    
    $usuarios = Get-LocalUser | Where-Object {$_.Enabled -eq $true} | Select-Object Name, Description
    $usuarios | Format-Table -AutoSize
    
    Write-Host ""
    $nombreUsuario = Read-Host "Ingresa el nombre del usuario a eliminar"
}

# Validar que se ingresó un nombre
if ([string]::IsNullOrWhiteSpace($nombreUsuario)) {
    Write-Host "[ERROR] Debes ingresar un nombre de usuario" -ForegroundColor Red
    pause
    exit 1
}

# Verificar si el usuario existe
$usuario = Get-LocalUser -Name $nombreUsuario -ErrorAction SilentlyContinue

if (-not $usuario) {
    Write-Host "[ERROR] El usuario '$nombreUsuario' no existe" -ForegroundColor Red
    Write-Host ""
    pause
    exit 1
}

# Mostrar información del usuario
Write-Host ""
Write-Host "Información del usuario:" -ForegroundColor Yellow
Write-Host "─────────────────────────────────────────" -ForegroundColor Gray
Write-Host "Nombre:       $($usuario.Name)" -ForegroundColor White
Write-Host "Nombre Full:  $($usuario.FullName)" -ForegroundColor White
Write-Host "Descripción:  $($usuario.Description)" -ForegroundColor White
Write-Host "Habilitado:   $($usuario.Enabled)" -ForegroundColor White
Write-Host ""

# Confirmar eliminación
Write-Host "⚠️  ADVERTENCIA: Esta acción NO se puede deshacer" -ForegroundColor Yellow
Write-Host ""
$confirmacion = Read-Host "¿Estás seguro de eliminar el usuario '$nombreUsuario'? (SI/NO)"

if ($confirmacion -ne "SI") {
    Write-Host ""
    Write-Host "[CANCELADO] Operación cancelada por el usuario" -ForegroundColor Yellow
    Write-Host ""
    pause
    exit 0
}

# Eliminar el usuario
try {
    Write-Host ""
    Write-Host "[INFO] Eliminando usuario '$nombreUsuario'..." -ForegroundColor Cyan
    
    Remove-LocalUser -Name $nombreUsuario -ErrorAction Stop
    
    Write-Host ""
    Write-Host "[OK] Usuario '$nombreUsuario' eliminado exitosamente" -ForegroundColor Green
    Write-Host ""
    
    # Log
    $LogFile = "C:\WPE-Dashboard\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$Timestamp] Eliminar Usuario ($nombreUsuario) - Exitoso - PC: $env:COMPUTERNAME" -ErrorAction SilentlyContinue
    
} catch {
    Write-Host ""
    Write-Host "[ERROR] Error al eliminar usuario: $_" -ForegroundColor Red
    Write-Host ""
    
    # Log
    $LogFile = "C:\WPE-Dashboard\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$Timestamp] Eliminar Usuario ($nombreUsuario) - Error: $_" -ErrorAction SilentlyContinue
}

Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
