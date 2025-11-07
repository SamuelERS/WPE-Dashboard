# Arquitectura de Componentes - Dashboard Paradise-SystemLabs

## Introduccion

Este documento define la arquitectura tecnica de componentes reutilizables para el dashboard. El objetivo es crear funciones helper que simplifiquen el codigo y faciliten el mantenimiento.

## Estructura del Codigo

### Organizacion del Archivo Dashboard.ps1

```
Dashboard.ps1
├── 1. Configuracion Inicial (lineas 1-153)
│   ├── Deteccion de ubicacion
│   ├── Importacion de modulos
│   ├── Verificacion de puerto
│   └── Funcion Write-DashboardLog
│
├── 2. Variables de Diseno (NUEVO)
│   ├── $Colors (paleta de colores)
│   ├── $Spacing (sistema de espaciado)
│   └── $Config (configuracion general)
│
├── 3. Funciones Helper (NUEVO)
│   ├── New-DashboardButton
│   ├── New-ButtonGroup
│   ├── New-InfoCard
│   └── New-CriticalZone
│
├── 4. Definicion del Dashboard (linea 154+)
│   ├── Header
│   ├── Informacion del Sistema
│   ├── Acciones Rapidas
│   ├── Configuracion del Sistema
│   ├── Mantenimiento
│   ├── Areas Especializadas
│   ├── Zona Critica
│   └── Footer
│
└── 5. Inicio del Dashboard (ultima linea)
    └── Start-UDDashboard
```

## Variables de Diseno

### Implementacion

Agregar despues de la funcion `Write-DashboardLog` (linea 137):

```powershell
# ============================================
# VARIABLES DE DISENO
# ============================================

# Sistema de Colores
$Colors = @{
    # Colores de Accion
    Primary     = "#2196F3"
    Success     = "#4caf50"
    Warning     = "#ff9800"
    Danger      = "#dc3545"
    Info        = "#17a2b8"
    Secondary   = "#6c757d"
    
    # Colores de Fondo
    BgWarning   = "#fff3cd"
    BgDanger    = "#ffe6e6"
    BgSuccess   = "#e8f5e9"
    BgInfo      = "#e3f2fd"
    BgLight     = "#f5f5f5"
    
    # Colores de Borde
    BorderWarning = "#ffc107"
    BorderDanger  = "#dc3545"
    BorderInfo    = "#2196F3"
    BorderLight   = "#dee2e6"
    
    # Colores de Texto
    TextPrimary   = "#212529"
    TextSecondary = "#6c757d"
    TextLight     = "#ffffff"
    TextMuted     = "#999999"
}

# Sistema de Espaciado
$Spacing = @{
    XS  = "4px"
    S   = "8px"
    M   = "12px"
    L   = "16px"
    XL  = "24px"
    XXL = "32px"
}

# Configuracion General
$Config = @{
    ButtonWidth = "100%"
    BorderRadius = "5px"
    CardPadding = "16px"
}
```

## Funciones Helper

### 1. New-DashboardButton

**Proposito:** Crear botones con estilos consistentes

**Parametros:**
- `Text`: Texto del boton
- `OnClick`: Script block con la logica
- `Type`: Tipo de boton (default, primary, success, warning, danger)
- `Width`: Ancho del boton (default: 100%)
- `Bold`: Hacer texto en negrita (default: false)

**Implementacion:**

