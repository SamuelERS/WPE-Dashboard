# ============================================
# SCRIPT LOADER - Sistema Modular de Scripts
# ============================================
# Gestiona la carga dinámica de scripts organizados por categoría
# Parte de la arquitectura modular WPE-Dashboard

<#
.SYNOPSIS
    Sistema de carga dinámica de scripts modulares
.DESCRIPTION
    Proporciona funciones para descubrir, cargar y ejecutar scripts
    organizados por categorías con metadata
.NOTES
    Versión: 2.0 - Fase 3
    Parte de la arquitectura modular WPE-Dashboard
#>

# Detectar ubicación del dashboard para rutas relativas
if (-not $Global:DashboardRoot) {
    $Global:DashboardRoot = Split-Path -Parent $PSScriptRoot
}

# Importar utilidades
. (Join-Path $Global:DashboardRoot "Utils\Logging-Utils.ps1")

function Get-ScriptsByCategory {
    <#
    .SYNOPSIS
        Obtiene todos los scripts de una categoría específica
    .PARAMETER Category
        Nombre de la categoría (Configuracion, Mantenimiento, POS, etc.)
    .EXAMPLE
        $scripts = Get-ScriptsByCategory -Category "Configuracion"
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Category
    )
    
    try {
        # Usar ruta relativa
        $categoryPath = Join-Path $Global:DashboardRoot "Scripts\$Category"
        
        if (-not (Test-Path $categoryPath)) {
            Write-DashboardLog -Message "Categoría no encontrada: $Category" -Level "Warning" -Component "ScriptLoader"
            return @()
        }
        
        # Obtener todos los scripts .ps1 excepto ScriptLoader
        $scripts = Get-ChildItem -Path $categoryPath -Filter "*.ps1" -File -ErrorAction Stop | 
            Where-Object { $_.Name -ne "ScriptLoader.ps1" }
        
        Write-DashboardLog -Message "Encontrados $($scripts.Count) scripts en categoría: $Category" -Level "Info" -Component "ScriptLoader"
        
        return $scripts
        
    } catch {
        Write-DashboardLog -Message "Error obteniendo scripts de categoría $Category : $_" -Level "Error" -Component "ScriptLoader"
        return @()
    }
}

function Get-ScriptMetadata {
    <#
    .SYNOPSIS
        Extrae metadata de un script desde sus comentarios
    .PARAMETER ScriptPath
        Ruta completa al archivo del script
    .EXAMPLE
        $metadata = Get-ScriptMetadata -ScriptPath "C:\...\Script.ps1"
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ScriptPath
    )
    
    try {
        if (-not (Test-Path $ScriptPath)) {
            throw "Script no encontrado: $ScriptPath"
        }
        
        # Leer las primeras 30 líneas para obtener metadata
        $content = Get-Content $ScriptPath -TotalCount 30 -ErrorAction Stop
        
        # Inicializar metadata con valores por defecto
        $metadata = @{
            Name = [System.IO.Path]::GetFileNameWithoutExtension($ScriptPath)
            Description = "Sin descripción"
            Category = ""
            RequiresAdmin = $false
            HasForm = $false
            FormFields = @()
            ScriptPath = $ScriptPath
        }
        
        # Parsear metadata desde comentarios
        foreach ($line in $content) {
            if ($line -match "^#\s*@Name:\s*(.+)$") {
                $metadata.Name = $matches[1].Trim()
            }
            elseif ($line -match "^#\s*@Description:\s*(.+)$") {
                $metadata.Description = $matches[1].Trim()
            }
            elseif ($line -match "^#\s*@Category:\s*(.+)$") {
                $metadata.Category = $matches[1].Trim()
            }
            elseif ($line -match "^#\s*@RequiresAdmin:\s*(true|yes|1)$") {
                $metadata.RequiresAdmin = $true
            }
            elseif ($line -match "^#\s*@HasForm:\s*(true|yes|1)$") {
                $metadata.HasForm = $true
            }
            elseif ($line -match "^#\s*@FormField:\s*(.+)$") {
                # Formato: nombreCampo|Placeholder|tipo
                $metadata.FormFields += $matches[1].Trim()
            }
        }
        
        return $metadata
        
    } catch {
        Write-DashboardLog -Message "Error obteniendo metadata de $ScriptPath : $_" -Level "Error" -Component "ScriptLoader"
        return $null
    }
}

