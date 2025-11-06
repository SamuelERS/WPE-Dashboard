# MALAS PRACTICAS

**Impacto:** ALTO - Dificulta escalabilidad y mantenimiento
**Prioridad:** ALTA (refactorizar antes de agregar mas scripts)

---

## MP-1: CODIGO DUPLICADO MASIVAMENTE

**Ubicacion:** Todo el archivo Dashboard.ps1
**Impacto:** ALTO (Mantenibilidad pesima)
**Tipo:** Violacion principio DRY

### Descripcion
El mismo patron se repite **15+ veces** con cambios minimos en el texto.

### Patron Repetido

**Estructura duplicada:**
```powershell
New-UDButton -Text "Nombre Accion" -OnClick {
    Show-UDToast -Message "Ejecutando accion..." -Duration 2000
    Write-DashboardLog -Accion "Nombre Accion" -Resultado "Iniciado"
}
```

### Cuantificacion

**Botones placeholder encontrados:** 15
**Lineas de codigo repetido:** ~30 lineas (2 lineas × 15 botones)
**Funciones helper implementadas:** 0

### Ejemplos de Duplicacion

```powershell
# Linea 598
New-UDButton -Text "Configurar Biometria" -OnClick {
    Show-UDToast -Message "Configurando biometria..." -Duration 2000
    Write-DashboardLog -Accion "Config Biometria" -Resultado "Iniciado"
}

# Linea 599
New-UDButton -Text "Instalar Software Base" -OnClick {
    Show-UDToast -Message "Instalando software..." -Duration 2000
    Write-DashboardLog -Accion "Software Base" -Resultado "Iniciado"
}

# Linea 600
New-UDButton -Text "Configurar Email Corporativo" -OnClick {
    Show-UDToast -Message "Configurando email..." -Duration 2000
    Write-DashboardLog -Accion "Email Corp" -Resultado "Iniciado"
}

# ... 12 botones mas con el mismo patron
```

### Problema
- Cambiar el patron requiere editar 15 lugares
- Facil olvidar actualizar algun boton
- Codigo repetitivo es dificil de leer
- Aumenta tamano del archivo innecesariamente

### Solucion con Funcion Helper

**Implementar (como esta documentado):**
```powershell
# Agregar despues de linea 142
function New-PlaceholderButton {
    param(
        [string]$Text,
        [string]$Action
    )

    New-UDButton -Text $Text -OnClick {
        Show-UDToast -Message "$Action..." -Duration 2000 -BackgroundColor $Colors.Primary
        Write-DashboardLog -Accion $Action -Resultado "Iniciado"
    }
}
```

**Uso simplificado:**
```powershell
# ANTES (3 lineas por boton)
New-UDButton -Text "Configurar Biometria" -OnClick {
    Show-UDToast -Message "Configurando biometria..." -Duration 2000
    Write-DashboardLog -Accion "Config Biometria" -Resultado "Iniciado"
}

# DESPUES (1 linea por boton)
New-PlaceholderButton -Text "Configurar Biometria" -Action "Config Biometria"
```

### Ahorro de Codigo

**Estado actual:** 15 botones × 3 lineas = 45 lineas
**Con funcion helper:** 15 botones × 1 linea = 15 lineas
**Ahorro:** 30 lineas (67% reduccion)

**Mas funcion helper:** +10 lineas
**Neto:** 20 lineas menos (44% reduccion)

**Tiempo estimado:** 2 horas

---

## MP-2: LOGICA DE NEGOCIO EMBEBIDA EN UI

**Ubicacion:** `Dashboard.ps1:176-594`
**Impacto:** ALTO (Codigo acoplado)
**Tipo:** Violacion de separacion de concerns

### Descripcion
Toda la logica de negocio esta **dentro** de los bloques `-OnClick`, haciendo imposible:
- Testear funciones individualmente
- Reutilizar logica
- Ejecutar scripts desde linea de comandos
- Mantener Dashboard.ps1 legible

### Ejemplo: Crear Usuario

