# ============================================
# LIMPIAR ARCHIVOS TEMPORALES
# ============================================
# @Name: Limpieza de Archivos Temporales
# @Description: Elimina archivos temporales de Windows y usuario para liberar espacio
# @Category: Mantenimiento
# @RequiresAdmin: false
# @HasForm: false

<#
.SYNOPSIS
    Limpia archivos temporales del sistema
.DESCRIPTION
    Script modular para limpiar archivos temporales del sistema y del usuario actual.
    No requiere permisos de administrador.
.NOTES
    Parte de la arquitectura modular WPE-Dashboard
#>

# Detectar ubicación del dashboard para rutas relativas
if (-not $Global:DashboardRoot) {
    $Global:DashboardRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
}

# Importar utilidades
. (Join-Path $Global:DashboardRoot "Utils\Logging-Utils.ps1")

function Get-FolderSize {
    param([string]$Path)
    if (Test-Path $Path) {
        $size = (Get-ChildItem $Path -Recurse -ErrorAction SilentlyContinue | 
                 Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        return [math]::Round($size / 1MB, 2)
    }
    return 0
}

try {
    # Auto-detectar PC
    $nombrePC = $env:COMPUTERNAME
    Write-DashboardLog -Message "Iniciando limpieza de archivos temporales en: $nombrePC" -Level "Info" -Component "Limpiar-Archivos-Temporales"
    
    $totalLiberado = 0
    $carpetasLimpiadas = 0
    
    # Carpetas a limpiar
    $carpetas = @(
        @{Path = "$env:TEMP"; Nombre = "Temp Usuario"},
        @{Path = "C:\Windows\Temp"; Nombre = "Temp Windows"},
        @{Path = "C:\Windows\Prefetch"; Nombre = "Prefetch"},
        @{Path = "$env:LOCALAPPDATA\Microsoft\Windows\INetCache"; Nombre = "Cache IE"}
    )
    
    Write-Host "Analizando carpetas..." -ForegroundColor Cyan
    
    foreach ($carpeta in $carpetas) {
        if (Test-Path $carpeta.Path) {
            $sizeBefore = Get-FolderSize -Path $carpeta.Path
            
            Write-Host "  Limpiando: $($carpeta.Nombre) ($sizeBefore MB)..." -ForegroundColor Gray
            
            # Limpiar archivos
            Get-ChildItem -Path $carpeta.Path -Recurse -Force -ErrorAction SilentlyContinue | 
                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            
            $sizeAfter = Get-FolderSize -Path $carpeta.Path
            $liberado = $sizeBefore - $sizeAfter
            
            if ($liberado -gt 0) {
                $totalLiberado += $liberado
                $carpetasLimpiadas++
                Write-Host "    Liberado: $liberado MB" -ForegroundColor Green
            }
        }
    }
    
    # Vaciar papelera de reciclaje
    Write-Host "  Vaciando papelera de reciclaje..." -ForegroundColor Gray
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    
    $mensaje = "Limpieza completada: $totalLiberado MB liberados en $carpetasLimpiadas carpetas"
    Write-DashboardLog -Message $mensaje -Level "Info" -Component "Limpiar-Archivos-Temporales"
    
    return @{
        Success = $true
        Message = $mensaje
        TotalLiberadoMB = $totalLiberado
        CarpetasLimpiadas = $carpetasLimpiadas
    }
    
} catch {
    $errorMsg = $_.Exception.Message
    Write-DashboardLog -Message "Error durante limpieza: $errorMsg" -Level "Error" -Component "Limpiar-Archivos-Temporales"
    
    return @{
        Success = $false
        Message = "Error: $errorMsg"
    }
}
