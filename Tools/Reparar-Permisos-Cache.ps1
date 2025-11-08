<#
.SYNOPSIS
    Reparar Permisos de Cache - WPE-Dashboard v1.0.0-LTS PATCH-3

.DESCRIPTION
    Corrige permisos NTFS en la carpeta Cache/ para permitir escritura
    del archivo scripts-metadata-cache.json

.NOTES
    Versión: 1.0.0-LTS PATCH-3
    Fecha: 2025-11-07
    Requiere: Privilegios de Administrador
#>

#Requires -RunAsAdministrator

# ============================================
# CONFIGURACIÓN
# ============================================

$ErrorActionPreference = "Stop"
$dashboardRoot = Split-Path -Parent $PSScriptRoot
$cachePath = Join-Path $dashboardRoot "Cache"

# ============================================
# FUNCIONES
# ============================================

function Write-ColorMessage {
    param(
        [string]$Message,
        [string]$Color = "White",
        [string]$Prefix = "[INFO]"
    )
    
    $prefixColor = switch ($Prefix) {
        "[OK]"    { "Green" }
        "[ERROR]" { "Red" }
        "[WARN]"  { "Yellow" }
        default   { "Cyan" }
    }
    
    Write-Host "$Prefix " -ForegroundColor $prefixColor -NoNewline
    Write-Host $Message -ForegroundColor $Color
}

# ============================================
# BANNER
# ============================================

Clear-Host
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  REPARACIÓN DE PERMISOS - CACHE/" -ForegroundColor Green
Write-Host "  WPE-Dashboard v1.0.0-LTS PATCH-3" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# VALIDACIONES
# ============================================

Write-ColorMessage "Validando privilegios de administrador..." "White" "[INFO]"

try {
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-ColorMessage "Este script requiere privilegios de administrador" "Red" "[ERROR]"
        Write-Host ""
        Write-Host "Ejecute PowerShell como Administrador y vuelva a intentar." -ForegroundColor Yellow
        Write-Host ""
        pause
        exit 1
    }
    
    Write-ColorMessage "Privilegios de administrador confirmados" "Green" "[OK]"
} catch {
    Write-ColorMessage "Error al verificar privilegios: $_" "Red" "[ERROR]"
    pause
    exit 1
}

Write-Host ""

# ============================================
# PASO 1: VERIFICAR CARPETA CACHE
# ============================================

Write-ColorMessage "Verificando carpeta Cache/..." "White" "[INFO]"

if (-not (Test-Path $cachePath)) {
    Write-ColorMessage "Carpeta Cache/ no existe, creándola..." "Yellow" "[WARN]"
    try {
        New-Item -Path $cachePath -ItemType Directory -Force | Out-Null
        Write-ColorMessage "Carpeta Cache/ creada exitosamente" "Green" "[OK]"
    } catch {
        Write-ColorMessage "Error al crear carpeta Cache/: $_" "Red" "[ERROR]"
        pause
        exit 1
    }
} else {
    Write-ColorMessage "Carpeta Cache/ existe" "Green" "[OK]"
}

Write-Host ""

# ============================================
# PASO 2: LIMPIAR ARCHIVOS DAÑADOS
# ============================================

Write-ColorMessage "Limpiando archivos de caché dañados..." "White" "[INFO]"

$cacheFile = Join-Path $cachePath "scripts-metadata-cache.json"

if (Test-Path $cacheFile) {
    try {
        $fileInfo = Get-Item $cacheFile
        
        if ($fileInfo.Length -eq 0) {
            Write-ColorMessage "Archivo de caché vacío detectado (0 bytes), eliminando..." "Yellow" "[WARN]"
            Remove-Item $cacheFile -Force
            Write-ColorMessage "Archivo de caché eliminado" "Green" "[OK]"
        } else {
            Write-ColorMessage "Archivo de caché existente: $($fileInfo.Length) bytes" "Cyan" "[INFO]"
            Write-ColorMessage "Eliminando para regeneración..." "Yellow" "[WARN]"
            Remove-Item $cacheFile -Force
            Write-ColorMessage "Archivo de caché eliminado para regeneración" "Green" "[OK]"
        }
    } catch {
        Write-ColorMessage "Error al limpiar caché: $_" "Yellow" "[WARN]"
    }
} else {
    Write-ColorMessage "No hay archivos de caché previos" "Cyan" "[INFO]"
}

