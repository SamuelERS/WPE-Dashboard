# ============================================
# CREAR USUARIO DEL SISTEMA
# ============================================
# @Name: Crear Usuario del Sistema
# @Description: Crea un nuevo usuario local de Windows con permisos de administrador
# @Category: Configuracion
# @RequiresAdmin: true
# @HasForm: true
# @FormField: nombreUsuario|Ejemplo: POS-Merliot|textbox
# @FormField: password|Password (obligatorio)|password
# @FormField: tipoUsuario|Tipo de usuario|select:POS,Admin,Diseno,Cliente,Mantenimiento

<#
.SYNOPSIS
    Crea un usuario local del sistema
.DESCRIPTION
    Script modular para crear usuarios locales de Windows con validaciones robustas.
    Agrega el usuario al grupo Administradores.
.NOTES
    Requiere permisos de administrador
    Parte de la arquitectura modular WPE-Dashboard
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$nombreUsuario,
    
    [Parameter(Mandatory=$true)]
    [string]$password,
    
    [Parameter(Mandatory=$false)]
    [string]$tipoUsuario = "POS"
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
        throw "Debes ingresar un nombre de usuario válido"
    }
    
    # Sanitizar input
    $nombreUsuario = Sanitize-Input -Input $nombreUsuario
    
    # Validar nombre de usuario usando utilidad
    if (-not (Test-ValidUsername -Username $nombreUsuario)) {
        throw "Nombre de usuario inválido. Debe tener 3-20 caracteres alfanuméricos, guiones o guiones bajos."
    }
    
    # Validar password (obligatorio)
    if ([string]::IsNullOrWhiteSpace($password)) {
        throw "Debes ingresar un password para el nuevo usuario. Campo obligatorio."
    }
    
    # Validar longitud de password
    if (-not (Test-ValidPassword -Password $password -MinLength 6)) {
        throw "El password debe tener al menos 6 caracteres por seguridad."
    }
    
    # Valor por defecto para tipo de usuario
    if ([string]::IsNullOrWhiteSpace($tipoUsuario)) {
        $tipoUsuario = "POS"
    }
    
    # Verificar si el usuario ya existe
    $usuarioExiste = Get-LocalUser -Name $nombreUsuario -ErrorAction SilentlyContinue
    if ($usuarioExiste) {
        throw "El usuario '$nombreUsuario' ya existe. Usa otro nombre o elimina el usuario existente primero."
    }
    
    # Auto-detectar PC
    $nombrePC = $env:COMPUTERNAME
    Write-DashboardLog -Message "Creando usuario '$nombreUsuario' en PC: $nombrePC" -Level "Info" -Component "Crear-Usuario-Sistema"
    
    # Crear usuario
    $securePass = ConvertTo-SecureString $password -AsPlainText -Force
    New-LocalUser -Name $nombreUsuario `
                  -Password $securePass `
                  -FullName "Usuario $tipoUsuario" `
                  -Description "Usuario de sistema $tipoUsuario - PC: $nombrePC" `
                  -PasswordNeverExpires `
                  -UserMayNotChangePassword `
                  -ErrorAction Stop | Out-Null
    
    # Agregar a grupo Administradores
    Add-LocalGroupMember -Group "Administradores" -Member $nombreUsuario -ErrorAction Stop
    
    Write-DashboardLog -Message "Usuario '$nombreUsuario' creado exitosamente en PC: $nombrePC" -Level "Info" -Component "Crear-Usuario-Sistema"
    
    return @{
        Success = $true
        Message = "Usuario '$nombreUsuario' creado exitosamente y agregado al grupo Administradores."
        Username = $nombreUsuario
        PC = $nombrePC
    }
    
} catch {
    $errorMsg = $_.Exception.Message
    Write-DashboardLog -Message "Error al crear usuario: $errorMsg" -Level "Error" -Component "Crear-Usuario-Sistema"
    
    return @{
        Success = $false
        Message = "Error: $errorMsg"
    }
}
