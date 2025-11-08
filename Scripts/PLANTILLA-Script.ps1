# ============================================
# PLANTILLA DE SCRIPT PARA DASHBOARD
# ============================================
# Copia este archivo y modifica según necesites
#
# METADATA (usado por el sistema de carga automática):
# @Name: Nombre del Script
# @Description: Descripción breve de lo que hace
# @RequiresAdmin: true/false
# @HasForm: true/false
# @FormField: nombreCampo|Placeholder|tipo (textbox/select/password)
# @FormField: otroCampo|Otro placeholder|textbox
#
# EJEMPLO DE METADATA:
# @Name: Crear Usuario del Sistema
# @Description: Crea un nuevo usuario local de Windows
# @RequiresAdmin: true
# @HasForm: true
# @FormField: nombreUsuario|Nombre del usuario|textbox
# @FormField: password|Password|password
# @FormField: tipoUsuario|Tipo de usuario|select:POS,Admin,Diseno
# ============================================

param(
    [string]$nombreUsuario,
    [string]$password,
    [string]$tipoUsuario
)

# Función de logging (siempre disponible - PORTABLE)
function Write-ScriptLog {
    param([string]$Mensaje)
    if (-not $Global:DashboardRoot) {
        $Global:DashboardRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    }
    $LogFile = Join-Path $Global:DashboardRoot "Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$Timestamp] $Mensaje" -ErrorAction SilentlyContinue
}

# Validar permisos si es necesario
function Test-AdminPrivileges {
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    return $isAdmin
}

# Auto-detectar nombre de PC
$nombrePC = $env:COMPUTERNAME
Write-ScriptLog "Ejecutando script en: $nombrePC"

# ============================================
# TU CÓDIGO AQUÍ
# ============================================

try {
    # Validaciones
    if ([string]::IsNullOrWhiteSpace($nombreUsuario)) {
        throw "Debes ingresar un nombre de usuario"
    }
    
    # Verificar permisos admin si es necesario
    if (-not (Test-AdminPrivileges)) {
        throw "Este script requiere permisos de administrador"
    }
    
    # Tu lógica aquí
    Write-Host "Ejecutando acción..." -ForegroundColor Cyan
    
    # Ejemplo: crear usuario
    # $securePass = ConvertTo-SecureString $password -AsPlainText -Force
    # New-LocalUser -Name $nombreUsuario -Password $securePass ...
    
    Write-ScriptLog "Script ejecutado exitosamente"
    return @{
        Success = $true
        Message = "Operación completada exitosamente"
    }
    
} catch {
    Write-ScriptLog "Error: $_"
    return @{
        Success = $false
        Message = "Error: $_"
    }
}
