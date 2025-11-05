# ============================================
# DASHBOARD ACUARIOS PARADISE
# ============================================

# Importar modulo si no esta cargado
if (-not (Get-Module -Name UniversalDashboard.Community)) {
    Write-Host "Cargando modulo UniversalDashboard..." -ForegroundColor Cyan
    Import-Module UniversalDashboard.Community -ErrorAction Stop
}

# Crear carpeta de Logs si no existe
$LogsPath = "C:\WPE-Dashboard\Logs"
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
$maxRetries = 3
$retryCount = 0
$portFree = $false

while (-not $portFree -and $retryCount -lt $maxRetries) {
    try {
        $portConnection = Get-NetTCPConnection -LocalPort 10000 -ErrorAction SilentlyContinue

        if ($portConnection) {
            # Separar conexiones activas de TimeWait
            $activeConnections = $portConnection | Where-Object { $_.State -ne 'TimeWait' -and $_.OwningProcess -gt 0 }
            $timeWaitConnections = $portConnection | Where-Object { $_.State -eq 'TimeWait' -or $_.OwningProcess -eq 0 }

            if ($activeConnections) {
                # Hay procesos activos usando el puerto
                Write-Host "Puerto 10000 ocupado por proceso activo. Intento $($retryCount + 1) de $maxRetries..." -ForegroundColor Yellow
                $processIds = $activeConnections | Select-Object -ExpandProperty OwningProcess -Unique

                foreach ($processId in $processIds) {
                    if ($processId -gt 0) {
                        try {
                            $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
                            if ($process -and $process.ProcessName -ne "Idle") {
                                Write-Host "Deteniendo proceso: $($process.ProcessName) (PID: $processId)" -ForegroundColor Yellow
                                Stop-Process -Id $processId -Force -ErrorAction Stop
                            }
                        } catch {
                            Write-Host "No se pudo detener proceso $processId" -ForegroundColor Red
                        }
                    }
                }

                # Esperar mas tiempo para que el puerto se libere
                Write-Host "Esperando liberacion del puerto..." -ForegroundColor Gray
                Start-Sleep -Seconds 5

            } elseif ($timeWaitConnections) {
                # Solo conexiones TimeWait (PID 0) - se liberan automaticamente
                $timeWaitCount = ($timeWaitConnections | Measure-Object).Count
                Write-Host "Puerto 10000 en estado TimeWait ($timeWaitCount conexiones)" -ForegroundColor Cyan
                Write-Host "Windows liberara el puerto automaticamente. Esperando 30 segundos..." -ForegroundColor Gray
                Start-Sleep -Seconds 30
            }

            # Verificar si el puerto se libero
            $checkPort = Get-NetTCPConnection -LocalPort 10000 -ErrorAction SilentlyContinue
            if (-not $checkPort) {
                $portFree = $true
                Write-Host "Puerto 10000 liberado correctamente" -ForegroundColor Green
            } elseif ($checkPort | Where-Object { $_.State -eq 'TimeWait' -or $_.OwningProcess -eq 0 }) {
                # Si solo quedan TimeWait, considerar el puerto como disponible
                $onlyTimeWait = -not ($checkPort | Where-Object { $_.State -ne 'TimeWait' -and $_.OwningProcess -gt 0 })
                if ($onlyTimeWait) {
                    Write-Host "Puerto 10000 solo tiene conexiones TimeWait residuales. Intentando iniciar dashboard..." -ForegroundColor Cyan
                    $portFree = $true
                }
            }
        } else {
            $portFree = $true
            Write-Host "Puerto 10000 disponible" -ForegroundColor Green
        }
    } catch {
        Write-Host "Error al verificar puerto: $_" -ForegroundColor Red
    }

    $retryCount++
}

if (-not $portFree) {
    Write-Host "ADVERTENCIA: No se pudo liberar el puerto 10000 despues de $maxRetries intentos" -ForegroundColor Red
    Write-Host "Intenta cerrar manualmente todas las ventanas de PowerShell y vuelve a intentar" -ForegroundColor Yellow
    pause
    exit 1
}

