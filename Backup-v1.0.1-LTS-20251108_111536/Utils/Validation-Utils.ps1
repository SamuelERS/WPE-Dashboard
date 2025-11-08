# ============================================
# VALIDATION UTILITIES
# ============================================
# Funciones de validación reutilizables
# Parte de la arquitectura modular WPE-Dashboard

<#
.SYNOPSIS
    Utilidades de validación para el Dashboard IT
.DESCRIPTION
    Contiene funciones para validar nombres de usuario, contraseñas,
    nombres de PC y sanitización de inputs
#>

function Test-ValidUsername {
    <#
    .SYNOPSIS
        Valida un nombre de usuario
    .PARAMETER Username
        Nombre de usuario a validar
    .EXAMPLE
        Test-ValidUsername "usuario123"
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Username
    )
    
    # Verificar que no esté vacío
    if ([string]::IsNullOrWhiteSpace($Username)) {
        return $false
    }
    
    # Verificar longitud (3-20 caracteres)
    if ($Username.Length -lt 3 -or $Username.Length -gt 20) {
        return $false
    }
    
    # Solo caracteres alfanuméricos, guiones y guiones bajos
    if ($Username -match '[^a-zA-Z0-9_-]') {
        return $false
    }
    
    # No puede empezar con número
    if ($Username -match '^[0-9]') {
        return $false
    }
    
    return $true
}

function Test-ValidPassword {
    <#
    .SYNOPSIS
        Valida una contraseña
    .PARAMETER Password
        Contraseña a validar
    .PARAMETER MinLength
        Longitud mínima requerida (default: 6)
    .EXAMPLE
        Test-ValidPassword "MiPassword123" -MinLength 8
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Password,
        
        [Parameter(Mandatory=$false)]
        [int]$MinLength = 6
    )
    
    # Verificar que no esté vacía
    if ([string]::IsNullOrWhiteSpace($Password)) {
        return $false
    }
    
    # Verificar longitud mínima
    if ($Password.Length -lt $MinLength) {
        return $false
    }
    
    return $true
}

function Test-ValidPCName {
    <#
    .SYNOPSIS
        Valida un nombre de PC según estándares de Windows
    .PARAMETER PCName
        Nombre de PC a validar
    .EXAMPLE
        Test-ValidPCName "WPE-PC01"
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$PCName
    )
    
    # Verificar que no esté vacío
    if ([string]::IsNullOrWhiteSpace($PCName)) {
        return $false
    }
    
    # Verificar longitud (1-15 caracteres según estándar NetBIOS)
    if ($PCName.Length -lt 1 -or $PCName.Length -gt 15) {
        return $false
    }
    
    # Solo caracteres alfanuméricos y guiones
    if ($PCName -match '[^a-zA-Z0-9-]') {
        return $false
    }
    
    # No puede empezar o terminar con guión
    if ($PCName -match '^-|-$') {
        return $false
    }
    
    return $true
}

function Sanitize-Input {
    <#
    .SYNOPSIS
        Sanitiza un input del usuario removiendo caracteres peligrosos
    .PARAMETER Input
        String a sanitizar
    .EXAMPLE
        Sanitize-Input "usuario<script>alert('xss')</script>"
    #>
    param(
        [Parameter(Mandatory=$true)]
        [AllowEmptyString()]
        [string]$Input
    )
    
    # Remover caracteres potencialmente peligrosos
    $sanitized = $Input -replace '[<>"''`;\\|]', ''
    
    # Trim espacios
    $sanitized = $sanitized.Trim()
    
    return $sanitized
}

function Test-ValidEmail {
    <#
    .SYNOPSIS
        Valida un email con regex básico
    .PARAMETER Email
        Email a validar
    .EXAMPLE
        Test-ValidEmail "usuario@dominio.com"
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Email
    )
    
    if ([string]::IsNullOrWhiteSpace($Email)) {
        return $false
    }
    
    # Regex básico para email
    $emailRegex = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    
    return $Email -match $emailRegex
}

# ============================================
# FUNCIONES EXPORTADAS (dot-sourced)
# ============================================
# Las siguientes funciones estan disponibles:
# - Test-ValidUsername
# - Test-ValidPassword
# - Test-ValidPCName
# - Sanitize-Input
# - Test-ValidEmail
