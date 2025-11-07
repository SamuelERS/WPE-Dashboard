# 🏗️ PROPUESTA DE ARQUITECTURA MODULAR - PARTE 2
## Dashboard IT - Paradise-SystemLabs

**Fecha:** 7 de Noviembre, 2025  
**Versión:** 1.0 - Parte 2 de 3  
**Propósito:** Integración, Ejecución y Convenciones del Sistema Modular

**Audiencia:** Arquitectos de Software, Líderes Técnicos y Desarrolladores  
**Tiempo de lectura:** 40 minutos

---

## 📌 NOTA DE CONTINUIDAD

Este documento es la **continuación** de:
- **03-PROPUESTA-ARQUITECTURA-MODULAR.md** (Secciones 1-5)

Para contexto completo, leer primero el documento 03 que contiene:
1. Resumen Ejecutivo
2. Principios Arquitectónicos
3. Arquitectura Objetivo
4. Roles y Responsabilidades
5. Estructura de Carpetas Detallada

**Siguiente documento:**
- **03-2-PROPUESTA-ARQUITECTURA-MODULAR-C.md** (Secciones 11-17)

---

## 📑 TABLA DE CONTENIDOS

### Secciones en este Documento (6-10)
6. [Integración de ScriptLoader](#6-integracion-de-scriptloader)
7. [Generación Dinámica de UI](#7-generacion-dinamica-de-ui)
8. [Flujo de Ejecución Modular](#8-flujo-de-ejecucion-modular)
9. [Convenciones y Estándares](#9-convenciones-y-estandares)
10. [Separación de Responsabilidades](#10-separacion-de-responsabilidades)

---

## 6. INTEGRACIÓN DE SCRIPTLOADER

### 6.1 Estado Actual del ScriptLoader

**Referencia:** Según **01-INFORME-AUDITORIA-TECNICA.md**, el ScriptLoader.ps1 existe pero no está integrado con Dashboard.ps1.

**Ubicación:** `Scripts/ScriptLoader.ps1`

**Funciones Existentes:**
```powershell
function Get-ScriptsByCategory($Category) { ... }
function Get-ScriptMetadata($ScriptPath) { ... }
$Global:DashboardCategories = @{ ... }
```

**Problema:** Dashboard.ps1 no importa ni utiliza estas funciones.

### 6.2 API Mínima del ScriptLoader

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
        Description = "Sin descripción"
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
            throw "El script no retornó formato válido"
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

### 6.3 Integración con Dashboard.ps1

**Paso 1: Importar ScriptLoader**

```powershell
# En Dashboard.ps1, después de importar Utils/ y Components/
$scriptLoaderPath = Join-Path $Global:DashboardRoot "Scripts\ScriptLoader.ps1"
if (Test-Path $scriptLoaderPath) {
    . $scriptLoaderPath
    Write-Host "✅ ScriptLoader importado" -ForegroundColor Green
} else {
    Write-Host "❌ ScriptLoader no encontrado" -ForegroundColor Red
    exit 1
}
```

**Paso 2: Cargar Categorías desde Config**

```powershell
$categoriesConfig = Load-CategoriesConfig

foreach ($category in $categoriesConfig.categories | Sort-Object order) {
    $scripts = Get-ScriptsByCategory -Category $category.path
    
    if ($scripts.Count -gt 0) {
        # Generar sección de UI para esta categoría
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

### 6.4 Validación de Scripts

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

## 7. GENERACIÓN DINÁMICA DE UI

### 7.1 Concepto de UI Dinámica

**Objetivo:** Generar botones y formularios automáticamente basándose en metadata de scripts.

**Beneficios:**
- ✅ Agregar funcionalidad = crear script con metadata
- ✅ No modificar Dashboard.ps1
- ✅ UI consistente automáticamente
- ✅ Menos código duplicado

### 7.2 Generación de Botones por Metadata

**Función en Components/UI-Components.ps1:**

```powershell
function New-ScriptButton {
    param(
        [Parameter(Mandatory=$true)][hashtable]$Metadata,
        [Parameter(Mandatory=$true)][string]$ScriptPath
    )
    
    # Determinar tipo de botón según permisos
    $buttonType = if ($Metadata.RequiresAdmin) { "warning" } else { "primary" }
    $buttonText = $Metadata.Name
    if ($Metadata.RequiresAdmin) {
        $buttonText = "🔒 $buttonText"
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

### 7.3 Generación de Formularios Dinámicos

**Función en Components/Form-Components.ps1:**

```powershell
function New-ScriptForm {
    param(
        [Parameter(Mandatory=$true)][hashtable]$Metadata,
        [Parameter(Mandatory=$true)][string]$ScriptPath
    )
    
    New-UDCard -Title $Metadata.Name -Content {
        # Descripción
        New-UDElement -Tag "p" -Content $Metadata.Description
        
        # Generar campos dinámicamente
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
        
        # Botones de acción
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

### 7.4 Generación de Secciones por Categoría

**En Dashboard.ps1:**

```powershell
$categoriesConfig = Load-CategoriesConfig

foreach ($category in $categoriesConfig.categories | Sort-Object order) {
    $scripts = Get-ScriptsByCategory -Category $category.path
    
    if ($scripts.Count -eq 0) {
        continue
    }
    
    # Crear sección para categoría
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
# @FormField: password|Contraseña|password
# @FormField: tipoUsuario|Tipo de usuario|select
```

**UI Generada Automáticamente:**
```
┌─────────────────────────────────────┐
│ 🔒 Crear Usuario del Sistema        │  ← Botón generado
└─────────────────────────────────────┘
         │ (Click)
         ▼
┌─────────────────────────────────────┐
│ Crear Usuario del Sistema           │  ← Modal generado
│                                     │
│ Crea un usuario local de Windows   │  ← Descripción
│                                     │
│ [Nombre del usuario        ]        │  ← Campo textbox
│ [Contraseña (oculta)       ]        │  ← Campo password
│ [Tipo de usuario ▼         ]        │  ← Campo select
│                                     │
│ [Ejecutar]  [Cancelar]              │  ← Botones
└─────────────────────────────────────┘
```

---

## 8. FLUJO DE EJECUCIÓN MODULAR

### 8.1 Flujo Completo End-to-End

**Diagrama de Secuencia:**

```
Usuario → Dashboard.ps1 → ScriptLoader → Script Modular → Utils/ → Sistema OS

1. Usuario abre navegador (localhost:10000)
   ↓
2. Dashboard.ps1 inicia
   ├─ Cargar Config/*.json
   ├─ Importar Utils/*.ps1
   ├─ Importar Components/*.ps1
   └─ Importar ScriptLoader.ps1
   ↓
3. Descubrimiento de scripts
   ├─ Para cada categoría:
   │  ├─ Get-ScriptsByCategory($category)
   │  └─ Get-ScriptMetadata($script)
   └─ Almacenar en caché
   ↓
4. Generación de UI
   ├─ Para cada categoría con scripts:
   │  ├─ New-CategorySection($category)
   │  └─ Para cada script:
   │     └─ New-ScriptButton($metadata)
   └─ Start-UDDashboard
   ↓
5. Usuario hace click en botón
   ↓
6. Si HasForm = true:
   ├─ Show-UDModal(New-ScriptForm($metadata))
   ├─ Usuario llena formulario
   └─ Click en "Ejecutar"
   ↓
7. Invoke-DashboardScript($scriptPath, $params)
   ├─ Validar script existe
   ├─ Ejecutar: & $scriptPath @params
   └─ Validar respuesta
   ↓
8. Script modular ejecuta
   ├─ Importar Utils/*.ps1
   ├─ Validar parámetros (Utils/Validation-Utils.ps1)
   ├─ Ejecutar lógica de negocio
   ├─ Interactuar con Sistema OS
   ├─ Logging (Utils/Logging-Utils.ps1)
   └─ Retornar @{ Success, Message, Data }
   ↓
9. Dashboard.ps1 recibe resultado
   ├─ Hide-UDModal (si había modal)
   └─ Show-UDToast($result.Message)
   ↓
10. Usuario ve notificación de resultado
```

### 8.2 Manejo de Errores

**Puntos de Fallo y Manejo:**

```
1. Script no encontrado
   └─ Catch en Invoke-DashboardScript
      └─ Retornar @{ Success = $false; Message = "Script no encontrado" }

2. Metadata inválida
   └─ Validación en Test-ScriptValid
      └─ No generar botón para ese script

3. Error en ejecución del script
   └─ Try/Catch en el script modular
      └─ Retornar @{ Success = $false; Message = "Error: ..." }

4. Parámetros faltantes
   └─ [Parameter(Mandatory=$true)] en script
      └─ PowerShell lanza error
         └─ Catch en Invoke-DashboardScript

5. Permisos insuficientes
   └─ Test-AdminPrivileges en script
      └─ Retornar @{ Success = $false; Message = "Requiere admin" }
```

### 8.3 Logging del Flujo

**Puntos de Logging:**

```powershell
# 1. Inicio del dashboard
Write-DashboardLog -Message "Dashboard iniciado" -Level "Info"

# 2. Carga de scripts
Write-DashboardLog -Message "Cargados $($scripts.Count) scripts" -Level "Info"

# 3. Ejecución de script
Write-DashboardLog -Message "Ejecutando: $scriptPath" -Level "Info"

# 4. Resultado
if ($result.Success) {
    Write-DashboardLog -Message "Éxito: $($result.Message)" -Level "Info"
} else {
    Write-DashboardLog -Message "Error: $($result.Message)" -Level "Error"
}
```

---

## 9. CONVENCIONES Y ESTÁNDARES

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
✅ Crear-Usuario-Sistema.ps1
✅ Cambiar-Nombre-PC.ps1
✅ Limpiar-Archivos-Temporales.ps1
✅ Obtener-Info-Sistema.ps1

Ejemplos incorrectos:
❌ crear_usuario.ps1
❌ CrearUsuario.ps1
❌ crear-usuario-sistema.ps1
```

#### Funciones PowerShell
```
Formato: Verb-Noun (PowerShell estándar)

Ejemplos:
✅ Test-AdminPrivileges
✅ Get-FilteredLocalUsers
✅ New-CustomButton
✅ Write-DashboardLog

❌ CheckAdmin
❌ getUsers
❌ createButton
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

### 9.2 Estándares de Metadata

**Metadata Obligatoria:**
```powershell
# @Name: Nombre descriptivo del script
# @Description: Qué hace el script (1-2 líneas)
# @RequiresAdmin: true/false
# @HasForm: true/false
```

**Metadata Opcional:**
```powershell
# @Category: Configuracion (si no está en carpeta de categoría)
# @Version: 1.0
# @Author: Nombre del desarrollador
# @LastModified: 2025-11-07
```

**Metadata de Formulario:**
```powershell
# @FormField: nombreCampo|Placeholder|tipo
# Tipos válidos: textbox, password, select, checkbox
```

### 9.3 Estándares de Código

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
        throw "Entrada inválida"
    }
    
    # 2. Lógica de negocio
    # ...
    
    # 3. Logging
    Write-DashboardLog -Message "Operación exitosa" -Level "Info"
    
    # 4. Retorno estructurado
    return @{
        Success = $true
        Message = "Operación completada exitosamente"
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

### 9.4 Estándares de Logging

**Niveles de Log:**
```
Info    - Operaciones normales
Warning - Situaciones inusuales pero manejables
Error   - Errores que impiden completar operación
Critical - Errores que afectan funcionamiento del sistema
```

**Formato de Log:**
```
[YYYY-MM-DD HH:mm:ss] [LEVEL] [Component] Message

Ejemplo:
[2025-11-07 14:30:15] [Info] [ScriptLoader] Cargados 5 scripts de Configuracion
[2025-11-07 14:30:20] [Error] [Crear-Usuario] Error: Usuario ya existe
```

### 9.5 Estándares de Comentarios

**Comentarios en Código:**
```powershell
# Comentario de una línea para explicar QUÉ hace el código

# Comentario multi-línea para explicar POR QUÉ
# se hace algo de cierta manera, especialmente
# si no es obvio

<#
.SYNOPSIS
Descripción breve de la función

.DESCRIPTION
Descripción detallada

.PARAMETER NombreParametro
Descripción del parámetro

.EXAMPLE
Ejemplo de uso
#>
```

---

## 10. SEPARACIÓN DE RESPONSABILIDADES

### 10.1 Capas de la Aplicación

**Referencia:** Basado en principios de **03-PROPUESTA-ARQUITECTURA-MODULAR.md** Sección 2.1

```
Capa 1: Presentación (UI)
├─ Responsable: Components/ + UniversalDashboard
├─ Qué hace: Renderizar UI, capturar entrada, mostrar resultados
└─ NO debe: Contener lógica de negocio, acceder a OS

Capa 2: Orquestación
├─ Responsable: Dashboard.ps1
├─ Qué hace: Coordinar componentes, generar UI, gestionar ciclo de vida
└─ NO debe: Implementar funcionalidades, tener código inline

Capa 3: Lógica de Negocio
├─ Responsable: Scripts/
├─ Qué hace: Implementar funcionalidades, validar reglas, interactuar con OS
└─ NO debe: Definir UI, gestionar configuración global

Capa 4: Utilidades
├─ Responsable: Utils/
├─ Qué hace: Funciones reutilizables, validaciones, logging
└─ NO debe: Mantener estado, depender de componentes específicos

Capa 5: Configuración
├─ Responsable: Config/
├─ Qué hace: Almacenar configuración del sistema
└─ NO debe: Contener código ejecutable (excepto Config-Loader.ps1)
```

### 10.2 Separación UI / Lógica / Validación

#### UI (Components/)
```powershell
# ✅ CORRECTO - Solo UI
function New-CustomButton {
    param($Text, $OnClick, $Type)
    
    New-UDButton -Text $Text -OnClick $OnClick -Style @{
        backgroundColor = $theme.colors[$Type]
        # ... estilos
    }
}

# ❌ INCORRECTO - UI con lógica de negocio
function New-UserButton {
    New-UDButton -Text "Crear Usuario" -OnClick {
        # ❌ NO: Lógica de negocio en componente UI
        $user = New-LocalUser -Name $username -Password $password
    }
}
```

#### Lógica de Negocio (Scripts/)
```powershell
# ✅ CORRECTO - Solo lógica
param([string]$nombreUsuario, [string]$password)

. "$PSScriptRoot\..\..\Utils\Validation-Utils.ps1"

try {
    # Validar usando Utils/
    if (-not (Test-ValidUsername $nombreUsuario)) {
        throw "Usuario inválido"
    }
    
    # Lógica de negocio
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    New-LocalUser -Name $nombreUsuario -Password $securePassword
    
    return @{ Success = $true; Message = "Usuario creado" }
} catch {
    return @{ Success = $false; Message = "Error: $_" }
}

# ❌ INCORRECTO - Lógica con UI embebida
param([string]$nombreUsuario)

try {
    New-LocalUser -Name $nombreUsuario
    # ❌ NO: UI en script de lógica
    Show-UDToast -Message "Usuario creado"
} catch {
    # ❌ NO: UI en script de lógica
    Show-UDToast -Message "Error"
}
```

#### Validaciones (Utils/)
```powershell
# ✅ CORRECTO - Validaciones reutilizables
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

# ❌ INCORRECTO - Validación con lógica de negocio
function Test-ValidUsername {
    param([string]$Username)
    
    # Validación OK
    if ($Username.Length -lt 3) {
        return $false
    }
    
    # ❌ NO: Lógica de negocio en validación
    $existingUser = Get-LocalUser -Name $Username -ErrorAction SilentlyContinue
    if ($existingUser) {
        return $false
    }
}
```

### 10.3 Reglas de Dependencia

**Regla 1: Las capas superiores pueden depender de las inferiores, pero no al revés**

```
Dashboard.ps1 (Capa 2)
├─ ✅ Puede usar: Components/, Utils/, Config/, Scripts/
└─ ❌ No puede: N/A (es la capa superior)

Components/ (Capa 1)
├─ ✅ Puede usar: Config/ (para tema)
└─ ❌ No puede: Scripts/, Utils/, Dashboard.ps1

Scripts/ (Capa 3)
├─ ✅ Puede usar: Utils/, Config/
└─ ❌ No puede: Components/, Dashboard.ps1

Utils/ (Capa 4)
├─ ✅ Puede usar: Config/ (para configuración de logging)
└─ ❌ No puede: Components/, Scripts/, Dashboard.ps1

Config/ (Capa 5)
├─ ✅ Puede usar: Nada (capa más baja)
└─ ❌ No puede: Todo lo demás
```

**Regla 2: Los scripts modulares son independientes entre sí**

```
✅ CORRECTO:
Scripts/Configuracion/Crear-Usuario.ps1
└─ Puede usar: Utils/

❌ INCORRECTO:
Scripts/Configuracion/Crear-Usuario.ps1
└─ NO puede usar: Scripts/Mantenimiento/Limpiar-Archivos.ps1
```

### 10.4 Ejemplo Completo de Separación

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

**2. Orquestación (Dashboard.ps1):**
```powershell
# Solo coordina
$metadata = Get-ScriptMetadata -ScriptPath $scriptPath
New-ScriptButton -Metadata $metadata -ScriptPath $scriptPath
```

**3. Lógica de Negocio (Scripts/Configuracion/Crear-Usuario-Sistema.ps1):**
```powershell
param([string]$nombreUsuario, [string]$password)

. "$PSScriptRoot\..\..\Utils\Validation-Utils.ps1"

try {
    # Usa validación de Utils/
    if (-not (Test-ValidUsername $nombreUsuario)) {
        throw "Usuario inválido"
    }
    
    # Lógica de negocio
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

**5. Configuración (Config/dashboard-config.json):**
```json
{
  "users": {
    "minUsernameLength": 3,
    "maxUsernameLength": 20
  }
}
```

### 10.5 Beneficios de la Separación

**Testabilidad:**
```powershell
# ✅ Fácil de testear
Describe "Test-ValidUsername" {
    It "Rechaza usernames cortos" {
        Test-ValidUsername -Username "ab" | Should -Be $false
    }
    
    It "Acepta usernames válidos" {
        Test-ValidUsername -Username "usuario123" | Should -Be $true
    }
}
```

**Reutilización:**
```powershell
# Validación usada en múltiples scripts
Scripts/Configuracion/Crear-Usuario-Sistema.ps1
└─ Test-ValidUsername

Scripts/POS/Crear-Usuario-POS.ps1
└─ Test-ValidUsername

Scripts/Auditoria/Verificar-Usuarios.ps1
└─ Test-ValidUsername
```

**Mantenibilidad:**
```
Cambiar validación de username:
├─ Antes (monolítico): Modificar en 7 lugares
└─ Ahora (modular): Modificar en 1 lugar (Utils/Validation-Utils.ps1)
```

---

## DOCUMENTOS RELACIONADOS

### Documentos Anteriores
1. **03-PROPUESTA-ARQUITECTURA-MODULAR.md** - Secciones 1-5 (Fundamentos)

### Documentos Base
2. **00-RESUMEN-EJECUTIVO.md** - Visión general de auditoría
3. **01-INFORME-AUDITORIA-TECNICA.md** - Análisis técnico detallado
4. **02-MAPA-DEPENDENCIAS-Y-COMPONENTES.md** - Relaciones entre componentes

### Siguiente Documento
5. **03-2-PROPUESTA-ARQUITECTURA-MODULAR-C.md** - Secciones 11-17 (Escalabilidad)

---

## 📦 ENTREGA B - COMPLETADA

### Cambios Incluidos en esta Entrega

**Secciones Completadas:**
6. ✅ **Integración de ScriptLoader** - API mínima, integración con Dashboard.ps1, validación de scripts
7. ✅ **Generación Dinámica de UI** - Botones y formularios automáticos basados en metadata
8. ✅ **Flujo de Ejecución Modular** - Diagrama end-to-end, manejo de errores, logging
9. ✅ **Convenciones y Estándares** - Nombres, metadata, código, logging, comentarios
10. ✅ **Separación de Responsabilidades** - Capas, reglas de dependencia, ejemplos completos

**Contenido Generado:**
- Funciones completas de ScriptLoader (Get-ScriptsByCategory, Get-ScriptMetadata, Invoke-DashboardScript)
- Funciones de generación dinámica de UI (New-ScriptButton, New-ScriptForm)
- Diagrama de flujo de ejecución completo
- Estándares de nombres para scripts, funciones, archivos JSON y variables
- Estructura estándar de script modular
- Ejemplos de separación UI/Lógica/Validación
- Reglas de dependencia entre capas

**Referencias a Documentos Base:**
- **01-INFORME-AUDITORIA-TECNICA.md** - Estado actual del ScriptLoader
- **03-PROPUESTA-ARQUITECTURA-MODULAR.md** - Principios arquitectónicos (Sección 2.1)

**Conceptos Clave:**
- UI dinámica basada en metadata
- Separación estricta de responsabilidades
- Flujo modular end-to-end
- Convenciones consistentes
- Manejo robusto de errores

**Próxima Entrega (C):**
- Secciones 11-17 en **03-2-PROPUESTA-ARQUITECTURA-MODULAR-C.md**:
  - Comunicación entre Componentes
  - Estrategia de Reducción (793 → ~300 líneas)
  - Escalabilidad a 50+ Funcionalidades
  - Portabilidad y Configuración
  - Seguridad y Permisos
  - Riesgos y Mitigación
  - Buenas Prácticas PowerShell + UD

---

**Preparado por:** Sistema de Análisis Arquitectónico  
**Fecha:** 7 de Noviembre, 2025  
**Versión:** 1.0 - Parte 2 de 3  
**Confidencialidad:** Interno - Paradise-SystemLabs