Write-Host ""

# ============================================
# PASO 3: REPARAR PERMISOS NTFS
# ============================================

Write-ColorMessage "Reparando permisos NTFS en Cache/..." "White" "[INFO]"

try {
    # Otorgar control total a Usuarios con herencia
    $icaclsCommand = "icacls `"$cachePath`" /grant `"Usuarios:(OI)(CI)F`" /T"
    Write-ColorMessage "Ejecutando: $icaclsCommand" "Gray" "[INFO]"
    
    $result = icacls "$cachePath" /grant "Usuarios:(OI)(CI)F" /T 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColorMessage "Permisos NTFS reparados exitosamente" "Green" "[OK]"
        Write-ColorMessage "Usuarios: Control Total (Full) con herencia OI/CI" "Cyan" "[INFO]"
    } else {
        Write-ColorMessage "Advertencia al reparar permisos (código: $LASTEXITCODE)" "Yellow" "[WARN]"
    }
} catch {
    Write-ColorMessage "Error al reparar permisos: $_" "Red" "[ERROR]"
}

Write-Host ""

# ============================================
# PASO 4: VERIFICAR PERMISOS
# ============================================

Write-ColorMessage "Verificando permisos aplicados..." "White" "[INFO]"

try {
    $acl = Get-Acl $cachePath
    $usersAccess = $acl.Access | Where-Object { $_.IdentityReference -like "*Usuarios*" -or $_.IdentityReference -like "*Users*" }
    
    if ($usersAccess) {
        Write-ColorMessage "Permisos para Usuarios:" "Cyan" "[INFO]"
        foreach ($access in $usersAccess) {
            Write-Host "  - $($access.IdentityReference): $($access.FileSystemRights)" -ForegroundColor Gray
        }
        Write-ColorMessage "Permisos verificados correctamente" "Green" "[OK]"
    } else {
        Write-ColorMessage "No se encontraron permisos para Usuarios" "Yellow" "[WARN]"
    }
} catch {
    Write-ColorMessage "Error al verificar permisos: $_" "Yellow" "[WARN]"
}

Write-Host ""

# ============================================
# PASO 5: PROBAR ESCRITURA
# ============================================

Write-ColorMessage "Probando escritura en Cache/..." "White" "[INFO]"

$testFile = Join-Path $cachePath "test-write-permissions.txt"

try {
    "Test de permisos - $(Get-Date)" | Out-File $testFile -Encoding UTF8 -Force
    
    if (Test-Path $testFile) {
        Write-ColorMessage "Prueba de escritura exitosa" "Green" "[OK]"
        Remove-Item $testFile -Force
        Write-ColorMessage "Archivo de prueba eliminado" "Green" "[OK]"
    } else {
        Write-ColorMessage "No se pudo crear archivo de prueba" "Red" "[ERROR]"
    }
} catch {
    Write-ColorMessage "Error en prueba de escritura: $_" "Red" "[ERROR]"
    Write-ColorMessage "Es posible que necesite reiniciar PowerShell" "Yellow" "[WARN]"
}

Write-Host ""

# ============================================
# RESUMEN
# ============================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  REPARACIÓN COMPLETADA" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-ColorMessage "Carpeta Cache/ reparada exitosamente" "Green" "[OK]"
Write-ColorMessage "Permisos NTFS aplicados correctamente" "Green" "[OK]"
Write-ColorMessage "Prueba de escritura exitosa" "Green" "[OK]"
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Cyan
Write-Host "  1. Iniciar el dashboard: .\Iniciar-Dashboard.bat" -ForegroundColor White
Write-Host "  2. Verificar que no aparezca el warning de caché" -ForegroundColor White
Write-Host "  3. Confirmar que el navegador carga la interfaz" -ForegroundColor White
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

pause
