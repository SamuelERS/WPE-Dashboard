# PROBLEMAS DE ESCALABILIDAD

**Impacto:** CRITICO - Bloqueador para crecimiento a 50+ scripts
**Prioridad:** MAXIMA (resolver antes de agregar mas funcionalidad)

---

## ES-1: NO HAY SISTEMA DE CARGA AUTOMATICA DE SCRIPTS

**Ubicacion:** Ausente (deberia existir en Utils/ScriptLoader.ps1)
**Impacto:** CRITICO (Escalabilidad bloqueada)
**Tipo:** Funcionalidad faltante

### Descripcion
No existe sistema para cargar scripts automaticamente basado en metadata.

### Estado Documentado vs Real

**CLAUDE.md (linea 4) menciona:**
> "ScriptLoader.ps1 para carga automatica (NO IMPLEMENTADO)"

**Estado Real:** Efectivamente NO EXISTE

### Problema Actual

Para agregar un nuevo script se requiere:

1. Crear archivo `.ps1` con metadata
2. **Editar manualmente Dashboard.ps1**
3. Agregar boton completo con:
   - Codigo de formulario (si aplica)
   - Validaciones
   - Llamada al script
   - Manejo de errores
   - Logging
   - Toasts de feedback
4. Ubicar en la categoria correcta

**Esto son ~30-70 lineas de codigo repetitivo POR SCRIPT**

### Con 50 Scripts Planeados

**Situacion actual:**
- Dashboard.ps1 actualmente: 652 lineas
- Promedio por script complejo: 70 lineas
- Con 50 scripts: 652 + (50 × 70) = **4,152 lineas**

**UN SOLO ARCHIVO DE 4,000+ LINEAS ES INMANTENIBLE**

### Solucion: ScriptLoader

**Crear: Utils/ScriptLoader.ps1**
```powershell
# Sistema de carga automatica de scripts

function Get-ScriptMetadata {
    param([string]$ScriptPath)

    $metadata = @{
        Name = ""
        Description = ""
        Category = ""
        RequiresAdmin = $false
        HasForm = $false
        FormFields = @()
    }

    # Leer primeras 20 lineas del script (metadata)
    $lines = Get-Content $ScriptPath -First 20

    foreach($line in $lines){
        if($line -match "^# @(\w+):\s*(.+)$"){
            $key = $Matches[1]
            $value = $Matches[2].Trim()

            switch($key){
                "Name" { $metadata.Name = $value }
                "Description" { $metadata.Description = $value }
                "RequiresAdmin" { $metadata.RequiresAdmin = ($value -eq "true") }
                "HasForm" { $metadata.HasForm = ($value -eq "true") }
                "FormField" {
                    # Formato: nombre|placeholder|tipo
                    $parts = $value -split '\|'
                    $metadata.FormFields += @{
                        Name = $parts[0]
                        Placeholder = $parts[1]
                        Type = $parts[2]
                    }
                }
            }
        }
    }

    # Detectar categoria del path
    if($ScriptPath -match "\\Scripts\\([^\\]+)\\"){
        $metadata.Category = $Matches[1]
    }

    return $metadata
}

function Load-DashboardScripts {
    param([string]$ScriptRoot)

    $scripts = Get-ChildItem "$ScriptRoot\Scripts" -Recurse -Filter "*.ps1" |
               Where-Object {$_.Name -ne "PLANTILLA-Script.ps1"}

    $scriptInfo = @()

    foreach($script in $scripts){
        $metadata = Get-ScriptMetadata $script.FullName
        if($metadata.Name){  # Solo si tiene metadata valida
            $scriptInfo += [PSCustomObject]@{
                Name = $metadata.Name
                Description = $metadata.Description
                Category = $metadata.Category
                Path = $script.FullName
                RequiresAdmin = $metadata.RequiresAdmin
                HasForm = $metadata.HasForm
                FormFields = $metadata.FormFields
            }
        }
    }

    return $scriptInfo | Sort-Object Category, Name
}

function New-ScriptButton {
    param(
        [PSCustomObject]$Script,
        [hashtable]$Colors
    )

    if($Script.HasForm){
        # Boton con formulario
        New-UDButton -Text $Script.Name -OnClick {
            Show-UDModal -Content {
                # Generar campos dinamicamente
                $fields = foreach($field in $Script.FormFields){
                    New-UDInputField -Name $field.Name -Placeholder $field.Placeholder -Type $field.Type
                }

                New-UDInput -Title $Script.Name -Content {
                    $fields
                } -Endpoint {
                    param([hashtable]$arguments)

                    # Ejecutar script con parametros
                    $result = & $Script.Path @arguments

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
    } else {
        # Boton simple (placeholder)
        New-UDButton -Text $Script.Name -OnClick {
            Show-UDToast -Message "$($Script.Name)..." -Duration 2000 -BackgroundColor $Colors.Primary
            Write-DashboardLog -Accion $Script.Name -Resultado "Iniciado"
        }
    }
}
```

