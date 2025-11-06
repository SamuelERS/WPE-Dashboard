# WPE-Dashboard - Guía para Claude Code

## Descripción General

Dashboard web de automatización IT para Paradise-SystemLabs. Permite gestionar usuarios, configuraciones y mantenimiento de equipos Windows de forma centralizada mediante una interfaz web.

**Tecnologías:**
- PowerShell 5.1+
- UniversalDashboard.Community v2.9.0
- Windows 10/11 o Windows Server 2016+

**Puerto:** 10000
**Arquitectura:** Aplicación web local con scripts de automatización

---

## ⚠️ CONCEPTO CRÍTICO: Ejecución LOCAL

**EL DASHBOARD ES UNA HERRAMIENTA DE AUTOMATIZACIÓN LOCAL, NO DE GESTIÓN REMOTA**

### Regla Fundamental
- Todos los scripts se ejecutan en la máquina donde corre el dashboard
- `New-LocalUser` crea usuarios en la PC local donde se ejecuta el dashboard
- NO crea usuarios remotamente en otras máquinas
- Para configurar múltiples PCs, ejecutar el dashboard EN cada PC objetivo

### Ejemplo de Uso Correcto
```
Escenario: Crear usuario en VM "DESKTOP-VHIMC05"

❌ INCORRECTO:
1. Conectado a HOST "DESKTOP-VHIMQ05"
2. Ejecutar dashboard en HOST
3. Crear usuario desde interfaz web
4. RESULTADO: Usuario creado en HOST, NO en la VM

✅ CORRECTO:
1. Conectarse via RDP a VM "DESKTOP-VHIMC05"
2. Ejecutar dashboard EN la VM: \\servidor\WPE-Dashboard\Iniciar-Dashboard.bat
3. Crear usuario desde interfaz web
4. RESULTADO: Usuario creado en VM correctamente
```

### Deployment Recomendado
```powershell
# Opción 1: Carpeta compartida de red (RECOMENDADO)
\\servidor\WPE-Dashboard\Iniciar-Dashboard.bat

# Opción 2: Copia local en cada PC
C:\WPE-Dashboard\Iniciar-Dashboard.bat
```

**Beneficio Opción 1:** Mantener una sola copia del dashboard, ejecutarla desde red en cada PC objetivo

---

## Estructura del Proyecto

```
C:\WPE-Dashboard\
├── Dashboard.ps1                # Core del dashboard (167 líneas)
├── Iniciar-Dashboard.bat        # Lanzador con permisos admin
├── README.md                    # Documentación principal
├── CLAUDE.md                    # Este archivo
│
├── Docs/                        # TODA la documentación
│   ├── LEEME-PRIMERO.txt
│   ├── GUIA-AGREGAR-SCRIPTS.md
│   ├── COMANDOS-UTILES.md
│   └── [otros...]
│
├── Scripts/                     # Scripts organizados por categoría
│   ├── PLANTILLA-Script.ps1
│   ├── Configuracion/
│   │   └── Crear-Usuario-Sistema.ps1
│   ├── Mantenimiento/
│   ├── POS/
│   ├── Diseno/
│   ├── Atencion-Al-Cliente/
│   └── Auditoria/
│
├── Tools/                       # Utilidades del dashboard
│   ├── Verificar-Sistema.ps1
│   └── Detener-Dashboard.ps1
│
├── Logs/                        # Logs auto-generados (ignorados en git)
├── Backup/                      # Backups (ignorados en git)
└── Temp/                        # Temporales (ignorados en git)
```

---

## Comandos Esenciales

### Iniciar Dashboard
```powershell
# Desde directorio raíz
.\Iniciar-Dashboard.bat

# Desde red compartida
\\servidor\WPE-Dashboard\Iniciar-Dashboard.bat

# Manual con PowerShell
cd C:\WPE-Dashboard
Import-Module UniversalDashboard.Community
.\Dashboard.ps1
```

### Detener Dashboard
```powershell
.\Tools\Detener-Dashboard.ps1

# O manualmente
Get-UDDashboard | Stop-UDDashboard
```

### Verificar Sistema
```powershell
.\Tools\Verificar-Sistema.ps1
```

### Ver Logs
```powershell
Get-Content "C:\WPE-Dashboard\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log" -Tail 30
```

---

## Arquitectura del Dashboard

### Dashboard.ps1 - Estructura

1. **Líneas 6-9:** Importación de módulo UniversalDashboard
2. **Líneas 11-16:** Creación de carpeta Logs
3. **Líneas 18-85:** Gestión de procesos y puerto 10000
   - Detiene dashboards existentes
   - Libera puerto con retry logic (3 intentos)
   - Mata procesos conflictivos