# Funcion de logging
function Write-DashboardLog {
    param([string]$Accion, [string]$Resultado)
    $LogFile = "C:\WPE-Dashboard\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    try {
        Add-Content -Path $LogFile -Value "[$Timestamp] $Accion - $Resultado" -ErrorAction SilentlyContinue
    } catch {
        Write-Host "Error al escribir log: $_" -ForegroundColor Red
    }
}

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  DASHBOARD INICIANDO" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "PC ACTUAL: $env:COMPUTERNAME" -ForegroundColor Yellow
Write-Host "IMPORTANTE: Los usuarios se crearan en este PC" -ForegroundColor Yellow
Write-Host "URL Local: http://localhost:10000" -ForegroundColor Cyan
Write-Host "URL Red:   http://$((Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike '169.*' -and $_.IPAddress -notlike '127.*'} | Select-Object -First 1).IPAddress):10000" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan
$Dashboard = New-UDDashboard -Title "Acuarios Paradise IT" -Content {
New-UDHeading -Text "ACUARIOS PARADISE - IT Automation" -Size 2
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

New-UDElement -Tag 'hr'
New-UDLayout -Columns 1 -Content {
New-UDCard -Title "CONFIGURACION INICIAL" -Content {
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

Show-UDToast -Message "Creando usuario $nombreUsuario..." -Duration 2000

# Crear el usuario
$securePass = ConvertTo-SecureString $password -AsPlainText -Force
New-LocalUser -Name $nombreUsuario -Password $securePass -FullName "Usuario $tipoUsuario" -Description "Usuario de sistema $tipoUsuario - PC: $env:COMPUTERNAME" -PasswordNeverExpires -UserMayNotChangePassword -ErrorAction Stop | Out-Null
Add-LocalGroupMember -Group "Users" -Member $nombreUsuario -ErrorAction Stop

Write-DashboardLog -Accion "Crear Usuario ($nombreUsuario)" -Resultado "Exitoso - PC: $env:COMPUTERNAME"
Show-UDToast -Message "Usuario $nombreUsuario creado exitosamente. Password: $password" -Duration 8000 -BackgroundColor "#4caf50"
Start-Sleep -Seconds 2
Hide-UDModal
}catch{
Write-DashboardLog -Accion "Crear Usuario ($nombreUsuario)" -Resultado "Error: $_"
Show-UDToast -Message "Error al crear usuario: $_" -Duration 8000 -BackgroundColor "#f44336"
}
}
}
}
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

