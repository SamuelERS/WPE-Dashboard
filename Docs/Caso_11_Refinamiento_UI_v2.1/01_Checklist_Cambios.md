# ✅ CHECKLIST DE CAMBIOS - Caso 11

**Paradise-SystemLabs**
**Caso 11 - Refinamiento UI v2.1**
**Fecha:** 2025-11-08
**Basado en:** [Caso 10 - 01_Analisis_Visual_UI.md](../Caso_10_Restauracion_Modular_v2.0/01_Analisis_Visual_UI.md)

---

## 📊 RESUMEN

**Total de issues:** 18
**Archivo principal:** [UI/Dashboard-UI.ps1](../../UI/Dashboard-UI.ps1)
**Estrategia:** Modificaciones quirúrgicas sin afectar funcionalidad

---

## 🔴 PRIORIDAD CRÍTICA (5 issues)

### Issue #1: Header "PC ACTUAL" sin negrita

**Ubicación:** [UI/Dashboard-UI.ps1:56](../../UI/Dashboard-UI.ps1) - Función `New-SystemInfoCard`

**Problema actual:**
```powershell
New-UDHeading -Size 5 -Text "PC ACTUAL: $pcName"
```

**Cambio requerido:**
```powershell
# Opción A: Agregar style inline
New-UDHeading -Size 5 -Text "PC ACTUAL: $pcName" -Style @{ 'font-weight' = 'bold' }

# Opción B: Usar New-UDElement con tag strong
New-UDElement -Tag 'h5' -Attributes @{
    style = @{
        'font-weight' = 'bold'
        'font-size' = '1.5rem'
        'margin' = '0'
    }
} -Content { "PC ACTUAL: $pcName" }
```

**Validación:**
- [ ] Header "PC ACTUAL" se muestra en **negrita**
- [ ] Tamaño de fuente apropiado
- [ ] No hay errores de renderizado

---

### Issue #2: Botones de categorías no centrados

**Ubicación:** [UI/Dashboard-UI.ps1:178-267](../../UI/Dashboard-UI.ps1) - Función `New-CategoryBox`

**Problema actual:**
Botones alineados a la izquierda por defecto

**Cambio requerido:**
```powershell
# En la definición del botón dentro de New-CategoryBox
New-UDButton -Text $buttonText -OnClick $scriptblock -Style @{
    'margin' = '8px auto'  # auto centers horizontally
    'display' = 'block'
    'width' = '80%'        # or specific width
    'background-color' = $colors.azul
    'color' = 'white'
}
```

**Validación:**
- [ ] Todos los botones de categorías están centrados
- [ ] Ancho uniforme (80% o 200px fijo)
- [ ] Espaciado vertical consistente

---

### Issue #3: Colores demasiado saturados

**Ubicación:** [UI/Dashboard-UI.ps1:708+](../../UI/Dashboard-UI.ps1) - Función `Get-ParadiseGlobalCSS`

**Problema actual:**
```powershell
$colors = $Config.colorsParadise
# azul: #2196F3 (demasiado saturado)
```

**Cambio requerido:**
```powershell
# Actualizar color azul en CSS o en dashboard-config.json
# De: #2196F3 (Material Blue 500)
# A:  #1976D2 (Material Blue 700 - menos saturado)

# Si se cambia en CSS:
.ud-button {
    background-color: #1976D2 !important;
}

# O actualizar $colors.azul donde se use
```

**Validación:**
- [ ] Botones azules tienen tono menos saturado
- [ ] Color sigue siendo reconocible como azul
- [ ] Contraste con texto blanco mantiene accesibilidad

---

### Issue #4: Texto "⚠️ Reiniciar PC" sin prominencia

**Ubicación:** [UI/Dashboard-UI.ps1:~400](../../UI/Dashboard-UI.ps1) - Función `New-CriticalActionsCard`

**Problema actual:**
```powershell
New-UDElement -Tag 'p' -Content { "⚠️ Acciones que requieren confirmación" }
```

**Cambio requerido:**
```powershell
New-UDElement -Tag 'p' -Attributes @{
    style = @{
        'font-weight' = 'bold'
        'font-size' = '1.1rem'
        'color' = '#d32f2f'  # Rojo más oscuro
        'text-align' = 'center'
        'margin' = '12px 0'
    }
} -Content { "⚠️ Acciones que requieren confirmación" }
```

**Validación:**
- [ ] Texto de advertencia en **negrita**
- [ ] Color rojo destacado
- [ ] Centrado correctamente

---

