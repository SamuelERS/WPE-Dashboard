# ============================================
# DASHBOARD UI - v1.0.1-LTS (MONOLITO)
# ============================================
# Version: 1.0.1-LTS (v1.0.1-LTS-Hybrid)
# Arquitectura: Monolítica (643 líneas, 13 funciones)
# Estado: ACTIVO - Preservado en arquitectura híbrida
# Fecha: 2025-11-08
# Caso: 10 - Restauración Modular v2.0
# Propósito: Generar UI del dashboard con identidad visual Paradise-SystemLabs
#
# NOTA: Este archivo está marcado para migración a v2.0 modular.
#       Ver: Docs/Caso_10_Restauracion_Modular_v2.0/02_Analisis_Modularidad.md
#       Plan: Migrar 13 funciones a 5 módulos especializados (45 horas estimadas)

<#
.SYNOPSIS
    Generador dinámico de UI para WPE-Dashboard con diseño Paradise

.DESCRIPTION
    Crea la interfaz del dashboard dinámicamente basándose en:
    - Scripts disponibles con metadata
    - Configuración de categorías
    - Configuración de colores Paradise y espaciado
    - Sistema de diseño corporativo Paradise-SystemLabs

    ADVERTENCIA: Monolito de 643 líneas con 13 funciones.
    Marcado para refactorización a módulos v2.0.

.NOTES
    Requiere: ScriptLoader, UniversalDashboard
    Version: 1.0.1-LTS
    Arquitectura: Monolítica (será migrado a v2.0 modular)
    Estado: FUNCIONAL - Coexiste con v2.0
    Funciones: 13 (todas en scope global)
    Líneas: 643
#>

# ============================================
# FUNCIONES DE COMPONENTES PARADISE
# ============================================

function New-SystemInfoCard {
    <#
    .SYNOPSIS
        Crea la tarjeta de informacion del sistema con estilo Paradise

    .PARAMETER Config
        Hashtable con configuracion completa del dashboard
    #>
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )

    $pcName = $env:COMPUTERNAME
    $colors = $Config.ui.colors
    $colorsParadise = $Config.ui.colorsParadise
    $spacing = $Config.ui.spacing

    New-UDCard -Title "INFORMACION DEL SISTEMA" -Content {
        New-UDElement -Tag 'div' -Attributes @{
            style = @{
                'padding' = $spacing.xs
                'background-color' = $colorsParadise.warningBackground
                'border' = "2px solid $($colorsParadise.warningBorder)"
                'border-radius' = '5px'
                'margin-bottom' = $spacing.xs
            }
        } -Content {

            New-UDHeading -Size 5 -Text "PC ACTUAL: $pcName"

            New-UDElement -Tag 'p' -Attributes @{
                style = @{'margin' = '8px 0'}
            } -Content {
                "IMPORTANTE: Todos los scripts se ejecutan en esta maquina"
            }

            New-UDElement -Tag 'p' -Attributes @{
                style = @{'margin' = '8px 0'}
            } -Content {
                "Los usuarios se crearan en: $pcName"
            }

            New-UDElement -Tag 'p' -Attributes @{
                style = @{'margin' = '8px 0'}
            } -Content {
                "Si necesitas configurar otra PC, ejecuta el dashboard EN esa maquina"
            }
        }
    }
}

function New-SectionSeparator {
    <#
    .SYNOPSIS
        Crea un separador HR con espaciado Paradise

    .PARAMETER Config
        Hashtable con configuracion completa del dashboard
    #>
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )

    $spacing = $Config.ui.spacing

    New-UDElement -Tag 'hr' -Attributes @{
        style = @{
            'margin' = $spacing.xl + ' 0'
            'border' = 'none'
            'border-top' = '1px solid #ddd'
        }
    }
}

