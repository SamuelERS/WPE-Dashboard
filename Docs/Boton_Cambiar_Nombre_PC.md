# 🖥️ CASO: Botón Cambiar Nombre del PC

**Fecha:** 4 de Noviembre, 2025  
**Versión:** 1.4  
**Estado:** ✅ IMPLEMENTADO  
**Prioridad:** Alta

---

## 📋 DESCRIPCIÓN DEL CASO

### Problema Identificado
Los equipos tienen nombres generados automáticamente por Windows que no son amigables para el usuario:
- Ejemplo: `DESKTOP-VHIMQ05`
- Difícil de recordar
- No descriptivo
- No indica la función del equipo

### Objetivo
Crear una funcionalidad en el dashboard que permita cambiar el nombre del PC de forma amigable y controlada.

---

## 🎯 REQUERIMIENTOS

### Funcionales
1. ✅ **Reconocimiento del entorno**
   - Detectar automáticamente el nombre actual del PC
   - Mostrar el nombre actual en el formulario
   - Ejecutar el cambio en el PC donde está corriendo el dashboard

2. ✅ **Ubicación del botón**
   - Colocado en la sección "CONFIGURACIÓN INICIAL"
   - Después del botón "Crear Usuario del Sistema"
   - Visible y accesible desde el inicio

3. ✅ **Formulario interactivo**
   - Campo 1: Nombre actual del PC (solo lectura, deshabilitado)
   - Campo 2: Nuevo nombre del PC (editable)
   - Validaciones en tiempo real
   - Mensajes claros de error/éxito

### No Funcionales
1. ✅ **Seguridad**
   - Requiere permisos de administrador
   - Validación de formato de nombre
   - Logging de todas las operaciones

2. ✅ **Usabilidad**
   - Interfaz intuitiva
   - Mensajes claros
   - Advertencia sobre reinicio requerido

3. ✅ **Mantenibilidad**
   - Código documentado
   - Script separado en carpeta Scripts
   - Logging para auditoría

---

## 🏗️ ARQUITECTURA DE LA SOLUCIÓN

### Componentes Creados

#### 1. Script de Backend
**Archivo:** `Scripts/Configuracion/Cambiar-Nombre-PC.ps1`

**Funcionalidades:**
- Validación de permisos de administrador
- Validación de formato de nombre (1-15 caracteres, alfanuméricos y guiones)
- Verificación de que el nombre es diferente al actual
- Ejecución del comando `Rename-Computer`
- Logging de la operación

**Metadata:**
```powershell
# @Name: Cambiar Nombre del PC
# @Description: Cambia el nombre del equipo de forma amigable
# @Category: Configuracion
# @RequiresAdmin: true
# @HasForm: true
# @FormField: nuevoNombre|Nuevo nombre del PC|textbox
```

#### 2. Botón en Dashboard
**Ubicación:** Sección "CONFIGURACIÓN INICIAL" en `Dashboard.ps1`

**Características:**
- Botón: "Cambiar Nombre del PC"
- Modal con formulario de 2 campos
- Validaciones inline
- Mensajes toast para feedback

---

## 🔄 FLUJO DE OPERACIÓN

### Paso a Paso

```
1. Usuario abre dashboard
   ↓
2. Ve tarjeta "INFORMACIÓN DEL SISTEMA"
   - Muestra: "PC ACTUAL: DESKTOP-VHIMQ05"
   - Identifica que el nombre no es amigable
   ↓
3. Click en "Cambiar Nombre del PC"
   ↓
4. Se abre modal con formulario:
   - Campo 1: "DESKTOP-VHIMQ05" (deshabilitado)
   - Campo 2: [Ingresa nuevo nombre]
   ↓
5. Usuario ingresa: "POS-Merliot"
   ↓
6. Click en "Submit"
   ↓
7. Dashboard valida:
   ✓ Permisos de administrador
   ✓ Formato del nombre
   ✓ Nombre diferente al actual
   ↓
8. Ejecuta: Rename-Computer -NewName "POS-Merliot"
   ↓
9. Muestra mensaje:
   "Nombre del PC cambiado exitosamente a 'POS-Merliot'.
    IMPORTANTE: Debes REINICIAR el equipo para aplicar los cambios."
   ↓
10. Usuario reinicia el equipo
    ↓
11. PC ahora se llama: "POS-Merliot"
```

---

## ✅ VALIDACIONES IMPLEMENTADAS

### 1. Validación de Permisos
```powershell
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if(-not $isAdmin){
    Show-UDToast -Message "Error: El dashboard debe ejecutarse como Administrador"
    return
}
```

### 2. Validación de Formato
```powershell
# Regex: 1-15 caracteres, letras, números y guiones
# No puede empezar o terminar con guión
if($nuevoNombrePC -notmatch '^[a-zA-Z0-9]([a-zA-Z0-9-]{0,13}[a-zA-Z0-9])?$'){
    Show-UDToast -Message "Nombre invalido. Usa solo letras, numeros y guiones (1-15 caracteres)"
    return
}
```

