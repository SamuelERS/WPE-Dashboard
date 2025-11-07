# 📖 GUÍA DE USUARIO - DASHBOARD IT
## Paradise-SystemLabs

**Versión:** 1.0.0  
**Fecha:** 7 de Noviembre, 2025  
**Audiencia:** Usuarios finales y administradores de sistemas

---

## 🎯 INTRODUCCIÓN

### ¿Qué es el Dashboard IT?

El Dashboard IT de Paradise-SystemLabs es una herramienta web de administración de sistemas Windows que permite:
- Configurar equipos de forma rápida y consistente
- Crear y gestionar usuarios locales
- Realizar tareas de mantenimiento del sistema
- Ejecutar scripts de administración desde una interfaz amigable

### Características Principales

- ✅ **Interfaz Web Moderna** - Acceso desde cualquier navegador
- ✅ **Ejecución Remota** - Administra equipos desde la red
- ✅ **Scripts Modulares** - Funcionalidades organizadas por categoría
- ✅ **Validaciones Integradas** - Previene errores de configuración
- ✅ **Logging Centralizado** - Auditoría de todas las acciones
- ✅ **100% Portable** - Funciona desde cualquier ubicación

---

## 💻 REQUISITOS DEL SISTEMA

### Requisitos Mínimos

| Componente | Requisito |
|------------|-----------|
| **Sistema Operativo** | Windows 10/11 o Windows Server 2016+ |
| **PowerShell** | Versión 5.1 o superior |
| **Permisos** | Administrador (para ejecutar scripts) |
| **Puerto** | 10000 disponible |
| **RAM** | 2 GB mínimo |
| **Disco** | 100 MB libres |

### Software Requerido

1. **PowerShell 5.1+** (incluido en Windows 10/11)
2. **UniversalDashboard.Community v2.9.0** (se instala automáticamente)
3. **Navegador Web Moderno** (Edge, Chrome, Firefox)

---

## 🚀 CÓMO INICIAR EL DASHBOARD

### Método 1: Doble Clic (Recomendado)

1. Navega a la carpeta del dashboard
2. Haz doble clic en `Iniciar-Dashboard.bat`
3. Acepta el UAC (Control de Cuentas de Usuario)
4. Espera a que se abra el navegador automáticamente

### Método 2: PowerShell

1. Abre PowerShell como Administrador
2. Navega a la carpeta del dashboard:
   ```powershell
   cd C:\ProgramData\WPE-Dashboard
   ```
3. Ejecuta el dashboard:
   ```powershell
   .\Dashboard.ps1
   ```

### Primer Inicio

**Al iniciar por primera vez:**

1. El sistema verificará si UniversalDashboard está instalado
2. Si no está instalado, se instalará automáticamente (puede tardar 2-3 minutos)
3. Se abrirá el navegador automáticamente en `http://localhost:10000`
4. Verás la pantalla principal del dashboard

---

## 📱 INTERFAZ DEL DASHBOARD

### Pantalla Principal

La interfaz está organizada en tarjetas por categoría:

```
┌─────────────────────────────────────────┐
│  Paradise-SystemLabs - Dashboard IT    │
├─────────────────────────────────────────┤
│  INFORMACIÓN DEL SISTEMA                │
│  PC ACTUAL: NOMBRE-PC                   │
├─────────────────────────────────────────┤
│  ⚙️ CONFIGURACIÓN INICIAL               │
│  ├─ Cambiar Nombre del PC               │
│  ├─ Crear Usuario del Sistema           │
│  └─ ...                                 │
├─────────────────────────────────────────┤
│  🔧 MANTENIMIENTO                       │
│  ├─ Limpieza de Disco                   │
│  ├─ Eliminar Usuarios                   │
│  └─ ...                                 │
└─────────────────────────────────────────┘
```

---

## 🛠️ FUNCIONALIDADES

### CONFIGURACIÓN INICIAL

#### 1. Cambiar Nombre del PC

**¿Cuándo usar?**
- Al configurar un equipo nuevo
- Para estandarizar nombres de equipos
- Ejemplo: `POS-Merliot`, `DISENO-Principal`

**Pasos:**
1. Haz clic en "Cambiar Nombre del PC"
2. Verás el nombre actual del equipo
3. Ingresa el nuevo nombre (1-15 caracteres)
4. Haz clic en "Submit"
5. **IMPORTANTE:** Debes reiniciar el equipo para aplicar cambios

**Reglas para nombres:**
- 1 a 15 caracteres
- Solo letras, números y guiones
- Debe empezar con letra
- No puede terminar con guión
- Ejemplos válidos: `POS-Merliot`, `Admin-Oficina`, `PC-Sala1`

**Errores comunes:**
- ❌ "Nombre inválido" - Verifica que cumpla las reglas
- ❌ "Requiere permisos de administrador" - Ejecuta como admin
- ❌ "El nombre es igual al actual" - Usa un nombre diferente

---

