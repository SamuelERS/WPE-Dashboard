# 🔧 GUÍA DE INSTALACIÓN - DASHBOARD IT
## Paradise-SystemLabs

**Versión:** 1.0.0  
**Fecha:** 7 de Noviembre, 2025  
**Audiencia:** Administradores de sistemas

---

## 📋 REQUISITOS PREVIOS

### Sistema Operativo

| Componente | Requisito Mínimo | Recomendado |
|------------|------------------|-------------|
| **OS** | Windows 10 (1809+) | Windows 11 |
| **PowerShell** | 5.1 | 5.1+ |
| **RAM** | 2 GB | 4 GB+ |
| **Disco** | 100 MB | 500 MB+ |
| **Procesador** | Dual Core | Quad Core+ |

### Permisos

- ✅ **Administrador local** - Requerido para instalar módulos
- ✅ **Ejecución de scripts** - PowerShell Execution Policy
- ✅ **Puerto 10000** - Debe estar disponible

### Red

- ✅ **Internet** - Para descargar UniversalDashboard (solo primera vez)
- ✅ **Puerto 10000** - Para acceso web local/red

---

## 📦 MÉTODOS DE INSTALACIÓN

### Método 1: Instalación Estándar (Recomendado)

**Ubicación:** `C:\ProgramData\WPE-Dashboard\`

#### Paso 1: Descargar el Dashboard

1. Descarga el paquete `WPE-Dashboard-v1.0.0.zip`
2. Extrae el contenido a `C:\ProgramData\`
3. Verifica que la estructura sea:
   ```
   C:\ProgramData\WPE-Dashboard\
   ├── Dashboard.ps1
   ├── Iniciar-Dashboard.bat
   ├── Scripts/
   ├── Components/
   ├── Utils/
   ├── Config/
   ├── Tools/
   └── Docs/
   ```

#### Paso 2: Verificar Permisos

1. Abre PowerShell como Administrador
2. Navega a la carpeta:
   ```powershell
   cd C:\ProgramData\WPE-Dashboard
   ```
3. Ejecuta el script de verificación:
   ```powershell
   .\Tools\Verificar-Sistema.ps1
   ```

#### Paso 3: Instalar Dependencias

**Opción A: Automática (Recomendada)**
1. Ejecuta `Iniciar-Dashboard.bat` como Administrador
2. El sistema instalará UniversalDashboard automáticamente
3. Espera 2-3 minutos para la instalación

**Opción B: Manual**
```powershell
.\Instalar-Dependencias.ps1
```

#### Paso 4: Primer Arranque

1. Ejecuta `Iniciar-Dashboard.bat`
2. Espera a que se abra el navegador
3. Accede a `http://localhost:10000`
4. Verifica que la interfaz carga correctamente

---

### Método 2: Instalación Portable

**Ubicación:** Cualquier carpeta (USB, carpeta personal, etc.)

#### Ventajas
- ✅ No requiere instalación en ubicación específica
- ✅ Puede ejecutarse desde USB
- ✅ Fácil de mover entre equipos

#### Pasos

1. Extrae el paquete a cualquier ubicación:
   ```
   D:\MisDashboards\WPE-Dashboard\
   ```
2. Navega a la carpeta
3. Ejecuta `Iniciar-Dashboard.bat` como Administrador
4. El sistema detectará automáticamente la ubicación

**Nota:** La primera vez instalará UniversalDashboard en el sistema (no portable)

---

## 🔐 CONFIGURACIÓN DE EXECUTION POLICY

### Verificar Policy Actual

```powershell
Get-ExecutionPolicy
```

### Configurar Policy (si es necesario)

**Opción 1: Solo para el proceso actual (Temporal)**
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

**Opción 2: Para el usuario actual (Recomendado)**
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

**Opción 3: Para todo el sistema (Requiere admin)**
```powershell
Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned
```

---

## 📁 ESTRUCTURA DE CARPETAS

### Estructura Completa