### 3. Validación de Nombre Vacío
```powershell
if([string]::IsNullOrWhiteSpace($nuevoNombrePC)){
    Show-UDToast -Message "Debes ingresar un nuevo nombre para el PC"
    return
}
```

### 4. Validación de Nombre Diferente
```powershell
$nombreActual = $env:COMPUTERNAME
if($nuevoNombrePC -eq $nombreActual){
    Show-UDToast -Message "El nuevo nombre es igual al actual. No hay cambios que realizar."
    return
}
```

---

## 📊 CASOS DE USO

### Caso 1: Cambio Exitoso
**Escenario:** Usuario cambia nombre de PC correctamente

```
Input: 
  - Nombre actual: DESKTOP-VHIMQ05
  - Nuevo nombre: POS-Merliot

Proceso:
  1. Validaciones pasan ✓
  2. Rename-Computer ejecutado ✓
  3. Mensaje de éxito mostrado ✓
  4. Log registrado ✓

Output:
  - PC renombrado a "POS-Merliot"
  - Requiere reinicio
  - Log: "Cambiar Nombre PC - Exitoso: DESKTOP-VHIMQ05 -> POS-Merliot"
```

### Caso 2: Nombre Inválido
**Escenario:** Usuario ingresa nombre con caracteres no permitidos

```
Input:
  - Nuevo nombre: "POS Merliot" (con espacio)

Proceso:
  1. Validación de formato falla ✗
  2. Mensaje de error mostrado

Output:
  - Error: "Nombre invalido. Usa solo letras, numeros y guiones (1-15 caracteres)"
  - No se ejecuta cambio
```

### Caso 3: Sin Permisos Admin
**Escenario:** Dashboard no se ejecutó como administrador

```
Input:
  - Nuevo nombre: POS-Merliot

Proceso:
  1. Validación de permisos falla ✗
  2. Mensaje de error mostrado

Output:
  - Error: "El dashboard debe ejecutarse como Administrador"
  - No se ejecuta cambio
```

### Caso 4: Nombre Igual al Actual
**Escenario:** Usuario ingresa el mismo nombre

```
Input:
  - Nombre actual: POS-Merliot
  - Nuevo nombre: POS-Merliot

Proceso:
  1. Validación de nombre diferente falla ✗
  2. Mensaje de advertencia mostrado

Output:
  - Advertencia: "El nuevo nombre es igual al actual. No hay cambios que realizar."
  - No se ejecuta cambio
```

---

## 🎨 INTERFAZ DE USUARIO

### Tarjeta de Información
```
┌─────────────────────────────────────────────┐
│ INFORMACIÓN DEL SISTEMA                     │
├─────────────────────────────────────────────┤
│ PC ACTUAL: DESKTOP-VHIMQ05                  │
│                                             │
│ IMPORTANTE: Todos los scripts se ejecutan  │
│ en esta máquina                             │
│                                             │
│ Los usuarios se crearán en: DESKTOP-VHIMQ05│
│                                             │
│ Si necesitas configurar otra PC, ejecuta   │
│ el dashboard EN esa máquina                 │
└─────────────────────────────────────────────┘
```

### Botón en Configuración Inicial
```
┌─────────────────────────────────────────────┐
│ CONFIGURACIÓN INICIAL                       │
├─────────────────────────────────────────────┤
│ [Crear Usuario del Sistema]                │
│ [Cambiar Nombre del PC]        ← NUEVO     │
│ [Configurar Biometría]                      │
│ [Instalar Software Base]                    │
│ [Configurar Email Corporativo]              │
└─────────────────────────────────────────────┘
```

### Modal del Formulario
```
┌─────────────────────────────────────────────┐
│ Cambiar Nombre del PC                   [X] │
├─────────────────────────────────────────────┤
│                                             │
│ Nombre Actual del PC:                       │
│ ┌─────────────────────────────────────────┐ │
│ │ DESKTOP-VHIMQ05          [DESHABILITADO]│ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ Nuevo Nombre del PC:                        │
│ ┌─────────────────────────────────────────┐ │
│ │ Ejemplo: POS-Merliot, DISENO-Principal  │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│                    [Cancelar]  [Submit]     │
└─────────────────────────────────────────────┘
```

---

## 📝 LOGGING Y AUDITORÍA

### Formato de Log
```
[2025-11-04 15:47:23] Cambiar Nombre PC - Exitoso: DESKTOP-VHIMQ05 -> POS-Merliot
[2025-11-04 15:48:15] Cambiar Nombre PC - Error: Nombre invalido
[2025-11-04 15:49:02] Cambiar Nombre PC - Error: Se requieren permisos de administrador
```

### Ubicación
- **Archivo:** `C:\WPE-Dashboard\Logs\dashboard-YYYY-MM.log`
- **Formato:** `[Timestamp] Accion - Resultado`
- **Rotación:** Mensual automática

---

## 🔒 SEGURIDAD

### Medidas Implementadas

1. **Validación de Permisos**
   - Solo administradores pueden cambiar el nombre
   - Verificación antes de ejecutar

2. **Validación de Entrada**
   - Regex estricto para formato de nombre
   - Previene inyección de comandos
   - Límite de 15 caracteres (estándar Windows)