```powershell
function New-DashboardButton {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Text,
        
        [Parameter(Mandatory=$true)]
        [scriptblock]$OnClick,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("default", "primary", "success", "warning", "danger")]
        [string]$Type = "default",
        
        [Parameter(Mandatory=$false)]
        [string]$Width = "100%",
        
        [Parameter(Mandatory=$false)]
        [bool]$Bold = $false
    )
    
    # Construir estilos basados en el tipo
    $styles = @{
        'width' = $Width
    }
    
    # Aplicar colores segun tipo
    switch ($Type) {
        "primary" {
            $styles['background-color'] = $Colors.Primary
            $styles['color'] = $Colors.TextLight
        }
        "success" {
            $styles['background-color'] = $Colors.Success
            $styles['color'] = $Colors.TextLight
        }
        "warning" {
            $styles['background-color'] = $Colors.Warning
            $styles['color'] = $Colors.TextLight
        }
        "danger" {
            $styles['background-color'] = $Colors.Danger
            $styles['color'] = $Colors.TextLight
            $styles['font-weight'] = 'bold'
        }
        # "default" no necesita estilos adicionales
    }
    
    # Aplicar negrita si se solicita
    if ($Bold -and $Type -ne "danger") {
        $styles['font-weight'] = 'bold'
    }
    
    # Crear y retornar el boton
    New-UDButton -Text $Text -OnClick $OnClick -Style $styles
}
```

**Uso:**

```powershell
# Boton primario
New-DashboardButton -Text "Crear Usuario" -Type "primary" -OnClick {
    Show-UDToast -Message "Creando usuario..." -Duration 2000
}

# Boton de peligro
New-DashboardButton -Text "REINICIAR PC" -Type "danger" -OnClick {
    Restart-Computer -Force
}

# Boton default
New-DashboardButton -Text "Setup Adobe" -OnClick {
    Show-UDToast -Message "Instalando..." -Duration 2000
}
```

### 2. New-ButtonGroup

**Proposito:** Crear grupo de botones con layout consistente

**Parametros:**
- `Buttons`: Array de script blocks que crean botones
- `Layout`: Tipo de layout (column, row, grid2, grid3)
- `Gap`: Espaciado entre botones (default: $Spacing.M)

**Implementacion:**

```powershell
function New-ButtonGroup {
    param(
        [Parameter(Mandatory=$true)]
        [array]$Buttons,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("column", "row", "grid2", "grid3")]
        [string]$Layout = "column",
        
        [Parameter(Mandatory=$false)]
        [string]$Gap = $Spacing.M
    )
    
    # Determinar flex-direction
    $flexDirection = "column"
    $useGrid = $false
    $gridColumns = 1
    
    switch ($Layout) {
        "column" {
            $flexDirection = "column"
        }
        "row" {
            $flexDirection = "row"
        }
        "grid2" {
            $useGrid = $true
            $gridColumns = 2
        }
        "grid3" {
            $useGrid = $true
            $gridColumns = 3
        }
    }
    
    # Si usa grid, usar New-UDLayout
    if ($useGrid) {
        New-UDLayout -Columns $gridColumns -Content {
            foreach ($button in $Buttons) {
                & $button
            }
        }
    } else {
        # Si no, usar flex
        New-UDElement -Tag 'div' -Attributes @{
            style=@{
                'display'='flex'
                'flex-direction'=$flexDirection
                'gap'=$Gap
                'padding'=$Spacing.L
            }
        } -Content {
            foreach ($button in $Buttons) {
                & $button
            }
        }
    }
}
```

**Uso:**

```powershell
# Grupo de botones en columna
New-ButtonGroup -Layout "column" -Buttons @(
    { New-DashboardButton -Text "Boton 1" -Type "primary" -OnClick {...} }
    { New-DashboardButton -Text "Boton 2" -OnClick {...} }
    { New-DashboardButton -Text "Boton 3" -OnClick {...} }
)

# Grupo de botones en grid de 2 columnas
New-ButtonGroup -Layout "grid2" -Buttons @(
    { New-DashboardButton -Text "Windows Update" -OnClick {...} }
    { New-DashboardButton -Text "Limpieza Disco" -OnClick {...} }
    { New-DashboardButton -Text "Verificar Sistema" -Type "success" -OnClick {...} }
    { New-DashboardButton -Text "Optimizar" -Type "success" -OnClick {...} }
)
```

### 3. New-InfoCard

