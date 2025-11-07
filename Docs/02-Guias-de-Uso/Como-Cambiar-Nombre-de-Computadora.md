# 🖥️ Como Cambiar el Nombre de una Computadora

**Para quien:** Usuarios que necesitan cambiar el nombre de un equipo Windows
**Tiempo de lectura:** 12 minutos
**Dificultad:** Facil

---

## Proposito

Esta guia explica como cambiar el nombre de una computadora Windows desde el dashboard de forma rapida y segura.

---

## Por Que Cambiar el Nombre del PC

### Problema con Nombres Automaticos

Windows asigna automaticamente nombres poco amigables a las computadoras:

```
❌ DESKTOP-VHIMQ05
❌ LAPTOP-A8G3HJ92
❌ WORKSTATION-9KL2
```

**Problemas:**
- Dificil de recordar
- No descriptivo
- No indica la funcion del equipo
- Complica el soporte tecnico

### Beneficios de Nombres Descriptivos

Nombres claros facilitan la administracion:

```
✅ POS-Merliot (Punto de venta en sucursal Merliot)
✅ DISENO-Principal (Equipo de diseno grafico principal)
✅ ADMIN-Gerencia (Equipo de gerencia)
```

**Ventajas:**
- Facil de identificar
- Describe la funcion del equipo
- Facilita el inventario
- Mejora el soporte tecnico
- Imagen mas profesional

---

## Antes de Empezar

### Requisitos Previos

1. **Permisos de Administrador**
   - El dashboard DEBE ejecutarse como Administrador
   - Si no, aparecera un mensaje de error

2. **Dashboard en Ejecucion**
   - El dashboard debe estar corriendo en la PC que quieres renombrar
   - Puerto 10000 debe estar libre
   - Accede a: `http://localhost:10000`

3. **Concepto Importante: Ejecucion Local**
   - El nombre se cambia en la PC donde corre el dashboard
   - NO se cambia remotamente en otras PCs
   - Si necesitas renombrar otra PC, ejecuta el dashboard EN esa PC

Ver: [Concepto-Importante-Ejecucion-Local.md](../03-Soluciones-a-Problemas/Concepto-Importante-Ejecucion-Local.md)

### Consideraciones Importantes

⚠️ **IMPORTANTE: REQUIERE REINICIO**

- El cambio de nombre **REQUIERE REINICIAR** el equipo
- Windows NO aplica el cambio hasta que reinicies
- El dashboard seguira mostrando el nombre antiguo hasta que reinicies
- Planifica el cambio en un momento apropiado

⚠️ **Impacto en Red**

- Si el PC esta en un dominio, puede requerir permisos adicionales
- Puede afectar conexiones de red activas
- Planifica el cambio en horario de bajo uso

⚠️ **Usuarios Activos**

- Cierra todas las sesiones de usuario antes de cambiar
- Guarda todo el trabajo pendiente
- Notifica a usuarios del reinicio programado

---

## Paso a Paso

### Paso 1: Identificar el Nombre Actual

1. Abre tu navegador
2. Ve a: `http://localhost:10000`
3. En la pagina principal veras una tarjeta **"INFORMACION DEL SISTEMA"**
4. Muestra el nombre actual del PC:

```
┌─────────────────────────────────────────────┐
│ INFORMACION DEL SISTEMA                     │
├─────────────────────────────────────────────┤
│ PC ACTUAL: DESKTOP-VHIMQ05                  │
│                                             │
│ IMPORTANTE: Todos los scripts se ejecutan  │
│ en esta maquina                             │
└─────────────────────────────────────────────┘
```

### Paso 2: Ubicar el Boton "Cambiar Nombre del PC"

1. En la seccion **"CONFIGURACION INICIAL"**
2. Busca el boton **"Cambiar Nombre del PC"**
3. Esta ubicado despues del boton "Crear Usuario del Sistema"

```
┌─────────────────────────────────────────────┐
│ CONFIGURACION INICIAL                       │
├─────────────────────────────────────────────┤
│ [Crear Usuario del Sistema]                │
│ [Cambiar Nombre del PC]        ← ESTE      │
│ [Otros botones...]                          │
└─────────────────────────────────────────────┘
```

### Paso 3: Abrir el Formulario

1. Haz clic en el boton **"Cambiar Nombre del PC"**
2. Se abrira un modal (ventana emergente) con un formulario
3. El formulario tiene 2 campos:

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

### Paso 4: Ingresar el Nuevo Nombre