4. **Líneas 87-97:** Función `Write-DashboardLog`
5. **Líneas 99-106:** Banner de inicio con info de PC
6. **Líneas 107-175:** Definición del dashboard
   - Línea 112-119: Tarjeta informativa PC actual
   - Línea 122-157: Sección Configuración Inicial
   - Línea 158: Sección Mantenimiento
   - Línea 159: Sección POS
   - Línea 160: Sección Diseño
   - Línea 161: Sección Atención al Cliente
   - Línea 162-171: Sección Historial/Auditoría (incluye botón Reiniciar)
6. **Línea 176:** Start-UDDashboard

### Gestión de Puerto 10000

El dashboard incluye lógica robusta para gestionar conflictos de puerto:

```powershell
# Algoritmo de liberación de puerto
while (-not $portFree -and $retryCount -lt $maxRetries) {
    1. Verificar si puerto 10000 está ocupado
    2. Si está ocupado:
       - Obtener PIDs de procesos usando el puerto
       - Matar cada proceso con Stop-Process -Force
       - Esperar 5 segundos
       - Verificar nuevamente
    3. Si sigue ocupado después de 3 intentos: Error y salir
}
```

---

## Sistema de Scripts

### Metadata de Scripts

Todos los scripts deben incluir metadata en comentarios:

```powershell
# @Name: Nombre Descriptivo
# @Description: Descripción del script
# @RequiresAdmin: true/false
# @HasForm: true/false
# @FormField: nombreCampo|Placeholder|tipo
```

### Tipos de Campos de Formulario
- `textbox` - Texto libre
- `password` - Contraseña oculta
- `select:Op1,Op2,Op3` - Lista desplegable

### Plantilla de Script

Ver: `Scripts/PLANTILLA-Script.ps1`

```powershell
param([string]$parametro1, [string]$parametro2)

function Write-ScriptLog {
    param([string]$Mensaje)
    $LogFile = "C:\WPE-Dashboard\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$Timestamp] $Mensaje"
}

try {
    # Validaciones
    if ([string]::IsNullOrWhiteSpace($parametro1)) {
        throw "Parametro requerido"
    }

    # Auto-detectar PC
    $nombrePC = $env:COMPUTERNAME
    Write-ScriptLog "Ejecutando en PC: $nombrePC"

    # LOGICA DEL SCRIPT AQUI

    Write-ScriptLog "Operación exitosa"
    return @{Success = $true; Message = "OK"}

} catch {
    Write-ScriptLog "Error: $_"
    return @{Success = $false; Message = "Error: $_"}
}
```

### Patrones de Auto-Detección

**NUNCA hardcodear nombres de PC. SIEMPRE auto-detectar:**

```powershell
# ✅ CORRECTO
$nombrePC = $env:COMPUTERNAME
$usuario = $env:USERNAME
$domain = $env:USERDOMAIN

# ❌ INCORRECTO
$nombrePC = "DESKTOP-123"  # NO HACER ESTO
$usuario = "admin"          # NO HACER ESTO
```

### Logging

Todos los scripts deben usar `Write-ScriptLog`:

```powershell
Write-ScriptLog "Crear Usuario ($nombreUsuario) - Exitoso - PC: $env:COMPUTERNAME"
Write-ScriptLog "Error al crear usuario: $_"
```

**Formato de log:**
```
[2025-11-04 15:30:45] Crear Usuario (POS-Merliot) - Exitoso - PC: DESKTOP-VHIMC05
[2025-11-04 15:31:12] Error al crear usuario: Access Denied
```

---

## Integración de Scripts en Dashboard.ps1

### Ejemplo: Script con Formulario

```powershell
New-UDButton -Text "Crear Usuario del Sistema" -OnClick {
    Show-UDModal -Content {
        New-UDInput -Title "Crear Usuario del Sistema" -Content {
            New-UDInputField -Name "nombreUsuario" -Placeholder "Ejemplo: POS-Merliot" -Type textbox
            New-UDInputField -Name "password" -Placeholder "Password (defecto: 841357)" -Type textbox
            New-UDInputField -Name "tipoUsuario" -Placeholder "Selecciona tipo" -Type select -Values @("POS", "Admin", "Diseno")
        } -Endpoint {
            param($nombreUsuario, $password, $tipoUsuario)

            # Validaciones
            if([string]::IsNullOrWhiteSpace($nombreUsuario)){
                Show-UDToast -Message "Error: Campo requerido" -Duration 3000 -BackgroundColor "#f44336"
                return
            }

            # Valores por defecto
            if([string]::IsNullOrWhiteSpace($password)){$password = "841357"}

            try {
                # LOGICA DEL SCRIPT AQUI
                Show-UDToast -Message "Usuario creado exitosamente" -Duration 8000 -BackgroundColor "#4caf50"
                Start-Sleep -Seconds 2  # IMPORTANTE: Permite que el toast se renderice
                Hide-UDModal
            } catch {
                Show-UDToast -Message "Error: $_" -Duration 8000 -BackgroundColor "#f44336"
            }
        }
    }
}
```

