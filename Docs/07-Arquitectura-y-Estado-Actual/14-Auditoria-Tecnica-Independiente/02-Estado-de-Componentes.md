# Estado de Componentes del Sistema

**Documento:** 02-Estado-de-Componentes.md
**Parte de:** Auditoría Técnica Independiente - WPE-Dashboard v1.0.0
**Fecha:** 7 de Noviembre, 2025
**Versión:** 1.0

---

## Tabla de Contenidos

1. [Mapa Completo del Sistema](#mapa-completo-del-sistema)
2. [Dashboard.ps1 - Componente Central](#dashboardps1---componente-central)
3. [ScriptLoader.ps1 - Código Muerto](#scriptloaderps1---código-muerto)
4. [UI-Components.ps1 - Código Muerto](#ui-componentsps1---código-muerto)
5. [Form-Components.ps1 - Código Muerto](#form-componentsps1---código-muerto)
6. [Utils/ - Utilidades Modulares](#utils---utilidades-modulares)
7. [Config/ - Configuración JSON](#config---configuración-json)
8. [Scripts/ - Scripts Modulares](#scripts---scripts-modulares)
9. [Tools/ - Herramientas Legacy](#tools---herramientas-legacy)
10. [Resumen de Hallazgos](#resumen-de-hallazgos)

---

## Mapa Completo del Sistema

### Estructura de Carpetas Encontrada

```
C:\ProgramData\WPE-Dashboard/
│
├─── Dashboard.ps1                    ⚠️ 681 líneas - MONOLÍTICO
├─── CLAUDE.md                        16 KB - Guía de desarrollo
├─── README.md                        Documentación principal
├─── CHANGELOG.md                     7 KB - Historial de versiones
├─── Iniciar-Dashboard.bat            Lanzador con permisos admin
├─── Instalar-Dependencias.bat
├─── Instalar-Dependencias.ps1
│
├─── Components/                      ⚠️ EXISTEN PERO NO SE USAN
│    ├─── UI-Components.ps1           179 líneas - 4 funciones
│    └─── Form-Components.ps1         159 líneas - 2 funciones
│
├─── Config/                          ✅ EXISTEN - ⚠️ NO SE CARGAN
│    ├─── dashboard-config.json       50 líneas - Configuración UI
│    └─── categories-config.json      32 líneas - Categorías de scripts
│
├─── Utils/                           ✅ IMPLEMENTADOS - ⚠️ USO PARCIAL
│    ├─── Logging-Utils.ps1           246 líneas - 4 funciones
│    ├─── Security-Utils.ps1          94 líneas - 4 funciones
│    ├─── System-Utils.ps1            177 líneas - 6 funciones
│    └─── Validation-Utils.ps1        170 líneas - 5 funciones
│
├─── Scripts/
│    ├─── ScriptLoader.ps1            ⚠️ 251 líneas - NO USADO
│    ├─── PLANTILLA-Script.ps1        ⚠️ 83 líneas - RUTAS HARDCODEADAS
│    │
│    ├─── Configuracion/              ✅ SCRIPTS MODULARES
│    │    ├─── Cambiar-Nombre-PC.ps1             89 líneas
│    │    └─── Crear-Usuario-Sistema.ps1         118 líneas
│    │
│    ├─── Mantenimiento/
│    │    ├─── Eliminar-Usuario.ps1              113 líneas
│    │    └─── Limpiar-Archivos-Temporales.ps1
│    │
│    ├─── POS/
│    │    ├─── Crear-Usuario.ps1
│    │    └─── Crear-Usuario-POS.ps1
│    │
│    ├─── Diseno/
│    ├─── Atencion-Al-Cliente/
│    └─── Auditoria/
│
├─── Tools/                           ⚠️ LEGACY - RUTAS HARDCODEADAS
│    ├─── Verificar-Sistema.ps1       ⚠️ 16+ rutas hardcodeadas
│    ├─── Detener-Dashboard.ps1
│    ├─── Eliminar-Usuario.ps1        ⚠️ DUPLICADO
│    ├─── Limpiar-Puerto-10000.ps1
│    └─── Abrir-Navegador.ps1
│
├─── Logs/                            Auto-generado (ignorado en git)
├─── Backup/                          Auto-generado (ignorado en git)
├─── Temp/
└─── Release/
     └─── WPE-Dashboard-v1.0.0/       Copia del proyecto para release
```

### Métricas Generales del Sistema

| Categoría | Archivos | Líneas de Código | Estado |
|-----------|----------|------------------|--------|
| **Core** | 1 (Dashboard.ps1) | 681 | ⚠️ Monolítico |
| **Components** | 2 | 338 | ❌ No usado |
| **ScriptLoader** | 1 | 251 | ❌ No usado |
| **Utils** | 4 | 687 | ✅ Usado parcialmente |
| **Config** | 2 (JSON) | 82 | ⚠️ No cargado |
| **Scripts Modulares** | 3 auditados | 320 | ✅ Excelente calidad |
| **Tools** | 5 | ~400 | ⚠️ Legacy |
| **TOTAL** | ~18 principales | ~2,759 | - |

**Código Muerto Identificado:** 589 líneas (ScriptLoader + Components) = **21.3% del código modular**

---

## Dashboard.ps1 - Componente Central

### Información General

| Propiedad | Valor |
|-----------|-------|
| **Ruta** | `C:\ProgramData\WPE-Dashboard\Dashboard.ps1` |
| **Líneas** | 681 |
| **Reducción vs versión anterior** | -112 líneas (-14% desde 793) |
| **Funciones inline** | 1 (`Write-DashboardLog`) |
| **Botones hardcodeados** | 10+ |
| **Uso de componentes modulares** | 0% |
| **Estado** | ⚠️ MONOLÍTICO |

### Análisis por Secciones

#### Sección 1: Inicialización (Líneas 1-82)
**Estado:** ✅ EXCELENTE - Portable y robusto

**Funcionalidades:**
- Detección automática de ubicación con `$PSScriptRoot`
- Instalación automática de `UniversalDashboard.Community`
- Verificación de versión del módulo
- Creación automática de carpeta `Logs/`

**Código Representativo:**
```powershell
# Líneas 6-9: Importación robusta
$ScriptRoot = $PSScriptRoot
if (-not $ScriptRoot) { $ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not (Get-Module -ListAvailable -Name UniversalDashboard.Community)) {
    Install-Module UniversalDashboard.Community -Force -Scope CurrentUser
}
```

**Evaluación:** ✅ Portable, sin rutas hardcodeadas, manejo de errores adecuado

---

#### Sección 2: Gestión de Dashboard Existentes (Líneas 83-98)
**Estado:** ✅ CORRECTO

**Funcionalidades:**
- Detiene dashboards de UniversalDashboard en ejecución
- Usa cmdlet oficial `Stop-UDDashboard`

**Código:**
```powershell
# Líneas 83-98
$runningDashboards = Get-UDDashboard
if ($runningDashboards) {
    foreach ($dashboard in $runningDashboards) {
        Stop-UDDashboard -Id $dashboard.Id
    }
}
```

**Evaluación:** ✅ Implementación estándar y correcta

---

#### Sección 3: Liberación Avanzada de Puerto 10000 (Líneas 99-187)
**Estado:** ✅ EXCELENTE - Lógica robusta y bien diseñada

**Funcionalidades:**
- Separación de conexiones activas vs TimeWait
- Retry logic (3 intentos)
- Espera de 5 segundos entre intentos
- Manejo de PIDs para matar procesos conflictivos
- Mensajes de error claros y útiles

**Código Representativo:**
```powershell
# Líneas 109-160: Algoritmo de liberación
while (-not $portFree -and $retryCount -lt $maxRetries) {
    $tcpConnections = Get-NetTCPConnection -LocalPort 10000 -ErrorAction SilentlyContinue

    # Separar conexiones activas vs TimeWait
    $activeConnections = $tcpConnections | Where-Object { $_.State -ne 'TimeWait' }

    if ($activeConnections) {
        $processIds = $activeConnections | Select-Object -ExpandProperty OwningProcess -Unique
        foreach ($pid in $processIds) {
            Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
        }
        Start-Sleep -Seconds 5
    }
}
```

**Evaluación:** ✅ 98/100 - Implementación ejemplar con manejo robusto de edge cases

---

#### Sección 4: Función Write-DashboardLog (Líneas 188-198)
**Estado:** ⚠️ PROBLEMÁTICO - Duplicación

**Código:**
```powershell
function Write-DashboardLog {
    param([string]$Accion, [string]$Resultado)
    $LogFile = Join-Path $ScriptRoot "Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Mensaje = "[$Timestamp] $Accion - $Resultado"
    Add-Content -Path $LogFile -Value $Mensaje -ErrorAction SilentlyContinue
    Write-Host $Mensaje -ForegroundColor Cyan
}
```

**Problema Identificado:**

Esta función está **DUPLICADA**. Existe una implementación más completa en `Utils/Logging-Utils.ps1`:

**En Utils/Logging-Utils.ps1 (líneas 15-75):**
```powershell
function Write-DashboardLog {
    param(
        [Parameter(Mandatory=$true)] [string]$Message,
        [Parameter(Mandatory=$false)] [string]$Level = "Info",
        [Parameter(Mandatory=$false)] [string]$Component = "Dashboard"
    )
    # Implementación completa con niveles (Info, Warning, Error, Success)
    # Colores diferentes por nivel
    # Manejo robusto de archivos
}
```

**Diferencias Críticas:**
- Dashboard.ps1: Firma `(Accion, Resultado)`
- Logging-Utils.ps1: Firma `(Message, Level, Component)`
- ❌ **Incompatibles** - No pueden coexistir sin confusión

**Evidencia de No Uso de Utils/Logging-Utils.ps1:**
```bash
grep "Logging-Utils" Dashboard.ps1
# Resultado: (vacío) - NO se importa
```

**Evaluación:** ❌ 40/100 - Duplicación innecesaria, rompe principio DRY

---

#### Sección 5: Variables de Configuración (Líneas 200-218)
**Estado:** ⚠️ PROBLEMÁTICO - Duplicación con JSON

**Código:**
```powershell
# Líneas 200-202: Definición de colores
$Colors = @{
    Primary = "#2196F3"
    Success = "#4caf50"
    Warning = "#ff9800"
    Error = "#f44336"
    Info = "#2196f3"
    Background = "#f5f5f5"
    Text = "#333333"
}

# Líneas 204-208: Definición de espaciados
$Spacing = @{
    XS = "10px"
    S = "12px"
    M = "16px"
    L = "20px"
    XL = "24px"
}
```

**Problema Identificado:**

Estas variables están **DUPLICADAS** en `Config/dashboard-config.json`:

**En Config/dashboard-config.json (líneas 32-48):**
```json
{
  "colors": {
    "primary": "#2196F3",
    "success": "#4caf50",
    "warning": "#ff9800",
    "error": "#f44336",
    ...
  },
  "spacing": {
    "xs": "10px",
    "s": "12px",
    "m": "16px",
    ...
  }
}
```

**Evidencia de No Carga de JSON:**
```bash
grep "dashboard-config.json" Dashboard.ps1
# Resultado: (vacío) - NO se carga el JSON
```

**Evaluación:** ❌ 30/100 - JSON existe pero no se usa, duplicación de configuración

---

#### Sección 6: Definición del Dashboard (Líneas 219-681)
**Estado:** ❌ COMPLETAMENTE MONOLÍTICO - Sin uso de componentes modulares

**Estructura:**
```powershell
# Línea 219: Inicio del bloque New-UDDashboard
$Dashboard = New-UDDashboard -Title "WPE-Dashboard" -Content {

    # Líneas 220-237: Tarjeta informativa PC actual
    New-UDLayout -Columns 1 -Content {
        New-UDCard -Title "Sistema Actual" -Content { ... }
    }

    # Líneas 238-271: Botón "Cambiar Nombre del PC" - HARDCODEADO
    # Líneas 272-338: Botón "Crear Usuario del Sistema" - HARDCODEADO
    # Líneas 339-381: Botón "Eliminar Usuario" - HARDCODEADO
    # ... más botones hardcodeados ...

} # Línea 681: Fin del bloque
```

**Análisis Detallado de un Botón (Ejemplo: "Cambiar Nombre PC")**

**Líneas 238-271:** 34 líneas de código hardcodeado

```powershell
New-UDButton -Text "Cambiar Nombre del PC" -OnClick {
    Show-UDModal -Content {
        New-UDInput -Title "Cambiar Nombre del PC" -Content {
            # Campo 1: Nombre actual (solo lectura)
            New-UDInputField -Name "nombreActualDisplay" `
                -Placeholder "Nombre actual del PC" `
                -Type textbox `
                -DefaultValue $env:COMPUTERNAME

            # Campo 2: Nuevo nombre
            New-UDInputField -Name "nuevoNombrePC" `
                -Placeholder "Nuevo nombre para el PC" `
                -Type textbox

        } -Endpoint {
            param($nombreActualDisplay, $nuevoNombrePC)

            # Validación INLINE (debería usar Validation-Utils)
            if([string]::IsNullOrWhiteSpace($nuevoNombrePC)){
                Show-UDToast -Message "Error: Debe ingresar un nombre" `
                    -Duration 3000 -BackgroundColor "#f44336"
                return
            }

            try {
                # Ejecutar script modular (✅ esto SÍ está bien)
                $scriptPath = Join-Path $ScriptRoot "Scripts\Configuracion\Cambiar-Nombre-PC.ps1"
                $resultado = & $scriptPath -nuevoNombre $nuevoNombrePC

                if($resultado.Success){
                    Show-UDToast -Message "Nombre cambiado exitosamente" `
                        -Duration 8000 -BackgroundColor "#4caf50"
                    Start-Sleep -Seconds 2
                    Hide-UDModal
                } else {
                    Show-UDToast -Message "Error: $($resultado.Message)" `
                        -Duration 8000 -BackgroundColor "#f44336"
                }
            } catch {
                Show-UDToast -Message "Error: $_" `
                    -Duration 8000 -BackgroundColor "#f44336"
            }
        }
    }
}
```

**Evaluación del Patrón:**

| Aspecto | Estado | Comentario |
|---------|--------|------------|
| Script ejecutado ES modular | ✅ | Usa `Scripts/Configuracion/Cambiar-Nombre-PC.ps1` |
| Formulario generado dinámicamente | ❌ | Hardcodeado con `New-UDInput` |
| Botón generado dinámicamente | ❌ | Hardcodeado con `New-UDButton` |
| Validación inline | ❌ | Debería usar `Validation-Utils.ps1` |
| Usa Form-Components.ps1 | ❌ | NO usa `New-DynamicForm` |
| Usa UI-Components.ps1 | ❌ | NO usa `New-ScriptButton` |

**Este patrón se repite en TODOS los botones del dashboard (10+ botones).**

---

**Evidencia de No Uso de Componentes Modulares:**

```bash
# Búsqueda de imports de componentes
grep -i "UI-Components\|Form-Components" Dashboard.ps1
# Resultado: (vacío)

# Búsqueda de uso de funciones de componentes
grep -i "New-ScriptButton\|New-DynamicForm\|New-CategoryCard" Dashboard.ps1
# Resultado: (vacío)

# Búsqueda de ScriptLoader
grep -i "ScriptLoader" Dashboard.ps1
# Resultado: (vacío)
```

**Conclusión:** Dashboard.ps1 NO usa ningún componente modular. La UI es 100% hardcodeada.

---

#### Sección 7: Inicio del Dashboard (Línea 682-681)
**Estado:** ✅ CORRECTO

**Código:**
```powershell
# Línea 682
Start-UDDashboard -Dashboard $Dashboard -Port 10000 -AutoReload
```

**Evaluación:** ✅ Configuración estándar y correcta

---

### Resumen de Dashboard.ps1

| Aspecto | Estado | Calificación |
|---------|--------|--------------|
| **Inicialización** | ✅ Excelente | 95/100 |
| **Gestión de puerto** | ✅ Excelente | 98/100 |
| **Logging** | ⚠️ Duplicado | 40/100 |
| **Configuración** | ⚠️ Duplicada, JSON no usado | 30/100 |
| **UI del Dashboard** | ❌ Monolítico, hardcodeado | 35/100 |
| **Uso de componentes** | ❌ No usa ninguno | 0/100 |
| **GENERAL** | ⚠️ Híbrido | 60/100 |

**Hallazgo Principal:** Dashboard.ps1 tiene **infraestructura excelente** (inicialización, puerto) pero **lógica de UI monolítica** que contradice el objetivo de modularización.

---

## ScriptLoader.ps1 - Código Muerto

### Información General

| Propiedad | Valor |
|-----------|-------|
| **Ruta** | `Scripts/ScriptLoader.ps1` |
| **Líneas** | 251 |
| **Funciones** | 5 |
| **Calidad de código** | ✅ Excelente (95/100) |
| **Estado de uso** | ❌ NO USADO (0%) |
| **Clasificación** | 🔴 CÓDIGO MUERTO |

### Funciones Implementadas

#### 1. Get-ScriptsByCategory (Líneas 26-61)
**Propósito:** Descubrir scripts en una carpeta por categoría

**Firma:**
```powershell
function Get-ScriptsByCategory {
    param([string]$Category)
    # Retorna: Array de objetos FileInfo
}
```

**Implementación:**
- ✅ Usa `$Global:DashboardRoot` (portable)
- ✅ Manejo de errores con try/catch
- ✅ Logging con `Write-DashboardLog`
- ✅ Filtrado por extensión `.ps1`

**Calificación:** 95/100 - Implementación ejemplar

---

#### 2. Get-ScriptMetadata (Líneas 63-125)
**Propósito:** Parsear metadata desde comentarios de scripts

**Firma:**
```powershell
function Get-ScriptMetadata {
    param([string]$ScriptPath)
    # Retorna: Hashtable con metadata
}
```

**Metadata Soportada:**
- `@Name` - Nombre descriptivo
- `@Description` - Descripción del script
- `@Category` - Categoría
- `@RequiresAdmin` - true/false
- `@HasForm` - true/false
- `@FormField` - nombreCampo|Placeholder|tipo

**Implementación:**
- ✅ Parseo robusto con regex
- ✅ Manejo de múltiples `@FormField`
- ✅ Valores por defecto sensatos
- ✅ Manejo de errores

**Calificación:** 98/100 - Implementación sofisticada y robusta

---

#### 3. Get-AllScriptsMetadata (Líneas 127-174)
**Propósito:** Descubrir TODOS los scripts y cargar su metadata

**Firma:**
```powershell
function Get-AllScriptsMetadata {
    # Retorna: Hashtable @{CategoryName = @(Metadata1, Metadata2, ...)}
}
```

**Implementación:**
- ✅ Carga categorías desde `categories-config.json`
- ✅ Itera sobre cada categoría
- ✅ Obtiene scripts con `Get-ScriptsByCategory`
- ✅ Parsea metadata con `Get-ScriptMetadata`
- ✅ Estructura de datos bien diseñada

**Calificación:** 95/100 - Excelente orquestación

---

#### 4. Load-CategoriesConfig (Líneas 176-207)
**Propósito:** Cargar configuración de categorías desde JSON

**Firma:**
```powershell
function Load-CategoriesConfig {
    # Retorna: Array de objetos categoría
}
```

**Implementación:**
- ✅ Lee `Config/categories-config.json`
- ✅ Parseo JSON con `ConvertFrom-Json`
- ✅ Fallback a configuración hardcodeada si JSON falla
- ✅ Manejo de errores robusto

**Calificación:** 90/100 - Implementación sólida con fallback

---

#### 5. Invoke-ModularScript (Líneas 209-248)
**Propósito:** Ejecutar scripts modulares con manejo de errores

**Firma:**
```powershell
function Invoke-ModularScript {
    param([string]$ScriptPath, [hashtable]$Parameters)
    # Retorna: Resultado del script
}
```

**Implementación:**
- ✅ Validación de existencia de script
- ✅ Ejecución con splatting de parámetros
- ✅ Manejo de errores con try/catch
- ✅ Logging de errores

**Calificación:** 90/100 - Implementación correcta

---

### Evidencia de No Uso

**Búsqueda de imports en Dashboard.ps1:**
```bash
grep -i "ScriptLoader" Dashboard.ps1
# Resultado: (vacío)

grep -i "Get-AllScriptsMetadata\|Get-ScriptsByCategory" Dashboard.ps1
# Resultado: (vacío)
```

**Búsqueda de imports en otros archivos:**
```bash
grep -r "ScriptLoader" --include="*.ps1" --exclude-dir=Backup --exclude-dir=Release
# Resultado: Solo en ScriptLoader.ps1 mismo (definiciones)
```

**Búsqueda de uso de funciones:**
```bash
grep -r "Get-AllScriptsMetadata" --include="*.ps1"
# Resultado: Solo definición en ScriptLoader.ps1, NO llamadas
```

### Conclusión sobre ScriptLoader.ps1

| Aspecto | Evaluación |
|---------|------------|
| **Calidad de código** | ✅ Excelente (95/100) |
| **Diseño de funciones** | ✅ Bien pensado y estructurado |
| **Documentación inline** | ✅ Adecuada |
| **Portabilidad** | ✅ Usa `$Global:DashboardRoot` |
| **Uso en el sistema** | ❌ 0% - NUNCA se importa ni se llama |
| **Clasificación** | 🔴 **CÓDIGO MUERTO** (251 líneas) |

**Veredicto:** ScriptLoader.ps1 es código de **excelente calidad** que **nadie usa**. Es un componente completamente implementado pero **desconectado del sistema**.

---

## UI-Components.ps1 - Código Muerto

### Información General

| Propiedad | Valor |
|-----------|-------|
| **Ruta** | `Components/UI-Components.ps1` |
| **Líneas** | 179 |
| **Funciones** | 4 |
| **Calidad de código** | ✅ Buena (85/100) |
| **Estado de uso** | ❌ NO USADO (0%) |
| **Clasificación** | 🔴 CÓDIGO MUERTO |

### Funciones Implementadas

#### 1. New-CategoryCard
**Propósito:** Generar tarjeta de categoría con descripción

**Firma:**
```powershell
function New-CategoryCard {
    param([string]$CategoryName, [string]$Description, [int]$ScriptCount)
}
```

**Evaluación:** ✅ Implementación correcta pero no usada

---

#### 2. New-ScriptButton
**Propósito:** Generar botón desde metadata de script

**Firma:**
```powershell
function New-ScriptButton {
    param([hashtable]$ScriptMetadata, [string]$ScriptRoot)
}
```

**Capacidades:**
- Genera `New-UDButton` dinámicamente
- Crea modal si script tiene formulario
- Crea botón simple si no tiene formulario

**Evaluación:** ✅ Implementación sofisticada pero no usada

---

#### 3. New-ScriptModal
**Propósito:** Generar modal con formulario o confirmación

**Evaluación:** ✅ Implementación correcta pero no usada

---

#### 4. New-ResultToast
**Propósito:** Mostrar resultado con `Show-UDToast`

**Evaluación:** ✅ Implementación simple y correcta pero no usada

---

### Evidencia de No Uso

```bash
grep -i "UI-Components" Dashboard.ps1
# Resultado: (vacío)

grep -i "New-ScriptButton\|New-CategoryCard" Dashboard.ps1
# Resultado: (vacío)
```

### Conclusión sobre UI-Components.ps1

**Clasificación:** 🔴 **CÓDIGO MUERTO** (179 líneas)

---

## Form-Components.ps1 - Código Muerto

### Información General

| Propiedad | Valor |
|-----------|-------|
| **Ruta** | `Components/Form-Components.ps1` |
| **Líneas** | 159 |
| **Funciones** | 2 |
| **Calidad de código** | ✅ Buena (85/100) |
| **Estado de uso** | ❌ NO USADO (0%) |
| **Clasificación** | 🔴 CÓDIGO MUERTO |

### Funciones Implementadas

#### 1. New-DynamicForm
**Propósito:** Generar formulario completo desde metadata

**Capacidades:**
- Parsea `@FormField` de metadata
- Genera `New-UDInput` dinámicamente
- Crea `New-UDInputField` por cada campo

**Evaluación:** ✅ Implementación sofisticada pero no usada

---

#### 2. New-FormField
**Propósito:** Generar campo individual de formulario

**Tipos Soportados:**
- `textbox` - Campo de texto
- `password` - Campo de contraseña
- `select:Op1,Op2,Op3` - Lista desplegable

**Evaluación:** ✅ Implementación correcta pero no usada

---

### Evidencia de No Uso

```bash
grep -i "Form-Components" Dashboard.ps1
# Resultado: (vacío)

grep -i "New-DynamicForm\|New-FormField" Dashboard.ps1
# Resultado: (vacío)
```

### Conclusión sobre Form-Components.ps1

**Clasificación:** 🔴 **CÓDIGO MUERTO** (159 líneas)

---

## Resumen de Código Muerto

| Archivo | Líneas | Funciones | Calidad | Uso |
|---------|--------|-----------|---------|-----|
| ScriptLoader.ps1 | 251 | 5 | 95/100 | ❌ 0% |
| UI-Components.ps1 | 179 | 4 | 85/100 | ❌ 0% |
| Form-Components.ps1 | 159 | 2 | 85/100 | ❌ 0% |
| **TOTAL** | **589** | **11** | **88/100** | **0%** |

**Hallazgo Crítico:** 589 líneas de código de buena calidad que **NUNCA se ejecutan**.

---

## Utils/ - Utilidades Modulares

### Información General

| Propiedad | Valor |
|-----------|-------|
| **Archivos** | 4 |
| **Líneas totales** | 687 |
| **Funciones totales** | 19 |
| **Calidad promedio** | 90/100 |
| **Estado** | ✅ Implementados - ⚠️ Uso parcial |

### 1. Logging-Utils.ps1

| Propiedad | Valor |
|-----------|-------|
| **Líneas** | 246 |
| **Funciones** | 4 |
| **Uso en scripts modulares** | ✅ 75% (3 de 4 funciones) |
| **Uso en Dashboard.ps1** | ❌ 0% |

**Funciones:**
1. `Write-DashboardLog` - ✅ Usada en scripts
2. `Get-RecentLogs` - ❌ No usada
3. `Clear-OldLogs` - ❌ No usada
4. `Get-LogStatistics` - ❌ No usada

**Problema:** Dashboard.ps1 define su propia versión de `Write-DashboardLog` en lugar de importar esta.

---

### 2. Validation-Utils.ps1

| Propiedad | Valor |
|-----------|-------|
| **Líneas** | 170 |
| **Funciones** | 5 |
| **Uso en scripts modulares** | ✅ 100% (5 de 5 funciones) |
| **Uso en Dashboard.ps1** | ❌ 0% |

**Funciones:**
1. `Test-ValidUsername` - ✅ Usada
2. `Test-ValidPassword` - ✅ Usada
3. `Test-ValidPCName` - ✅ Usada
4. `Sanitize-Input` - ✅ Usada
5. `Test-ValidEmail` - ✅ Usada

**Evaluación:** ✅ Excelente uso en scripts modulares, validaciones inline en Dashboard.ps1 deberían migrar aquí

---

### 3. Security-Utils.ps1

| Propiedad | Valor |
|-----------|-------|
| **Líneas** | 94 |
| **Funciones** | 4 |
| **Uso en scripts modulares** | ✅ 50% (2 de 4 funciones) |
| **Uso en Dashboard.ps1** | ❌ 0% |

**Funciones:**
1. `Test-AdminPrivileges` - ❌ No usada
2. `Assert-AdminPrivileges` - ✅ Usada
3. `Test-ScriptRequiresAdmin` - ❌ No usada
4. `Get-CurrentUser` - ✅ Usada

---

### 4. System-Utils.ps1

| Propiedad | Valor |
|-----------|-------|
| **Líneas** | 177 |
| **Funciones** | 6 |
| **Uso** | ❌ 0% - Ninguna función usada |

**Funciones:**
1. `Get-CurrentPCInfo` - ❌ No usada
2. `Get-FilteredLocalUsers` - ❌ No usada
3. `Test-PortAvailable` - ❌ No usada
4. `Get-DiskSpaceInfo` - ❌ No usada
5. `Test-InternetConnection` - ❌ No usada
6. `Get-SystemUptime` - ❌ No usada

**Oportunidad:** Estas funciones podrían usarse en la tarjeta informativa del dashboard (líneas 220-237 de Dashboard.ps1)

---

### Resumen de Utils/

| Archivo | Funciones | Usadas en Scripts | Usadas en Dashboard | Tasa de Uso |
|---------|-----------|-------------------|---------------------|-------------|
| Logging-Utils.ps1 | 4 | 3 | 0 | 75% |
| Validation-Utils.ps1 | 5 | 5 | 0 | 100% |
| Security-Utils.ps1 | 4 | 2 | 0 | 50% |
| System-Utils.ps1 | 6 | 0 | 0 | 0% |
| **TOTAL** | **19** | **10** | **0** | **53%** |

**Hallazgo:** Utils/ tiene buen uso en **scripts modulares** (53%) pero **cero uso en Dashboard.ps1** (que define sus propias versiones).

---

## Config/ - Configuración JSON

### 1. dashboard-config.json

| Propiedad | Valor |
|-----------|-------|
| **Ruta** | `Config/dashboard-config.json` |
| **Líneas** | 50 |
| **Formato** | ✅ JSON válido |
| **Estructura** | ✅ Bien diseñada |
| **Cargado en Dashboard** | ❌ NO |

**Contenido:**
```json
{
  "dashboard": {
    "title": "WPE-Dashboard",
    "port": 10000,
    "autoReload": true
  },
  "colors": {
    "primary": "#2196F3",
    "success": "#4caf50",
    ...
  },
  "spacing": {
    "xs": "10px",
    ...
  }
}
```

**Problema:** Esta configuración está duplicada en Dashboard.ps1 (líneas 200-208) en lugar de cargarse desde JSON.

---

### 2. categories-config.json

| Propiedad | Valor |
|-----------|-------|
| **Ruta** | `Config/categories-config.json` |
| **Líneas** | 32 |
| **Formato** | ✅ JSON válido |
| **Cargado** | ⚠️ Solo por ScriptLoader (que no se usa) |

**Contenido:**
```json
{
  "categories": [
    {"name": "Configuracion", "displayName": "Configuración Inicial", ...},
    {"name": "Mantenimiento", ...},
    {"name": "POS", ...}
  ]
}
```

**Uso:** ScriptLoader.ps1 lo carga con `Load-CategoriesConfig` pero ScriptLoader nunca se usa.

---

### Resumen de Config/

| Archivo | Estado JSON | Cargado | Usado |
|---------|-------------|---------|-------|
| dashboard-config.json | ✅ Válido | ❌ NO | ❌ NO |
| categories-config.json | ✅ Válido | ⚠️ Por ScriptLoader | ❌ NO (ScriptLoader no usado) |

**Hallazgo:** Archivos JSON bien diseñados pero **no se usan**, configuración está duplicada inline en Dashboard.ps1.

---

## Scripts/ - Scripts Modulares

### Scripts Auditados en Detalle

#### 1. Crear-Usuario-Sistema.ps1

| Propiedad | Valor |
|-----------|-------|
| **Ruta** | `Scripts/Configuracion/Crear-Usuario-Sistema.ps1` |
| **Líneas** | 118 |
| **Calificación** | ✅ 95/100 - EXCELENTE |

**Metadata:**
```powershell
# @Name: Crear Usuario del Sistema
# @Description: Crea un usuario local en Windows con configuración básica
# @RequiresAdmin: true
# @HasForm: true
# @FormField: nombreUsuario|Nombre del usuario|textbox
# @FormField: password|Contraseña (defecto: 841357)|password
# @FormField: tipoUsuario|Tipo de usuario|select:POS,Admin,Diseno
```

**Imports:**
```powershell
. (Join-Path $PSScriptRoot "..\..\Utils\Validation-Utils.ps1")
. (Join-Path $PSScriptRoot "..\..\Utils\Logging-Utils.ps1")
. (Join-Path $PSScriptRoot "..\..\Utils\Security-Utils.ps1")
```

**Funcionalidades:**
- ✅ Validación con `Assert-AdminPrivileges`
- ✅ Sanitización con `Sanitize-Input`
- ✅ Validación de username con `Test-ValidUsername`
- ✅ Validación de password con `Test-ValidPassword`
- ✅ Logging con `Write-DashboardLog`
- ✅ Uso de `$Global:DashboardRoot` (portable)
- ✅ Retorno estructurado: `@{Success, Message, Username, PC}`

**Evaluación:** ✅ Script modular ejemplar, sigue todas las mejores prácticas

---

#### 2. Cambiar-Nombre-PC.ps1

| Propiedad | Valor |
|-----------|-------|
| **Ruta** | `Scripts/Configuracion/Cambiar-Nombre-PC.ps1` |
| **Líneas** | 89 |
| **Calificación** | ✅ 95/100 - EXCELENTE |

**Características:**
- ✅ Metadata completa
- ✅ Imports de utilidades
- ✅ Validación con `Test-ValidPCName`
- ✅ Logging adecuado
- ✅ Portable

**Evaluación:** ✅ Script modular ejemplar

---

#### 3. Eliminar-Usuario.ps1

| Propiedad | Valor |
|-----------|-------|
| **Ruta** | `Scripts/Mantenimiento/Eliminar-Usuario.ps1` |
| **Líneas** | 113 |
| **Calificación** | ✅ 95/100 - EXCELENTE |

**Funcionalidades Avanzadas:**
- ✅ Protección de usuarios críticos (Administrator, DefaultAccount, etc.)
- ✅ Limpieza de registro
- ✅ Eliminación de perfil
- ✅ Validaciones robustas

**Evaluación:** ✅ Script modular ejemplar con lógica sofisticada

---

### PLANTILLA-Script.ps1

| Propiedad | Valor |
|-----------|-------|
| **Ruta** | `Scripts/PLANTILLA-Script.ps1` |
| **Líneas** | 83 |
| **Problema** | ⚠️ RUTA HARDCODEADA |

**Código Problemático (Línea 33):**
```powershell
$LogFile = "C:\WPE-Dashboard\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
```

**Debería ser:**
```powershell
$LogFile = Join-Path $Global:DashboardRoot "Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
```

**Impacto:** Nuevos scripts creados con esta plantilla **NO serán portables**.

---

### Resumen de Scripts/

| Script | Líneas | Calidad | Portable | Usa Utils | Metadata |
|--------|--------|---------|----------|-----------|----------|
| Crear-Usuario-Sistema.ps1 | 118 | 95/100 | ✅ | ✅ | ✅ |
| Cambiar-Nombre-PC.ps1 | 89 | 95/100 | ✅ | ✅ | ✅ |
| Eliminar-Usuario.ps1 | 113 | 95/100 | ✅ | ✅ | ✅ |
| PLANTILLA-Script.ps1 | 83 | 70/100 | ❌ | ⚠️ | ✅ |

**Hallazgo Principal:** Scripts modulares son de **excelente calidad** (95/100), pero PLANTILLA tiene ruta hardcodeada que compromete portabilidad de futuros scripts.

---

## Tools/ - Herramientas Legacy

### Estado General

| Propiedad | Valor |
|-----------|-------|
| **Archivos** | 5 principales |
| **Estado** | ⚠️ LEGACY - Rutas hardcodeadas |
| **Duplicaciones** | 1 (Eliminar-Usuario.ps1) |

### Archivos Identificados

#### 1. Verificar-Sistema.ps1
**Problema:** 16+ ocurrencias de `C:\WPE-Dashboard` hardcodeado

**Evidencia:**
```bash
grep "C:\\WPE-Dashboard" Tools/Verificar-Sistema.ps1 | wc -l
# Resultado: 16
```

**Estado:** ⚠️ No portable

---

#### 2. Eliminar-Usuario.ps1 (Tools/)
**Problema:** DUPLICADO de `Scripts/Mantenimiento/Eliminar-Usuario.ps1`

**Evidencia:** Existe el mismo script en dos ubicaciones con funcionalidad similar.

**Estado:** ⚠️ Duplicación

---

#### 3. Otros Tools
- `Detener-Dashboard.ps1` - ✅ Útil, portable
- `Limpiar-Puerto-10000.ps1` - ✅ Útil
- `Abrir-Navegador.ps1` - ✅ Útil

---

### Resumen de Tools/

**Hallazgo:** Carpeta Tools/ contiene mezcla de:
- Scripts legacy con rutas hardcodeadas (Verificar-Sistema.ps1)
- Duplicaciones (Eliminar-Usuario.ps1)
- Scripts útiles y portables (Detener-Dashboard.ps1)

**Recomendación:** Limpiar Tools/, actualizar rutas hardcodeadas, eliminar duplicados.

---

## Resumen de Hallazgos

### Por Categoría de Componente

| Componente | Estado | Calificación | Hallazgo Principal |
|------------|--------|--------------|-------------------|
| **Dashboard.ps1** | ⚠️ Híbrido | 60/100 | Infraestructura excelente, UI monolítica |
| **ScriptLoader.ps1** | ❌ Código muerto | 0/100 uso | 251 líneas no usadas |
| **UI-Components.ps1** | ❌ Código muerto | 0/100 uso | 179 líneas no usadas |
| **Form-Components.ps1** | ❌ Código muerto | 0/100 uso | 159 líneas no usadas |
| **Utils/** | ✅ Funcional | 53/100 uso | Buena calidad, uso parcial |
| **Config/** | ⚠️ No usado | 0/100 uso | JSON válido pero no cargado |
| **Scripts/** | ✅ Excelente | 95/100 | Scripts modulares ejemplares |
| **Tools/** | ⚠️ Legacy | 60/100 | Mezcla de útiles y legacy |

### Métricas Consolidadas

| Métrica | Valor |
|---------|-------|
| **Código muerto total** | 589 líneas (21.3%) |
| **Funciones duplicadas** | 2 (Write-DashboardLog, Colors/Spacing) |
| **Rutas hardcodeadas** | 20+ ubicaciones |
| **Archivos duplicados** | 1 (Eliminar-Usuario.ps1) |
| **JSON no usado** | 2 archivos (82 líneas) |
| **Funciones de Utils no usadas** | 9 de 19 (47%) |

### Hallazgo Central

**El sistema tiene una arquitectura HÍBRIDA:**
- ✅ **Capa de scripts modulares:** Excelente calidad (95/100)
- ✅ **Capa de utilidades:** Bien diseñada, uso parcial (53%)
- ❌ **Capa de presentación (Dashboard.ps1):** Monolítica, no usa componentes modulares
- ❌ **Sistema de carga dinámica:** Implementado pero desconectado (código muerto)

**Conclusión:** La modularización se logró en scripts individuales pero NO en el dashboard central.

---

**Próximo documento:** [03-Validacion-Arquitectonica.md](03-Validacion-Arquitectonica.md) - Evaluación cuantitativa de cumplimiento de objetivos arquitectónicos.

---

**Preparado por:** Sistema de Auditoría Técnica Independiente
**Versión:** 1.0
**Última actualización:** 7 de Noviembre, 2025
