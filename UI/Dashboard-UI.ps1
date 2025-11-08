# ============================================
# DASHBOARD UI - GENERACION DINAMICA DE INTERFAZ
# ============================================
# Version: 2.0 - Modular y Dinamico
# Proposito: Generar UI del dashboard basada en scripts y configuracion

<#
.SYNOPSIS
    Generador dinamico de UI para WPE-Dashboard

.DESCRIPTION
    Crea la interfaz del dashboard dinamicamente basandose en:
    - Scripts disponibles con metadata
    - Configuracion de categorias
    - Configuracion de colores y espaciado

.NOTES
    Requiere: ScriptLoader, UniversalDashboard
#>

# ============================================
# FUNCIONES DE GENERACION DE UI
# ============================================

function New-DashboardHeader {
    <#
    .SYNOPSIS
        Genera el header del dashboard
    
    .PARAMETER Colors
        Hashtable con colores del tema
    #>
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Colors
    )
    
    New-UDRow -Columns {
        New-UDColumn -Size 12 -Content {
            New-UDHeading -Text "Dashboard IT Paradise-SystemLabs" -Size 3
            New-UDElement -Tag "p" -Content {
                "PC ACTUAL: $env:COMPUTERNAME"
            }
        }
    }
}

function New-ScriptButton {
    <#
    .SYNOPSIS
        Genera un boton para ejecutar un script
    
    .PARAMETER Script
        Hashtable con metadata del script
    
    .PARAMETER Colors
        Hashtable con colores del tema
    #>
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Script,
        
        [Parameter(Mandatory=$true)]
        [hashtable]$Colors
    )
    
    $scriptPath = $Script.Path
    $scriptName = $Script.Name
    $requiresAdmin = $Script.RequiresAdmin
    
    New-UDButton -Text $scriptName -OnClick {
        Show-UDModal -Content {
            New-UDHeading -Text $scriptName -Size 5
            
            # Verificar permisos de admin si es necesario
            if ($requiresAdmin) {
                $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
                
                if (-not $isAdmin) {
                    New-UDElement -Tag "div" -Attributes @{style = @{color = "red"}} -Content {
                        "[ERROR] Este script requiere permisos de administrador"
                    }
                    return
                }
            }
            
            New-UDElement -Tag "div" -Content {
                "Ejecutando script..."
            }
            
            try {
                # Ejecutar script
                $output = & $scriptPath 2>&1 | Out-String
                
                New-UDElement -Tag "pre" -Attributes @{style = @{
                    backgroundColor = "#f5f5f5"
                    padding = "10px"
                    borderRadius = "5px"
                    maxHeight = "400px"
                    overflow = "auto"
                }} -Content {
                    $output
                }
                
                Write-DashboardLog -Message "Script ejecutado: $scriptName" -Level "Info" -Component "UI"
                
            } catch {
                New-UDElement -Tag "div" -Attributes @{style = @{color = "red"}} -Content {
                    "[ERROR] Error al ejecutar script: $_"
                }
                
                Write-DashboardLog -Message "Error al ejecutar $scriptName : $_" -Level "Error" -Component "UI"
            }
            
        } -Footer {
            New-UDButton -Text "Cerrar" -OnClick {
                Hide-UDModal
            }
        }
    } -Style @{
        margin = "5px"
        backgroundColor = $Colors.Primary
    }
}

function New-CategorySection {
    <#
    .SYNOPSIS
        Genera una seccion de categoria con sus scripts
    
    .PARAMETER CategoryName
        Nombre de la categoria
    
    .PARAMETER Scripts
        Array de scripts en esta categoria
    
    .PARAMETER Colors
        Hashtable con colores del tema
    
    .PARAMETER CategoryConfig
        Configuracion de la categoria (icon, order, etc)
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$CategoryName,
        
        [Parameter(Mandatory=$true)]
        [array]$Scripts,
        
        [Parameter(Mandatory=$true)]
        [hashtable]$Colors,
        
        [Parameter(Mandatory=$false)]
        [hashtable]$CategoryConfig = @{}
    )
    
    New-UDRow -Columns {
        New-UDColumn -Size 12 -Content {
            New-UDHeading -Text $CategoryName -Size 4
            
            New-UDRow -Columns {
                foreach ($script in $Scripts) {
                    New-UDColumn -Size 3 -Content {
                        New-ScriptButton -Script $script -Colors $Colors
                    }
                }
            }
        }
    }
}

function New-DashboardContent {
    <#
    .SYNOPSIS
        Genera el contenido completo del dashboard
    
    .PARAMETER ScriptsByCategory
        Hashtable con scripts agrupados por categoria
    
    .PARAMETER CategoriesConfig
        Array con configuracion de categorias
    
    .PARAMETER Colors
        Hashtable con colores del tema
    #>
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$ScriptsByCategory,
        
        [Parameter(Mandatory=$true)]
        [array]$CategoriesConfig,
        
        [Parameter(Mandatory=$true)]
        [hashtable]$Colors
    )
    
    # Header
    New-DashboardHeader -Colors $Colors
    
    # Separador
    New-UDElement -Tag "hr"
    
    # Ordenar categorias segun configuracion
    $orderedCategories = $CategoriesConfig | 
                         Where-Object { $_.enabled -eq $true } | 
                         Sort-Object -Property order
    
    # Generar seccion para cada categoria
    foreach ($categoryConfig in $orderedCategories) {
        $categoryName = $categoryConfig.name
        
        if ($ScriptsByCategory.ContainsKey($categoryName)) {
            $scripts = $ScriptsByCategory[$categoryName]
            
            New-CategorySection -CategoryName $categoryName `
                               -Scripts $scripts `
                               -Colors $Colors `
                               -CategoryConfig $categoryConfig
            
            # Separador entre categorias
            New-UDElement -Tag "hr"
        }
    }
    
    # Agregar categorias no configuradas al final
    foreach ($categoryName in $ScriptsByCategory.Keys) {
        $isConfigured = $orderedCategories | Where-Object { $_.name -eq $categoryName }
        
        if (-not $isConfigured) {
            $scripts = $ScriptsByCategory[$categoryName]
            
            New-CategorySection -CategoryName $categoryName `
                               -Scripts $scripts `
                               -Colors $Colors
            
            New-UDElement -Tag "hr"
        }
    }
}

# ============================================
# EXPORTAR FUNCIONES
# ============================================

Export-ModuleMember -Function @(
    'New-DashboardHeader',
    'New-ScriptButton',
    'New-CategorySection',
    'New-DashboardContent'
)

Write-DashboardLog -Message "Dashboard-UI 2.0 cargado exitosamente" -Level "Info" -Component "UI"
