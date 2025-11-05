# @Name: Crear Usuario del Sistema
# @Description: Crea un nuevo usuario local de Windows con configuración automática
# @RequiresAdmin: true
# @HasForm: true
# @FormField: nombreUsuario|Ejemplo: POS-Merliot|textbox
# @FormField: password|Password (defecto: 841357)|password
# @FormField: tipoUsuario|Tipo de usuario|select:POS,Admin,Diseno,Cliente,Mantenimiento

param(
    [string]$nombreUsuario,
    [string]$password,
    [string]$tipoUsuario
)

function Write-ScriptLog {
    param([string]$Mensaje)
    $LogFile = "C:\WPE-Dashboard\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$Timestamp] $Mensaje"
}

try {
    # Validaciones
    if ([string]::IsNullOrWhiteSpace($nombreUsuario)) {
        throw "Debes ingresar un nombre de usuario"
    }
    
    # Valores por defecto
    if ([string]::IsNullOrWhiteSpace($password)) {
        $password = "841357"
    }
    
    if ([string]::IsNullOrWhiteSpace($tipoUsuario)) {
        $tipoUsuario = "POS"
    }
    
    # Verificar permisos admin
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        throw "El dashboard debe ejecutarse como Administrador"
    }
    
    # Verificar si el usuario ya existe
    $usuarioExiste = Get-LocalUser -Name $nombreUsuario -ErrorAction SilentlyContinue
    if ($usuarioExiste) {
        throw "El usuario $nombreUsuario ya existe. Usa otro nombre o elimina el usuario existente primero."
    }
    
    # Auto-detectar PC
    $nombrePC = $env:COMPUTERNAME
    Write-ScriptLog "Creando usuario $nombreUsuario en PC: $nombrePC"
    
    # Crear usuario
    $securePass = ConvertTo-SecureString $password -AsPlainText -Force
    New-LocalUser -Name $nombreUsuario `
                  -Password $securePass `
                  -FullName "Usuario $tipoUsuario" `
                  -Description "Usuario de sistema $tipoUsuario - PC: $nombrePC" `
                  -PasswordNeverExpires `
                  -UserMayNotChangePassword `
                  -ErrorAction Stop | Out-Null
    
    # Agregar a grupo Users
    Add-LocalGroupMember -Group "Users" -Member $nombreUsuario -ErrorAction Stop
    
    Write-ScriptLog "Usuario $nombreUsuario creado exitosamente en PC: $nombrePC"
    
    return @{
        Success = $true
        Message = "Usuario $nombreUsuario creado exitosamente. Password: $password"
    }
    
} catch {
    Write-ScriptLog "Error al crear usuario: $_"
    return @{
        Success = $false
        Message = "Error: $_"
    }
}
