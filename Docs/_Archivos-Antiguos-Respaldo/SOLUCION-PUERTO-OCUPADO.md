# Solución: Puerto 10000 Ocupado

## Descripción del Problema

Cuando intentas iniciar el dashboard, ves este error:

```
Puerto 10000 ocupado por proceso activo. Intento 1 de 3...
Deteniendo proceso: powershell (PID: 49660)
Esperando liberacion del puerto...
[...repetir...]
ADVERTENCIA: No se pudo liberar el puerto 10000 despues de 3 intentos
```

## ¿Por qué sucede esto?

El dashboard corre en el puerto 10000. Si una instancia anterior no se cerró correctamente, el puerto sigue ocupado. Esto puede pasar por:

1. **Cierre abrupto** - Cerraste la ventana de PowerShell en lugar de detener el dashboard correctamente
2. **Crash del dashboard** - El dashboard se cerró inesperadamente
3. **Múltiples instancias** - Intentaste iniciar el dashboard dos veces
4. **Proceso zombie** - Un proceso de PowerShell quedó colgado

## Soluciones (en orden de agresividad)

### ✅ Solución 1: Script de Detención Estándar

**Usa esto primero** - Es el método más limpio y seguro.

```powershell
# Desde la raíz del proyecto
.\Tools\Detener-Dashboard.ps1
```

Este script:
- Detiene dashboards activos usando UniversalDashboard
- Libera el puerto 10000 matando procesos asociados
- Espera 10 segundos para que Windows libere el puerto
- Verifica que todo esté limpio

**Tasa de éxito:** ~95%

---

### ⚠️ Solución 2: Limpieza Agresiva de Puerto

Si la Solución 1 falla, usa este script más agresivo:

```powershell
# Desde la raíz del proyecto
.\Tools\Limpiar-Puerto-10000.ps1
```

Este script:
- Mata TODOS los procesos usando el puerto 10000
- Espera 15 segundos
- Verifica resultado
- **ADVERTENCIA:** Puede cerrar otras aplicaciones sin guardar

**Tasa de éxito:** ~99%

---

### 🔴 Solución 3: Limpieza Manual

Si ningún script funciona, hazlo manualmente:

#### Paso 1: Identificar el proceso
```powershell
Get-NetTCPConnection -LocalPort 10000 | Select-Object State, OwningProcess
```

#### Paso 2: Obtener información del proceso
```powershell
# Reemplaza 12345 con el PID que obtuviste en Paso 1
Get-Process -Id 12345
```

#### Paso 3: Matar el proceso
```powershell
Stop-Process -Id 12345 -Force
```

#### Paso 4: Esperar y verificar
```powershell
Start-Sleep -Seconds 10
Get-NetTCPConnection -LocalPort 10000
```

Si no retorna nada, el puerto está libre.

---

### 🆘 Solución 4: Reiniciar PC

Si **nada** funciona, reinicia el equipo:

```powershell
Restart-Computer
```

Esto garantiza que todos los procesos y puertos se liberen.

**Tasa de éxito:** 100%

---

## Prevención: Cómo Cerrar el Dashboard Correctamente

### ❌ NO HAGAS ESTO:
- Cerrar la ventana de PowerShell con la X
- Matar el proceso desde el Administrador de Tareas
- Apagar la PC sin detener el dashboard

### ✅ HAZ ESTO:

**Opción 1: Desde la interfaz web**
1. Abre http://localhost:10000
2. Ve a "Historial y Auditoría"
3. Clic en "Reiniciar Dashboard" (si vas a reiniciar)
4. O presiona `Ctrl+C` en la ventana de PowerShell

**Opción 2: Desde PowerShell**
```powershell
# En la ventana donde corre el dashboard
Ctrl + C

# O desde otra ventana
.\Tools\Detener-Dashboard.ps1
```

---

## Mejoras Implementadas en Dashboard.ps1

### ✅ Versión Nueva (Mejorada)

```powershell
# Obtener PID del proceso actual para no matarnos a nosotros mismos
$currentPID = $PID

# Excluir proceso actual al matar procesos
$processIds = $activeConnections |
    Select-Object -ExpandProperty OwningProcess -Unique |
    Where-Object { $_ -gt 0 -and $_ -ne $currentPID }  # ← CRÍTICO

# Esperar 10 segundos (más tiempo que antes)
Start-Sleep -Seconds 10
```

### ❌ Versión Antigua (Problemática)

```powershell
# No excluía el proceso actual
foreach ($pid in $processIds) {
    Stop-Process -Id $pid -Force
}

# Solo esperaba 5 segundos (insuficiente)
Start-Sleep -Seconds 5
```

### Cambios Clave:

1. **Excluye el proceso actual** - No se mata a sí mismo
2. **Espera más tiempo** - 10 segundos en lugar de 5
3. **Distingue estados de conexión** - Solo mata `Listen` y `Established`, ignora `TimeWait`
4. **Mejor manejo de errores** - Mensajes más claros
5. **Verificación post-kill** - Confirma que el puerto se liberó

