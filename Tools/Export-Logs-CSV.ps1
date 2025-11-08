# ============================================
# EXPORTAR LOGS A CSV
# ============================================
# Herramienta para exportar logs del dashboard a formato CSV

<#
.SYNOPSIS
    Exporta logs del dashboard a formato CSV

.DESCRIPTION
    Lee los archivos de log del dashboard y los exporta a formato CSV
    para análisis en Excel u otras herramientas

.PARAMETER Month
    Mes a exportar (formato yyyy-MM). Por defecto: mes actual

.PARAMETER OutputPath
    Ruta donde guardar el CSV. Por defecto: Logs\export-{fecha}.csv

.EXAMPLE
    .\Export-Logs-CSV.ps1
    .\Export-Logs-CSV.ps1 -Month "2025-11"
    .\Export-Logs-CSV.ps1 -OutputPath "C:\Exports\logs.csv"
#>

param(
    [string]$Month = (Get-Date -Format 'yyyy-MM'),
    [string]$OutputPath = ""
)

# Detectar ubicación del dashboard
if (-not $Global:DashboardRoot) {
    $Global:DashboardRoot = Split-Path -Parent $PSScriptRoot
}

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  EXPORTAR LOGS A CSV" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Dashboard Root: $Global:DashboardRoot" -ForegroundColor Gray
Write-Host "Mes a exportar: $Month" -ForegroundColor Gray

# Determinar ruta de salida
if (-not $OutputPath) {
    $OutputPath = Join-Path $Global:DashboardRoot "Logs\export-$Month-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
}

Write-Host "Archivo de salida: $OutputPath" -ForegroundColor Gray
Write-Host ""

# Buscar archivo de log
$logFile = Join-Path $Global:DashboardRoot "Logs\dashboard-$Month.log"

if (-not (Test-Path $logFile)) {
    Write-Host "[ERROR] No se encontró el archivo de log: $logFile" -ForegroundColor Red
    Write-Host "`nArchivos de log disponibles:" -ForegroundColor Yellow
    Get-ChildItem (Join-Path $Global:DashboardRoot "Logs") -Filter "dashboard-*.log" | 
        ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Gray }
    pause
    exit 1
}

Write-Host "[INFO] Leyendo log: $logFile" -ForegroundColor Cyan

# Leer y parsear log
$logEntries = @()
$lineNumber = 0

Get-Content $logFile | ForEach-Object {
    $lineNumber++
    $line = $_
    
    # Formato esperado: [2025-11-07 20:00:00] [INFO] [Component] Message
    if ($line -match '^\[(.+?)\]\s+\[(.+?)\]\s+\[(.+?)\]\s+(.+)$') {
        $logEntries += [PSCustomObject]@{
            LineNumber = $lineNumber
            Timestamp = $Matches[1]
            Level = $Matches[2]
            Component = $Matches[3]
            Message = $Matches[4]
        }
    }
    # Formato alternativo: [2025-11-07 20:00:00] Message
    elseif ($line -match '^\[(.+?)\]\s+(.+)$') {
        $logEntries += [PSCustomObject]@{
            LineNumber = $lineNumber
            Timestamp = $Matches[1]
            Level = "Info"
            Component = "Dashboard"
            Message = $Matches[2]
        }
    }
    # Línea sin formato estándar
    elseif ($line.Trim() -ne "") {
        $logEntries += [PSCustomObject]@{
            LineNumber = $lineNumber
            Timestamp = ""
            Level = "Unknown"
            Component = "Unknown"
            Message = $line
        }
    }
}

Write-Host "[OK] Entradas parseadas: $($logEntries.Count)" -ForegroundColor Green

# Exportar a CSV
try {
    $logEntries | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
    Write-Host "[OK] Log exportado exitosamente" -ForegroundColor Green
    Write-Host "`nArchivo creado: $OutputPath" -ForegroundColor White
    
    # Mostrar estadísticas
    Write-Host "`n============================================" -ForegroundColor Cyan
    Write-Host "  ESTADÍSTICAS" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Cyan
    
    $stats = $logEntries | Group-Object -Property Level | 
             Select-Object @{N="Nivel";E={$_.Name}}, @{N="Cantidad";E={$_.Count}} |
             Sort-Object -Property Cantidad -Descending
    
    $stats | Format-Table -AutoSize
    
    Write-Host "Total de entradas: $($logEntries.Count)" -ForegroundColor White
    Write-Host "Tamaño del archivo: $([math]::Round((Get-Item $OutputPath).Length / 1KB, 2)) KB" -ForegroundColor White
    
    # Preguntar si abrir el archivo
    Write-Host "`n¿Deseas abrir el archivo CSV? (S/N): " -ForegroundColor Yellow -NoNewline
    $response = Read-Host
    
    if ($response -eq "S" -or $response -eq "s") {
        Start-Process $OutputPath
    }
    
} catch {
    Write-Host "[ERROR] Error al exportar CSV: $_" -ForegroundColor Red
    pause
    exit 1
}

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host ""
pause
