# 👤 Como Crear Usuarios del Sistema

**Para quien:** Usuarios que necesitan crear usuarios locales en una computadora
**Tiempo de lectura:** 10 minutos
**Dificultad:** Facil

---

## Proposito

Esta guia explica como crear usuarios locales de Windows desde el dashboard de forma rapida y segura.

---

## Antes de Empezar

### Requisitos Previos

1. **Permisos de Administrador**
   - El dashboard DEBE ejecutarse como Administrador
   - Si no, aparecera un mensaje de error

2. **Dashboard en Ejecucion**
   - El dashboard debe estar corriendo en la PC donde quieres crear el usuario
   - Puerto 10000 debe estar libre
   - Accede a: `http://localhost:10000`

3. **Concepto Importante: Ejecucion Local**
   - Los usuarios se crean en la PC donde corre el dashboard
   - NO se crean remotamente en otras PCs
   - Si necesitas crear usuarios en otra PC, ejecuta el dashboard EN esa PC

Ver: [Concepto-Importante-Ejecucion-Local.md](../03-Soluciones-a-Problemas/Concepto-Importante-Ejecucion-Local.md)

---

## Paso a Paso

### Paso 1: Abrir el Dashboard

1. Abre tu navegador
2. Ve a: `http://localhost:10000`
3. Veras la pantalla principal del dashboard

### Paso 2: Ubicar la Seccion "CONFIGURACION INICIAL"

1. En la pagina principal, busca la seccion **"CONFIGURACION INICIAL"**
2. Debe ser la primera seccion visible
3. Contiene varios botones, el primero es **"Crear Usuario del Sistema"**

### Paso 3: Abrir el Formulario

1. Haz clic en el boton **"Crear Usuario del Sistema"**
2. Se abrira un modal (ventana emergente) con un formulario
3. El formulario tiene 3 campos:

```
┌─────────────────────────────────────────────┐
│ Crear Usuario del Sistema              [X] │
├─────────────────────────────────────────────┤
│                                             │
│ Nombre de Usuario:                          │
│ ┌─────────────────────────────────────────┐ │
│ │ Ejemplo: POS-Merliot                    │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ Password:                                   │
│ ┌─────────────────────────────────────────┐ │
│ │ Password (defecto: 841357)              │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ Tipo de Usuario:                            │
│ ┌─────────────────────────────────────────┐ │
│ │ [POS ▼]                                 │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│                    [Cancelar]  [Submit]     │
└─────────────────────────────────────────────┘
```

### Paso 4: Llenar el Formulario

#### Campo 1: Nombre de Usuario (OBLIGATORIO)

**Que ingresar:**
- Nombre descriptivo que identifique la funcion del usuario
- Sigue las convenciones de nombres de tu organizacion

**Ejemplos validos:**
- `POS-Merliot` (Usuario de punto de venta en sucursal Merliot)
- `POS-Escalon` (Usuario de punto de venta en sucursal Escalon)
- `DISENO-Principal` (Usuario de diseno grafico)
- `ATENCION-Recepcion` (Usuario de atencion al cliente)

