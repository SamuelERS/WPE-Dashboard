# ============================================
# FORM COMPONENTS - Componentes de Formulario
# ============================================
# Generación dinámica de formularios desde metadata
# Parte de la arquitectura modular WPE-Dashboard

<#
.SYNOPSIS
    Componentes para generación dinámica de formularios
.DESCRIPTION
    Genera formularios automáticamente basándose en metadata de scripts
    con validaciones integradas
.NOTES
    Versión: 1.0 - Fase 3
    Parte de la arquitectura modular WPE-Dashboard
#>

function New-DynamicForm {
    <#
    .SYNOPSIS
        Genera un formulario dinámico desde metadata de script
    .PARAMETER ScriptMetadata
        Hashtable con metadata del script
    .PARAMETER ScriptRoot
        Ruta raíz del dashboard
    .PARAMETER Colors
        Hashtable con colores del tema
    .EXAMPLE
        New-DynamicForm -ScriptMetadata $metadata -ScriptRoot $ScriptRoot -Colors $Colors
    #>
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$ScriptMetadata,
        
        [Parameter(Mandatory=$true)]
        [string]$ScriptRoot,
        
        [Parameter(Mandatory=$true)]
        [hashtable]$Colors
    )
    
    New-UDInput -Title $ScriptMetadata.Name -Content {
        # Generar campos dinámicamente desde FormFields
        foreach ($fieldDef in $ScriptMetadata.FormFields) {
            New-FormField -FieldDefinition $fieldDef
        }
        
    } -Endpoint {
        param($ArgumentList)
        
        try {
            # Validaciones básicas
            $hasErrors = $false
            $errorMessages = @()
            
            # Validar campos requeridos
            foreach ($fieldDef in $ScriptMetadata.FormFields) {
                $parts = $fieldDef -split '\|'
                $fieldName = $parts[0]
                
                if ([string]::IsNullOrWhiteSpace($ArgumentList[$fieldName])) {
                    $hasErrors = $true
                    $errorMessages += "El campo '$fieldName' es requerido"
                }
            }
            
            if ($hasErrors) {
                Show-UDToast -Message ($errorMessages -join "; ") -Duration 5000 -BackgroundColor $Colors.Danger
                return
            }
            
            # Mostrar mensaje de progreso
            Show-UDToast -Message "Ejecutando $($ScriptMetadata.Name)..." -Duration 2000
            
            # Preparar parámetros para el script
            $scriptParams = @{}
            foreach ($fieldDef in $ScriptMetadata.FormFields) {
                $parts = $fieldDef -split '\|'
                $fieldName = $parts[0]
                $scriptParams[$fieldName] = $ArgumentList[$fieldName]
            }
            
            # Ejecutar script con parámetros
            $resultado = & $ScriptMetadata.ScriptPath @scriptParams
            
            # Mostrar resultado
            if ($resultado -and $resultado.Success) {
                Show-UDToast -Message $resultado.Message -Duration 8000 -BackgroundColor $Colors.Success
                Hide-UDModal
            } elseif ($resultado) {
                Show-UDToast -Message $resultado.Message -Duration 8000 -BackgroundColor $Colors.Danger
            } else {
                Show-UDToast -Message "Operación completada" -Duration 3000 -BackgroundColor $Colors.Success
                Hide-UDModal
            }
            
        } catch {
            Show-UDToast -Message "Error: $_" -Duration 8000 -BackgroundColor $Colors.Danger
        }
    }
}

function New-FormField {
    <#
    .SYNOPSIS
        Genera un campo de formulario desde definición
    .PARAMETER FieldDefinition
        String con definición del campo (formato: nombre|placeholder|tipo)
    .EXAMPLE
        New-FormField -FieldDefinition "nombreUsuario|Nombre del usuario|textbox"
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$FieldDefinition
    )
    
    # Parsear definición: nombreCampo|Placeholder|tipo
    $parts = $FieldDefinition -split '\|'
    
    if ($parts.Count -lt 2) {
        Write-Warning "Definición de campo inválida: $FieldDefinition"
        return
    }
    
    $fieldName = $parts[0].Trim()
    $placeholder = $parts[1].Trim()
    $fieldType = if ($parts.Count -ge 3) { $parts[2].Trim() } else { "textbox" }
    
    # Generar campo según tipo
    switch ($fieldType.ToLower()) {
        "textbox" {
            New-UDInputField -Name $fieldName -Placeholder $placeholder -Type textbox
        }
        "password" {
            New-UDInputField -Name $fieldName -Placeholder $placeholder -Type password
        }
        "select" {
            # Para select, el placeholder contiene las opciones separadas por comas
            if ($parts.Count -ge 4) {
                $options = $parts[3] -split ','
                New-UDInputField -Name $fieldName -Placeholder $placeholder -Type select -Values $options
            } else {
                New-UDInputField -Name $fieldName -Placeholder $placeholder -Type textbox
            }
        }
        "number" {
            New-UDInputField -Name $fieldName -Placeholder $placeholder -Type number
        }
        "checkbox" {
            New-UDInputField -Name $fieldName -Placeholder $placeholder -Type checkbox
        }
        default {
            New-UDInputField -Name $fieldName -Placeholder $placeholder -Type textbox
        }
    }
}

# Exportar funciones
Export-ModuleMember -Function New-DynamicForm, New-FormField
