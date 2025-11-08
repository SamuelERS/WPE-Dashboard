# ===================================================================
# DashboardContent.psm1
# Paradise Dashboard v2.0 - Módulo Base de Contenido
# ===================================================================
#
# Descripción:
#   Módulo base para la arquitectura modular v2.0 del Paradise Dashboard.
#   Implementa el contenido principal del dashboard de forma desacoplada.
#
# Compatibilidad:
#   - UniversalDashboard.Community v2.9.0
#   - PowerShell 5.1+
#   - Windows 10/11, Windows Server 2016+
#
# Dependencias:
#   - UniversalDashboard.Community (debe estar importado previamente)
#
# Autor: Paradise-SystemLabs
# Versión: 2.0.0
# Fecha: 2025-11-08
# Caso: 10 - Restauración Modular v2.0
# ===================================================================

<#
.SYNOPSIS
    Genera una tarjeta de demostración del módulo Paradise Dashboard v2.0.

.DESCRIPTION
    Función modular que crea una tarjeta de información sobre el estado
    del módulo v2.0. Diseñada para demostración de la arquitectura modular.

.EXAMPLE
    New-ParadiseModuleDemo
    Genera una tarjeta informativa del módulo v2.0 con estilo Paradise.

.NOTES
    - No requiere parámetros externos
    - Estilo Paradise: amarillo (#fff3cd) con borde amber (#ffc107)
    - NO interfiere con New-DashboardContent de v1.0.1-LTS
    - Nombre cambiado para evitar conflicto de funciones
#>
function New-ParadiseModuleDemo {
    [CmdletBinding()]
    param()

    try {
        # Contenido modular inicial Paradise v2.0
        New-UDColumn -AutoSize -Content {
            New-UDCard -Title "Paradise Dashboard v2.0" -Content {

                # Tarjeta de información con estilo Paradise
                New-UDElement -Tag 'div' -Attributes @{
                    style = @{
                        'background-color' = '#fff3cd'
                        'border'           = '2px solid #ffc107'
                        'border-radius'    = '5px'
                        'padding'          = '12px'
                        'margin-bottom'    = '16px'
                    }
                } -Content {
                    New-UDHeading -Size 5 -Text "Reconstrucción modular inicial en progreso..."
                    New-UDParagraph -Text "Entorno base funcional - Fase 1 completándose."
                }

                # Información técnica
                New-UDElement -Tag 'div' -Attributes @{
                    style = @{
                        'background-color' = '#f5f5f5'
                        'border-left'      = '4px solid #2196F3'
                        'padding'          = '12px'
                        'margin-top'       = '12px'
                        'font-family'      = 'Consolas, Monaco, monospace'
                        'font-size'        = '12px'
                    }
                } -Content {
                    New-UDHtml -Markup @"
                    <strong>Módulo:</strong> DashboardContent.psm1<br>
                    <strong>Versión:</strong> 2.0.0<br>
                    <strong>Estado:</strong> Integración Híbrida Activa<br>
                    <strong>Arquitectura:</strong> Modular desacoplada<br>
                    <strong>Caso:</strong> 10 - Restauración Modular v2.0
"@
                }
            }
        }
    }
    catch {
        # Manejo de errores robusto
        Write-Error "Error en New-ParadiseModuleDemo: $_"
        New-UDTypography -Text "Error al generar contenido v2.0: $($_.Exception.Message)" -Color 'Red'
    }
}

# ===================================================================
# Exportación de funciones
# ===================================================================

Export-ModuleMember -Function New-ParadiseModuleDemo
