# ============================================
# SECURITY UTILITIES
# ============================================
# Funciones de seguridad reutilizables
# Parte de la arquitectura modular WPE-Dashboard

<#
.SYNOPSIS
    Utilidades de seguridad para el Dashboard IT
.DESCRIPTION
    Contiene funciones para verificar permisos de administrador
    y validar requisitos de seguridad
#>

function Test-AdminPrivileges {
    <#
    .SYNOPSIS
        Verifica si el proceso actual tiene permisos de administrador
    .EXAMPLE
        if (Test-AdminPrivileges) { Write-Host "Es administrador" }
    #>
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [Security.Principal.WindowsPrincipal]$identity
        $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
        
        return $principal.IsInRole($adminRole)
    } catch {
        Write-Warning "Error verificando permisos de administrador: $_"
        return $false
    }
}

function Assert-AdminPrivileges {
    <#
    .SYNOPSIS
        Lanza una excepción si no tiene permisos de administrador
    .EXAMPLE
        Assert-AdminPrivileges  # Lanza excepción si no es admin
    #>
    if (-not (Test-AdminPrivileges)) {
        throw "Esta operación requiere permisos de administrador. Por favor, ejecuta el dashboard como administrador."
    }
}

function Test-ScriptRequiresAdmin {
    <#
    .SYNOPSIS
        Verifica si un script requiere permisos de administrador según su metadata
    .PARAMETER Metadata
        Hashtable con metadata del script
    .EXAMPLE
        if (Test-ScriptRequiresAdmin -Metadata $metadata) { Assert-AdminPrivileges }
    #>
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Metadata
    )
    
    return $Metadata.RequiresAdmin -eq $true
}

function Get-CurrentUser {
    <#
    .SYNOPSIS
        Obtiene información del usuario actual
    .EXAMPLE
        $user = Get-CurrentUser
        Write-Host "Usuario: $($user.Name)"
    #>
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        
        return @{
            Name = $env:USERNAME
            Domain = $env:USERDOMAIN
            FullName = $identity.Name
            IsAdmin = Test-AdminPrivileges
            AuthenticationType = $identity.AuthenticationType
        }
    } catch {
        Write-Warning "Error obteniendo información del usuario: $_"
        return @{
            Name = $env:USERNAME
            Domain = $env:USERDOMAIN
            FullName = "$env:USERDOMAIN\$env:USERNAME"
            IsAdmin = $false
            AuthenticationType = "Unknown"
        }
    }
}

# Exportar funciones
Export-ModuleMember -Function Test-AdminPrivileges, Assert-AdminPrivileges, Test-ScriptRequiresAdmin, Get-CurrentUser
