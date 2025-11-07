# 🗺️ MAPA DE DEPENDENCIAS Y COMPONENTES
## Dashboard IT - Paradise-SystemLabs

**Fecha:** 7 de Noviembre, 2025  
**Versión:** 1.0  
**Propósito:** Mapear relaciones entre componentes y dependencias del sistema

---

## 📊 DIAGRAMA DE ARQUITECTURA ACTUAL

### Vista de Alto Nivel

```
┌─────────────────────────────────────────────────────────────┐
│                    USUARIO FINAL                             │
│              (Navegador Web - Puerto 10000)                  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│            UniversalDashboard.Community v2.9.0              │
│                  (Framework Web PowerShell)                  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   Dashboard.ps1 (793 líneas)                │
│                      ⚠️ MONOLÍTICO                          │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ • UI Components (inline)                             │  │
│  │ • Business Logic (inline)                            │  │
│  │ • Validations (inline)                               │  │
│  │ • Logging (función global)                           │  │
│  │ • 7 Funcionalidades completas (400+ líneas)          │  │
│  │ • 13 Botones stub (placeholders)                     │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────┘
                         │
         ┌───────────────┼───────────────┐
         │               │               │
         ▼               ▼               ▼
    ┌────────┐     ┌─────────┐    ┌──────────┐
    │ Logs/  │     │Scripts/ │    │ Tools/   │
    │(auto)  │     │(NO USADO)│    │(manual)  │
    └────────┘     └─────────┘    └──────────┘
```

### Vista Detallada de Componentes

```
WPE-Dashboard/
│
├─ [CORE] Dashboard.ps1 ────────────┐
│   │                                │
│   ├─ Depende de:                   │
│   │  • UniversalDashboard module   │
│   │  • $env:COMPUTERNAME           │
│   │  • $env:USERNAME               │
│   │  • Puerto 10000                │
│   │  • Permisos Admin              │
│   │                                │
│   └─ Crea/Usa:                     │
│      • Logs/ (auto-creada)         │
│      • Variables globales          │
│      • Funciones inline            │
│                                    │
├─ [MODULAR] Scripts/ ──────────────┤
│   │                                │
│   ├─ ScriptLoader.ps1              │ ⚠️ NO INTEGRADO
│   │  └─ Funciones:                 │
│   │     • Get-ScriptsByCategory()  │
│   │     • Get-ScriptMetadata()     │
│   │     • $Global:DashboardCategories
│   │                                │
│   ├─ PLANTILLA-Script.ps1          │ ✅ Referencia
│   │  └─ Funciones:                 │
│   │     • Write-ScriptLog()        │
│   │     • Test-AdminPrivileges()   │
│   │                                │
│   └─ Categorías/                   │
│      ├─ Configuracion/ (2 scripts) │ ⚠️ NO USADOS
│      ├─ Mantenimiento/ (1 script)  │ ⚠️ NO USADOS
│      └─ POS/ (2 scripts)           │ ⚠️ NO USADOS
│                                    │
├─ [UTILS] Tools/ ──────────────────┤
│   │                                │
│   └─ Utilidades independientes:    │
│      • Detener-Dashboard.ps1       │
│      • Limpiar-Puerto-10000.ps1    │
│      • Abrir-Navegador.ps1         │
│      • Eliminar-Usuario.ps1        │
│                                    │
├─ [EMPTY] Components/ ─────────────┤ ⚠️ VACÍA
├─ [EMPTY] Config/ ─────────────────┤ ⚠️ VACÍA
├─ [EMPTY] Utils/ ──────────────────┤ ⚠️ VACÍA
│                                    │
└─ [DOCS] Docs/ ────────────────────┘ ✅ COMPLETA
    └─ 20+ documentos organizados
```

---

## 🔗 ANÁLISIS DE DEPENDENCIAS

### Dependencias Externas

#### 1. UniversalDashboard.Community
```
Módulo: UniversalDashboard.Community
Versión: 2.9.0 (específica)
Fuente: PowerShell Gallery
Estado: ✅ Gestión automática implementada

Funciones Utilizadas:
├─ New-UDDashboard
├─ Start-UDDashboard
├─ Stop-UDDashboard
├─ Get-UDDashboard
├─ New-UDCard
├─ New-UDButton
├─ New-UDInput
├─ New-UDModal
├─ Show-UDModal
├─ Hide-UDModal
├─ Show-UDToast
├─ New-UDHeading
├─ New-UDElement
├─ New-UDLayout
└─ New-UDInputField

Gestión de Instalación:
├─ Detección automática (líneas 10-60)
├─ Instalación automática con permisos admin
├─ Fallback a instalación manual
└─ Validación post-instalación
```