# Validar formato del nombre
if($nuevoNombrePC -notmatch '^[a-zA-Z0-9]([a-zA-Z0-9-]{0,13}[a-zA-Z0-9])?$'){
Show-UDToast -Message "Nombre invalido. Usa solo letras, numeros y guiones (1-15 caracteres)" -Duration 8000 -BackgroundColor "#f44336"
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
New-UDButton -Text "Configurar Biometria" -OnClick {Show-UDToast -Message "Configurando biometria..." -Duration 2000;Write-DashboardLog -Accion "Config Biometria" -Resultado "Iniciado"}
New-UDButton -Text "Instalar Software Base" -OnClick {Show-UDToast -Message "Instalando software..." -Duration 2000;Write-DashboardLog -Accion "Software Base" -Resultado "Iniciado"}
New-UDButton -Text "Configurar Email Corporativo" -OnClick {Show-UDToast -Message "Configurando email..." -Duration 2000;Write-DashboardLog -Accion "Email Corp" -Resultado "Iniciado"}
}}
New-UDLayout -Columns 1 -Content {New-UDCard -Title "MANTENIMIENTO GENERAL" -Content {New-UDButton -Text "Windows Update" -OnClick {Show-UDToast -Message "Verificando actualizaciones..." -Duration 2000;Write-DashboardLog -Accion "Windows Update" -Resultado "Iniciado"}; New-UDButton -Text "Limpieza de Disco" -OnClick {Show-UDToast -Message "Limpiando disco..." -Duration 2000;Write-DashboardLog -Accion "Limpieza Disco" -Resultado "Iniciado"}; New-UDButton -Text "Verificar Sistema" -OnClick {Show-UDToast -Message "Verificando..." -Duration 2000;Write-DashboardLog -Accion "Verificar Sistema" -Resultado "Iniciado"}; New-UDButton -Text "Optimizar Rendimiento" -OnClick {Show-UDToast -Message "Optimizando..." -Duration 2000;Write-DashboardLog -Accion "Optimizar" -Resultado "Iniciado"}}}
New-UDLayout -Columns 1 -Content {New-UDCard -Title "PUNTO DE VENTA (POS)" -Content {New-UDButton -Text "Reset Terminal" -OnClick {Show-UDToast -Message "Reseteando..." -Duration 2000;Write-DashboardLog -Accion "Reset Terminal" -Resultado "Iniciado"}; New-UDButton -Text "Sincronizar Inventario" -OnClick {Show-UDToast -Message "Sincronizando..." -Duration 2000;Write-DashboardLog -Accion "Sync Inventario" -Resultado "Iniciado"}; New-UDButton -Text "Config Impresora Fiscal" -OnClick {Show-UDToast -Message "Configurando..." -Duration 2000;Write-DashboardLog -Accion "Impresora Fiscal" -Resultado "Iniciado"}}}
New-UDLayout -Columns 1 -Content {New-UDCard -Title "DISENO GRAFICO" -Content {New-UDButton -Text "Setup Adobe Suite" -OnClick {Show-UDToast -Message "Instalando Adobe..." -Duration 2000;Write-DashboardLog -Accion "Adobe" -Resultado "Iniciado"}; New-UDButton -Text "Calibrar Monitor" -OnClick {Show-UDToast -Message "Calibrando..." -Duration 2000;Write-DashboardLog -Accion "Calibrar Monitor" -Resultado "Iniciado"}; New-UDButton -Text "Drivers Impresora" -OnClick {Show-UDToast -Message "Instalando..." -Duration 2000;Write-DashboardLog -Accion "Drivers" -Resultado "Iniciado"}}}
New-UDLayout -Columns 1 -Content {New-UDCard -Title "ATENCION AL CLIENTE" -Content {New-UDButton -Text "Setup CRM" -OnClick {Show-UDToast -Message "Configurando CRM..." -Duration 2000;Write-DashboardLog -Accion "CRM" -Resultado "Iniciado"}; New-UDButton -Text "Config Estacion" -OnClick {Show-UDToast -Message "Configurando..." -Duration 2000;Write-DashboardLog -Accion "Estacion" -Resultado "Iniciado"}; New-UDButton -Text "Config Softphone" -OnClick {Show-UDToast -Message "Configurando..." -Duration 2000;Write-DashboardLog -Accion "Softphone" -Resultado "Iniciado"}}}
New-UDLayout -Columns 1 -Content {New-UDCard -Title "HISTORIAL Y AUDITORIA" -Content {New-UDButton -Text "Ver Logs" -OnClick {$LogFile="C:\WPE-Dashboard\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log";if(Test-Path $LogFile){$Logs=Get-Content $LogFile -Tail 30|Out-String;Show-UDModal -Content {New-UDHeading -Text "Ultimas 30 ejecuciones" -Size 4;New-UDElement -Tag 'pre' -Attributes @{style=@{'background-color'='#f5f5f5';'padding'='15px';'border-radius'='5px';'font-family'='Consolas, monospace';'font-size'='12px';'overflow-x'='auto'}} -Content {$Logs}} -Header {New-UDHeading -Text "Logs" -Size 5}}else{Show-UDToast -Message "No hay logs" -Duration 3000}}; New-UDButton -Text "Reiniciar Dashboard" -OnClick {Show-UDToast -Message "Reiniciando dashboard..." -Duration 3000 -BackgroundColor "#ff9800";Write-DashboardLog -Accion "Reiniciar Dashboard" -Resultado "Solicitado";try{Get-UDDashboard | Stop-UDDashboard;Start-Sleep -Seconds 2;Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -NoExit -Command `"cd C:\WPE-Dashboard; .\Dashboard.ps1`"" -Verb RunAs;exit}catch{Show-UDToast -Message "Error al reiniciar: $_" -Duration 5000 -BackgroundColor "#f44336"}}}}
New-UDElement -Tag 'hr'
New-UDElement -Tag 'p' -Attributes @{style=@{'text-align'='center';'color'='#666'}} -Content {"Acuarios Paradise IT Dashboard v1.0 | $(Get-Date -Format 'dd/MM/yyyy HH:mm')"}
}
Start-UDDashboard -Dashboard $Dashboard -Port 10000 -AutoReload
