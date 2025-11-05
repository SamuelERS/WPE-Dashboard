# @Name: Cambiar Nombre del PC
# @Description: Cambia el nombre del equipo de forma amigable
# @Category: Configuracion
# @RequiresAdmin: true
# @HasForm: true
# @FormField: nuevoNombre|Nuevo nombre del PC|textbox

<#
.SYNOPSIS
    Cambia el nombre del equipo de Windows
.DESCRIPTION
    Script para cambiar el nombre del PC de forma amigable.
    Detecta el nombre actual y permite cambiarlo a uno más descriptivo.
    Requiere reinicio del equipo para aplicar cambios.
.NOTES
    Requiere permisos de administrador
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$nuevoNombre
)

# Función de logging
function Write-ScriptLog {
    param([string]$Mensaje)
    $LogFile = "C:\WPE-Dashboard\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    try {
        if (-not (Test-Path (Split-Path $LogFile))) {
            New-Item -Path (Split-Path $LogFile) -ItemType Directory -Force | Out-Null
        }
        Add-Content -Path $LogFile -Value "[$Timestamp] Cambiar-Nombre-PC: $Mensaje" -ErrorAction SilentlyContinue
    } catch {
        Write-Warning "No se pudo escribir en el log: $_"
    }
}

try {
    # Obtener nombre actual del PC
    $nombreActual = $env:COMPUTERNAME
    Write-ScriptLog "Nombre actual del PC: $nombreActual"
    
    # Validar que se proporcionó un nuevo nombre
    if ([string]::IsNullOrWhiteSpace($nuevoNombre)) {
        throw "Debes ingresar un nuevo nombre para el PC"
    }
    
    # Validar formato del nombre
    # Nombres de PC válidos: 1-15 caracteres, letras, números y guiones
    # No puede empezar o terminar con guión
    if ($nuevoNombre -notmatch '^[a-zA-Z0-9]([a-zA-Z0-9-]{0,13}[a-zA-Z0-9])?$') {
        throw "Nombre inválido. Usa solo letras, números y guiones (1-15 caracteres). No puede empezar o terminar con guión."
    }
    
    # Verificar si el nombre es diferente al actual
    if ($nuevoNombre -eq $nombreActual) {
        throw "El nuevo nombre es igual al actual. No hay cambios que realizar."
    }
    
    # Verificar permisos de administrador
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        throw "Se requieren permisos de administrador para cambiar el nombre del PC"
    }
    
    Write-ScriptLog "Cambiando nombre de '$nombreActual' a '$nuevoNombre'"
    
    # Cambiar el nombre del PC
    Rename-Computer -NewName $nuevoNombre -Force -ErrorAction Stop
    
    Write-ScriptLog "Nombre del PC cambiado exitosamente a: $nuevoNombre"
    
    # Retornar resultado exitoso
    return @{
        Success = $true
        Message = "Nombre del PC cambiado de '$nombreActual' a '$nuevoNombre'. IMPORTANTE: Debes reiniciar el equipo para aplicar los cambios."
        RequiereReinicio = $true
        NombreAnterior = $nombreActual
        NombreNuevo = $nuevoNombre
    }
    
} catch {
    $errorMsg = $_.Exception.Message
    Write-ScriptLog "Error al cambiar nombre del PC: $errorMsg"
    
    return @{
        Success = $false
        Message = "Error: $errorMsg"
    }
}