#### 2. PowerShell Cmdlets del Sistema
```
Cmdlets de Windows:
├─ Get-LocalUser
├─ New-LocalUser
├─ Set-LocalUser
├─ Remove-LocalUser
├─ Get-LocalGroup
├─ Get-LocalGroupMember
├─ Rename-Computer
├─ Restart-Computer
├─ Get-NetTCPConnection
├─ Get-NetIPAddress
├─ Get-Process
├─ Stop-Process
├─ Get-WmiObject
├─ Get-ItemProperty
├─ Set-ItemProperty
└─ Remove-ItemProperty

Requisitos:
├─ PowerShell 5.1+
├─ Windows 10/11 o Server 2016+
└─ Permisos de Administrador
```

### Dependencias Internas

#### Dashboard.ps1 → Recursos del Sistema

```
Dashboard.ps1 (793 líneas)
│
├─ Variables de Entorno
│  ├─ $env:COMPUTERNAME ────────────┐ Usado en 15+ lugares
│  └─ $env:USERNAME ─────────────────┤ Usado en logging
│                                    │
├─ Sistema de Archivos               │
│  ├─ $ScriptRoot ───────────────────┤ Portabilidad ✅
│  ├─ Logs/ (auto-creada) ───────────┤ Logging
│  └─ C:\Users\* ────────────────────┤ Gestión de perfiles
│                                    │
├─ Registro de Windows               │
│  ├─ HKLM:\SOFTWARE\...\Winlogon    │ Usuarios ocultos
│  └─ HKLM:\SOFTWARE\...\Policies    │ Políticas de sistema
│                                    │
├─ Red                               │
│  ├─ Puerto 10000 ──────────────────┤ Servidor web
│  └─ Detección de IP local          │ Info al usuario
│                                    │
└─ Permisos                          │
   └─ Administrador ───────────────────┤ Operaciones críticas
```

#### Scripts Modulares → Recursos

```
Scripts/Configuracion/Cambiar-Nombre-PC.ps1
├─ Depende de:
│  ├─ Permisos Admin
│  ├─ Cmdlet Rename-Computer
│  └─ Logs/ (para Write-ScriptLog)
│
└─ NO DEPENDE DE: Dashboard.ps1 ✅ (Independiente)

Scripts/Configuracion/Crear-Usuario-Sistema.ps1
├─ Depende de:
│  ├─ Permisos Admin
│  ├─ Cmdlets de usuario local
│  └─ Logs/ (para Write-ScriptLog)
│
└─ NO DEPENDE DE: Dashboard.ps1 ✅ (Independiente)

ScriptLoader.ps1
├─ Depende de:
│  ├─ Estructura de carpetas Scripts/
│  └─ Metadata en comentarios de scripts
│
└─ DEBERÍA SER USADO POR: Dashboard.ps1 ⚠️ (No integrado)
```

---

## 🔄 FLUJO DE DATOS Y CONTROL

### Flujo de Inicio del Dashboard