function Get-AllScriptsMetadata {
    <#
    .SYNOPSIS
        Obtiene metadata de todos los scripts organizados por categoría
    .EXAMPLE
        $allScripts = Get-AllScriptsMetadata
    #>
    
    try {
        $allScripts = @{}
        
        # Cargar categorías desde config
        $categoriesConfig = Load-CategoriesConfig
        
        foreach ($category in $categoriesConfig.categories) {
            $categoryId = $category.id
            $categoryPath = $category.path
            
            # Obtener scripts de esta categoría
            $scripts = Get-ScriptsByCategory -Category $categoryPath
            
            $scriptsMetadata = @()
            foreach ($script in $scripts) {
                $metadata = Get-ScriptMetadata -ScriptPath $script.FullName
                if ($metadata) {
                    $scriptsMetadata += $metadata
                }
            }
            
            $allScripts[$categoryId] = @{
                Title = $category.title
                Icon = $category.icon
                Description = $category.description
                Order = $category.order
                Visible = $category.visible
                Scripts = $scriptsMetadata
            }
        }
        
        Write-DashboardLog -Message "Metadata cargada para $($allScripts.Count) categorías" -Level "Info" -Component "ScriptLoader"
        
        return $allScripts
        
    } catch {
        Write-DashboardLog -Message "Error cargando metadata de todos los scripts: $_" -Level "Error" -Component "ScriptLoader"
        return @{}
    }
}

function Load-CategoriesConfig {
    <#
    .SYNOPSIS
        Carga configuración de categorías desde JSON
    .EXAMPLE
        $categories = Load-CategoriesConfig
    #>
    
    try {
        $configPath = Join-Path $Global:DashboardRoot "Config\categories-config.json"
        
        if (-not (Test-Path $configPath)) {
            throw "Archivo de configuración de categorías no encontrado: $configPath"
        }
        
        $config = Get-Content $configPath -Raw -ErrorAction Stop | ConvertFrom-Json
        
        return $config
        
    } catch {
        Write-DashboardLog -Message "Error cargando configuración de categorías: $_" -Level "Error" -Component "ScriptLoader"
        
        # Retornar configuración por defecto
        return @{
            categories = @(
                @{id="configuracion"; title="CONFIGURACIÓN INICIAL"; icon="⚙️"; path="Configuracion"; order=1; visible=$true; description="Configuración inicial del sistema"}
                @{id="mantenimiento"; title="MANTENIMIENTO"; icon="🔧"; path="Mantenimiento"; order=2; visible=$true; description="Tareas de mantenimiento"}
                @{id="pos"; title="PUNTO DE VENTA"; icon="💰"; path="POS"; order=3; visible=$true; description="Configuración POS"}
            )
        }
    }
}

function Invoke-ModularScript {
    <#
    .SYNOPSIS
        Ejecuta un script modular con parámetros
    .PARAMETER ScriptPath
        Ruta completa al script
    .PARAMETER Parameters
        Hashtable con parámetros para el script
    .EXAMPLE
        $result = Invoke-ModularScript -ScriptPath "C:\...\Script.ps1" -Parameters @{param1="value1"}
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ScriptPath,
        
        [Parameter(Mandatory=$false)]
        [hashtable]$Parameters = @{}
    )
    
    try {
        if (-not (Test-Path $ScriptPath)) {
            throw "Script no encontrado: $ScriptPath"
        }
        
        Write-DashboardLog -Message "Ejecutando script: $ScriptPath" -Level "Info" -Component "ScriptLoader"
        
        # Ejecutar script con parámetros
        $result = & $ScriptPath @Parameters
        
        return $result
        
    } catch {
        Write-DashboardLog -Message "Error ejecutando script $ScriptPath : $_" -Level "Error" -Component "ScriptLoader"
        
        return @{
            Success = $false
            Message = "Error: $_"
        }
    }
}

# Exportar funciones
Export-ModuleMember -Function Get-ScriptsByCategory, Get-ScriptMetadata, Get-AllScriptsMetadata, Load-CategoriesConfig, Invoke-ModularScript
