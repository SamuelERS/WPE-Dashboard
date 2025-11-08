# ============================================
# CREAR USUARIO POS
# ============================================
<# METADATA
Name: Crear Usuario POS
Description: Crea usuario para sistema POS
Category: POS
RequiresAdmin: true
Icon: shopping-cart
Order: 1
Enabled: true
#>
# @FormField: nombreUsuario|Nombre del usuario POS|textbox
# @FormField: password|Password|password

<#
.SYNOPSIS
    Crea un usuario estÃ¡ndar para punto de venta
.DESCRIPTION
    Script modular para crear usuarios POS sin permisos de administrador.
    Agrega el usuario al grupo Usuarios (no Administradores).
.NOTES
    Requiere permisos de administrador
    Parte de la arquitectura modular WPE-Dashboard
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$nombreUsuario,
    
    [Parameter(Mandatory=$true)]
    [string]$password
)

# Detectar ubicaciÃ³n del dashboard para rutas relativas
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
    
    # Validar que se proporcionÃ³ nombre de usuario
    if ([string]::IsNullOrWhiteSpace($nombreUsuario)) {
        throw "Debes ingresar un nombre de usuario vÃ¡lido"
    }
    
    # Sanitizar input
    $nombreUsuario = Sanitize-Input -Input $nombreUsuario
    
    # Validar nombre de usuario usando utilidad
    if (-not (Test-ValidUsername -Username $nombreUsuario)) {
        throw "Nombre de usuario invÃ¡lido. Debe tener 3-20 caracteres alfanumÃ©ricos, guiones o guiones bajos."
    }
    
    # Validar password (obligatorio)
    if ([string]::IsNullOrWhiteSpace($password)) {
        throw "Debes ingresar un password para el nuevo usuario. Campo obligatorio."
    }
    
    # Validar longitud de password (mÃ­nimo 4 para POS)
    if (-not (Test-ValidPassword -Password $password -MinLength 4)) {
        throw "El password debe tener al menos 4 caracteres."
    }
    
    # Verificar si el usuario ya existe
    $usuarioExiste = Get-LocalUser -Name $nombreUsuario -ErrorAction SilentlyContinue
    if ($usuarioExiste) {
        throw "El usuario '$nombreUsuario' ya existe. Usa otro nombre o elimina el usuario existente primero."
    }
    
    # Auto-detectar PC
    $nombrePC = $env:COMPUTERNAME
    Write-DashboardLog -Message "Creando usuario POS '$nombreUsuario' en PC: $nombrePC" -Level "Info" -Component "Crear-Usuario-POS"
    
    # Crear usuario POS (sin permisos admin)
    $securePass = ConvertTo-SecureString $password -AsPlainText -Force
    New-LocalUser -Name $nombreUsuario `
                  -Password $securePass `
                  -FullName "Usuario POS" `
                  -Description "Usuario POS - PC: $nombrePC" `
                  -PasswordNeverExpires `
                  -UserMayNotChangePassword `
                  -ErrorAction Stop | Out-Null
    
    # Agregar a grupo Usuarios (NO Administradores)
    Add-LocalGroupMember -Group "Usuarios" -Member $nombreUsuario -ErrorAction Stop
    
    Write-DashboardLog -Message "Usuario POS '$nombreUsuario' creado exitosamente en PC: $nombrePC" -Level "Info" -Component "Crear-Usuario-POS"
    
    return @{
        Success = $true
        Message = "Usuario POS '$nombreUsuario' creado exitosamente (sin permisos de administrador)."
        Username = $nombreUsuario
        PC = $nombrePC
    }
    
} catch {
    $errorMsg = $_.Exception.Message
    Write-DashboardLog -Message "Error al crear usuario POS: $errorMsg" -Level "Error" -Component "Crear-Usuario-POS"
    
    return @{
        Success = $false
        Message = "Error: $errorMsg"
    }
}