**Reglas:**
- ✅ Usa letras, numeros y guiones
- ✅ Puedes usar mayusculas o minusculas
- ❌ NO uses espacios
- ❌ NO uses caracteres especiales (@ # $ % etc.)

#### Campo 2: Password (OPCIONAL)

**Que ingresar:**
- Contrasena para el nuevo usuario
- Si lo dejas vacio, usa el password por defecto: `841357`

**Recomendaciones:**
- Usa un password seguro si es un usuario con permisos especiales
- Para usuarios POS estandar, el password por defecto es suficiente
- Anota el password para comunicarselo al usuario

#### Campo 3: Tipo de Usuario (OPCIONAL)

**Opciones disponibles:**
- **POS** (por defecto) - Usuario de punto de venta
- **Admin** - Usuario administrativo
- **Diseno** - Usuario de diseno grafico
- **Cliente** - Usuario de atencion al cliente
- **Mantenimiento** - Usuario de mantenimiento tecnico

**Nota:** Este campo es descriptivo y ayuda a identificar la funcion del usuario en el sistema.

### Paso 5: Crear el Usuario

1. Revisa que la informacion este correcta
2. Haz clic en el boton **"Submit"**
3. El dashboard:
   - Validara los datos
   - Verificara permisos
   - Verificara que el usuario no exista
   - Creara el usuario
   - Agregara el usuario al grupo "Users"
   - Registrara la operacion en los logs

### Paso 6: Confirmar Creacion

Si todo salio bien, veras un mensaje verde (toast) en la parte superior:

```
✓ Usuario POS-Merliot creado exitosamente. Password: 841357
```

El mensaje se mostrara por 8 segundos y luego desaparecera.

---

## Ejemplos Completos

### Ejemplo 1: Usuario POS Basico

**Escenario:** Crear usuario de punto de venta con configuracion estandar

```
Campo 1 (Nombre):    POS-Merliot
Campo 2 (Password):  [dejar vacio - usa 841357]
Campo 3 (Tipo):      POS
```

**Resultado:**
- Usuario creado: `POS-Merliot`
- Password: `841357`
- Tipo: POS
- Grupo: Users

### Ejemplo 2: Usuario de Diseno con Password Personalizado

**Escenario:** Crear usuario de diseno con password especifico

```
Campo 1 (Nombre):    DISENO-Principal
Campo 2 (Password):  MiPassword2025!
Campo 3 (Tipo):      Diseno
```

**Resultado:**
- Usuario creado: `DISENO-Principal`
- Password: `MiPassword2025!`
- Tipo: Diseno
- Grupo: Users

### Ejemplo 3: Usuario Administrativo

**Escenario:** Crear usuario administrativo

```
Campo 1 (Nombre):    ADMIN-Gerencia
Campo 2 (Password):  AdminSecure123
Campo 3 (Tipo):      Admin
```

**Resultado:**
- Usuario creado: `ADMIN-Gerencia`
- Password: `AdminSecure123`
- Tipo: Admin
- Grupo: Users

---

## Problemas Comunes

### Problema 1: "El dashboard debe ejecutarse como Administrador"

**Causa:** El dashboard no se inicio con permisos de administrador

**Solucion:**
1. Cierra el dashboard actual
2. Busca el archivo `Iniciar-Dashboard.bat`
3. Haz clic derecho sobre el
4. Selecciona "Ejecutar como administrador"
5. Vuelve a intentar crear el usuario

### Problema 2: "El usuario [nombre] ya existe"

**Causa:** Ya existe un usuario con ese nombre en el sistema

**Soluciones:**

**Opcion A: Usar otro nombre**
1. Cancela el formulario
2. Vuelve a abrirlo
3. Ingresa un nombre diferente (ejemplo: POS-Merliot2)

**Opcion B: Eliminar el usuario existente**
1. Abre PowerShell como Administrador
2. Ejecuta:
   ```powershell
   cd C:\ProgramData\WPE-Dashboard
   .\Tools\Eliminar-Usuario.ps1
   ```
3. Sigue las instrucciones para eliminar el usuario
4. Vuelve al dashboard y crea el usuario nuevamente

Ver: [Cuando-el-Usuario-Ya-Existe.md](../03-Soluciones-a-Problemas/Cuando-el-Usuario-Ya-Existe.md)

### Problema 3: "Debes ingresar un nombre de usuario"

**Causa:** El campo "Nombre de Usuario" esta vacio

**Solucion:**
1. Ingresa un nombre en el primer campo
2. No dejes el campo vacio
3. Vuelve a hacer clic en "Submit"

### Problema 4: Usuario Creado en PC Incorrecta

**Causa:** El dashboard esta corriendo en una PC diferente a la que querias configurar

**Solucion:**
1. Recuerda: Los usuarios se crean en la PC donde corre el dashboard
2. Si necesitas crear usuarios en otra PC:
   - Conectate a esa PC (via RDP o fisicamente)
   - Ejecuta el dashboard EN esa PC
   - Crea los usuarios desde alli

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

## Verificar que el Usuario se Creo Correctamente

### Desde PowerShell

```powershell
# Listar todos los usuarios locales
Get-LocalUser

# Ver informacion de un usuario especifico
Get-LocalUser -Name "POS-Merliot"

# Ver grupos del usuario
Get-LocalGroup | Where-Object { (Get-LocalGroupMember -Group $_Name -ErrorAction SilentlyContinue).Name -contains "$env:COMPUTERNAME\POS-Merliot" }
```

### Desde Windows

1. Abre "Configuracion" de Windows
2. Ve a "Cuentas"
3. Selecciona "Otros usuarios"
4. Veras la lista de usuarios locales

---

## Que Hace el Dashboard Automaticamente

Cuando creas un usuario, el dashboard realiza estas acciones automaticamente:

1. ✅ **Valida el nombre** - Verifica que no este vacio
2. ✅ **Verifica permisos** - Confirma que tienes permisos de administrador
3. ✅ **Verifica que no exista** - Confirma que el usuario no existe
4. ✅ **Crea el usuario** - Crea el usuario local en Windows
5. ✅ **Configura descripcion** - Agrega descripcion con tipo de usuario y nombre del PC
6. ✅ **Configura password** - Usa el password especificado o el por defecto
7. ✅ **Configura expiracion** - Password nunca expira
8. ✅ **Configura cambio de password** - Usuario no puede cambiar password
9. ✅ **Agrega a grupo Users** - Agrega el usuario al grupo "Users" de Windows
10. ✅ **Registra en logs** - Guarda la operacion en los logs del dashboard

**Ubicacion de logs:**
```
C:\ProgramData\WPE-Dashboard\Logs\dashboard-[año]-[mes].log
```

---

## Proximos Pasos Despues de Crear el Usuario

1. **Comunica las credenciales al usuario:**
   - Nombre de usuario
   - Password
   - Instrucciones de inicio de sesion

2. **Verifica el login:**
   - Prueba iniciar sesion con el nuevo usuario
   - Confirma que puede acceder al sistema

3. **Configura permisos adicionales (si es necesario):**
   - Agrega a grupos adicionales
   - Configura permisos de carpetas
   - Configura permisos de aplicaciones

4. **Documenta:**
   - Anota el usuario creado en tu inventario
   - Registra la fecha de creacion
   - Registra el PC donde se creo

---

## Seguridad y Mejores Practicas

### Recomendaciones de Seguridad

1. **Passwords:**
   - Usa el password por defecto solo para usuarios estandar
   - Usa passwords seguros para usuarios administrativos
   - No compartas passwords por email o chat

2. **Nombres de Usuario:**
   - No uses nombres personales (evita "Juan", "Maria", etc.)
   - Usa nombres descriptivos de la funcion
   - Sigue las convenciones de la organizacion

3. **Permisos:**
   - Crea usuarios con los minimos permisos necesarios
   - No agregues todos los usuarios al grupo Administradores
   - Revisa periodicamente los usuarios activos

4. **Auditoria:**
   - Revisa los logs periodicamente
   - Documenta todos los usuarios creados
   - Elimina usuarios que ya no se usan

### Mejores Practicas

1. **Planifica antes de crear:**
   - Define el nombre antes de crear el usuario
   - Ten claro el tipo de usuario
   - Verifica que el dashboard esta en la PC correcta

2. **Verifica despues de crear:**
   - Confirma que el mensaje de exito aparecio
   - Prueba iniciar sesion con el nuevo usuario
   - Verifica que tiene los permisos necesarios

3. **Documenta:**
   - Mantén un registro de usuarios creados
   - Anota la fecha y el PC
   - Documenta el proposito del usuario

---

## Comandos Utiles

### Ver Usuarios Locales

```powershell
Get-LocalUser
```

### Ver Usuario Especifico

```powershell
Get-LocalUser -Name "POS-Merliot"
```

### Ver Grupos del Usuario

```powershell
Get-LocalGroup | Where-Object {
    (Get-LocalGroupMember -Group $_.Name -ErrorAction SilentlyContinue).Name -contains "$env:COMPUTERNAME\POS-Merliot"
}
```

### Eliminar Usuario

```powershell
cd C:\ProgramData\WPE-Dashboard
.\Tools\Eliminar-Usuario.ps1
```

### Ver Logs

```powershell
Get-Content "C:\ProgramData\WPE-Dashboard\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log" -Tail 20
```

---

## Preguntas Frecuentes

### ¿Puedo crear usuarios en multiples PCs desde un solo dashboard?

**No.** El dashboard crea usuarios LOCALMENTE en la PC donde esta corriendo. Si necesitas crear usuarios en multiples PCs, debes:
1. Ejecutar el dashboard EN cada PC
2. Crear los usuarios desde esa PC

O bien, implementar una solucion centralizada con Active Directory (no cubierto en esta guia).

### ¿Que pasa si olvido el password de un usuario?

Puedes usar PowerShell para cambiar el password:

```powershell
$newPassword = ConvertTo-SecureString "NuevoPassword123" -AsPlainText -Force
Set-LocalUser -Name "POS-Merliot" -Password $newPassword
```

### ¿Puedo cambiar el nombre de un usuario despues de crearlo?

No directamente. Windows no permite renombrar usuarios locales facilmente. Lo mejor es:
1. Crear un nuevo usuario con el nombre correcto
2. Eliminar el usuario antiguo

### ¿Los usuarios creados son administradores?

No, por defecto los usuarios se crean en el grupo "Users" que tiene permisos limitados. Si necesitas un usuario administrador, debes agregarlo manualmente al grupo "Administradores" despues de crearlo.

---

## Documentacion Relacionada

- [Concepto-Importante-Ejecucion-Local.md](../03-Soluciones-a-Problemas/Concepto-Importante-Ejecucion-Local.md) - **CRITICO** - Lee esto primero
- [Cuando-el-Usuario-Ya-Existe.md](../03-Soluciones-a-Problemas/Cuando-el-Usuario-Ya-Existe.md) - Solucion a error de usuario existente
- [Comandos-Utiles-para-Administradores.md](Comandos-Utiles-para-Administradores.md) - Referencia completa de comandos
- [Guia-Inicio-Rapido-5-Minutos.txt](../01-Primeros-Pasos/Guia-Inicio-Rapido-5-Minutos.txt) - Como iniciar el dashboard

---

**Dashboard IT - Paradise-SystemLabs**
*Automatizacion inteligente para equipos eficientes*

**Ultima actualizacion:** 7 de Noviembre, 2025
**Version:** 1.0