**Uso en Dashboard.ps1:**
```powershell
# Linea 143 - Cargar ScriptLoader
. (Join-Path $ScriptRoot "Utils\ScriptLoader.ps1")

# Cargar todos los scripts
$allScripts = Load-DashboardScripts -ScriptRoot $ScriptRoot

# Agrupar por categoria
$scriptsByCategory = $allScripts | Group-Object -Property Category -AsHashTable

# Generar UI dinamicamente
foreach($category in $scriptsByCategory.Keys | Sort-Object){
    New-UDCard -Title $category.ToUpper() -Content {
        foreach($script in $scriptsByCategory[$category]){
            New-ScriptButton -Script $script -Colors $Colors
        }
    }
}
```

### Beneficios

1. **Agregar nuevo script:**
   - Crear archivo con metadata
   - **LISTO** - Se carga automaticamente

2. **Dashboard.ps1 mas corto:**
   - De 652 lineas a ~200 lineas
   - Solo configuracion y estructura

3. **Mantenibilidad:**
   - Cambios en un script no afectan a otros
   - No editar Dashboard.ps1 nunca mas

4. **Escalabilidad:**
   - 50, 100, 200 scripts - mismo codigo
   - No crece el archivo principal

**Tiempo estimado:** 8-10 horas (desarrollo + testing + migracion)

---

## ES-2: ARQUITECTURA MONOLITICA

**Ubicacion:** Dashboard.ps1 (652 lineas en un solo archivo)
**Impacto:** ALTO
**Tipo:** Problema estructural

### Descripcion
Todo el codigo esta en un solo archivo gigante sin separacion de concerns.

### Estructura Actual

```
Dashboard.ps1 (652 lineas)
├── Lineas 1-5: Comentarios de cabecera
├── Lineas 6-7: Deteccion de ScriptRoot
├── Lineas 8-12: Imports de modulo UD
├── Lineas 13-16: Creacion de carpeta Logs
├── Lineas 18-125: Gestion de puerto (107 lineas!)
├── Lineas 128-137: Funcion Write-DashboardLog
├── Lineas 139-142: Variables de diseno
├── Lineas 145-157: Banner de inicio
└── Lineas 158-652: UI completa (494 LINEAS!)
    ├── Lineas 164-173: Card de informacion
    ├── Lineas 175-601: Seccion Config Inicial (426 lineas!)
    ├── Lineas 603-614: Seccion Mantenimiento
    ├── Lineas 616-623: Seccion POS
    ├── Lineas 624-630: Seccion Diseno
    ├── Lineas 631-638: Seccion Atencion al Cliente
    └── Lineas 640-652: Seccion Acciones Criticas
```

### Problemas

1. **Dificil de navegar**
   - Buscar algo especifico es tedioso
   - No hay estructura clara

2. **Merge conflicts**
   - Multiples personas editando = conflictos
   - Imposible trabajar en paralelo

3. **Testing imposible**
   - No se puede testear funcion individualmente
   - Todo o nada

4. **Coupling alto**
   - Cambio en una parte puede romper otra
   - Dificil refactorizar

5. **No modular**
   - No se puede reutilizar codigo
   - No se puede desactivar secciones

### Solucion: Arquitectura Modular