### Issue #5: Botones críticos demasiado pequeños

**Ubicación:** [UI/Dashboard-UI.ps1:~420](../../UI/Dashboard-UI.ps1) - Dentro de `New-CriticalActionsCard`

**Problema actual:**
```powershell
New-UDButton -Text "Reiniciar PC" -OnClick {...}
# Sin estilos específicos, usa tamaño por defecto
```

**Cambio requerido:**
```powershell
New-UDButton -Text "Reiniciar PC" -OnClick {...} -Style @{
    'width' = '180px'          # Ancho fijo más grande
    'height' = '48px'          # Altura aumentada
    'font-size' = '1.1rem'     # Texto más grande
    'font-weight' = 'bold'
    'margin' = '8px auto'
    'display' = 'block'
}
```

**Validación:**
- [ ] Botones críticos son visiblemente más grandes
- [ ] Fácil de clickear
- [ ] Mantienen alineación centrada

---

## 🟡 PRIORIDAD MEDIA (8 issues)

### Issue #6: Espaciado inconsistente entre secciones

**Ubicación:** [UI/Dashboard-UI.ps1](../../UI/Dashboard-UI.ps1) - Función `New-SectionSeparator`

**Problema actual:**
```powershell
New-UDElement -Tag 'hr' -Attributes @{
    style = @{ 'margin' = '20px 0' }  # Variable en diferentes partes
}
```

**Cambio requerido:**
```powershell
# Estandarizar a 16px vertical
New-UDElement -Tag 'hr' -Attributes @{
    style = @{
        'margin' = '16px 0'      # Consistente
        'border' = 'none'
        'border-top' = "2px solid $($colors.amarillo)"
    }
}
```

**Validación:**
- [ ] Todos los separadores tienen 16px de margen vertical
- [ ] Espaciado uniforme en toda la interfaz

---

### Issue #7: Padding de cards variable

**Ubicación:** [UI/Dashboard-UI.ps1](../../UI/Dashboard-UI.ps1) - Múltiples funciones con `New-UDCard`

**Problema actual:**
```powershell
# Diferentes valores de padding en diferentes cards
New-UDCard -Content {...}  # Padding por defecto
```

**Cambio requerido:**
```powershell
# Estandarizar padding en todas las cards
New-UDCard -Content {...} -Style @{
    'padding' = '16px'        # Consistente
    'margin' = '12px 0'
}
```

**Validación:**
- [ ] Todas las cards tienen 16px de padding interno
- [ ] Margen vertical de 12px entre cards

---

### Issue #8: Títulos de categorías sin negrita

**Ubicación:** [UI/Dashboard-UI.ps1:~190](../../UI/Dashboard-UI.ps1) - Dentro de `New-CategoryBox`

**Problema actual:**
```powershell
New-UDHeading -Size 4 -Text $categoryName
```

**Cambio requerido:**
```powershell
New-UDHeading -Size 4 -Text $categoryName -Style @{
    'font-weight' = 'bold'
    'margin-bottom' = '12px'
    'text-align' = 'center'
}
```

**Validación:**
- [ ] Títulos de categorías (POS, Mantenimiento, etc.) en **negrita**
- [ ] Centrados correctamente

---

### Issue #9: Ancho de botones inconsistente

**Ubicación:** [UI/Dashboard-UI.ps1](../../UI/Dashboard-UI.ps1) - Funciones `New-ActionButton` y `New-CategoryBox`

**Problema actual:**
```powershell
# Botones con anchos variables
New-UDButton -Text "..." -OnClick {...}
```

**Cambio requerido:**
```powershell
# Opción A: Ancho relativo
New-UDButton -Text "..." -OnClick {...} -Style @{
    'width' = '80%'
    'max-width' = '300px'
    'margin' = '8px auto'
    'display' = 'block'
}

# Opción B: Ancho fijo
New-UDButton -Text "..." -OnClick {...} -Style @{
    'width' = '220px'
    'margin' = '8px auto'
    'display' = 'block'
}
```

**Validación:**
- [ ] Todos los botones tienen mismo ancho
- [ ] Se ven uniformes visualmente

---

### Issue #10: Falta de jerarquía visual en textos

**Ubicación:** [UI/Dashboard-UI.ps1](../../UI/Dashboard-UI.ps1) - Múltiples funciones