```
WPE-Dashboard/
├── Dashboard.ps1                    # Archivo principal
├── Iniciar-Dashboard.bat            # Launcher
├── Instalar-Dependencias.ps1        # Instalador de módulos
│
├── Scripts/                         # Scripts modulares
│   ├── ScriptLoader.ps1            # Cargador dinámico
│   ├── PLANTILLA-Script.ps1        # Plantilla para nuevos scripts
│   ├── Configuracion/              # Scripts de configuración
│   │   ├── Cambiar-Nombre-PC.ps1
│   │   └── Crear-Usuario-Sistema.ps1
│   ├── Mantenimiento/              # Scripts de mantenimiento
│   │   ├── Limpiar-Archivos-Temporales.ps1
│   │   └── Eliminar-Usuario.ps1
│   └── POS/                        # Scripts de punto de venta
│       └── Crear-Usuario-POS.ps1
│
├── Components/                      # Componentes de UI
│   ├── UI-Components.ps1           # Componentes de interfaz
│   └── Form-Components.ps1         # Componentes de formularios
│
├── Utils/                          # Utilidades reutilizables
│   ├── Validation-Utils.ps1        # Validaciones
│   ├── Logging-Utils.ps1           # Logging
│   ├── System-Utils.ps1            # Utilidades de sistema
│   └── Security-Utils.ps1          # Utilidades de seguridad
│
├── Config/                         # Configuración
│   ├── dashboard-config.json       # Configuración del dashboard
│   └── categories-config.json      # Configuración de categorías
│
├── Tools/                          # Herramientas auxiliares
│   ├── Abrir-Navegador.ps1        # Abrir navegador
│   ├── Detener-Dashboard.ps1      # Detener dashboard
│   ├── Limpiar-Puerto-10000.ps1   # Liberar puerto
│   └── Verificar-Sistema.ps1      # Verificación del sistema
│
├── Logs/                           # Logs del sistema
│   └── dashboard-YYYY-MM.log      # Logs mensuales
│
├── Backup/                         # Backups automáticos
│
└── Docs/                           # Documentación
    ├── CHANGELOG.md
    ├── 11-GUIA-USUARIO-FINAL.md
    └── 12-GUIA-INSTALACION.md
```

### Carpetas Creadas Automáticamente

El dashboard crea automáticamente:
- `Logs/` - Si no existe
- `Backup/` - Si no existe
- `Temp/` - Si no existe

---

## ⚙️ CONFIGURACIÓN INICIAL

### dashboard-config.json

Ubicación: `Config/dashboard-config.json`

```json
{
  "server": {
    "port": 10000,
    "autoReload": true,
    "title": "Paradise-SystemLabs - Dashboard IT"
  },
  "ui": {
    "colors": {
      "primary": "#2196F3",
      "success": "#4caf50",
      "warning": "#ff9800",
      "danger": "#dc3545"
    }
  }
}
```

**Personalización:**
- Cambia `port` para usar otro puerto
- Cambia `title` para personalizar el título
- Cambia `colors` para personalizar la paleta de colores

### categories-config.json

Ubicación: `Config/categories-config.json`

```json
{
  "categories": [
    {
      "id": "configuracion",
      "title": "CONFIGURACIÓN INICIAL",
      "icon": "⚙️",
      "path": "Configuracion",
      "order": 1,
      "visible": true
    }
  ]
}
```

**Personalización:**
- Agrega nuevas categorías
- Cambia el orden con `order`
- Oculta categorías con `visible: false`

---

## 🚀 PRIMER ARRANQUE

### Checklist de Primer Arranque

- [ ] 1. Carpetas extraídas correctamente
- [ ] 2. PowerShell como Administrador
- [ ] 3. Execution Policy configurada
- [ ] 4. Puerto 10000 disponible
- [ ] 5. `Verificar-Sistema.ps1` ejecutado sin errores
- [ ] 6. `Iniciar-Dashboard.bat` ejecutado
- [ ] 7. UniversalDashboard instalado (automático)
- [ ] 8. Navegador abierto en `http://localhost:10000`
- [ ] 9. Interfaz carga correctamente
- [ ] 10. Logs generándose en `Logs/`

### Validación de Instalación

Ejecuta el script de verificación:

```powershell
cd C:\ProgramData\WPE-Dashboard
.\Tools\Verificar-Sistema.ps1
```

**Resultado esperado:**
```
============================================
  VERIFICACION DEL SISTEMA - DASHBOARD IT
============================================

1. VERIFICANDO PERMISOS
─────────────────────────────────────────
[OK] Permisos de Administrador

2. VERIFICANDO MÓDULOS
─────────────────────────────────────────
[OK] Universal Dashboard Community instalado
[OK] PowerShell 5.1 o superior

3. VERIFICANDO ESTRUCTURA DE CARPETAS
─────────────────────────────────────────
[OK] Scripts
[OK] Components
[OK] Utils
[OK] Config
[OK] Logs
[OK] Backup

4. VERIFICANDO ARCHIVOS PRINCIPALES
─────────────────────────────────────────
[OK] Dashboard.ps1
[OK] ScriptLoader.ps1
...

5. VERIFICANDO RED
─────────────────────────────────────────
[OK] Puerto 10000 disponible
[OK] IP: 192.168.1.100

============================================
RESUMEN: 0 errores, 0 advertencias
Sistema listo para usar
============================================
```

---

## 🌐 ACCESO DESDE LA RED

### Configurar Acceso Remoto

#### Paso 1: Obtener IP del Servidor

```powershell
ipconfig
```

Busca la IP en la sección "Adaptador de Ethernet" o "Adaptador de Wi-Fi"

Ejemplo: `192.168.1.100`

#### Paso 2: Configurar Firewall