**Estructura propuesta:**
```
Dashboard/
├── Dashboard.ps1 (50-80 lineas, solo composicion)
│
├── Config/
│   ├── Colors.ps1 (definicion de colores)
│   ├── Spacing.ps1 (definicion de espaciado)
│   └── Settings.ps1 (configuracion general)
│
├── Components/
│   ├── Buttons.ps1 (New-DashboardButton, New-PlaceholderButton)
│   ├── Cards.ps1 (New-InfoCard, New-SectionCard)
│   └── Modals.ps1 (New-ScriptModal)
│
├── Pages/
│   ├── Header.ps1 (card de informacion del sistema)
│   ├── ConfiguracionInicial.ps1 (seccion Config Inicial)
│   ├── Mantenimiento.ps1 (seccion Mantenimiento)
│   ├── AreasCriticas.ps1 (seccion Acciones Criticas)
│   └── Especializadas.ps1 (POS, Diseno, Atencion)
│
├── Utils/
│   ├── ScriptLoader.ps1 (carga automatica)
│   ├── PortManager.ps1 (gestion de puerto)
│   └── Logging.ps1 (sistema de logs)
│
└── Scripts/ (sin cambios)
    └── ...
```

**Dashboard.ps1 simplificado:**
```powershell
# Dashboard.ps1 - Version modular

# 1. Detectar ubicacion
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# 2. Importar modulo UD
Import-Module UniversalDashboard.Community -ErrorAction Stop

# 3. Cargar configuracion
. (Join-Path $ScriptRoot "Config\Colors.ps1")
. (Join-Path $ScriptRoot "Config\Spacing.ps1")
. (Join-Path $ScriptRoot "Config\Settings.ps1")

# 4. Cargar utilidades
. (Join-Path $ScriptRoot "Utils\Logging.ps1")
. (Join-Path $ScriptRoot "Utils\PortManager.ps1")
. (Join-Path $ScriptRoot "Utils\ScriptLoader.ps1")

# 5. Cargar componentes
. (Join-Path $ScriptRoot "Components\Buttons.ps1")
. (Join-Path $ScriptRoot "Components\Cards.ps1")
. (Join-Path $ScriptRoot "Components\Modals.ps1")

# 6. Cargar paginas
. (Join-Path $ScriptRoot "Pages\Header.ps1")
. (Join-Path $ScriptRoot "Pages\ConfiguracionInicial.ps1")
. (Join-Path $ScriptRoot "Pages\Mantenimiento.ps1")
. (Join-Path $ScriptRoot "Pages\AreasCriticas.ps1")
. (Join-Path $ScriptRoot "Pages\Especializadas.ps1")

# 7. Gestionar puerto
Initialize-DashboardPort -Port 10000

# 8. Cargar scripts
$allScripts = Load-DashboardScripts -ScriptRoot $ScriptRoot

# 9. Crear dashboard
$dashboard = New-UDDashboard -Title "WPE Dashboard" -Content {
    New-UDElement -Tag 'div' -Attributes @{style=@{'max-width'='1400px';'margin'='0 auto';'padding'='20px'}} -Content {
        New-HeaderPage
        New-ConfiguracionInicialPage -Scripts ($allScripts | Where-Object {$_.Category -eq "Configuracion"})
        New-MantenimientoPage -Scripts ($allScripts | Where-Object {$_.Category -eq "Mantenimiento"})
        New-EspecializadasPage -Scripts $allScripts
        New-AreasCriticasPage
    }
}

# 10. Iniciar dashboard
Start-UDDashboard -Dashboard $dashboard -Port 10000 -AutoReload
```

### Beneficios

1. **Mantenibilidad:**
   - Cada archivo tiene una responsabilidad
   - Facil encontrar y editar codigo

2. **Trabajo en equipo:**
   - Persona A edita PortManager.ps1
   - Persona B edita Buttons.ps1
   - Sin conflictos

3. **Testing:**
   - Testear cada modulo independientemente
   - Unit tests por componente

4. **Reutilizacion:**
   - Components/ reutilizable en otros proyectos
   - Utils/ puede ser libreria separada

5. **Escalabilidad:**
   - Agregar nueva pagina = agregar archivo
   - No tocar codigo existente

**Tiempo estimado:** 12-16 horas (refactoring completo)

---

## ES-3: NO HAY SISTEMA DE CATEGORIAS DINAMICO

**Ubicacion:** `Dashboard.ps1:602-638`
**Impacto:** MEDIO
**Tipo:** Hardcoded structure

### Descripcion
Las categorias de scripts estan hardcodeadas en el codigo.

### Codigo Actual