**Proposito:** Crear card de informacion con estilo consistente

**Parametros:**
- `Title`: Titulo de la card
- `Content`: Script block con el contenido
- `Type`: Tipo de card (info, warning, danger, success)
- `ShowBorder`: Mostrar borde (default: true)

**Implementacion:**

```powershell
function New-InfoCard {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Title,
        
        [Parameter(Mandatory=$true)]
        [scriptblock]$Content,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("info", "warning", "danger", "success")]
        [string]$Type = "info",
        
        [Parameter(Mandatory=$false)]
        [bool]$ShowBorder = $true
    )
    
    # Determinar colores segun tipo
    $bgColor = $Colors.BgInfo
    $borderColor = $Colors.BorderInfo
    
    switch ($Type) {
        "warning" {
            $bgColor = $Colors.BgWarning
            $borderColor = $Colors.BorderWarning
        }
        "danger" {
            $bgColor = $Colors.BgDanger
            $borderColor = $Colors.BorderDanger
        }
        "success" {
            $bgColor = $Colors.BgSuccess
            $borderColor = $Colors.Success
        }
    }
    
    # Construir estilos
    $styles = @{
        'padding' = $Spacing.L
        'background-color' = $bgColor
        'border-radius' = $Config.BorderRadius
    }
    
    if ($ShowBorder) {
        $styles['border'] = "2px solid $borderColor"
    }
    
    # Crear card
    New-UDCard -Title $Title -Content {
        New-UDElement -Tag 'div' -Attributes @{style=$styles} -Content {
            & $Content
        }
    }
}
```

**Uso:**

```powershell
# Card de advertencia
New-InfoCard -Title "INFORMACION DEL SISTEMA" -Type "warning" -Content {
    New-UDHeading -Text "PC ACTUAL: $env:COMPUTERNAME" -Size 5
    New-UDElement -Tag 'p' -Content {
        "IMPORTANTE: Todos los scripts se ejecutan en esta maquina"
    }
}

# Card de peligro
New-InfoCard -Title "ACCIONES CRITICAS" -Type "danger" -Content {
    New-UDElement -Tag 'p' -Content {
        "ADVERTENCIA: Estas acciones afectaran el sistema inmediatamente"
    }
    New-UDElement -Tag 'div' -Attributes @{
        style=@{'margin-top'=$Spacing.M}
    } -Content {
        New-DashboardButton -Text "REINICIAR PC" -Type "danger" -OnClick {...}
    }
}
```

### 4. New-SectionCard

**Proposito:** Crear card de seccion con botones

**Parametros:**
- `Title`: Titulo de la seccion
- `Buttons`: Array de script blocks que crean botones
- `Layout`: Layout de botones (column, grid2, grid3)

**Implementacion:**

```powershell
function New-SectionCard {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Title,
        
        [Parameter(Mandatory=$true)]
        [array]$Buttons,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("column", "grid2", "grid3")]
        [string]$Layout = "column"
    )
    
    New-UDCard -Title $Title -Content {
        New-ButtonGroup -Layout $Layout -Buttons $Buttons
    }
}
```

**Uso:**

```powershell
# Seccion simple con botones en columna
New-SectionCard -Title "SISTEMA" -Layout "column" -Buttons @(
    { New-DashboardButton -Text "Cambiar Nombre PC" -OnClick {...} }
    { New-DashboardButton -Text "Configurar Biometria" -OnClick {...} }
    { New-DashboardButton -Text "Instalar Software" -OnClick {...} }
)

# Seccion con grid de 2 columnas
New-SectionCard -Title "MANTENIMIENTO" -Layout "grid2" -Buttons @(
    { New-DashboardButton -Text "Windows Update" -OnClick {...} }
    { New-DashboardButton -Text "Limpieza Disco" -OnClick {...} }
    { New-DashboardButton -Text "Verificar Sistema" -Type "success" -OnClick {...} }
    { New-DashboardButton -Text "Optimizar" -Type "success" -OnClick {...} }
)
```

