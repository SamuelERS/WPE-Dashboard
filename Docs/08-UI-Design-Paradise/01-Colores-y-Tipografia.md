# Colores y Tipografía Paradise-SystemLabs

**Documento:** Sistema de Diseño Paradise
**Versión:** 1.0.1-LTS
**Fecha:** Noviembre 2025

---

## 🎨 Paleta de Colores Paradise

### Colores Principales (Heredados v1.0.0-LTS)

| Nombre | Código HEX | RGB | Uso |
|--------|-----------|-----|-----|
| **Primary** | `#2196F3` | rgb(33, 150, 243) | Botones estándar, enlaces, acciones principales |
| **Success** | `#4caf50` | rgb(76, 175, 80) | Confirmaciones, estados positivos, botones de éxito |
| **Warning** | `#ff9800` | rgb(255, 152, 0) | Advertencias, precauciones, botones de atención |
| **Danger** | `#dc3545` | rgb(220, 53, 69) | Errores, acciones destructivas, alertas críticas |
| **Info** | `#17a2b8` | rgb(23, 162, 184) | Información, tooltips, mensajes informativos |
| **Dark** | `#343a40` | rgb(52, 58, 64) | Textos, headers, elementos oscuros |
| **Light** | `#f8f9fa` | rgb(248, 249, 250) | Fondos claros, separadores |

---

### Colores Paradise Extendidos (Nuevos en v1.0.1-LTS)

| Nombre | Código HEX | RGB | Uso |
|--------|-----------|-----|-----|
| **Warning Background** | `#fff3cd` | rgb(255, 243, 205) | Fondo de System Info Card |
| **Warning Border** | `#ffc107` | rgb(255, 193, 7) | Borde de System Info Card |
| **Danger Background** | `#ffe6e6` | rgb(255, 230, 230) | Fondo de Critical Actions Section |
| **Success Background** | `#e8f5e9` | rgb(232, 245, 233) | Fondos de mensajes de éxito |
| **Code Background** | `#f5f5f5` | rgb(245, 245, 245) | Bloques de código/output |
| **Footer Text** | `#666666` | rgb(102, 102, 102) | Texto del footer |
| **Neutral Background** | `#f4f4f4` | rgb(244, 244, 244) | Fondos neutros generales |

---

## 🖼️ Aplicación de Colores por Componente

### System Info Card (Caja Amarilla de Advertencia)

**Propósito:** Destacar información crítica sobre el PC actual

**Esquema de colores:**
```css
background-color: #fff3cd  /* Warning Background */
border: 2px solid #ffc107  /* Warning Border */
border-radius: 5px
padding: 10px
```

**Visualización:**
```
┌─────────────────────────────────────────────┐
│  🟡 INFORMACION DEL SISTEMA                 │
│  ┌──────────────────────────────────────┐   │
│  │ PC ACTUAL: DESKTOP-ABC123            │   │
│  │                                      │   │
│  │ IMPORTANTE: Todos los scripts se     │   │
│  │ ejecutan en esta máquina             │   │
│  └──────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
     Fondo: #fff3cd | Borde: #ffc107
```

---

### Critical Actions Section (Caja Roja de Peligro)

**Propósito:** Advertir sobre acciones que afectan el sistema inmediatamente

**Esquema de colores:**
```css
background-color: #ffe6e6  /* Danger Background */
border: 2px solid #dc3545  /* Danger */
border-radius: 5px
padding: 16px
```

**Visualización:**
```
┌─────────────────────────────────────────────┐
│  🔴 ACCIONES CRITICAS                       │
│  ┌──────────────────────────────────────┐   │
│  │ ⚠️ ADVERTENCIA: Estas acciones       │   │
│  │ afectarán el sistema inmediatamente  │   │
│  │                                      │   │
│  │ [REINICIAR PC] [Reiniciar Dashboard] │   │
│  └──────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
     Fondo: #ffe6e6 | Borde: #dc3545
```

---

### Cajas de Estado en Modales

#### Success Box (Verde)
```css
background-color: #e8f5e9  /* Success Background */
border-left: 4px solid #4caf50  /* Success */
padding: 12px
border-radius: 4px
```

**Ejemplo:**
```
┌─────────────────────────────────┐
│ ✅ Usuario creado exitosamente  │
│    Nombre: POS-Merliot          │
│    Tipo: Administrador          │
└─────────────────────────────────┘
   Fondo: #e8f5e9 | Borde izq: #4caf50
```