function New-CriticalActionsSection {
    <#
    .SYNOPSIS
        Crea la seccion de acciones criticas con advertencias visuales

    .PARAMETER Config
        Hashtable con configuracion completa del dashboard
    #>
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )

    $colors = $Config.ui.colors
    $colorsParadise = $Config.ui.colorsParadise
    $spacing = $Config.ui.spacing

    New-UDCard -Title "ACCIONES CRITICAS" -Content {

        New-UDElement -Tag 'div' -Attributes @{
            style = @{
                'padding' = $spacing.m
                'background-color' = $colorsParadise.dangerBackground
                'border' = "2px solid $($colors.danger)"
                'border-radius' = '5px'
                'margin-bottom' = $spacing.m
            }
        } -Content {

            New-UDElement -Tag 'p' -Attributes @{
                style = @{
                    'font-weight' = 'bold'
                    'margin-bottom' = $spacing.s
                }
            } -Content {
                "ADVERTENCIA: Estas acciones afectaran el sistema inmediatamente"
            }

            New-UDElement -Tag 'div' -Attributes @{
                style = @{
                    'display' = 'flex'
                    'gap' = $spacing.s
                    'flex-wrap' = 'wrap'
                }
            } -Content {

                # Boton REINICIAR PC
                New-UDButton -Text "REINICIAR PC" -OnClick {
                    Show-UDModal -Content {
                        New-UDHeading -Size 5 -Content {
                            New-UDElement -Tag 'span' -Attributes @{
                                style = @{'color' = '#dc3545'}
                            } -Content { "Confirmar Reinicio" }
                        }

                        New-UDElement -Tag 'p' -Content {
                            "Estas seguro de que deseas reiniciar el PC?"
                        }

                        New-UDElement -Tag 'p' -Content {
                            "Esta accion cerrara todas las aplicaciones abiertas."
                        }

                        New-UDElement -Tag 'div' -Attributes @{
                            style = @{
                                'display' = 'flex'
                                'gap' = '10px'
                                'margin-top' = '20px'
                            }
                        } -Content {

                            New-UDButton -Text "SI, REINICIAR" -OnClick {
                                try {
                                    Write-DashboardLog -Message "REINICIO DE PC solicitado por usuario" -Level "Warning" -Component "CriticalActions"
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
                    'background-color' = $colors.danger
                    'color' = 'white'
                    'font-weight' = 'bold'
                    'padding' = '12px 24px'
                    'border' = 'none'
                    'border-radius' = '4px'
                    'cursor' = 'pointer'
                }

                # Boton Reiniciar Dashboard
                New-UDButton -Text "Reiniciar Dashboard" -OnClick {
                    try {
                        Write-DashboardLog -Message "REINICIO DE DASHBOARD solicitado por usuario" -Level "Warning" -Component "CriticalActions"
                        Show-UDToast -Message "Reiniciando dashboard..." -Duration 3000 -BackgroundColor "#ff9800"
                        Start-Sleep -Seconds 2

                        # Detener dashboard actual
                        Get-UDDashboard | Stop-UDDashboard

                        # Reiniciar usando el script principal
                        $dashboardScript = Join-Path $PSScriptRoot "..\Dashboard.ps1"
                        Start-Process -FilePath "powershell.exe" -ArgumentList "-File `"$dashboardScript`"" -WindowStyle Hidden

                    } catch {
                        Show-UDToast -Message "Error al reiniciar dashboard: $_" -Duration 5000 -BackgroundColor "#dc3545"
                    }
                } -Style @{
                    'background-color' = $colors.warning
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

function New-DashboardFooter {
    <#
    .SYNOPSIS
        Crea el footer del dashboard con version y timestamp

    .PARAMETER Config
        Hashtable con configuracion completa del dashboard
    #>
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )

    $colorsParadise = $Config.ui.colorsParadise
    $spacing = $Config.ui.spacing
    $timestamp = Get-Date -Format 'dd/MM/yyyy HH:mm'

    New-UDElement -Tag 'div' -Attributes @{
        style = @{
            'text-align' = 'center'
            'color' = $colorsParadise.footerText
            'margin-top' = $spacing.xl
            'padding' = $spacing.m
            'font-size' = '12px'
            'border-top' = '1px solid #ddd'
        }
    } -Content {
        "Paradise-SystemLabs Dashboard v1.0.1-LTS | $timestamp"
    }
}

function New-CodeBlock {
    <#
    .SYNOPSIS
        Crea un bloque de codigo formateado estilo Paradise

    .PARAMETER Content
        Contenido del bloque de codigo

    .PARAMETER Config
        Hashtable con configuracion completa del dashboard
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Content,

        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )

    $colorsParadise = $Config.ui.colorsParadise
    $typography = $Config.ui.typography

    New-UDElement -Tag 'pre' -Attributes @{
        style = @{
            'background-color' = $colorsParadise.codeBackground
            'padding' = '15px'
            'border-radius' = '5px'
            'font-family' = $typography.codeFontFamily
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

function New-SuccessBox {
    <#
    .SYNOPSIS
        Crea una caja de estado de exito

    .PARAMETER Message
        Mensaje a mostrar

    .PARAMETER Config
        Hashtable con configuracion completa del dashboard
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )

    $colors = $Config.ui.colors
    $colorsParadise = $Config.ui.colorsParadise

    New-UDElement -Tag 'div' -Attributes @{
        style = @{
            'background-color' = $colorsParadise.successBackground
            'border-left' = "4px solid $($colors.success)"
            'padding' = '12px'
            'border-radius' = '4px'
            'margin' = '10px 0'
        }
    } -Content {
        New-UDElement -Tag 'span' -Content { " $Message" }
    }
}

function New-WarningBox {
    <#
    .SYNOPSIS
        Crea una caja de advertencia

    .PARAMETER Message
        Mensaje a mostrar

    .PARAMETER Config
        Hashtable con configuracion completa del dashboard
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )

    $colorsParadise = $Config.ui.colorsParadise

    New-UDElement -Tag 'div' -Attributes @{
        style = @{
            'background-color' = $colorsParadise.warningBackground
            'border' = "2px solid $($colorsParadise.warningBorder)"
            'padding' = '12px'
            'border-radius' = '4px'
            'margin' = '10px 0'
        }
    } -Content {
        New-UDElement -Tag 'span' -Content { " $Message" }
    }
}

function New-DangerBox {
    <#
    .SYNOPSIS
        Crea una caja de error/peligro

    .PARAMETER Message
        Mensaje a mostrar

    .PARAMETER Config
        Hashtable con configuracion completa del dashboard
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )

    $colors = $Config.ui.colors
    $colorsParadise = $Config.ui.colorsParadise

    New-UDElement -Tag 'div' -Attributes @{
        style = @{
            'background-color' = $colorsParadise.dangerBackground
            'border' = "2px solid $($colors.danger)"
            'padding' = '12px'
            'border-radius' = '4px'
            'margin' = '10px 0'
        }
    } -Content {
        New-UDElement -Tag 'span' -Content { " $Message" }
    }
}

# ============================================
# FUNCIONES DE GENERACION DE UI
# ============================================

function New-DashboardHeader {
    <#
    .SYNOPSIS
        Genera el header del dashboard estilo Paradise

    .PARAMETER Config
        Hashtable con configuracion completa del dashboard
    #>
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )

    New-UDRow -Columns {
        New-UDColumn -Size 12 -Content {
            New-UDHeading -Text "Paradise-SystemLabs Dashboard" -Size 2
        }
    }
}

function New-ScriptButton {
    <#
    .SYNOPSIS
        Genera un boton para ejecutar un script con estilos Paradise

    .PARAMETER Script
        Hashtable con metadata del script

    .PARAMETER Config
        Hashtable con configuracion completa del dashboard

    .PARAMETER ButtonStyle
        Estilo del boton: default, success, danger, warning
    #>
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Script,

        [Parameter(Mandatory=$true)]
        [hashtable]$Config,

        [Parameter(Mandatory=$false)]
        [ValidateSet('default', 'success', 'danger', 'warning')]
        [string]$ButtonStyle = 'default'
    )

    $scriptPath = $Script.Path
    $scriptName = $Script.Name
    $requiresAdmin = $Script.RequiresAdmin
    $colors = $Config.ui.colors

    # Determinar colores segun estilo
    $buttonColors = switch ($ButtonStyle) {
        'success' {
            @{
                'background-color' = $colors.success
                'color' = 'white'
                'font-weight' = 'normal'
            }
        }
        'danger' {
            @{
                'background-color' = $colors.danger
                'color' = 'white'
                'font-weight' = 'bold'
            }
        }
        'warning' {
            @{
                'background-color' = $colors.warning
                'color' = 'white'
                'font-weight' = 'normal'
            }
        }
        default {
            @{
                'background-color' = $colors.primary
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
    $buttonColors['margin'] = '5px 0'

    New-UDButton -Text $scriptName -OnClick {
        Show-UDModal -Content {
            New-UDHeading -Text $scriptName -Size 5

            # Verificar permisos de admin si es necesario
            if ($requiresAdmin) {
                $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

                if (-not $isAdmin) {
                    New-DangerBox -Message "Este script requiere permisos de administrador" -Config $Config
                    return
                }
            }

            New-UDElement -Tag "div" -Content {
                "Ejecutando script en: $env:COMPUTERNAME"
            }

            try {
                # Ejecutar script
                $output = & $scriptPath 2>&1 | Out-String

                New-CodeBlock -Content $output -Config $Config

                New-SuccessBox -Message "Script ejecutado exitosamente" -Config $Config

                Write-DashboardLog -Message "Script ejecutado: $scriptName" -Level "Info" -Component "UI"

            } catch {
                New-DangerBox -Message "Error al ejecutar script: $_" -Config $Config

                Write-DashboardLog -Message "Error al ejecutar $scriptName : $_" -Level "Error" -Component "UI"
            }

        } -Footer {
            New-UDButton -Text "Cerrar" -OnClick {
                Hide-UDModal
            }
        }
    } -Style $buttonColors
}

function New-CategorySection {
    <#
    .SYNOPSIS
        Genera una seccion de categoria con card estilo Paradise

    .PARAMETER CategoryName
        Nombre de la categoria

    .PARAMETER Scripts
        Array de scripts en esta categoria

    .PARAMETER Config
        Hashtable con configuracion completa del dashboard

    .PARAMETER CategoryConfig
        Configuracion de la categoria (icon, order, etc)
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$CategoryName,

        [Parameter(Mandatory=$true)]
        [array]$Scripts,

        [Parameter(Mandatory=$true)]
        [hashtable]$Config,

        [Parameter(Mandatory=$false)]
        [hashtable]$CategoryConfig = @{}
    )

    $spacing = $Config.ui.spacing
    $colors = $Config.ui.colors

    New-UDCard -Title $CategoryName -Content {
        New-UDElement -Tag 'div' -Attributes @{
            style = @{
                'display' = 'flex'
                'flex-direction' = 'column'
                'gap' = $spacing.s
                'padding' = $spacing.m
            }
        } -Content {
            foreach ($script in $Scripts) {
                New-ScriptButton -Script $script -Config $Config
            }
        }
    }
}

function New-DashboardContent {
    <#
    .SYNOPSIS
        Genera el contenido completo del dashboard con estructura Paradise

    .PARAMETER ScriptsByCategory
        Hashtable con scripts agrupados por categoria

    .PARAMETER CategoriesConfig
        Array con configuracion de categorias

    .PARAMETER Config
        Hashtable con configuracion completa del dashboard
    #>
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$ScriptsByCategory,

        [Parameter(Mandatory=$true)]
        [array]$CategoriesConfig,

        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )

    # Inyectar CSS global Paradise
    $globalCSS = Get-ParadiseGlobalCSS -Config $Config
    New-UDHtml -Markup $globalCSS

    # Container wrapper principal (max-width 1400px, centrado)
    New-UDElement -Tag 'div' -Attributes @{
        style = @{
            'max-width' = '1400px'
            'margin' = '0 auto'
            'padding' = '20px'
        }
    } -Content {

        # Header
        New-DashboardHeader -Config $Config

        # System Info Card
        New-SystemInfoCard -Config $Config

        # Separador
        New-SectionSeparator -Config $Config

        # Ordenar categorias segun configuracion
        $orderedCategories = $CategoriesConfig |
                             Where-Object { $_.enabled -eq $true } |
                             Sort-Object -Property order

        # Generar seccion para cada categoria
        foreach ($categoryConfig in $orderedCategories) {
            # FIX: Cambiar de .name a .title para coincidir con categories-config.json
            $categoryName = $categoryConfig.title

            if ($ScriptsByCategory.ContainsKey($categoryName)) {
                $scripts = $ScriptsByCategory[$categoryName]

                New-CategorySection -CategoryName $categoryName `
                                   -Scripts $scripts `
                                   -Config $Config `
                                   -CategoryConfig $categoryConfig

                # Espacio entre categorias
                New-UDElement -Tag 'div' -Attributes @{
                    style = @{'margin-bottom' = $Config.ui.spacing.m}
                }
            }
        }

        # Agregar categorias no configuradas al final
        foreach ($categoryName in $ScriptsByCategory.Keys) {
            $isConfigured = $orderedCategories | Where-Object { $_.title -eq $categoryName }

            if (-not $isConfigured) {
                $scripts = $ScriptsByCategory[$categoryName]

                New-CategorySection -CategoryName $categoryName `
                                   -Scripts $scripts `
                                   -Config $Config

                New-UDElement -Tag 'div' -Attributes @{
                    style = @{'margin-bottom' = $Config.ui.spacing.m}
                }
            }
        }

        # Separador antes de acciones criticas
        New-SectionSeparator -Config $Config

        # Seccion de acciones criticas
        New-CriticalActionsSection -Config $Config

        # Separador antes del footer
        New-SectionSeparator -Config $Config

        # Footer
        New-DashboardFooter -Config $Config
    }
}

# ============================================
# CSS GLOBAL PARADISE
# ============================================
function Get-ParadiseGlobalCSS {
    <#
    .SYNOPSIS
        Genera CSS global para tipografia Paradise

    .PARAMETER Config
        Hashtable con configuracion completa del dashboard
    #>
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )

    $typography = $Config.ui.typography

    @"
<style>
    body {
        font-family: $($typography.fontFamily);
        font-size: $($typography.baseFontSize);
    }

    h1, h2, h3, h4, h5, h6 {
        font-family: $($typography.fontFamily);
        font-weight: bold;
    }

    h4 {
        font-size: $($typography.headingFontSize);
    }

    pre, code {
        font-family: $($typography.codeFontFamily);
    }

    button {
        font-family: $($typography.fontFamily);
        transition: opacity 0.2s;
    }

    button:hover {
        opacity: 0.9;
    }
</style>
"@
}

# ============================================
# FUNCIONES EXPORTADAS (dot-sourced)
# ============================================
# Las siguientes funciones estan disponibles:
# - New-DashboardHeader
# - New-ScriptButton
# - New-CategorySection
# - New-DashboardContent
# - New-SystemInfoCard
# - New-CriticalActionsSection
# - New-DashboardFooter
# - New-CodeBlock
# - New-SuccessBox
# - New-WarningBox
# - New-DangerBox
# - New-SectionSeparator
# - Get-ParadiseGlobalCSS

Write-DashboardLog -Message "Dashboard-UI 2.1 (Paradise Design) cargado exitosamente" -Level "Info" -Component "UI"