## Patron de Implementacion

### Estructura Completa de una Seccion

```powershell
# Separador visual
New-UDElement -Tag 'hr'

# Seccion con Layout de 2 columnas
New-UDLayout -Columns 2 -Content {
    
    # Card 1: Sistema
    New-SectionCard -Title "SISTEMA" -Layout "column" -Buttons @(
        {
            New-DashboardButton -Text "Cambiar Nombre PC" -OnClick {
                Show-UDModal -Content {
                    New-UDInput -Title "Cambiar Nombre del PC" -Content {
                        # Campos del formulario
                    } -Endpoint {
                        param($campo1, $campo2)
                        # Logica del formulario
                    }
                }
            }
        }
        {
            New-DashboardButton -Text "Configurar Biometria" -OnClick {
                Show-UDToast -Message "Configurando biometria..." -Duration 2000
                Write-DashboardLog -Accion "Config Biometria" -Resultado "Iniciado"
            }
        }
        {
            New-DashboardButton -Text "Instalar Software Base" -OnClick {
                Show-UDToast -Message "Instalando software..." -Duration 2000
                Write-DashboardLog -Accion "Software Base" -Resultado "Iniciado"
            }
        }
    )
    
    # Card 2: Usuarios
    New-SectionCard -Title "USUARIOS" -Layout "column" -Buttons @(
        {
            New-DashboardButton -Text "Crear Usuario" -Type "primary" -OnClick {
                # Logica de crear usuario
            }
        }
        {
            New-DashboardButton -Text "Ver Usuarios" -Type "primary" -OnClick {
                # Logica de ver usuarios
            }
        }
        {
            New-DashboardButton -Text "Reparar Usuarios" -Type "warning" -OnClick {
                # Logica de reparar usuarios
            }
        }
        {
            New-DashboardButton -Text "Eliminar Usuarios" -Type "danger" -OnClick {
                # Logica de eliminar usuarios
            }
        }
    )
}
```

## Migracion del Codigo Actual

### Estrategia de Migracion

1. **Fase 1**: Agregar variables de diseno y funciones helper
2. **Fase 2**: Migrar seccion por seccion
3. **Fase 3**: Validar funcionalidad
4. **Fase 4**: Optimizar y limpiar

### Ejemplo de Migracion

#### Antes (Codigo Actual):

```powershell
New-UDLayout -Columns 1 -Content {
    New-UDCard -Title "MANTENIMIENTO GENERAL" -Content {
        New-UDElement -Tag 'div' -Attributes @{
            style=@{'display'='flex';'gap'='10px';'flex-wrap'='wrap'}
        } -Content {
            New-UDButton -Text "Windows Update" -OnClick {
                Show-UDToast -Message "Verificando actualizaciones..." -Duration 2000
                Write-DashboardLog -Accion "Windows Update" -Resultado "Iniciado"
            }
            New-UDButton -Text "Limpieza de Disco" -OnClick {
                Show-UDToast -Message "Limpiando disco..." -Duration 2000
                Write-DashboardLog -Accion "Limpieza Disco" -Resultado "Iniciado"
            }
            New-UDButton -Text "Verificar Sistema" -OnClick {
                Show-UDToast -Message "Verificando..." -Duration 2000
                Write-DashboardLog -Accion "Verificar Sistema" -Resultado "Iniciado"
            }
            New-UDButton -Text "Optimizar Rendimiento" -OnClick {
                Show-UDToast -Message "Optimizando..." -Duration 2000
                Write-DashboardLog -Accion "Optimizar" -Resultado "Iniciado"
            }
        }
    }
}
```

#### Despues (Con Componentes):