**Estado actual (68 lineas embebidas):**
```powershell
# Linea 251-319
New-UDButton -Text "Crear Usuario del Sistema" -OnClick {
    Show-UDModal -Content {
        New-UDInput -Title "..." -Content {...} -Endpoint {
            param($nombreUsuario, $password, $tipoUsuario)

            # TODA LA LOGICA AQUI (68 LINEAS)
            # Validaciones
            if([string]::IsNullOrWhiteSpace($nombreUsuario)){...}

            # Verificar permisos admin
            $isAdmin = ([Security.Principal.WindowsPrincipal]...)

            # Verificar si usuario existe
            $usuarioExiste = Get-LocalUser...

            # Crear usuario con net user
            & net user "$nombreUsuario" "$password" /add...

            # Agregar a grupo
            & net localgroup "Administrators" "$nombreUsuario" /add...

            # Configurar registro para no ocultar
            Remove-ItemProperty -Path $registroSpecialAccounts...

            # Logging
            Write-DashboardLog...

            # UI feedback
            Show-UDToast...
            Start-Sleep -Seconds 2
            Hide-UDModal
        }
    }
}
```

### Problemas

1. **No testeable:** No se puede llamar a la funcion directamente
2. **No reutilizable:** Logica atrapada en el closure
3. **Dificil de debuggear:** No hay forma de ejecutar paso a paso
4. **Dashboard.ps1 gigante:** 68 lineas para un solo boton

### Solucion: Separar en Script

**Crear: Scripts/Configuracion/Crear-Usuario-Sistema.ps1**
```powershell
# @Name: Crear Usuario del Sistema
# @Description: Crea un nuevo usuario local de Windows
# @RequiresAdmin: true

param(
    [Parameter(Mandatory=$true)]
    [string]$nombreUsuario,

    [string]$password = "841357",

    [ValidateSet("POS", "Admin", "Diseno", "Atencion")]
    [string]$tipoUsuario = "POS"
)

function Write-ScriptLog {
    param([string]$Mensaje)
    $LogFile = Join-Path $PSScriptRoot "..\..\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$Timestamp] $Mensaje"
}

try {
    # Validaciones
    if([string]::IsNullOrWhiteSpace($nombreUsuario)){
        throw "El nombre de usuario es obligatorio"
    }

    # Verificar permisos admin
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if(-not $isAdmin){
        throw "Este script requiere permisos de administrador"
    }

    # Auto-detectar PC
    $nombrePC = $env:COMPUTERNAME
    Write-ScriptLog "Crear Usuario ($nombreUsuario) - Iniciado - PC: $nombrePC"

    # Verificar si usuario existe
    $usuarioExiste = Get-LocalUser -Name $nombreUsuario -ErrorAction SilentlyContinue
    if($usuarioExiste){
        throw "El usuario '$nombreUsuario' ya existe"
    }

    # Crear usuario
    $resultNet = & net user "$nombreUsuario" "$password" /add /fullname:"$nombreUsuario" /passwordchg:no /expires:never
    if($LASTEXITCODE -ne 0){
        throw "Error al crear usuario: $resultNet"
    }

    # Agregar a grupo segun tipo
    $grupo = switch($tipoUsuario){
        "Admin" { "Administrators" }
        default { "Users" }
    }
    & net localgroup $grupo "$nombreUsuario" /add | Out-Null

    # Configurar registro
    $registroSpecialAccounts = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
    if(Test-Path $registroSpecialAccounts){
        Remove-ItemProperty -Path $registroSpecialAccounts -Name $nombreUsuario -ErrorAction SilentlyContinue
    }

    Write-ScriptLog "Crear Usuario ($nombreUsuario) - Exitoso - PC: $nombrePC"
    return @{Success = $true; Message = "Usuario '$nombreUsuario' creado exitosamente en PC: $nombrePC"}

} catch {
    Write-ScriptLog "Crear Usuario - Error: $_"
    return @{Success = $false; Message = "Error: $_"}
}
```