**Cambio requerido:**
```powershell
# Headers principales (h3)
New-UDHeading -Size 3 -Text "..." -Style @{
    'font-size' = '1.75rem'
    'font-weight' = 'bold'
    'margin' = '16px 0 12px 0'
}

# Headers secundarios (h4)
New-UDHeading -Size 4 -Text "..." -Style @{
    'font-size' = '1.5rem'
    'font-weight' = '600'
    'margin' = '12px 0 8px 0'
}

# Headers terciarios (h5)
New-UDHeading -Size 5 -Text "..." -Style @{
    'font-size' = '1.25rem'
    'font-weight' = '600'
    'margin' = '8px 0'
}
```

**Validación:**
- [ ] Jerarquía visual clara (H3 > H4 > H5)
- [ ] Tamaños de fuente coherentes

---

### Issue #11: Colores de advertencia poco efectivos

**Ubicación:** [UI/Dashboard-UI.ps1](../../UI/Dashboard-UI.ps1) - Función `New-WarningBox` y `New-DangerBox`

**Problema actual:**
```powershell
# Warning box con color muy claro
$warningColor = "#fff3cd"
```

**Cambio requerido:**
```powershell
# Warning box con mejor contraste
New-UDElement -Tag 'div' -Attributes @{
    style = @{
        'background-color' = '#fff3cd'
        'border-left' = '4px solid #ff9800'  # Borde naranja más visible
        'padding' = '16px'
        'margin' = '12px 0'
    }
}

# Danger box con borde más prominente
New-UDElement -Tag 'div' -Attributes @{
    style = @{
        'background-color' = '#ffebee'
        'border-left' = '4px solid #d32f2f'  # Borde rojo más oscuro
        'padding' = '16px'
        'margin' = '12px 0'
    }
}
```

**Validación:**
- [ ] Warning boxes tienen borde naranja visible
- [ ] Danger boxes tienen borde rojo prominente

---

### Issue #12: Sombras inexistentes en elementos elevados

**Ubicación:** [UI/Dashboard-UI.ps1](../../UI/Dashboard-UI.ps1) - Cards y botones

**Cambio requerido:**
```powershell
# Cards con sombra sutil
New-UDCard -Content {...} -Style @{
    'box-shadow' = '0 2px 4px rgba(0,0,0,0.1)'
    'padding' = '16px'
}

# Botones con hover effect (si UD soporta)
New-UDButton -Text "..." -OnClick {...} -Style @{
    'box-shadow' = '0 2px 4px rgba(0,0,0,0.15)'
    'transition' = 'all 0.3s ease'
}
```

**Validación:**
- [ ] Cards tienen sombra sutil
- [ ] Elementos se ven "elevados" del fondo

---

### Issue #13: Espaciado horizontal no uniform

**Ubicación:** [UI/Dashboard-UI.ps1](../../UI/Dashboard-UI.ps1) - Todas las funciones

**Cambio requerido:**
```powershell
# Estandarizar padding horizontal
New-UDElement -Tag 'div' -Attributes @{
    style = @{
        'padding' = '16px 24px'  # 16px vertical, 24px horizontal
    }
}

# Para contenedores principales
New-UDColumn -Content {...} -Size 12 -Style @{
    'padding' = '0 24px'
}
```

**Validación:**
- [ ] Padding horizontal de 24px en todos los contenedores principales
- [ ] Consistencia visual en márgenes laterales

---

## 🟢 PRIORIDAD BAJA (5 issues)

### Issue #14: Footer demasiado pequeño

**Ubicación:** [UI/Dashboard-UI.ps1:574-600](../../UI/Dashboard-UI.ps1) - Función `New-DashboardFooter`

**Problema actual:**
```powershell
New-UDElement -Tag 'footer' -Content {...}
# Sin estilos específicos
```

**Cambio requerido:**
```powershell
New-UDElement -Tag 'footer' -Attributes @{
    style = @{
        'padding' = '24px 24px'      # Aumentar padding
        'font-size' = '0.95rem'       # Aumentar tamaño de fuente
        'text-align' = 'center'
        'margin-top' = '32px'
        'border-top' = "2px solid $($colors.amarillo)"
    }
} -Content {...}
```

**Validación:**
- [ ] Footer más grande y legible
- [ ] Separador visual claro con el contenido

---

### Issue #15: Sin separador visual antes del footer

**Ubicación:** Justo antes del footer en [UI/Dashboard-UI.ps1](../../UI/Dashboard-UI.ps1)

**Cambio requerido:**
```powershell
# Antes del footer, agregar separador
New-SectionSeparator -Config $Config
New-DashboardFooter -Config $Config
```

**Validación:**
- [ ] Línea separadora visible antes del footer
- [ ] Transición visual clara

---