```powershell
New-SectionCard -Title "MANTENIMIENTO GENERAL" -Layout "grid2" -Buttons @(
    {
        New-DashboardButton -Text "Windows Update" -OnClick {
            Show-UDToast -Message "Verificando actualizaciones..." -Duration 2000
            Write-DashboardLog -Accion "Windows Update" -Resultado "Iniciado"
        }
    }
    {
        New-DashboardButton -Text "Limpieza de Disco" -OnClick {
            Show-UDToast -Message "Limpiando disco..." -Duration 2000
            Write-DashboardLog -Accion "Limpieza Disco" -Resultado "Iniciado"
        }
    }
    {
        New-DashboardButton -Text "Verificar Sistema" -Type "success" -OnClick {
            Show-UDToast -Message "Verificando..." -Duration 2000
            Write-DashboardLog -Accion "Verificar Sistema" -Resultado "Iniciado"
        }
    }
    {
        New-DashboardButton -Text "Optimizar Rendimiento" -Type "success" -OnClick {
            Show-UDToast -Message "Optimizando..." -Duration 2000
            Write-DashboardLog -Accion "Optimizar" -Resultado "Iniciado"
        }
    }
)
```

**Beneficios:**
- Codigo mas limpio y legible
- Menos lineas (de ~20 a ~15)
- Estilos consistentes automaticamente
- Facil cambiar layout (column a grid2)
- Facil agregar colores (Type="success")

## Orden de Implementacion

### 1. Agregar Variables (Linea ~138)

```powershell
# Despues de Write-DashboardLog
# Agregar:
# - $Colors
# - $Spacing
# - $Config
```

### 2. Agregar Funciones Helper (Linea ~180)

```powershell
# Despues de las variables
# Agregar:
# - New-DashboardButton
# - New-ButtonGroup
# - New-InfoCard
# - New-SectionCard
```

### 3. Migrar Contenido del Dashboard (Linea ~220+)

```powershell
# Mantener estructura:
# - Header (sin cambios)
# - Info Sistema (usar New-InfoCard)
# - Acciones Rapidas (NUEVA - usar New-SectionCard con grid3)
# - Config Sistema (usar New-UDLayout + New-SectionCard)
# - Mantenimiento (usar New-SectionCard con grid2)
# - Areas Especializadas (usar New-UDLayout + New-SectionCard)
# - Zona Critica (NUEVA - usar New-InfoCard tipo danger)
# - Footer (sin cambios)
```

## Ventajas de la Arquitectura

### Mantenibilidad
- **Codigo centralizado**: Cambiar estilos en un solo lugar
- **Funciones reutilizables**: No repetir codigo
- **Facil de entender**: Estructura clara

### Escalabilidad
- **Agregar botones**: Solo agregar un script block al array
- **Cambiar layout**: Solo cambiar parametro Layout
- **Nuevas secciones**: Copiar patron existente

### Consistencia
- **Estilos uniformes**: Todos los botones usan mismos colores
- **Espaciado consistente**: Sistema de spacing centralizado
- **Nomenclatura clara**: Funciones con nombres descriptivos

### Testabilidad
- **Funciones aisladas**: Facil probar individualmente
- **Parametros validados**: ValidateSet previene errores
- **Codigo modular**: Cambios no afectan otras partes

## Limitaciones y Consideraciones

### Limitaciones de UniversalDashboard
- No soporta CSS modules o styled-components
- Estilos inline solamente
- JavaScript personalizado limitado
- Grid responsivo basico

### Consideraciones de Performance
- Funciones helper agregan overhead minimo
- Script blocks en arrays son eficientes
- No hay impacto significativo en tiempo de carga

### Compatibilidad
- PowerShell 5.1+
- UniversalDashboard.Community 2.x
- Navegadores modernos

## Proximos Pasos

1. Implementar variables de diseno
2. Implementar funciones helper
3. Migrar seccion por seccion
4. Validar funcionalidad
5. Documentar cambios

---

**Version:** 1.0  
**Ultima Actualizacion:** 06 de Noviembre, 2025  
**Mantenedor:** Equipo Paradise-SystemLabs
