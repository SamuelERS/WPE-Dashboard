# ============================================
# CAMBIAR NOMBRE DEL PC
# ============================================
# @Name: Cambiar Nombre del PC
# @Description: Cambia el nombre del equipo de forma segura con validaciones
# @Category: Configuracion
# @RequiresAdmin: true
# @HasForm: true
# @FormField: nuevoNombre|Nuevo nombre del PC|textbox

<#
.SYNOPSIS
    Cambia el nombre del equipo de Windows
.DESCRIPTION
    Script modular para cambiar el nombre del PC de forma segura.
    Detecta el nombre actual y permite cambiarlo a uno más descriptivo.
    Requiere reinicio del equipo para aplicar cambios.
.NOTES
    Requiere permisos de administrador
    Parte de la arquitectura modular WPE-Dashboard
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$nuevoNombre
)

# Detectar ubicación del dashboard para rutas relativas
if (-not $Global:DashboardRoot) {
    $Global:DashboardRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
}

# Importar utilidades
. (Join-Path $Global:DashboardRoot "Utils\Validation-Utils.ps1")
. (Join-Path $Global:DashboardRoot "Utils\Logging-Utils.ps1")
. (Join-Path $Global:DashboardRoot "Utils\Security-Utils.ps1")

try {
    # Verificar permisos de administrador primero
    Assert-AdminPrivileges
    
    # Obtener nombre actual del PC
    $nombreActual = $env:COMPUTERNAME
    Write-DashboardLog -Message "Nombre actual del PC: $nombreActual" -Level "Info" -Component "Cambiar-Nombre-PC"
    
    # Validar que se proporcionó un nuevo nombre
    if ([string]::IsNullOrWhiteSpace($nuevoNombre)) {
        throw "Debes ingresar un nuevo nombre para el PC"
    }
    
    # Sanitizar input
    $nuevoNombre = Sanitize-Input -Input $nuevoNombre
    
    # Validar formato del nombre usando utilidad
    if (-not (Test-ValidPCName -PCName $nuevoNombre)) {
        throw "Nombre inválido. Debe tener 1-15 caracteres alfanuméricos y guiones. No puede empezar o terminar con guión."
    }
    
    # Verificar si el nombre es diferente al actual
    if ($nuevoNombre -eq $nombreActual) {
        throw "El nuevo nombre es igual al actual. No hay cambios que realizar."
    }
    
    Write-DashboardLog -Message "Cambiando nombre de '$nombreActual' a '$nuevoNombre'" -Level "Info" -Component "Cambiar-Nombre-PC"
    
    # Cambiar el nombre del PC
    Rename-Computer -NewName $nuevoNombre -Force -ErrorAction Stop
    
    Write-DashboardLog -Message "Nombre del PC cambiado exitosamente a: $nuevoNombre" -Level "Info" -Component "Cambiar-Nombre-PC"
    
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
    Write-DashboardLog -Message "Error al cambiar nombre del PC: $errorMsg" -Level "Error" -Component "Cambiar-Nombre-PC"
    
    return @{
        Success = $false
        Message = "Error: $errorMsg"
    }
}
