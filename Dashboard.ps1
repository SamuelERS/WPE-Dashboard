# ============================================
# DASHBOARD PARADISE-SYSTEMLABS
# ============================================

# Detectar la ubicacion del script automaticamente (PORTABLE)
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host "Ubicacion del dashboard: $ScriptRoot" -ForegroundColor Cyan

# Importar modulo si no esta cargado
if (-not (Get-Module -Name UniversalDashboard.Community)) {
    Write-Host "Cargando modulo UniversalDashboard..." -ForegroundColor Cyan
    Import-Module UniversalDashboard.Community -ErrorAction Stop
}

# Crear carpeta de Logs si no existe (relativa a la ubicacion del script)
$LogsPath = Join-Path $ScriptRoot "Logs"
if (-not (Test-Path $LogsPath)) {
    Write-Host "Creando carpeta de logs..." -ForegroundColor Yellow
    New-Item -Path $LogsPath -ItemType Directory -Force | Out-Null
}

# Detener dashboards existentes para evitar conflictos de puerto
Write-Host "Verificando dashboards activos..." -ForegroundColor Cyan

# Primero intentar detener via Get-UDDashboard
try {
    $existingDashboards = Get-UDDashboard -ErrorAction SilentlyContinue
    if ($existingDashboards) {
        Write-Host "Deteniendo dashboards existentes..." -ForegroundColor Yellow
        Get-UDDashboard | Stop-UDDashboard
        Start-Sleep -Seconds 2
        Write-Host "Dashboards detenidos correctamente" -ForegroundColor Green
    }
} catch {
    Write-Host "No se detectaron dashboards via comando" -ForegroundColor Gray
}

# Verificar si el puerto 10000 sigue ocupado y liberarlo
Write-Host "Verificando puerto 10000..." -ForegroundColor Cyan

# Obtener PID del proceso actual para no matarnos a nosotros mismos
$currentPID = $PID

# Intentar detener dashboards existentes via UniversalDashboard primero
try {
    $runningDashboards = Get-UDDashboard -ErrorAction SilentlyContinue | Where-Object { $_.Port -eq 10000 }
    if ($runningDashboards) {
        Write-Host "Deteniendo dashboards en puerto 10000..." -ForegroundColor Yellow
        $runningDashboards | Stop-UDDashboard -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 3
    }
} catch {
    # Silenciosamente continuar si no hay dashboards
}

# Verificar estado del puerto
$portCheck = Get-NetTCPConnection -LocalPort 10000 -ErrorAction SilentlyContinue

if (-not $portCheck) {
    Write-Host "Puerto 10000 disponible" -ForegroundColor Green
} else {
    # Separar conexiones por estado
    $activeConnections = $portCheck | Where-Object {
        $_.State -eq 'Listen' -or $_.State -eq 'Established'
    }
    $timeWaitConnections = $portCheck | Where-Object { $_.State -eq 'TimeWait' }

    # Solo procesar si hay conexiones activas
    if ($activeConnections) {
        Write-Host "Puerto 10000 ocupado. Liberando..." -ForegroundColor Yellow

        # Obtener PIDs unicos, excluyendo el proceso actual
        $processIds = $activeConnections |
            Select-Object -ExpandProperty OwningProcess -Unique |
            Where-Object { $_ -gt 0 -and $_ -ne $currentPID }

        if ($processIds) {
            foreach ($processId in $processIds) {
                try {
                    $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
                    if ($process) {
                        Write-Host "  Deteniendo: $($process.ProcessName) (PID: $processId)" -ForegroundColor Gray
                        Stop-Process -Id $processId -Force -ErrorAction Stop
                    }
                } catch {
                    Write-Host "  Advertencia: No se pudo detener PID $processId" -ForegroundColor DarkYellow
                }
            }

            # Esperar a que Windows libere el puerto (mas tiempo)
            Write-Host "Esperando liberacion del puerto (10 segundos)..." -ForegroundColor Gray
            Start-Sleep -Seconds 10

            # Verificar nuevamente
            $recheckPort = Get-NetTCPConnection -LocalPort 10000 -ErrorAction SilentlyContinue
            $recheckActive = $recheckPort | Where-Object {
                $_.State -eq 'Listen' -or $_.State -eq 'Established'
            }

            if ($recheckActive) {
                Write-Host "ADVERTENCIA: El puerto 10000 sigue ocupado" -ForegroundColor Red
                Write-Host "" -ForegroundColor Yellow
                Write-Host "Opciones para resolver:" -ForegroundColor Yellow
                Write-Host "1. Ejecuta: .\Tools\Detener-Dashboard.ps1" -ForegroundColor White
                Write-Host "2. Cierra todas las ventanas de PowerShell" -ForegroundColor White
                Write-Host "3. Reinicia el equipo" -ForegroundColor White
                Write-Host "" -ForegroundColor Yellow
                pause
                exit 1
            } else {
                Write-Host "Puerto 10000 liberado exitosamente" -ForegroundColor Green
            }
        } else {
            Write-Host "Puerto ocupado pero no se encontraron procesos para detener" -ForegroundColor Yellow
            Write-Host "Intentando iniciar de todas formas..." -ForegroundColor Cyan
        }
    } elseif ($timeWaitConnections) {
        # Solo conexiones TimeWait - pueden coexistir con el nuevo dashboard
        $timeWaitCount = ($timeWaitConnections | Measure-Object).Count
        Write-Host "Puerto 10000 tiene $timeWaitCount conexiones TimeWait (residuales)" -ForegroundColor Cyan
        Write-Host "Esto es normal, iniciando dashboard..." -ForegroundColor Green
    } else {
        Write-Host "Puerto 10000 disponible" -ForegroundColor Green
    }
}