### Ejemplo: Script Sin Formulario

```powershell
New-UDButton -Text "Limpiar Disco" -OnClick {
    Show-UDToast -Message "Limpiando disco..." -Duration 2000
    Write-DashboardLog -Accion "Limpieza Disco" -Resultado "Iniciado"
    # Aquí iría la lógica del script
}
```

---

## Problemas Comunes y Soluciones

### 1. Puerto 10000 Bloqueado

**Síntoma:**
```
Failed to bind to address http://0.0.0.0:10000: address already in use
```

**Causa:** Dashboard previo no cerrado correctamente

**Solución Automática:** Dashboard.ps1 ahora incluye retry logic que mata procesos automáticamente

**Solución Manual:**
```powershell
Get-UDDashboard | Stop-UDDashboard
Get-NetTCPConnection -LocalPort 10000 | Select -ExpandProperty OwningProcess | ForEach-Object { Stop-Process -Id $_ -Force }
```

### 2. Usuarios Creados en Máquina Incorrecta

**Síntoma:** Ejecuto dashboard en HOST pero usuarios no aparecen en VM

**Causa:** Dashboard crea usuarios LOCALMENTE donde se ejecuta

**Solución:**
1. Conectarse a la VM objetivo
2. Ejecutar dashboard EN la VM
3. Crear usuario desde interfaz

Ver sección "Concepto Crítico: Ejecución LOCAL" arriba.

### 3. Race Condition en Modales

**Síntoma:** Toast no se muestra antes de que modal se cierre

**Causa:** `Hide-UDModal` ejecuta inmediatamente después de `Show-UDToast`

**Solución:**
```powershell
Show-UDToast -Message "Operación exitosa" -Duration 8000 -BackgroundColor "#4caf50"
Start-Sleep -Seconds 2  # CRÍTICO: Permite que toast se renderice
Hide-UDModal
```

### 4. Caracteres Especiales (UTF-8)

**Síntoma:** Aparece "ContraseÃ±a" en lugar de "Contraseña"

**Causa:** UniversalDashboard no maneja bien UTF-8 en algunos contextos

**Solución:** Evitar caracteres especiales en:
- Placeholders de formularios
- Títulos de botones
- Mensajes de toast

```powershell
# ❌ EVITAR
-Placeholder "Contraseña (defecto: 841357)"

# ✅ USAR
-Placeholder "Password (defecto: 841357)"
```

### 5. Variable Reservada `$pid`

**Síntoma:**
```
The Variable 'pid' cannot be assigned since it is a readonly automatic variable
```

**Causa:** `$pid` es una variable automática de PowerShell

**Solución:** Usar otro nombre como `$processId`

```powershell
# ❌ INCORRECTO
foreach ($pid in $processIds) { }

# ✅ CORRECTO
foreach ($processId in $processIds) { }
```

---

## Colores del Dashboard

```powershell
# Toasts
"#4caf50"  # Verde - Éxito
"#f44336"  # Rojo - Error
"#ff9800"  # Naranja - Advertencia
"#2196f3"  # Azul - Información

# Tarjetas
"#fff3cd"  # Amarillo claro - Fondo de alerta
"#ffc107"  # Amarillo - Borde de alerta
```

---

## Convenciones de Código

### Nombres de Archivos
- Scripts: `PascalCase-Con-Guiones.ps1`
- Documentación: `MAYUSCULAS-CON-GUIONES.md`
- Carpetas de scripts: `PascalCase`

### Nombres de Variables
```powershell
$nombreUsuario    # camelCase para variables locales
$nombrePC         # camelCase
$LogFile          # PascalCase para constantes/configuración
```

### Formato de Logs
```powershell
Write-DashboardLog -Accion "Crear Usuario ($nombreUsuario)" -Resultado "Exitoso - PC: $env:COMPUTERNAME"
```

---

## Testing

### Verificar Dashboard
```powershell
# 1. Verificar módulo cargado
Get-Module UniversalDashboard.Community

# 2. Verificar puerto libre
Get-NetTCPConnection -LocalPort 10000

# 3. Iniciar dashboard
.\Iniciar-Dashboard.bat

# 4. Verificar en navegador
http://localhost:10000

# 5. Ver logs
Get-Content "C:\WPE-Dashboard\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log" -Tail 10
```