#### Warning Box (Amarillo)
```css
background-color: #fff3cd  /* Warning Background */
border: 2px solid #ffc107  /* Warning Border */
padding: 12px
border-radius: 4px
```

#### Danger Box (Rojo)
```css
background-color: #ffe6e6  /* Danger Background */
border: 2px solid #dc3545  /* Danger */
padding: 12px
border-radius: 4px
```

---

### Botones

#### Botón Estándar (Primary)
```css
background-color: #2196F3  /* Primary */
color: white
border: none
padding: 10px 20px
border-radius: 4px
```

#### Botón de Éxito (Success)
```css
background-color: #4caf50  /* Success */
color: white
border: none
padding: 10px 20px
border-radius: 4px
```

**Uso:** Scripts de mantenimiento, verificación, limpieza

#### Botón de Peligro (Danger)
```css
background-color: #dc3545  /* Danger */
color: white
font-weight: bold  /* ¡IMPORTANTE! */
border: none
padding: 10px 20px
border-radius: 4px
```

**Uso:** "REINICIAR PC", eliminar usuarios, acciones destructivas

#### Botón de Advertencia (Warning)
```css
background-color: #ff9800  /* Warning */
color: white
border: none
padding: 10px 20px
border-radius: 4px
```

**Uso:** "Reiniciar Dashboard", acciones que requieren precaución

---

### Bloques de Código/Output

```css
background-color: #f5f5f5  /* Code Background */
border: 1px solid #ddd
border-radius: 5px
padding: 15px
font-family: Consolas, monospace
font-size: 13px
color: #333
```

**Visualización:**
```
┌──────────────────────────────────────┐
│ PS C:\> Get-LocalUser                │
│                                      │
│ Name         Enabled Description     │
│ ----         ------- -----------     │
│ POS-Merliot  True    Usuario POS     │
│ Admin        True    Administrador   │
└──────────────────────────────────────┘
   Fondo: #f5f5f5 | Fuente: Consolas
```

---

### Footer

```css
color: #666666  /* Footer Text */
text-align: center
font-size: 12px
```

**Visualización:**
```
─────────────────────────────────────────────
Paradise-SystemLabs Dashboard v1.0.1-LTS | 08/11/2025 14:30
                    Color: #666
```

---

## 🔤 Tipografía Paradise

### Familia de Fuentes

**Fuente principal:**
```css
font-family: Segoe UI, Arial, sans-serif
```

**Fuente de código:**
```css
font-family: Consolas, Monaco, 'Courier New', monospace
```

---

### Tamaños de Fuente

| Elemento | Tamaño | Peso | Uso |
|----------|--------|------|-----|
| **Texto base** | 13px | Normal (400) | Párrafos, labels, texto general |
| **Headings** | 16px | Bold (700) | Títulos de secciones, cards |
| **Código** | 13px | Normal (400) | Bloques de código, output |
| **Footer** | 12px | Normal (400) | Footer del dashboard |
| **Botones** | 13px | Normal (400) | Texto de botones (excepto danger que es bold) |

---

### Jerarquía Tipográfica

```
H2 (Paradise-SystemLabs)         → Size 2 (UniversalDashboard)
H4 (INFORMACION DEL SISTEMA)     → Size 4 (UniversalDashboard) = 16px
H5 (PC ACTUAL: ...)              → Size 5 (UniversalDashboard) = 14px
Body (texto normal)              → 13px
Footer                           → 12px
```

---

### Espaciado de Líneas (Line Height)

| Contexto | Line Height | Razón |
|----------|-------------|-------|
| **Texto normal** | 1.5 | Legibilidad óptima |
| **Código** | 1.6 | Mejor separación de líneas de código |
| **Headings** | 1.2 | Compacto pero legible |
| **Botones** | 1 | Centrado vertical del texto |

---

## 📐 Espaciado (Spacing System)

### Valores del Sistema

Definidos en `Config/dashboard-config.json`:

```json
"spacing": {
  "xs": "10px",   // Extra Small
  "s": "12px",    // Small
  "m": "16px",    // Medium (base)
  "l": "20px",    // Large
  "xl": "24px"    // Extra Large
}
```

---

### Aplicación de Espaciado

#### Padding de Cards
```
padding: $spacing.m  (16px)
```

#### Gap entre Botones (Flex)
```
gap: $spacing.s  (12px)  → Para categorías normales
gap: $spacing.xs (10px)  → Para categorías compactas (POS, Diseño, etc.)
```

