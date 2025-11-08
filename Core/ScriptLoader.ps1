# ============================================
# SCRIPTLOADER REAL - CARGA DINAMICA DE MODULOS
# ============================================
# Version: 2.0 - Modular y Dinamico
# Proposito: Cargar scripts automaticamente desde Scripts/ con metadata

<#
.SYNOPSIS
    Cargador dinamico de scripts modulares para WPE-Dashboard

.DESCRIPTION
    Lee metadata de scripts en Scripts/, los categoriza y genera
    botones UI dinamicamente basados en categories-config.json

.NOTES
    Requiere: categories-config.json, scripts con metadata
#>

# ============================================
# FUNCIONES DE PARSING DE METADATA
# ============================================

function Get-ScriptMetadata {
    <#
    .SYNOPSIS
        Extrae metadata de un script PowerShell
    
    .PARAMETER ScriptPath
        Ruta completa al script
    
    .OUTPUTS
        Hashtable con metadata del script
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ScriptPath
    )
    
    try {
        $content = Get-Content $ScriptPath -Raw -ErrorAction Stop
        
        # Buscar bloque de metadata (entre <# METADATA y #>)
        if ($content -match '(?s)<#\s*METADATA\s*(.*?)#>') {
            $metadataBlock = $Matches[1]
            
            $metadata = @{
                Name = ""
                Description = ""
                Category = ""
                RequiresAdmin = $false
                Icon = "cog"
                Order = 999
                Enabled = $true
                Path = $ScriptPath
            }
            
            # Parsear cada campo
            if ($metadataBlock -match 'Name:\s*(.+)') { $metadata.Name = $Matches[1].Trim() }
            if ($metadataBlock -match 'Description:\s*(.+)') { $metadata.Description = $Matches[1].Trim() }
            if ($metadataBlock -match 'Category:\s*(.+)') { $metadata.Category = $Matches[1].Trim() }
            if ($metadataBlock -match 'RequiresAdmin:\s*(true|false)') { $metadata.RequiresAdmin = [bool]::Parse($Matches[1]) }
            if ($metadataBlock -match 'Icon:\s*(.+)') { $metadata.Icon = $Matches[1].Trim() }
            if ($metadataBlock -match 'Order:\s*(\d+)') { $metadata.Order = [int]$Matches[1] }
            if ($metadataBlock -match 'Enabled:\s*(true|false)') { $metadata.Enabled = [bool]::Parse($Matches[1]) }
            
            return $metadata
        }
        
        return $null
        
    } catch {
        Write-DashboardLog -Message "Error al leer metadata de $ScriptPath : $_" -Level "Warning" -Component "ScriptLoader"
        return $null
    }
}

function Get-AllScriptsWithMetadata {
    <#
    .SYNOPSIS
        Obtiene todos los scripts con metadata valida
    
    .OUTPUTS
        Array de hashtables con metadata de scripts
    #>
    
    $scriptsPath = Join-Path $Global:DashboardRoot "Scripts"
    $allScripts = @()
    
    if (-not (Test-Path $scriptsPath)) {
        Write-DashboardLog -Message "Carpeta Scripts/ no encontrada" -Level "Error" -Component "ScriptLoader"
        return @()
    }
    
    # Buscar todos los .ps1 recursivamente, excluyendo PLANTILLA y ScriptLoader
    $scriptFiles = Get-ChildItem $scriptsPath -Recurse -Filter "*.ps1" | 
                   Where-Object { 
                       $_.Name -ne "PLANTILLA-Script.ps1" -and 
                       $_.Name -ne "ScriptLoader.ps1" 
                   }
    
    foreach ($file in $scriptFiles) {
        $metadata = Get-ScriptMetadata -ScriptPath $file.FullName
        
        if ($metadata -and $metadata.Enabled) {
            $allScripts += $metadata
        }
    }
    
    Write-DashboardLog -Message "Scripts cargados: $($allScripts.Count)" -Level "Info" -Component "ScriptLoader"
    return $allScripts
}

function Get-ScriptsByCategory {
    <#
    .SYNOPSIS
        Agrupa scripts por categoria
    
    .OUTPUTS
        Hashtable con categorias como keys y arrays de scripts como values
    #>
    
    $allScripts = Get-AllScriptsWithMetadata
    $categorized = @{}
    
    foreach ($script in $allScripts) {
        $category = $script.Category
        
        if (-not $category) {
            $category = "Sin Categoria"
        }
        
        if (-not $categorized.ContainsKey($category)) {
            $categorized[$category] = @()
        }
        
        $categorized[$category] += $script
    }
    
    # Ordenar scripts dentro de cada categoria por Order
    foreach ($category in $categorized.Keys) {
        $categorized[$category] = $categorized[$category] | Sort-Object -Property Order
    }
    
    return $categorized
}

# ============================================
# FUNCIONES DE CARGA DE CONFIGURACION
# ============================================

function Get-CategoriesConfig {
    <#
    .SYNOPSIS
        Carga configuracion de categorias desde JSON
    
    .OUTPUTS
        Array de categorias con configuracion
    #>
    
    $configPath = Join-Path $Global:DashboardRoot "Config\categories-config.json"
    
    if (-not (Test-Path $configPath)) {
        Write-DashboardLog -Message "categories-config.json no encontrado, usando categorias por defecto" -Level "Warning" -Component "ScriptLoader"
        return @(
            @{name = "Configuracion"; icon = "cog"; order = 1; enabled = $true}
            @{name = "Mantenimiento"; icon = "wrench"; order = 2; enabled = $true}
            @{name = "POS"; icon = "shopping-cart"; order = 3; enabled = $true}
        )
    }
    
    try {
        $config = Get-Content $configPath -Raw | ConvertFrom-Json
        return $config.categories
    } catch {
        Write-DashboardLog -Message "Error al cargar categories-config.json: $_" -Level "Error" -Component "ScriptLoader"
        return @()
    }
}

# ============================================
# EXPORTAR FUNCIONES
# ============================================

Export-ModuleMember -Function @(
    'Get-ScriptMetadata',
    'Get-AllScriptsWithMetadata',
    'Get-ScriptsByCategory',
    'Get-CategoriesConfig'
)

Write-DashboardLog -Message "ScriptLoader 2.0 cargado exitosamente" -Level "Info" -Component "ScriptLoader"