**En Dashboard.ps1 (simplificado a 20 lineas):**
```powershell
New-UDButton -Text "Crear Usuario del Sistema" -OnClick {
    Show-UDModal -Content {
        New-UDInput -Title "Crear Usuario del Sistema" -Content {
            New-UDInputField -Name "nombreUsuario" -Placeholder "Ejemplo: POS-Merliot" -Type textbox
            New-UDInputField -Name "password" -Placeholder "Password (defecto: 841357)" -Type textbox
            New-UDInputField -Name "tipoUsuario" -Placeholder "Tipo" -Type select -Values @("POS", "Admin", "Diseno")
        } -Endpoint {
            param($nombreUsuario, $password, $tipoUsuario)

            # Validacion minima
            if([string]::IsNullOrWhiteSpace($nombreUsuario)){
                Show-UDToast -Message "El nombre de usuario es obligatorio" -Duration 5000 -BackgroundColor $Colors.Danger
                return
            }

            # Ejecutar script separado
            $scriptPath = Join-Path $ScriptRoot "Scripts\Configuracion\Crear-Usuario-Sistema.ps1"
            $result = & $scriptPath -nombreUsuario $nombreUsuario -password $password -tipoUsuario $tipoUsuario

            # Mostrar resultado
            if($result.Success){
                Show-UDToast -Message $result.Message -Duration 5000 -BackgroundColor $Colors.Success
                Hide-UDModal
            } else {
                Show-UDToast -Message $result.Message -Duration 8000 -BackgroundColor $Colors.Danger
            }
        }
    }
}
```

### Beneficios

- **Testeable:** `.\Crear-Usuario-Sistema.ps1 -nombreUsuario "Test" -password "123"`
- **Reutilizable:** Llamar desde otros scripts
- **Dashboard.ps1 mas corto:** De 68 lineas a 20 lineas
- **Mejor logging:** Centralizado en el script
- **Facilita ScriptLoader:** Metadata en el script

**Tiempo estimado:** 6-8 horas (mover 5-7 scripts complejos)

---

## MP-3: HARDCODED PATHS

**Ubicacion:** Scripts individuales
**Impacto:** MEDIO (Portabilidad comprometida)
**Tipo:** Acoplamiento a filesystem

### Descripcion
Algunos scripts tienen paths absolutos hardcodeados, impidiendo portabilidad.

### Ejemplo en Script

**Scripts/Configuracion/Crear-Usuario-Sistema.ps1 (linea 17):**
```powershell
$LogFile = "C:\WPE-Dashboard\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
```

### Problema
Path hardcodeado impide:
- Ejecutar dashboard desde carpeta de red (ej: `\\servidor\WPE-Dashboard`)
- Instalar en ubicacion personalizada (ej: `D:\Herramientas\WPE-Dashboard`)
- Portabilidad entre sistemas
- Testing con paths temporales

### Dashboard.ps1 LO HACE BIEN

**Linea 6-7:**
```powershell
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host "Ubicacion del dashboard: $ScriptRoot" -ForegroundColor Cyan
```

### Solucion

**Opcion A: Usar $PSScriptRoot (solo PS 3.0+)**
```powershell
# En cada script:
$LogFile = Join-Path $PSScriptRoot "..\..\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
```

**Opcion B: Recibir $ScriptRoot como parametro**
```powershell
param(
    [string]$nombreUsuario,
    [string]$password,
    [string]$ScriptRoot = "C:\WPE-Dashboard"  # Fallback
)

$LogFile = Join-Path $ScriptRoot "Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
```

**Opcion C: Detectar automaticamente**
```powershell
# Detectar root del proyecto (buscar hacia arriba)
$currentPath = $PSScriptRoot
while($currentPath -and -not (Test-Path (Join-Path $currentPath "Dashboard.ps1"))){
    $currentPath = Split-Path -Parent $currentPath
}
$ProjectRoot = $currentPath
$LogFile = Join-Path $ProjectRoot "Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
```

**Recomendado:** Opcion C (mas robusto)

**Tiempo estimado:** 2 horas (actualizar 7 scripts)

---

## MP-4: LOGGING INCONSISTENTE

**Ubicacion:** Dashboard.ps1 vs Scripts
**Impacto:** MEDIO (Debugging dificil)
**Tipo:** Inconsistencia de implementacion

