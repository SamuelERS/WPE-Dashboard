# 🏗️ PROPUESTA DE ARQUITECTURA MODULAR
## Dashboard IT - Paradise-SystemLabs

**Fecha:** 7 de Noviembre, 2025  
**Versión:** 1.0  
**Propósito:** Definir arquitectura modular sostenible y escalable para WPE-Dashboard

**Audiencia:** Arquitectos de Software, Líderes Técnicos y Desarrolladores  
**Tiempo de lectura:** 60 minutos  
**Estado:** En desarrollo por entregas

---

## 📑 TABLA DE CONTENIDOS

> **Nota:** Esta propuesta arquitectónica está dividida en 3 documentos para facilitar su lectura y mantenimiento.

### 📄 Documento 03 (Este Documento) - Secciones 1-5
1. [Resumen Ejecutivo](#1-resumen-ejecutivo)
2. [Principios Arquitectónicos](#2-principios-arquitectonicos)
3. [Arquitectura Objetivo](#3-arquitectura-objetivo)
4. [Roles y Responsabilidades](#4-roles-y-responsabilidades)
5. [Estructura de Carpetas Detallada](#5-estructura-de-carpetas-detallada)

### 📄 Documento 03-1 - Secciones 6-10
Ver: `03-1-PROPUESTA-ARQUITECTURA-MODULAR-B.md`
- Integración de ScriptLoader
- Generación Dinámica de UI
- Flujo de Ejecución Modular
- Convenciones y Estándares
- Separación de Responsabilidades

### 📄 Documento 03-2 - Secciones 11-17
Ver: `03-2-PROPUESTA-ARQUITECTURA-MODULAR-C.md`
- Comunicación entre Componentes
- Estrategia de Reducción
- Escalabilidad a 50+ Funcionalidades
- Portabilidad y Configuración
- Seguridad y Permisos
- Riesgos y Mitigación
- Buenas Prácticas PowerShell + UD

### Anexos
- [Documentos Relacionados](#documentos-relacionados)

---

## 1. RESUMEN EJECUTIVO

### 1.1 Objetivo Principal

Transformar el sistema actual de **arquitectura monolítica** (Dashboard.ps1 con 793 líneas) a una **arquitectura modular, escalable y mantenible** que permita crecimiento sostenible hasta 50+ funcionalidades sin degradación de calidad.

**Referencia:** Según **00-RESUMEN-EJECUTIVO.md**, el sistema actual es "funcional con áreas de mejora" y sufre de deuda técnica arquitectónica crítica.

### 1.2 Situación Actual

**Problema Central** (identificado en **01-INFORME-AUDITORIA-TECNICA.md**):
- Dashboard.ps1 contiene 793 líneas con toda la lógica del sistema
- 7 funcionalidades completas embebidas inline (400+ líneas de código)
- Sistema modular (ScriptLoader.ps1) existe pero no se utiliza
- Carpetas estructurales (Components/, Config/, Utils/) vacías
- Duplicación de código en validaciones y operaciones

**Impacto:**
- Difícil de mantener y extender
- Imposible de testear unitariamente
- Alto riesgo de regresiones al modificar código
- Desarrollo colaborativo limitado (conflictos de merge)
- Cada nueva funcionalidad aumenta complejidad exponencialmente

### 1.3 Solución Propuesta

**Arquitectura Modular con:**

| Componente | Rol | Tamaño Objetivo |
|------------|-----|-----------------|
| **Dashboard.ps1** | Orquestador | ~300 líneas (-62%) |
| **ScriptLoader.ps1** | Carga dinámica | Integrado ✅ |
| **Components/** | UI reutilizable | 3-4 archivos |
| **Config/** | Configuración JSON | 3-4 archivos |
| **Utils/** | Utilidades compartidas | 3-4 archivos |
| **Scripts/** | Funcionalidades modulares | Ilimitado |

### 1.4 Principios Rectores

1. **Separación de Responsabilidades** - Cada componente tiene un propósito único
2. **Modularidad** - Funcionalidades independientes y reutilizables
3. **Escalabilidad** - Fácil agregar nuevas funcionalidades sin modificar core
4. **Mantenibilidad** - Código claro, documentado y testeable
5. **Portabilidad** - Sistema funcional en cualquier ubicación
6. **Configurabilidad** - Separación de configuración y código

### 1.5 Beneficios Esperados

| Aspecto | Antes | Después | Mejora |
|---------|-------|---------|--------|
| **Dashboard.ps1** | 793 líneas | ~300 líneas | -62% |
| **Funcionalidades inline** | 7 (400+ líneas) | 0 | -100% |
| **Componentes reutilizables** | 0 | 15+ | +∞ |
| **Configuración hardcoded** | Sí | No (JSON) | -100% |
| **Duplicación de código** | Alta | Baja | -80% |
| **Tiempo agregar funcionalidad** | Variable | <30 min | Consistente |
| **Testeable** | No | Sí | +100% |

### 1.6 Resultado Final

Sistema modular que permite:
- ✅ Desarrollo paralelo de funcionalidades
- ✅ Testing automatizado con Pester
- ✅ Crecimiento ordenado a 50+ funcionalidades
- ✅ Mantenimiento simplificado
- ✅ Onboarding rápido de nuevos desarrolladores
- ✅ Reducción de bugs por separación de responsabilidades

---

## 2. PRINCIPIOS ARQUITECTÓNICOS

### 2.1 Separación de Responsabilidades (SoC)

**Definición:** Cada componente debe tener una única responsabilidad bien definida.

**Aplicación en WPE-Dashboard:**

```
Dashboard.ps1
├─ Responsabilidad: Orquestación e inicialización
├─ NO debe: Contener lógica de negocio
└─ NO debe: Implementar validaciones específicas

Scripts/
├─ Responsabilidad: Lógica de negocio y operaciones
├─ NO debe: Definir UI
└─ NO debe: Gestionar configuración global

Components/
├─ Responsabilidad: Componentes UI reutilizables
├─ NO debe: Contener lógica de negocio
└─ NO debe: Acceder directamente a sistema operativo

Config/
├─ Responsabilidad: Configuración del sistema
├─ NO debe: Contener código ejecutable
└─ NO debe: Mezclarse con lógica

Utils/
├─ Responsabilidad: Funciones de utilidad compartidas
├─ NO debe: Mantener estado
└─ NO debe: Depender de componentes específicos
```

### 2.2 Modularidad

**Definición:** Componentes independientes que pueden desarrollarse, testearse y desplegarse por separado.

**Características de un Módulo:**
- ✅ Interfaz clara y documentada
- ✅ Dependencias explícitas
- ✅ Testeable de forma aislada
- ✅ Reutilizable en diferentes contextos
- ✅ Versionable independientemente

**Ejemplo - Script Modular:**
```powershell
# @Name: Crear Usuario del Sistema
# @Description: Crea un usuario local de Windows
# @RequiresAdmin: true
# @HasForm: true
# @FormField: nombreUsuario|Nombre del usuario|textbox

param(
    [Parameter(Mandatory=$true)]
    [string]$nombreUsuario
)

# Importar utilidades
. "$PSScriptRoot\..\..\Utils\Validation-Utils.ps1"

try {
    if (-not (Test-ValidUsername $nombreUsuario)) {
        throw "Nombre de usuario inválido"
    }
    
    # Lógica de negocio...
    
    return @{
        Success = $true
        Message = "Usuario creado exitosamente"
    }
} catch {
    return @{
        Success = $false
        Message = "Error: $_"
    }
}
```

### 2.3 Escalabilidad

**Definición:** Capacidad de crecer sin degradación de calidad o performance.

**Escalabilidad Horizontal (Agregar Funcionalidades):**
```
Agregar nueva funcionalidad:
1. Crear script en Scripts/Categoria/
2. Usar PLANTILLA-Script.ps1 como base
3. Incluir metadata completa
4. Dashboard.ps1 lo detecta automáticamente
5. UI se genera dinámicamente

Tiempo estimado: <30 minutos
Impacto en core: CERO (no se modifica Dashboard.ps1)
```

### 2.4 Mantenibilidad

**Métricas de Mantenibilidad:**

| Métrica | Objetivo | Medición |
|---------|----------|----------|
| **Complejidad ciclomática** | <10 por función | Análisis estático |
| **Líneas por archivo** | <500 | Contador |
| **Profundidad de anidamiento** | <4 niveles | Revisión de código |
| **Duplicación de código** | <5% | Herramientas de análisis |
| **Cobertura de documentación** | 100% funciones públicas | Revisión manual |

### 2.5 Portabilidad

**Implementación:**

```powershell
# ✅ CORRECTO - Rutas relativas
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogsPath = Join-Path $ScriptRoot "Logs"

# ❌ INCORRECTO - Rutas absolutas
$LogsPath = "C:\WPE-Dashboard\Logs"

# ✅ CORRECTO - Variable global
$Global:DashboardRoot = $ScriptRoot
```

### 2.6 Configurabilidad

**Niveles de Configuración:**

```
1. Configuración de Sistema (dashboard-config.json)
   ├─ Puerto del servidor
   ├─ Rutas del sistema
   └─ Configuración de logging

2. Configuración de Tema (theme-config.json)
   ├─ Colores
   ├─ Espaciado
   └─ Tipografía

3. Configuración de Categorías (categories-config.json)
   ├─ Definición de categorías
   ├─ Orden de visualización
   └─ Iconos y descripciones
```

---

## 3. ARQUITECTURA OBJETIVO

### 3.1 Vista de Alto Nivel

**Referencia:** Basado en análisis de **02-MAPA-DEPENDENCIAS-Y-COMPONENTES.md**

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
│                   Dashboard.ps1 (~300 líneas)               │
│                    ✅ ORQUESTADOR                           │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ • Inicialización del sistema                         │  │
│  │ • Carga de configuración (Config/)                   │  │
│  │ • Importación de módulos (Utils/, Components/)       │  │
│  │ • Integración de ScriptLoader                        │  │
│  │ • Generación dinámica de UI                          │  │
│  │ • Orquestación de componentes                        │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────┬────────────┬────────────┬────────────┬─────────┘
             │            │            │            │
    ┌────────▼───┐  ┌────▼─────┐  ┌──▼──────┐  ┌──▼──────┐
    │ Components │  │  Config  │  │  Utils  │  │ Scripts │
    │  (UI/UX)   │  │ (Settings)│  │(Helpers)│  │(Actions)│
    └────────────┘  └──────────┘  └─────────┘  └─────────┘
         │               │             │            │
         └───────────────┴─────────────┴────────────┘
                         │
                         ▼
                  Sistema Operativo
                  (Ejecución Local)
```

### 3.2 Capas de la Arquitectura

#### Capa 1: Presentación (UI)
```
Responsable: UniversalDashboard + Components/

Componentes:
├─ Framework: UniversalDashboard.Community
├─ Componentes Base: Components/UI-Components.ps1
├─ Formularios: Components/Form-Components.ps1
└─ Layouts: Components/Layout-Components.ps1

Responsabilidades:
├─ Renderizar interfaz de usuario
├─ Capturar entrada del usuario
├─ Mostrar resultados y mensajes
└─ Gestionar modales y toasts

NO debe:
├─ Contener lógica de negocio
├─ Acceder directamente a sistema operativo
└─ Gestionar estado de aplicación
```

#### Capa 2: Orquestación
```
Responsable: Dashboard.ps1

Responsabilidades:
├─ Inicializar sistema
├─ Cargar configuración
├─ Importar módulos
├─ Generar UI dinámicamente
├─ Conectar UI con lógica de negocio
├─ Gestionar ciclo de vida del dashboard
└─ Coordinar componentes

NO debe:
├─ Implementar lógica de negocio
├─ Contener validaciones específicas
└─ Tener código inline de funcionalidades
```

#### Capa 3: Lógica de Negocio
```
Responsable: Scripts/

Componentes:
├─ ScriptLoader.ps1 (cargador dinámico)
├─ Scripts por categoría (Configuracion/, Mantenimiento/, etc.)
└─ PLANTILLA-Script.ps1 (referencia)

Responsabilidades:
├─ Implementar funcionalidades del sistema
├─ Ejecutar operaciones de negocio
├─ Validar reglas de negocio
├─ Interactuar con sistema operativo
└─ Retornar resultados estructurados

NO debe:
├─ Definir UI
├─ Gestionar configuración global
└─ Depender de otros scripts
```

#### Capa 4: Utilidades
```
Responsable: Utils/

Componentes:
├─ Validation-Utils.ps1 (validaciones comunes)
├─ System-Utils.ps1 (operaciones de sistema)
├─ Logging-Utils.ps1 (logging avanzado)
└─ Security-Utils.ps1 (funciones de seguridad)

Responsabilidades:
├─ Proporcionar funciones reutilizables
├─ Validaciones comunes
├─ Operaciones de sistema
└─ Logging y auditoría

NO debe:
├─ Mantener estado
├─ Depender de componentes específicos
└─ Contener lógica de negocio
```

#### Capa 5: Configuración
```
Responsable: Config/

Componentes:
├─ dashboard-config.json (configuración principal)
├─ theme-config.json (tema y diseño)
├─ categories-config.json (categorías de scripts)
└─ Config-Loader.ps1 (cargador de configuración)

Responsabilidades:
├─ Almacenar configuración del sistema
├─ Definir parámetros de comportamiento
├─ Configurar tema y diseño
└─ Definir estructura de categorías

NO debe:
├─ Contener código ejecutable (excepto Config-Loader.ps1)
├─ Mezclarse con lógica
└─ Ser modificado por el sistema (solo lectura)
```

### 3.3 Flujo de Datos

```
1. Inicio
   Usuario → Iniciar-Dashboard.bat → Dashboard.ps1

2. Inicialización
   Dashboard.ps1 → Verificar UniversalDashboard
                 → Crear carpetas (Logs/, Backup/)
                 → Liberar puerto 10000

3. Carga de Configuración
   Dashboard.ps1 → Config-Loader.ps1 → dashboard-config.json
                                      → theme-config.json
                                      → categories-config.json

4. Importación de Módulos
   Dashboard.ps1 → Utils/*.ps1
                 → Components/*.ps1
                 → ScriptLoader.ps1

5. Generación de UI
   Dashboard.ps1 → ScriptLoader.Get-ScriptsByCategory()
                 → Components.New-CustomButton()
                 → New-UDDashboard

6. Ejecución de Funcionalidad
   Usuario → Botón → Dashboard.ps1 → ScriptLoader.Invoke-DashboardScript()
                                    → Scripts/Categoria/Script.ps1
                                    → Utils/*.ps1 (validaciones)
                                    → Sistema Operativo
                                    → Retorno de resultado
                                    → Show-UDToast (feedback)
```

---

## 4. ROLES Y RESPONSABILIDADES

### 4.1 Dashboard.ps1 - Orquestador Principal

**Rol:** Punto de entrada y coordinador del sistema

**Tamaño Objetivo:** ~300 líneas (vs. 793 actual = -62%)

**Estructura Propuesta:**

```powershell
# ============================================
# DASHBOARD.PS1 - ORQUESTADOR PRINCIPAL
# ============================================

# SECCIÓN 1: INICIALIZACIÓN (50 líneas)
# • Detectar ubicación del script ($ScriptRoot)
# • Definir variable global $Global:DashboardRoot
# • Verificar/Instalar UniversalDashboard
# • Gestionar puerto 10000
# • Crear carpetas necesarias (Logs/, Backup/)

# SECCIÓN 2: CARGA DE CONFIGURACIÓN (30 líneas)
# • Importar Config-Loader.ps1
# • Cargar dashboard-config.json
# • Cargar theme-config.json
# • Cargar categories-config.json
# • Validar configuración

# SECCIÓN 3: IMPORTACIÓN DE MÓDULOS (40 líneas)
# • Importar Utils/Validation-Utils.ps1
# • Importar Utils/System-Utils.ps1
# • Importar Utils/Logging-Utils.ps1
# • Importar Components/UI-Components.ps1
# • Importar Components/Form-Components.ps1
# • Importar Scripts/ScriptLoader.ps1
# • Inicializar ScriptLoader

# SECCIÓN 4: GENERACIÓN DE UI (150 líneas)
# • Crear dashboard con New-UDDashboard
# • Generar tarjeta de información del sistema
# • Para cada categoría:
#   - Obtener scripts con Get-ScriptsByCategory()
#   - Crear sección de categoría
#   - Generar botones dinámicamente
# • Agregar secciones fijas

# SECCIÓN 5: INICIO DEL SERVIDOR (30 líneas)
# • Logging de inicio
# • Start-UDDashboard -Port $config.server.port
# • Mostrar información de acceso
```

**Lo que NO debe hacer:**
- ❌ Implementar funcionalidades inline
- ❌ Contener validaciones específicas
- ❌ Tener lógica de negocio embebida
- ❌ Hardcodear configuración
- ❌ Duplicar código

### 4.2 Components/ - Componentes UI Reutilizables

**Rol:** Biblioteca de componentes de interfaz

**Archivos Propuestos:**

#### Components/UI-Components.ps1
```
Funciones:
├─ New-CustomCard($Title, $Content, $Style)
├─ New-CustomButton($Text, $OnClick, $Type)
├─ New-InfoBanner($Message, $Type)
└─ New-LoadingSpinner($Message)

Propósito: Componentes base con estilo consistente del tema
```

#### Components/Form-Components.ps1
```
Funciones:
├─ New-GenericForm($Title, $Fields, $OnSubmit)
├─ New-ValidationMessage($Message, $Type)
└─ New-ConfirmDialog($Title, $Message, $OnConfirm)

Propósito: Formularios y diálogos reutilizables
```

#### Components/Layout-Components.ps1
```
Funciones:
├─ New-TwoColumnLayout($LeftContent, $RightContent)
├─ New-ThreeColumnLayout($Content1, $Content2, $Content3)
└─ New-CategorySection($CategoryName, $Scripts)

Propósito: Layouts responsive y estructuras
```

### 4.3 Config/ - Configuración Centralizada

**Rol:** Almacenar toda la configuración del sistema

**Archivos Propuestos:**

#### Config/dashboard-config.json
```json
{
  "server": {
    "port": 10000,
    "autoReload": true,
    "title": "Paradise-SystemLabs"
  },
  "paths": {
    "logs": "Logs",
    "scripts": "Scripts",
    "backup": "Backup"
  },
  "logging": {
    "enabled": true,
    "level": "info",
    "maxFileSizeMB": 10,
    "retentionDays": 180
  }
}
```

#### Config/theme-config.json
```json
{
  "colors": {
    "primary": "#2196F3",
    "success": "#4caf50",
    "warning": "#ff9800",
    "danger": "#dc3545"
  },
  "spacing": {
    "xs": "10px",
    "s": "12px",
    "m": "16px",
    "l": "20px"
  }
}
```

#### Config/categories-config.json
```json
{
  "categories": [
    {
      "id": "configuracion",
      "title": "CONFIGURACIÓN INICIAL",
      "icon": "⚙️",
      "path": "Configuracion",
      "order": 1
    }
  ]
}
```

#### Config/Config-Loader.ps1
```powershell
function Load-DashboardConfig {
    $path = "$Global:DashboardRoot\Config\dashboard-config.json"
    return Get-Content $path | ConvertFrom-Json
}

function Load-ThemeConfig {
    $path = "$Global:DashboardRoot\Config\theme-config.json"
    return Get-Content $path | ConvertFrom-Json
}
```

### 4.4 Utils/ - Utilidades Compartidas

**Rol:** Funciones reutilizables sin estado

**Archivos Propuestos:**

#### Utils/Validation-Utils.ps1
```powershell
function Test-AdminPrivileges { ... }
function Test-ValidUsername($Username) { ... }
function Test-ValidPassword($Password, $MinLength = 6) { ... }
function Test-ValidPCName($PCName) { ... }
```

#### Utils/System-Utils.ps1
```powershell
function Get-CurrentPCInfo { ... }
function Get-FilteredLocalUsers { ... }
function Test-PortAvailable($Port) { ... }
```

#### Utils/Logging-Utils.ps1
```powershell
function Write-DashboardLog($Message, $Level, $Component) { ... }
function Get-RecentLogs($Lines = 50) { ... }
function Clear-OldLogs($RetentionDays) { ... }
```

### 4.5 Scripts/ - Funcionalidades Modulares

**Rol:** Implementar lógica de negocio

**Estructura:**
```
Scripts/
├─ ScriptLoader.ps1 (cargador dinámico)
├─ PLANTILLA-Script.ps1 (template)
├─ Configuracion/
│  ├─ Cambiar-Nombre-PC.ps1
│  └─ Crear-Usuario-Sistema.ps1
├─ Mantenimiento/
│  └─ Limpiar-Archivos-Temporales.ps1
└─ [otras categorías]/
```

**Contrato de Script:**
```powershell
# Metadata obligatoria
# @Name: Nombre descriptivo
# @Description: Qué hace el script
# @RequiresAdmin: true/false
# @HasForm: true/false
# @FormField: campo|placeholder|tipo

param(...)  # Parámetros tipados

# Importar utilidades necesarias
. "$PSScriptRoot\..\..\Utils\*.ps1"

try {
    # Lógica de negocio
    return @{
        Success = $true
        Message = "Mensaje de éxito"
        Data = @{ ... }  # Opcional
    }
} catch {
    return @{
        Success = $false
        Message = "Error: $_"
    }
}
```

### 4.6 Tools/ - Herramientas de Mantenimiento

**Rol:** Utilidades independientes para administración

**Archivos Existentes:**
- `Detener-Dashboard.ps1` - Detiene dashboards en ejecución
- `Limpiar-Puerto-10000.ps1` - Libera puerto manualmente
- `Abrir-Navegador.ps1` - Abre navegador en localhost:10000
- `Eliminar-Usuario.ps1` - Elimina usuario local

**Características:**
- Ejecutables independientemente
- No dependen de Dashboard.ps1
- Útiles para troubleshooting

### 4.7 Docs/ - Documentación

**Rol:** Documentación completa del proyecto

**Estado:** ✅ Excelente (20+ documentos organizados)

**Mantenimiento:** Actualizar cuando cambie arquitectura

---

## 5. ESTRUCTURA DE CARPETAS DETALLADA

### 5.1 Árbol Completo de Carpetas

```
WPE-Dashboard/
│
├── Dashboard.ps1                    # ✅ Orquestador principal (~300 líneas)
├── Iniciar-Dashboard.bat            # ✅ Lanzador con permisos admin
├── Instalar-Dependencias.bat        # ✅ Instalador automático
├── Instalar-Dependencias.ps1        # ✅ Script de instalación
├── README.md                        # ✅ Documentación principal
├── CHANGELOG.md                     # ✅ Historial de cambios
├── CLAUDE.md                        # ✅ Notas de desarrollo
│
├── Components/                      # 🆕 Componentes UI reutilizables
│   ├── UI-Components.ps1            # Componentes base (cards, buttons, banners)
│   ├── Form-Components.ps1          # Formularios y validaciones
│   └── Layout-Components.ps1        # Layouts responsive
│
├── Config/                          # 🆕 Configuración centralizada
│   ├── dashboard-config.json        # Configuración principal del sistema
│   ├── theme-config.json            # Colores, espaciado, tipografía
│   ├── categories-config.json       # Definición de categorías de scripts
│   └── Config-Loader.ps1            # Funciones para cargar configuración
│
├── Utils/                           # 🆕 Utilidades compartidas
│   ├── Validation-Utils.ps1         # Validaciones comunes (username, password, etc.)
│   ├── System-Utils.ps1             # Operaciones de sistema (users, PC info, etc.)
│   ├── Logging-Utils.ps1            # Sistema de logging avanzado
│   └── Security-Utils.ps1           # Funciones de seguridad
│
├── Scripts/                         # ✅ Scripts de automatización
│   ├── ScriptLoader.ps1             # ✅ Cargador dinámico (mejorado)
│   ├── PLANTILLA-Script.ps1         # ✅ Template para nuevos scripts
│   │
│   ├── Configuracion/               # Scripts de configuración inicial
│   │   ├── Cambiar-Nombre-PC.ps1
│   │   └── Crear-Usuario-Sistema.ps1
│   │
│   ├── Mantenimiento/               # Scripts de mantenimiento
│   │   └── Limpiar-Archivos-Temporales.ps1
│   │
│   ├── POS/                         # Scripts de punto de venta
│   │   ├── Crear-Usuario-POS.ps1
│   │   └── Crear-Usuario.ps1
│   │
│   ├── Diseno/                      # Scripts de diseño gráfico
│   ├── Atencion-Al-Cliente/         # Scripts de atención al cliente
│   └── Auditoria/                   # Scripts de auditoría
│
├── Tools/                           # ✅ Herramientas de mantenimiento
│   ├── Abrir-Navegador.ps1
│   ├── Detener-Dashboard.ps1
│   ├── Eliminar-Usuario.ps1
│   ├── Limpiar-Puerto-10000.ps1
│   └── Verificar-Sistema.ps1
│
├── Docs/                            # ✅ Documentación completa
│   ├── 00-INDICE-MAESTRO.md
│   ├── Arquitectura-y-Estado-Actual/
│   └── [otras carpetas de documentación]
│
├── Logs/                            # ✅ Logs automáticos (auto-creada)
│   └── dashboard-YYYY-MM.log
│
├── Backup/                          # ✅ Backups del sistema (auto-creada)
└── Temp/                            # ✅ Archivos temporales (auto-creada)
```

### 5.2 Convenciones de Nombres

#### Archivos PowerShell
```
Formato: PascalCase-Con-Guiones.ps1

Ejemplos:
✅ Crear-Usuario-Sistema.ps1
✅ Cambiar-Nombre-PC.ps1
✅ Limpiar-Archivos-Temporales.ps1

❌ crear_usuario.ps1
❌ CrearUsuario.ps1
❌ crear-usuario-sistema.ps1
```

#### Archivos JSON
```
Formato: kebab-case.json

Ejemplos:
✅ dashboard-config.json
✅ theme-config.json
✅ categories-config.json

❌ DashboardConfig.json
❌ dashboard_config.json
```

#### Funciones PowerShell
```
Formato: Verb-Noun (PowerShell estándar)

Ejemplos:
✅ Test-AdminPrivileges
✅ Get-FilteredLocalUsers
✅ New-CustomButton

❌ CheckAdmin
❌ getUsers
❌ createButton
```

### 5.3 Tamaños Objetivo por Componente

| Componente | Archivos | Líneas Totales | Estado |
|------------|----------|----------------|--------|
| **Dashboard.ps1** | 1 | ~300 | Refactorizar |
| **Components/** | 3 | ~400 | Crear |
| **Config/** | 4 | ~200 | Crear |
| **Utils/** | 4 | ~400 | Crear |
| **Scripts/** | 5+ | Ilimitado | Usar existentes |
| **Tools/** | 5 | ~200 | ✅ Mantener |
| **Docs/** | 20+ | N/A | ✅ Mantener |

**Total estimado:** ~1,900 líneas (vs. ~1,500 actual)

**Nota:** Aunque el total aumenta ligeramente, el código está mejor organizado, es más mantenible y escalable.

### 5.4 Dependencias entre Carpetas

```
Dashboard.ps1
├─ Depende de: Config/, Utils/, Components/, Scripts/
└─ No depende de: Tools/, Docs/

Components/
├─ Depende de: Config/ (para tema)
└─ No depende de: Scripts/, Utils/

Config/
└─ No depende de: Ninguna (solo lectura)

Utils/
├─ Depende de: Config/ (para logging config)
└─ No depende de: Components/, Scripts/

Scripts/
├─ Depende de: Utils/ (validaciones, logging)
└─ No depende de: Components/, Dashboard.ps1

Tools/
├─ Puede depender de: Utils/ (opcional)
└─ No depende de: Dashboard.ps1, Components/
```

### 5.5 Archivos Críticos

**Archivos que NO deben modificarse sin planificación:**
1. `Dashboard.ps1` - Core del sistema
2. `Scripts/ScriptLoader.ps1` - Cargador dinámico
3. `Scripts/PLANTILLA-Script.ps1` - Template de referencia
4. `Config/*.json` - Configuración del sistema

**Archivos seguros para modificar:**
1. Scripts individuales en `Scripts/Categoria/`
2. Documentación en `Docs/`
3. Herramientas en `Tools/`

---

## 📦 ENTREGA A - COMPLETADA

### Cambios en esta Entrega

**Secciones Completadas:**
1. ✅ **Resumen Ejecutivo** - Objetivo, situación actual, solución propuesta, beneficios
2. ✅ **Principios Arquitectónicos** - 6 principios fundamentales con ejemplos
3. ✅ **Arquitectura Objetivo** - Vista de alto nivel, capas, flujo de datos
4. ✅ **Roles y Responsabilidades** - Definición detallada de cada componente
5. ✅ **Estructura de Carpetas Detallada** - Árbol completo, convenciones, tamaños

**Contenido Generado:**
- Diagramas ASCII de arquitectura
- Ejemplos de código PowerShell
- Estructuras JSON de configuración
- Tablas comparativas
- Convenciones de nombres

**Referencias a Documentos Base:**
- **00-RESUMEN-EJECUTIVO.md** - Estado actual y problemas críticos
- **01-INFORME-AUDITORIA-TECNICA.md** - Análisis detallado de Dashboard.ps1
- **02-MAPA-DEPENDENCIAS-Y-COMPONENTES.md** - Relaciones entre componentes

**Continuación:**
- Ver **03-1-PROPUESTA-ARQUITECTURA-MODULAR-B.md** para secciones 6-10
- Ver **03-2-PROPUESTA-ARQUITECTURA-MODULAR-C.md** para secciones 11-17

---

## DOCUMENTOS RELACIONADOS

### Documentos de Auditoría Base
1. **00-RESUMEN-EJECUTIVO.md** - Visión general de auditoría
2. **01-INFORME-AUDITORIA-TECNICA.md** - Análisis técnico detallado
3. **02-MAPA-DEPENDENCIAS-Y-COMPONENTES.md** - Relaciones entre componentes
4. **04-PLAN-REORGANIZACION.md** - Plan de implementación paso a paso

### Continuación de esta Propuesta
5. **03-1-PROPUESTA-ARQUITECTURA-MODULAR-B.md** - Secciones 6-10 (Integración y Ejecución)
6. **03-2-PROPUESTA-ARQUITECTURA-MODULAR-C.md** - Secciones 11-17 (Escalabilidad y Buenas Prácticas)

---

**Preparado por:** Sistema de Análisis Arquitectónico  
**Fecha:** 7 de Noviembre, 2025  
**Versión:** 1.0 - Parte 1 de 3  
**Confidencialidad:** Interno - Paradise-SystemLabs
