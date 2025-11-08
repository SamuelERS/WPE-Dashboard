# Restauración Visual de Dashboard-UI.ps1

**Documento:** Guía de Implementación Técnica
**Versión:** 1.0.1-LTS
**Archivo objetivo:** `UI/Dashboard-UI.ps1`
**Fecha:** Noviembre 2025

---

## 📋 Índice de Componentes

1. [Container Wrapper Principal](#1-container-wrapper-principal)
2. [System Info Card](#2-system-info-card)
3. [HR Separators con Espaciado](#3-hr-separators-con-espaciado)
4. [Card-Based Category Sections](#4-card-based-category-sections)
5. [Critical Actions Section](#5-critical-actions-section)
6. [Dashboard Footer](#6-dashboard-footer)
7. [Variantes de Botones](#7-variantes-de-botones)
8. [Code Blocks Formateados](#8-code-blocks-formateados)
9. [Cajas de Estado](#9-cajas-de-estado)
10. [CSS Global](#10-css-global)

---

## 1. Container Wrapper Principal

### Propósito
Centrar el dashboard en pantallas grandes (max-width: 1400px) con padding consistente.

### Implementación

**Ubicación:** Envuelve TODO el contenido del dashboard en `New-DashboardContent`

```powershell
function New-DashboardContent {
    param(
        [Parameter(Mandatory)]
        [hashtable]$Config,

        [Parameter(Mandatory)]
        [array]$AllScripts
    )

    # WRAPPER PRINCIPAL
    New-UDElement -Tag 'div' -Attributes @{
        style = @{
            'max-width' = '1400px'
            'margin' = '0 auto'
            'padding' = '20px'
        }
    } -Content {

        # Todo el contenido del dashboard va aquí
        # (System Info, Categorías, Critical Actions, Footer)

    }
}
```

### Resultado Visual
- Pantallas > 1400px: Contenido centrado con márgenes laterales
- Pantallas < 1400px: Contenido ocupa 100% del ancho con padding de 20px

---

## 2. System Info Card

### Propósito
Destacar información crítica sobre el PC actual donde se ejecuta el dashboard.

### Función Nueva

```powershell
function New-SystemInfoCard {
    param(
        [Parameter(Mandatory)]
        [hashtable]$Config
    )

    $pcName = $env:COMPUTERNAME

    New-UDCard -Title "INFORMACION DEL SISTEMA" -Content {

        # Caja de advertencia amarilla
        New-UDElement -Tag 'div' -Attributes @{
            style = @{
                'padding' = $Config.spacing.xs
                'background-color' = $Config.colorsParadise.warningBackground
                'border' = "2px solid $($Config.colorsParadise.warningBorder)"
                'border-radius' = '5px'
                'margin-bottom' = $Config.spacing.xs
            }
        } -Content {

            # Título principal
            New-UDHeading -Size 5 -Text "PC ACTUAL: $pcName" -Content {
                New-UDElement -Tag 'span' -Attributes @{
                    style = @{'font-weight' = 'bold'}
                } -Content { "PC ACTUAL: $pcName" }
            }

            # Texto de advertencia
            New-UDElement -Tag 'p' -Content {
                "IMPORTANTE: Todos los scripts se ejecutan en esta maquina"
            }

            New-UDElement -Tag 'p' -Content {
                "Los usuarios se crearan en: $pcName"
            }

            New-UDElement -Tag 'p' -Content {
                "Si necesitas configurar otra PC, ejecuta el dashboard EN esa maquina"
            }
        }
    }
}
```

### Uso en Dashboard-UI.ps1

```powershell
# Dentro de New-DashboardContent, después del header
New-SystemInfoCard -Config $Config

# HR Separator
New-UDElement -Tag 'hr' -Attributes @{
    style = @{'margin' = $Config.spacing.xl + ' 0'}
}

# Luego siguen las categorías...
```

### Ejemplo Visual

```
┌─────────────────────────────────────────────────────┐
│  INFORMACION DEL SISTEMA                            │
│  ┌───────────────────────────────────────────────┐  │
│  │                                               │  │
│  │  PC ACTUAL: DESKTOP-VHIMC05                   │  │
│  │                                               │  │
│  │  IMPORTANTE: Todos los scripts se ejecutan    │  │
│  │  en esta máquina                              │  │
│  │                                               │  │
│  │  Los usuarios se crearán en: DESKTOP-VHIMC05  │  │
│  │                                               │  │
│  │  Si necesitas configurar otra PC, ejecuta     │  │
│  │  el dashboard EN esa máquina                  │  │
│  │                                               │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
    Fondo: #fff3cd | Borde: 2px solid #ffc107
```

---

## 3. HR Separators con Espaciado

### Propósito
Separar visualmente las secciones principales del dashboard.

### Implementación

```powershell
function New-SectionSeparator {
    param(
        [Parameter(Mandatory)]
        [hashtable]$Config
    )

    New-UDElement -Tag 'hr' -Attributes @{
        style = @{
            'margin' = $Config.spacing.xl + ' 0'  # 24px arriba y abajo
            'border' = 'none'
            'border-top' = '1px solid #ddd'
        }
    }
}
```

### Ubicación de Separadores

```powershell
# 1. Después de System Info Card
New-SystemInfoCard -Config $Config
New-SectionSeparator -Config $Config

# 2. Antes de Critical Actions
# (Categorías aquí)
New-SectionSeparator -Config $Config
New-CriticalActionsSection -Config $Config

# 3. Antes del Footer
New-SectionSeparator -Config $Config
New-DashboardFooter -Config $Config
```

---

## 4. Card-Based Category Sections

### Propósito
Agrupar scripts en cards visuales con títulos claros.

### Modificación de `New-CategorySection`

**ANTES (v1.0.0-LTS):**
```powershell
function New-CategorySection {
    param(...)

    New-UDHeading -Size 4 -Text $category.name

    New-UDRow {
        foreach ($script in $scripts) {
            New-UDColumn -Size 3 {
                New-ScriptButton -Script $script -Config $Config
            }
        }
    }
}
```

**DESPUÉS (v1.0.1-LTS Paradise):**
```powershell
function New-CategorySection {
    param(
        [Parameter(Mandatory)]
        [hashtable]$Category,

        [Parameter(Mandatory)]
        [array]$Scripts,

        [Parameter(Mandatory)]
        [hashtable]$Config
    )

    New-UDCard -Title $Category.name -Content {

        # Flex layout vertical con gap
        New-UDElement -Tag 'div' -Attributes @{
            style = @{
                'display' = 'flex'
                'flex-direction' = 'column'
                'gap' = $Config.spacing.s  # 12px entre botones
                'padding' = $Config.spacing.m  # 16px padding interno
            }
        } -Content {

            # Botones de scripts apilados verticalmente
            foreach ($script in $Scripts) {
                New-ScriptButton -Script $script -Config $Config
            }
        }
    }
}
```

### Layout Multi-Columna (Opcional)

Para categorías con muchos scripts, crear layout de 2 o 3 columnas:

```powershell
# Layout de 2 columnas
New-UDLayout -Columns 2 -Content {
    foreach ($script in $Scripts) {
        New-ScriptButton -Script $script -Config $Config
    }
}

# Layout de 3 columnas (para POS, Diseño, Atención)
New-UDLayout -Columns 3 -Content {
    foreach ($script in $Scripts) {
        New-ScriptButton -Script $script -Config $Config
    }
}
```

---

## 5. Critical Actions Section

### Propósito
Sección dedicada para acciones que afectan el sistema inmediatamente (reiniciar PC, reiniciar dashboard).

### Función Nueva

```powershell
function New-CriticalActionsSection {
    param(
        [Parameter(Mandatory)]
        [hashtable]$Config
    )

    New-UDCard -Title "ACCIONES CRITICAS" -Content {

        # Caja de advertencia roja
        New-UDElement -Tag 'div' -Attributes @{
            style = @{
                'padding' = $Config.spacing.m
                'background-color' = $Config.colorsParadise.dangerBackground
                'border' = "2px solid $($Config.colors.danger)"
                'border-radius' = '5px'
                'margin-bottom' = $Config.spacing.m
            }
        } -Content {

            New-UDElement -Tag 'p' -Attributes @{
                style = @{
                    'font-weight' = 'bold'
                    'margin-bottom' = $Config.spacing.s
                }
            } -Content {
                "⚠️ ADVERTENCIA: Estas acciones afectaran el sistema inmediatamente"
            }

            # Contenedor flex para botones
            New-UDElement -Tag 'div' -Attributes @{
                style = @{
                    'display' = 'flex'
                    'gap' = $Config.spacing.s
                    'flex-wrap' = 'wrap'
                }
            } -Content {

                # Botón REINICIAR PC
                New-UDButton -Text "REINICIAR PC" -OnClick {
                    Show-UDModal -Content {
                        New-UDHeading -Size 5 -Text "Confirmar Reinicio" -Content {
                            New-UDElement -Tag 'span' -Attributes @{
                                style = @{'color' = '#dc3545'}
                            } -Content { "Confirmar Reinicio" }
                        }

                        New-UDElement -Tag 'p' -Content {
                            "¿Estas seguro de que deseas reiniciar el PC?"
                        }

                        New-UDElement -Tag 'p' -Content {
                            "Esta accion cerrara todas las aplicaciones abiertas."
                        }

                        # Botones de confirmación
                        New-UDElement -Tag 'div' -Attributes @{
                            style = @{
                                'display' = 'flex'
                                'gap' = '10px'
                                'margin-top' = '20px'
                            }
                        } -Content {

                            New-UDButton -Text "SI, REINICIAR" -OnClick {
                                try {
                                    Write-DashboardLog -Message "REINICIO DE PC solicitado por usuario"
                                    Show-UDToast -Message "Reiniciando PC en 10 segundos..." -Duration 8000 -BackgroundColor "#dc3545"
                                    Start-Sleep -Seconds 2
                                    Hide-UDModal
                                    Restart-Computer -Force -Delay 10
                                } catch {
                                    Show-UDToast -Message "Error al reiniciar: $_" -Duration 5000 -BackgroundColor "#dc3545"
                                }
                            } -Style @{
                                'background-color' = '#dc3545'
                                'color' = 'white'
                                'font-weight' = 'bold'
                            }

                            New-UDButton -Text "Cancelar" -OnClick {
                                Hide-UDModal
                            } -Style @{
                                'background-color' = '#6c757d'
                                'color' = 'white'
                            }
                        }
                    }
                } -Style @{
                    'background-color' = $Config.colors.danger
                    'color' = 'white'
                    'font-weight' = 'bold'
                    'padding' = '12px 24px'
                    'border' = 'none'
                    'border-radius' = '4px'
                    'cursor' = 'pointer'
                }

                # Botón Reiniciar Dashboard
                New-UDButton -Text "Reiniciar Dashboard" -OnClick {
                    try {
                        Write-DashboardLog -Message "REINICIO DE DASHBOARD solicitado por usuario"
                        Show-UDToast -Message "Reiniciando dashboard..." -Duration 3000 -BackgroundColor "#ff9800"
                        Start-Sleep -Seconds 2

                        # Detener dashboard actual
                        Get-UDDashboard | Stop-UDDashboard

                        # Reiniciar (el script Iniciar-Dashboard.bat lo manejará)
                        Start-Process -FilePath "powershell.exe" -ArgumentList "-File `"$PSScriptRoot\..\..\Dashboard.ps1`"" -WindowStyle Hidden

                    } catch {
                        Show-UDToast -Message "Error al reiniciar dashboard: $_" -Duration 5000 -BackgroundColor "#dc3545"
                    }
                } -Style @{
                    'background-color' = $Config.colors.warning
                    'color' = 'white'
                    'padding' = '12px 24px'
                    'border' = 'none'
                    'border-radius' = '4px'
                    'cursor' = 'pointer'
                }
            }
        }
    }
}
```

### Uso en Dashboard-UI.ps1

```powershell
# Al final del contenido, después de todas las categorías
New-SectionSeparator -Config $Config
New-CriticalActionsSection -Config $Config
```

---

## 6. Dashboard Footer

### Propósito
Mostrar versión del dashboard y timestamp en el footer.

### Función Nueva

```powershell
function New-DashboardFooter {
    param(
        [Parameter(Mandatory)]
        [hashtable]$Config
    )

    New-UDElement -Tag 'div' -Attributes @{
        style = @{
            'text-align' = 'center'
            'color' = $Config.colorsParadise.footerText
            'margin-top' = $Config.spacing.xl
            'padding' = $Config.spacing.m
            'font-size' = '12px'
            'border-top' = '1px solid #ddd'
        }
    } -Content {
        $timestamp = Get-Date -Format 'dd/MM/yyyy HH:mm'
        "Paradise-SystemLabs Dashboard v$($Config.version) | $timestamp"
    }
}
```

### Uso en Dashboard-UI.ps1

```powershell
# Al final absoluto del dashboard
New-SectionSeparator -Config $Config
New-DashboardFooter -Config $Config
```

---

## 7. Variantes de Botones

### Propósito
Diferenciar visualmente botones según su tipo de acción (estándar, éxito, peligro, advertencia).

### Modificación de `New-ScriptButton`

**Agregar parámetro `-ButtonStyle`:**

```powershell
function New-ScriptButton {
    param(
        [Parameter(Mandatory)]
        [hashtable]$Script,

        [Parameter(Mandatory)]
        [hashtable]$Config,

        [Parameter()]
        [ValidateSet('default', 'success', 'danger', 'warning')]
        [string]$ButtonStyle = 'default'
    )

    # Determinar colores según estilo
    $buttonColors = switch ($ButtonStyle) {
        'success' {
            @{
                'background-color' = $Config.colors.success
                'color' = 'white'
                'font-weight' = 'normal'
            }
        }
        'danger' {
            @{
                'background-color' = $Config.colors.danger
                'color' = 'white'
                'font-weight' = 'bold'
            }
        }
        'warning' {
            @{
                'background-color' = $Config.colors.warning
                'color' = 'white'
                'font-weight' = 'normal'
            }
        }
        default {
            @{
                'background-color' = $Config.colors.primary
                'color' = 'white'
                'font-weight' = 'normal'
            }
        }
    }

    # Agregar estilos comunes
    $buttonColors['padding'] = '12px 20px'
    $buttonColors['border'] = 'none'
    $buttonColors['border-radius'] = '4px'
    $buttonColors['cursor'] = 'pointer'
    $buttonColors['width'] = '100%'
    $buttonColors['text-align'] = 'left'

    New-UDButton -Text $Script.Name -OnClick {
        # Lógica del script...
    } -Style $buttonColors
}
```

### Ejemplo de Uso

```powershell
# Botón estándar (azul)
New-ScriptButton -Script $script -Config $Config

# Botón de éxito (verde) - para mantenimiento
New-ScriptButton -Script $script -Config $Config -ButtonStyle 'success'

# Botón de peligro (rojo, bold) - para eliminar usuarios
New-ScriptButton -Script $script -Config $Config -ButtonStyle 'danger'

# Botón de advertencia (naranja) - para acciones delicadas
New-ScriptButton -Script $script -Config $Config -ButtonStyle 'warning'
```

### Asignación Automática por Metadata

Opcionalmente, leer metadata del script para asignar estilo:

```powershell
# En el script, agregar:
# @ButtonStyle: success

# En New-ScriptButton, leer:
if ($Script.metadata.ContainsKey('ButtonStyle')) {
    $ButtonStyle = $Script.metadata.ButtonStyle
}
```

---

## 8. Code Blocks Formateados

### Propósito
Mostrar outputs de scripts, logs y diagnósticos con formato de código legible.

### Función Nueva

```powershell
function New-CodeBlock {
    param(
        [Parameter(Mandatory)]
        [string]$Content,

        [Parameter(Mandatory)]
        [hashtable]$Config
    )

    New-UDElement -Tag 'pre' -Attributes @{
        style = @{
            'background-color' = $Config.colorsParadise.codeBackground
            'padding' = '15px'
            'border-radius' = '5px'
            'font-family' = $Config.typography.codeFontFamily
            'font-size' = '13px'
            'max-height' = '500px'
            'overflow' = 'auto'
            'white-space' = 'pre-wrap'
            'line-height' = '1.6'
            'border' = '1px solid #ddd'
            'color' = '#333'
        }
    } -Content {
        $Content
    }
}
```

### Ejemplo de Uso

```powershell
# En un modal, mostrar output de Get-LocalUser
$output = Get-LocalUser | Format-Table -AutoSize | Out-String

Show-UDModal -Content {
    New-UDHeading -Size 5 -Text "Usuarios del Sistema"

    New-CodeBlock -Content $output -Config $Config
}
```

---

## 9. Cajas de Estado

### Propósito
Mostrar mensajes de éxito, advertencia o error en modales con formato visual claro.

### Funciones Nuevas

#### Success Box (Verde)

```powershell
function New-SuccessBox {
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [Parameter(Mandatory)]
        [hashtable]$Config
    )

    New-UDElement -Tag 'div' -Attributes @{
        style = @{
            'background-color' = $Config.colorsParadise.successBackground
            'border-left' = "4px solid $($Config.colors.success)"
            'padding' = '12px'
            'border-radius' = '4px'
            'margin' = '10px 0'
        }
    } -Content {
        New-UDElement -Tag 'span' -Content { "✅ " }
        New-UDElement -Tag 'span' -Content { $Message }
    }
}
```

#### Warning Box (Amarillo)

```powershell
function New-WarningBox {
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [Parameter(Mandatory)]
        [hashtable]$Config
    )

    New-UDElement -Tag 'div' -Attributes @{
        style = @{
            'background-color' = $Config.colorsParadise.warningBackground
            'border' = "2px solid $($Config.colorsParadise.warningBorder)"
            'padding' = '12px'
            'border-radius' = '4px'
            'margin' = '10px 0'
        }
    } -Content {
        New-UDElement -Tag 'span' -Content { "⚠️ " }
        New-UDElement -Tag 'span' -Content { $Message }
    }
}
```

#### Danger Box (Rojo)

```powershell
function New-DangerBox {
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [Parameter(Mandatory)]
        [hashtable]$Config
    )

    New-UDElement -Tag 'div' -Attributes @{
        style = @{
            'background-color' = $Config.colorsParadise.dangerBackground
            'border' = "2px solid $($Config.colors.danger)"
            'padding' = '12px'
            'border-radius' = '4px'
            'margin' = '10px 0'
        }
    } -Content {
        New-UDElement -Tag 'span' -Content { "❌ " }
        New-UDElement -Tag 'span' -Content { $Message }
    }
}
```

### Ejemplo de Uso

```powershell
# En un endpoint de script
try {
    # Crear usuario...

    Show-UDModal -Content {
        New-SuccessBox -Message "Usuario creado exitosamente: POS-Merliot" -Config $Config

        New-CodeBlock -Content "Nombre: POS-Merliot`nTipo: Administrador`nEstado: Habilitado" -Config $Config
    }

} catch {
    Show-UDModal -Content {
        New-DangerBox -Message "Error al crear usuario: $_" -Config $Config
    }
}
```

---

## 10. CSS Global

### Propósito
Aplicar tipografía y estilos base a todo el dashboard.

### Implementación

**Agregar al inicio del dashboard (en `New-UDDashboard`):**

```powershell
function New-DashboardUI {
    param(...)

    # CSS global
    $globalCSS = @"
<style>
    body {
        font-family: $($Config.typography.fontFamily);
        font-size: $($Config.typography.baseFontSize);
    }

    h1, h2, h3, h4, h5, h6 {
        font-family: $($Config.typography.fontFamily);
        font-weight: bold;
    }

    h4 {
        font-size: $($Config.typography.headingFontSize);
    }

    pre, code {
        font-family: $($Config.typography.codeFontFamily);
    }

    button {
        font-family: $($Config.typography.fontFamily);
        transition: opacity 0.2s;
    }

    button:hover {
        opacity: 0.9;
    }
</style>
"@

    New-UDDashboard -Title "Paradise-SystemLabs Dashboard" -Content {

        # Inyectar CSS global
        New-UDElement -Tag 'style' -Content { $globalCSS }

        # Header
        New-DashboardHeader -Config $Config

        # Contenido principal
        New-DashboardContent -Config $Config -AllScripts $AllScripts
    }
}
```

---

## 📦 Resumen de Cambios en Dashboard-UI.ps1

### Funciones Nuevas a Agregar

1. ✅ `New-SystemInfoCard` - Caja amarilla con info del PC
2. ✅ `New-SectionSeparator` - HR con espaciado XL
3. ✅ `New-CriticalActionsSection` - Caja roja con botones de reinicio
4. ✅ `New-DashboardFooter` - Footer con versión
5. ✅ `New-CodeBlock` - Bloques de código formateados
6. ✅ `New-SuccessBox` - Caja verde de éxito
7. ✅ `New-WarningBox` - Caja amarilla de advertencia
8. ✅ `New-DangerBox` - Caja roja de error

### Funciones a Modificar

1. ✏️ `New-DashboardContent` - Agregar container wrapper
2. ✏️ `New-CategorySection` - Convertir a card-based layout
3. ✏️ `New-ScriptButton` - Agregar parámetro `-ButtonStyle`
4. ✏️ `New-DashboardUI` - Inyectar CSS global

### Estructura Final

```
New-UDDashboard
├── CSS Global
├── New-DashboardHeader
└── New-DashboardContent (con wrapper 1400px)
    ├── New-SystemInfoCard
    ├── New-SectionSeparator
    ├── Categorías (foreach)
    │   └── New-CategorySection (card-based)
    │       └── New-ScriptButton (con estilos)
    ├── New-SectionSeparator
    ├── New-CriticalActionsSection
    ├── New-SectionSeparator
    └── New-DashboardFooter
```

---

**Documento creado:** Noviembre 2025
**Próximo paso:** Implementar cambios en Dashboard-UI.ps1
