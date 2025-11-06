# 📋 REGLAS DE LA CASA - Dashboard IT

**Versión:** 1.1  
**Última actualización:** Noviembre 2025

---

## 🎯 PROPÓSITO

Este documento establece las reglas obligatorias para mantener el orden y la organización del proyecto Dashboard IT. **TODOS los desarrolladores y usuarios deben seguir estas reglas.**

---

## 📁 ESTRUCTURA DE CARPETAS

### 🔴 RAÍZ DEL PROYECTO (`C:\WPE-Dashboard\`)

**SOLO archivos esenciales para ejecutar el dashboard:**

#### ✅ PERMITIDO:
- `Dashboard.ps1` - Core del dashboard
- `Iniciar-Dashboard.bat` - Lanzador principal
- `README.md` - Documentación principal
- `.gitignore` - Control de versiones
- Archivos de configuración del sistema (si son necesarios)

#### ❌ PROHIBIDO:
- Documentación adicional → Va en `Docs/`
- Scripts de utilidad → Va en `Tools/`
- Scripts de automatización → Va en `Scripts/`
- Archivos temporales → Va en `Temp/`
- Backups → Va en `Backup/`

**Regla de oro:** Si no es esencial para iniciar el dashboard, NO va en la raíz.

---

### 📚 CARPETA `Docs/`

**TODA la documentación del proyecto:**

#### ✅ PERMITIDO:
- Guías de usuario (`.txt`, `.md`)
- Documentación técnica (`.md`)
- Manuales de procedimientos
- Reportes de progreso
- Changelogs
- Índices y referencias
- Diagramas y esquemas

#### ❌ PROHIBIDO:
- Scripts ejecutables (`.ps1`, `.bat`)
- Archivos de configuración
- Logs
- Backups

**Convención de nombres:**
- Documentos principales: `MAYUSCULAS-CON-GUIONES.md`
- Guías rápidas: `MAYUSCULAS-CON-GUIONES.txt`
- Documentos técnicos: `PascalCase-Con-Guiones.md`

---

### 🔧 CARPETA `Scripts/`

**SOLO scripts de automatización organizados por categoría:**

#### ✅ PERMITIDO:
- Scripts de producción
- Plantillas de scripts
- Scripts organizados en subcarpetas por categoría

#### ❌ PROHIBIDO:
- Scripts de prueba → Va en `Temp/`
- Scripts de utilidad del dashboard → Va en `Tools/`
- Scripts sin categoría → Crear categoría o usar `Temp/`
- Documentación → Va en `Docs/`

**Subcarpetas obligatorias:**
```
Scripts/
├── ScriptLoader.ps1           # Sistema de carga
├── PLANTILLA-Script.ps1       # Template
├── Configuracion/             # Setup inicial
├── Mantenimiento/             # Mantenimiento
├── POS/                       # Punto de venta
├── Diseno/                    # Diseño gráfico
├── Atencion-Al-Cliente/       # Atención al cliente
└── Auditoria/                 # Auditoría
```

**Reglas de scripts:**
1. Usar `PLANTILLA-Script.ps1` como base
2. Incluir metadata en comentarios
3. Nombres en PascalCase: `Crear-Usuario-Sistema.ps1`
4. Auto-detección de PC: `$env:COMPUTERNAME`
5. Logging obligatorio: `Write-ScriptLog`
6. Manejo de errores con try/catch

---

### 🛠️ CARPETA `Tools/`

**Herramientas de mantenimiento del dashboard:**

#### ✅ PERMITIDO:
- Scripts de diagnóstico
- Utilidades de desarrollo
- Scripts de backup/restore
- Herramientas de testing
- Scripts de limpieza

#### ❌ PROHIBIDO:
- Scripts de producción → Va en `Scripts/`
- Documentación → Va en `Docs/`
- Scripts temporales → Va en `Temp/`

**Ejemplos:**
- `Verificar-Sistema.ps1` - Diagnóstico
- `Detener-Dashboard.ps1` - Gestión del dashboard
- `Backup-Dashboard.ps1` - Backup automático
- `Test-Scripts.ps1` - Testing

---

### 📊 CARPETA `Logs/`

**Auto-generada por el sistema:**

#### ✅ PERMITIDO:
- Logs automáticos del dashboard
- Formato: `dashboard-YYYY-MM.log`
- Archivo `.gitkeep` para mantener carpeta

#### ❌ PROHIBIDO:
- Editar logs manualmente
- Agregar archivos que no sean logs
- Commitear logs en git (están ignorados)

**Gestión:**
- Logs se crean automáticamente
- Formato mensual: `dashboard-2025-11.log`
- Limpiar logs antiguos (>6 meses) manualmente

---

### 📦 CARPETA `Backup/`

**Backups automáticos y manuales:**

#### ✅ PERMITIDO:
- Backups del dashboard completo
- Backups de scripts
- Backups de configuración
- Archivo `.gitkeep`

#### ❌ PROHIBIDO:
- Archivos que no sean backups
- Commitear en git (carpeta ignorada)

**Convención de nombres:**
- `Dashboard-YYYY-MM-DD.zip`
- `Scripts-YYYY-MM-DD.zip`
- `Config-YYYY-MM-DD.zip`

---

### 🗂️ CARPETA `Temp/`

**Archivos temporales de desarrollo:**

#### ✅ PERMITIDO:
- Scripts en prueba
- Borradores
- Archivos temporales
- Experimentos
- Archivo `.gitkeep`

#### ❌ PROHIBIDO:
- Scripts de producción → Va en `Scripts/`
- Documentación final → Va en `Docs/`
- Commitear en git (carpeta ignorada)