```
1. Usuario ejecuta: Iniciar-Dashboard.bat
   │
   ├─ Solicita permisos de administrador
   └─ Ejecuta: Dashboard.ps1
       │
       ▼
2. Dashboard.ps1 - Inicialización (líneas 1-218)
   │
   ├─ [Líneas 10-60] Verificar/Instalar UniversalDashboard
   │  ├─ Get-Module -ListAvailable
   │  ├─ Si no existe → Install-Module
   │  └─ Import-Module
   │
   ├─ [Líneas 76-81] Crear carpeta Logs/
   │  └─ New-Item -Path $LogsPath -ItemType Directory
   │
   ├─ [Líneas 84-186] Gestión de Puerto 10000
   │  ├─ Get-UDDashboard → Stop-UDDashboard
   │  ├─ Get-NetTCPConnection -LocalPort 10000
   │  ├─ Identificar procesos en puerto
   │  ├─ Stop-Process (si necesario)
   │  └─ Esperar liberación (10 segundos)
   │
   ├─ [Líneas 189-198] Definir función Write-DashboardLog
   │  └─ Función global para logging
   │
   └─ [Líneas 200-218] Variables de diseño y header
      ├─ $Colors (colores del tema)
      ├─ $Spacing (espaciado)
      └─ Mostrar información de inicio
       │
       ▼
3. Dashboard.ps1 - Definición de UI (líneas 219-791)
   │
   ├─ New-UDDashboard -Content { ... }
   │  │
   │  ├─ Tarjeta de información del sistema
   │  ├─ Layout de 2 columnas
   │  │  ├─ Card "CONFIGURACION INICIAL"
   │  │  │  └─ 10 botones (7 funcionales + 3 stub)
   │  │  └─ Card "MANTENIMIENTO GENERAL"
   │  │     └─ 4 botones (todos stub)
   │  │
   │  ├─ Layout de 3 columnas
   │  │  ├─ Card "PUNTO DE VENTA" (3 botones stub)
   │  │  ├─ Card "DISEÑO GRAFICO" (3 botones stub)
   │  │  └─ Card "ATENCION AL CLIENTE" (3 botones stub)
   │  │
   │  └─ Card "ACCIONES CRITICAS"
   │     ├─ Botón "REINICIAR PC"
   │     └─ Botón "Reiniciar Dashboard"
   │
   └─ Cada botón tiene lógica inline en -OnClick { ... }
       │
       ▼
4. Start-UDDashboard (línea 792)
   │
   └─ Inicia servidor web en puerto 10000
      └─ Modo AutoReload activado
```

### Flujo de Ejecución de Funcionalidad

**Ejemplo: Crear Usuario del Sistema**

```
Usuario hace clic en botón "Crear Usuario del Sistema"
│
▼
Dashboard.ps1 línea 295: New-UDButton -OnClick { ... }
│
├─ Show-UDModal (línea 296)
│  └─ New-UDInput con 3 campos (líneas 298-300)
│     ├─ nombreUsuario (textbox)
│     ├─ password (password)
│     └─ tipoUsuario (select)
│
▼
Usuario llena formulario y envía
│
▼
Endpoint del formulario (líneas 301-411)
│
├─ [Líneas 305-329] Validaciones de nombreUsuario
│  ├─ IsNullOrWhiteSpace()
│  ├─ Lista negra de nombres
│  └─ Caracteres peligrosos
│
├─ [Líneas 332-343] Validaciones de password
│  ├─ IsNullOrWhiteSpace()
│  └─ Longitud mínima (6 caracteres)
│
├─ [Líneas 346-352] Verificar permisos admin
│  └─ Si no admin → Error y return
│
├─ [Líneas 354-360] Verificar usuario no existe
│  └─ Get-LocalUser -Name $nombreUsuario
│
├─ [Líneas 368-370] Validación final de seguridad
│  └─ Último chequeo antes de crear
│
├─ [Líneas 374-402] Crear usuario
│  ├─ net user "$nombreUsuario" "$password" /add
│  ├─ Set-LocalUser -PasswordNeverExpires $true
│  ├─ net localgroup Users "$nombreUsuario" /add
│  ├─ Eliminar de registro de usuarios ocultos
│  └─ gpupdate /force
│
├─ [Línea 404] Write-DashboardLog (éxito)
│
└─ [Línea 405] Show-UDToast (mensaje al usuario)
   └─ Hide-UDModal
```

**Problema Identificado:** Toda esta lógica (119 líneas) está inline en Dashboard.ps1, cuando debería estar en un script modular.

---

## 📦 COMPONENTES Y SUS RESPONSABILIDADES

### Componentes Actuales

#### 1. Dashboard.ps1 (CORE)
```
Responsabilidades ACTUALES:
├─ ✅ Inicialización del sistema
├─ ✅ Gestión de dependencias
├─ ✅ Gestión de puerto
├─ ✅ Definición de UI
├─ ⚠️ Lógica de negocio (DEBERÍA DELEGARSE)
├─ ⚠️ Validaciones (DEBERÍA DELEGARSE)
├─ ⚠️ Operaciones de sistema (DEBERÍA DELEGARSE)
└─ ✅ Logging (función global)

Responsabilidades IDEALES:
├─ ✅ Inicialización del sistema
├─ ✅ Gestión de dependencias
├─ ✅ Gestión de puerto
├─ ✅ Definición de UI
├─ ✅ Orquestación de componentes
└─ ✅ Logging (función global)

Tamaño ACTUAL: 793 líneas
Tamaño IDEAL: ~300 líneas
```