#### 2. Crear Usuario del Sistema

**¿Cuándo usar?**
- Para crear usuarios con permisos de administrador
- Para configurar cuentas de trabajo
- Para usuarios que necesitan instalar software

**Pasos:**
1. Haz clic en "Crear Usuario del Sistema"
2. Ingresa el nombre de usuario (Ejemplo: `Admin-Oficina`)
3. Ingresa una contraseña (mínimo 6 caracteres)
4. Selecciona el tipo de usuario (POS, Admin, Diseño, etc.)
5. Haz clic en "Submit"
6. El usuario se crea con permisos de administrador

**Reglas:**
- Nombre: 3-20 caracteres alfanuméricos
- Contraseña: Mínimo 6 caracteres
- El usuario se agrega al grupo Administradores

**Errores comunes:**
- ❌ "Usuario ya existe" - Usa otro nombre o elimina el existente
- ❌ "Contraseña muy corta" - Usa al menos 6 caracteres
- ❌ "Nombre inválido" - Solo letras, números, guiones y guiones bajos

---

#### 3. Crear Usuario POS

**¿Cuándo usar?**
- Para crear usuarios de punto de venta
- Para usuarios que NO necesitan permisos de administrador
- Para cuentas con acceso limitado

**Pasos:**
1. Haz clic en "Crear Usuario POS"
2. Ingresa el nombre de usuario (Ejemplo: `POS-Caja1`)
3. Ingresa una contraseña (mínimo 4 caracteres)
4. Haz clic en "Submit"
5. El usuario se crea sin permisos de administrador

**Diferencias con Usuario del Sistema:**
- ✅ NO tiene permisos de administrador
- ✅ NO puede instalar software
- ✅ Ideal para terminales de punto de venta
- ✅ Mayor seguridad

---

### MANTENIMIENTO

#### 4. Limpieza de Disco

**¿Cuándo usar?**
- Cuando el disco está lleno
- Como mantenimiento preventivo mensual
- Para liberar espacio rápidamente

**Pasos:**
1. Haz clic en "Limpieza de Disco"
2. El sistema limpiará automáticamente:
   - Archivos temporales del usuario
   - Archivos temporales de Windows
   - Caché de Internet Explorer
   - Prefetch
3. Verás un mensaje con el espacio liberado

**Carpetas limpiadas:**
- `%TEMP%` - Archivos temporales del usuario
- `C:\Windows\Temp` - Archivos temporales de Windows
- `C:\Windows\Prefetch` - Caché de prefetch
- Caché de navegadores

**Nota:** Esta operación es segura y NO elimina archivos importantes

---

#### 5. Eliminar Usuarios

**¿Cuándo usar?**
- Para eliminar usuarios que ya no se usan
- Para limpiar cuentas de prueba
- Para liberar espacio en disco

**Pasos:**
1. Haz clic en "Eliminar Usuarios"
2. Ingresa el nombre EXACTO del usuario a eliminar
3. Haz clic en "Submit"
4. El usuario y su perfil se eliminan completamente

**ADVERTENCIA:**
- ⚠️ Esta acción NO se puede deshacer
- ⚠️ Se elimina el perfil completo del usuario
- ⚠️ Se pierden todos los archivos del usuario

**Usuarios protegidos (NO se pueden eliminar):**
- Administrator / Administrador
- Guest / Invitado
- DefaultAccount
- WDAGUtilityAccount

---

## 🔍 INFORMACIÓN DEL SISTEMA

### Tarjeta de Información

En la parte superior del dashboard verás:

```
┌─────────────────────────────────────────┐
│  INFORMACIÓN DEL SISTEMA                │
│  PC ACTUAL: NOMBRE-PC                   │
│  IMPORTANTE: Todos los scripts se       │
│  ejecutan en esta máquina               │
└─────────────────────────────────────────┘
```

**¿Qué significa?**
- Todos los cambios se aplican al equipo donde se ejecuta el dashboard
- Si necesitas configurar otro equipo, ejecuta el dashboard EN ese equipo
- Los usuarios se crean en el equipo local, no remotamente

---

## 📋 LOGS Y AUDITORÍA

### ¿Dónde están los logs?

Los logs se guardan en: `Logs/dashboard-YYYY-MM.log`

Ejemplo: `Logs/dashboard-2025-11.log`

### Formato de logs

```
[2025-11-07 14:30:15] [Info] [Cambiar-Nombre-PC] Nombre actual del PC: PC-Viejo
[2025-11-07 14:30:20] [Info] [Cambiar-Nombre-PC] Cambiando nombre a: PC-Nuevo
[2025-11-07 14:30:22] [Info] [Cambiar-Nombre-PC] Nombre cambiado exitosamente
```

### Niveles de log

- **Info** - Operación normal
- **Warning** - Advertencia (no crítico)
- **Error** - Error en la operación
- **Critical** - Error crítico del sistema

---

## ❌ ERRORES COMUNES Y SOLUCIONES