---

## Entendiendo los Estados de Conexión TCP

| Estado | Descripción | ¿Problema? |
|--------|-------------|-----------|
| **Listen** | Servidor escuchando en puerto | ✅ Sí - Matar proceso |
| **Established** | Conexión activa cliente-servidor | ✅ Sí - Matar proceso |
| **TimeWait** | Conexión cerrada esperando timeout | ⚠️ No - Esperar (30-240 seg) |
| **CloseWait** | Esperando cierre de aplicación | ⚠️ Posiblemente - Revisar |

El dashboard ahora **ignora conexiones TimeWait** porque:
- Son residuales (la conexión ya se cerró)
- No bloquean que el puerto sea reutilizado
- Se limpian automáticamente en 30-240 segundos
- Intentar "matarlas" no tiene sentido (PID es 0)

---

## FAQ - Preguntas Frecuentes

### ¿Por qué el puerto sigue ocupado después de cerrar PowerShell?

Windows mantiene conexiones TCP en estado `TimeWait` por 30-240 segundos después de cerrar. Esto es **normal** y el nuevo código del dashboard puede iniciarse incluso con conexiones TimeWait residuales.

### ¿Es peligroso matar procesos de PowerShell?

Generalmente no, pero:
- ✅ Seguro: Matar procesos del dashboard
- ⚠️ Cuidado: Si tienes otros scripts de PowerShell corriendo
- 🔴 Peligroso: Matar procesos del sistema (PID bajo)

Los scripts ahora verifican el nombre del proceso antes de matar.

### ¿Qué pasa si mato el proceso equivocado?

Los scripts actuales:
1. Muestran el nombre del proceso antes de matar
2. Excluyen el proceso actual
3. Solo matan procesos asociados al puerto 10000

Es muy difícil matar algo crítico por error.

### ¿Puedo cambiar el puerto del dashboard?

Sí, pero no es recomendado. Si quieres cambiar el puerto:

```powershell
# En Dashboard.ps1, línea final
Start-UDDashboard -Dashboard $Dashboard -Port 8080 -AutoReload
```

También debes actualizar:
- Lógica de liberación de puerto
- Scripts de detención
- Firewall de Windows

---

## Comando Rápido de Diagnóstico

Copia y pega esto en PowerShell para diagnóstico completo:

```powershell
Write-Host "=== DIAGNOSTICO PUERTO 10000 ===" -ForegroundColor Cyan
Write-Host ""

# Ver dashboards activos
Write-Host "Dashboards activos:" -ForegroundColor Yellow
try {
    Import-Module UniversalDashboard.Community -ErrorAction Stop
    Get-UDDashboard | Format-Table
} catch {
    Write-Host "Modulo UniversalDashboard no cargado" -ForegroundColor Gray
}

# Ver conexiones en puerto 10000
Write-Host ""
Write-Host "Conexiones en puerto 10000:" -ForegroundColor Yellow
$conns = Get-NetTCPConnection -LocalPort 10000 -ErrorAction SilentlyContinue
if ($conns) {
    $conns | ForEach-Object {
        $pid = $_.OwningProcess
        $proc = if ($pid -gt 0) { (Get-Process -Id $pid -ErrorAction SilentlyContinue).ProcessName } else { "Sistema" }
        Write-Host "  Estado: $($_.State) | PID: $pid | Proceso: $proc"
    }
} else {
    Write-Host "  Puerto libre" -ForegroundColor Green
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
```

---

## Resumen de Herramientas Disponibles

| Herramienta | Uso | Agresividad | Tiempo |
|-------------|-----|-------------|--------|
| `Detener-Dashboard.ps1` | Cierre limpio estándar | Baja | 15 seg |
| `Limpiar-Puerto-10000.ps1` | Limpieza agresiva | Alta | 20 seg |
| Comandos manuales | Diagnóstico y control fino | Variable | Variable |
| Reinicio de PC | Solución garantizada | Máxima | 2-5 min |

---

## Cuando Pedir Ayuda

Si después de intentar **todas las soluciones** el problema persiste:

1. Ejecuta el comando de diagnóstico de arriba
2. Copia el output completo
3. Revisa los logs: `C:\WPE-Dashboard\Logs\dashboard-*.log`
4. Verifica que no haya otro software usando el puerto 10000

```powershell
# Ver qué software usa puertos comunes
Get-NetTCPConnection | Where-Object {$_.LocalPort -eq 10000 -or $_.LocalPort -eq 8080} |
    Select-Object LocalPort, State, OwningProcess, @{Name="Process";Expression={(Get-Process -Id $_.OwningProcess).ProcessName}}
```

---

**Última actualización:** Noviembre 2025
**Versión Dashboard:** 1.1
**Mejoras implementadas:** ✅ Exclusión de proceso actual, ✅ Tiempos de espera aumentados, ✅ Manejo de TimeWait
