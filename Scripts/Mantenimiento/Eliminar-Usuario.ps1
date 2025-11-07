# ============================================
# ELIMINAR USUARIO
# ============================================
# @Name: Eliminar Usuario
# @Description: Elimina un usuario local del sistema de forma segura
# @Category: Mantenimiento
# @RequiresAdmin: true
# @HasForm: true
# @FormField: nombreUsuario|Nombre del usuario a eliminar|textbox

<#
.SYNOPSIS
    Elimina un usuario local del sistema
.DESCRIPTION
    Script modular para eliminar usuarios locales de Windows con validaciones de seguridad.
    Protege usuarios críticos del sistema y elimina el perfil del usuario.
.NOTES
    Requiere permisos de administrador
    Parte de la arquitectura modular WPE-Dashboard
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$nombreUsuario
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
    
    # Validar que se proporcionó nombre de usuario
    if ([string]::IsNullOrWhiteSpace($nombreUsuario)) {
        throw "Debes ingresar el nombre del usuario a eliminar"
    }
    
    # Sanitizar input
    $nombreUsuario = Sanitize-Input -Input $nombreUsuario
    
    # Lista de usuarios protegidos que NO se pueden eliminar
    $usuariosProtegidos = @(
        "Administrator", 
        "Administrador", 
        "DefaultAccount", 
        "Guest", 
        "Invitado", 
        "WDAGUtilityAccount"
    )
    
    # Verificar que no sea un usuario protegido
    if ($usuariosProtegidos -contains $nombreUsuario) {
        throw "No se puede eliminar el usuario '$nombreUsuario' (usuario protegido del sistema)"
    }
    
    # Verificar si el usuario existe
    $usuarioExiste = Get-LocalUser -Name $nombreUsuario -ErrorAction SilentlyContinue
    if (-not $usuarioExiste) {
        throw "El usuario '$nombreUsuario' no existe"
    }
    
    # Auto-detectar PC
    $nombrePC = $env:COMPUTERNAME
    Write-DashboardLog -Message "Eliminando usuario '$nombreUsuario' en PC: $nombrePC" -Level "Info" -Component "Eliminar-Usuario"
    
    # Eliminar usuario
    Remove-LocalUser -Name $nombreUsuario -ErrorAction Stop
    
    # Eliminar carpeta de perfil si existe
    $perfilPath = "C:\Users\$nombreUsuario"
    if (Test-Path $perfilPath) {
        Start-Sleep -Seconds 1
        Remove-Item -Path $perfilPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-DashboardLog -Message "Perfil del usuario eliminado: $perfilPath" -Level "Info" -Component "Eliminar-Usuario"
    }
    
    # Limpiar del registro de usuarios ocultos
    try {
        $registroSpecialAccounts = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
        if (Test-Path $registroSpecialAccounts) {
            Remove-ItemProperty -Path $registroSpecialAccounts -Name $nombreUsuario -ErrorAction SilentlyContinue
        }
    } catch {
        # Ignorar errores de registro
    }
    
    Write-DashboardLog -Message "Usuario '$nombreUsuario' eliminado exitosamente en PC: $nombrePC" -Level "Info" -Component "Eliminar-Usuario"
    
    return @{
        Success = $true
        Message = "Usuario '$nombreUsuario' eliminado exitosamente"
        Username = $nombreUsuario
        PC = $nombrePC
    }
    
} catch {
    $errorMsg = $_.Exception.Message
    Write-DashboardLog -Message "Error al eliminar usuario: $errorMsg" -Level "Error" -Component "Eliminar-Usuario"
    
    return @{
        Success = $false
        Message = "Error: $errorMsg"
    }
}