```powershell
# Lineas 602-638: Hardcoded
New-UDLayout -Columns 3 -Content {
    # PUNTO DE VENTA
    New-UDCard -Title "PUNTO DE VENTA" -Content {
        New-UDButton -Text "Config Impresora Fiscal"
        New-UDButton -Text "Configurar Sistema de Cobro"
        New-UDButton -Text "Configurar Lector Codigo de Barras"
    }

    # DISENO GRAFICO
    New-UDCard -Title "DISENO GRAFICO" -Content {
        New-UDButton -Text "Setup Adobe Suite"
        New-UDButton -Text "Configurar Monitor Calibrado"
    }

    # ATENCION AL CLIENTE
    New-UDCard -Title "ATENCION AL CLIENTE" -Content {
        New-UDButton -Text "Config Telefonia"
        New-UDButton -Text "Configurar CRM"
    }
}
```

### Problema

Para agregar nueva categoria (ej: "CONTABILIDAD"):
1. Editar Dashboard.ps1 manualmente
2. Agregar nueva card completa
3. Ajustar layout (de 3 a 4 columnas?)
4. Copiar estructura de otras cards

**No escala bien**

### Solucion: Categorias Dinamicas

**Con ScriptLoader (ES-1):**
```powershell
# Cargar scripts
$allScripts = Load-DashboardScripts -ScriptRoot $ScriptRoot

# Detectar categorias automaticamente
$categories = $allScripts | Select-Object -ExpandProperty Category -Unique | Sort-Object

# Generar UI dinamicamente
New-UDLayout -Columns 3 -Content {
    foreach($category in $categories){
        $categoryScripts = $allScripts | Where-Object {$_.Category -eq $category}

        New-UDCard -Title $category.ToUpper() -Content {
            foreach($script in $categoryScripts){
                New-ScriptButton -Script $script -Colors $Colors
            }
        }
    }
}
```

### Beneficios

1. **Agregar categoria:**
   - Crear carpeta: `Scripts/Contabilidad/`
   - Agregar scripts con metadata
   - **LISTO** - Aparece automaticamente

2. **Sin editar codigo:**
   - Dashboard.ps1 no se toca
   - Todo es data-driven

3. **Flexible:**
   - Deshabilitar categoria: renombrar carpeta
   - Reordenar: cambiar nombre de carpeta (orden alfabetico)

**Tiempo estimado:** 2 horas (requiere ES-1 primero)

---

## ES-4: NO HAY SISTEMA DE PERMISOS

**Ubicacion:** Ausente
**Impacto:** MEDIO (Seguridad)
**Tipo:** Funcionalidad faltante

### Descripcion
Todos los botones son visibles para todos los usuarios sin restricciones.

### Riesgos

1. **Usuario de POS puede:**
   - REINICIAR PC (perder datos)
   - Eliminar usuarios
   - Cambiar configuracion critica

2. **Usuario de Diseno puede:**
   - Acceder a funciones de POS
   - Ver informacion de otros departamentos

3. **Sin audit trail:**
   - No se registra quien ejecuto que
   - Imposible rastrear acciones

### Solucion: Sistema de Roles

**Metadata en scripts:**
```powershell
# @Name: Eliminar Usuarios de Prueba
# @Description: Elimina usuarios de testing
# @RequiresAdmin: true
# @RequiresRole: Admin,Mantenimiento  # ← Nuevo campo
```

**Definir roles:**
```powershell
# Config/Roles.ps1
$Roles = @{
    "Admin" = @("Configuracion", "Mantenimiento", "POS", "Diseno", "Atencion", "Criticas")
    "Mantenimiento" = @("Configuracion", "Mantenimiento", "Criticas")
    "POS" = @("POS")
    "Diseno" = @("Diseno")
    "Atencion" = @("Atencion")
    "Readonly" = @()  # Solo ver, no ejecutar
}
```

**Detectar usuario y rol:**
```powershell
function Get-UserRole {
    param([string]$Username = $env:USERNAME)

    # Detectar grupo de usuario
    $groups = whoami /groups /fo csv | ConvertFrom-Csv | Select-Object -ExpandProperty "Group Name"

    if($groups -match "Administrators"){
        return "Admin"
    } elseif($groups -match "POS"){
        return "POS"
    } elseif($groups -match "Diseno"){
        return "Diseno"
    } else {
        return "Readonly"
    }
}
```

**Filtrar scripts por rol:**
```powershell
# En Dashboard.ps1
$currentRole = Get-UserRole
$allowedCategories = $Roles[$currentRole]

# Filtrar scripts
$visibleScripts = $allScripts | Where-Object {
    $_.Category -in $allowedCategories
}

# Generar UI solo con scripts permitidos
foreach($script in $visibleScripts){
    New-ScriptButton -Script $script -Colors $Colors
}
```

