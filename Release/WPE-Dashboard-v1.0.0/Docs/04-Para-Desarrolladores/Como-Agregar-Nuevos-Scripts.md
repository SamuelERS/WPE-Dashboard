# 📚 GUÍA: Cómo Agregar Scripts al Dashboard

## 🎯 Objetivo
Esta guía te enseña cómo migrar tus scripts de Notion al Dashboard de forma rápida y organizada.

---

## ⚠️ IMPORTANTE: Ejecución LOCAL de Scripts

**TODOS LOS SCRIPTS SE EJECUTAN EN LA MAQUINA DONDE CORRE EL DASHBOARD**

El dashboard NO es una herramienta de gestión remota. Es una herramienta de automatización LOCAL:

### ✅ Comportamiento Correcto
- Dashboard ejecutándose en PC "OFICINA-01"
- Script "Crear Usuario" se ejecuta
- Usuario se crea en "OFICINA-01" (donde corre el dashboard)

### ❌ Comportamiento Esperado Incorrectamente
- Dashboard ejecutándose en PC "HOST"
- Quieres crear usuario en PC "VM-CLIENTE"
- **ERROR:** Usuario se creará en "HOST", NO en "VM-CLIENTE"
- **SOLUCIÓN:** Ejecutar el dashboard EN "VM-CLIENTE"

### 📌 Reglas al Escribir Scripts
1. Los scripts operan sobre `$env:COMPUTERNAME` (PC local)
2. Comandos como `New-LocalUser`, `Get-LocalUser` operan LOCALMENTE
3. NO uses nombres de PC hardcodeados (ej: "DESKTOP-123")
4. USA auto-detección: `$nombrePC = $env:COMPUTERNAME`
5. Si necesitas operar en múltiples PCs, ejecuta el dashboard en cada uno

### 🔄 Uso Correcto en Múltiples Máquinas
**Opción 1: Carpeta compartida de red**
```powershell
\\servidor\WPE-Dashboard\Iniciar-Dashboard.bat
```
Ejecutar desde cada PC objetivo

**Opción 2: Copia local**
```powershell
C:\WPE-Dashboard\Iniciar-Dashboard.bat
```
Copiar dashboard a cada PC y ejecutar localmente

---

## 📁 Estructura de Carpetas

```
C:\WPE-Dashboard\
├── Scripts\
│   ├── Configuracion\          # Scripts de configuración inicial
│   ├── Mantenimiento\          # Scripts de mantenimiento
│   ├── POS\                    # Scripts de punto de venta
│   ├── Diseno\                 # Scripts de diseño gráfico
│   ├── Atencion-Al-Cliente\    # Scripts de atención al cliente
│   ├── Auditoria\              # Scripts de auditoría
│   ├── ScriptLoader.ps1        # Sistema de carga automática
│   └── PLANTILLA-Script.ps1    # Plantilla para nuevos scripts
├── Dashboard.ps1               # Dashboard principal
└── Logs\                       # Logs automáticos
```

---

## 🚀 Pasos para Agregar un Script

### 1️⃣ Copia la Plantilla
```powershell
Copy-Item "C:\WPE-Dashboard\Scripts\PLANTILLA-Script.ps1" `
          "C:\WPE-Dashboard\Scripts\[CATEGORIA]\[NombreScript].ps1"
