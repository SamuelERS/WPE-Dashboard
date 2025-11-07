# ============================================
# LIMPIADOR DE PUERTO 10000 - MODO ULTRA AGRESIVO
# ============================================
# Usar solo si Detener-Dashboard.ps1 no funciona
# Este script mata TODOS los procesos usando el puerto 10000

param(
    [switch]$Force
)

Write-Host ""
Write-Host "============================================" -ForegroundColor Red
Write-Host "  LIMPIADOR DE PUERTO 10000" -ForegroundColor Red
Write-Host "  MODO ULTRA AGRESIVO" -ForegroundColor Red
Write-Host "============================================" -ForegroundColor Red
Write-Host ""

# Verificar permisos de administrador
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[ERROR] Este script requiere permisos de administrador" -ForegroundColor Red
    Write-Host "Ejecuta PowerShell como administrador y vuelve a intentar`n" -ForegroundColor Yellow
    pause
    exit 1
}

# Advertencia
if (-not $Force) {
    Write-Host "ADVERTENCIA: Este script:" -ForegroundColor Yellow
    Write-Host "  - Matara TODOS los procesos usando el puerto 10000" -ForegroundColor Yellow
    Write-Host "  - Puede cerrar otras aplicaciones sin guardar" -ForegroundColor Yellow
    Write-Host "  - Solo debe usarse si otros metodos fallaron" -ForegroundColor Yellow
    Write-Host ""
    $confirmacion = Read-Host "Estas seguro? (escribe 'SI' para continuar)"

    if ($confirmacion -ne "SI") {
        Write-Host "`n[CANCELADO] Operacion cancelada por el usuario" -ForegroundColor Gray
        pause
        exit 0
    }
}

Write-Host ""
Write-Host "[INFO] Iniciando limpieza agresiva del puerto 10000..." -ForegroundColor Cyan
Write-Host ""

# Paso 1: Obtener todas las conexiones en el puerto 10000
$connections = Get-NetTCPConnection -LocalPort 10000 -ErrorAction SilentlyContinue

if (-not $connections) {
    Write-Host "[OK] Puerto 10000 ya esta libre" -ForegroundColor Green
    Write-Host ""
    pause
    exit 0
}

# Paso 2: Mostrar informacion de las conexiones
Write-Host "Conexiones encontradas en puerto 10000:" -ForegroundColor Yellow
$connections | ForEach-Object {
    $state = $_.State
    $pid = $_.OwningProcess

    if ($pid -gt 0) {
        $process = Get-Process -Id $pid -ErrorAction SilentlyContinue
        if ($process) {
            Write-Host "  - Estado: $state | PID: $pid | Proceso: $($process.ProcessName)" -ForegroundColor Gray
        } else {
            Write-Host "  - Estado: $state | PID: $pid | Proceso: (desconocido)" -ForegroundColor Gray
        }
    } else {
        Write-Host "  - Estado: $state | PID: 0 (sistema)" -ForegroundColor DarkGray
    }
}

Write-Host ""

# Paso 3: Obtener PIDs unicos de procesos activos
$processIds = $connections |
    Where-Object { $_.OwningProcess -gt 0 } |
    Select-Object -ExpandProperty OwningProcess -Unique

if (-not $processIds) {
    Write-Host "[INFO] No hay procesos activos para detener (solo conexiones del sistema)" -ForegroundColor Gray
    Write-Host "[INFO] Las conexiones se liberaran automaticamente en unos minutos" -ForegroundColor Cyan
    Write-Host ""
    pause
    exit 0
}

# Paso 4: Matar procesos
Write-Host "Deteniendo procesos..." -ForegroundColor Cyan

$killed = 0
$failed = 0

foreach ($pid in $processIds) {
    try {
        $process = Get-Process -Id $pid -ErrorAction SilentlyContinue

        if ($process) {
            Write-Host "  Matando: $($process.ProcessName) (PID: $pid)..." -ForegroundColor Yellow -NoNewline

            Stop-Process -Id $pid -Force -ErrorAction Stop

            Write-Host " [OK]" -ForegroundColor Green
            $killed++
        }
    } catch {
        Write-Host " [FALLO]" -ForegroundColor Red
        Write-Host "    Error: $_" -ForegroundColor Red
        $failed++
    }
}

# Paso 5: Esperar liberacion del puerto
Write-Host ""
Write-Host "Esperando a que Windows libere el puerto (15 segundos)..." -ForegroundColor Gray
Start-Sleep -Seconds 15

# Paso 6: Verificar resultado
$finalCheck = Get-NetTCPConnection -LocalPort 10000 -ErrorAction SilentlyContinue
$activeCheck = $finalCheck | Where-Object { $_.State -eq 'Listen' -or $_.State -eq 'Established' }

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  RESUMEN" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Procesos detenidos: $killed" -ForegroundColor $(if ($killed -gt 0) { "Green" } else { "Gray" })
Write-Host "Procesos fallidos:  $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Gray" })
Write-Host ""

if (-not $activeCheck) {
    Write-Host "[OK] Puerto 10000 liberado exitosamente" -ForegroundColor Green
    Write-Host ""
    Write-Host "Puedes iniciar el dashboard con:" -ForegroundColor White
    Write-Host "  .\Iniciar-Dashboard.bat" -ForegroundColor Cyan
} else {
    $remainingCount = ($activeCheck | Measure-Object).Count
    Write-Host "[WARN] Puerto 10000 aun tiene $remainingCount conexiones activas" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Opciones restantes:" -ForegroundColor Yellow
    Write-Host "  1. Espera 5 minutos y vuelve a intentar" -ForegroundColor White
    Write-Host "  2. Reinicia el equipo" -ForegroundColor White
    Write-Host "  3. Ejecuta: netstat -ano | findstr :10000" -ForegroundColor White
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
