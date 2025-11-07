# ============================================
# UI COMPONENTS - Componentes de Interfaz
# ============================================
# Funciones para generar UI dinámica desde metadata
# Parte de la arquitectura modular WPE-Dashboard

<#
.SYNOPSIS
    Componentes reutilizables de UI para UniversalDashboard
.DESCRIPTION
    Proporciona funciones para generar cards, botones, modales y toasts
    de forma dinámica basándose en metadata de scripts
.NOTES
    Versión: 1.0 - Fase 3
    Parte de la arquitectura modular WPE-Dashboard
#>

function New-CategoryCard {
    <#
    .SYNOPSIS
        Crea una tarjeta de categoría con sus scripts
    .PARAMETER CategoryInfo
        Hashtable con información de la categoría
    .PARAMETER ScriptRoot
        Ruta raíz del dashboard
    .PARAMETER Colors
        Hashtable con colores del tema
    .PARAMETER Spacing
        Hashtable con espaciados del tema
    .EXAMPLE
        New-CategoryCard -CategoryInfo $catInfo -ScriptRoot $ScriptRoot -Colors $Colors -Spacing $Spacing
    #>
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$CategoryInfo,
        
        [Parameter(Mandatory=$true)]
        [string]$ScriptRoot,
        
        [Parameter(Mandatory=$true)]
        [hashtable]$Colors,
        
        [Parameter(Mandatory=$true)]
        [hashtable]$Spacing
    )
    
    # Crear card de categoría
    New-UDCard -Title "$($CategoryInfo.Icon) $($CategoryInfo.Title)" -Content {
        New-UDElement -Tag 'div' -Attributes @{
            style = @{
                'display' = 'flex'
                'flex-direction' = 'column'
                'gap' = $Spacing.S
                'padding' = $Spacing.M
            }
        } -Content {
            # Generar botón para cada script
            foreach ($script in $CategoryInfo.Scripts) {
                New-ScriptButton -ScriptMetadata $script -ScriptRoot $ScriptRoot -Colors $Colors
            }
        }
    }
}

function New-ScriptButton {
    <#
    .SYNOPSIS
        Crea un botón para ejecutar un script
    .PARAMETER ScriptMetadata
        Hashtable con metadata del script
    .PARAMETER ScriptRoot
        Ruta raíz del dashboard
    .PARAMETER Colors
        Hashtable con colores del tema
    .EXAMPLE
        New-ScriptButton -ScriptMetadata $metadata -ScriptRoot $ScriptRoot -Colors $Colors
    #>
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$ScriptMetadata,
        
        [Parameter(Mandatory=$true)]
        [string]$ScriptRoot,
        
        [Parameter(Mandatory=$true)]
        [hashtable]$Colors
    )
    
    # Crear botón con modal si tiene formulario
    if ($ScriptMetadata.HasForm) {
        New-UDButton -Text $ScriptMetadata.Name -OnClick {
            # Importar componentes de formulario
            . (Join-Path $ScriptRoot "Components\Form-Components.ps1")
            
            # Mostrar modal con formulario
            New-ScriptModal -ScriptMetadata $ScriptMetadata -ScriptRoot $ScriptRoot -Colors $Colors
        }
    } else {
        # Botón sin formulario - ejecuta directamente
        New-UDButton -Text $ScriptMetadata.Name -OnClick {
            try {
                Show-UDToast -Message "Ejecutando $($ScriptMetadata.Name)..." -Duration 2000
                
                # Ejecutar script
                $resultado = & $ScriptMetadata.ScriptPath
                
                # Mostrar resultado
                New-ResultToast -Result $resultado -Colors $Colors
                
            } catch {
                Show-UDToast -Message "Error: $_" -Duration 5000 -BackgroundColor $Colors.Danger
            }
        }
    }
}

function New-ScriptModal {
    <#
    .SYNOPSIS
        Crea un modal con formulario para un script
    .PARAMETER ScriptMetadata
        Hashtable con metadata del script
    .PARAMETER ScriptRoot
        Ruta raíz del dashboard
    .PARAMETER Colors
        Hashtable con colores del tema
    .EXAMPLE
        New-ScriptModal -ScriptMetadata $metadata -ScriptRoot $ScriptRoot -Colors $Colors
    #>
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$ScriptMetadata,
        
        [Parameter(Mandatory=$true)]
        [string]$ScriptRoot,
        
        [Parameter(Mandatory=$true)]
        [hashtable]$Colors
    )
    
    Show-UDModal -Content {
        # Importar componentes de formulario
        . (Join-Path $ScriptRoot "Components\Form-Components.ps1")
        
        # Generar formulario dinámico
        New-DynamicForm -ScriptMetadata $ScriptMetadata -ScriptRoot $ScriptRoot -Colors $Colors
    }
}

function New-ResultToast {
    <#
    .SYNOPSIS
        Muestra un toast con el resultado de la ejecución
    .PARAMETER Result
        Hashtable con resultado (Success, Message)
    .PARAMETER Colors
        Hashtable con colores del tema
    .EXAMPLE
        New-ResultToast -Result $resultado -Colors $Colors
    #>
    param(
        [Parameter(Mandatory=$true)]
        $Result,
        
        [Parameter(Mandatory=$true)]
        [hashtable]$Colors
    )
    
    if ($Result -and $Result.Success) {
        Show-UDToast -Message $Result.Message -Duration 8000 -BackgroundColor $Colors.Success
    } elseif ($Result) {
        Show-UDToast -Message $Result.Message -Duration 8000 -BackgroundColor $Colors.Danger
    } else {
        Show-UDToast -Message "Operación completada" -Duration 3000 -BackgroundColor $Colors.Success
    }
}

# Exportar funciones
Export-ModuleMember -Function New-CategoryCard, New-ScriptButton, New-ScriptModal, New-ResultToast
