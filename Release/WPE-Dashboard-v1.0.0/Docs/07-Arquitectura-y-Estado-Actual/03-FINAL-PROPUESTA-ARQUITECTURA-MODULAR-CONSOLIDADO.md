# 🏗️ PROPUESTA DE ARQUITECTURA MODULAR - DOCUMENTO CONSOLIDADO FINAL
## Dashboard IT - Paradise-SystemLabs

**Fecha:** 7 de Noviembre, 2025  
**Versión:** 1.0 - Consolidado Final  
**Propósito:** Definir arquitectura modular sostenible y escalable para WPE-Dashboard

**Audiencia:** Arquitectos de Software, Líderes Técnicos y Desarrolladores  
**Tiempo de lectura:** 120 minutos  
**Estado:** ✅ COMPLETADO

---

## 📌 SOBRE ESTE DOCUMENTO

Este es el **documento consolidado final** que integra las 3 partes de la propuesta arquitectónica modular:
- **Parte 1** (Secciones 1-5): Fundamentos y Arquitectura Objetivo
- **Parte 2** (Secciones 6-10): Integración y Ejecución Modular
- **Parte 3** (Secciones 11-17): Escalabilidad, Seguridad y Buenas Prácticas

**Documentos fuente:**
- `03-PROPUESTA-ARQUITECTURA-MODULAR.md`
- `03-1-PROPUESTA-ARQUITECTURA-MODULAR-B.md`
- `03-2-PROPUESTA-ARQUITECTURA-MODULAR-C.md`

---

## 📑 TABLA DE CONTENIDOS COMPLETA