```

**Categorías disponibles:**
- `Configuracion` - Setup inicial de equipos
- `Mantenimiento` - Limpieza, updates, optimización
- `POS` - Todo relacionado con puntos de venta
- `Diseno` - Adobe, calibración, impresoras
- `Atencion-Al-Cliente` - CRM, softphones, estaciones
- `Auditoria` - Logs, reportes, historial

---

### 2️⃣ Configura la Metadata

Edita las primeras líneas del script:

```powershell
# @Name: Nombre Descriptivo del Script
# @Description: Qué hace este script
# @RequiresAdmin: true/false
# @HasForm: true/false
# @FormField: campo1|Placeholder del campo|textbox
# @FormField: campo2|Otro campo|select:Opcion1,Opcion2,Opcion3
```

**Tipos de campos disponibles:**
- `textbox` - Texto libre
- `password` - Contraseña (oculta)
- `select:Op1,Op2,Op3` - Lista desplegable

---

### 3️⃣ Escribe tu Código

Reemplaza la sección "TU CÓDIGO AQUÍ" con tu lógica:

```powershell
try {
    # Validaciones
    if ([string]::IsNullOrWhiteSpace($parametro)) {
        throw "Error: parámetro requerido"
    }
    
    # Tu lógica aquí
    Write-Host "Ejecutando..." -ForegroundColor Cyan
    
    # Auto-detectar PC (ya incluido)
    $nombrePC = $env:COMPUTERNAME
    
    # Hacer algo...
    
    Write-ScriptLog "Operación exitosa"
    
    return @{
        Success = $true
        Message = "Todo OK"
    }
    
} catch {
    Write-ScriptLog "Error: $_"
    return @{
        Success = $false
        Message = "Error: $_"
    }
}
```

---

## 📝 Ejemplo Completo

**Archivo:** `C:\WPE-Dashboard\Scripts\Mantenimiento\Limpiar-Disco.ps1`

```powershell
# @Name: Limpieza de Disco
# @Description: Ejecuta limpieza automática de archivos temporales
# @RequiresAdmin: true
# @HasForm: false

function Write-ScriptLog {
    param([string]$Mensaje)
    $LogFile = "C:\WPE-Dashboard\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$Timestamp] $Mensaje"
}

try {
    $nombrePC = $env:COMPUTERNAME
    Write-ScriptLog "Iniciando limpieza en: $nombrePC"
    
    # Limpiar temp
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    
    # Limpiar Windows temp
    Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    
    Write-ScriptLog "Limpieza completada"
    
    return @{
        Success = $true
        Message = "Disco limpiado exitosamente"
    }
    
} catch {
    Write-ScriptLog "Error: $_"
    return @{
        Success = $false
        Message = "Error: $_"
    }
}
```

---

## 🔄 Integración Automática (Próximamente)

En la siguiente versión del dashboard, los scripts se cargarán automáticamente usando `ScriptLoader.ps1`.

**Por ahora:** Debes agregar manualmente el botón al `Dashboard.ps1`

---

## ✅ Checklist para Migrar un Script

- [ ] Copiar plantilla a la carpeta correcta
- [ ] Configurar metadata (@Name, @Description, etc.)
- [ ] Agregar parámetros si usa formulario
- [ ] Implementar lógica del script
- [ ] Usar `Write-ScriptLog` para logging
- [ ] Retornar Success/Message
- [ ] Probar desde el dashboard
- [ ] Verificar logs en `C:\WPE-Dashboard\Logs\`

---

## 🎨 Tips y Mejores Prácticas

### ✅ Hacer:
- Usar `$env:COMPUTERNAME` para auto-detectar PC
- Validar todos los parámetros antes de ejecutar
- Usar `Write-ScriptLog` para auditoría
- Retornar siempre Success/Message
- Manejar errores con try/catch

### ❌ Evitar:
- Hardcodear nombres de PC
- Ejecutar sin validaciones
- Ignorar errores
- No hacer logging
- Usar rutas absolutas innecesarias

---

## 🆘 Solución de Problemas

### El script no aparece en el dashboard
→ Por ahora es normal, debes agregarlo manualmente a `Dashboard.ps1`

### Error "Acceso denegado"
→ Asegúrate que `@RequiresAdmin: true` y ejecuta el dashboard como admin

### El formulario no muestra los campos
→ Verifica la sintaxis de `@FormField` (campo|placeholder|tipo)

### Los logs no se guardan
→ Verifica que la carpeta `C:\WPE-Dashboard\Logs\` existe

---

## 📞 Soporte

Para dudas o problemas, revisa:
1. Esta guía
2. `PLANTILLA-Script.ps1`
3. Ejemplo: `Scripts\Configuracion\Crear-Usuario-Sistema.ps1`

---

**Última actualización:** Noviembre 2025
**Versión del Dashboard:** 1.1
