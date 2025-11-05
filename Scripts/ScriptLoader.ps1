# ============================================
# SCRIPT LOADER - Sistema Modular de Scripts
# ============================================
# Este archivo gestiona la carga dinámica de scripts
# organizados por categoría

function Get-ScriptsByCategory {
    param([string]$Category)
    
    $categoryPath = "C:\WPE-Dashboard\Scripts\$Category"
    
    if (-not (Test-Path $categoryPath)) {
        return @()
    }
    
    $scripts = Get-ChildItem -Path $categoryPath -Filter "*.ps1" -File | 
        Where-Object { $_.Name -ne "ScriptLoader.ps1" }
    
    return $scripts
}

function Get-ScriptMetadata {
    param([string]$ScriptPath)
    
    # Leer las primeras líneas del script para obtener metadata
    $content = Get-Content $ScriptPath -TotalCount 20
    
    $metadata = @{
        Name = "Script"
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
        elseif ($line -match "^#\s*@RequiresAdmin:\s*(true|yes|1)$") {
            $metadata.RequiresAdmin = $true
        }
        elseif ($line -match "^#\s*@HasForm:\s*(true|yes|1)$") {
            $metadata.HasForm = $true
        }
        elseif ($line -match "^#\s*@FormField:\s*(.+)$") {
            $metadata.FormFields += $matches[1].Trim()
        }
    }
    
    return $metadata
}

# Categorías disponibles
$Global:DashboardCategories = @{
    "Configuracion" = @{
        Title = "CONFIGURACION INICIAL"
        Path = "Configuracion"
    }
    "Mantenimiento" = @{
        Title = "MANTENIMIENTO GENERAL"
        Path = "Mantenimiento"
    }
    "POS" = @{
        Title = "PUNTO DE VENTA (POS)"
        Path = "POS"
    }
    "Diseno" = @{
        Title = "DISEÑO GRAFICO"
        Path = "Diseno"
    }
    "AtencionCliente" = @{
        Title = "ATENCION AL CLIENTE"
        Path = "Atencion-Al-Cliente"
    }
    "Auditoria" = @{
        Title = "HISTORIAL Y AUDITORIA"
        Path = "Auditoria"
    }
}
