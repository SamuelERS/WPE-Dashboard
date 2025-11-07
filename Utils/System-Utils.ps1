# ============================================
# SYSTEM UTILITIES
# ============================================
# Funciones de sistema reutilizables
# Parte de la arquitectura modular WPE-Dashboard

<#
.SYNOPSIS
    Utilidades de sistema para el Dashboard IT
.DESCRIPTION
    Contiene funciones para obtener información del sistema,
    gestionar usuarios locales y verificar puertos
#>

function Get-CurrentPCInfo {
    <#
    .SYNOPSIS
        Obtiene información completa del PC actual
    .EXAMPLE
        $pcInfo = Get-CurrentPCInfo
        Write-Host "PC: $($pcInfo.Name)"
    #>
    try {
        $computerSystem = Get-CimInstance Win32_ComputerSystem -ErrorAction Stop
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        
        return @{
            Name = $env:COMPUTERNAME
            OS = $os.Caption
            Version = $os.Version
            Architecture = $os.OSArchitecture
            Manufacturer = $computerSystem.Manufacturer
            Model = $computerSystem.Model
            TotalMemoryGB = [math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)
            Domain = $computerSystem.Domain
            Username = $env:USERNAME
        }
    } catch {
        Write-Warning "Error obteniendo información del PC: $_"
        return @{
            Name = $env:COMPUTERNAME
            OS = "Desconocido"
            Version = "Desconocido"
            Architecture = "Desconocido"
            Manufacturer = "Desconocido"
            Model = "Desconocido"
            TotalMemoryGB = 0
            Domain = "Desconocido"
            Username = $env:USERNAME
        }
    }
}

function Get-FilteredLocalUsers {
    <#
    .SYNOPSIS
        Obtiene lista de usuarios locales excluyendo usuarios del sistema
    .EXAMPLE
        $users = Get-FilteredLocalUsers
        foreach ($user in $users) { Write-Host $user.Name }
    #>
    try {
        $users = Get-LocalUser -ErrorAction Stop | Where-Object {
            $_.Name -notmatch '^(Administrador|DefaultAccount|Guest|WDAGUtilityAccount)$'
        }
        
        return $users
    } catch {
        Write-Warning "Error obteniendo usuarios locales: $_"
        return @()
    }
}

function Test-PortAvailable {
    <#
    .SYNOPSIS
        Verifica si un puerto está disponible
    .PARAMETER Port
        Número de puerto a verificar
    .EXAMPLE
        if (Test-PortAvailable -Port 10000) { Write-Host "Puerto disponible" }
    #>
    param(
        [Parameter(Mandatory=$true)]
        [int]$Port
    )
    
    try {
        $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
        return ($null -eq $connection)
    } catch {
        # Si hay error, asumimos que el puerto está disponible
        return $true
    }
}

function Get-DiskSpaceInfo {
    <#
    .SYNOPSIS
        Obtiene información de espacio en disco
    .EXAMPLE
        $diskInfo = Get-DiskSpaceInfo
        Write-Host "Espacio libre: $($diskInfo.FreeSpaceGB) GB"
    #>
    try {
        $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction Stop
        
        return @{
            Drive = $disk.DeviceID
            TotalSizeGB = [math]::Round($disk.Size / 1GB, 2)
            FreeSpaceGB = [math]::Round($disk.FreeSpace / 1GB, 2)
            UsedSpaceGB = [math]::Round(($disk.Size - $disk.FreeSpace) / 1GB, 2)
            PercentFree = [math]::Round(($disk.FreeSpace / $disk.Size) * 100, 2)
        }
    } catch {
        Write-Warning "Error obteniendo información de disco: $_"
        return @{
            Drive = "C:"
            TotalSizeGB = 0
            FreeSpaceGB = 0
            UsedSpaceGB = 0
            PercentFree = 0
        }
    }
}

function Test-InternetConnection {
    <#
    .SYNOPSIS
        Verifica si hay conexión a Internet
    .EXAMPLE
        if (Test-InternetConnection) { Write-Host "Conectado a Internet" }
    #>
    try {
        $result = Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet -ErrorAction SilentlyContinue
        return $result
    } catch {
        return $false
    }
}

function Get-SystemUptime {
    <#
    .SYNOPSIS
        Obtiene el tiempo de actividad del sistema
    .EXAMPLE
        $uptime = Get-SystemUptime
        Write-Host "Sistema activo por: $($uptime.Days) días"
    #>
    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $lastBoot = $os.LastBootUpTime
        $uptime = (Get-Date) - $lastBoot
        
        return @{
            LastBootTime = $lastBoot
            Days = $uptime.Days
            Hours = $uptime.Hours
            Minutes = $uptime.Minutes
            TotalHours = [math]::Round($uptime.TotalHours, 2)
            FormattedUptime = "$($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m"
        }
    } catch {
        Write-Warning "Error obteniendo uptime del sistema: $_"
        return @{
            LastBootTime = Get-Date
            Days = 0
            Hours = 0
            Minutes = 0
            TotalHours = 0
            FormattedUptime = "Desconocido"
        }
    }
}

# Exportar funciones
Export-ModuleMember -Function Get-CurrentPCInfo, Get-FilteredLocalUsers, Test-PortAvailable, Get-DiskSpaceInfo, Test-InternetConnection, Get-SystemUptime