**Regla importante:**
- Limpiar regularmente (cada semana)
- No dejar archivos importantes aquí
- Mover a carpeta correcta cuando esté listo

---

## 🎯 CONVENCIONES DE NOMBRES

### Archivos PowerShell (`.ps1`)
```
PascalCase-Con-Guiones.ps1

Ejemplos:
✅ Crear-Usuario-Sistema.ps1
✅ Limpiar-Archivos-Temporales.ps1
✅ Verificar-Sistema.ps1
❌ crear_usuario.ps1
❌ CrearUsuario.ps1
❌ crear-usuario.ps1
```

### Documentación Markdown (`.md`)
```
MAYUSCULAS-CON-GUIONES.md (documentos principales)
PascalCase-Con-Guiones.md (documentos técnicos)

Ejemplos:
✅ README.md
✅ CHANGELOG.md
✅ GUIA-AGREGAR-SCRIPTS.md
✅ Diagrama-Arquitectura.md
❌ readme.md
❌ guia_scripts.md
```

### Documentación Texto (`.txt`)
```
MAYUSCULAS-CON-GUIONES.txt

Ejemplos:
✅ LEEME-PRIMERO.txt
✅ INICIO-RAPIDO.txt
❌ leeme.txt
❌ inicio_rapido.txt
```

### Carpetas
```
PascalCase (sin guiones)

Ejemplos:
✅ Docs
✅ Scripts
✅ Tools
✅ Configuracion
✅ AtencionAlCliente
❌ docs
❌ atencion-al-cliente
❌ atencion_cliente
```

---

## 📝 REGLAS DE CÓDIGO

### Scripts de Automatización

#### 1. Metadata Obligatoria
```powershell
# @Name: Nombre Descriptivo
# @Description: Qué hace el script
# @RequiresAdmin: true/false
# @HasForm: true/false
# @FormField: campo|placeholder|tipo
```

#### 2. Auto-detección de PC
```powershell
$nombrePC = $env:COMPUTERNAME
```

#### 3. Logging Obligatorio
```powershell
function Write-ScriptLog {
    param([string]$Mensaje)
    $LogFile = "C:\WPE-Dashboard\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$Timestamp] $Mensaje"
}
```

#### 4. Manejo de Errores
```powershell
try {
    # Código aquí
    Write-ScriptLog "Operación exitosa"
} catch {
    Write-ScriptLog "Error: $_"
    throw
}
```

#### 5. Validación de Permisos
```powershell
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    throw "Requiere permisos de administrador"
}
```

---

## 🚫 PROHIBICIONES ABSOLUTAS

### ❌ NUNCA hacer esto:

1. **Hardcodear nombres de PC**
   ```powershell
   ❌ $pc = "WPE-MERLIOT"
   ✅ $pc = $env:COMPUTERNAME
   ```

2. **Scripts sin categoría en raíz**
   ```
   ❌ C:\WPE-Dashboard\MiScript.ps1
   ✅ C:\WPE-Dashboard\Scripts\Categoria\MiScript.ps1
   ```

3. **Documentación en raíz**
   ```
   ❌ C:\WPE-Dashboard\GUIA.md
   ✅ C:\WPE-Dashboard\Docs\GUIA.md
   ```

4. **Commitear archivos temporales**
   ```
   ❌ git add Temp/
   ❌ git add Logs/
   ❌ git add Backup/
   ```

5. **Scripts sin metadata**
   ```powershell
   ❌ # Script sin comentarios
   ✅ # @Name: Mi Script
       # @Description: Hace algo
   ```

6. **Mezclar categorías**
   ```
   ❌ Scripts/POS/Crear-Usuario.ps1
   ✅ Scripts/Configuracion/Crear-Usuario.ps1
   ```

---

## ✅ CHECKLIST ANTES DE COMMIT

Antes de hacer commit en git, verificar:

- [ ] Archivos en carpetas correctas
- [ ] No hay archivos en raíz que no deban estar
- [ ] No se commitean carpetas Temp/, Logs/, Backup/
- [ ] Scripts tienen metadata completa
- [ ] Nombres de archivos siguen convenciones
- [ ] Documentación está en Docs/
- [ ] Scripts están categorizados correctamente
- [ ] No hay código hardcodeado
- [ ] Hay logging en scripts críticos
- [ ] Hay manejo de errores

---

## 🔍 VERIFICACIÓN

Ejecutar regularmente:
```powershell
.\Tools\Verificar-Sistema.ps1
```

Este script verifica:
- Estructura de carpetas correcta
- Archivos en ubicaciones correctas
- Sintaxis de scripts
- Metadata presente

---

## 📞 SOPORTE

Si tienes dudas sobre dónde colocar un archivo:

1. Consulta este documento
2. Revisa la estructura en `README.md`
3. Pregunta antes de colocar en lugar incorrecto

---

## 🎯 RESUMEN RÁPIDO

| Tipo de Archivo | Carpeta | Ejemplo |
|-----------------|---------|---------|
| Dashboard core | Raíz | `Dashboard.ps1` |
| Lanzador | Raíz | `Iniciar-Dashboard.bat` |
| Documentación | `Docs/` | `GUIA-AGREGAR-SCRIPTS.md` |
| Script de producción | `Scripts/Categoria/` | `Crear-Usuario-Sistema.ps1` |
| Herramienta | `Tools/` | `Verificar-Sistema.ps1` |
| Log | `Logs/` | `dashboard-2025-11.log` |
| Backup | `Backup/` | `Dashboard-2025-11-04.zip` |
| Temporal | `Temp/` | `test-script.ps1` |

---

**Estas reglas son OBLIGATORIAS para mantener el proyecto organizado y profesional.**

**Versión:** 1.1  
**Dashboard IT - Paradise-SystemLabs** 🐠