### PARTE 1: FUNDAMENTOS (Secciones 1-5)
1. [Resumen Ejecutivo](#1-resumen-ejecutivo)
2. [Principios Arquitectónicos](#2-principios-arquitectonicos)
3. [Arquitectura Objetivo](#3-arquitectura-objetivo)
4. [Roles y Responsabilidades](#4-roles-y-responsabilidades)
5. [Estructura de Carpetas Detallada](#5-estructura-de-carpetas-detallada)
### 1.1 Objetivo Principal

Transformar el sistema actual de **arquitectura monolÃ­tica** (Dashboard.ps1 con 793 lÃ­neas) a una **arquitectura modular, escalable y mantenible** que permita crecimiento sostenible hasta 50+ funcionalidades sin degradaciÃ³n de calidad.

**Referencia:** SegÃºn **00-RESUMEN-EJECUTIVO.md**, el sistema actual es "funcional con Ã¡reas de mejora" y sufre de deuda tÃ©cnica arquitectÃ³nica crÃ­tica.

### 1.2 SituaciÃ³n Actual

**Problema Central** (identificado en **01-INFORME-AUDITORIA-TECNICA.md**):
- Dashboard.ps1 contiene 793 lÃ­neas con toda la lÃ³gica del sistema
- 7 funcionalidades completas embebidas inline (400+ lÃ­neas de cÃ³digo)
- Sistema modular (ScriptLoader.ps1) existe pero no se utiliza
- Carpetas estructurales (Components/, Config/, Utils/) vacÃ­as
- DuplicaciÃ³n de cÃ³digo en validaciones y operaciones

**Impacto:**
- DifÃ­cil de mantener y extender
- Imposible de testear unitariamente
- Alto riesgo de regresiones al modificar cÃ³digo
- Desarrollo colaborativo limitado (conflictos de merge)
- Cada nueva funcionalidad aumenta complejidad exponencialmente

### 1.3 SoluciÃ³n Propuesta

**Arquitectura Modular con:**

| Componente | Rol | TamaÃ±o Objetivo |
|------------|-----|-----------------|
| **Dashboard.ps1** | Orquestador | ~300 lÃ­neas (-62%) |
| **ScriptLoader.ps1** | Carga dinÃ¡mica | Integrado âœ… |
| **Components/** | UI reutilizable | 3-4 archivos |
| **Config/** | ConfiguraciÃ³n JSON | 3-4 archivos |
| **Utils/** | Utilidades compartidas | 3-4 archivos |
| **Scripts/** | Funcionalidades modulares | Ilimitado |

### 1.4 Principios Rectores

1. **SeparaciÃ³n de Responsabilidades** - Cada componente tiene un propÃ³sito Ãºnico
2. **Modularidad** - Funcionalidades independientes y reutilizables
3. **Escalabilidad** - FÃ¡cil agregar nuevas funcionalidades sin modificar core
4. **Mantenibilidad** - CÃ³digo claro, documentado y testeable
5. **Portabilidad** - Sistema funcional en cualquier ubicaciÃ³n
6. **Configurabilidad** - SeparaciÃ³n de configuraciÃ³n y cÃ³digo

### 1.5 Beneficios Esperados

| Aspecto | Antes | DespuÃ©s | Mejora |
|---------|-------|---------|--------|
| **Dashboard.ps1** | 793 lÃ­neas | ~300 lÃ­neas | -62% |
| **Funcionalidades inline** | 7 (400+ lÃ­neas) | 0 | -100% |
| **Componentes reutilizables** | 0 | 15+ | +âˆž |
| **ConfiguraciÃ³n hardcoded** | SÃ­ | No (JSON) | -100% |
| **DuplicaciÃ³n de cÃ³digo** | Alta | Baja | -80% |
| **Tiempo agregar funcionalidad** | Variable | <30 min | Consistente |
| **Testeable** | No | SÃ­ | +100% |

### 1.6 Resultado Final

Sistema modular que permite:
- âœ… Desarrollo paralelo de funcionalidades
- âœ… Testing automatizado con Pester
- âœ… Crecimiento ordenado a 50+ funcionalidades
- âœ… Mantenimiento simplificado
- âœ… Onboarding rÃ¡pido de nuevos desarrolladores
- âœ… ReducciÃ³n de bugs por separaciÃ³n de responsabilidades

---

## 2. PRINCIPIOS ARQUITECTÃ“NICOS

### 2.1 SeparaciÃ³n de Responsabilidades (SoC)

**DefiniciÃ³n:** Cada componente debe tener una Ãºnica responsabilidad bien definida.

**AplicaciÃ³n en WPE-Dashboard:**

```
Dashboard.ps1
â”œâ”€ Responsabilidad: OrquestaciÃ³n e inicializaciÃ³n
â”œâ”€ NO debe: Contener lÃ³gica de negocio
â””â”€ NO debe: Implementar validaciones especÃ­ficas

Scripts/
â”œâ”€ Responsabilidad: LÃ³gica de negocio y operaciones
â”œâ”€ NO debe: Definir UI
â””â”€ NO debe: Gestionar configuraciÃ³n global

Components/
â”œâ”€ Responsabilidad: Componentes UI reutilizables
â”œâ”€ NO debe: Contener lÃ³gica de negocio
â””â”€ NO debe: Acceder directamente a sistema operativo

Config/
â”œâ”€ Responsabilidad: ConfiguraciÃ³n del sistema
â”œâ”€ NO debe: Contener cÃ³digo ejecutable
â””â”€ NO debe: Mezclarse con lÃ³gica

Utils/
â”œâ”€ Responsabilidad: Funciones de utilidad compartidas
â”œâ”€ NO debe: Mantener estado
â””â”€ NO debe: Depender de componentes especÃ­ficos
```

### 2.2 Modularidad

**DefiniciÃ³n:** Componentes independientes que pueden desarrollarse, testearse y desplegarse por separado.

**CaracterÃ­sticas de un MÃ³dulo:**
- âœ… Interfaz clara y documentada
- âœ… Dependencias explÃ­citas
- âœ… Testeable de forma aislada
- âœ… Reutilizable en diferentes contextos
- âœ… Versionable independientemente

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
        throw "Nombre de usuario invÃ¡lido"
    }
    
    # LÃ³gica de negocio...
    
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

**DefiniciÃ³n:** Capacidad de crecer sin degradaciÃ³n de calidad o performance.

**Escalabilidad Horizontal (Agregar Funcionalidades):**
```
Agregar nueva funcionalidad:
1. Crear script en Scripts/Categoria/
2. Usar PLANTILLA-Script.ps1 como base
3. Incluir metadata completa
4. Dashboard.ps1 lo detecta automÃ¡ticamente
5. UI se genera dinÃ¡micamente

Tiempo estimado: <30 minutos
Impacto en core: CERO (no se modifica Dashboard.ps1)
```

### 2.4 Mantenibilidad

**MÃ©tricas de Mantenibilidad:**

| MÃ©trica | Objetivo | MediciÃ³n |
|---------|----------|----------|
| **Complejidad ciclomÃ¡tica** | <10 por funciÃ³n | AnÃ¡lisis estÃ¡tico |
| **LÃ­neas por archivo** | <500 | Contador |
| **Profundidad de anidamiento** | <4 niveles | RevisiÃ³n de cÃ³digo |
| **DuplicaciÃ³n de cÃ³digo** | <5% | Herramientas de anÃ¡lisis |
| **Cobertura de documentaciÃ³n** | 100% funciones pÃºblicas | RevisiÃ³n manual |

### 2.5 Portabilidad

**ImplementaciÃ³n:**

```powershell
# âœ… CORRECTO - Rutas relativas
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogsPath = Join-Path $ScriptRoot "Logs"

# âŒ INCORRECTO - Rutas absolutas
$LogsPath = "C:\WPE-Dashboard\Logs"

# âœ… CORRECTO - Variable global
$Global:DashboardRoot = $ScriptRoot
```

### 2.6 Configurabilidad

**Niveles de ConfiguraciÃ³n:**

```
1. ConfiguraciÃ³n de Sistema (dashboard-config.json)
   â”œâ”€ Puerto del servidor
   â”œâ”€ Rutas del sistema
   â””â”€ ConfiguraciÃ³n de logging

2. ConfiguraciÃ³n de Tema (theme-config.json)
   â”œâ”€ Colores
   â”œâ”€ Espaciado
   â””â”€ TipografÃ­a

3. ConfiguraciÃ³n de CategorÃ­as (categories-config.json)
   â”œâ”€ DefiniciÃ³n de categorÃ­as
   â”œâ”€ Orden de visualizaciÃ³n
   â””â”€ Iconos y descripciones
```

---

## 3. ARQUITECTURA OBJETIVO

### 3.1 Vista de Alto Nivel

**Referencia:** Basado en anÃ¡lisis de **02-MAPA-DEPENDENCIAS-Y-COMPONENTES.md**

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                    USUARIO FINAL                             â”‚
â”‚              (Navegador Web - Puerto 10000)                  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                         â”‚
                         â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚            UniversalDashboard.Community v2.9.0              â”‚
â”‚                  (Framework Web PowerShell)                  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                         â”‚
                         â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                   Dashboard.ps1 (~300 lÃ­neas)               â”‚
â”‚                    âœ… ORQUESTADOR                           â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚
â”‚  â”‚ â€¢ InicializaciÃ³n del sistema                         â”‚  â”‚
â”‚  â”‚ â€¢ Carga de configuraciÃ³n (Config/)                   â”‚  â”‚
â”‚  â”‚ â€¢ ImportaciÃ³n de mÃ³dulos (Utils/, Components/)       â”‚  â”‚
â”‚  â”‚ â€¢ IntegraciÃ³n de ScriptLoader                        â”‚  â”‚
â”‚  â”‚ â€¢ GeneraciÃ³n dinÃ¡mica de UI                          â”‚  â”‚
â”‚  â”‚ â€¢ OrquestaciÃ³n de componentes                        â”‚  â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
             â”‚            â”‚            â”‚            â”‚
    â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â–¼â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â–¼â”€â”€â”€â”€â”€â”€â”
    â”‚ Components â”‚  â”‚  Config  â”‚  â”‚  Utils  â”‚  â”‚ Scripts â”‚
    â”‚  (UI/UX)   â”‚  â”‚ (Settings)â”‚  â”‚(Helpers)â”‚  â”‚(Actions)â”‚
    â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
         â”‚               â”‚             â”‚            â”‚
         â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                         â”‚
                         â–¼
                  Sistema Operativo
                  (EjecuciÃ³n Local)
```

### 3.2 Capas de la Arquitectura

#### Capa 1: PresentaciÃ³n (UI)
```
Responsable: UniversalDashboard + Components/

Componentes:
â”œâ”€ Framework: UniversalDashboard.Community
â”œâ”€ Componentes Base: Components/UI-Components.ps1
â”œâ”€ Formularios: Components/Form-Components.ps1
â””â”€ Layouts: Components/Layout-Components.ps1

Responsabilidades:
â”œâ”€ Renderizar interfaz de usuario
â”œâ”€ Capturar entrada del usuario
â”œâ”€ Mostrar resultados y mensajes
â””â”€ Gestionar modales y toasts

NO debe:
â”œâ”€ Contener lÃ³gica de negocio
â”œâ”€ Acceder directamente a sistema operativo
â””â”€ Gestionar estado de aplicaciÃ³n
```

#### Capa 2: OrquestaciÃ³n
```
Responsable: Dashboard.ps1

Responsabilidades:
â”œâ”€ Inicializar sistema
â”œâ”€ Cargar configuraciÃ³n
â”œâ”€ Importar mÃ³dulos
â”œâ”€ Generar UI dinÃ¡micamente
â”œâ”€ Conectar UI con lÃ³gica de negocio
â”œâ”€ Gestionar ciclo de vida del dashboard
â””â”€ Coordinar componentes

NO debe:
â”œâ”€ Implementar lÃ³gica de negocio
â”œâ”€ Contener validaciones especÃ­ficas
â””â”€ Tener cÃ³digo inline de funcionalidades
```

#### Capa 3: LÃ³gica de Negocio
```
Responsable: Scripts/

Componentes:
â”œâ”€ ScriptLoader.ps1 (cargador dinÃ¡mico)
â”œâ”€ Scripts por categorÃ­a (Configuracion/, Mantenimiento/, etc.)
â””â”€ PLANTILLA-Script.ps1 (referencia)

Responsabilidades:
â”œâ”€ Implementar funcionalidades del sistema
â”œâ”€ Ejecutar operaciones de negocio
â”œâ”€ Validar reglas de negocio
â”œâ”€ Interactuar con sistema operativo
â””â”€ Retornar resultados estructurados

NO debe:
â”œâ”€ Definir UI
â”œâ”€ Gestionar configuraciÃ³n global
â””â”€ Depender de otros scripts
```

#### Capa 4: Utilidades
```
Responsable: Utils/

Componentes:
â”œâ”€ Validation-Utils.ps1 (validaciones comunes)
â”œâ”€ System-Utils.ps1 (operaciones de sistema)
â”œâ”€ Logging-Utils.ps1 (logging avanzado)
â””â”€ Security-Utils.ps1 (funciones de seguridad)

Responsabilidades:
â”œâ”€ Proporcionar funciones reutilizables
â”œâ”€ Validaciones comunes
â”œâ”€ Operaciones de sistema
â””â”€ Logging y auditorÃ­a

NO debe:
â”œâ”€ Mantener estado
â”œâ”€ Depender de componentes especÃ­ficos
â””â”€ Contener lÃ³gica de negocio
```

#### Capa 5: ConfiguraciÃ³n
```
Responsable: Config/

Componentes:
â”œâ”€ dashboard-config.json (configuraciÃ³n principal)
â”œâ”€ theme-config.json (tema y diseÃ±o)
â”œâ”€ categories-config.json (categorÃ­as de scripts)
â””â”€ Config-Loader.ps1 (cargador de configuraciÃ³n)

Responsabilidades:
â”œâ”€ Almacenar configuraciÃ³n del sistema
â”œâ”€ Definir parÃ¡metros de comportamiento
â”œâ”€ Configurar tema y diseÃ±o
â””â”€ Definir estructura de categorÃ­as

NO debe:
â”œâ”€ Contener cÃ³digo ejecutable (excepto Config-Loader.ps1)
â”œâ”€ Mezclarse con lÃ³gica
â””â”€ Ser modificado por el sistema (solo lectura)
```

### 3.3 Flujo de Datos

```
1. Inicio
   Usuario â†’ Iniciar-Dashboard.bat â†’ Dashboard.ps1

2. InicializaciÃ³n
   Dashboard.ps1 â†’ Verificar UniversalDashboard
                 â†’ Crear carpetas (Logs/, Backup/)
                 â†’ Liberar puerto 10000

3. Carga de ConfiguraciÃ³n
   Dashboard.ps1 â†’ Config-Loader.ps1 â†’ dashboard-config.json
                                      â†’ theme-config.json
                                      â†’ categories-config.json

4. ImportaciÃ³n de MÃ³dulos
   Dashboard.ps1 â†’ Utils/*.ps1
                 â†’ Components/*.ps1
                 â†’ ScriptLoader.ps1

5. GeneraciÃ³n de UI
   Dashboard.ps1 â†’ ScriptLoader.Get-ScriptsByCategory()
                 â†’ Components.New-CustomButton()
                 â†’ New-UDDashboard

6. EjecuciÃ³n de Funcionalidad
   Usuario â†’ BotÃ³n â†’ Dashboard.ps1 â†’ ScriptLoader.Invoke-DashboardScript()
                                    â†’ Scripts/Categoria/Script.ps1
                                    â†’ Utils/*.ps1 (validaciones)
                                    â†’ Sistema Operativo
                                    â†’ Retorno de resultado
                                    â†’ Show-UDToast (feedback)
```

---

## 4. ROLES Y RESPONSABILIDADES

### 4.1 Dashboard.ps1 - Orquestador Principal

**Rol:** Punto de entrada y coordinador del sistema

**TamaÃ±o Objetivo:** ~300 lÃ­neas (vs. 793 actual = -62%)

**Estructura Propuesta:**

```powershell
# ============================================
# DASHBOARD.PS1 - ORQUESTADOR PRINCIPAL
# ============================================

# SECCIÃ“N 1: INICIALIZACIÃ“N (50 lÃ­neas)
# â€¢ Detectar ubicaciÃ³n del script ($ScriptRoot)
# â€¢ Definir variable global $Global:DashboardRoot
# â€¢ Verificar/Instalar UniversalDashboard
# â€¢ Gestionar puerto 10000
# â€¢ Crear carpetas necesarias (Logs/, Backup/)

# SECCIÃ“N 2: CARGA DE CONFIGURACIÃ“N (30 lÃ­neas)
# â€¢ Importar Config-Loader.ps1
# â€¢ Cargar dashboard-config.json
# â€¢ Cargar theme-config.json
# â€¢ Cargar categories-config.json
# â€¢ Validar configuraciÃ³n

# SECCIÃ“N 3: IMPORTACIÃ“N DE MÃ“DULOS (40 lÃ­neas)
# â€¢ Importar Utils/Validation-Utils.ps1
# â€¢ Importar Utils/System-Utils.ps1
# â€¢ Importar Utils/Logging-Utils.ps1
# â€¢ Importar Components/UI-Components.ps1
# â€¢ Importar Components/Form-Components.ps1
# â€¢ Importar Scripts/ScriptLoader.ps1
# â€¢ Inicializar ScriptLoader

# SECCIÃ“N 4: GENERACIÃ“N DE UI (150 lÃ­neas)
# â€¢ Crear dashboard con New-UDDashboard
# â€¢ Generar tarjeta de informaciÃ³n del sistema
# â€¢ Para cada categorÃ­a:
#   - Obtener scripts con Get-ScriptsByCategory()
#   - Crear secciÃ³n de categorÃ­a
#   - Generar botones dinÃ¡micamente
# â€¢ Agregar secciones fijas

# SECCIÃ“N 5: INICIO DEL SERVIDOR (30 lÃ­neas)
# â€¢ Logging de inicio
# â€¢ Start-UDDashboard -Port $config.server.port
# â€¢ Mostrar informaciÃ³n de acceso
```

**Lo que NO debe hacer:**
- âŒ Implementar funcionalidades inline
- âŒ Contener validaciones especÃ­ficas
- âŒ Tener lÃ³gica de negocio embebida
- âŒ Hardcodear configuraciÃ³n
- âŒ Duplicar cÃ³digo

### 4.2 Components/ - Componentes UI Reutilizables

**Rol:** Biblioteca de componentes de interfaz

**Archivos Propuestos:**

#### Components/UI-Components.ps1
```
Funciones:
â”œâ”€ New-CustomCard($Title, $Content, $Style)
â”œâ”€ New-CustomButton($Text, $OnClick, $Type)
â”œâ”€ New-InfoBanner($Message, $Type)
â””â”€ New-LoadingSpinner($Message)

PropÃ³sito: Componentes base con estilo consistente del tema
```

#### Components/Form-Components.ps1
```
Funciones:
â”œâ”€ New-GenericForm($Title, $Fields, $OnSubmit)
â”œâ”€ New-ValidationMessage($Message, $Type)
â””â”€ New-ConfirmDialog($Title, $Message, $OnConfirm)

PropÃ³sito: Formularios y diÃ¡logos reutilizables
```

#### Components/Layout-Components.ps1
```
Funciones:
â”œâ”€ New-TwoColumnLayout($LeftContent, $RightContent)
â”œâ”€ New-ThreeColumnLayout($Content1, $Content2, $Content3)
â””â”€ New-CategorySection($CategoryName, $Scripts)

PropÃ³sito: Layouts responsive y estructuras
```

### 4.3 Config/ - ConfiguraciÃ³n Centralizada

**Rol:** Almacenar toda la configuraciÃ³n del sistema

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
      "title": "CONFIGURACIÃ“N INICIAL",
      "icon": "âš™ï¸",
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

**Rol:** Implementar lÃ³gica de negocio

**Estructura:**
```
Scripts/
â”œâ”€ ScriptLoader.ps1 (cargador dinÃ¡mico)
â”œâ”€ PLANTILLA-Script.ps1 (template)
â”œâ”€ Configuracion/
â”‚  â”œâ”€ Cambiar-Nombre-PC.ps1
â”‚  â””â”€ Crear-Usuario-Sistema.ps1
â”œâ”€ Mantenimiento/
â”‚  â””â”€ Limpiar-Archivos-Temporales.ps1
â””â”€ [otras categorÃ­as]/
```

**Contrato de Script:**
```powershell
# Metadata obligatoria
# @Name: Nombre descriptivo
# @Description: QuÃ© hace el script
# @RequiresAdmin: true/false
# @HasForm: true/false
# @FormField: campo|placeholder|tipo

param(...)  # ParÃ¡metros tipados

# Importar utilidades necesarias
. "$PSScriptRoot\..\..\Utils\*.ps1"

try {
    # LÃ³gica de negocio
    return @{
        Success = $true
        Message = "Mensaje de Ã©xito"
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

**Rol:** Utilidades independientes para administraciÃ³n

**Archivos Existentes:**
- `Detener-Dashboard.ps1` - Detiene dashboards en ejecuciÃ³n
- `Limpiar-Puerto-10000.ps1` - Libera puerto manualmente
- `Abrir-Navegador.ps1` - Abre navegador en localhost:10000
- `Eliminar-Usuario.ps1` - Elimina usuario local

**CaracterÃ­sticas:**
- Ejecutables independientemente
- No dependen de Dashboard.ps1
- Ãštiles para troubleshooting

### 4.7 Docs/ - DocumentaciÃ³n

**Rol:** DocumentaciÃ³n completa del proyecto

**Estado:** âœ… Excelente (20+ documentos organizados)

**Mantenimiento:** Actualizar cuando cambie arquitectura

---

## 5. ESTRUCTURA DE CARPETAS DETALLADA

### 5.1 Ãrbol Completo de Carpetas

```
WPE-Dashboard/
â”‚
â”œâ”€â”€ Dashboard.ps1                    # âœ… Orquestador principal (~300 lÃ­neas)
â”œâ”€â”€ Iniciar-Dashboard.bat            # âœ… Lanzador con permisos admin
â”œâ”€â”€ Instalar-Dependencias.bat        # âœ… Instalador automÃ¡tico
â”œâ”€â”€ Instalar-Dependencias.ps1        # âœ… Script de instalaciÃ³n
â”œâ”€â”€ README.md                        # âœ… DocumentaciÃ³n principal
â”œâ”€â”€ CHANGELOG.md                     # âœ… Historial de cambios
â”œâ”€â”€ CLAUDE.md                        # âœ… Notas de desarrollo
â”‚
â”œâ”€â”€ Components/                      # ðŸ†• Componentes UI reutilizables
â”‚   â”œâ”€â”€ UI-Components.ps1            # Componentes base (cards, buttons, banners)
â”‚   â”œâ”€â”€ Form-Components.ps1          # Formularios y validaciones
â”‚   â””â”€â”€ Layout-Components.ps1        # Layouts responsive
â”‚
â”œâ”€â”€ Config/                          # ðŸ†• ConfiguraciÃ³n centralizada
â”‚   â”œâ”€â”€ dashboard-config.json        # ConfiguraciÃ³n principal del sistema
â”‚   â”œâ”€â”€ theme-config.json            # Colores, espaciado, tipografÃ­a
â”‚   â”œâ”€â”€ categories-config.json       # DefiniciÃ³n de categorÃ­as de scripts
â”‚   â””â”€â”€ Config-Loader.ps1            # Funciones para cargar configuraciÃ³n
â”‚
â”œâ”€â”€ Utils/                           # ðŸ†• Utilidades compartidas
â”‚   â”œâ”€â”€ Validation-Utils.ps1         # Validaciones comunes (username, password, etc.)
â”‚   â”œâ”€â”€ System-Utils.ps1             # Operaciones de sistema (users, PC info, etc.)
â”‚   â”œâ”€â”€ Logging-Utils.ps1            # Sistema de logging avanzado
â”‚   â””â”€â”€ Security-Utils.ps1           # Funciones de seguridad
â”‚
â”œâ”€â”€ Scripts/                         # âœ… Scripts de automatizaciÃ³n
â”‚   â”œâ”€â”€ ScriptLoader.ps1             # âœ… Cargador dinÃ¡mico (mejorado)
â”‚   â”œâ”€â”€ PLANTILLA-Script.ps1         # âœ… Template para nuevos scripts
â”‚   â”‚
â”‚   â”œâ”€â”€ Configuracion/               # Scripts de configuraciÃ³n inicial
â”‚   â”‚   â”œâ”€â”€ Cambiar-Nombre-PC.ps1
â”‚   â”‚   â””â”€â”€ Crear-Usuario-Sistema.ps1
â”‚   â”‚
â”‚   â”œâ”€â”€ Mantenimiento/               # Scripts de mantenimiento
â”‚   â”‚   â””â”€â”€ Limpiar-Archivos-Temporales.ps1
â”‚   â”‚
â”‚   â”œâ”€â”€ POS/                         # Scripts de punto de venta
â”‚   â”‚   â”œâ”€â”€ Crear-Usuario-POS.ps1
â”‚   â”‚   â””â”€â”€ Crear-Usuario.ps1
â”‚   â”‚
â”‚   â”œâ”€â”€ Diseno/                      # Scripts de diseÃ±o grÃ¡fico
â”‚   â”œâ”€â”€ Atencion-Al-Cliente/         # Scripts de atenciÃ³n al cliente
â”‚   â””â”€â”€ Auditoria/                   # Scripts de auditorÃ­a
â”‚
â”œâ”€â”€ Tools/                           # âœ… Herramientas de mantenimiento
â”‚   â”œâ”€â”€ Abrir-Navegador.ps1
â”‚   â”œâ”€â”€ Detener-Dashboard.ps1
â”‚   â”œâ”€â”€ Eliminar-Usuario.ps1
â”‚   â”œâ”€â”€ Limpiar-Puerto-10000.ps1
â”‚   â””â”€â”€ Verificar-Sistema.ps1
â”‚
â”œâ”€â”€ Docs/                            # âœ… DocumentaciÃ³n completa
â”‚   â”œâ”€â”€ 00-INDICE-MAESTRO.md
â”‚   â”œâ”€â”€ Arquitectura-y-Estado-Actual/
â”‚   â””â”€â”€ [otras carpetas de documentaciÃ³n]
â”‚
â”œâ”€â”€ Logs/                            # âœ… Logs automÃ¡ticos (auto-creada)
â”‚   â””â”€â”€ dashboard-YYYY-MM.log
â”‚
â”œâ”€â”€ Backup/                          # âœ… Backups del sistema (auto-creada)
â””â”€â”€ Temp/                            # âœ… Archivos temporales (auto-creada)
```

### 5.2 Convenciones de Nombres

#### Archivos PowerShell
```
Formato: PascalCase-Con-Guiones.ps1

Ejemplos:
âœ… Crear-Usuario-Sistema.ps1
âœ… Cambiar-Nombre-PC.ps1
âœ… Limpiar-Archivos-Temporales.ps1

âŒ crear_usuario.ps1
âŒ CrearUsuario.ps1
âŒ crear-usuario-sistema.ps1
```

#### Archivos JSON
```
Formato: kebab-case.json

Ejemplos:
âœ… dashboard-config.json
âœ… theme-config.json
âœ… categories-config.json

âŒ DashboardConfig.json
âŒ dashboard_config.json
```

#### Funciones PowerShell
```
Formato: Verb-Noun (PowerShell estÃ¡ndar)

Ejemplos:
âœ… Test-AdminPrivileges
âœ… Get-FilteredLocalUsers
âœ… New-CustomButton

âŒ CheckAdmin
âŒ getUsers
âŒ createButton
```

### 5.3 TamaÃ±os Objetivo por Componente

| Componente | Archivos | LÃ­neas Totales | Estado |
|------------|----------|----------------|--------|
| **Dashboard.ps1** | 1 | ~300 | Refactorizar |
| **Components/** | 3 | ~400 | Crear |
| **Config/** | 4 | ~200 | Crear |
| **Utils/** | 4 | ~400 | Crear |
| **Scripts/** | 5+ | Ilimitado | Usar existentes |
| **Tools/** | 5 | ~200 | âœ… Mantener |
| **Docs/** | 20+ | N/A | âœ… Mantener |

**Total estimado:** ~1,900 lÃ­neas (vs. ~1,500 actual)

**Nota:** Aunque el total aumenta ligeramente, el cÃ³digo estÃ¡ mejor organizado, es mÃ¡s mantenible y escalable.

### 5.4 Dependencias entre Carpetas

```
Dashboard.ps1
â”œâ”€ Depende de: Config/, Utils/, Components/, Scripts/
â””â”€ No depende de: Tools/, Docs/

Components/
â”œâ”€ Depende de: Config/ (para tema)
â””â”€ No depende de: Scripts/, Utils/

Config/
â””â”€ No depende de: Ninguna (solo lectura)

Utils/
â”œâ”€ Depende de: Config/ (para logging config)
â””â”€ No depende de: Components/, Scripts/

Scripts/
â”œâ”€ Depende de: Utils/ (validaciones, logging)
â””â”€ No depende de: Components/, Dashboard.ps1

Tools/
â”œâ”€ Puede depender de: Utils/ (opcional)
â””â”€ No depende de: Dashboard.ps1, Components/
```

### 5.5 Archivos CrÃ­ticos

**Archivos que NO deben modificarse sin planificaciÃ³n:**
1. `Dashboard.ps1` - Core del sistema
2. `Scripts/ScriptLoader.ps1` - Cargador dinÃ¡mico
3. `Scripts/PLANTILLA-Script.ps1` - Template de referencia
4. `Config/*.json` - ConfiguraciÃ³n del sistema

**Archivos seguros para modificar:**
1. Scripts individuales en `Scripts/Categoria/`
2. DocumentaciÃ³n en `Docs/`
3. Herramientas en `Tools/`

---

## ðŸ“¦ ENTREGA A - COMPLETADA

### Cambios en esta Entrega

**Secciones Completadas:**
1. âœ… **Resumen Ejecutivo** - Objetivo, situaciÃ³n actual, soluciÃ³n propuesta, beneficios
2. âœ… **Principios ArquitectÃ³nicos** - 6 principios fundamentales con ejemplos
3. âœ… **Arquitectura Objetivo** - Vista de alto nivel, capas, flujo de datos
4. âœ… **Roles y Responsabilidades** - DefiniciÃ³n detallada de cada componente
5. âœ… **Estructura de Carpetas Detallada** - Ãrbol completo, convenciones, tamaÃ±os

**Contenido Generado:**
- Diagramas ASCII de arquitectura
- Ejemplos de cÃ³digo PowerShell
- Estructuras JSON de configuraciÃ³n
- Tablas comparativas
- Convenciones de nombres

**Referencias a Documentos Base:**
- **00-RESUMEN-EJECUTIVO.md** - Estado actual y problemas crÃ­ticos
- **01-INFORME-AUDITORIA-TECNICA.md** - AnÃ¡lisis detallado de Dashboard.ps1
- **02-MAPA-DEPENDENCIAS-Y-COMPONENTES.md** - Relaciones entre componentes

**ContinuaciÃ³n:**
- Ver **03-1-PROPUESTA-ARQUITECTURA-MODULAR-B.md** para secciones 6-10
- Ver **03-2-PROPUESTA-ARQUITECTURA-MODULAR-C.md** para secciones 11-17

---

## DOCUMENTOS RELACIONADOS

### Documentos de AuditorÃ­a Base
1. **00-RESUMEN-EJECUTIVO.md** - VisiÃ³n general de auditorÃ­a
2. **01-INFORME-AUDITORIA-TECNICA.md** - AnÃ¡lisis tÃ©cnico detallado
3. **02-MAPA-DEPENDENCIAS-Y-COMPONENTES.md** - Relaciones entre componentes
4. **04-PLAN-REORGANIZACION.md** - Plan de implementaciÃ³n paso a paso

### ContinuaciÃ³n de esta Propuesta
5. **03-1-PROPUESTA-ARQUITECTURA-MODULAR-B.md** - Secciones 6-10 (IntegraciÃ³n y EjecuciÃ³n)
6. **03-2-PROPUESTA-ARQUITECTURA-MODULAR-C.md** - Secciones 11-17 (Escalabilidad y Buenas PrÃ¡cticas)

---

**Preparado por:** Sistema de AnÃ¡lisis ArquitectÃ³nico  
**Fecha:** 7 de Noviembre, 2025  
**VersiÃ³n:** 1.0 - Parte 1 de 3  
**Confidencialidad:** Interno - Paradise-SystemLabs
# ðŸ—ï¸ PROPUESTA DE ARQUITECTURA MODULAR - PARTE 2
## Dashboard IT - Paradise-SystemLabs

**Fecha:** 7 de Noviembre, 2025  
**VersiÃ³n:** 1.0 - Parte 2 de 3  
**PropÃ³sito:** IntegraciÃ³n, EjecuciÃ³n y Convenciones del Sistema Modular

**Audiencia:** Arquitectos de Software, LÃ­deres TÃ©cnicos y Desarrolladores  
**Tiempo de lectura:** 40 minutos

---

## ðŸ“Œ NOTA DE CONTINUIDAD

Este documento es la **continuaciÃ³n** de:
- **03-PROPUESTA-ARQUITECTURA-MODULAR.md** (Secciones 1-5)

Para contexto completo, leer primero el documento 03 que contiene:
1. Resumen Ejecutivo
2. Principios ArquitectÃ³nicos
3. Arquitectura Objetivo
4. Roles y Responsabilidades
5. Estructura de Carpetas Detallada

**Siguiente documento:**
- **03-2-PROPUESTA-ARQUITECTURA-MODULAR-C.md** (Secciones 11-17)

---

## ðŸ“‘ TABLA DE CONTENIDOS

### Secciones en este Documento (6-10)
6. [IntegraciÃ³n de ScriptLoader](#6-integracion-de-scriptloader)
7. [GeneraciÃ³n DinÃ¡mica de UI](#7-generacion-dinamica-de-ui)
8. [Flujo de EjecuciÃ³n Modular](#8-flujo-de-ejecucion-modular)
9. [Convenciones y EstÃ¡ndares](#9-convenciones-y-estandares)
10. [SeparaciÃ³n de Responsabilidades](#10-separacion-de-responsabilidades)

---

## 6. INTEGRACIÃ“N DE SCRIPTLOADER

### 6.1 Estado Actual del ScriptLoader

**Referencia:** SegÃºn **01-INFORME-AUDITORIA-TECNICA.md**, el ScriptLoader.ps1 existe pero no estÃ¡ integrado con Dashboard.ps1.

**UbicaciÃ³n:** `Scripts/ScriptLoader.ps1`

**Funciones Existentes:**
```powershell
function Get-ScriptsByCategory($Category) { ... }
function Get-ScriptMetadata($ScriptPath) { ... }
$Global:DashboardCategories = @{ ... }
```

**Problema:** Dashboard.ps1 no importa ni utiliza estas funciones.

### 6.2 API MÃ­nima del ScriptLoader

**Funciones Requeridas:**

#### Get-ScriptsByCategory
```powershell
function Get-ScriptsByCategory {
    param([Parameter(Mandatory=$true)][string]$Category)
    
    $categoryPath = Join-Path $Global:DashboardRoot "Scripts\$Category"
    
    if (-not (Test-Path $categoryPath)) {
        return @()
    }
    
    $scripts = Get-ChildItem -Path $categoryPath -Filter "*.ps1" -File | 
        Where-Object { 
            $_.Name -ne "ScriptLoader.ps1" -and 
            $_.Name -ne "PLANTILLA-Script.ps1" 
        }
    
    return $scripts
}
```

#### Get-ScriptMetadata
```powershell
function Get-ScriptMetadata {
    param([Parameter(Mandatory=$true)][string]$ScriptPath)
    
    $content = Get-Content $ScriptPath -TotalCount 30
    
    $metadata = @{
        Name = [System.IO.Path]::GetFileNameWithoutExtension($ScriptPath)
        Description = "Sin descripciÃ³n"
        RequiresAdmin = $false
        HasForm = $false
        FormFields = @()
    }
    
    foreach ($line in $content) {
        if ($line -match "^#\s*@Name:\s*(.+)$") {
            $metadata.Name = $matches[1].Trim()
        }
        elseif ($line -match "^#\s*@Description:\s*(.+)$") {
            $metadata.Description = $matches[1].Trim()
        }
        elseif ($line -match "^#\s*@RequiresAdmin:\s*(true|false)$") {
            $metadata.RequiresAdmin = $matches[1] -eq "true"
        }
        elseif ($line -match "^#\s*@HasForm:\s*(true|false)$") {
            $metadata.HasForm = $matches[1] -eq "true"
        }
        elseif ($line -match "^#\s*@FormField:\s*(.+)$") {
            $fieldDef = $matches[1].Trim()
            $parts = $fieldDef -split '\|'
            if ($parts.Count -eq 3) {
                $metadata.FormFields += @{
                    Name = $parts[0].Trim()
                    Placeholder = $parts[1].Trim()
                    Type = $parts[2].Trim()
                }
            }
        }
    }
    
    return $metadata
}
```

#### Invoke-DashboardScript
```powershell
function Invoke-DashboardScript {
    param(
        [Parameter(Mandatory=$true)][string]$ScriptPath,
        [Parameter(Mandatory=$false)][hashtable]$Parameters = @{}
    )
    
    try {
        if (-not (Test-Path $ScriptPath)) {
            throw "Script no encontrado: $ScriptPath"
        }
        
        $result = & $ScriptPath @Parameters
        
        if ($result -isnot [hashtable] -or 
            -not $result.ContainsKey("Success") -or 
            -not $result.ContainsKey("Message")) {
            throw "El script no retornÃ³ formato vÃ¡lido"
        }
        
        return $result
        
    } catch {
        Write-DashboardLog -Message "Error ejecutando script: $_" -Level "Error"
        return @{
            Success = $false
            Message = "Error: $_"
        }
    }
}
```

### 6.3 IntegraciÃ³n con Dashboard.ps1

**Paso 1: Importar ScriptLoader**

```powershell
# En Dashboard.ps1, despuÃ©s de importar Utils/ y Components/
$scriptLoaderPath = Join-Path $Global:DashboardRoot "Scripts\ScriptLoader.ps1"
if (Test-Path $scriptLoaderPath) {
    . $scriptLoaderPath
    Write-Host "âœ… ScriptLoader importado" -ForegroundColor Green
} else {
    Write-Host "âŒ ScriptLoader no encontrado" -ForegroundColor Red
    exit 1
}
```

**Paso 2: Cargar CategorÃ­as desde Config**

```powershell
$categoriesConfig = Load-CategoriesConfig

foreach ($category in $categoriesConfig.categories | Sort-Object order) {
    $scripts = Get-ScriptsByCategory -Category $category.path
    
    if ($scripts.Count -gt 0) {
        # Generar secciÃ³n de UI para esta categorÃ­a
    }
}
```

**Paso 3: Usar en Botones**

```powershell
New-CustomButton -Text $metadata.Name -OnClick {
    $result = Invoke-DashboardScript -ScriptPath $scriptPath -Parameters $params
    
    if ($result.Success) {
        Show-UDToast -Message $result.Message -BackgroundColor "green"
    } else {
        Show-UDToast -Message $result.Message -BackgroundColor "red"
    }
}
```

### 6.4 ValidaciÃ³n de Scripts

```powershell
function Test-ScriptValid {
    param([string]$ScriptPath)
    
    $metadata = Get-ScriptMetadata -ScriptPath $ScriptPath
    
    if ([string]::IsNullOrWhiteSpace($metadata.Name)) {
        Write-Warning "Script sin @Name: $ScriptPath"
        return $false
    }
    
    if ([string]::IsNullOrWhiteSpace($metadata.Description)) {
        Write-Warning "Script sin @Description: $ScriptPath"
        return $false
    }
    
    if ($metadata.HasForm -and $metadata.FormFields.Count -eq 0) {
        Write-Warning "Script con @HasForm:true pero sin @FormField: $ScriptPath"
        return $false
    }
    
    return $true
}
```

---

## 7. GENERACIÃ“N DINÃMICA DE UI

### 7.1 Concepto de UI DinÃ¡mica

**Objetivo:** Generar botones y formularios automÃ¡ticamente basÃ¡ndose en metadata de scripts.

**Beneficios:**
- âœ… Agregar funcionalidad = crear script con metadata
- âœ… No modificar Dashboard.ps1
- âœ… UI consistente automÃ¡ticamente
- âœ… Menos cÃ³digo duplicado

### 7.2 GeneraciÃ³n de Botones por Metadata

**FunciÃ³n en Components/UI-Components.ps1:**

```powershell
function New-ScriptButton {
    param(
        [Parameter(Mandatory=$true)][hashtable]$Metadata,
        [Parameter(Mandatory=$true)][string]$ScriptPath
    )
    
    # Determinar tipo de botÃ³n segÃºn permisos
    $buttonType = if ($Metadata.RequiresAdmin) { "warning" } else { "primary" }
    $buttonText = $Metadata.Name
    if ($Metadata.RequiresAdmin) {
        $buttonText = "ðŸ”’ $buttonText"
    }
    
    New-CustomButton -Text $buttonText -Type $buttonType -FullWidth -OnClick {
        $Session:CurrentScriptPath = $ScriptPath
        $Session:CurrentMetadata = $Metadata
        
        if ($Metadata.HasForm) {
            Show-UDModal -Content {
                New-ScriptForm -Metadata $Metadata -ScriptPath $ScriptPath
            }
        } else {
            $result = Invoke-DashboardScript -ScriptPath $ScriptPath
            
            if ($result.Success) {
                Show-UDToast -Message $result.Message -BackgroundColor "green"
            } else {
                Show-UDToast -Message $result.Message -BackgroundColor "red"
            }
        }
    }
}
```

### 7.3 GeneraciÃ³n de Formularios DinÃ¡micos

**FunciÃ³n en Components/Form-Components.ps1:**

```powershell
function New-ScriptForm {
    param(
        [Parameter(Mandatory=$true)][hashtable]$Metadata,
        [Parameter(Mandatory=$true)][string]$ScriptPath
    )
    
    New-UDCard -Title $Metadata.Name -Content {
        # DescripciÃ³n
        New-UDElement -Tag "p" -Content $Metadata.Description
        
        # Generar campos dinÃ¡micamente
        foreach ($field in $Metadata.FormFields) {
            switch ($field.Type) {
                "textbox" {
                    New-UDTextbox -Id $field.Name -Label $field.Placeholder
                }
                "password" {
                    New-UDTextbox -Id $field.Name -Label $field.Placeholder -Type "password"
                }
                "select" {
                    New-UDSelect -Id $field.Name -Label $field.Placeholder
                }
            }
        }
        
        # Botones de acciÃ³n
        New-UDButton -Text "Ejecutar" -OnClick {
            # Recolectar valores
            $params = @{}
            foreach ($field in $Metadata.FormFields) {
                $value = (Get-UDElement -Id $field.Name).Attributes.value
                $params[$field.Name] = $value
            }
            
            # Ejecutar script
            $result = Invoke-DashboardScript -ScriptPath $ScriptPath -Parameters $params
            
            Hide-UDModal
            
            if ($result.Success) {
                Show-UDToast -Message $result.Message -BackgroundColor "green"
            } else {
                Show-UDToast -Message $result.Message -BackgroundColor "red"
            }
        }
        
        New-UDButton -Text "Cancelar" -OnClick {
            Hide-UDModal
        }
    }
}
```

### 7.4 GeneraciÃ³n de Secciones por CategorÃ­a

**En Dashboard.ps1:**

```powershell
$categoriesConfig = Load-CategoriesConfig

foreach ($category in $categoriesConfig.categories | Sort-Object order) {
    $scripts = Get-ScriptsByCategory -Category $category.path
    
    if ($scripts.Count -eq 0) {
        continue
    }
    
    # Crear secciÃ³n para categorÃ­a
    New-CategorySection -CategoryName $category.title -Icon $category.icon -Content {
        
        foreach ($script in $scripts) {
            $metadata = Get-ScriptMetadata -ScriptPath $script.FullName
            
            if (-not (Test-ScriptValid -ScriptPath $script.FullName)) {
                continue
            }
            
            New-ScriptButton -Metadata $metadata -ScriptPath $script.FullName
        }
    }
}
```

### 7.5 Ejemplo Completo

**Metadata en Script:**
```powershell
# @Name: Crear Usuario del Sistema
# @Description: Crea un usuario local de Windows
# @RequiresAdmin: true
# @HasForm: true
# @FormField: nombreUsuario|Nombre del usuario|textbox
# @FormField: password|ContraseÃ±a|password
# @FormField: tipoUsuario|Tipo de usuario|select
```

**UI Generada AutomÃ¡ticamente:**
```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ ðŸ”’ Crear Usuario del Sistema        â”‚  â† BotÃ³n generado
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
         â”‚ (Click)
         â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Crear Usuario del Sistema           â”‚  â† Modal generado
â”‚                                     â”‚
â”‚ Crea un usuario local de Windows   â”‚  â† DescripciÃ³n
â”‚                                     â”‚
â”‚ [Nombre del usuario        ]        â”‚  â† Campo textbox
â”‚ [ContraseÃ±a (oculta)       ]        â”‚  â† Campo password
â”‚ [Tipo de usuario â–¼         ]        â”‚  â† Campo select
â”‚                                     â”‚
â”‚ [Ejecutar]  [Cancelar]              â”‚  â† Botones
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

---

## 8. FLUJO DE EJECUCIÃ“N MODULAR

### 8.1 Flujo Completo End-to-End

**Diagrama de Secuencia:**

```
Usuario â†’ Dashboard.ps1 â†’ ScriptLoader â†’ Script Modular â†’ Utils/ â†’ Sistema OS

1. Usuario abre navegador (localhost:10000)
   â†“
2. Dashboard.ps1 inicia
   â”œâ”€ Cargar Config/*.json
   â”œâ”€ Importar Utils/*.ps1
   â”œâ”€ Importar Components/*.ps1
   â””â”€ Importar ScriptLoader.ps1
   â†“
3. Descubrimiento de scripts
   â”œâ”€ Para cada categorÃ­a:
   â”‚  â”œâ”€ Get-ScriptsByCategory($category)
   â”‚  â””â”€ Get-ScriptMetadata($script)
   â””â”€ Almacenar en cachÃ©
   â†“
4. GeneraciÃ³n de UI
   â”œâ”€ Para cada categorÃ­a con scripts:
   â”‚  â”œâ”€ New-CategorySection($category)
   â”‚  â””â”€ Para cada script:
   â”‚     â””â”€ New-ScriptButton($metadata)
   â””â”€ Start-UDDashboard
   â†“
5. Usuario hace click en botÃ³n
   â†“
6. Si HasForm = true:
   â”œâ”€ Show-UDModal(New-ScriptForm($metadata))
   â”œâ”€ Usuario llena formulario
   â””â”€ Click en "Ejecutar"
   â†“
7. Invoke-DashboardScript($scriptPath, $params)
   â”œâ”€ Validar script existe
   â”œâ”€ Ejecutar: & $scriptPath @params
   â””â”€ Validar respuesta
   â†“
8. Script modular ejecuta
   â”œâ”€ Importar Utils/*.ps1
   â”œâ”€ Validar parÃ¡metros (Utils/Validation-Utils.ps1)
   â”œâ”€ Ejecutar lÃ³gica de negocio
   â”œâ”€ Interactuar con Sistema OS
   â”œâ”€ Logging (Utils/Logging-Utils.ps1)
   â””â”€ Retornar @{ Success, Message, Data }
   â†“
9. Dashboard.ps1 recibe resultado
   â”œâ”€ Hide-UDModal (si habÃ­a modal)
   â””â”€ Show-UDToast($result.Message)
   â†“
10. Usuario ve notificaciÃ³n de resultado
```

### 8.2 Manejo de Errores

**Puntos de Fallo y Manejo:**

```
1. Script no encontrado
   â””â”€ Catch en Invoke-DashboardScript
      â””â”€ Retornar @{ Success = $false; Message = "Script no encontrado" }

2. Metadata invÃ¡lida
   â””â”€ ValidaciÃ³n en Test-ScriptValid
      â””â”€ No generar botÃ³n para ese script

3. Error en ejecuciÃ³n del script
   â””â”€ Try/Catch en el script modular
      â””â”€ Retornar @{ Success = $false; Message = "Error: ..." }

4. ParÃ¡metros faltantes
   â””â”€ [Parameter(Mandatory=$true)] en script
      â””â”€ PowerShell lanza error
         â””â”€ Catch en Invoke-DashboardScript

5. Permisos insuficientes
   â””â”€ Test-AdminPrivileges en script
      â””â”€ Retornar @{ Success = $false; Message = "Requiere admin" }
```

### 8.3 Logging del Flujo

**Puntos de Logging:**

```powershell
# 1. Inicio del dashboard
Write-DashboardLog -Message "Dashboard iniciado" -Level "Info"

# 2. Carga de scripts
Write-DashboardLog -Message "Cargados $($scripts.Count) scripts" -Level "Info"

# 3. EjecuciÃ³n de script
Write-DashboardLog -Message "Ejecutando: $scriptPath" -Level "Info"

# 4. Resultado
if ($result.Success) {
    Write-DashboardLog -Message "Ã‰xito: $($result.Message)" -Level "Info"
} else {
    Write-DashboardLog -Message "Error: $($result.Message)" -Level "Error"
}
```

---

## 9. CONVENCIONES Y ESTÃNDARES

### 9.1 Convenciones de Nombres

#### Scripts PowerShell
```
Formato: Verbo-Sustantivo-Complemento.ps1 (PascalCase con guiones)

Verbos recomendados:
- Crear-*
- Cambiar-*
- Eliminar-*
- Obtener-*
- Limpiar-*
- Verificar-*
- Configurar-*

Ejemplos correctos:
âœ… Crear-Usuario-Sistema.ps1
âœ… Cambiar-Nombre-PC.ps1
âœ… Limpiar-Archivos-Temporales.ps1
âœ… Obtener-Info-Sistema.ps1

Ejemplos incorrectos:
âŒ crear_usuario.ps1
âŒ CrearUsuario.ps1
âŒ crear-usuario-sistema.ps1
```

#### Funciones PowerShell
```
Formato: Verb-Noun (PowerShell estÃ¡ndar)

Ejemplos:
âœ… Test-AdminPrivileges
âœ… Get-FilteredLocalUsers
âœ… New-CustomButton
âœ… Write-DashboardLog

âŒ CheckAdmin
âŒ getUsers
âŒ createButton
```

#### Archivos JSON
```
Formato: kebab-case.json

Ejemplos:
âœ… dashboard-config.json
âœ… theme-config.json
âœ… categories-config.json

âŒ DashboardConfig.json
âŒ dashboard_config.json
```

#### Variables
```
Formato: $camelCase o $PascalCase

Variables locales:
$nombreUsuario
$scriptPath
$metadata

Variables globales:
$Global:DashboardRoot
$Global:LoadedScripts
$Global:ThemeConfig
```

### 9.2 EstÃ¡ndares de Metadata

**Metadata Obligatoria:**
```powershell
# @Name: Nombre descriptivo del script
# @Description: QuÃ© hace el script (1-2 lÃ­neas)
# @RequiresAdmin: true/false
# @HasForm: true/false
```

**Metadata Opcional:**
```powershell
# @Category: Configuracion (si no estÃ¡ en carpeta de categorÃ­a)
# @Version: 1.0
# @Author: Nombre del desarrollador
# @LastModified: 2025-11-07
```

**Metadata de Formulario:**
```powershell
# @FormField: nombreCampo|Placeholder|tipo
# Tipos vÃ¡lidos: textbox, password, select, checkbox
```

### 9.3 EstÃ¡ndares de CÃ³digo

**Estructura de Script Modular:**
```powershell
# ============================================
# NOMBRE DEL SCRIPT
# ============================================
# Metadata
# @Name: ...
# @Description: ...
# @RequiresAdmin: ...
# @HasForm: ...

param(
    [Parameter(Mandatory=$true)]
    [string]$parametro1,
    
    [Parameter(Mandatory=$false)]
    [string]$parametro2 = "valor_default"
)

# Importar utilidades
. "$PSScriptRoot\..\..\Utils\Validation-Utils.ps1"
. "$PSScriptRoot\..\..\Utils\Logging-Utils.ps1"

try {
    # 1. Validaciones
    if (-not (Test-ValidInput $parametro1)) {
        throw "Entrada invÃ¡lida"
    }
    
    # 2. LÃ³gica de negocio
    # ...
    
    # 3. Logging
    Write-DashboardLog -Message "OperaciÃ³n exitosa" -Level "Info"
    
    # 4. Retorno estructurado
    return @{
        Success = $true
        Message = "OperaciÃ³n completada exitosamente"
        Data = @{ ... }  # Opcional
    }
    
} catch {
    Write-DashboardLog -Message "Error: $_" -Level "Error"
    return @{
        Success = $false
        Message = "Error: $_"
    }
}
```

### 9.4 EstÃ¡ndares de Logging

**Niveles de Log:**
```
Info    - Operaciones normales
Warning - Situaciones inusuales pero manejables
Error   - Errores que impiden completar operaciÃ³n
Critical - Errores que afectan funcionamiento del sistema
```

**Formato de Log:**
```
[YYYY-MM-DD HH:mm:ss] [LEVEL] [Component] Message

Ejemplo:
[2025-11-07 14:30:15] [Info] [ScriptLoader] Cargados 5 scripts de Configuracion
[2025-11-07 14:30:20] [Error] [Crear-Usuario] Error: Usuario ya existe
```

### 9.5 EstÃ¡ndares de Comentarios

**Comentarios en CÃ³digo:**
```powershell
# Comentario de una lÃ­nea para explicar QUÃ‰ hace el cÃ³digo

# Comentario multi-lÃ­nea para explicar POR QUÃ‰
# se hace algo de cierta manera, especialmente
# si no es obvio

<#
.SYNOPSIS
DescripciÃ³n breve de la funciÃ³n

.DESCRIPTION
DescripciÃ³n detallada

.PARAMETER NombreParametro
DescripciÃ³n del parÃ¡metro

.EXAMPLE
Ejemplo de uso
#>
```

---

## 10. SEPARACIÃ“N DE RESPONSABILIDADES

### 10.1 Capas de la AplicaciÃ³n

**Referencia:** Basado en principios de **03-PROPUESTA-ARQUITECTURA-MODULAR.md** SecciÃ³n 2.1

```
Capa 1: PresentaciÃ³n (UI)
â”œâ”€ Responsable: Components/ + UniversalDashboard
â”œâ”€ QuÃ© hace: Renderizar UI, capturar entrada, mostrar resultados
â””â”€ NO debe: Contener lÃ³gica de negocio, acceder a OS

Capa 2: OrquestaciÃ³n
â”œâ”€ Responsable: Dashboard.ps1
â”œâ”€ QuÃ© hace: Coordinar componentes, generar UI, gestionar ciclo de vida
â””â”€ NO debe: Implementar funcionalidades, tener cÃ³digo inline

Capa 3: LÃ³gica de Negocio
â”œâ”€ Responsable: Scripts/
â”œâ”€ QuÃ© hace: Implementar funcionalidades, validar reglas, interactuar con OS
â””â”€ NO debe: Definir UI, gestionar configuraciÃ³n global

Capa 4: Utilidades
â”œâ”€ Responsable: Utils/
â”œâ”€ QuÃ© hace: Funciones reutilizables, validaciones, logging
â””â”€ NO debe: Mantener estado, depender de componentes especÃ­ficos

Capa 5: ConfiguraciÃ³n
â”œâ”€ Responsable: Config/
â”œâ”€ QuÃ© hace: Almacenar configuraciÃ³n del sistema
â””â”€ NO debe: Contener cÃ³digo ejecutable (excepto Config-Loader.ps1)
```

### 10.2 SeparaciÃ³n UI / LÃ³gica / ValidaciÃ³n

#### UI (Components/)
```powershell
# âœ… CORRECTO - Solo UI
function New-CustomButton {
    param($Text, $OnClick, $Type)
    
    New-UDButton -Text $Text -OnClick $OnClick -Style @{
        backgroundColor = $theme.colors[$Type]
        # ... estilos
    }
}

# âŒ INCORRECTO - UI con lÃ³gica de negocio
function New-UserButton {
    New-UDButton -Text "Crear Usuario" -OnClick {
        # âŒ NO: LÃ³gica de negocio en componente UI
        $user = New-LocalUser -Name $username -Password $password
    }
}
```

#### LÃ³gica de Negocio (Scripts/)
```powershell
# âœ… CORRECTO - Solo lÃ³gica
param([string]$nombreUsuario, [string]$password)

. "$PSScriptRoot\..\..\Utils\Validation-Utils.ps1"

try {
    # Validar usando Utils/
    if (-not (Test-ValidUsername $nombreUsuario)) {
        throw "Usuario invÃ¡lido"
    }
    
    # LÃ³gica de negocio
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    New-LocalUser -Name $nombreUsuario -Password $securePassword
    
    return @{ Success = $true; Message = "Usuario creado" }
} catch {
    return @{ Success = $false; Message = "Error: $_" }
}

# âŒ INCORRECTO - LÃ³gica con UI embebida
param([string]$nombreUsuario)

try {
    New-LocalUser -Name $nombreUsuario
    # âŒ NO: UI en script de lÃ³gica
    Show-UDToast -Message "Usuario creado"
} catch {
    # âŒ NO: UI en script de lÃ³gica
    Show-UDToast -Message "Error"
}
```

#### Validaciones (Utils/)
```powershell
# âœ… CORRECTO - Validaciones reutilizables
function Test-ValidUsername {
    param([string]$Username)
    
    if ([string]::IsNullOrWhiteSpace($Username)) {
        return $false
    }
    
    if ($Username.Length -lt 3 -or $Username.Length -gt 20) {
        return $false
    }
    
    if ($Username -match '[^a-zA-Z0-9_-]') {
        return $false
    }
    
    return $true
}

# âŒ INCORRECTO - ValidaciÃ³n con lÃ³gica de negocio
function Test-ValidUsername {
    param([string]$Username)
    
    # ValidaciÃ³n OK
    if ($Username.Length -lt 3) {
        return $false
    }
    
    # âŒ NO: LÃ³gica de negocio en validaciÃ³n
    $existingUser = Get-LocalUser -Name $Username -ErrorAction SilentlyContinue
    if ($existingUser) {
        return $false
    }
}
```

### 10.3 Reglas de Dependencia

**Regla 1: Las capas superiores pueden depender de las inferiores, pero no al revÃ©s**

```
Dashboard.ps1 (Capa 2)
â”œâ”€ âœ… Puede usar: Components/, Utils/, Config/, Scripts/
â””â”€ âŒ No puede: N/A (es la capa superior)

Components/ (Capa 1)
â”œâ”€ âœ… Puede usar: Config/ (para tema)
â””â”€ âŒ No puede: Scripts/, Utils/, Dashboard.ps1

Scripts/ (Capa 3)
â”œâ”€ âœ… Puede usar: Utils/, Config/
â””â”€ âŒ No puede: Components/, Dashboard.ps1

Utils/ (Capa 4)
â”œâ”€ âœ… Puede usar: Config/ (para configuraciÃ³n de logging)
â””â”€ âŒ No puede: Components/, Scripts/, Dashboard.ps1

Config/ (Capa 5)
â”œâ”€ âœ… Puede usar: Nada (capa mÃ¡s baja)
â””â”€ âŒ No puede: Todo lo demÃ¡s
```

**Regla 2: Los scripts modulares son independientes entre sÃ­**

```
âœ… CORRECTO:
Scripts/Configuracion/Crear-Usuario.ps1
â””â”€ Puede usar: Utils/

âŒ INCORRECTO:
Scripts/Configuracion/Crear-Usuario.ps1
â””â”€ NO puede usar: Scripts/Mantenimiento/Limpiar-Archivos.ps1
```

### 10.4 Ejemplo Completo de SeparaciÃ³n

**Caso de Uso: Crear Usuario del Sistema**

**1. UI (Components/Form-Components.ps1):**
```powershell
function New-ScriptForm {
    # Solo genera formulario
    New-UDCard -Content {
        New-UDTextbox -Id "nombreUsuario"
        New-UDTextbox -Id "password" -Type "password"
        New-UDButton -Text "Crear" -OnClick {
            # Delega a ScriptLoader
            $result = Invoke-DashboardScript -ScriptPath $path -Parameters $params
            Show-UDToast -Message $result.Message
        }
    }
}
```

**2. OrquestaciÃ³n (Dashboard.ps1):**
```powershell
# Solo coordina
$metadata = Get-ScriptMetadata -ScriptPath $scriptPath
New-ScriptButton -Metadata $metadata -ScriptPath $scriptPath
```

**3. LÃ³gica de Negocio (Scripts/Configuracion/Crear-Usuario-Sistema.ps1):**
```powershell
param([string]$nombreUsuario, [string]$password)

. "$PSScriptRoot\..\..\Utils\Validation-Utils.ps1"

try {
    # Usa validaciÃ³n de Utils/
    if (-not (Test-ValidUsername $nombreUsuario)) {
        throw "Usuario invÃ¡lido"
    }
    
    # LÃ³gica de negocio
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    New-LocalUser -Name $nombreUsuario -Password $securePassword
    
    return @{ Success = $true; Message = "Usuario creado" }
} catch {
    return @{ Success = $false; Message = "Error: $_" }
}
```

**4. Validaciones (Utils/Validation-Utils.ps1):**
```powershell
function Test-ValidUsername {
    param([string]$Username)
    
    if ([string]::IsNullOrWhiteSpace($Username)) { return $false }
    if ($Username.Length -lt 3) { return $false }
    if ($Username -match '[^a-zA-Z0-9_-]') { return $false }
    
    return $true
}
```

**5. ConfiguraciÃ³n (Config/dashboard-config.json):**
```json
{
  "users": {
    "minUsernameLength": 3,
    "maxUsernameLength": 20
  }
}
```

### 10.5 Beneficios de la SeparaciÃ³n

**Testabilidad:**
```powershell
# âœ… FÃ¡cil de testear
Describe "Test-ValidUsername" {
    It "Rechaza usernames cortos" {
        Test-ValidUsername -Username "ab" | Should -Be $false
    }
    
    It "Acepta usernames vÃ¡lidos" {
        Test-ValidUsername -Username "usuario123" | Should -Be $true
    }
}
```

**ReutilizaciÃ³n:**
```powershell
# ValidaciÃ³n usada en mÃºltiples scripts
Scripts/Configuracion/Crear-Usuario-Sistema.ps1
â””â”€ Test-ValidUsername

Scripts/POS/Crear-Usuario-POS.ps1
â””â”€ Test-ValidUsername

Scripts/Auditoria/Verificar-Usuarios.ps1
â””â”€ Test-ValidUsername
```

**Mantenibilidad:**
```
Cambiar validaciÃ³n de username:
â”œâ”€ Antes (monolÃ­tico): Modificar en 7 lugares
â””â”€ Ahora (modular): Modificar en 1 lugar (Utils/Validation-Utils.ps1)
```

---

## DOCUMENTOS RELACIONADOS

### Documentos Anteriores
1. **03-PROPUESTA-ARQUITECTURA-MODULAR.md** - Secciones 1-5 (Fundamentos)

### Documentos Base
2. **00-RESUMEN-EJECUTIVO.md** - VisiÃ³n general de auditorÃ­a
3. **01-INFORME-AUDITORIA-TECNICA.md** - AnÃ¡lisis tÃ©cnico detallado
4. **02-MAPA-DEPENDENCIAS-Y-COMPONENTES.md** - Relaciones entre componentes

### Siguiente Documento
5. **03-2-PROPUESTA-ARQUITECTURA-MODULAR-C.md** - Secciones 11-17 (Escalabilidad)

---

## ðŸ“¦ ENTREGA B - COMPLETADA

### Cambios Incluidos en esta Entrega

**Secciones Completadas:**
6. âœ… **IntegraciÃ³n de ScriptLoader** - API mÃ­nima, integraciÃ³n con Dashboard.ps1, validaciÃ³n de scripts
7. âœ… **GeneraciÃ³n DinÃ¡mica de UI** - Botones y formularios automÃ¡ticos basados en metadata
8. âœ… **Flujo de EjecuciÃ³n Modular** - Diagrama end-to-end, manejo de errores, logging
9. âœ… **Convenciones y EstÃ¡ndares** - Nombres, metadata, cÃ³digo, logging, comentarios
10. âœ… **SeparaciÃ³n de Responsabilidades** - Capas, reglas de dependencia, ejemplos completos

**Contenido Generado:**
- Funciones completas de ScriptLoader (Get-ScriptsByCategory, Get-ScriptMetadata, Invoke-DashboardScript)
- Funciones de generaciÃ³n dinÃ¡mica de UI (New-ScriptButton, New-ScriptForm)
- Diagrama de flujo de ejecuciÃ³n completo
- EstÃ¡ndares de nombres para scripts, funciones, archivos JSON y variables
- Estructura estÃ¡ndar de script modular
- Ejemplos de separaciÃ³n UI/LÃ³gica/ValidaciÃ³n
- Reglas de dependencia entre capas

**Referencias a Documentos Base:**
- **01-INFORME-AUDITORIA-TECNICA.md** - Estado actual del ScriptLoader
- **03-PROPUESTA-ARQUITECTURA-MODULAR.md** - Principios arquitectÃ³nicos (SecciÃ³n 2.1)

**Conceptos Clave:**
- UI dinÃ¡mica basada en metadata
- SeparaciÃ³n estricta de responsabilidades
- Flujo modular end-to-end
- Convenciones consistentes
- Manejo robusto de errores

**PrÃ³xima Entrega (C):**
- Secciones 11-17 en **03-2-PROPUESTA-ARQUITECTURA-MODULAR-C.md**:
  - ComunicaciÃ³n entre Componentes
  - Estrategia de ReducciÃ³n (793 â†’ ~300 lÃ­neas)
  - Escalabilidad a 50+ Funcionalidades
  - Portabilidad y ConfiguraciÃ³n
  - Seguridad y Permisos
  - Riesgos y MitigaciÃ³n
  - Buenas PrÃ¡cticas PowerShell + UD

---

**Preparado por:** Sistema de AnÃ¡lisis ArquitectÃ³nico  
**Fecha:** 7 de Noviembre, 2025  
**VersiÃ³n:** 1.0 - Parte 2 de 3  
**Confidencialidad:** Interno - Paradise-SystemLabs
# ðŸ—ï¸ PROPUESTA DE ARQUITECTURA MODULAR - PARTE 3
## Dashboard IT - Paradise-SystemLabs

**Fecha:** 7 de Noviembre, 2025  
**VersiÃ³n:** 1.0 - Parte 3 de 3  
**PropÃ³sito:** Escalabilidad, Seguridad y Buenas PrÃ¡cticas del Sistema Modular

**Audiencia:** Arquitectos de Software, LÃ­deres TÃ©cnicos y Desarrolladores  
**Tiempo de lectura:** 40 minutos

---

## ðŸ“Œ NOTA DE CONTINUIDAD

Este documento es la **continuaciÃ³n** de:
- **03-PROPUESTA-ARQUITECTURA-MODULAR.md** (Secciones 1-5)
- **03-1-PROPUESTA-ARQUITECTURA-MODULAR-B.md** (Secciones 6-10)

Para contexto completo, leer primero los documentos anteriores que contienen:
1. Resumen Ejecutivo
2. Principios ArquitectÃ³nicos
3. Arquitectura Objetivo
4. Roles y Responsabilidades
5. Estructura de Carpetas Detallada
6. IntegraciÃ³n de ScriptLoader
7. GeneraciÃ³n DinÃ¡mica de UI
8. Flujo de EjecuciÃ³n Modular
9. Convenciones y EstÃ¡ndares
10. SeparaciÃ³n de Responsabilidades

---

## ðŸ“‘ TABLA DE CONTENIDOS

### Secciones en este Documento (11-17)
11. [ComunicaciÃ³n entre Componentes](#11-comunicacion-entre-componentes)
12. [Estrategia de ReducciÃ³n](#12-estrategia-de-reduccion)
13. [Escalabilidad a 50+ Funcionalidades](#13-escalabilidad-a-50-funcionalidades)
14. [Portabilidad y ConfiguraciÃ³n](#14-portabilidad-y-configuracion)
15. [Seguridad y Permisos](#15-seguridad-y-permisos)
16. [Riesgos y MitigaciÃ³n](#16-riesgos-y-mitigacion)
17. [Buenas PrÃ¡cticas PowerShell + UD](#17-buenas-practicas-powershell-ud)

---

## 11. COMUNICACIÃ“N ENTRE COMPONENTES

### 11.1 Mapa de ComunicaciÃ³n

**Referencia:** Basado en **02-MAPA-DEPENDENCIAS-Y-COMPONENTES.md**

```
Usuario
  â†“
UniversalDashboard (Framework)
  â†“
Dashboard.ps1 (Orquestador)
  â”œâ”€â†’ Config-Loader.ps1 â†’ Config/*.json
  â”œâ”€â†’ Utils/*.ps1
  â”œâ”€â†’ Components/*.ps1 â†’ Config/theme-config.json
  â””â”€â†’ ScriptLoader.ps1
       â”œâ”€â†’ Get-ScriptsByCategory() â†’ Scripts/Categoria/*.ps1
       â”œâ”€â†’ Get-ScriptMetadata() â†’ Lee metadata de scripts
       â””â”€â†’ Invoke-DashboardScript()
            â””â”€â†’ Script Modular
                 â”œâ”€â†’ Utils/Validation-Utils.ps1
                 â”œâ”€â†’ Utils/Logging-Utils.ps1
                 â”œâ”€â†’ Utils/System-Utils.ps1
                 â””â”€â†’ Sistema Operativo
```

### 11.2 Contratos de Entrada/Salida

#### Dashboard.ps1 â†’ Config-Loader.ps1
```powershell
# Entrada: Ninguna
# Salida: Hashtable con configuraciÃ³n

$config = Load-DashboardConfig
# Retorna: @{
#   server = @{ port = 10000; autoReload = $true }
#   paths = @{ logs = "Logs"; scripts = "Scripts" }
#   logging = @{ enabled = $true; level = "info" }
# }
```

#### Dashboard.ps1 â†’ ScriptLoader.Get-ScriptsByCategory()
```powershell
# Entrada: [string]$Category
# Salida: Array de FileInfo

$scripts = Get-ScriptsByCategory -Category "Configuracion"
# Retorna: @(
#   [FileInfo] Crear-Usuario-Sistema.ps1
#   [FileInfo] Cambiar-Nombre-PC.ps1
# )
```

#### ScriptLoader.Get-ScriptMetadata()
```powershell
# Entrada: [string]$ScriptPath
# Salida: Hashtable con metadata

$metadata = Get-ScriptMetadata -ScriptPath "C:\...\Crear-Usuario.ps1"
# Retorna: @{
#   Name = "Crear Usuario del Sistema"
#   Description = "Crea un usuario local de Windows"
#   RequiresAdmin = $true
#   HasForm = $true
#   FormFields = @(
#     @{ Name = "nombreUsuario"; Placeholder = "Nombre"; Type = "textbox" }
#   )
# }
```

#### ScriptLoader.Invoke-DashboardScript()
```powershell
# Entrada: [string]$ScriptPath, [hashtable]$Parameters
# Salida: Hashtable con resultado

$result = Invoke-DashboardScript -ScriptPath $path -Parameters @{
    nombreUsuario = "test"
    password = "Pass123"
}
# Retorna: @{
#   Success = $true/$false
#   Message = "Mensaje descriptivo"
#   Data = @{ ... }  # Opcional
# }
```

#### Script Modular â†’ Utils/
```powershell
# Validaciones
Test-ValidUsername -Username "test"  # Retorna: $true/$false
Test-AdminPrivileges                  # Retorna: $true/$false

# Logging
Write-DashboardLog -Message "Mensaje" -Level "Info"  # Retorna: void

# Sistema
Get-CurrentPCInfo  # Retorna: @{ Name = "..."; OS = "..."; ... }
```

### 11.3 Flujo de Datos

**Caso: Usuario crea un usuario del sistema**

```
1. Usuario â†’ Dashboard UI
   Datos: Click en botÃ³n "Crear Usuario"
   
2. Dashboard UI â†’ Dashboard.ps1
   Datos: Evento OnClick
   
3. Dashboard.ps1 â†’ Components/Form-Components.ps1
   Datos: Show-UDModal(New-ScriptForm($metadata))
   
4. Usuario â†’ Formulario
   Datos: { nombreUsuario: "test", password: "Pass123" }
   
5. Formulario â†’ ScriptLoader.Invoke-DashboardScript()
   Datos: { scriptPath: "...", parameters: { ... } }
   
6. ScriptLoader â†’ Script Modular
   Datos: ParÃ¡metros del formulario
   
7. Script â†’ Utils/Validation-Utils.ps1
   Datos: nombreUsuario = "test"
   Retorno: $true (vÃ¡lido)
   
8. Script â†’ Sistema Operativo
   Datos: New-LocalUser -Name "test" -Password $securePass
   Retorno: Usuario creado
   
9. Script â†’ Utils/Logging-Utils.ps1
   Datos: "Usuario test creado exitosamente"
   
10. Script â†’ ScriptLoader
    Retorno: @{ Success = $true; Message = "Usuario creado" }
    
11. ScriptLoader â†’ Dashboard.ps1
    Retorno: Resultado del script
    
12. Dashboard.ps1 â†’ Dashboard UI
    Datos: Show-UDToast("Usuario creado")
    
13. Dashboard UI â†’ Usuario
    Datos: NotificaciÃ³n verde de Ã©xito
```

### 11.4 Manejo de Estado

**Estado Global (Variables $Global:):**
```powershell
$Global:DashboardRoot      # Ruta raÃ­z del dashboard
$Global:DashboardConfig    # ConfiguraciÃ³n cargada
$Global:ThemeConfig        # Tema cargado
$Global:LoadedScripts      # CachÃ© de metadata de scripts
```

**Estado de SesiÃ³n (Variables $Session:):**
```powershell
$Session:CurrentScriptPath    # Script actualmente seleccionado
$Session:CurrentMetadata      # Metadata del script actual
$Session:FormData             # Datos del formulario actual
```

**Reglas de Estado:**
- âœ… Variables globales solo para configuraciÃ³n inmutable
- âœ… Variables de sesiÃ³n para datos temporales de UI
- âŒ NO usar variables globales para estado mutable
- âŒ NO compartir estado entre scripts modulares

---

## 12. ESTRATEGIA DE REDUCCIÃ“N

### 12.1 AnÃ¡lisis del Dashboard.ps1 Actual

**Referencia:** SegÃºn **01-INFORME-AUDITORIA-TECNICA.md**, Dashboard.ps1 tiene 793 lÃ­neas.

**Desglose de lÃ­neas:**
```
Total: 793 lÃ­neas
â”œâ”€ InicializaciÃ³n y setup: ~100 lÃ­neas
â”œâ”€ DefiniciÃ³n de variables de diseÃ±o: ~20 lÃ­neas
â”œâ”€ Funcionalidades inline (7 funciones): ~400 lÃ­neas
â”‚  â”œâ”€ Cambiar nombre PC: ~60 lÃ­neas
â”‚  â”œâ”€ Crear usuario sistema: ~80 lÃ­neas
â”‚  â”œâ”€ Crear usuario POS: ~70 lÃ­neas
â”‚  â”œâ”€ Limpiar archivos temporales: ~50 lÃ­neas
â”‚  â”œâ”€ Eliminar usuario: ~40 lÃ­neas
â”‚  â”œâ”€ Abrir navegador: ~30 lÃ­neas
â”‚  â””â”€ Detener dashboard: ~70 lÃ­neas
â”œâ”€ GeneraciÃ³n de UI: ~250 lÃ­neas
â””â”€ Inicio del servidor: ~23 lÃ­neas
```

### 12.2 Plan de ReducciÃ³n: 793 â†’ ~300 lÃ­neas

**Objetivo:** Reducir 62% del cÃ³digo (493 lÃ­neas)

#### Fase 1: Extraer Funcionalidades Inline (âˆ’400 lÃ­neas)

**AcciÃ³n:** Mover 7 funcionalidades inline a Scripts/

**Antes (Dashboard.ps1):**
```powershell
# LÃ­neas 200-260: Cambiar nombre PC (inline)
New-UDButton -Text "Cambiar Nombre PC" -OnClick {
    $nuevoNombre = (Get-UDElement -Id "nuevoNombre").Attributes.value
    
    if ([string]::IsNullOrWhiteSpace($nuevoNombre)) {
        Show-UDToast -Message "Debes ingresar un nombre" -BackgroundColor "red"
        return
    }
    
    # ... 50+ lÃ­neas mÃ¡s de lÃ³gica inline
}
```

**DespuÃ©s (Dashboard.ps1):**
```powershell
# LÃ­neas reducidas a ~10
$metadata = Get-ScriptMetadata -ScriptPath "Scripts/Configuracion/Cambiar-Nombre-PC.ps1"
New-ScriptButton -Metadata $metadata -ScriptPath $scriptPath
```

**Resultado:** âˆ’50 lÃ­neas Ã— 7 funciones = **âˆ’350 lÃ­neas**

#### Fase 2: Extraer Variables de DiseÃ±o a Config (âˆ’20 lÃ­neas)

**Antes (Dashboard.ps1):**
```powershell
$Colors = @{
    Primary = "#2196F3"
    Success = "#4caf50"
    Warning = "#ff9800"
    Danger = "#dc3545"
}
$Spacing = @{ XS = "10px"; S = "12px"; M = "16px"; L = "20px" }
```

**DespuÃ©s (Dashboard.ps1):**
```powershell
$theme = Load-ThemeConfig  # Lee Config/theme-config.json
```

**Resultado:** **âˆ’20 lÃ­neas**

#### Fase 3: Simplificar GeneraciÃ³n de UI (âˆ’100 lÃ­neas)

**Antes (Dashboard.ps1):**
```powershell
# GeneraciÃ³n manual de cada secciÃ³n
New-UDCard -Title "CONFIGURACIÃ“N INICIAL" -Content {
    New-UDButton -Text "Cambiar Nombre PC" -OnClick { ... }
    New-UDButton -Text "Crear Usuario" -OnClick { ... }
    # ... repetido para cada categorÃ­a
}
```

**DespuÃ©s (Dashboard.ps1):**
```powershell
# GeneraciÃ³n dinÃ¡mica por categorÃ­a
foreach ($category in $categoriesConfig.categories) {
    $scripts = Get-ScriptsByCategory -Category $category.path
    New-CategorySection -CategoryName $category.title -Content {
        foreach ($script in $scripts) {
            $metadata = Get-ScriptMetadata -ScriptPath $script.FullName
            New-ScriptButton -Metadata $metadata -ScriptPath $script.FullName
        }
    }
}
```

**Resultado:** **âˆ’100 lÃ­neas**

#### Fase 4: Consolidar InicializaciÃ³n (âˆ’23 lÃ­neas)

**Antes:** CÃ³digo disperso de inicializaciÃ³n

**DespuÃ©s:** FunciÃ³n centralizada
```powershell
function Initialize-Dashboard {
    # Detectar ubicaciÃ³n
    # Verificar mÃ³dulo
    # Liberar puerto
    # Crear carpetas
    # Cargar configuraciÃ³n
    # Importar mÃ³dulos
}

Initialize-Dashboard
```

**Resultado:** **âˆ’23 lÃ­neas**

### 12.3 Estructura del Dashboard.ps1 Objetivo (~300 lÃ­neas)

```powershell
# ============================================
# DASHBOARD.PS1 - ORQUESTADOR PRINCIPAL
# ============================================
# Total: ~300 lÃ­neas

# SECCIÃ“N 1: INICIALIZACIÃ“N (50 lÃ­neas)
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Global:DashboardRoot = $ScriptRoot

# Verificar/Instalar UniversalDashboard
if (-not (Get-Module -ListAvailable -Name UniversalDashboard.Community)) {
    Install-Module -Name UniversalDashboard.Community -Force -Scope CurrentUser
}

# Liberar puerto 10000
$processOnPort = Get-NetTCPConnection -LocalPort 10000 -ErrorAction SilentlyContinue
if ($processOnPort) {
    Stop-Process -Id $processOnPort.OwningProcess -Force
}

# Crear carpetas necesarias
@("Logs", "Backup", "Temp") | ForEach-Object {
    $path = Join-Path $Global:DashboardRoot $_
    if (-not (Test-Path $path)) {
        New-Item -Path $path -ItemType Directory -Force | Out-Null
    }
}

# SECCIÃ“N 2: CARGA DE CONFIGURACIÃ“N (30 lÃ­neas)
. "$Global:DashboardRoot\Config\Config-Loader.ps1"

$config = Load-DashboardConfig
$theme = Load-ThemeConfig
$categories = Load-CategoriesConfig

# SECCIÃ“N 3: IMPORTACIÃ“N DE MÃ“DULOS (40 lÃ­neas)
. "$Global:DashboardRoot\Utils\Validation-Utils.ps1"
. "$Global:DashboardRoot\Utils\System-Utils.ps1"
. "$Global:DashboardRoot\Utils\Logging-Utils.ps1"
. "$Global:DashboardRoot\Components\UI-Components.ps1"
. "$Global:DashboardRoot\Components\Form-Components.ps1"
. "$Global:DashboardRoot\Components\Layout-Components.ps1"
. "$Global:DashboardRoot\Scripts\ScriptLoader.ps1"

Write-DashboardLog -Message "Dashboard iniciado" -Level "Info"

# SECCIÃ“N 4: GENERACIÃ“N DE UI (150 lÃ­neas)
$dashboard = New-UDDashboard -Title $config.server.title -Content {
    
    # Tarjeta de informaciÃ³n del sistema
    New-CustomCard -Title "InformaciÃ³n del Sistema" -Content {
        $pcInfo = Get-CurrentPCInfo
        New-UDElement -Tag "p" -Content "PC: $($pcInfo.Name)"
        New-UDElement -Tag "p" -Content "OS: $($pcInfo.OS)"
    }
    
    # Generar secciones dinÃ¡micamente por categorÃ­a
    foreach ($category in $categories.categories | Sort-Object order) {
        $scripts = Get-ScriptsByCategory -Category $category.path
        
        if ($scripts.Count -eq 0) { continue }
        
        New-CategorySection -CategoryName $category.title -Icon $category.icon -Content {
            foreach ($script in $scripts) {
                $metadata = Get-ScriptMetadata -ScriptPath $script.FullName
                
                if (-not (Test-ScriptValid -ScriptPath $script.FullName)) {
                    continue
                }
                
                New-ScriptButton -Metadata $metadata -ScriptPath $script.FullName
            }
        }
    }
    
    # SecciÃ³n de acciones crÃ­ticas (fija)
    New-CategorySection -CategoryName "ACCIONES CRÃTICAS" -Icon "âš ï¸" -Content {
        New-CustomButton -Text "Detener Dashboard" -Type "danger" -OnClick {
            Stop-UDDashboard -Name "WPE-Dashboard"
        }
    }
}

# SECCIÃ“N 5: INICIO DEL SERVIDOR (30 lÃ­neas)
Write-DashboardLog -Message "Iniciando servidor en puerto $($config.server.port)" -Level "Info"

Start-UDDashboard -Dashboard $dashboard -Port $config.server.port -AutoReload

Write-Host "Dashboard iniciado en http://localhost:$($config.server.port)" -ForegroundColor Green
```

### 12.4 Tabla de ReducciÃ³n

| Componente | Antes | DespuÃ©s | ReducciÃ³n |
|------------|-------|---------|----------|
| **Funcionalidades inline** | 400 lÃ­neas | 0 lÃ­neas | âˆ’400 (âˆ’100%) |
| **Variables de diseÃ±o** | 20 lÃ­neas | 0 lÃ­neas | âˆ’20 (âˆ’100%) |
| **GeneraciÃ³n de UI** | 250 lÃ­neas | 150 lÃ­neas | âˆ’100 (âˆ’40%) |
| **InicializaciÃ³n** | 100 lÃ­neas | 50 lÃ­neas | âˆ’50 (âˆ’50%) |
| **ConfiguraciÃ³n** | 0 lÃ­neas | 30 lÃ­neas | +30 |
| **ImportaciÃ³n** | 0 lÃ­neas | 40 lÃ­neas | +40 |
| **Inicio servidor** | 23 lÃ­neas | 30 lÃ­neas | +7 |
| **TOTAL** | **793 lÃ­neas** | **~300 lÃ­neas** | **âˆ’493 (âˆ’62%)** |

### 12.5 DÃ³nde Va el CÃ³digo ExtraÃ­do

```
CÃ³digo extraÃ­do de Dashboard.ps1 â†’ Nuevo destino

400 lÃ­neas de funcionalidades inline
â”œâ”€ 60 lÃ­neas â†’ Scripts/Configuracion/Cambiar-Nombre-PC.ps1
â”œâ”€ 80 lÃ­neas â†’ Scripts/Configuracion/Crear-Usuario-Sistema.ps1
â”œâ”€ 70 lÃ­neas â†’ Scripts/POS/Crear-Usuario-POS.ps1
â”œâ”€ 50 lÃ­neas â†’ Scripts/Mantenimiento/Limpiar-Archivos-Temporales.ps1
â”œâ”€ 40 lÃ­neas â†’ Scripts/Mantenimiento/Eliminar-Usuario.ps1
â”œâ”€ 30 lÃ­neas â†’ Tools/Abrir-Navegador.ps1
â””â”€ 70 lÃ­neas â†’ Tools/Detener-Dashboard.ps1

20 lÃ­neas de variables de diseÃ±o
â””â”€ 20 lÃ­neas â†’ Config/theme-config.json

100 lÃ­neas de generaciÃ³n manual de UI
â””â”€ Reemplazadas por generaciÃ³n dinÃ¡mica (ScriptLoader)

50 lÃ­neas de inicializaciÃ³n dispersa
â””â”€ Consolidadas en secciÃ³n organizada
```

---

## 13. ESCALABILIDAD A 50+ FUNCIONALIDADES

### 13.1 PatrÃ³n de Crecimiento

**Objetivo:** Crecer de 7 funcionalidades actuales a 50+ sin degradaciÃ³n.

**PatrÃ³n de Plugin/MÃ³dulo:**
```
Agregar nueva funcionalidad:
1. Crear script en Scripts/Categoria/
2. Seguir PLANTILLA-Script.ps1
3. Incluir metadata completa
4. Dashboard detecta automÃ¡ticamente
5. UI se genera dinÃ¡micamente

Tiempo: <30 minutos
Impacto en Dashboard.ps1: CERO
```

### 13.2 OrganizaciÃ³n por CategorÃ­as

**Estructura Escalable:**
```
Scripts/
â”œâ”€ Configuracion/          (10 scripts)
â”‚  â”œâ”€ Cambiar-Nombre-PC.ps1
â”‚  â”œâ”€ Crear-Usuario-Sistema.ps1
â”‚  â”œâ”€ Configurar-Red.ps1
â”‚  â””â”€ ...
â”‚
â”œâ”€ Mantenimiento/          (8 scripts)
â”‚  â”œâ”€ Limpiar-Archivos-Temporales.ps1
â”‚  â”œâ”€ Actualizar-Sistema.ps1
â”‚  â””â”€ ...
â”‚
â”œâ”€ POS/                    (12 scripts)
â”‚  â”œâ”€ Crear-Usuario-POS.ps1
â”‚  â”œâ”€ Configurar-Impresora-Tickets.ps1
â”‚  â””â”€ ...
â”‚
â”œâ”€ Diseno/                 (6 scripts)
â”œâ”€ Atencion-Al-Cliente/    (5 scripts)
â””â”€ Auditoria/              (9 scripts)

Total: 50 scripts organizados en 6 categorÃ­as
```

### 13.3 Lineamientos para ExpansiÃ³n

**Regla 1: MÃ¡ximo 15 scripts por categorÃ­a**
```
Si una categorÃ­a supera 15 scripts:
â”œâ”€ OpciÃ³n A: Crear subcategorÃ­as
â”‚  Ejemplo: POS/ â†’ POS/Hardware/, POS/Software/
â”‚
â””â”€ OpciÃ³n B: Dividir en categorÃ­as mÃ¡s especÃ­ficas
   Ejemplo: Mantenimiento/ â†’ Mantenimiento-Sistema/, Mantenimiento-Red/
```

**Regla 2: Nombres descriptivos y Ãºnicos**
```
âœ… CORRECTO:
Configurar-Impresora-Tickets-Epson.ps1
Configurar-Impresora-Laser-HP.ps1

âŒ INCORRECTO:
Configurar-Impresora.ps1
Configurar-Impresora2.ps1
```

**Regla 3: Metadata completa obligatoria**
```powershell
# Todos los scripts deben tener:
# @Name: Nombre descriptivo
# @Description: QuÃ© hace (1-2 lÃ­neas)
# @RequiresAdmin: true/false
# @HasForm: true/false
# @FormField: ... (si HasForm = true)
```

### 13.4 Performance con 50+ Scripts

**Optimizaciones:**

#### 1. CachÃ© de Metadata
```powershell
# Cargar metadata solo una vez al inicio
$Global:LoadedScripts = @{}

foreach ($category in $categories.categories) {
    $scripts = Get-ScriptsByCategory -Category $category.path
    
    foreach ($script in $scripts) {
        $metadata = Get-ScriptMetadata -ScriptPath $script.FullName
        $Global:LoadedScripts[$script.FullName] = $metadata
    }
}

# Usar cachÃ© en lugar de leer cada vez
$metadata = $Global:LoadedScripts[$scriptPath]
```

**Beneficio:** ReducciÃ³n de 50 lecturas de archivo a 0 en runtime.

#### 2. Carga Lazy de CategorÃ­as
```powershell
# Solo cargar scripts de categorÃ­as visibles
foreach ($category in $categories.categories) {
    if ($category.visible -eq $false) {
        continue  # Saltar categorÃ­as ocultas
    }
    
    # Cargar solo si tiene scripts
    $scripts = Get-ScriptsByCategory -Category $category.path
    if ($scripts.Count -eq 0) {
        continue
    }
}
```

### 13.5 MÃ©tricas de Escalabilidad

| MÃ©trica | 7 Scripts | 50 Scripts | 100 Scripts |
|---------|-----------|------------|-------------|
| **Tiempo de inicio** | 2s | 3s | 5s |
| **Memoria usada** | 50 MB | 80 MB | 120 MB |
| **TamaÃ±o Dashboard.ps1** | 300 lÃ­neas | 300 lÃ­neas | 300 lÃ­neas |
| **Tiempo agregar script** | 30 min | 30 min | 30 min |
| **Complejidad mantenimiento** | Baja | Baja | Media |

**Nota:** Dashboard.ps1 se mantiene en 300 lÃ­neas independientemente del nÃºmero de scripts.

---

## 14. PORTABILIDAD Y CONFIGURACIÃ“N

### 14.1 Portabilidad Total

**Objetivo:** Dashboard funcional en cualquier ubicaciÃ³n sin modificaciones.

**Principio:** Usar rutas relativas y detecciÃ³n automÃ¡tica.

#### DetecciÃ³n AutomÃ¡tica de UbicaciÃ³n
```powershell
# En Dashboard.ps1
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Global:DashboardRoot = $ScriptRoot

# Ahora todas las rutas son relativas a $Global:DashboardRoot
$logsPath = Join-Path $Global:DashboardRoot "Logs"
$configPath = Join-Path $Global:DashboardRoot "Config\dashboard-config.json"
```

#### Rutas Relativas en Scripts Modulares
```powershell
# En Scripts/Configuracion/Crear-Usuario.ps1

# âœ… CORRECTO - Ruta relativa desde el script
. "$PSScriptRoot\..\..\Utils\Validation-Utils.ps1"

# âŒ INCORRECTO - Ruta absoluta
. "C:\WPE-Dashboard\Utils\Validation-Utils.ps1"

# âœ… CORRECTO - Usar variable global
. "$Global:DashboardRoot\Utils\Validation-Utils.ps1"
```

### 14.2 ConfiguraciÃ³n Centralizada

#### Config/dashboard-config.json
```json
{
  "server": {
    "port": 10000,
    "autoReload": true,
    "title": "Paradise-SystemLabs - Dashboard IT"
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
      "title": "CONFIGURACIÃ“N INICIAL",
      "icon": "âš™ï¸",
      "path": "Configuracion",
      "order": 1,
      "visible": true
    }
  ]
}
```

### 14.3 Cargador de ConfiguraciÃ³n

#### Config/Config-Loader.ps1
```powershell
function Load-DashboardConfig {
    $configPath = Join-Path $Global:DashboardRoot "Config\dashboard-config.json"
    
    if (-not (Test-Path $configPath)) {
        throw "Archivo de configuraciÃ³n no encontrado: $configPath"
    }
    
    try {
        $config = Get-Content $configPath -Raw | ConvertFrom-Json
        $Global:DashboardConfig = $config
        return $config
    } catch {
        throw "Error cargando configuraciÃ³n: $_"
    }
}

function Load-ThemeConfig {
    $themePath = Join-Path $Global:DashboardRoot "Config\theme-config.json"
    
    if (-not (Test-Path $themePath)) {
        # Retornar tema por defecto
        return @{
            colors = @{
                primary = "#2196F3"
                success = "#4caf50"
            }
            spacing = @{ xs = "10px"; s = "12px" }
        }
    }
    
    try {
        $theme = Get-Content $themePath -Raw | ConvertFrom-Json
        $Global:ThemeConfig = $theme
        return $theme
    } catch {
        throw "Error cargando tema: $_"
    }
}
```

### 14.4 Checklist de Portabilidad

**Antes de mover el dashboard a otra ubicaciÃ³n:**

- âœ… Todas las rutas usan `$Global:DashboardRoot` o `$PSScriptRoot`
- âœ… No hay rutas absolutas hardcodeadas
- âœ… Config/*.json existen y son vÃ¡lidos
- âœ… Carpetas necesarias se crean automÃ¡ticamente
- âœ… Logs/ se crea si no existe
- âœ… Scripts modulares usan rutas relativas
- âœ… No hay dependencias de ubicaciÃ³n especÃ­fica

---

## 15. SEGURIDAD Y PERMISOS

### 15.1 Principios de Seguridad

**Principio 1: Privilegio MÃ­nimo**
```
Solo solicitar permisos admin cuando sea absolutamente necesario

âœ… Requiere Admin:
- Crear/Eliminar usuarios
- Cambiar nombre del PC
- Instalar software
- Modificar configuraciÃ³n del sistema

âŒ NO Requiere Admin:
- Leer informaciÃ³n del sistema
- Generar reportes
- Limpiar archivos temporales del usuario
```

**Principio 2: ValidaciÃ³n de Entrada**
```
TODA entrada del usuario debe ser validada

âœ… Validar:
- Longitud de strings
- Caracteres permitidos
- Formato de datos
- Rangos numÃ©ricos
```

**Principio 3: Logging de AuditorÃ­a**
```
Registrar TODAS las operaciones crÃ­ticas

âœ… Loggear:
- CreaciÃ³n/EliminaciÃ³n de usuarios
- Cambios de configuraciÃ³n
- Errores de ejecuciÃ³n
- Intentos de acceso no autorizado
```

### 15.2 ValidaciÃ³n de Permisos

#### Utils/Security-Utils.ps1
```powershell
function Test-AdminPrivileges {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    
    return $principal.IsInRole($adminRole)
}

function Assert-AdminPrivileges {
    if (-not (Test-AdminPrivileges)) {
        throw "Esta operaciÃ³n requiere permisos de administrador"
    }
}
```

#### Uso en Scripts Modulares
```powershell
# En Scripts/Configuracion/Crear-Usuario-Sistema.ps1

param([string]$nombreUsuario, [string]$password)

. "$PSScriptRoot\..\..\Utils\Security-Utils.ps1"

try {
    # Verificar permisos admin
    Assert-AdminPrivileges
    
    # LÃ³gica del script...
    
    return @{ Success = $true; Message = "Usuario creado" }
} catch {
    return @{ Success = $false; Message = "Error: $_" }
}
```

### 15.3 ValidaciÃ³n de Entrada

#### Utils/Validation-Utils.ps1
```powershell
function Test-ValidUsername {
    param([string]$Username)
    
    if ([string]::IsNullOrWhiteSpace($Username)) { return $false }
    if ($Username.Length -lt 3 -or $Username.Length -gt 20) { return $false }
    if ($Username -match '[^a-zA-Z0-9_-]') { return $false }
    if ($Username -match '^[0-9]') { return $false }
    
    return $true
}

function Test-ValidPCName {
    param([string]$PCName)
    
    if ([string]::IsNullOrWhiteSpace($PCName)) { return $false }
    if ($PCName.Length -lt 1 -or $PCName.Length -gt 15) { return $false }
    if ($PCName -match '[^a-zA-Z0-9-]') { return $false }
    if ($PCName -match '^-|-$') { return $false }
    
    return $true
}

function Sanitize-Input {
    param([string]$Input)
    
    # Remover caracteres especiales peligrosos
    $sanitized = $Input -replace '[<>"''`;\\|]', ''
    $sanitized = $sanitized.Trim()
    
    return $sanitized
}
```

### 15.4 ProtecciÃ³n contra InyecciÃ³n

**Nunca usar Invoke-Expression con entrada del usuario:**

```powershell
# âŒ PELIGROSO - Vulnerable a inyecciÃ³n de cÃ³digo
$comando = "Get-Process -Name $nombreProceso"
Invoke-Expression $comando

# âœ… SEGURO - Usar parÃ¡metros
Get-Process -Name $nombreProceso
```

### 15.5 Manejo Seguro de Credenciales

**NO almacenar contraseÃ±as en texto plano:**

```powershell
# âŒ INCORRECTO
$password = "MiPassword123"

# âœ… CORRECTO - Usar SecureString
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $securePassword)
```

**NO loggear contraseÃ±as:**

```powershell
# âŒ INCORRECTO
Write-DashboardLog -Message "Creando usuario $username con password $password"

# âœ… CORRECTO
Write-DashboardLog -Message "Creando usuario $username"
```

---

## 16. RIESGOS Y MITIGACIÃ“N

### 16.1 Riesgos Identificados

#### Riesgo 1: RegresiÃ³n durante RefactorizaciÃ³n

**Probabilidad:** Alta  
**Impacto:** Alto  
**DescripciÃ³n:** Al extraer funcionalidades inline a scripts modulares, pueden introducirse bugs.

**MitigaciÃ³n:**
- âœ… Refactorizar por fases (1 funcionalidad a la vez)
- âœ… Mantener backup de Dashboard.ps1 original
- âœ… Testing manual exhaustivo despuÃ©s de cada fase
- âœ… Implementar tests automatizados con Pester
- âœ… Rollback inmediato si se detectan problemas

#### Riesgo 2: Incompatibilidad con UniversalDashboard

**Probabilidad:** Media  
**Impacto:** Alto  
**DescripciÃ³n:** Cambios en la arquitectura pueden no ser compatibles con UD v2.9.0.

**MitigaciÃ³n:**
- âœ… Mantener versiÃ³n fija de UniversalDashboard.Community (v2.9.0)
- âœ… Probar en entorno de desarrollo antes de producciÃ³n
- âœ… Documentar dependencias especÃ­ficas de versiÃ³n
- âœ… No actualizar UD sin testing completo

#### Riesgo 3: Performance Degradada

**Probabilidad:** Baja  
**Impacto:** Medio  
**DescripciÃ³n:** La arquitectura modular puede ser mÃ¡s lenta que el monolito.

**MitigaciÃ³n:**
- âœ… Implementar cachÃ© de metadata de scripts
- âœ… Carga lazy de categorÃ­as
- âœ… Medir tiempos de inicio antes y despuÃ©s
- âœ… Optimizar puntos crÃ­ticos identificados

#### Riesgo 4: Curva de Aprendizaje

**Probabilidad:** Alta  
**Impacto:** Bajo  
**DescripciÃ³n:** Desarrolladores necesitan aprender la nueva arquitectura.

**MitigaciÃ³n:**
- âœ… DocumentaciÃ³n completa (este documento)
- âœ… PLANTILLA-Script.ps1 como referencia
- âœ… Ejemplos de scripts modulares existentes
- âœ… SesiÃ³n de capacitaciÃ³n para el equipo

#### Riesgo 5: ConfiguraciÃ³n Incorrecta

**Probabilidad:** Media  
**Impacto:** Alto  
**DescripciÃ³n:** Errores en archivos JSON pueden romper el dashboard.

**MitigaciÃ³n:**
- âœ… ValidaciÃ³n de JSON al cargar
- âœ… Valores por defecto si falta configuraciÃ³n
- âœ… Mensajes de error claros
- âœ… Backup automÃ¡tico de configuraciÃ³n

### 16.2 Plan de Rollback

**Si algo sale mal durante la implementaciÃ³n:**

```
1. Detener Dashboard.ps1 actual
   â””â”€ Stop-UDDashboard -Name "WPE-Dashboard"

2. Restaurar Dashboard.ps1 original desde backup
   â””â”€ Copy-Item Backup/Dashboard.ps1.bak Dashboard.ps1 -Force

3. Reiniciar dashboard
   â””â”€ .\Iniciar-Dashboard.bat

4. Verificar funcionamiento
   â””â”€ Abrir http://localhost:10000
   â””â”€ Probar funcionalidades crÃ­ticas

5. Investigar causa del problema
   â””â”€ Revisar Logs/dashboard-*.log
   â””â”€ Identificar error especÃ­fico

6. Corregir y reintentar
```

### 16.3 Estrategia de Testing

**Testing Manual:**
```
DespuÃ©s de cada fase de refactorizaciÃ³n:

1. Iniciar dashboard
2. Verificar que todas las secciones se cargan
3. Probar cada botÃ³n/funcionalidad
4. Verificar que los formularios funcionan
5. Confirmar que los resultados son correctos
6. Revisar logs por errores
```

**Testing Automatizado (Pester):**
```powershell
Describe "Dashboard Architecture" {
    It "Dashboard.ps1 debe tener menos de 350 lÃ­neas" {
        $lines = (Get-Content Dashboard.ps1).Count
        $lines | Should -BeLessThan 350
    }
    
    It "Todos los scripts deben tener metadata" {
        $scripts = Get-ChildItem Scripts -Recurse -Filter *.ps1
        foreach ($script in $scripts) {
            $metadata = Get-ScriptMetadata -ScriptPath $script.FullName
            $metadata.Name | Should -Not -BeNullOrEmpty
        }
    }
}
```

---

## 17. BUENAS PRÃCTICAS POWERSHELL + UD

### 17.1 PowerShell Best Practices

**1. Usar Verbos Aprobados**
```powershell
# âœ… CORRECTO
Get-UserInfo
Set-Configuration
New-CustomButton

# âŒ INCORRECTO
FetchUserInfo
UpdateConfig
CreateButton
```

**2. ParÃ¡metros Tipados**
```powershell
# âœ… CORRECTO
param(
    [Parameter(Mandatory=$true)]
    [string]$Username,
    
    [Parameter(Mandatory=$false)]
    [int]$MaxRetries = 3
)

# âŒ INCORRECTO
param($Username, $MaxRetries)
```

**3. Try/Catch Siempre**
```powershell
# âœ… CORRECTO
try {
    $result = Do-Something
    return @{ Success = $true; Message = "OK" }
} catch {
    Write-DashboardLog -Message "Error: $_" -Level "Error"
    return @{ Success = $false; Message = "Error: $_" }
}
```

**4. Usar -ErrorAction**
```powershell
# âœ… CORRECTO
$user = Get-LocalUser -Name $username -ErrorAction SilentlyContinue
if (-not $user) {
    # Manejar usuario no encontrado
}
```

### 17.2 UniversalDashboard Best Practices

**1. Usar Show-UDToast para Feedback**
```powershell
# âœ… CORRECTO
if ($result.Success) {
    Show-UDToast -Message $result.Message -Duration 5000 -BackgroundColor "green"
} else {
    Show-UDToast -Message $result.Message -Duration 5000 -BackgroundColor "red"
}
```

**2. Usar $Session: para Estado Temporal**
```powershell
# âœ… CORRECTO - Estado de sesiÃ³n
$Session:CurrentScript = $scriptPath

# âŒ INCORRECTO - Variable global mutable
$Global:CurrentScript = $scriptPath
```

**3. Usar Hide-UDModal DespuÃ©s de AcciÃ³n**
```powershell
New-UDButton -Text "Guardar" -OnClick {
    $result = Save-Data
    
    # Cerrar modal
    Hide-UDModal
    
    # Mostrar resultado
    Show-UDToast -Message $result.Message
}
```

**4. Timeouts para Operaciones Largas**
```powershell
# âœ… CORRECTO
New-UDButton -Text "Proceso Largo" -OnClick {
    Show-UDToast -Message "Procesando..." -Duration 2000
    
    Start-Sleep -Seconds 1  # Dar tiempo para mostrar mensaje
    
    $result = Do-LongOperation
    
    Show-UDToast -Message $result.Message
}
```

### 17.3 Logging Best Practices

**1. Niveles de Log Apropiados**
```powershell
# Info - Operaciones normales
Write-DashboardLog -Message "Dashboard iniciado" -Level "Info"

# Warning - Situaciones inusuales
Write-DashboardLog -Message "Script no tiene metadata" -Level "Warning"

# Error - Errores que impiden operaciÃ³n
Write-DashboardLog -Message "Error creando usuario: $_" -Level "Error"

# Critical - Errores que afectan sistema completo
Write-DashboardLog -Message "No se puede cargar configuraciÃ³n" -Level "Critical"
```

**2. Contexto en Logs**
```powershell
# âœ… CORRECTO - Con contexto
Write-DashboardLog -Message "Usuario 'test' creado por 'admin' en PC 'WPE-01'" -Level "Info"

# âŒ INCORRECTO - Sin contexto
Write-DashboardLog -Message "Usuario creado" -Level "Info"
```

### 17.4 Testing con Pester

**Estructura de Tests:**
```powershell
Describe "Validation-Utils" {
    Context "Test-ValidUsername" {
        It "Rechaza usernames vacÃ­os" {
            Test-ValidUsername -Username "" | Should -Be $false
        }
        
        It "Rechaza usernames cortos" {
            Test-ValidUsername -Username "ab" | Should -Be $false
        }
        
        It "Acepta usernames vÃ¡lidos" {
            Test-ValidUsername -Username "usuario123" | Should -Be $true
        }
    }
}
```

### 17.5 DocumentaciÃ³n de Funciones

**Comment-Based Help:**
```powershell
function Get-UserInfo {
    <#
    .SYNOPSIS
    Obtiene informaciÃ³n de un usuario local
    
    .DESCRIPTION
    Obtiene informaciÃ³n detallada de un usuario local de Windows,
    incluyendo nombre, descripciÃ³n y Ãºltimo inicio de sesiÃ³n.
    
    .PARAMETER Username
    Nombre del usuario a consultar
    
    .EXAMPLE
    Get-UserInfo -Username "test"
    
    .OUTPUTS
    Hashtable con informaciÃ³n del usuario
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Username
    )
    
    # ImplementaciÃ³n...
}
```

### 17.6 Manejo de Errores

**Errores EspecÃ­ficos:**
```powershell
try {
    $user = Get-LocalUser -Name $username -ErrorAction Stop
} catch [Microsoft.PowerShell.Commands.UserNotFoundException] {
    return @{ Success = $false; Message = "Usuario no encontrado" }
} catch [System.UnauthorizedAccessException] {
    return @{ Success = $false; Message = "Permisos insuficientes" }
} catch {
    return @{ Success = $false; Message = "Error inesperado: $_" }
}
```

---

## DOCUMENTOS RELACIONADOS

### Documentos Anteriores
1. **03-PROPUESTA-ARQUITECTURA-MODULAR.md** - Secciones 1-5 (Fundamentos)
2. **03-1-PROPUESTA-ARQUITECTURA-MODULAR-B.md** - Secciones 6-10 (IntegraciÃ³n y EjecuciÃ³n)

### Documentos Base
3. **00-RESUMEN-EJECUTIVO.md** - VisiÃ³n general de auditorÃ­a
4. **01-INFORME-AUDITORIA-TECNICA.md** - AnÃ¡lisis tÃ©cnico detallado
5. **02-MAPA-DEPENDENCIAS-Y-COMPONENTES.md** - Relaciones entre componentes
6. **04-PLAN-REORGANIZACION.md** - Plan de implementaciÃ³n paso a paso

---

## ðŸ“¦ ENTREGA C - COMPLETADA

### Cambios Incluidos en esta Entrega

**Secciones Completadas:**
11. âœ… **ComunicaciÃ³n entre Componentes** - Mapa de comunicaciÃ³n, contratos de entrada/salida, flujo de datos, manejo de estado
12. âœ… **Estrategia de ReducciÃ³n** - AnÃ¡lisis de Dashboard.ps1 actual, plan de reducciÃ³n 793â†’300 lÃ­neas, tabla de reducciÃ³n, destino del cÃ³digo extraÃ­do
13. âœ… **Escalabilidad a 50+ Funcionalidades** - PatrÃ³n de crecimiento, organizaciÃ³n por categorÃ­as, lineamientos de expansiÃ³n, optimizaciones de performance
14. âœ… **Portabilidad y ConfiguraciÃ³n** - Portabilidad total, configuraciÃ³n centralizada (JSON), cargador de configuraciÃ³n, checklist
15. âœ… **Seguridad y Permisos** - Principios de seguridad, validaciÃ³n de permisos, validaciÃ³n de entrada, protecciÃ³n contra inyecciÃ³n, manejo seguro de credenciales
16. âœ… **Riesgos y MitigaciÃ³n** - 5 riesgos identificados con mitigaciones, plan de rollback, estrategia de testing
17. âœ… **Buenas PrÃ¡cticas PowerShell + UD** - PowerShell best practices, UniversalDashboard best practices, logging, testing con Pester, documentaciÃ³n, manejo de errores

**Contenido Generado:**
- Mapa completo de comunicaciÃ³n entre componentes
- Contratos de entrada/salida para todas las funciones clave
- Plan detallado de reducciÃ³n de Dashboard.ps1 (793 â†’ 300 lÃ­neas)
- Estrategia de escalabilidad a 50+ funcionalidades
- Archivos JSON de configuraciÃ³n completos
- Funciones de seguridad (Test-AdminPrivileges, validaciones)
- 5 riesgos identificados con mitigaciones especÃ­ficas
- Plan de rollback paso a paso
- 17 buenas prÃ¡cticas especÃ­ficas para PowerShell + UniversalDashboard

**Referencias a Documentos Base:**
- **02-MAPA-DEPENDENCIAS-Y-COMPONENTES.md** - Mapa de comunicaciÃ³n
- **01-INFORME-AUDITORIA-TECNICA.md** - AnÃ¡lisis de Dashboard.ps1 actual

**Conceptos Clave:**
- ComunicaciÃ³n clara entre componentes con contratos definidos
- ReducciÃ³n sistemÃ¡tica de Dashboard.ps1 en 4 fases
- Escalabilidad horizontal sin modificar core
- Portabilidad total con rutas relativas
- Seguridad por capas (validaciÃ³n, permisos, logging)
- GestiÃ³n de riesgos con mitigaciones especÃ­ficas
- Buenas prÃ¡cticas especÃ­ficas para PowerShell + UD

**Estado Final de la Propuesta ArquitectÃ³nica:**
- âœ… Documento 03 (Secciones 1-5) - Fundamentos
- âœ… Documento 03-1 (Secciones 6-10) - IntegraciÃ³n y EjecuciÃ³n
- âœ… Documento 03-2 (Secciones 11-17) - Escalabilidad y Buenas PrÃ¡cticas

**Total:** 17 secciones completadas distribuidas en 3 documentos

---

**Preparado por:** Sistema de AnÃ¡lisis ArquitectÃ³nico  
**Fecha:** 7 de Noviembre, 2025  
**VersiÃ³n:** 1.0 - Parte 3 de 3 âœ… COMPLETADA  
**Confidencialidad:** Interno - Paradise-SystemLabs