### Descripcion
Existen **2 implementaciones diferentes** de logging con APIs incompatibles.

### Implementacion 1: Dashboard.ps1

**Funcion: `Write-DashboardLog` (linea 128-137)**
```powershell
function Write-DashboardLog {
    param(
        [string]$Accion,
        [string]$Resultado
    )
    $LogFile = Join-Path $ScriptRoot "Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    try {
        Add-Content -Path $LogFile -Value "[$Timestamp] $Accion - $Resultado" -ErrorAction SilentlyContinue
    } catch {
        Write-Host "Error al escribir log: $_" -ForegroundColor Red
    }
}
```

**Uso:**
```powershell
Write-DashboardLog -Accion "Crear Usuario" -Resultado "Exitoso"
```

**Formato de salida:**
```
[2025-11-06 14:30:45] Crear Usuario - Exitoso
```

### Implementacion 2: Scripts Individuales

**Funcion: `Write-ScriptLog` (Crear-Usuario-Sistema.ps1:15-20)**
```powershell
function Write-ScriptLog {
    param([string]$Mensaje)
    $LogFile = "C:\WPE-Dashboard\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$Timestamp] $Mensaje"
}
```

**Uso:**
```powershell
Write-ScriptLog "Crear Usuario (Test) - Exitoso - PC: DESKTOP-123"
```

**Formato de salida:**
```
[2025-11-06 14:30:45] Crear Usuario (Test) - Exitoso - PC: DESKTOP-123
```

### Diferencias

| Aspecto | Write-DashboardLog | Write-ScriptLog |
|---------|-------------------|-----------------|
| Parametros | 2 (Accion, Resultado) | 1 (Mensaje) |
| Path | Dinamico (Join-Path) | Hardcoded (C:\...) |
| Error handling | try/catch | Sin manejo |
| Formato | "$Accion - $Resultado" | "$Mensaje" (libre) |
| Consistencia | Forzada por parametros | Manual en cada llamada |

### Problema
- No hay formato unificado en logs
- Dificil parsear logs programaticamente
- Llamadas incompatibles entre Dashboard y Scripts
- Path hardcoded en scripts

### Solucion: Libreria Compartida

**Crear: Utils/Logging.ps1**
```powershell
# Libreria compartida de logging

function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Accion,

        [Parameter(Mandatory=$true)]
        [string]$Resultado,

        [string]$Detalles = "",

        [string]$LogPath = $null
    )

    # Auto-detectar path si no se provee
    if(-not $LogPath){
        $rootPath = $PSScriptRoot
        # Buscar hacia arriba hasta encontrar Dashboard.ps1
        while($rootPath -and -not (Test-Path (Join-Path $rootPath "Dashboard.ps1"))){
            $rootPath = Split-Path -Parent $rootPath
        }
        if($rootPath){
            $LogPath = Join-Path $rootPath "Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
        } else {
            $LogPath = ".\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
        }
    }

    # Formato consistente
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $PC = $env:COMPUTERNAME
    $Usuario = $env:USERNAME

    $mensaje = "[$Timestamp] [$PC] [$Usuario] $Accion - $Resultado"
    if($Detalles){
        $mensaje += " | $Detalles"
    }

    try {
        Add-Content -Path $LogPath -Value $mensaje -ErrorAction Stop
    } catch {
        Write-Warning "Error al escribir log: $_"
    }
}

# Aliases para compatibilidad
Set-Alias -Name Write-DashboardLog -Value Write-Log
Set-Alias -Name Write-ScriptLog -Value Write-Log
```

**Uso unificado:**
```powershell
# En Dashboard.ps1:
. (Join-Path $ScriptRoot "Utils\Logging.ps1")
Write-Log -Accion "Dashboard Iniciado" -Resultado "OK"

# En scripts:
. (Join-Path $PSScriptRoot "..\..\Utils\Logging.ps1")
Write-Log -Accion "Crear Usuario" -Resultado "Exitoso" -Detalles "Usuario: $nombreUsuario"
```