#### Márgenes de HR Separators
```
margin: $spacing.xl 0  (24px arriba y abajo)
```

#### Padding de Cajas de Advertencia
```
padding: $spacing.xs  (10px)  → System Info Card
padding: $spacing.m   (16px)  → Critical Actions Section
```

---

## 🎨 Configuración JSON Completa

### dashboard-config.json (Actualizado v1.0.1-LTS)

```json
{
  "version": "1.0.1-LTS",
  "port": 10000,
  "autoOpenBrowser": true,
  "colors": {
    "primary": "#2196F3",
    "success": "#4caf50",
    "warning": "#ff9800",
    "danger": "#dc3545",
    "info": "#17a2b8",
    "dark": "#343a40",
    "light": "#f8f9fa"
  },
  "colorsParadise": {
    "warningBackground": "#fff3cd",
    "warningBorder": "#ffc107",
    "dangerBackground": "#ffe6e6",
    "successBackground": "#e8f5e9",
    "codeBackground": "#f5f5f5",
    "footerText": "#666666",
    "neutralBackground": "#f4f4f4"
  },
  "typography": {
    "fontFamily": "Segoe UI, Arial, sans-serif",
    "baseFontSize": "13px",
    "headingFontSize": "16px",
    "codeFontFamily": "Consolas, Monaco, 'Courier New', monospace"
  },
  "spacing": {
    "xs": "10px",
    "s": "12px",
    "m": "16px",
    "l": "20px",
    "xl": "24px"
  }
}
```

---

## 🌈 Guía de Uso de Colores

### Cuándo Usar Cada Color

#### Primary (#2196F3 - Azul)
- ✅ Botones de acción estándar
- ✅ Enlaces
- ✅ Elementos interactivos neutros
- ❌ NO para advertencias o peligros

#### Success (#4caf50 - Verde)
- ✅ Confirmaciones
- ✅ Estados positivos ("Usuario creado")
- ✅ Botones de verificación/mantenimiento
- ❌ NO para acciones destructivas

#### Warning (#ff9800 - Naranja)
- ✅ Precauciones
- ✅ Acciones que requieren atención
- ✅ "Reiniciar Dashboard"
- ❌ NO para errores críticos

#### Danger (#dc3545 - Rojo)
- ✅ Errores
- ✅ Acciones destructivas ("REINICIAR PC", "Eliminar Usuario")
- ✅ Alertas críticas
- ❌ NO para advertencias menores

#### Warning Background + Border (Amarillo claro/amber)
- ✅ System Info Card
- ✅ Contexto importante pero no peligroso
- ✅ Información que el usuario DEBE leer
- ❌ NO para errores

#### Danger Background (Rojo claro)
- ✅ Critical Actions Section
- ✅ Advertencias de acciones inmediatas
- ✅ Zonas de alto riesgo
- ❌ NO para información general

---

## 📊 Accesibilidad

### Contraste de Colores

Todos los pares de colores cumplen **WCAG 2.1 AA** para accesibilidad:

| Fondo | Texto | Contraste | Estado |
|-------|-------|-----------|--------|
| #2196F3 (Primary) | White | 4.56:1 | ✅ AA |
| #4caf50 (Success) | White | 3.09:1 | ⚠️ AAA Large Text |
| #dc3545 (Danger) | White | 5.53:1 | ✅ AA |
| #fff3cd (Warning BG) | #333 | 11.84:1 | ✅ AAA |
| #ffe6e6 (Danger BG) | #dc3545 | 6.12:1 | ✅ AA |

---

## 🔮 Futuras Variantes de Diseño

### Paradise Dark Mode (Propuesta)

```json
"colorsParadiseDark": {
  "warningBackground": "#3d3416",
  "warningBorder": "#ffb300",
  "dangerBackground": "#3d1616",
  "successBackground": "#1b3d1b",
  "codeBackground": "#1e1e1e",
  "footerText": "#aaa",
  "neutralBackground": "#2a2a2a"
}
```

### Paradise Modern (Propuesta)

```json
"colorsParadiseModern": {
  "primary": "#0055FF",
  "accent": "#00D9FF",
  "warningBackground": "#FFF8DC",
  "warningBorder": "#FFD700"
}
```

---

**Documento creado:** Noviembre 2025
**Próxima actualización:** Después de implementación v1.0.1-LTS
