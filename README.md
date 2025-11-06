# WPE-Dashboard - Paradise-SystemLabs

Dashboard web de automatizacion IT para gestion centralizada de equipos Windows.

## Requisitos del Sistema

- Windows 10/11 o Windows Server 2016+
- PowerShell 5.1 o superior
- Permisos de administrador
- Modulo UniversalDashboard.Community v2.9.0

## Instalacion en PC Nueva

### Opcion 1: Instalacion Automatica (Recomendado)

1. Copia la carpeta `WPE-Dashboard` completa a la PC nueva
2. Haz doble clic en: `Instalar-Dependencias.bat`
3. Espera a que termine la instalacion (varios minutos)
4. Una vez completado, inicia el dashboard con: `Iniciar-Dashboard.bat`

### Opcion 2: Instalacion Manual

Si prefieres instalar manualmente:

```powershell
# 1. Abrir PowerShell como Administrador
# 2. Instalar el modulo
Install-Module -Name UniversalDashboard.Community -RequiredVersion 2.9.0 -Force

# 3. Verificar instalacion
Import-Module UniversalDashboard.Community
Get-Module UniversalDashboard.Community

# 4. Iniciar dashboard
cd C:\WPE-Dashboard
.\Iniciar-Dashboard.bat
```

## Uso Diario

### Iniciar Dashboard

```batch
.\Iniciar-Dashboard.bat
```

Luego abre en tu navegador: `http://localhost:10000`

### Detener Dashboard

```powershell
.\Tools\Detener-Dashboard.ps1
```

### Ver Logs

Desde el dashboard web: Boton "Ver Logs" en seccion "Historial y Auditoria"

O manualmente:
```powershell
Get-Content "C:\WPE-Dashboard\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log" -Tail 30
```

## Concepto Importante: Ejecucion LOCAL

**IMPORTANTE:** El dashboard ejecuta todos los scripts en la PC donde esta corriendo.

- Si quieres crear un usuario en PC "DESKTOP-A", debes ejecutar el dashboard EN "DESKTOP-A"
- NO es una herramienta de gestion remota
- Para configurar multiples PCs: ejecuta el dashboard en cada PC

### Deployment Recomendado

**Opcion A: Carpeta de red compartida** (Recomendado)
```
\\servidor\WPE-Dashboard\Iniciar-Dashboard.bat
```
Ventaja: Una sola copia del codigo, se ejecuta localmente en cada PC

**Opcion B: Copia local en cada PC**
```
C:\WPE-Dashboard\Iniciar-Dashboard.bat
```
Ventaja: Funciona sin conexion a red

## Estructura del Proyecto

```
C:\WPE-Dashboard\
├── Dashboard.ps1                    # Core del dashboard
├── Iniciar-Dashboard.bat            # Lanzador con permisos admin
├── Instalar-Dependencias.bat        # Instalador automatico (PCs nuevas)
├── Instalar-Dependencias.ps1        # Script de instalacion
├── README.md                        # Este archivo
│
├── Docs/                            # Documentacion completa
│   ├── LEEME-PRIMERO.txt
│   ├── INICIO-RAPIDO.txt
│   ├── GUIA-AGREGAR-SCRIPTS.md
│   ├── COMANDOS-UTILES.md
│   └── CLAUDE.md                    # Guia para Claude Code
│
├── Scripts/                         # Scripts organizados por categoria
│   ├── PLANTILLA-Script.ps1
│   ├── Configuracion/
│   │   └── Crear-Usuario-Sistema.ps1
│   ├── Mantenimiento/
│   ├── POS/
│   ├── Diseno/
│   ├── Atencion-Al-Cliente/
│   └── Auditoria/
│
├── Tools/                           # Utilidades del dashboard
│   ├── Verificar-Sistema.ps1
│   └── Detener-Dashboard.ps1
│
├── Logs/                            # Logs auto-generados (ignorado en git)
├── Backup/                          # Backups (ignorado en git)
└── Temp/                            # Temporales (ignorado en git)
```

## Funcionalidades Disponibles

### Configuracion Inicial
- ✅ Crear usuarios del sistema (con validacion y auto-deteccion de PC)
- ✅ Cambiar nombre del PC (con validacion de formato Windows)
- 🔜 Configurar biometria
- 🔜 Instalar software base
- 🔜 Configurar email corporativo

### Mantenimiento General
- 🔜 Windows Update
- 🔜 Limpieza de disco
- 🔜 Verificar sistema
- 🔜 Optimizar rendimiento

### Punto de Venta (POS)
- 🔜 Reset terminal
- 🔜 Sincronizar inventario
- 🔜 Configurar impresora fiscal

### Diseno Grafico
- 🔜 Setup Adobe Suite
- 🔜 Calibrar monitor
- 🔜 Drivers de impresora

### Atencion al Cliente
- 🔜 Setup CRM
- 🔜 Configurar estacion
- 🔜 Configurar softphone

### Historial y Auditoria
- ✅ Ver logs del sistema
- ✅ Reiniciar dashboard
- 🔜 Exportar reportes

## Solucion de Problemas

### Error: "Modulo no encontrado"

```
Import-Module : The specified module 'UniversalDashboard.Community' was not loaded
```

**Solucion:**
1. Ejecuta `Instalar-Dependencias.bat` en esa PC
2. Espera a que termine la instalacion
3. Vuelve a intentar iniciar el dashboard

### Error: "Puerto 10000 ocupado"

El dashboard ya incluye logica automatica para liberar el puerto. Si persiste:

```powershell
.\Tools\Detener-Dashboard.ps1
```

O manualmente:
```powershell
Get-UDDashboard | Stop-UDDashboard
```

### Error: "Requiere permisos de administrador"

Asegurate de ejecutar `Iniciar-Dashboard.bat` (no `Dashboard.ps1` directamente)

## Documentacion Adicional

- **Inicio rapido:** [Docs/INICIO-RAPIDO.txt](Docs/INICIO-RAPIDO.txt)
- **Agregar scripts:** [Docs/GUIA-AGREGAR-SCRIPTS.md](Docs/GUIA-AGREGAR-SCRIPTS.md)
- **Comandos utiles:** [Docs/COMANDOS-UTILES.md](Docs/COMANDOS-UTILES.md)
- **Guia completa:** [Docs/CLAUDE.md](Docs/CLAUDE.md)

## Soporte

Para problemas o dudas:
1. Revisa la carpeta `Docs/`
2. Ejecuta `.\Tools\Verificar-Sistema.ps1`
3. Revisa los logs: Boton "Ver Logs" en el dashboard

---

**Version:** 1.1
**Plataforma:** Windows 10/11, PowerShell 5.1+
**Desarrollado para:** Paradise-SystemLabs