**Formato de salida unificado:**
```
[2025-11-06 14:30:45] [DESKTOP-123] [Admin] Dashboard Iniciado - OK
[2025-11-06 14:31:12] [DESKTOP-123] [Admin] Crear Usuario - Exitoso | Usuario: POS-Merliot
```

**Tiempo estimado:** 3 horas (crear libreria + actualizar llamadas)

---

## MP-5: PASSWORDS EN PLAINTEXT

**Ubicacion:** Multiple
**Impacto:** MEDIO (Seguridad)
**Tipo:** Vulnerabilidad de seguridad

### Descripcion
Passwords manejados como strings planos en lugar de SecureString.

### Ejemplos Problematicos

**1. Password por defecto hardcodeado (linea 257):**
```powershell
if([string]::IsNullOrWhiteSpace($password)){$password = "841357"}
```

**2. Parametro password como string (linea 252):**
```powershell
param($nombreUsuario, $password, $tipoUsuario)  # $password es string
```

**3. Password visible en comando (linea 282):**
```powershell
$resultNet = & net user "$nombreUsuario" "$password" /add /fullname:"$nombreUsuario"
```

### Riesgos

1. **Password en logs de procesos**
   - Get-Process muestra command line con passwords
   - Event Viewer registra comandos completos

2. **Password en memoria**
   - Strings son inmutables en .NET
   - Permanecen en memoria hasta garbage collection
   - Pueden ser leidos con debuggers

3. **Password por defecto conocido**
   - "841357" hardcodeado en codigo fuente
   - Cualquiera con acceso al repo conoce el password

4. **Sin rotacion de passwords**
   - Todos los usuarios creados tienen mismo password por defecto
   - No hay politica de cambio obligatorio

### Solucion

**Usar SecureString:**
```powershell
param(
    [string]$nombreUsuario,

    [SecureString]$password,  # ← Usar SecureString

    [string]$tipoUsuario
)

# Generar password seguro si no se provee
if(-not $password){
    $password = ConvertTo-SecureString -String (New-RandomPassword -Length 12) -AsPlainText -Force
}

# Convertir SecureString a plaintext solo cuando sea necesario
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
$plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)

# Usar y limpiar inmediatamente
$resultNet = & net user "$nombreUsuario" "$plainPassword" /add
$plainPassword = $null  # Limpiar de memoria
```

**Funcion para generar passwords:**
```powershell
function New-RandomPassword {
    param([int]$Length = 12)

    $characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%"
    $password = -join ((1..$Length) | ForEach-Object { $characters[(Get-Random -Maximum $characters.Length)] })
    return $password
}
```

**Mejor practica: Forzar cambio en primer login**
```powershell
# Al crear usuario:
& net user "$nombreUsuario" "$plainPassword" /add /logonpasswordchg:yes

# Usuario debera cambiar password en primer inicio de sesion
```

**Tiempo estimado:** 2 horas

---

## RESUMEN DE MALAS PRACTICAS

| ID | Mala Practica | Ubicacion | Impacto | Tiempo Fix |
|----|---------------|-----------|---------|------------|
| MP-1 | Codigo duplicado | Todo el archivo | ALTO | 2h |
| MP-2 | Logica embebida en UI | Dashboard.ps1:176-594 | ALTO | 6-8h |
| MP-3 | Hardcoded paths | Scripts individuales | MEDIO | 2h |
| MP-4 | Logging inconsistente | Dashboard + Scripts | MEDIO | 3h |
| MP-5 | Passwords plaintext | Multiple | MEDIO | 2h |

**Tiempo total estimado:** 15-19 horas

---

## PRIORIDAD DE CORRECCION

1. **MP-2** - Separar logica (6-8h) → **CRITICA** para escalabilidad
2. **MP-1** - Eliminar duplicacion (2h) → **ALTA**
3. **MP-4** - Unificar logging (3h) → **ALTA**
4. **MP-3** - Paths relativos (2h) → **MEDIA**
5. **MP-5** - SecureString (2h) → **MEDIA**

**Minimo viable:** MP-2 + MP-1 = 8-10 horas
**Completo:** 15-19 horas