#### Campo 1: Nombre Actual (No Editable)

- Muestra el nombre actual del PC
- Este campo esta deshabilitado (solo lectura)
- Es informativo para que confirmes que estas en la PC correcta

#### Campo 2: Nuevo Nombre (OBLIGATORIO)

**Que ingresar:**
- Nombre descriptivo que identifique la funcion del equipo
- Sigue las convenciones de nombres de tu organizacion

**Reglas de Formato:**
- ✅ 1-15 caracteres maximo
- ✅ Usa letras, numeros y guiones
- ✅ Puede empezar con letra o numero
- ❌ NO puede empezar o terminar con guion
- ❌ NO uses espacios
- ❌ NO uses caracteres especiales (@ # $ % etc.)

**Ejemplos validos:**
```
✅ POS-Merliot
✅ DISENO-Principal
✅ ADMIN-Gerencia
✅ ATENCION-01
```

**Ejemplos invalidos:**
```
❌ POS Merliot (tiene espacio)
❌ -POS-Merliot (empieza con guion)
❌ POS-Merliot- (termina con guion)
❌ POS@Merliot (caracter especial)
❌ POS-MerliotSucursalPrincipal (mas de 15 caracteres)
```

### Paso 5: Cambiar el Nombre

1. Revisa que el nuevo nombre este correcto
2. Verifica que sigues las reglas de formato
3. Haz clic en el boton **"Submit"**
4. El dashboard:
   - Validara los permisos de administrador
   - Validara el formato del nombre
   - Verificara que el nombre es diferente al actual
   - Ejecutara el comando para cambiar el nombre
   - Registrara la operacion en los logs

### Paso 6: Confirmar y Reiniciar

Si todo salio bien, veras un mensaje verde (toast) en la parte superior:

```
✓ Nombre del PC cambiado exitosamente a 'POS-Merliot'.

IMPORTANTE: Debes REINICIAR el equipo para aplicar los cambios.
```

**Acciones siguientes:**

1. **Guarda todo tu trabajo pendiente**
2. **Cierra todas las aplicaciones**
3. **Notifica a otros usuarios (si aplica)**
4. **Reinicia el equipo:**

   - Opcion A: Usando Windows
     - Menu Inicio → Energia → Reiniciar

   - Opcion B: Usando PowerShell
     ```powershell
     Restart-Computer -Force
     ```

5. **Espera a que Windows reinicie**
6. **Verifica el nuevo nombre:**
   - Abre PowerShell
   - Ejecuta: `$env:COMPUTERNAME`
   - Debe mostrar el nuevo nombre

---

## Ejemplos Completos

### Ejemplo 1: Punto de Venta

**Escenario:** Renombrar PC de punto de venta en sucursal Merliot

```
Nombre Actual:  DESKTOP-VHIMQ05
Nuevo Nombre:   POS-Merliot
```

**Resultado:**
- Nombre cambiado a `POS-Merliot`
- Requiere reinicio
- Log registrado

### Ejemplo 2: Equipo de Diseno

**Escenario:** Renombrar equipo de diseno grafico principal

```
Nombre Actual:  DESKTOP-ABC123
Nuevo Nombre:   DISENO-Principal
```

**Resultado:**
- Nombre cambiado a `DISENO-Principal`
- Requiere reinicio
- Log registrado

### Ejemplo 3: Equipo Administrativo

**Escenario:** Renombrar equipo de gerencia

```
Nombre Actual:  LAPTOP-XYZ789
Nuevo Nombre:   ADMIN-Gerencia
```

**Resultado:**
- Nombre cambiado a `ADMIN-Gerencia`
- Requiere reinicio
- Log registrado

---

## Problemas Comunes

### Problema 1: "El dashboard debe ejecutarse como Administrador"

**Causa:** El dashboard no se inicio con permisos de administrador

**Solucion:**
1. Cierra el dashboard actual
2. Busca el archivo `Iniciar-Dashboard.bat`
3. Haz clic derecho sobre el
4. Selecciona "Ejecutar como administrador"
5. Vuelve a intentar cambiar el nombre

### Problema 2: "Nombre invalido. Usa solo letras, numeros y guiones (1-15 caracteres)"

**Causa:** El nombre ingresado no cumple con el formato requerido

**Soluciones:**

**Si tiene espacios:**
```
❌ POS Merliot
✅ POS-Merliot
```

**Si es muy largo:**
```
❌ POS-MerliotSucursalPrincipal (mas de 15 caracteres)
✅ POS-Merliot (15 caracteres o menos)
```

**Si tiene caracteres especiales:**
```
❌ POS@Merliot
✅ POS-Merliot
```

**Si empieza/termina con guion:**
```
❌ -POS-Merliot
❌ POS-Merliot-
✅ POS-Merliot
```

### Problema 3: "El nuevo nombre es igual al actual. No hay cambios que realizar."

**Causa:** Ingresaste el mismo nombre que ya tiene el PC

**Solucion:**
1. Verifica el nombre actual en el campo deshabilitado
2. Ingresa un nombre DIFERENTE
3. Vuelve a hacer clic en "Submit"

### Problema 4: El nombre no cambia despues de hacer clic en Submit

**Causa:** No reiniciaste el equipo

**Solucion:**
1. El cambio de nombre REQUIERE REINICIO
2. Windows no aplica el cambio hasta que reinicies
3. Reinicia el equipo
4. Verifica el nuevo nombre despues del reinicio

### Problema 5: Nombre Cambiado en PC Incorrecta

**Causa:** El dashboard estaba corriendo en una PC diferente a la que querias renombrar

**Solucion:**
1. Recuerda: El nombre se cambia en la PC donde corre el dashboard
2. Si necesitas renombrar otra PC:
   - Conectate a esa PC (via RDP o fisicamente)
   - Ejecuta el dashboard EN esa PC
   - Cambia el nombre desde alli

Ver: [Concepto-Importante-Ejecucion-Local.md](../03-Soluciones-a-Problemas/Concepto-Importante-Ejecucion-Local.md)

---

## Convenciones de Nombres Sugeridas

Para mantener un estandar en la organizacion, se recomienda usar estas convenciones:

### Por Tipo de Equipo

#### Punto de Venta (POS)
```
POS-[Ubicacion]

Ejemplos:
  - POS-Merliot
  - POS-Escalon
  - POS-SantaTecla
  - POS-Principal
```

#### Diseno Grafico
```
DISENO-[Descripcion]

Ejemplos:
  - DISENO-Principal
  - DISENO-Render
  - DISENO-Edicion
  - DISENO-Video
```

#### Atencion al Cliente
```
ATENCION-[Ubicacion]

Ejemplos:
  - ATENCION-Recepcion
  - ATENCION-CallCenter
  - ATENCION-Soporte
  - ATENCION-Ventas
```

#### Administracion
```
ADMIN-[Funcion]

Ejemplos:
  - ADMIN-Gerencia
  - ADMIN-Contabilidad
  - ADMIN-RRHH
  - ADMIN-Sistemas
```

#### Mantenimiento
```
MANT-[Descripcion]

Ejemplos:
  - MANT-Taller
  - MANT-Bodega
  - MANT-Tecnico
  - MANT-Almacen
```

---

## Verificar el Cambio

### Antes del Reinicio

El cambio NO se aplica inmediatamente. Si ejecutas estos comandos ANTES de reiniciar, seguiras viendo el nombre antiguo:

```powershell
# Todavia muestra el nombre antiguo
$env:COMPUTERNAME
```

### Despues del Reinicio

Despues de reiniciar el equipo, verifica el cambio:

```powershell
# Ahora muestra el nuevo nombre
$env:COMPUTERNAME

# O tambien puedes usar
Get-ComputerInfo | Select-Object CsName
```

### Desde Windows

1. Abre "Configuracion" de Windows
2. Ve a "Sistema"
3. Selecciona "Acerca de"
4. Veras el nombre del equipo

---

## Que Hace el Dashboard Automaticamente

Cuando cambias el nombre, el dashboard realiza estas acciones automaticamente:

1. ✅ **Valida permisos** - Verifica que tienes permisos de administrador
2. ✅ **Valida formato** - Verifica que el nombre cumple las reglas
3. ✅ **Valida nombre vacio** - Verifica que ingresaste un nombre
4. ✅ **Valida nombre diferente** - Verifica que el nuevo nombre es diferente al actual
5. ✅ **Auto-detecta PC actual** - Identifica automaticamente el nombre actual
6. ✅ **Ejecuta el comando** - Ejecuta `Rename-Computer -NewName "[nombre]"`
7. ✅ **Muestra mensaje de exito** - Confirma que el cambio fue exitoso
8. ✅ **Registra en logs** - Guarda la operacion en los logs del dashboard

**Ubicacion de logs:**
```
C:\ProgramData\WPE-Dashboard\Logs\dashboard-[año]-[mes].log
```

**Ejemplo de log:**
```
[2025-11-07 15:47:23] Cambiar Nombre PC - Exitoso: DESKTOP-VHIMQ05 -> POS-Merliot
```

---

## Seguridad y Mejores Practicas

### Recomendaciones

1. **Planifica el cambio:**
   - Define el nombre antes de cambiar
   - Verifica que el dashboard esta en la PC correcta
   - Planifica el reinicio en un momento apropiado

2. **Comunica el cambio:**
   - Notifica a usuarios del reinicio programado
   - Actualiza tu inventario con el nuevo nombre
   - Documenta la fecha del cambio

3. **Verifica despues del cambio:**
   - Confirma que el mensaje de exito aparecio
   - Reinicia el equipo
   - Verifica el nuevo nombre despues del reinicio
   - Prueba que las conexiones de red funcionan

4. **Documenta:**
   - Mantén un registro de cambios de nombre
   - Anota la fecha y el PC
   - Actualiza el inventario

### Mejores Practicas

1. **Usa nombres consistentes:**
   - Sigue las convenciones de la organizacion
   - Usa patrones predecibles (POS-[Ubicacion], etc.)
   - Facilita la identificacion y el inventario

2. **No cambies nombres frecuentemente:**
   - El cambio de nombre interrumpe el trabajo
   - Puede afectar conexiones de red
   - Planifica bien el nombre antes de cambiar

3. **Revisa los logs:**
   - Los logs registran todos los cambios
   - Util para auditoria
   - Ayuda a resolver problemas

---

## Comandos Utiles

### Ver Nombre Actual

```powershell
# Opcion 1
$env:COMPUTERNAME

# Opcion 2
Get-ComputerInfo | Select-Object CsName

# Opcion 3
hostname
```

### Cambiar Nombre (Manualmente con PowerShell)

```powershell
# Si prefieres usar PowerShell directamente
Rename-Computer -NewName "NuevoNombre" -Force
```

### Reiniciar Equipo

```powershell
# Reiniciar inmediatamente
Restart-Computer -Force

# Reiniciar con retraso de 30 segundos
Restart-Computer -Force -Delay 30
```

### Ver Logs del Dashboard

```powershell
Get-Content "C:\ProgramData\WPE-Dashboard\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log" -Tail 20
```

---

## Preguntas Frecuentes

### ¿Puedo cambiar el nombre sin reiniciar?

**No.** Windows requiere un reinicio para aplicar el cambio de nombre. Es una limitacion del sistema operativo, no del dashboard.

### ¿Puedo cambiar nombres de multiples PCs desde un solo dashboard?

**No.** El dashboard cambia el nombre LOCALMENTE en la PC donde esta corriendo. Si necesitas renombrar multiples PCs, debes ejecutar el dashboard EN cada PC.

### ¿Que pasa si el PC esta en un dominio?

El cambio de nombre puede requerir permisos adicionales del dominio. Consulta con tu administrador de red antes de cambiar el nombre de un PC en dominio.

### ¿Puedo usar el mismo nombre en multiples PCs?

**No.** Cada PC en la red debe tener un nombre unico. Si intentas usar un nombre duplicado, puede causar conflictos de red.

### ¿El cambio afecta mis archivos o configuraciones?

**No.** El cambio de nombre NO afecta tus archivos, programas o configuraciones. Solo cambia el nombre del equipo en la red.

---

## Documentacion Relacionada

- [Concepto-Importante-Ejecucion-Local.md](../03-Soluciones-a-Problemas/Concepto-Importante-Ejecucion-Local.md) - **CRITICO** - Lee esto primero
- [Como-Se-Implemento-Cambiar-Nombre-PC.md](../06-Casos-de-Implementacion/Como-Se-Implemento-Cambiar-Nombre-PC.md) - Documentacion tecnica completa
- [Comandos-Utiles-para-Administradores.md](Comandos-Utiles-para-Administradores.md) - Referencia completa de comandos
- [Guia-Inicio-Rapido-5-Minutos.txt](../01-Primeros-Pasos/Guia-Inicio-Rapido-5-Minutos.txt) - Como iniciar el dashboard

---

**Dashboard IT - Paradise-SystemLabs**
*Automatizacion inteligente para equipos eficientes*

**Ultima actualizacion:** 7 de Noviembre, 2025
**Version:** 1.0