# Funcion de logging (PORTABLE - usa ubicacion relativa)
function Write-DashboardLog {
    param([string]$Accion, [string]$Resultado)
    $LogFile = Join-Path $ScriptRoot "Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    try {
        Add-Content -Path $LogFile -Value "[$Timestamp] $Accion - $Resultado" -ErrorAction SilentlyContinue
    } catch {
        Write-Host "Error al escribir log: $_" -ForegroundColor Red
    }
}

# Variables de Diseno
$Colors = @{Primary = "#2196F3"; Success = "#4caf50"; Warning = "#ff9800"; Danger = "#dc3545"}
$Spacing = @{M = "12px"; L = "16px"}

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  DASHBOARD INICIANDO" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "PC ACTUAL: $env:COMPUTERNAME" -ForegroundColor Yellow
Write-Host "IMPORTANTE: Los usuarios se crearan en este PC" -ForegroundColor Yellow
Write-Host "URL Local: http://localhost:10000" -ForegroundColor Cyan
try {
    $ipAddress = (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop | Where-Object {$_.IPAddress -notlike '169.*' -and $_.IPAddress -notlike '127.*'} | Select-Object -First 1).IPAddress
    if ($ipAddress) {
        Write-Host "URL Red:   http://$ipAddress:10000" -ForegroundColor Cyan
    }
} catch {
    Write-Host "URL Red:   (No disponible)" -ForegroundColor Gray
}
Write-Host "============================================`n" -ForegroundColor Cyan
$Dashboard = New-UDDashboard -Title "Paradise-SystemLabs" -Content {
New-UDElement -Tag 'div' -Attributes @{style=@{'max-width'='1400px';'margin'='0 auto';'padding'='20px'}} -Content {
New-UDHeading -Text "Paradise-SystemLabs" -Size 2
New-UDElement -Tag 'hr'

# Tarjeta informativa sobre PC actual
New-UDCard -Title "INFORMACION DEL SISTEMA" -Content {
    New-UDElement -Tag 'div' -Attributes @{style=@{'padding'='10px';'background-color'='#fff3cd';'border'='2px solid #ffc107';'border-radius'='5px';'margin-bottom'='10px'}} -Content {
        New-UDHeading -Text "PC ACTUAL: $env:COMPUTERNAME" -Size 5
        New-UDElement -Tag 'p' -Content {"IMPORTANTE: Todos los scripts se ejecutan en esta maquina"}
        New-UDElement -Tag 'p' -Content {"Los usuarios se crearan en: $env:COMPUTERNAME"}
        New-UDElement -Tag 'p' -Content {"Si necesitas configurar otra PC, ejecuta el dashboard EN esa maquina"}
    }
}

New-UDElement -Tag 'hr' -Attributes @{style=@{'margin'='24px 0'}}
New-UDLayout -Columns 2 -Content {
New-UDCard -Title "CONFIGURACION INICIAL" -Content {
New-UDElement -Tag 'div' -Attributes @{style=@{'display'='flex';'flex-direction'='column';'gap'='12px';'padding'='16px'}} -Content {
# BOTON 1: Cambiar Nombre PC
New-UDButton -Text "Cambiar Nombre del PC" -OnClick {
Show-UDModal -Content {
New-UDInput -Title "Cambiar Nombre del PC" -Content {
New-UDInputField -Name "nombreActualDisplay" -Placeholder $env:COMPUTERNAME -Type textbox -DefaultValue $env:COMPUTERNAME -Disabled
New-UDInputField -Name "nuevoNombrePC" -Placeholder "Ejemplo: POS-Merliot, DISENO-Principal" -Type textbox
} -Endpoint {
param($nombreActualDisplay, $nuevoNombrePC)
if([string]::IsNullOrWhiteSpace($nuevoNombrePC)){
Show-UDToast -Message "Debes ingresar un nuevo nombre para el PC" -Duration 3000 -BackgroundColor "#f44336"
return
}
try{
# Verificar permisos de administrador
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if(-not $isAdmin){
Show-UDToast -Message "Error: El dashboard debe ejecutarse como Administrador" -Duration 8000 -BackgroundColor "#f44336"
return
}

# Validar formato del nombre (reglas de Windows)
# - 1 a 15 caracteres
# - Solo letras, numeros y guiones
# - NO puede empezar con guion o numero
# - NO puede terminar con guion
if($nuevoNombrePC.Length -lt 1 -or $nuevoNombrePC.Length -gt 15){
Show-UDToast -Message "Nombre invalido. Debe tener entre 1 y 15 caracteres" -Duration 8000 -BackgroundColor "#f44336"
return
}
if($nuevoNombrePC -notmatch '^[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9]$' -and $nuevoNombrePC -notmatch '^[a-zA-Z]$'){
Show-UDToast -Message "Nombre invalido. Debe empezar con letra, terminar con letra/numero, y solo contener letras, numeros y guiones" -Duration 8000 -BackgroundColor "#f44336"
return
}

# Verificar si el nombre es diferente
$nombreActual = $env:COMPUTERNAME
if($nuevoNombrePC -eq $nombreActual){
Show-UDToast -Message "El nuevo nombre es igual al actual. No hay cambios que realizar." -Duration 5000 -BackgroundColor "#ff9800"
return
}

Show-UDToast -Message "Cambiando nombre del PC de '$nombreActual' a '$nuevoNombrePC'..." -Duration 3000

# Cambiar el nombre del PC
Rename-Computer -NewName $nuevoNombrePC -Force -ErrorAction Stop

Write-DashboardLog -Accion "Cambiar Nombre PC" -Resultado "Exitoso: $nombreActual -> $nuevoNombrePC"
Show-UDToast -Message "Nombre del PC cambiado exitosamente a '$nuevoNombrePC'. IMPORTANTE: Debes REINICIAR el equipo para aplicar los cambios." -Duration 15000 -BackgroundColor "#4caf50"
Hide-UDModal
}catch{
Write-DashboardLog -Accion "Cambiar Nombre PC" -Resultado "Error: $_"
Show-UDToast -Message "Error al cambiar nombre del PC: $_" -Duration 8000 -BackgroundColor "#f44336"
}
}
}
}
# BOTON 2: Reiniciar PC (Boton rojo de advertencia)
New-UDButton -Text "REINICIAR PC" -OnClick {
Show-UDToast -Message "Reiniciando el equipo en 10 segundos..." -Duration 10000 -BackgroundColor "#ff9800"
Write-DashboardLog -Accion "Reiniciar PC" -Resultado "Solicitado"
Start-Sleep -Seconds 3
Restart-Computer -Force
} -Style @{'background-color'='#dc3545';'color'='white'}
# BOTON 3: Crear Usuario del Sistema
New-UDButton -Text "Crear Usuario del Sistema" -OnClick {
Show-UDModal -Content {
New-UDInput -Title "Crear Usuario del Sistema" -Content {
New-UDInputField -Name "nombreUsuario" -Placeholder "Ejemplo: POS-Merliot" -Type textbox
New-UDInputField -Name "password" -Placeholder "Password (defecto: 841357)" -Type textbox
New-UDInputField -Name "tipoUsuario" -Placeholder "Selecciona tipo" -Type select -Values @("POS", "Admin", "Diseno", "Cliente", "Mantenimiento")
} -Endpoint {
param($nombreUsuario, $password, $tipoUsuario)
if([string]::IsNullOrWhiteSpace($nombreUsuario)){
Show-UDToast -Message "Debes ingresar un nombre de usuario" -Duration 3000 -BackgroundColor "#f44336"
return
}
if([string]::IsNullOrWhiteSpace($password)){$password = "841357"}
if([string]::IsNullOrWhiteSpace($tipoUsuario)){$tipoUsuario = "POS"}
try{
# Verificar permisos de administrador
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if(-not $isAdmin){
Show-UDToast -Message "Error: El dashboard debe ejecutarse como Administrador" -Duration 8000 -BackgroundColor "#f44336"
return
}

# Verificar si el usuario ya existe
$usuarioExiste = Get-LocalUser -Name $nombreUsuario -ErrorAction SilentlyContinue
if($usuarioExiste){
Show-UDToast -Message "Error: El usuario $nombreUsuario ya existe. Usa otro nombre o elimina el usuario existente." -Duration 8000 -BackgroundColor "#ff9800"
Write-DashboardLog -Accion "Crear Usuario ($nombreUsuario)" -Resultado "Error: Usuario ya existe"
return
}

Show-UDToast -Message "Creando usuario $nombreUsuario usando metodo compatible..." -Duration 2000

# SOLUCION: Usar comandos NET USER (legacy) en lugar de New-LocalUser
# Estos comandos son MAS compatibles con la pantalla de login de Windows

# PASO 1: Crear usuario con NET USER
# CRITICO: fullname debe ser el NOMBRE DEL USUARIO para que aparezca correctamente en login
$resultNet = & net user "$nombreUsuario" "$password" /add /fullname:"$nombreUsuario" /comment:"Tipo: $tipoUsuario - PC: $env:COMPUTERNAME" /passwordchg:no /active:yes 2>&1

if($LASTEXITCODE -ne 0){
throw "Error al crear usuario: $resultNet"
}

# PASO 2: Configurar que el password no expire
# Metodo compatible con Windows 10/11 (sin wmic)
Start-Sleep -Milliseconds 500
Set-LocalUser -Name $nombreUsuario -PasswordNeverExpires $true -ErrorAction SilentlyContinue

# PASO 3: Agregar al grupo Users
Start-Sleep -Milliseconds 500
& net localgroup Users "$nombreUsuario" /add 2>&1 | Out-Null

# PASO 4: Asegurar que NO este en la lista de usuarios ocultos del registro
try {
$registroSpecialAccounts = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
if(Test-Path $registroSpecialAccounts){
# Eliminar la entrada si existe (para que sea visible)
Remove-ItemProperty -Path $registroSpecialAccounts -Name $nombreUsuario -ErrorAction SilentlyContinue
}
} catch {}

# PASO 5: Forzar actualizacion del sistema de usuarios
Start-Sleep -Milliseconds 500
gpupdate /force 2>&1 | Out-Null

Write-DashboardLog -Accion "Crear Usuario ($nombreUsuario)" -Resultado "Exitoso - PC: $env:COMPUTERNAME - Usuario configurado para login"
Show-UDToast -Message "Usuario $nombreUsuario creado exitosamente. Password: $password. IMPORTANTE: Cierra sesion o reinicia para ver el usuario en la pantalla de login." -Duration 12000 -BackgroundColor "#4caf50"
Start-Sleep -Seconds 2
Hide-UDModal
}catch{
Write-DashboardLog -Accion "Crear Usuario ($nombreUsuario)" -Resultado "Error: $_"
Show-UDToast -Message "Error al crear usuario: $_" -Duration 8000 -BackgroundColor "#f44336"
}
}
}
}
# BOTON 4: Ver Usuarios Actuales
New-UDButton -Text "Ver Usuarios Actuales" -OnClick {
try {
# Obtener todos los usuarios locales del sistema con informacion extendida
$usuarios = Get-LocalUser | Sort-Object Name

if ($usuarios) {
$totalUsuarios = ($usuarios | Measure-Object).Count
$usuariosActivos = ($usuarios | Where-Object {$_.Enabled} | Measure-Object).Count

# Crear texto formateado con DIAGNOSTICO COMPLETO
$usuariosTexto = "DIAGNOSTICO COMPLETO DE USUARIOS`n"
$usuariosTexto += "================================`n`n"

foreach ($user in $usuarios) {
$estado = if($user.Enabled){"[ACTIVO]"}else{"[INACTIVO]"}
$lastLogon = if($user.LastLogon){$user.LastLogon.ToString("dd/MM/yyyy HH:mm")}else{"Nunca"}
$descripcion = if($user.Description){$user.Description}else{"Sin descripcion"}
$usuariosTexto += "Usuario: $($user.Name) $estado`n"
$usuariosTexto += "Descripcion: $descripcion`n"
$usuariosTexto += "Ultimo acceso: $lastLogon`n"
$usuariosTexto += "Password expira: $($user.PasswordExpires)`n"
$usuariosTexto += "Cuenta expira: $($user.AccountExpires)`n"
$usuariosTexto += "SID: $($user.SID)`n"

# Verificar si tiene carpeta de perfil
$perfilPath = "C:\Users\$($user.Name)"
$tienePerfil = Test-Path $perfilPath
$usuariosTexto += "Carpeta perfil existe: $tienePerfil ($perfilPath)`n"

# Verificar grupos del usuario
try {
$grupos = Get-LocalGroup | Where-Object {
(Get-LocalGroupMember -Group $_.Name -ErrorAction SilentlyContinue).Name -contains "$env:COMPUTERNAME\$($user.Name)"
}
$gruposNombres = ($grupos | Select-Object -ExpandProperty Name) -join ", "
if($gruposNombres){
$usuariosTexto += "Grupos: $gruposNombres`n"
}else{
$usuariosTexto += "Grupos: NINGUNO (PROBLEMA!)`n"
}
} catch {
$usuariosTexto += "Grupos: Error al obtener`n"
}

$usuariosTexto += "----------------------------------------`n`n"
}

Show-UDModal -Content {
New-UDHeading -Text "Usuarios en: $env:COMPUTERNAME" -Size 4
New-UDElement -Tag 'p' -Content {"Total de usuarios: $totalUsuarios | Activos: $usuariosActivos"}
New-UDElement -Tag 'pre' -Attributes @{style=@{'background-color'='#f5f5f5';'padding'='15px';'border-radius'='5px';'font-family'='Consolas, monospace';'font-size'='12px';'overflow-x'='auto';'white-space'='pre-wrap';'max-height'='600px'}} -Content {$usuariosTexto}
} -Header {New-UDHeading -Text "Usuarios del Sistema - DIAGNOSTICO" -Size 5}

Write-DashboardLog -Accion "Ver Usuarios" -Resultado "Exitoso - PC: $env:COMPUTERNAME - Total: $totalUsuarios"
} else {
Show-UDToast -Message "No se encontraron usuarios en el sistema" -Duration 3000 -BackgroundColor "#ff9800"
}
} catch {
Write-DashboardLog -Accion "Ver Usuarios" -Resultado "Error: $_"
Show-UDToast -Message "Error al obtener usuarios: $_" -Duration 5000 -BackgroundColor "#f44336"
}
}
# BOTON 5: Reparar Usuarios Existentes
New-UDButton -Text "Reparar Usuarios Existentes" -OnClick {
try {
Show-UDToast -Message "Reparando configuracion de usuarios... Esto puede tomar varios segundos." -Duration 5000

# Obtener todos los usuarios que NO son del sistema
$todosUsuarios = Get-LocalUser | Where-Object {
$_.Name -notlike "Administrador*" -and
$_.Name -notlike "DefaultAccount" -and
$_.Name -notlike "Invitado" -and
$_.Name -notlike "WDAGUtilityAccount" -and
$_.Name -notlike "Guest" -and
$_.Name -notlike "Administrator" -and
$_.Enabled -eq $true
}

$reparados = 0
$errores = 0

foreach ($usuario in $todosUsuarios) {
try {
$nombreUsuario = $usuario.Name

# REPARACION PASO 1: Corregir fullname para que aparezca el nombre correcto en login
& net user "$nombreUsuario" /fullname:"$nombreUsuario" 2>&1 | Out-Null

# REPARACION PASO 2: Habilitar usuario
& net user "$nombreUsuario" /active:yes 2>&1 | Out-Null

# REPARACION PASO 3: Password no expira (metodo compatible)
Start-Sleep -Milliseconds 300
Set-LocalUser -Name $nombreUsuario -PasswordNeverExpires $true -ErrorAction SilentlyContinue

# REPARACION PASO 3: Asegurar que este en grupo Users
Start-Sleep -Milliseconds 300
& net localgroup Users "$nombreUsuario" /add 2>&1 | Out-Null

# REPARACION PASO 4: Eliminar del registro de usuarios ocultos
try {
$registroSpecialAccounts = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
if(Test-Path $registroSpecialAccounts){
Remove-ItemProperty -Path $registroSpecialAccounts -Name $nombreUsuario -ErrorAction SilentlyContinue
}
} catch {}

$reparados++
} catch {
$errores++
}
}

# Forzar actualizacion de politicas
Start-Sleep -Seconds 1
gpupdate /force 2>&1 | Out-Null

Write-DashboardLog -Accion "Reparar Usuarios" -Resultado "Reparados: $reparados, Errores: $errores - PC: $env:COMPUTERNAME"
Show-UDToast -Message "Reparacion completada: $reparados usuarios configurados, $errores errores. CRITICO: Debes CERRAR SESION (no reiniciar) para que los usuarios aparezcan en la pantalla de login." -Duration 15000 -BackgroundColor "#4caf50"
} catch {
Write-DashboardLog -Accion "Reparar Usuarios" -Resultado "Error: $_"
Show-UDToast -Message "Error al reparar usuarios: $_" -Duration 8000 -BackgroundColor "#f44336"
}
}
# BOTON 6: Eliminar Usuarios (MOVIDO del closure de Reparar Usuarios)
New-UDButton -Text "Eliminar Usuarios" -OnClick {
Show-UDModal -Content {
New-UDInput -Title "Eliminar Usuario del Sistema" -Content {
New-UDInputField -Name "nombreUsuarioEliminar" -Placeholder "Nombre exacto del usuario a eliminar" -Type textbox
} -Endpoint {
param($nombreUsuarioEliminar)

if([string]::IsNullOrWhiteSpace($nombreUsuarioEliminar)){
Show-UDToast -Message "Debes ingresar el nombre del usuario a eliminar" -Duration 3000 -BackgroundColor "#f44336"
return
}

# Proteger usuarios criticos del sistema
$usuariosProtegidos = @("Administrator", "Administrador", "DefaultAccount", "Guest", "Invitado", "WDAGUtilityAccount", "Paradise-SystemLabs", "Test7-POS")

if($usuariosProtegidos -contains $nombreUsuarioEliminar){
Show-UDToast -Message "Error: No se puede eliminar el usuario $nombreUsuarioEliminar (usuario protegido)" -Duration 8000 -BackgroundColor "#f44336"
return
}

try {
# Verificar si el usuario existe
$usuarioExiste = Get-LocalUser -Name $nombreUsuarioEliminar -ErrorAction SilentlyContinue
if(-not $usuarioExiste){
Show-UDToast -Message "Error: El usuario $nombreUsuarioEliminar no existe" -Duration 5000 -BackgroundColor "#ff9800"
return
}

Show-UDToast -Message "Eliminando usuario $nombreUsuarioEliminar..." -Duration 3000

# Eliminar usuario usando Remove-LocalUser
Remove-LocalUser -Name $nombreUsuarioEliminar -ErrorAction Stop

# Eliminar carpeta de perfil si existe
$perfilPath = "C:\Users\$nombreUsuarioEliminar"
if(Test-Path $perfilPath){
Start-Sleep -Seconds 1
Remove-Item -Path $perfilPath -Recurse -Force -ErrorAction SilentlyContinue
}

# Limpiar del registro de usuarios ocultos
try {
$registroSpecialAccounts = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
if(Test-Path $registroSpecialAccounts){
Remove-ItemProperty -Path $registroSpecialAccounts -Name $nombreUsuarioEliminar -ErrorAction SilentlyContinue
}
} catch {}

Write-DashboardLog -Accion "Eliminar Usuario ($nombreUsuarioEliminar)" -Resultado "Exitoso - PC: $env:COMPUTERNAME"
Show-UDToast -Message "Usuario $nombreUsuarioEliminar eliminado exitosamente" -Duration 8000 -BackgroundColor "#4caf50"
Start-Sleep -Seconds 2
Hide-UDModal
} catch {
Write-DashboardLog -Accion "Eliminar Usuario ($nombreUsuarioEliminar)" -Resultado "Error: $_"
Show-UDToast -Message "Error al eliminar usuario: $_" -Duration 8000 -BackgroundColor "#f44336"
}
}
}
}
# BOTON 7: Diagnostico Pantalla Login
New-UDButton -Text "Diagnostico Pantalla Login" -OnClick {
try {
Show-UDToast -Message "Analizando configuracion de pantalla de login..." -Duration 3000

$diagnostico = "DIAGNOSTICO DE PANTALLA DE LOGIN`n"
$diagnostico += "==================================`n`n"

# 1. Verificar usuarios locales
$usuariosLocales = Get-LocalUser | Where-Object {$_.Enabled -eq $true}
$diagnostico += "USUARIOS LOCALES ACTIVOS:`n"
foreach ($u in $usuariosLocales) {
$diagnostico += "  - $($u.Name)`n"
}
$diagnostico += "`n"

# 2. Verificar registro SpecialAccounts (usuarios ocultos)
$diagnostico += "REGISTRO DE USUARIOS OCULTOS:`n"
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
if(Test-Path $regPath){
$hiddenUsers = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue
if($hiddenUsers){
$hiddenUsers.PSObject.Properties | Where-Object {$_.Name -notlike "PS*"} | ForEach-Object {
$valor = if($_.Value -eq 0){"OCULTO"}else{"VISIBLE"}
$diagnostico += "  - $($_.Name): $valor`n"
}
} else {
$diagnostico += "  (No hay usuarios configurados como ocultos)`n"
}
} else {
$diagnostico += "  (Clave de registro no existe - todos los usuarios deberian ser visibles)`n"
}
$diagnostico += "`n"

# 3. Verificar configuracion de inicio de sesion automatico
$diagnostico += "CONFIGURACION DE INICIO DE SESION:`n"
$winlogonPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$autoAdminLogon = (Get-ItemProperty -Path $winlogonPath -Name "AutoAdminLogon" -ErrorAction SilentlyContinue).AutoAdminLogon
$defaultUser = (Get-ItemProperty -Path $winlogonPath -Name "DefaultUserName" -ErrorAction SilentlyContinue).DefaultUserName
$diagnostico += "  Inicio automatico: $autoAdminLogon`n"
$diagnostico += "  Usuario por defecto: $defaultUser`n`n"

# 4. Verificar si esta en dominio
$diagnostico += "CONFIGURACION DE DOMINIO/WORKGROUP:`n"
$computerSystem = Get-WmiObject -Class Win32_ComputerSystem
$diagnostico += "  Nombre: $($computerSystem.Name)`n"
$diagnostico += "  Dominio/Workgroup: $($computerSystem.Domain)`n"
$diagnostico += "  Parte de dominio: $($computerSystem.PartOfDomain)`n`n"

# 5. Verificar politicas de grupo
$diagnostico += "POLITICAS DE VISUALIZACION DE USUARIOS:`n"
$regPolicies = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
if(Test-Path $regPolicies){
$dontDisplayLastUserName = (Get-ItemProperty -Path $regPolicies -Name "dontdisplaylastusername" -ErrorAction SilentlyContinue).dontdisplaylastusername
$diagnostico += "  No mostrar ultimo usuario: $dontDisplayLastUserName`n"
} else {
$diagnostico += "  (Sin politicas especiales)`n"
}
$diagnostico += "`n"

# 6. Contar usuarios por tipo
$totalUsuarios = ($usuariosLocales | Measure-Object).Count
$usuariosConPerfil = 0
foreach ($u in $usuariosLocales) {
if(Test-Path "C:\Users\$($u.Name)"){
$usuariosConPerfil++
}
}
$diagnostico += "RESUMEN:`n"
$diagnostico += "  Total usuarios locales activos: $totalUsuarios`n"
$diagnostico += "  Usuarios con carpeta de perfil: $usuariosConPerfil`n"
$diagnostico += "`n"

$diagnostico += "RECOMENDACION:`n"
$diagnostico += "Si los usuarios no aparecen en pantalla de login:`n"
$diagnostico += "1. Verifica que NO esten en la lista de ocultos arriba`n"
$diagnostico += "2. CIERRA SESION (no reinicies) y verifica`n"
$diagnostico += "3. Si PC esta en dominio, puede que solo muestre usuarios de dominio`n"

Show-UDModal -Content {
New-UDHeading -Text "Diagnostico de Pantalla de Login" -Size 4
New-UDElement -Tag 'pre' -Attributes @{style=@{'background-color'='#f5f5f5';'padding'='15px';'border-radius'='5px';'font-family'='Consolas, monospace';'font-size'='12px';'overflow-x'='auto';'white-space'='pre-wrap';'max-height'='600px'}} -Content {$diagnostico}
} -Header {New-UDHeading -Text "Diagnostico Completo" -Size 5}

Write-DashboardLog -Accion "Diagnostico Login" -Resultado "Completado"
} catch {
Show-UDToast -Message "Error en diagnostico: $_" -Duration 5000 -BackgroundColor "#f44336"
}
}
# BOTON 8: Configurar Biometria
New-UDButton -Text "Configurar Biometria" -OnClick {Show-UDToast -Message "Configurando biometria..." -Duration 2000;Write-DashboardLog -Accion "Config Biometria" -Resultado "Iniciado"}
# BOTON 9: Instalar Software Base
New-UDButton -Text "Instalar Software Base" -OnClick {Show-UDToast -Message "Instalando software..." -Duration 2000;Write-DashboardLog -Accion "Software Base" -Resultado "Iniciado"}
# BOTON 10: Configurar Email Corporativo
New-UDButton -Text "Configurar Email Corporativo" -OnClick {Show-UDToast -Message "Configurando email..." -Duration 2000;Write-DashboardLog -Accion "Email Corp" -Resultado "Iniciado"}
}
}
New-UDCard -Title "MANTENIMIENTO GENERAL" -Content {
New-UDElement -Tag 'div' -Attributes @{style=@{'display'='flex';'flex-direction'='column';'gap'='12px';'padding'='16px'}} -Content {
New-UDButton -Text "Windows Update" -OnClick {Show-UDToast -Message "Verificando actualizaciones..." -Duration 2000;Write-DashboardLog -Accion "Windows Update" -Resultado "Iniciado"}
New-UDButton -Text "Limpieza de Disco" -OnClick {Show-UDToast -Message "Limpiando disco..." -Duration 2000;Write-DashboardLog -Accion "Limpieza Disco" -Resultado "Iniciado"}
New-UDButton -Text "Verificar Sistema" -Style @{'background-color'='#4caf50';'color'='white'} -OnClick {Show-UDToast -Message "Verificando..." -Duration 2000;Write-DashboardLog -Accion "Verificar Sistema" -Resultado "Iniciado"}
New-UDButton -Text "Optimizar Rendimiento" -OnClick {Show-UDToast -Message "Optimizando..." -Duration 2000;Write-DashboardLog -Accion "Optimizar" -Resultado "Iniciado"} -Style @{'background-color'='#4caf50';'color'='white'}
}
}
}
New-UDElement -Tag 'div' -Attributes @{style=@{'margin-top'='24px'}} -Content {
New-UDLayout -Columns 3 -Content {
New-UDCard -Title "PUNTO DE VENTA" -Content {
New-UDElement -Tag 'div' -Attributes @{style=@{'display'='flex';'flex-direction'='column';'gap'='10px';'padding'='16px'}} -Content {
New-UDButton -Text "Reset Terminal" -OnClick {Show-UDToast -Message "Reseteando..." -Duration 2000;Write-DashboardLog -Accion "Reset Terminal" -Resultado "Iniciado"}
New-UDButton -Text "Sincronizar Inventario" -OnClick {Show-UDToast -Message "Sincronizando..." -Duration 2000;Write-DashboardLog -Accion "Sync Inventario" -Resultado "Iniciado"}
New-UDButton -Text "Config Impresora Fiscal" -OnClick {Show-UDToast -Message "Configurando..." -Duration 2000;Write-DashboardLog -Accion "Impresora Fiscal" -Resultado "Iniciado"}
}
}
New-UDCard -Title "DISENO GRAFICO" -Content {
New-UDElement -Tag 'div' -Attributes @{style=@{'display'='flex';'flex-direction'='column';'gap'='10px';'padding'='16px'}} -Content {
New-UDButton -Text "Setup Adobe Suite" -OnClick {Show-UDToast -Message "Instalando Adobe..." -Duration 2000;Write-DashboardLog -Accion "Adobe" -Resultado "Iniciado"}
New-UDButton -Text "Calibrar Monitor" -OnClick {Show-UDToast -Message "Calibrando..." -Duration 2000;Write-DashboardLog -Accion "Calibrar Monitor" -Resultado "Iniciado"}
New-UDButton -Text "Drivers Impresora" -OnClick {Show-UDToast -Message "Instalando..." -Duration 2000;Write-DashboardLog -Accion "Drivers" -Resultado "Iniciado"}
}
}
New-UDCard -Title "ATENCION AL CLIENTE" -Content {
New-UDElement -Tag 'div' -Attributes @{style=@{'display'='flex';'flex-direction'='column';'gap'='10px';'padding'='16px'}} -Content {
New-UDButton -Text "Setup CRM" -OnClick {Show-UDToast -Message "Configurando CRM..." -Duration 2000;Write-DashboardLog -Accion "CRM" -Resultado "Iniciado"}
New-UDButton -Text "Config Estacion" -OnClick {Show-UDToast -Message "Configurando..." -Duration 2000;Write-DashboardLog -Accion "Estacion" -Resultado "Iniciado"}
New-UDButton -Text "Config Softphone" -OnClick {Show-UDToast -Message "Configurando..." -Duration 2000;Write-DashboardLog -Accion "Softphone" -Resultado "Iniciado"}
}
}
}
}
New-UDElement -Tag 'hr' -Attributes @{style=@{'margin'='24px 0'}}
New-UDCard -Title "ACCIONES CRITICAS" -Content {
New-UDElement -Tag 'div' -Attributes @{style=@{'padding'='16px';'background-color'='#ffe6e6';'border'='2px solid #dc3545';'border-radius'='5px'}} -Content {
New-UDElement -Tag 'p' -Content {"ADVERTENCIA: Estas acciones afectaran el sistema inmediatamente"}
New-UDElement -Tag 'div' -Attributes @{style=@{'margin-top'='12px';'display'='flex';'gap'='12px';'flex-wrap'='wrap'}} -Content {
New-UDButton -Text "REINICIAR PC" -OnClick {Show-UDToast -Message "Reiniciando el equipo en 10 segundos..." -Duration 10000 -BackgroundColor "#ff9800";Write-DashboardLog -Accion "Reiniciar PC" -Resultado "Solicitado";Start-Sleep -Seconds 3;Restart-Computer -Force} -Style @{'background-color'='#dc3545';'color'='white';'font-weight'='bold'}
New-UDButton -Text "Reiniciar Dashboard" -OnClick {Show-UDToast -Message "Reiniciando dashboard..." -Duration 3000 -BackgroundColor "#ff9800";Write-DashboardLog -Accion "Reiniciar Dashboard" -Resultado "Solicitado";try{Get-UDDashboard | Stop-UDDashboard;Start-Sleep -Seconds 2;Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -NoExit -File `"$ScriptRoot\Dashboard.ps1`"" -Verb RunAs;exit}catch{Show-UDToast -Message "Error al reiniciar: $_" -Duration 5000 -BackgroundColor "#f44336"}} -Style @{'background-color'='#ff9800';'color'='white'}
}
}}
New-UDElement -Tag 'hr'
New-UDElement -Tag 'p' -Attributes @{style=@{'text-align'='center';'color'='#666'}} -Content {"Paradise-SystemLabs Dashboard v2.0 | " + (Get-Date -Format 'dd/MM/yyyy HH:mm')}
}
}
Start-UDDashboard -Dashboard $Dashboard -Port 10000 -AutoReload