### Test de Script Nuevo
1. Copiar `PLANTILLA-Script.ps1`
2. Configurar metadata
3. Implementar lógica
4. Test desde PowerShell:
```powershell
.\Scripts\Categoria\Mi-Script.ps1 -param1 "valor"
```
5. Integrar en Dashboard.ps1
6. Reiniciar dashboard
7. Probar desde interfaz web

---

## Reglas de Desarrollo

### REGLAS DE LA CASA - OBLIGATORIAS

**RAÍZ del proyecto:**
- ✅ Solo archivos esenciales: `Dashboard.ps1`, `Iniciar-Dashboard.bat`, `README.md`
- ❌ NO documentación → Va en `Docs/`
- ❌ NO scripts → Va en `Scripts/`

**Carpeta Scripts:**
- ✅ Usar subcarpetas por categoría
- ✅ Seguir `PLANTILLA-Script.ps1`
- ✅ Incluir metadata completa
- ❌ NO mezclar categorías

**Carpeta Docs:**
- ✅ TODA la documentación
- ❌ NO scripts ejecutables

**Logs, Backup, Temp:**
- ✅ Auto-generadas
- ❌ NO commitear en git (ignoradas)

### Auto-Detección Obligatoria
- SIEMPRE usar `$env:COMPUTERNAME`
- NUNCA hardcodear nombres de PC
- Scripts deben funcionar en cualquier máquina
- NO asumir nombres de usuarios específicos

### Logging Obligatorio
- Todo script debe usar `Write-ScriptLog`
- Registrar inicio, éxito y errores
- Incluir siempre `$env:COMPUTERNAME` en logs

---

## Estado del Proyecto

| Componente | Estado | Notas |
|------------|--------|-------|
| Infraestructura | ✅ Completado | Puerto, permisos, logs |
| Interfaz Web | ✅ Completado | 6 categorías funcionales |
| Gestión de Puerto | ✅ Completado | Retry logic implementado |
| Script: Crear Usuario | ✅ Completado | Con formulario y validación |
| Scripts Migrados | 🟡 En progreso | Solo 1 de ~50 scripts |
| Carga Automática | 🔴 Pendiente | ScriptLoader.ps1 no implementado |

---

## Próximos Pasos

### Prioridad Alta
1. Migrar scripts de Notion a carpetas apropiadas
2. Implementar carga automática de scripts (`ScriptLoader.ps1`)
3. Hacer todos los scripts genéricos (auto-detección)

### Prioridad Media
4. Más formularios interactivos
5. Validaciones robustas
6. Exportar reportes de logs

---

## Referencias Rápidas

### Comandos UniversalDashboard
```powershell
New-UDDashboard      # Crear dashboard
Start-UDDashboard    # Iniciar servidor
Stop-UDDashboard     # Detener servidor
Get-UDDashboard      # Listar dashboards activos
New-UDButton         # Crear botón
Show-UDToast         # Mostrar notificación
Show-UDModal         # Mostrar modal
Hide-UDModal         # Cerrar modal
New-UDInput          # Crear formulario
New-UDInputField     # Campo de formulario
New-UDCard           # Tarjeta
New-UDLayout         # Layout de columnas
New-UDHeading        # Encabezado
New-UDElement        # Elemento HTML genérico
```

### PowerShell Local Admin
```powershell
New-LocalUser              # Crear usuario local
Get-LocalUser              # Listar usuarios
Remove-LocalUser           # Eliminar usuario
Add-LocalGroupMember       # Agregar a grupo
Get-LocalGroupMember       # Ver miembros de grupo
```

### Detección de Sistema
```powershell
$env:COMPUTERNAME          # Nombre del PC
$env:USERNAME              # Usuario actual
$env:USERDOMAIN            # Dominio
[Environment]::OSVersion   # Versión de Windows
```

---

## Contacto y Soporte

**Documentación:**
- `Docs/LEEME-PRIMERO.txt` - Introducción
- `Docs/INICIO-RAPIDO.txt` - Guía de 5 minutos
- `Docs/GUIA-AGREGAR-SCRIPTS.md` - Migración de scripts
- `Docs/COMANDOS-UTILES.md` - Referencia comandos

**Herramientas:**
- `Tools/Verificar-Sistema.ps1` - Diagnóstico completo
- `Tools/Detener-Dashboard.ps1` - Detener dashboard

---

**Versión:** 1.1
**Última actualización:** Noviembre 2025
**Plataforma:** Windows 10/11, PowerShell 5.1+, UniversalDashboard.Community 2.9.0
