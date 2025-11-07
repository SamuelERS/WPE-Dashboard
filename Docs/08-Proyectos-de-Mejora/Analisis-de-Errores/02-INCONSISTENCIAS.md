# INCONSISTENCIAS

**Impacto:** MEDIO-ALTO - Afecta mantenibilidad y profesionalismo
**Prioridad:** ALTA (corregir en siguiente sprint)

---

## IN-1: SISTEMA DE COLORES INCONSISTENTE

**Ubicacion:** Todo el archivo Dashboard.ps1
**Impacto:** ALTO (Mantenibilidad)
**Tipo:** Inconsistencia de implementacion

### Descripcion
Se usan **4 metodos diferentes** para definir colores en el mismo archivo.

### Metodos Encontrados

**1. Variables definidas (CORRECTO, pero NO USADAS)**
```powershell
# Linea 140
$Colors = @{Primary = "#2196F3"; Success = "#4caf50"; Warning = "#ff9800"; Danger = "#dc3545"}
```

**2. Hardcoded hex en estilos de botones**
```powershell
# Linea 241
-Style @{'background-color'='#dc3545';'color'='white'}  # Rojo
```

**3. Hardcoded hex diferente en toasts**
```powershell
# Linea 316
-BackgroundColor "#f44336"  # Rojo DIFERENTE de $Colors.Danger
```

**4. Hardcoded hex en otros elementos**
```powershell
# Linea 608
-Style @{'background-color'='#4caf50';'color'='white'}  # Verde
```

### Ejemplos de Inconsistencia

**Boton REINICIAR PC aparece 2 veces con mismo estilo:**
```powershell
# Linea 241 (Primera aparicion)
-Style @{'background-color'='#dc3545';'color'='white'}

# Linea 644 (Segunda aparicion - duplicado)
-Style @{'background-color'='#dc3545';'color'='white';'font-weight'='bold'}
```

**Toasts usan colores diferentes para mismo tipo:**
```powershell
# Toast de error - Color 1
-BackgroundColor "#f44336"  # Linea 316

# Toast de error - Color 2 (definido pero no usado)
$Colors.Danger = "#dc3545"  # Linea 140

# Diferencia: #f44336 vs #dc3545 (ambos rojos, pero diferentes)
```

