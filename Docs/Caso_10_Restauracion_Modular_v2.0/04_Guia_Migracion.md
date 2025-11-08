# 🚀 Guía de Migración - v1.0.1-LTS → v2.0

**Paradise-SystemLabs**
**Caso 10 - Restauración Modular v2.0**
**Fecha:** 2025-11-08
**Audiencia:** Desarrolladores, DevOps, Mantenedores del Dashboard

---

## 📋 Tabla de Contenidos

1. [Introducción](#introducción)
2. [Prerequisitos](#prerequisitos)
3. [Estrategia de Migración](#estrategia-de-migración)
4. [Crear un Módulo v2.0](#crear-un-módulo-v20)
5. [Migrar Funciones Existentes](#migrar-funciones-existentes)
6. [Testing](#testing)
7. [Integración en Dashboard](#integración-en-dashboard)
8. [Deprecación de v1.0.1](#deprecación-de-v101)
9. [Checklist de Migración](#checklist-de-migración)
10. [Troubleshooting](#troubleshooting)

---

## 📖 Introducción

### Propósito de esta Guía

Esta guía documenta el proceso completo para migrar funciones del monolito v1.0.1-LTS (UI/Dashboard-UI.ps1 - 643 líneas) a módulos v2.0 (Modules/*.psm1).

### Estado Actual

**v1.0.1-LTS:**
- ✅ Funcional y estable
- ⚠️ Monolítico (643 líneas en un archivo)
- ⚠️ 13 funciones en scope global
- ⚠️ Difícil de mantener y testear

**v2.0:**
- ✅ Arquitectura modular
- ✅ 1 módulo demo completado (DashboardContent.psm1)
- ⚠️ Requiere migración de 12 funciones restantes

### Objetivo Final

```
UI/Dashboard-UI.ps1 (643 líneas) → Modules/ (5 módulos especializados)
    ├─ ParadiseTheme.psm1     (50 líneas)
    ├─ ParadiseCards.psm1     (230 líneas)
    ├─ ParadiseBoxes.psm1     (160 líneas)
    ├─ ParadiseLayout.psm1    (220 líneas)
    └─ DashboardContent.psm1  (98 líneas) ✅ COMPLETADO
```

---

## ✅ Prerequisitos

### Conocimientos Requeridos

- [x] PowerShell 5.1+
- [x] Módulos PowerShell (.psm1)
- [x] UniversalDashboard.Community v2.9.0
- [x] Git (control de versiones)
- [x] Pester (testing) - Opcional pero recomendado

### Herramientas

```powershell
# Verificar PowerShell
$PSVersionTable.PSVersion
# Debe ser >= 5.1

# Verificar UniversalDashboard
Get-Module -ListAvailable UniversalDashboard.Community
# Debe ser v2.9.0

# Instalar Pester (opcional)
Install-Module -Name Pester -Force -SkipPublisherCheck
```

### Archivos Clave

| Archivo | Propósito | Estado |
|---------|-----------|--------|
| [UI/Dashboard-UI.ps1](../../UI/Dashboard-UI.ps1) | Monolito v1.0.1 a migrar | ⚠️ Activo |
| [Modules/DashboardContent.psm1](../../Modules/DashboardContent.psm1) | Módulo demo v2.0 | ✅ Referencia |
| [Dashboard.ps1](../../Dashboard.ps1) | Entry point con integración híbrida | ✅ Activo |
| [02_Analisis_Modularidad.md](02_Analisis_Modularidad.md) | Plan de modularización | 📚 Documentación |

---

## 🎯 Estrategia de Migración

### Principio: Migración Gradual sin Downtime

```
Fase 1: Coexistencia (ACTUAL)
    v1.0.1-LTS (Dot-sourcing) + v2.0 (Import-Module)
    └─ Dashboard usa v1.0.1, v2.0 disponible

Fase 2: Migración Paralela (1-2 funciones/semana)
    v1.0.1-LTS + v2.0 (creciendo)
    └─ Dashboard usa v1.0.1, testeamos v2.0

Fase 3: Switchover (Cuando v2.0 completo)
    v1.0.1-LTS (deprecated) + v2.0 (activo)
    └─ Dashboard usa v2.0, v1.0.1 disponible como fallback

Fase 4: Cleanup (Después de 1 mes estable)
    v2.0 exclusivo
    └─ Eliminar UI/Dashboard-UI.ps1
```

### Orden de Migración Recomendado

**Prioridad por Complejidad (simple → complejo):**

1. ✅ **New-ParadiseModuleDemo** (Ya migrado)
2. 🔜 **Get-ParadiseGlobalCSS** (Simple, sin parámetros)
3. 🔜 **New-SectionSeparator** (Simple, 1 parámetro)
4. 🔜 **New-DashboardHeader** (Medio, 1 parámetro)
5. 🔜 **New-DashboardFooter** (Medio, 1 parámetro)
6. 🔜 **New-CodeBox** (Medio, 2 parámetros)
7. 🔜 **New-SuccessBox** (Medio, 2 parámetros)
8. 🔜 **New-WarningBox** (Medio, 2 parámetros)
9. 🔜 **New-DangerBox** (Medio, 2 parámetros)
10. 🔜 **New-ActionButton** (Complejo, 4 parámetros + scriptblock)
11. 🔜 **New-CategoryBox** (Complejo, 5 parámetros)
12. 🔜 **New-SystemInfoCard** (Complejo, 1 parámetro + logic)
13. 🔜 **New-CriticalActionsCard** (Complejo, 1 parámetro + UI compleja)
14. 🔜 **New-DashboardContent** (MUY COMPLEJO, 3 parámetros + 602 líneas)

---

## 🏗️ Crear un Módulo v2.0

### Paso 1: Crear Estructura del Módulo

```powershell
# Crear archivo del módulo
$moduleName = "ParadiseTheme"  # Ejemplo
$modulePath = "C:\ProgramData\WPE-Dashboard\Modules\$moduleName.psm1"

New-Item -Path $modulePath -ItemType File -Force
```

### Paso 2: Plantilla Básica del Módulo

```powershell
# Modules/ParadiseTheme.psm1 - PLANTILLA

<#
.SYNOPSIS
    Módulo Paradise v2.0 - Tema y estilos globales

.DESCRIPTION
    Contiene funciones relacionadas con el sistema de diseño Paradise:
    - Colores globales
    - CSS global
    - Estilos compartidos

.NOTES
    Nombre:         ParadiseTheme.psm1
    Autor:          Paradise-SystemLabs
    Versión:        2.0.0
    Fecha Creación: 2025-11-08
    Arquitectura:   Modular v2.0
    Dependencias:   UniversalDashboard.Community v2.9.0

.LINK
    https://github.com/Paradise-SystemLabs/WPE-Dashboard
#>

# ============================================
# FUNCIONES EXPORTADAS
# ============================================

function Get-ParadiseGlobalCSS {
    <#
    .SYNOPSIS
        Obtiene el CSS global del sistema Paradise

    .DESCRIPTION
        Genera el CSS global que define:
        - Fuentes tipográficas (Segoe UI)
        - Colores del sistema
        - Estilos base de la interfaz

    .PARAMETER Config
        Hashtable de configuración del dashboard
        Contiene colores Paradise y configuración general

    .EXAMPLE
        $css = Get-ParadiseGlobalCSS -Config $dashConfig
        New-UDDashboard -Content { ... } -EndpointInitialization $css

    .OUTPUTS
        ScriptBlock con definiciones CSS
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Config
    )

    try {
        # Extraer colores de configuración
        $colors = $Config.colorsParadise

        # Generar CSS
        $cssBlock = {
            # CSS aquí
        }

        return $cssBlock

    } catch {
        Write-Error "Error en Get-ParadiseGlobalCSS: $_"
        throw
    }
}

# ============================================
# EXPORTS
# ============================================

Export-ModuleMember -Function @(
    'Get-ParadiseGlobalCSS'
)
```

### Paso 3: Documentar el Módulo

Crear `Modules/README.md` si no existe:

```markdown
# Módulos Paradise v2.0

## Módulos Disponibles

### ParadiseTheme.psm1
**Versión:** 2.0.0
**Funciones:** Get-ParadiseGlobalCSS
**Dependencias:** UniversalDashboard.Community
**Estado:** ✅ Completado

### DashboardContent.psm1
**Versión:** 2.0.0
**Funciones:** New-ParadiseModuleDemo
**Dependencias:** UniversalDashboard.Community
**Estado:** ✅ Completado

## Convenciones

- Prefijo de funciones: `New-Paradise*`, `Get-Paradise*`
- Formato: PascalCase para nombres de módulos
- Exports explícitos con `Export-ModuleMember`
```

---

## 🔄 Migrar Funciones Existentes

### Ejemplo Completo: Migrar Get-ParadiseGlobalCSS

#### Paso 1: Identificar Función en v1.0.1

**Ubicación:** [UI/Dashboard-UI.ps1:708](../../UI/Dashboard-UI.ps1)

```powershell
# v1.0.1 - Líneas 708-776 (68 líneas)
function Get-ParadiseGlobalCSS {
    param([hashtable]$Config)

    $colors = $Config.colorsParadise
    return {
        # ... CSS definitions ...
    }
}
```

#### Paso 2: Analizar Dependencias

```powershell
# Dependencias externas
- $Config (parámetro) ✅ Ya está parametrizado
- $Config.colorsParadise ✅ Acceso a través de parámetro
- UniversalDashboard (New-UDElement implícito en CSS) ✅ Ya está cargado

# Sin dependencias de otras funciones v1.0.1 ✅ SEGURO MIGRAR
```

#### Paso 3: Copiar a Módulo v2.0

```powershell
# Modules/ParadiseTheme.psm1

function Get-ParadiseGlobalCSS {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Config
    )

    try {
        $colors = $Config.colorsParadise

        return {
            # CSS copiado desde v1.0.1
            "body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }"
            # ... resto del CSS ...
        }

    } catch {
        Write-Error "Error en Get-ParadiseGlobalCSS: $_"
        throw
    }
}

Export-ModuleMember -Function 'Get-ParadiseGlobalCSS'
```

#### Paso 4: Agregar Mejoras v2.0

```powershell
# Mejoras opcionales en v2.0:
# - Validación de parámetros más estricta
# - Mejor manejo de errores
# - Logging
# - Documentación mejorada

function Get-ParadiseGlobalCSS {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [hashtable]$Config
    )

    # Validar que exista colorsParadise
    if (-not $Config.ContainsKey('colorsParadise')) {
        throw "Configuración inválida: falta 'colorsParadise'"
    }

    try {
        $colors = $Config.colorsParadise

        # Validar colores requeridos
        $requiredColors = @('amarillo', 'azul', 'verde', 'rojo')
        foreach ($color in $requiredColors) {
            if (-not $colors.ContainsKey($color)) {
                Write-Warning "Color '$color' no encontrado en configuración"
            }
        }

        return {
            # CSS definitions
        }

    } catch {
        Write-Error "Error en Get-ParadiseGlobalCSS: $_"
        throw
    }
}
```

#### Paso 5: Crear Tests

```powershell
# Tests/ParadiseTheme.Tests.ps1

Describe "ParadiseTheme Module" {
    BeforeAll {
        Import-Module "$PSScriptRoot\..\Modules\ParadiseTheme.psm1" -Force

        # Config de prueba
        $testConfig = @{
            colorsParadise = @{
                amarillo = "#fff3cd"
                azul     = "#2196F3"
                verde    = "#4caf50"
                rojo     = "#f44336"
            }
        }
    }

    Context "Get-ParadiseGlobalCSS" {
        It "Existe y es exportada" {
            Get-Command Get-ParadiseGlobalCSS -Module ParadiseTheme | Should -Not -BeNullOrEmpty
        }

        It "Requiere parámetro Config" {
            { Get-ParadiseGlobalCSS } | Should -Throw
        }

        It "Retorna scriptblock" {
            $css = Get-ParadiseGlobalCSS -Config $testConfig
            $css | Should -BeOfType [scriptblock]
        }

        It "CSS contiene font-family" {
            $css = Get-ParadiseGlobalCSS -Config $testConfig
            $cssString = $css.ToString()
            $cssString | Should -Match "font-family"
        }

        It "Lanza error si falta colorsParadise" {
            $badConfig = @{}
            { Get-ParadiseGlobalCSS -Config $badConfig } | Should -Throw "*colorsParadise*"
        }
    }
}
```

#### Paso 6: Ejecutar Tests

```powershell
# Test manual
cd C:\ProgramData\WPE-Dashboard

# Cargar módulo
Import-Module .\Modules\ParadiseTheme.psm1 -Force

# Cargar config
. .\Core\Dashboard-Init.ps1
$dashConfig = Initialize-DashboardConfig

# Test básico
$css = Get-ParadiseGlobalCSS -Config $dashConfig
Write-Host "[TEST] Get-ParadiseGlobalCSS: $($css -ne $null)" -ForegroundColor $(if($css){'Green'}else{'Red'})

# Test con Pester (si está instalado)
Invoke-Pester .\Tests\ParadiseTheme.Tests.ps1 -Output Detailed
```

#### Paso 7: Integrar en Dashboard.ps1

```powershell
# Dashboard.ps1 - Añadir después de línea 106

# Cargar módulo ParadiseTheme v2.0
$themeModulePath = Join-Path $ScriptRoot "Modules\ParadiseTheme.psm1"
if (Test-Path $themeModulePath) {
    try {
        Import-Module $themeModulePath -Force -ErrorAction Stop
        Write-Host "[OK] Módulo v2.0 cargado: ParadiseTheme.psm1" -ForegroundColor Cyan
        $Global:ParadiseThemeLoaded = $true
    } catch {
        Write-Host "[WARN] Error al cargar ParadiseTheme v2.0: $_" -ForegroundColor Yellow
        $Global:ParadiseThemeLoaded = $false
    }
}
```

#### Paso 8: Usar Función v2.0 (Opcional)

```powershell
# Dashboard.ps1 - En scriptblock del dashboard

# Opción A: Usar v2.0 si está disponible
if ($Global:ParadiseThemeLoaded) {
    $cssBlock = Get-ParadiseGlobalCSS -Config $Cache:Config
} else {
    # Fallback a v1.0.1
    $cssBlock = Get-ParadiseGlobalCSS -Config $Cache:Config
}
```

**NOTA:** En fase de coexistencia, ambas versiones funcionan idénticamente. El switchover real ocurre en Fase 3.

#### Paso 9: Deprecar v1.0.1 (Fase 3)

```powershell
# UI/Dashboard-UI.ps1 - Marcar como deprecated

function Get-ParadiseGlobalCSS {
    [Obsolete("Esta función ha sido migrada a Modules/ParadiseTheme.psm1. Use la versión v2.0")]
    param([hashtable]$Config)

    Write-Warning "Get-ParadiseGlobalCSS (v1.0.1) está deprecated. Use módulo ParadiseTheme v2.0"

    # Código original...
}
```

#### Paso 10: Eliminar v1.0.1 (Fase 4)

```powershell
# Después de 1 mes estable con v2.0:
# 1. Verificar que NO hay referencias a v1.0.1
Get-ChildItem -Recurse -Include *.ps1 | Select-String "Get-ParadiseGlobalCSS" | Where-Object { $_.Path -notmatch "Backup|UI\\Dashboard-UI" }

# 2. Si no hay referencias externas, eliminar de UI/Dashboard-UI.ps1
# Eliminar líneas 708-776

# 3. Commit con mensaje claro
git add UI/Dashboard-UI.ps1
git commit -m "Remove Get-ParadiseGlobalCSS v1.0.1 (migrated to ParadiseTheme.psm1 v2.0)"
```

---

## 🧪 Testing

### Estrategia de Testing

```
Nivel 1: Tests Unitarios (Pester)
    └─ Cada función individualmente

Nivel 2: Tests de Integración
    └─ Módulo completo con dependencias

Nivel 3: Tests de Sistema
    └─ Dashboard completo con módulos v2.0
```

### Plantilla de Test Pester

```powershell
# Tests/[ModuleName].Tests.ps1

Describe "[ModuleName] Module" {
    BeforeAll {
        # Importar módulo
        $modulePath = "$PSScriptRoot\..\Modules\[ModuleName].psm1"
        Import-Module $modulePath -Force

        # Setup de datos de prueba
        $testConfig = @{
            # ... configuración de prueba ...
        }
    }

    AfterAll {
        # Cleanup
        Remove-Module [ModuleName] -Force -ErrorAction SilentlyContinue
    }

    Context "[FunctionName]" {
        It "Should export function" {
            Get-Command [FunctionName] -Module [ModuleName] | Should -Not -BeNullOrEmpty
        }

        It "Should require mandatory parameters" {
            { [FunctionName] } | Should -Throw
        }

        It "Should return expected type" {
            $result = [FunctionName] -Param1 "value"
            $result | Should -BeOfType [ExpectedType]
        }

        It "Should handle errors gracefully" {
            { [FunctionName] -Param1 $null } | Should -Throw
        }

        It "Should produce valid output" {
            $result = [FunctionName] -Param1 "value"
            $result | Should -Not -BeNullOrEmpty
        }
    }
}
```

### Tests de Integración Manual

```powershell
# Tools/Test-Module-Integration.ps1

cd C:\ProgramData\WPE-Dashboard

Write-Host "=== TEST INTEGRACION MODULO [ModuleName] ===" -ForegroundColor Cyan

# Cargar dependencias v1.0.1
. .\Utils\Logging-Utils.ps1
. .\Core\Dashboard-Init.ps1
$dashConfig = Initialize-DashboardConfig

# Cargar módulo v2.0
Import-Module .\Modules\[ModuleName].psm1 -Force

# Test 1: Función existe
Write-Host "`n[TEST 1] Función [FunctionName] existe..." -ForegroundColor Yellow
$function = Get-Command [FunctionName] -ErrorAction SilentlyContinue
if ($function) {
    Write-Host "[OK] Función encontrada" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Función NO encontrada" -ForegroundColor Red
    exit 1
}

# Test 2: Ejecución básica
Write-Host "`n[TEST 2] Ejecutar función básica..." -ForegroundColor Yellow
try {
    $result = [FunctionName] -Config $dashConfig
    Write-Host "[OK] Ejecución exitosa" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Ejecución falló: $_" -ForegroundColor Red
    exit 1
}

# Test 3: Validar output
Write-Host "`n[TEST 3] Validar output..." -ForegroundColor Yellow
if ($result -ne $null) {
    Write-Host "[OK] Output válido" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Output es null" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== TODOS LOS TESTS PASADOS ===" -ForegroundColor Green
```

---

## 🔌 Integración en Dashboard

### Paso 1: Cargar Módulo en Dashboard.ps1

```powershell
# Dashboard.ps1 - Después de bloque v1.0.1 (línea ~106)

# ============================================
# CARGA DE MODULOS v2.0
# ============================================

$modulesPath = Join-Path $ScriptRoot "Modules"
$modulesToLoad = @(
    "DashboardContent.psm1",
    "ParadiseTheme.psm1",
    "ParadiseCards.psm1",
    "ParadiseBoxes.psm1",
    "ParadiseLayout.psm1"
)

$Global:LoadedModulesV2 = @{}

foreach ($moduleName in $modulesToLoad) {
    $modulePath = Join-Path $modulesPath $moduleName

    if (Test-Path $modulePath) {
        try {
            Import-Module $modulePath -Force -ErrorAction Stop
            Write-Host "[OK] Módulo v2.0 cargado: $moduleName" -ForegroundColor Cyan
            $Global:LoadedModulesV2[$moduleName] = $true
        } catch {
            Write-Host "[WARN] Error al cargar $moduleName : $_" -ForegroundColor Yellow
            $Global:LoadedModulesV2[$moduleName] = $false
        }
    } else {
        Write-Host "[INFO] Módulo v2.0 no encontrado: $moduleName" -ForegroundColor Gray
        $Global:LoadedModulesV2[$moduleName] = $false
    }
}

# Resumen de carga
$loadedCount = ($Global:LoadedModulesV2.Values | Where-Object { $_ -eq $true }).Count
$totalCount = $modulesToLoad.Count
Write-Host "[INFO] Módulos v2.0 cargados: $loadedCount/$totalCount" -ForegroundColor $(if($loadedCount -eq $totalCount){'Green'}else{'Yellow'})
```

### Paso 2: Usar Funciones v2.0

```powershell
# Dashboard.ps1 - En scriptblock del dashboard

$dashboard = New-UDDashboard -Title "Paradise Dashboard" -Content {

    # Usar función v2.0 con fallback
    if ($Global:LoadedModulesV2["ParadiseTheme.psm1"]) {
        $cssBlock = Get-ParadiseGlobalCSS -Config $Cache:Config
    } else {
        # Fallback a v1.0.1
        $cssBlock = Get-ParadiseGlobalCSS -Config $Cache:Config
    }

    # Header con fallback
    if ($Global:LoadedModulesV2["ParadiseLayout.psm1"]) {
        New-ParadiseHeader -Config $Cache:Config
    } else {
        New-DashboardHeader -Config $Cache:Config
    }

    # Resto del contenido...
}
```

### Paso 3: Logging de Uso

```powershell
# Agregar logging para trackear uso de v1.0.1 vs v2.0

function Write-ModuleUsageLog {
    param(
        [string]$FunctionName,
        [string]$Version  # "v1.0.1" o "v2.0"
    )

    $logFile = "C:\ProgramData\WPE-Dashboard\Logs\module-usage-$(Get-Date -Format 'yyyy-MM').log"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[$timestamp] $FunctionName - $Version"

    Add-Content -Path $logFile -Value $logLine
}

# Uso en Dashboard.ps1
if ($Global:LoadedModulesV2["ParadiseTheme.psm1"]) {
    $cssBlock = Get-ParadiseGlobalCSS -Config $Cache:Config
    Write-ModuleUsageLog -FunctionName "Get-ParadiseGlobalCSS" -Version "v2.0"
} else {
    $cssBlock = Get-ParadiseGlobalCSS -Config $Cache:Config
    Write-ModuleUsageLog -FunctionName "Get-ParadiseGlobalCSS" -Version "v1.0.1"
}
```

---

## ⚠️ Deprecación de v1.0.1

### Fase 3: Marcar como Deprecated

```powershell
# UI/Dashboard-UI.ps1 - Añadir atributo Obsolete

function Get-ParadiseGlobalCSS {
    [Obsolete("Migrado a Modules/ParadiseTheme.psm1 v2.0. Será eliminado en v2.1.0")]
    param([hashtable]$Config)

    Write-Warning "Get-ParadiseGlobalCSS v1.0.1 está deprecated. Use ParadiseTheme v2.0"

    # Código original sin cambios...
}
```

### Fase 4: Eliminar Código v1.0.1

**Criterios para eliminar:**

1. ✅ Módulo v2.0 completado y testeado
2. ✅ Dashboard usa v2.0 por defecto
3. ✅ Sin errores en 1 mes de uso
4. ✅ Logs confirman uso 100% v2.0
5. ✅ Backup de v1.0.1 existe

**Proceso de eliminación:**

```powershell
# 1. Backup final
$backupPath = "C:\ProgramData\WPE-Dashboard\Backup\v1.0.1-Final-$(Get-Date -Format 'yyyyMMdd')"
New-Item -ItemType Directory -Path $backupPath -Force
Copy-Item ".\UI\Dashboard-UI.ps1" -Destination $backupPath

# 2. Eliminar funciones de UI/Dashboard-UI.ps1
# Editar manualmente o con script

# 3. Test completo
.\Tools\Test-Hybrid-Integration.ps1

# 4. Commit
git add UI/Dashboard-UI.ps1
git commit -m "Remove [FunctionName] v1.0.1 (migrated to v2.0)"
git push

# 5. Monitorear logs por 1 semana
Get-Content ".\Logs\dashboard-*.log" | Select-String "ERROR"
```

### Plan de Rollback

```powershell
# Si hay problemas después de eliminar v1.0.1:

# 1. Detener dashboard
.\Tools\Detener-Dashboard.ps1

# 2. Restaurar desde backup
Copy-Item "$backupPath\Dashboard-UI.ps1" -Destination ".\UI\" -Force

# 3. Recargar dashboard
.\Dashboard.ps1

# 4. Reportar issue
# Crear issue en GitHub con:
# - Logs de error
# - Pasos para reproducir
# - Configuración del sistema
```

---

## ✅ Checklist de Migración

### Por Cada Función

- [ ] **Preparación**
  - [ ] Leer función en v1.0.1
  - [ ] Identificar dependencias externas
  - [ ] Identificar dependencias de otras funciones v1.0.1
  - [ ] Verificar compatibilidad con UD Community v2.9.0

- [ ] **Implementación**
  - [ ] Crear/modificar módulo v2.0
  - [ ] Copiar lógica de función
  - [ ] Agregar validaciones mejoradas
  - [ ] Documentar con CBH (Comment-Based Help)
  - [ ] Agregar manejo de errores
  - [ ] Exportar función con `Export-ModuleMember`

- [ ] **Testing**
  - [ ] Crear test unitario Pester
  - [ ] Ejecutar test manual
  - [ ] Verificar output idéntico a v1.0.1
  - [ ] Test de integración con Dashboard

- [ ] **Integración**
  - [ ] Cargar módulo en Dashboard.ps1
  - [ ] Implementar fallback a v1.0.1
  - [ ] Agregar logging de uso
  - [ ] Verificar dashboard inicia correctamente

- [ ] **Documentación**
  - [ ] Actualizar README del módulo
  - [ ] Documentar cambios en CHANGELOG
  - [ ] Actualizar esta guía si es necesario

- [ ] **Deprecación** (Fase 3)
  - [ ] Marcar función v1.0.1 como Obsolete
  - [ ] Agregar warning en logs
  - [ ] Switchover: usar v2.0 por defecto

- [ ] **Eliminación** (Fase 4)
  - [ ] Verificar 1 mes estable
  - [ ] Backup final v1.0.1
  - [ ] Eliminar código v1.0.1
  - [ ] Test completo
  - [ ] Commit y push

### Por Cada Módulo

- [ ] **Módulo: ParadiseTheme.psm1**
  - [ ] Migrar Get-ParadiseGlobalCSS

- [ ] **Módulo: ParadiseLayout.psm1**
  - [ ] Migrar New-DashboardHeader
  - [ ] Migrar New-SectionSeparator
  - [ ] Migrar New-DashboardFooter
  - [ ] Migrar New-ActionButton
  - [ ] Migrar New-CategoryBox

- [ ] **Módulo: ParadiseCards.psm1**
  - [ ] Migrar New-SystemInfoCard
  - [ ] Migrar New-CriticalActionsCard

- [ ] **Módulo: ParadiseBoxes.psm1**
  - [ ] Migrar New-CodeBox
  - [ ] Migrar New-SuccessBox
  - [ ] Migrar New-WarningBox
  - [ ] Migrar New-DangerBox

- [ ] **Módulo: DashboardContent.psm1**
  - [x] Migrar New-DashboardContent → New-ParadiseModuleDemo ✅
  - [ ] Migrar lógica completa de New-DashboardContent (602 líneas)

---

## 🔧 Troubleshooting

### Problema 1: Módulo NO se Carga

**Síntoma:**
```
[WARN] Error al cargar ParadiseTheme v2.0: [error message]
```

**Diagnóstico:**
```powershell
# Verificar ruta del módulo
$modulePath = "C:\ProgramData\WPE-Dashboard\Modules\ParadiseTheme.psm1"
Test-Path $modulePath  # Debe ser True

# Intentar importar manualmente
Import-Module $modulePath -Force -Verbose
# Observar mensajes de error
```

**Soluciones:**
- Verificar sintaxis del .psm1 (errores de parseo)
- Verificar permisos del archivo
- Verificar que no haya caracteres no-ASCII
- Usar `-Verbose` para diagnóstico detallado

### Problema 2: Función NO Exportada

**Síntoma:**
```powershell
Get-Command Get-ParadiseGlobalCSS -Module ParadiseTheme
# Resultado: ERROR - Comando no encontrado
```

**Diagnóstico:**
```powershell
# Verificar exports del módulo
Get-Module ParadiseTheme | Select-Object -ExpandProperty ExportedCommands
# Debería listar la función

# Verificar línea Export-ModuleMember
Select-String "Export-ModuleMember" .\Modules\ParadiseTheme.psm1
```

**Soluciones:**
- Asegurar que existe línea `Export-ModuleMember -Function 'Get-ParadiseGlobalCSS'`
- Nombre de función debe coincidir exactamente (case-sensitive)
- Reimportar módulo con `-Force`

### Problema 3: Conflicto de Nombres

**Síntoma:**
```
WARNING: The names of some imported commands from the module 'ParadiseTheme' include unapproved verbs
```
O función v2.0 no se llama (se usa v1.0.1 en su lugar).

**Diagnóstico:**
```powershell
# Listar todas las funciones con mismo nombre
Get-Command Get-ParadiseGlobalCSS -All

# Ver de qué módulo/script viene cada una
Get-Command Get-ParadiseGlobalCSS -All | Select-Object Name, Source, ModuleName
```

**Soluciones:**
- Renombrar función v2.0 con prefijo: `New-ParadiseSystemCard` (no `New-SystemInfoCard`)
- Usar `-Prefix` al importar módulo: `Import-Module ParadiseTheme -Prefix Paradise`
- Eliminar v1.0.1 de scope global antes de cargar v2.0

### Problema 4: Parámetros Incompatibles

**Síntoma:**
```
No se puede resolver el conjunto de parámetros usando los parámetros con nombre especificados
```

**Diagnóstico:**
```powershell
# Ver firma de la función
Get-Command Get-ParadiseGlobalCSS -Syntax

# Comparar con llamada en código
Select-String "Get-ParadiseGlobalCSS" .\Dashboard.ps1
```

**Soluciones:**
- Asegurar que parámetros de v2.0 son compatibles con v1.0.1
- Agregar parámetros opcionales con valores por defecto
- Usar `[Parameter(Mandatory=$false)]` para backwards compatibility

### Problema 5: Dependencias Circulares

**Síntoma:**
Dashboard no inicia, error de carga de módulos.

**Diagnóstico:**
```powershell
# Trazar orden de carga
Write-Host "[DEBUG] Cargando módulo A" -ForegroundColor Magenta
Import-Module .\Modules\ModuloA.psm1 -Force
Write-Host "[DEBUG] Cargando módulo B" -ForegroundColor Magenta
Import-Module .\Modules\ModuloB.psm1 -Force
```

**Soluciones:**
- Evitar que módulos importen otros módulos Paradise
- Extraer funciones compartidas a módulo común `ParadiseCore.psm1`
- Documentar dependencias en README

### Problema 6: Performance Degradado

**Síntoma:**
Dashboard arranca más lento después de migración.

**Diagnóstico:**
```powershell
# Medir tiempo de carga de cada módulo
Measure-Command { Import-Module .\Modules\ParadiseTheme.psm1 -Force }
# Comparar con v1.0.1
Measure-Command { . .\UI\Dashboard-UI.ps1 }
```

**Soluciones:**
- Lazy loading: cargar módulos solo cuando se usan
- Eliminar código debug/logging en producción
- Usar `-Force` solo cuando es necesario
- Cachear resultados de funciones costosas

---

## 📚 Referencias

### Documentación Relacionada

- [00_Plan_Modularizacion.md](00_Plan_Modularizacion.md) - Plan completo del proyecto
- [01_Analisis_Visual_UI.md](01_Analisis_Visual_UI.md) - Análisis estético
- [02_Analisis_Modularidad.md](02_Analisis_Modularidad.md) - Análisis de arquitectura
- [03_Arquitectura_Hibrida.md](03_Arquitectura_Hibrida.md) - Arquitectura actual
- [05_Comparativa_v1_v2.md](05_Comparativa_v1_v2.md) - Evolución del proyecto
- [HOTFIX_Conflicto_Nombres.md](HOTFIX_Conflicto_Nombres.md) - Errores resueltos

### Archivos de Referencia

- [Modules/DashboardContent.psm1](../../Modules/DashboardContent.psm1) - Módulo demo completado
- [UI/Dashboard-UI.ps1](../../UI/Dashboard-UI.ps1) - Código v1.0.1 a migrar
- [Dashboard.ps1](../../Dashboard.ps1) - Entry point con integración híbrida

### Herramientas de Testing

- [Tools/Test-Hybrid-Integration.ps1](../../Tools/Test-Hybrid-Integration.ps1) - Test de integración
- [Tools/Test-Individual-Functions.ps1](../../Tools/Test-Individual-Functions.ps1) - Test de funciones
- [05_Test_Unitarios_Modularizacion.ps1](05_Test_Unitarios_Modularizacion.ps1) - Suite Pester

### Recursos Externos

- [PowerShell Modules Documentation](https://docs.microsoft.com/powershell/scripting/developer/module/writing-a-windows-powershell-module)
- [UniversalDashboard Community Docs](https://docs.universaldashboard.io/)
- [Pester Documentation](https://pester.dev/docs/quick-start)

---

## 🎯 Métricas de Progreso

### Estado Actual (2025-11-08)

| Métrica | v1.0.1 | v2.0 | Meta |
|---------|--------|------|------|
| **Módulos** | 1 monolito | 1 módulo | 5 módulos |
| **Funciones Migradas** | 13 | 1 | 13 |
| **Líneas en Módulos** | 0 | 98 | ~758 |
| **Líneas en Monolito** | 643 | 643 | 0 |
| **% Completado** | 0% | 7.7% | 100% |

### Estimación de Esfuerzo

| Tarea | Tiempo Estimado | Prioridad |
|-------|----------------|-----------|
| Migrar Get-ParadiseGlobalCSS | 2 horas | Alta |
| Migrar New-SectionSeparator | 1 hora | Alta |
| Migrar New-DashboardHeader | 2 horas | Alta |
| Migrar New-DashboardFooter | 2 horas | Media |
| Migrar 4 Boxes (Code, Success, Warning, Danger) | 4 horas | Media |
| Migrar New-ActionButton | 3 horas | Media |
| Migrar New-CategoryBox | 4 horas | Alta |
| Migrar New-SystemInfoCard | 3 horas | Alta |
| Migrar New-CriticalActionsCard | 4 horas | Alta |
| Migrar New-DashboardContent (completa) | 8 horas | Crítica |
| Tests Pester para todos los módulos | 8 horas | Alta |
| Documentación completa | 4 horas | Media |
| **TOTAL** | **45 horas** (~1 sprint) | |

---

## ✍️ Notas Finales

### Filosofía de Migración

**"Gradual, no disruptiva"** - Cada función migrada debe:
1. Coexistir con v1.0.1 sin conflictos
2. Tener tests que validen paridad con v1.0.1
3. Ser opt-in (no forzar uso inmediato)
4. Permitir rollback instantáneo

### Lecciones Aprendidas del Caso 10

1. **Renombrar funciones con conflicto de nombres** - Ver [HOTFIX_Conflicto_Nombres.md](HOTFIX_Conflicto_Nombres.md)
2. **Validar compatibilidad con UD Community v2.9.0** - `New-UDHeading` no acepta `-Content`
3. **Testing exhaustivo antes de deploy** - 33 tests salvaron el proyecto
4. **Backups son críticos** - Permitieron rollback seguro

### Contacto y Soporte

**Issues:** Reportar en GitHub o documentar en `Docs/Caso_10_Restauracion_Modular_v2.0/`

**Contribuciones:** Seguir esta guía para mantener consistencia en migraciones

---

**Fin de la Guía de Migración**
**Paradise-SystemLabs © 2025**
**Caso 10 - Restauración Modular v2.0**