### Error: "Puerto 10000 en uso"

**Causa:** Ya hay un dashboard ejecutándose

**Solución:**
1. Cierra todas las ventanas de PowerShell
2. O ejecuta: `Tools\Limpiar-Puerto-10000.ps1`
3. Vuelve a iniciar el dashboard

---

### Error: "Requiere permisos de administrador"

**Causa:** El dashboard no se ejecutó como administrador

**Solución:**
1. Cierra el dashboard
2. Haz clic derecho en `Iniciar-Dashboard.bat`
3. Selecciona "Ejecutar como administrador"

---

### Error: "UniversalDashboard no está instalado"

**Causa:** Módulo no instalado

**Solución:**
1. El dashboard lo instalará automáticamente
2. Si falla, ejecuta manualmente:
   ```powershell
   Install-Module UniversalDashboard.Community -RequiredVersion 2.9.0
   ```

---

### Error: "El usuario ya existe"

**Causa:** Ya hay un usuario con ese nombre

**Solución:**
1. Usa otro nombre de usuario
2. O elimina el usuario existente primero
3. Verifica usuarios existentes con el botón "Ver Usuarios Actuales"

---

### Error: "Nombre de PC inválido"

**Causa:** El nombre no cumple las reglas de Windows

**Solución:**
- Usa solo letras, números y guiones
- 1 a 15 caracteres
- Debe empezar con letra
- No puede terminar con guión
- Ejemplo válido: `POS-Merliot`

---

## 🔐 SEGURIDAD Y MEJORES PRÁCTICAS

### Contraseñas

✅ **Recomendaciones:**
- Usa al menos 8 caracteres
- Combina letras, números y símbolos
- No uses contraseñas obvias (123456, password, etc.)
- Cambia las contraseñas periódicamente

❌ **Evita:**
- Contraseñas muy cortas (< 6 caracteres)
- Palabras del diccionario
- Información personal (nombres, fechas)

### Nombres de Usuario

✅ **Recomendaciones:**
- Usa nombres descriptivos: `POS-Caja1`, `Admin-Oficina`
- Sigue un estándar en tu organización
- Incluye el rol o ubicación

❌ **Evita:**
- Nombres genéricos: `Usuario1`, `Test`
- Caracteres especiales
- Nombres muy largos

### Permisos

✅ **Recomendaciones:**
- Usa "Usuario POS" para terminales sin privilegios
- Usa "Usuario del Sistema" solo cuando sea necesario
- Revisa periódicamente los usuarios creados

❌ **Evita:**
- Dar permisos de admin a todos los usuarios
- Usar la misma contraseña para todos
- Dejar usuarios de prueba activos

---

## 📞 SOPORTE Y AYUDA

### Documentación Adicional

- **Guía de Instalación:** `Docs/12-GUIA-INSTALACION.md`
- **Changelog:** `Docs/CHANGELOG.md`
- **Documentación Técnica:** `Docs/07-Arquitectura-y-Estado-Actual/`

### Verificar Sistema

Para verificar que todo está correctamente configurado:

```powershell
.\Tools\Verificar-Sistema.ps1
```

Este script verifica:
- ✅ Permisos de administrador
- ✅ Módulos instalados
- ✅ Estructura de carpetas
- ✅ Archivos principales
- ✅ Puerto disponible

---

## 🎓 CASOS DE USO COMUNES

### Caso 1: Configurar un Nuevo Equipo POS

1. Ejecuta el dashboard como administrador
2. Cambia el nombre del PC a `POS-[Ubicación]`
3. Reinicia el equipo
4. Crea un usuario POS: `POS-Caja1`
5. Configura el software de punto de venta
6. Cierra sesión y prueba con el usuario POS

### Caso 2: Configurar Equipo de Oficina

1. Ejecuta el dashboard como administrador
2. Cambia el nombre del PC a `Admin-[Ubicación]`
3. Reinicia el equipo
4. Crea un usuario del sistema: `Admin-[Nombre]`
5. Instala el software necesario
6. Configura permisos adicionales si es necesario

### Caso 3: Mantenimiento Mensual

1. Ejecuta el dashboard como administrador
2. Ejecuta "Limpieza de Disco"
3. Revisa los logs en `Logs/`
4. Elimina usuarios que ya no se usan
5. Verifica espacio en disco disponible

---

## ✅ CHECKLIST DE CONFIGURACIÓN

### Configuración Inicial de Equipo

- [ ] Dashboard ejecutándose como administrador
- [ ] Nombre del PC cambiado y reiniciado
- [ ] Usuario(s) creado(s) con contraseñas seguras
- [ ] Software necesario instalado
- [ ] Permisos verificados
- [ ] Prueba de inicio de sesión realizada
- [ ] Limpieza de archivos temporales
- [ ] Logs revisados

---

**Versión:** 1.0.0  
**Última Actualización:** 7 de Noviembre, 2025  
**Paradise-SystemLabs** - Dashboard IT
