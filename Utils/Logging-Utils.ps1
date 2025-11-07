# ============================================
# LOGGING UTILITIES
# ============================================
# Sistema de logging centralizado
# Parte de la arquitectura modular WPE-Dashboard

<#
.SYNOPSIS
    Utilidades de logging para el Dashboard IT
.DESCRIPTION
    Sistema centralizado de logging con niveles, rotación
    y formato consistente
#>

function Write-DashboardLog {
    <#
    .SYNOPSIS
        Escribe un mensaje en el log del dashboard
    .PARAMETER Message
        Mensaje a registrar
    .PARAMETER Level
        Nivel del log: Info, Warning, Error, Critical
    .PARAMETER Component
        Componente que genera el log
    .EXAMPLE
        Write-DashboardLog -Message "Usuario creado exitosamente" -Level "Info" -Component "Crear-Usuario"
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("Info", "Warning", "Error", "Critical", "Debug")]
        [string]$Level = "Info",
        
        [Parameter(Mandatory=$false)]
        [string]$Component = "Dashboard"
    )
    
    try {
        # Usar DashboardRoot si está definido, sino usar ruta relativa
        if ($Global:DashboardRoot) {
            $logFile = Join-Path $Global:DashboardRoot "Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
        } else {
            $logFile = "C:\ProgramData\WPE-Dashboard\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
        }
        
        # Crear carpeta Logs si no existe
        $logsDir = Split-Path $logFile
        if (-not (Test-Path $logsDir)) {
            New-Item -Path $logsDir -ItemType Directory -Force | Out-Null
        }
        
        # Formatear mensaje
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logMessage = "[$timestamp] [$Level] [$Component] $Message"
        
        # Escribir en archivo
        Add-Content -Path $logFile -Value $logMessage -ErrorAction SilentlyContinue
        
        # También mostrar en consola según nivel
        switch ($Level) {
            "Info"     { Write-Host $logMessage -ForegroundColor Cyan }
            "Warning"  { Write-Host $logMessage -ForegroundColor Yellow }
            "Error"    { Write-Host $logMessage -ForegroundColor Red }
            "Critical" { Write-Host $logMessage -ForegroundColor Magenta }
            "Debug"    { Write-Host $logMessage -ForegroundColor Gray }
        }
        
    } catch {
        Write-Warning "No se pudo escribir en el log: $_"
    }
}

function Get-RecentLogs {
    <#
    .SYNOPSIS
        Obtiene las últimas líneas del log
    .PARAMETER Lines
        Número de líneas a obtener (default: 50)
    .PARAMETER Level
        Filtrar por nivel específico (opcional)
    .EXAMPLE
        Get-RecentLogs -Lines 100
        Get-RecentLogs -Lines 50 -Level "Error"
    #>
    param(
        [Parameter(Mandatory=$false)]
        [int]$Lines = 50,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("Info", "Warning", "Error", "Critical", "Debug")]
        [string]$Level
    )
    
    try {
        # Usar DashboardRoot si está definido
        if ($Global:DashboardRoot) {
            $logFile = Join-Path $Global:DashboardRoot "Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
        } else {
            $logFile = "C:\ProgramData\WPE-Dashboard\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
        }
        
        if (-not (Test-Path $logFile)) {
            Write-Warning "Archivo de log no encontrado: $logFile"
            return @()
        }
        
        $logs = Get-Content $logFile -Tail $Lines -ErrorAction Stop
        
        # Filtrar por nivel si se especifica
        if ($Level) {
            $logs = $logs | Where-Object { $_ -match "\[$Level\]" }
        }
        
        return $logs
        
    } catch {
        Write-Warning "Error leyendo logs: $_"
        return @()
    }
}

function Clear-OldLogs {
    <#
    .SYNOPSIS
        Limpia logs antiguos según política de retención
    .PARAMETER RetentionDays
        Días de retención (default: 180)
    .EXAMPLE
        Clear-OldLogs -RetentionDays 90
    #>
    param(
        [Parameter(Mandatory=$false)]
        [int]$RetentionDays = 180
    )
    
    try {
        # Usar DashboardRoot si está definido
        if ($Global:DashboardRoot) {
            $logsPath = Join-Path $Global:DashboardRoot "Logs"
        } else {
            $logsPath = "C:\ProgramData\WPE-Dashboard\Logs"
        }
        
        if (-not (Test-Path $logsPath)) {
            Write-Warning "Carpeta de logs no encontrada: $logsPath"
            return
        }
        
        $cutoffDate = (Get-Date).AddDays(-$RetentionDays)
        $oldLogs = Get-ChildItem -Path $logsPath -Filter "dashboard-*.log" -File | 
                   Where-Object { $_.LastWriteTime -lt $cutoffDate }
        
        $deletedCount = 0
        $deletedSize = 0
        
        foreach ($log in $oldLogs) {
            $deletedSize += $log.Length
            Remove-Item $log.FullName -Force -ErrorAction Stop
            $deletedCount++
        }
        
        $sizeMB = [math]::Round($deletedSize / 1MB, 2)
        
        Write-DashboardLog -Message "Limpieza de logs completada: $deletedCount archivos eliminados ($sizeMB MB)" -Level "Info" -Component "Logging-Utils"
        
        return @{
            FilesDeleted = $deletedCount
            SizeMB = $sizeMB
        }
        
    } catch {
        Write-Warning "Error limpiando logs antiguos: $_"
        return @{
            FilesDeleted = 0
            SizeMB = 0
        }
    }
}

function Get-LogStatistics {
    <#
    .SYNOPSIS
        Obtiene estadísticas de los logs
    .EXAMPLE
        $stats = Get-LogStatistics
        Write-Host "Total de logs: $($stats.TotalLogs)"
    #>
    try {
        # Usar DashboardRoot si está definido
        if ($Global:DashboardRoot) {
            $logsPath = Join-Path $Global:DashboardRoot "Logs"
        } else {
            $logsPath = "C:\ProgramData\WPE-Dashboard\Logs"
        }
        
        if (-not (Test-Path $logsPath)) {
            return @{
                TotalLogs = 0
                TotalSizeMB = 0
                OldestLog = $null
                NewestLog = $null
            }
        }
        
        $logs = Get-ChildItem -Path $logsPath -Filter "dashboard-*.log" -File
        
        if ($logs.Count -eq 0) {
            return @{
                TotalLogs = 0
                TotalSizeMB = 0
                OldestLog = $null
                NewestLog = $null
            }
        }
        
        $totalSize = ($logs | Measure-Object -Property Length -Sum).Sum
        $oldest = ($logs | Sort-Object LastWriteTime | Select-Object -First 1).LastWriteTime
        $newest = ($logs | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime
        
        return @{
            TotalLogs = $logs.Count
            TotalSizeMB = [math]::Round($totalSize / 1MB, 2)
            OldestLog = $oldest
            NewestLog = $newest
        }
        
    } catch {
        Write-Warning "Error obteniendo estadísticas de logs: $_"
        return @{
            TotalLogs = 0
            TotalSizeMB = 0
            OldestLog = $null
            NewestLog = $null
        }
    }
}

# Exportar funciones
Export-ModuleMember -Function Write-DashboardLog, Get-RecentLogs, Clear-OldLogs, Get-LogStatistics