3. **Logging Completo**
   - Todas las operaciones se registran
   - Incluye éxitos y errores
   - Auditoría completa

4. **Confirmación Implícita**
   - Usuario debe ingresar nombre manualmente
   - No hay cambios automáticos

---

## 🚀 CONVENCIONES DE NOMBRES SUGERIDAS

### Por Tipo de Equipo

#### Punto de Venta (POS)
```
POS-[Ubicacion]
Ejemplos:
  - POS-Merliot
  - POS-Escalon
  - POS-SantaTecla
```

#### Diseño Gráfico
```
DISENO-[Descripcion]
Ejemplos:
  - DISENO-Principal
  - DISENO-Render
  - DISENO-Edicion
```

#### Atención al Cliente
```
ATENCION-[Ubicacion]
Ejemplos:
  - ATENCION-Recepcion
  - ATENCION-CallCenter
  - ATENCION-Soporte
```

#### Administración
```
ADMIN-[Funcion]
Ejemplos:
  - ADMIN-Gerencia
  - ADMIN-Contabilidad
  - ADMIN-RRHH
```

#### Mantenimiento
```
MANT-[Descripcion]
Ejemplos:
  - MANT-Taller
  - MANT-Bodega
  - MANT-Tecnico
```

---

## 📚 DOCUMENTACIÓN RELACIONADA

### Scripts
- `Scripts/Configuracion/Cambiar-Nombre-PC.ps1` - Script principal
- `Dashboard.ps1` (líneas 172-218) - Implementación en dashboard

### Documentación
- `README.md` - Documentación general
- `Docs/REGLAS-DE-LA-CASA.md` - Convenciones del proyecto
- `Docs/GUIA-AGREGAR-SCRIPTS.md` - Cómo agregar nuevos scripts

---

## 🧪 TESTING

### Casos de Prueba

#### Test 1: Cambio Exitoso
```powershell
# Precondición: Dashboard ejecutado como admin
# Input: Nuevo nombre "POS-Test"
# Esperado: Nombre cambiado exitosamente
# Resultado: ✓ PASS
```

#### Test 2: Nombre Inválido
```powershell
# Input: "POS Test" (con espacio)
# Esperado: Error de validación
# Resultado: ✓ PASS
```

#### Test 3: Sin Permisos
```powershell
# Precondición: Dashboard sin permisos admin
# Input: "POS-Test"
# Esperado: Error de permisos
# Resultado: ✓ PASS
```

#### Test 4: Nombre Muy Largo
```powershell
# Input: "POS-MerliotSucursalPrincipal" (>15 caracteres)
# Esperado: Error de validación
# Resultado: ✓ PASS
```

---

## 🔄 PRÓXIMAS MEJORAS

### Corto Plazo
- [ ] Agregar lista desplegable con nombres sugeridos
- [ ] Mostrar preview del nuevo nombre
- [ ] Agregar botón "Reiniciar Ahora" después del cambio

### Mediano Plazo
- [ ] Historial de cambios de nombre
- [ ] Validación contra nombres duplicados en red
- [ ] Integración con Active Directory (si aplica)

### Largo Plazo
- [ ] Cambio masivo de nombres (múltiples PCs)
- [ ] Plantillas de nombres por sucursal
- [ ] Sincronización con inventario

---

## ⚠️ CONSIDERACIONES IMPORTANTES

### Reinicio Requerido
- El cambio de nombre **REQUIERE REINICIO** del equipo
- Windows no aplica el cambio hasta reiniciar
- El dashboard seguirá mostrando el nombre antiguo hasta reiniciar

### Impacto en Red
- Si el PC está en dominio, puede requerir permisos adicionales
- Puede afectar conexiones de red activas
- Planificar cambio en horario de bajo uso

### Usuarios Activos
- Cerrar todas las sesiones de usuario antes de cambiar
- Guardar trabajo pendiente
- Notificar a usuarios del reinicio

---

## 📊 MÉTRICAS Y KPIs

### Métricas de Uso
- Número de cambios de nombre realizados
- Tasa de éxito vs errores
- Tiempo promedio de operación

### Métricas de Calidad
- Nombres que siguen convenciones: >90%
- Errores de validación: <10%
- Cambios revertidos: <5%

---

## ✅ CONCLUSIÓN

### Estado Actual
- ✅ Funcionalidad implementada completamente
- ✅ Validaciones robustas
- ✅ Interfaz intuitiva
- ✅ Logging completo
- ✅ Documentación completa

### Beneficios
1. **Usabilidad:** Nombres amigables y descriptivos
2. **Organización:** Fácil identificación de equipos
3. **Mantenimiento:** Simplifica soporte técnico
4. **Profesionalismo:** Imagen corporativa mejorada

### Próximos Pasos
1. Probar en diferentes escenarios
2. Capacitar usuarios sobre convenciones de nombres
3. Documentar nombres asignados en inventario
4. Monitorear uso y feedback

---

**Implementado:** 4 de Noviembre, 2025  
**Versión:** 1.4  
**Estado:** ✅ PRODUCCIÓN

---

**Dashboard IT - Paradise-SystemLabs** 🐠  
*Automatización inteligente para equipos eficientes*