#### 2. ScriptLoader.ps1 (MODULAR - NO USADO)
```
Responsabilidades DISEÑADAS:
├─ ✅ Cargar scripts por categoría
├─ ✅ Extraer metadata de scripts
├─ ✅ Definir categorías disponibles
└─ ✅ Proporcionar API de carga dinámica

Estado: ⚠️ Implementado pero NO integrado con Dashboard.ps1

Funciones Disponibles:
├─ Get-ScriptsByCategory($Category)
│  └─ Retorna lista de scripts en categoría
├─ Get-ScriptMetadata($ScriptPath)
│  └─ Extrae metadata de comentarios
└─ $Global:DashboardCategories
   └─ Definición de categorías

Potencial: ALTO - Podría reemplazar 400+ líneas de código inline
```

#### 3. Scripts Modulares (PRODUCCIÓN - NO USADOS)
```
Scripts Disponibles:
├─ Configuracion/
│  ├─ Cambiar-Nombre-PC.ps1 (92 líneas)
│  │  └─ Funcionalidad: Cambiar nombre del equipo
│  └─ Crear-Usuario-Sistema.ps1
│     └─ Funcionalidad: Crear usuario local
│
├─ Mantenimiento/
│  └─ Limpiar-Archivos-Temporales.ps1
│     └─ Funcionalidad: Limpieza de sistema
│
└─ POS/
   ├─ Crear-Usuario-POS.ps1
   └─ Crear-Usuario.ps1

Estado: ⚠️ Bien diseñados pero NO UTILIZADOS

Problema: Dashboard.ps1 tiene código inline duplicado
```

#### 4. PLANTILLA-Script.ps1 (REFERENCIA)
```
Propósito: Plantilla para nuevos scripts

Proporciona:
├─ Estructura de metadata
├─ Función Write-ScriptLog()
├─ Función Test-AdminPrivileges()
├─ Manejo de errores con try/catch
└─ Retorno estructurado de resultados

Estado: ✅ Excelente referencia
Uso: Copiar y modificar para nuevos scripts
```

#### 5. Tools/ (UTILIDADES)
```
Herramientas Independientes:
├─ Detener-Dashboard.ps1
│  └─ Detiene dashboards en ejecución
├─ Limpiar-Puerto-10000.ps1
│  └─ Libera puerto manualmente
├─ Abrir-Navegador.ps1
│  └─ Abre navegador en localhost:10000
└─ Eliminar-Usuario.ps1
   └─ Elimina usuario local

Estado: ✅ Funcionales e independientes
Uso: Ejecución manual para mantenimiento
```

### Componentes Planificados (Carpetas Vacías)

#### 6. Components/ (VACÍA)
```
Propósito PLANIFICADO: Componentes reutilizables de UI

Debería contener:
├─ UI-Components.ps1
│  ├─ New-CustomCard()
│  ├─ New-CustomButton()
│  └─ New-CustomModal()
│
├─ Form-Components.ps1
│  ├─ New-UserForm()
│  ├─ New-PCNameForm()
│  └─ New-ValidationMessage()
│
└─ Layout-Components.ps1
   ├─ New-TwoColumnLayout()
   └─ New-ThreeColumnLayout()

Estado: ⚠️ NO IMPLEMENTADO
Impacto: UI code duplicado en Dashboard.ps1
```

#### 7. Config/ (VACÍA)
```
Propósito PLANIFICADO: Configuración centralizada

Debería contener:
├─ dashboard-config.json
│  ├─ Puerto del servidor
│  ├─ Colores del tema
│  ├─ Espaciado
│  └─ Rutas del sistema
│
├─ categories-config.json
│  └─ Definición de categorías de scripts
│
└─ Config-Loader.ps1
   └─ Funciones para cargar configuración

Estado: ⚠️ NO IMPLEMENTADO
Impacto: Configuración hardcoded en Dashboard.ps1
```