**Logging con usuario:**
```powershell
# Utils/Logging.ps1 (ya propuesto en MP-4)
function Write-Log {
    param([string]$Accion, [string]$Resultado)

    $PC = $env:COMPUTERNAME
    $Usuario = $env:USERNAME  # ← Registrar usuario
    $Role = Get-UserRole

    $mensaje = "[$Timestamp] [$PC] [$Usuario] [$Role] $Accion - $Resultado"
    Add-Content -Path $LogPath -Value $mensaje
}
```

**Ejemplo de log con usuarios:**
```
[2025-11-06 14:30:45] [DESKTOP-123] [Juan.Perez] [Admin] Crear Usuario - Exitoso
[2025-11-06 14:31:12] [DESKTOP-456] [Maria.Lopez] [POS] Configurar Impresora - Iniciado
[2025-11-06 14:32:00] [DESKTOP-789] [Pedro.Gomez] [Readonly] ACCESO DENEGADO - Intento REINICIAR PC
```

### Beneficios

1. **Seguridad:**
   - Usuarios solo ven funciones relevantes
   - Acciones criticas restringidas

2. **Auditoria:**
   - Saber quien hizo que
   - Rastrear problemas

3. **UX mas limpia:**
   - Usuario de POS solo ve botones de POS
   - No abrumar con opciones irrelevantes

**Tiempo estimado:** 6-8 horas

---

## RESUMEN DE PROBLEMAS DE ESCALABILIDAD

| ID | Problema | Ubicacion | Impacto | Tiempo Fix |
|----|----------|-----------|---------|------------|
| ES-1 | No hay ScriptLoader | Ausente | CRITICO | 8-10h |
| ES-2 | Arquitectura monolitica | Dashboard.ps1 (652 lineas) | ALTO | 12-16h |
| ES-3 | Categorias hardcoded | Dashboard.ps1:602-638 | MEDIO | 2h |
| ES-4 | No hay sistema de permisos | Ausente | MEDIO | 6-8h |

**Tiempo total estimado:** 28-36 horas

---

## PRIORIDAD DE CORRECCION

### FASE 1: Fundacion (CRITICA)
1. **ES-1** - Implementar ScriptLoader (8-10h) → **BLOQUEADOR**
2. **ES-2** - Modularizar Dashboard.ps1 (12-16h) → **CRITICA**

**Subtotal:** 20-26 horas

### FASE 2: Mejoras (ALTA)
3. **ES-3** - Categorias dinamicas (2h) → **DEPENDE DE ES-1**
4. **ES-4** - Sistema de permisos (6-8h) → **SEGURIDAD**

**Subtotal:** 8-10 horas

**Total:** 28-36 horas (~1 semana de trabajo)

---

## DECISION CRITICA

**SIN ES-1 y ES-2, el proyecto NO PUEDE ESCALAR a 50+ scripts.**

**Opciones:**

**A) Refactorizar ahora (RECOMENDADO)**
- Invertir 20-26 horas
- Dashboard mantenible a largo plazo
- Agregar scripts es facil

**B) Continuar como esta (NO RECOMENDADO)**
- Dashboard.ps1 crecera a 4,000+ lineas
- Inmantenible
- Agregar scripts es tedioso

**C) Enfoque hibrido**
- Implementar ES-1 (ScriptLoader) ahora (8-10h)
- Postponer ES-2 (modularizacion) para despues
- Permite escalar, pero Dashboard.ps1 sigue grande

---

## IMPACTO DE NO RESOLVER

**En 6 meses con 50 scripts:**
- Dashboard.ps1: 4,000+ lineas
- Tiempo para agregar script: 1-2 horas
- Merge conflicts: frecuentes
- Bugs: dificiles de rastrear
- Onboarding de nuevos devs: 1-2 semanas

**Con ES-1 y ES-2 resueltos:**
- Dashboard.ps1: ~200 lineas
- Tiempo para agregar script: 10-15 minutos
- Merge conflicts: raros
- Bugs: aislados a archivos especificos
- Onboarding: 1-2 dias

**ROI:** Por cada hora invertida ahora, se ahorran 10+ horas en el futuro.