**Opción A: Automática**
```powershell
New-NetFirewallRule -DisplayName "Dashboard IT" -Direction Inbound -LocalPort 10000 -Protocol TCP -Action Allow
```

**Opción B: Manual**
1. Abre "Firewall de Windows Defender"
2. Clic en "Configuración avanzada"
3. Clic en "Reglas de entrada"
4. Clic en "Nueva regla..."
5. Tipo: Puerto
6. Puerto: 10000
7. Acción: Permitir la conexión
8. Nombre: "Dashboard IT"

#### Paso 3: Acceder desde Otro Equipo

Desde cualquier equipo en la misma red:

```
http://192.168.1.100:10000
```

---

## 🔧 SOLUCIÓN DE PROBLEMAS

### Problema: UniversalDashboard no se instala

**Síntomas:**
- Error al instalar módulo
- "No se puede descargar"

**Soluciones:**
1. Verifica conexión a Internet
2. Configura PSGallery como confiable:
   ```powershell
   Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
   ```
3. Instala manualmente:
   ```powershell
   Install-Module UniversalDashboard.Community -RequiredVersion 2.9.0 -Force
   ```

---

### Problema: Puerto 10000 en uso

**Síntomas:**
- "Puerto 10000 ya está en uso"
- Dashboard no inicia

**Soluciones:**
1. Ejecuta el limpiador de puerto:
   ```powershell
   .\Tools\Limpiar-Puerto-10000.ps1
   ```
2. O cambia el puerto en `Config/dashboard-config.json`

---

### Problema: "Execution of scripts is disabled"

**Síntomas:**
- Scripts no se ejecutan
- Error de Execution Policy

**Solución:**
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

---

### Problema: Dashboard no abre navegador

**Síntomas:**
- Dashboard inicia pero navegador no abre
- Consola muestra URL pero no abre

**Solución:**
1. Abre manualmente el navegador
2. Navega a `http://localhost:10000`
3. O ejecuta:
   ```powershell
   .\Tools\Abrir-Navegador.ps1
   ```

---

## 📊 VERIFICACIÓN POST-INSTALACIÓN

### Tests de Funcionalidad

#### Test 1: Interfaz Web
- [ ] Dashboard accesible en `http://localhost:10000`
- [ ] Tarjetas de categorías visibles
- [ ] Botones responden al clic

#### Test 2: Scripts Modulares
- [ ] Abrir formulario "Cambiar Nombre PC"
- [ ] Campos de formulario visibles
- [ ] Validaciones funcionan

#### Test 3: Logging
- [ ] Archivo de log creado en `Logs/`
- [ ] Entradas de log generándose
- [ ] Formato correcto

#### Test 4: Portabilidad
- [ ] Copiar dashboard a otra ubicación
- [ ] Ejecutar desde nueva ubicación
- [ ] Funciona correctamente

---

## 🔄 ACTUALIZACIÓN

### Actualizar a Nueva Versión

1. **Backup de configuración:**
   ```powershell
   Copy-Item Config\*.json Backup\Config-Backup\
   ```

2. **Backup de scripts personalizados:**
   ```powershell
   Copy-Item Scripts\Custom\* Backup\Scripts-Custom\
   ```

3. **Descargar nueva versión**

4. **Extraer sobre instalación existente**

5. **Restaurar configuración personalizada**

6. **Verificar funcionamiento:**
   ```powershell
   .\Tools\Verificar-Sistema.ps1
   ```

---

## 🗑️ DESINSTALACIÓN

### Desinstalación Completa

1. **Detener dashboard:**
   ```powershell
   .\Tools\Detener-Dashboard.ps1
   ```

2. **Backup de datos (opcional):**
   ```powershell
   Copy-Item Logs\ C:\Backup\Dashboard-Logs\
   Copy-Item Config\ C:\Backup\Dashboard-Config\
   ```

3. **Eliminar carpeta:**
   ```powershell
   Remove-Item C:\ProgramData\WPE-Dashboard -Recurse -Force
   ```

4. **Desinstalar UniversalDashboard (opcional):**
   ```powershell
   Uninstall-Module UniversalDashboard.Community
   ```

---

## 📞 SOPORTE

### Recursos

- **Guía de Usuario:** `Docs/11-GUIA-USUARIO-FINAL.md`
- **Changelog:** `Docs/CHANGELOG.md`
- **Documentación Técnica:** `Docs/07-Arquitectura-y-Estado-Actual/`

### Logs de Diagnóstico

Para reportar problemas, incluye:
1. Contenido de `Logs/dashboard-YYYY-MM.log`
2. Resultado de `.\Tools\Verificar-Sistema.ps1`
3. Versión de PowerShell: `$PSVersionTable`
4. Versión de Windows: `winver`

---

**Versión:** 1.0.0  
**Última Actualización:** 7 de Noviembre, 2025  
**Paradise-SystemLabs** - Dashboard IT