#### 8. Utils/ (VACÍA)
```
Propósito PLANIFICADO: Utilidades compartidas

Debería contener:
├─ Validation-Utils.ps1
│  ├─ Test-AdminPrivileges()
│  ├─ Test-ValidUsername()
│  ├─ Test-ValidPassword()
│  └─ Test-ValidPCName()
│
├─ System-Utils.ps1
│  ├─ Get-CurrentPC()
│  ├─ Get-LocalUsers()
│  └─ Get-SystemInfo()
│
└─ Logging-Utils.ps1
   ├─ Write-Log()
   ├─ Get-LogFile()
   └─ Clear-OldLogs()

Estado: ⚠️ NO IMPLEMENTADO
Impacto: Funciones duplicadas en múltiples lugares
```

---

## 🔀 DEPENDENCIAS CRUZADAS

### Matriz de Dependencias

```
                    │ Dashboard │ Scripts │ Tools │ Components │ Config │ Utils │
────────────────────┼───────────┼─────────┼───────┼────────────┼────────┼───────┤
Dashboard.ps1       │     -     │   ❌    │  ❌   │     ❌     │   ❌   │  ❌   │
Scripts/            │    ❌     │    -    │  ❌   │     ❌     │   ❌   │  ❌   │
Tools/              │    ❌     │   ❌    │   -   │     ❌     │   ❌   │  ❌   │
Components/ (vacía) │    ❌     │   ❌    │  ❌   │     -      │   ❌   │  ❌   │
Config/ (vacía)     │    ❌     │   ❌    │  ❌   │     ❌     │    -   │  ❌   │
Utils/ (vacía)      │    ❌     │   ❌    │  ❌   │     ❌     │   ❌   │   -   │

Leyenda:
✅ = Dependencia implementada
⚠️ = Dependencia parcial
❌ = Sin dependencia
```

**Observación:** Componentes están completamente desacoplados (no hay dependencias cruzadas). Esto es bueno para modularidad pero indica falta de integración.

### Dependencias Ideales (Arquitectura Objetivo)

```
                    │ Dashboard │ Scripts │ Tools │ Components │ Config │ Utils │
────────────────────┼───────────┼─────────┼───────┼────────────┼────────┼───────┤
Dashboard.ps1       │     -     │   ✅    │  ⚠️   │     ✅     │   ✅   │  ✅   │
Scripts/            │    ❌     │    -    │  ❌   │     ⚠️     │   ⚠️   │  ✅   │
Tools/              │    ⚠️     │   ❌    │   -   │     ❌     │   ⚠️   │  ✅   │
Components/         │    ❌     │   ❌    │  ❌   │     -      │   ✅   │  ✅   │
Config/             │    ❌     │   ❌    │  ❌   │     ❌     │    -   │  ❌   │
Utils/              │    ❌     │   ❌    │  ❌   │     ❌     │   ❌   │   -   │
```

---

## 🚨 PROBLEMAS DE DEPENDENCIAS

### 1. Falta de Integración ScriptLoader
```
PROBLEMA:
ScriptLoader.ps1 existe con funciones de carga dinámica
Dashboard.ps1 NO lo utiliza

IMPACTO:
├─ Código inline duplicado (400+ líneas)
├─ Scripts modulares ignorados
└─ Arquitectura inconsistente

SOLUCIÓN:
Dashboard.ps1 debería:
├─ Import ScriptLoader.ps1
├─ Usar Get-ScriptsByCategory()
├─ Generar botones dinámicamente
└─ Delegar ejecución a scripts modulares
```

### 2. Carpetas Estructurales Vacías
```
PROBLEMA:
Components/, Config/, Utils/ están vacías

IMPACTO:
├─ No hay lugar claro para código compartido
├─ Duplicación de validaciones y utilidades
└─ Configuración hardcoded

SOLUCIÓN:
Poblar carpetas con:
├─ Components/ → Componentes de UI reutilizables
├─ Config/ → Archivos de configuración
└─ Utils/ → Funciones de utilidad compartidas
```

### 3. Rutas Hardcodeadas
```
PROBLEMA:
ScriptLoader.ps1 línea 10:
$categoryPath = "C:\WPE-Dashboard\Scripts\$Category"

IMPACTO:
├─ No portable a otras ubicaciones
├─ Inconsistente con $ScriptRoot en Dashboard.ps1

SOLUCIÓN:
Usar variable global o parámetro:
$categoryPath = "$Global:DashboardRoot\Scripts\$Category"
```