### Problema
- Imposible cambiar esquema de colores sin buscar/reemplazar manualmente
- Inconsistencia visual sutil (#f44336 vs #dc3545)
- Duplicacion de valores magicos
- No hay single source of truth

### Mapa de Colores Usado

| Color | Variable | Valor Esperado | Valores Reales Usados |
|-------|----------|----------------|----------------------|
| Rojo/Danger | $Colors.Danger | #dc3545 | #dc3545, #f44336 |
| Verde/Success | $Colors.Success | #4caf50 | #4caf50 (consistente) |
| Naranja/Warning | $Colors.Warning | #ff9800 | #ff9800 (solo en modal) |
| Azul/Primary | $Colors.Primary | #2196F3 | NO USADO |

### Solucion

**1. Unificar color rojo:**
```powershell
# Decidir: cual usar?
# Opcion A: Material Design Red 600
$Colors.Danger = "#dc3545"

# Opcion B: Material Design Red 500
$Colors.Danger = "#f44336"

# Reemplazar TODAS las ocurrencias con variable
```

**2. Reemplazar todos los hardcoded values:**
```powershell
# Buscar y reemplazar:
"#dc3545" → $Colors.Danger
"#f44336" → $Colors.Danger
"#4caf50" → $Colors.Success
"#ff9800" → $Colors.Warning
"#2196F3" → $Colors.Primary
```

**Tiempo estimado:** 2 horas

---

## IN-2: ESPACIADO INCONSISTENTE

**Ubicacion:** Todo el archivo
**Impacto:** MEDIO (Apariencia desorganizada)
**Tipo:** Inconsistencia visual

### Valores de Gap Encontrados

| Valor | Lineas | Contexto |
|-------|--------|----------|
| 10px | 177, 244, 323, 617, 624, 631 | Gap entre botones (mayoria) |
| 12px | 643 | Gap en zona critica |
| Variable $Spacing.M = "12px" | 141 | Definida pero NO USADA |

### Valores de Padding Encontrados

| Valor | Lineas | Contexto |
|-------|--------|----------|
| 10px | 166 | Card de informacion |
| 15px | 641 | Card de zona critica |
| 16px | 604, 617, 624, 631 | Cards de secciones especializadas |

### Valores de Margin Encontrados

| Valor | Lineas | Contexto |
|-------|--------|----------|
| 0 auto | 159, 160 | Centrado horizontal |
| 10px (margin-bottom) | 177, 244 | Separacion entre elementos |
| 12px (margin-top) | 643 | Zona critica |
| 24px 0 | 173, 639 | Margin vertical grande |

### Problema
- No hay consistencia visual entre secciones
- Algunos elementos se ven mas "apretados" que otros
- Variable `$Spacing` definida pero ignorada
- Dificil ajustar espaciado globalmente

### Solucion

**1. Definir escala de espaciado:**
```powershell
$Spacing = @{
    XS = "4px"   # Extra small
    S  = "8px"   # Small
    M  = "12px"  # Medium (defecto)
    L  = "16px"  # Large
    XL = "24px"  # Extra large
}
```

**2. Aplicar consistentemente:**
```powershell
# Gap entre botones → Spacing.M
'gap' = $Spacing.M  # 12px

# Padding de cards normales → Spacing.L
'padding' = $Spacing.L  # 16px

# Padding de cards pequenas → Spacing.M
'padding' = $Spacing.M  # 12px

# Margin entre secciones → Spacing.XL
'margin' = "$($Spacing.XL) 0"  # 24px 0
```

**Tiempo estimado:** 1.5 horas

---

## IN-3: ORGANIZACION DE BOTONES ILOGICA

**Ubicacion:** `Dashboard.ps1:175-601`
**Impacto:** MEDIO (UX confusa)
**Tipo:** Arquitectura de informacion

### Problema 1: Boton Duplicado

**"REINICIAR PC" aparece 2 veces:**

```powershell
# Primera aparicion - Linea 236
# Seccion: "CONFIGURACION INICIAL"
New-UDButton -Text "REINICIAR PC" -OnClick {...}

# Segunda aparicion - Linea 644
# Seccion: "ACCIONES CRITICAS"
New-UDButton -Text "REINICIAR PC" -OnClick {...}
```

**Diferencias entre ambas:**
- Misma funcionalidad
- Mismo color de fondo (#dc3545)
- Segunda tiene `font-weight: bold`
- Segunda tiene mejor contexto visual (zona critica)

**Solucion:** Eliminar primera aparicion, dejar solo en "ACCIONES CRITICAS"

### Problema 2: Botones Relacionados Dispersos

**Gestion de usuarios dividida en 5 botones en 2 secciones:**

```powershell
# SECCION: CONFIGURACION INICIAL
- "Crear Usuario del Sistema" (linea 248)
- "Ver Usuarios Actuales" (linea 324)
- "Reparar Usuarios Existentes" (linea 386)
- "Eliminar Usuarios" (linea 446) ← Bug: no se renderiza
- "Diagnostico Pantalla Login" (linea 506)

# Todos deberian estar juntos en una sub-seccion
```

**Mejor organizacion:**
```
CONFIGURACION INICIAL
├── USUARIOS
│   ├── Crear Usuario
│   ├── Ver Usuarios
│   ├── Reparar Usuarios
│   ├── Eliminar Usuarios
│   └── Diagnostico Login
├── SISTEMA
│   ├── Cambiar Nombre PC
│   └── Configurar Red
└── OTROS
    └── ...
```

### Problema 3: Seccion Sobrecargada

**"CONFIGURACION INICIAL" tiene demasiadas funciones:**

```powershell
# Linea 175-601: CONFIGURACION INICIAL
1. Cambiar Nombre del PC
2. REINICIAR PC ← No deberia estar aqui
3. Crear Usuario del Sistema
4. Ver Usuarios Actuales
5. Reparar Usuarios Existentes
6. Eliminar Usuarios (bug)
7. Diagnostico Pantalla Login
8. Configurar Biometria (placeholder)
9. Instalar Software Base (placeholder)
```

**9 funciones mezcladas sin jerarquia clara**

### Solucion

**Reorganizar en sub-secciones:**
```powershell
New-UDLayout -Columns 2 -Content {
    # COLUMNA 1: USUARIOS
    New-UDCard -Title "GESTION DE USUARIOS" -Content {
        New-UDButton -Text "Crear Usuario"
        New-UDButton -Text "Ver Usuarios"
        New-UDButton -Text "Reparar Usuarios"
        New-UDButton -Text "Eliminar Usuarios"
        New-UDButton -Text "Diagnostico Login"
    }

    # COLUMNA 2: SISTEMA
    New-UDCard -Title "CONFIGURACION DE SISTEMA" -Content {
        New-UDButton -Text "Cambiar Nombre PC"
        New-UDButton -Text "Configurar Red"
        New-UDButton -Text "Instalar Software Base"
    }
}
```

**Tiempo estimado:** 3 horas (requiere reestructuracion)

---

## IN-4: NOMENCLATURA INCONSISTENTE

**Ubicacion:** Titulos de botones y cards
**Impacto:** BAJO (Profesionalismo)
**Tipo:** Inconsistencia de estilo

### Inconsistencias en Mayusculas

**Cards: Mayoria en MAYUSCULAS (correcto)**
```powershell
"INFORMACION DEL SISTEMA"      # ✓ Linea 164
"CONFIGURACION INICIAL"        # ✓ Linea 175
"MANTENIMIENTO GENERAL"        # ✓ Linea 603
"PUNTO DE VENTA"               # ✓ Linea 616
"ACCIONES CRITICAS"            # ✓ Linea 640
```

**Botones: Mayoria en Title Case, algunos en MAYUSCULAS**
```powershell
"Crear Usuario del Sistema"       # ✓ Title Case (normal)
"Ver Usuarios Actuales"            # ✓ Title Case (normal)
"REINICIAR PC"                     # ✓ MAYUSCULAS (enfasis critico)
```

**Esto es aceptable - MAYUSCULAS para acciones criticas**

### Inconsistencias en Idioma

**Mezcla de Español e Ingles:**
```powershell
"Setup Adobe Suite"                # ✗ Ingles
# Deberia ser: "Instalar Adobe Suite" o "Configurar Adobe Suite"

"Config Impresora Fiscal"          # ✗ Abreviado
# Deberia ser: "Configurar Impresora Fiscal"

"Config Estacion"                  # ✗ Abreviado + falta acento
# Deberia ser: "Configurar Estacion" o "Configurar Estación"
```

### Inconsistencias en Acentos

**CLAUDE.md recomienda evitar acentos para prevenir problemas UTF-8**
**Pero el codigo actual tiene acentos selectivamente:**

```powershell
# CON acentos (documentacion):
"Diagnóstico Pantalla Login"  # Forma correcta en español

# SIN acentos (codigo real):
"Diagnostico Pantalla Login"   # Linea 506 - Sin acento

# Mensajes tambien sin acentos:
"IMPORTANTE: Todos los scripts se ejecutan en esta maquina"  # Sin acento
"Si necesitas configurar otra PC, ejecuta el dashboard EN esa maquina"  # Sin acento
"ADVERTENCIA: Estas acciones afectaran el sistema"  # Sin acento
```

### Decision Requerida

**Opcion A: Español completo con UTF-8 (RECOMENDADO)**
```powershell
# Guardar Dashboard.ps1 como UTF-8 con BOM
# Usar acentos correctamente:
"Diagnóstico Pantalla Login"
"Configuración de Estación"
"Esta máquina"
```

**Opcion B: Español sin acentos (menos profesional)**
```powershell
# Mantener sin acentos:
"Diagnostico Pantalla Login"
"Configuracion de Estacion"
"Esta maquina"
```

**Opcion C: Ingles completo (cambio mayor)**
```powershell
# Todo en ingles:
"Login Screen Diagnostic"
"Station Configuration"
"This machine"
```

### Solucion Recomendada

**1. Unificar idioma:** Todo en Español
**2. Unificar acentos:** Usar UTF-8 correctamente
**3. No abreviar:** "Config" → "Configurar"

```powershell
# ANTES
"Setup Adobe Suite"           # Ingles
"Config Impresora Fiscal"     # Abreviado
"Diagnostico Pantalla Login"  # Sin acento

# DESPUES
"Configurar Adobe Suite"            # Español completo
"Configurar Impresora Fiscal"       # Sin abreviar
"Diagnóstico de Pantalla de Login"  # Con acentos (UTF-8)
```

**Tiempo estimado:** 1 hora

---

## IN-5: CARACTERES ESPECIALES Y UTF-8

**Ubicacion:** Multiple
**Impacto:** BAJO (Potenciales problemas de encoding)
**Tipo:** Encoding inconsistente

### Problema de Encoding

**CLAUDE.md (linea 250) dice:**
> "Evitar caracteres especiales en placeholders, titulos de botones, mensajes de toast"

**Razon citada:**
> "UniversalDashboard no maneja bien UTF-8 en algunos contextos"

**Pero el codigo TIENE caracteres especiales en mensajes:**
```powershell
# Linea 167
"IMPORTANTE: Todos los scripts se ejecutan en esta maquina"
# Deberia ser: "máquina" (con acento)

# Linea 169
"Si necesitas configurar otra PC, ejecuta el dashboard EN esa maquina"
# Deberia ser: "máquina"

# Linea 642
"ADVERTENCIA: Estas acciones afectaran el sistema inmediatamente"
# Deberia ser: "afectarán"
```

### Contextos Donde Aparecen Caracteres Especiales

**1. Mensajes en cards (New-UDElement)**
- Actualmente SIN acentos
- ¿UniversalDashboard los soporta aqui?

**2. Placeholders de formularios (New-UDInputField)**
- Documentacion dice evitarlos
- Pero algunos podrian funcionar

**3. Titulos de botones (New-UDButton -Text)**
- No hay evidencia de problemas
- Se podrian usar acentos

**4. Mensajes de toast (Show-UDToast -Message)**
- No hay evidencia de problemas
- Se podrian usar acentos

### Prueba Necesaria

**Crear script de prueba:**
```powershell
# Test-UTF8.ps1
Show-UDToast -Message "Prueba con acentos: máquina, configuración, diagnóstico" -Duration 5000
New-UDButton -Text "Configuración con acentos" -OnClick {
    Show-UDToast -Message "¡Funcionó!" -Duration 3000
}
```

**Si funciona:** Usar UTF-8 completo
**Si falla:** Mantener sin acentos

### Solucion Temporal

Mientras se decide, **documentar la razon:**
```powershell
# Nota: Acentos omitidos intencionalmente para compatibilidad UD
# Ver: CLAUDE.md linea 250
$mensajeBienvenida = "Configuracion del sistema"  # Sin acento
```

**Tiempo estimado:** 2 horas (pruebas + implementacion)

---

## RESUMEN DE INCONSISTENCIAS

| ID | Inconsistencia | Ubicacion | Impacto | Tiempo Fix |
|----|----------------|-----------|---------|------------|
| IN-1 | Sistema de colores | Todo el archivo | ALTO | 2h |
| IN-2 | Espaciado | Todo el archivo | MEDIO | 1.5h |
| IN-3 | Organizacion de botones | Dashboard.ps1:175-601 | MEDIO | 3h |
| IN-4 | Nomenclatura | Botones y cards | BAJO | 1h |
| IN-5 | UTF-8 y acentos | Multiple | BAJO | 2h |

**Tiempo total estimado:** 9.5 horas

---

## PRIORIDAD DE CORRECCION

1. **IN-1** - Colores inconsistentes (2h) → **ALTA**
2. **IN-2** - Espaciado inconsistente (1.5h) → **ALTA**
3. **IN-3** - Reorganizar botones (3h) → **MEDIA**
4. **IN-4** - Nomenclatura (1h) → **BAJA**
5. **IN-5** - UTF-8 (2h) → **BAJA**

**Minimo viable:** IN-1 + IN-2 = 3.5 horas
**Completo:** 9.5 horas