### Issue #16: Iconos sin espaciado con texto

**Ubicación:** [UI/Dashboard-UI.ps1](../../UI/Dashboard-UI.ps1) - Donde se usan emojis/iconos

**Cambio requerido:**
```powershell
# En lugar de:
New-UDElement -Tag 'span' -Content { "⚠️Advertencia" }

# Usar:
New-UDElement -Tag 'span' -Content { "⚠️ Advertencia" }
# Agregar espacio después del emoji
```

**Validación:**
- [ ] Emojis tienen espacio con el texto siguiente
- [ ] Lectura más cómoda

---

### Issue #17: Tooltips inexistentes

**Ubicación:** [UI/Dashboard-UI.ps1](../../UI/Dashboard-UI.ps1) - Botones críticos

**Cambio requerido:**
```powershell
# Agregar tooltips a botones críticos (si UD soporta)
New-UDButton -Text "Reiniciar PC" -OnClick {...} -Title "Reinicia el equipo (requiere confirmación)"
```

**Validación:**
- [ ] Tooltips informativos en botones críticos
- [ ] Ayuda contextual al pasar mouse (si funciona)

---

### Issue #18: Responsive inexistente

**Ubicación:** [UI/Dashboard-UI.ps1](../../UI/Dashboard-UI.ps1) - Layout general

**Nota:** UniversalDashboard Community v2.9.0 tiene soporte limitado para responsive design.

**Cambio requerido (limitado):**
```powershell
# Usar New-UDLayout con columnas adaptativas
New-UDLayout -Columns 2 -Content {
    # Contenido se distribuye en 2 columnas
    # En pantallas pequeñas puede colapsar a 1 columna (comportamiento de UD)
}

# Usar max-width en elementos
New-UDElement -Tag 'div' -Attributes @{
    style = @{
        'max-width' = '1200px'
        'margin' = '0 auto'
    }
}
```

**Validación:**
- [ ] Dashboard tiene ancho máximo de 1200px
- [ ] Centrado en pantallas grandes
- [ ] (Opcional) Test en diferentes resoluciones

---

## 📊 PROGRESO

**Estado actual:** 0/18 issues resueltos (0%)

**Por prioridad:**
- Crítica: 0/5 (0%)
- Media: 0/8 (0%)
- Baja: 0/5 (0%)

---

## 🎯 ORDEN DE EJECUCIÓN RECOMENDADO

### Ronda 1: Issues Críticos (2 horas)

1. [ ] Issue #1 - Header PC ACTUAL en negrita
2. [ ] Issue #2 - Centrar botones de categorías
3. [ ] Issue #3 - Reducir saturación de colores
4. [ ] Issue #4 - Prominencia de texto de advertencia
5. [ ] Issue #5 - Aumentar tamaño de botones críticos

**Checkpoint:** Ejecutar tests, validar visualmente, commit

### Ronda 2: Issues Media (3 horas)

6. [ ] Issue #6 - Espaciado consistente entre secciones
7. [ ] Issue #7 - Padding uniforme en cards
8. [ ] Issue #8 - Títulos de categorías en negrita
9. [ ] Issue #9 - Ancho consistente de botones
10. [ ] Issue #10 - Jerarquía visual de textos
11. [ ] Issue #11 - Mejorar colores de advertencia
12. [ ] Issue #12 - Agregar sombras sutiles
13. [ ] Issue #13 - Espaciado horizontal uniforme

**Checkpoint:** Ejecutar tests, validar visualmente, commit

### Ronda 3: Issues Baja (1.5 horas)

14. [ ] Issue #14 - Footer más grande
15. [ ] Issue #15 - Separador antes del footer
16. [ ] Issue #16 - Espaciado con iconos
17. [ ] Issue #17 - Tooltips (si UD soporta)
18. [ ] Issue #18 - Mejoras responsive (limitado)

**Checkpoint final:** Tests completos, documentación, entrega

---

## ✅ VALIDACIÓN FINAL

Después de resolver todos los issues:

- [ ] **Tests funcionales:** 33/33 pasados (100%)
- [ ] **Dashboard inicia:** Sin errores, < 2s
- [ ] **Validación visual:** Todas las secciones revisadas
- [ ] **Comparativa:** Screenshots antes/después documentados
- [ ] **Performance:** Tiempo de startup mantenido
- [ ] **Checklist:** 18/18 issues marcados como resueltos

---

**FIN DEL CHECKLIST**

**Paradise-SystemLabs © 2025**

**Caso 11 - Refinamiento UI v2.1**