### 4. Sin Gestión de Configuración
```
PROBLEMA:
Variables de diseño hardcoded en Dashboard.ps1:
$Colors = @{Primary = "#2196F3"; ...}
$Spacing = @{XS = "10px"; ...}

IMPACTO:
├─ Difícil cambiar tema o colores
├─ No hay separación de configuración y código

SOLUCIÓN:
Crear Config/dashboard-config.json:
{
  "server": {"port": 10000},
  "theme": {"colors": {...}, "spacing": {...}}
}
```

---

## 📈 MÉTRICAS DE ACOPLAMIENTO

### Acoplamiento Actual

```
Dashboard.ps1:
├─ Acoplamiento con UniversalDashboard: ALTO (necesario)
├─ Acoplamiento con Sistema Operativo: ALTO (necesario)
├─ Acoplamiento con Scripts/: NULO (problema)
├─ Acoplamiento con Components/: NULO (problema)
├─ Acoplamiento con Config/: NULO (problema)
└─ Acoplamiento con Utils/: NULO (problema)

Cohesión de Dashboard.ps1: BAJA (hace demasiado)
Cohesión de Scripts/: ALTA (bien separados)
```

### Métricas de Complejidad

```
Complejidad Ciclomática:
├─ Dashboard.ps1: ALTA (múltiples paths de ejecución)
├─ Scripts modulares: BAJA (funciones específicas)
└─ Tools/: BAJA (utilidades simples)

Profundidad de Anidamiento:
├─ Dashboard.ps1: ALTA (5-7 niveles)
├─ Scripts modulares: MEDIA (3-4 niveles)
└─ Tools/: BAJA (2-3 niveles)
```

---

## 💡 RECOMENDACIONES

### Prioridad 1: Integrar ScriptLoader
```
ACCIÓN:
1. Modificar Dashboard.ps1 para importar ScriptLoader.ps1
2. Usar Get-ScriptsByCategory() para cargar scripts
3. Generar botones dinámicamente desde metadata
4. Delegar ejecución a scripts modulares

BENEFICIO:
├─ Reducir Dashboard.ps1 de 793 a ~300 líneas
├─ Habilitar scripts modulares existentes
└─ Facilitar agregar nuevas funcionalidades
```

### Prioridad 2: Poblar Carpetas Estructurales
```
ACCIÓN:
1. Crear Utils/Validation-Utils.ps1 con validaciones comunes
2. Crear Config/dashboard-config.json con configuración
3. Crear Components/UI-Components.ps1 con componentes reutilizables

BENEFICIO:
├─ Eliminar duplicación de código
├─ Separar configuración de código
└─ Reutilizar componentes de UI
```

### Prioridad 3: Refactorizar Rutas
```
ACCIÓN:
1. Definir variable global $Global:DashboardRoot
2. Actualizar ScriptLoader.ps1 para usar rutas relativas
3. Verificar portabilidad en diferentes ubicaciones

BENEFICIO:
├─ Sistema completamente portable
└─ Consistencia en manejo de rutas
```

---

## 📋 CONCLUSIONES

### Estado de Dependencias
- **Dependencias externas:** ✅ Bien gestionadas
- **Dependencias internas:** ⚠️ Desacopladas pero no integradas
- **Acoplamiento:** ⚠️ Dashboard.ps1 muy acoplado a todo
- **Cohesión:** ⚠️ Dashboard.ps1 baja cohesión (hace demasiado)

### Oportunidades
1. Integrar ScriptLoader para activar arquitectura modular
2. Poblar carpetas estructurales para eliminar duplicación
3. Centralizar configuración para facilitar personalización
4. Crear componentes reutilizables para UI consistente

### Riesgos
1. Sin integración de ScriptLoader, sistema seguirá creciendo monolíticamente
2. Carpetas vacías indican arquitectura planificada pero abandonada
3. Duplicación de código aumentará con cada nueva funcionalidad

---

**Fin del Mapa de Dependencias y Componentes**

**Preparado por:** Sistema de Análisis Arquitectónico  
**Fecha:** 7 de Noviembre, 2025  
**Versión:** 1.0
