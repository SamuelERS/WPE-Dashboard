# Guia de Estilos y Directrices - Dashboard Paradise-SystemLabs

## Introduccion

Este documento define el sistema de diseno completo para el dashboard, incluyendo colores, tipografia, espaciado, componentes y directrices de uso. Todos los desarrolladores deben seguir estas reglas para mantener consistencia.

## Sistema de Colores

### Paleta Principal

```powershell
# Definir al inicio del script Dashboard.ps1
$Colors = @{
    # Colores de Accion
    Primary     = "#2196F3"    # Azul - Acciones principales
    Success     = "#4caf50"    # Verde - Confirmaciones/Exito
    Warning     = "#ff9800"    # Naranja - Advertencias
    Danger      = "#dc3545"    # Rojo - Acciones criticas/destructivas
    Info        = "#17a2b8"    # Cyan - Informacion
    Secondary   = "#6c757d"    # Gris - Acciones secundarias
    
    # Colores de Fondo
    BgWarning   = "#fff3cd"    # Amarillo claro
    BgDanger    = "#ffe6e6"    # Rojo claro
    BgSuccess   = "#e8f5e9"    # Verde claro
    BgInfo      = "#e3f2fd"    # Azul claro
    BgLight     = "#f5f5f5"    # Gris muy claro
    
    # Colores de Borde
    BorderWarning = "#ffc107"  # Amarillo
    BorderDanger  = "#dc3545"  # Rojo
    BorderInfo    = "#2196F3"  # Azul
    BorderLight   = "#dee2e6"  # Gris claro
    
    # Colores de Texto
    TextPrimary   = "#212529"  # Negro casi puro
    TextSecondary = "#6c757d"  # Gris
    TextLight     = "#ffffff"  # Blanco
    TextMuted     = "#999999"  # Gris claro
}
```

### Uso de Colores por Tipo de Accion

#### Botones Primarios (Azul #2196F3)
**Cuando usar:**
- Acciones principales del sistema
- Funciones de creacion/configuracion
- Acciones frecuentes

**Ejemplos:**
- Crear Usuario
- Ver Usuarios
- Configurar Biometria
- Instalar Software Base
- Ver Logs

**Codigo:**
```powershell
New-UDButton -Text "Crear Usuario" -OnClick {...} -Style @{
    'background-color' = $Colors.Primary
    'color' = $Colors.TextLight
}
```

#### Botones de Exito (Verde #4caf50)
**Cuando usar:**
- Confirmaciones
- Acciones completadas
- Reparaciones/Optimizaciones

**Ejemplos:**
- Reparar Usuarios (podria ser verde en lugar de naranja)
- Optimizar Rendimiento
- Verificar Sistema

**Codigo:**
```powershell
New-UDButton -Text "Optimizar Sistema" -OnClick {...} -Style @{
    'background-color' = $Colors.Success
    'color' = $Colors.TextLight
}
```

#### Botones de Advertencia (Naranja #ff9800)
**Cuando usar:**
- Acciones que requieren atencion
- Diagnosticos
- Reinicios/Cambios importantes

**Ejemplos:**
- Reiniciar Dashboard
- Diagnostico Login
- Reparar Usuarios

**Codigo:**
```powershell
New-UDButton -Text "Reiniciar Dashboard" -OnClick {...} -Style @{
    'background-color' = $Colors.Warning
    'color' = $Colors.TextLight
}
```

#### Botones de Peligro (Rojo #dc3545)
**Cuando usar:**
- Acciones destructivas
- Eliminaciones
- Reinicios del sistema

**Ejemplos:**
- REINICIAR PC
- Eliminar Usuarios

**Codigo:**
```powershell
New-UDButton -Text "REINICIAR PC" -OnClick {...} -Style @{
    'background-color' = $Colors.Danger
    'color' = $Colors.TextLight
    'font-weight' = 'bold'
}
```

#### Botones Secundarios (Default/Sin color)
**Cuando usar:**
- Funciones especializadas
- Acciones menos frecuentes
- Herramientas especificas

**Ejemplos:**
- Setup Adobe Suite
- Config Impresora Fiscal
- Calibrar Monitor

**Codigo:**
```powershell
New-UDButton -Text "Setup Adobe Suite" -OnClick {...}
# Sin estilo personalizado - usa default de UniversalDashboard
```

### Colores de Cards

#### Card de Informacion (Amarillo)
```powershell
New-UDCard -Title "INFORMACION DEL SISTEMA" -Content {
    New-UDElement -Tag 'div' -Attributes @{
        style=@{
            'padding'='16px'
            'background-color'=$Colors.BgWarning
            'border'="2px solid $($Colors.BorderWarning)"
            'border-radius'='5px'
        }
    } -Content {...}
}
```

#### Card de Zona Critica (Rojo)
```powershell
New-UDCard -Title "ACCIONES CRITICAS" -Content {
    New-UDElement -Tag 'div' -Attributes @{
        style=@{
            'padding'='16px'
            'background-color'=$Colors.BgDanger
            'border'="2px solid $($Colors.BorderDanger)"
            'border-radius'='5px'
        }
    } -Content {...}
}
```

#### Card Normal (Sin color especial)
```powershell
New-UDCard -Title "MANTENIMIENTO" -Content {
    # Sin fondo especial - usa default
}
```

## Sistema de Espaciado

### Variables de Espaciado

```powershell
# Definir al inicio del script
$Spacing = @{
    XS = "4px"   # Extra pequeno - separacion minima
    S  = "8px"   # Pequeno - gap entre elementos relacionados
    M  = "12px"  # Medio - gap entre botones
    L  = "16px"  # Grande - padding de cards
    XL = "24px"  # Extra grande - margin entre secciones
    XXL = "32px" # Doble extra grande - separadores principales
}
```

### Reglas de Espaciado

#### Gap entre Botones
```powershell
# Usar $Spacing.M (12px)
New-UDElement -Tag 'div' -Attributes @{
    style=@{
        'display'='flex'
        'flex-direction'='column'
        'gap'=$Spacing.M  # 12px entre botones
    }
}
```

#### Padding de Cards
```powershell
# Usar $Spacing.L (16px)
New-UDElement -Tag 'div' -Attributes @{
    style=@{
        'padding'=$Spacing.L  # 16px de padding interno
    }
}
```

#### Margin entre Secciones
```powershell
# Usar $Spacing.XL (24px)
New-UDElement -Tag 'div' -Attributes @{
    style=@{
        'margin-bottom'=$Spacing.XL  # 24px entre secciones
    }
}
```

#### Gap entre Columnas de Grid
```powershell
# UniversalDashboard maneja esto automaticamente
# Pero si usamos flex manual, usar $Spacing.L (16px)
```

## Sistema de Tipografia

### Jerarquia de Headings

```powershell
# H1 - Titulo Principal (Solo uno por pagina)
New-UDHeading -Text "Paradise-SystemLabs" -Size 2

# H2 - Titulos de Seccion Principal (Opcional, si necesitamos agrupar)
New-UDHeading -Text "CONFIGURACION" -Size 3

# H3 - Titulos de Card (Usar -Title en New-UDCard)
New-UDCard -Title "SISTEMA" -Content {...}

# H4 - Subtitulos dentro de Cards
New-UDHeading -Text "PC ACTUAL: $env:COMPUTERNAME" -Size 5

# Texto Normal
New-UDElement -Tag 'p' -Content {"Texto descriptivo"}
```

### Reglas de Tipografia

1. **Titulo Principal**: Solo usar `Size 2` para el header principal
2. **Titulos de Card**: Siempre usar `-Title` en `New-UDCard`, no headings manuales
3. **Subtitulos**: Usar `Size 5` para informacion destacada dentro de cards
4. **Texto Normal**: Usar `New-UDElement -Tag 'p'` para parrafos

### Formato de Texto

```powershell
# Texto en Negrita (para advertencias)
New-UDElement -Tag 'strong' -Content {"ADVERTENCIA"}

# Texto en Cursiva (raramente usado)
New-UDElement -Tag 'em' -Content {"Nota importante"}

# Texto Preformateado (para logs/codigo)
New-UDElement -Tag 'pre' -Attributes @{
    style=@{
        'background-color'=$Colors.BgLight
        'padding'='15px'
        'border-radius'='5px'
        'font-family'='Consolas, monospace'
        'font-size'='12px'
        'overflow-x'='auto'
    }
} -Content {$textoPreformateado}
```

## Componentes de Botones

### Anatomia de un Boton

```powershell
New-UDButton -Text "Texto del Boton" -OnClick {
    # Logica del boton
} -Style @{
    'background-color' = $Colors.Primary
    'color' = $Colors.TextLight
    'width' = '100%'  # Opcional: ancho completo
    'font-weight' = 'bold'  # Opcional: para botones criticos
}
```

### Tamanos de Botones

#### Boton de Ancho Completo (Default)
```powershell
# No especificar width, o usar 100%
New-UDButton -Text "Boton Completo" -OnClick {...}
```

#### Boton de Ancho Fijo
```powershell
# Usar solo si es necesario
New-UDButton -Text "Boton Fijo" -OnClick {...} -Style @{
    'width' = '200px'
}
```

### Estados de Botones

UniversalDashboard maneja automaticamente:
- **Hover**: Oscurece el color ligeramente
- **Active**: Oscurece mas al hacer click
- **Disabled**: Gris claro (usar `-Disabled $true`)

```powershell
# Boton deshabilitado
New-UDButton -Text "No Disponible" -OnClick {...} -Disabled $true
```

## Componentes de Cards

### Anatomia de una Card

```powershell
New-UDCard -Title "TITULO DE LA CARD" -Content {
    New-UDElement -Tag 'div' -Attributes @{
        style=@{
            'padding'=$Spacing.L
            'display'='flex'
            'flex-direction'='column'
            'gap'=$Spacing.M
        }
    } -Content {
        # Contenido de la card
    }
}
```

### Tipos de Cards

#### Card Simple (Solo Botones)
```powershell
New-UDCard -Title "MANTENIMIENTO" -Content {
    New-UDLayout -Columns 2 -Content {
        New-UDButton -Text "Boton 1" -OnClick {...}
        New-UDButton -Text "Boton 2" -OnClick {...}
    }
}
```

#### Card con Informacion y Botones
```powershell
New-UDCard -Title "SISTEMA" -Content {
    New-UDElement -Tag 'div' -Attributes @{
        style=@{'padding'=$Spacing.L}
    } -Content {
        New-UDElement -Tag 'p' -Content {"Informacion descriptiva"}
        New-UDElement -Tag 'div' -Attributes @{
            style=@{
                'display'='flex'
                'flex-direction'='column'
                'gap'=$Spacing.M
                'margin-top'=$Spacing.M
            }
        } -Content {
            New-UDButton -Text "Accion 1" -OnClick {...}
            New-UDButton -Text "Accion 2" -OnClick {...}
        }
    }
}
```

#### Card de Advertencia
```powershell
New-UDCard -Title "ADVERTENCIA" -Content {
    New-UDElement -Tag 'div' -Attributes @{
        style=@{
            'padding'=$Spacing.L
            'background-color'=$Colors.BgWarning
            'border'="2px solid $($Colors.BorderWarning)"
            'border-radius'='5px'
        }
    } -Content {
        New-UDElement -Tag 'p' -Content {"Mensaje de advertencia"}
    }
}
```

## Sistema de Grid

### Reglas de Grid

1. **3 Columnas**: Para acciones rapidas o areas especializadas (3 items)
2. **2 Columnas**: Para configuracion (2 grupos grandes)
3. **1 Columna**: Para informacion o zona critica

### Patron de Grid

```powershell
# Grid de 3 columnas
New-UDLayout -Columns 3 -Content {
    # Card 1
    New-UDCard -Title "TITULO 1" -Content {...}
    # Card 2
    New-UDCard -Title "TITULO 2" -Content {...}
    # Card 3
    New-UDCard -Title "TITULO 3" -Content {...}
}

# Grid de 2 columnas
New-UDLayout -Columns 2 -Content {
    # Card 1
    New-UDCard -Title "TITULO 1" -Content {...}
    # Card 2
    New-UDCard -Title "TITULO 2" -Content {...}
}

# Grid de 1 columna (no necesita Layout)
New-UDCard -Title "TITULO" -Content {...}
```

## Directrices de Uso

### Como Agregar un Nuevo Boton

#### Paso 1: Determinar el Tipo de Accion
- **Primaria**: Crear, Ver, Configurar
- **Exito**: Reparar, Optimizar, Verificar
- **Advertencia**: Reiniciar, Diagnosticar
- **Peligro**: Eliminar, Reiniciar PC
- **Secundaria**: Funciones especializadas

#### Paso 2: Elegir la Seccion Correcta
- **Acciones Rapidas**: Solo las 3 mas usadas
- **Configuracion del Sistema**: Configuracion general
- **Mantenimiento**: Herramientas de mantenimiento
- **Areas Especializadas**: POS, Diseno, Atencion
- **Zona Critica**: Solo acciones destructivas

#### Paso 3: Usar el Patron Correcto
```powershell
# Determinar color
$buttonColor = $Colors.Primary  # o Warning, Danger, etc.

# Crear boton
New-UDButton -Text "Nombre Descriptivo" -OnClick {
    # Paso 1: Mostrar toast de inicio
    Show-UDToast -Message "Iniciando accion..." -Duration 2000
    
    # Paso 2: Ejecutar logica
    try {
        # Tu codigo aqui
        
        # Paso 3: Log exitoso
        Write-DashboardLog -Accion "Nombre Accion" -Resultado "Exitoso"
        
        # Paso 4: Toast de exito
        Show-UDToast -Message "Accion completada" -Duration 3000 -BackgroundColor $Colors.Success
    } catch {
        # Log de error
        Write-DashboardLog -Accion "Nombre Accion" -Resultado "Error: $_"
        
        # Toast de error
        Show-UDToast -Message "Error: $_" -Duration 5000 -BackgroundColor $Colors.Danger
    }
} -Style @{
    'background-color' = $buttonColor
    'color' = $Colors.TextLight
}
```

### Como Agregar una Nueva Seccion

#### Paso 1: Decidir el Layout
- 1 columna: Informacion o zona critica
- 2 columnas: Dos grupos de funciones
- 3 columnas: Tres areas especializadas

#### Paso 2: Crear la Estructura
```powershell
# Separador visual
New-UDElement -Tag 'hr'

# Layout con grid
New-UDLayout -Columns 2 -Content {
    # Card 1
    New-UDCard -Title "GRUPO 1" -Content {
        New-UDElement -Tag 'div' -Attributes @{
            style=@{
                'display'='flex'
                'flex-direction'='column'
                'gap'=$Spacing.M
                'padding'=$Spacing.L
            }
        } -Content {
            # Botones aqui
        }
    }
    
    # Card 2
    New-UDCard -Title "GRUPO 2" -Content {
        New-UDElement -Tag 'div' -Attributes @{
            style=@{
                'display'='flex'
                'flex-direction'='column'
                'gap'=$Spacing.M
                'padding'=$Spacing.L
            }
        } -Content {
            # Botones aqui
        }
    }
}
```

### Reglas de Nomenclatura

#### Titulos de Cards
- **MAYUSCULAS**: Para titulos de cards
- **Descriptivo**: Maximo 3 palabras
- **Consistente**: Usar mismo patron

**Ejemplos:**
- ✅ "CONFIGURACION DEL SISTEMA"
- ✅ "MANTENIMIENTO GENERAL"
- ✅ "PUNTO DE VENTA"
- ❌ "configuracion" (minusculas)
- ❌ "Config" (abreviado)

#### Texto de Botones
- **Capitalize**: Primera letra mayuscula
- **Verbo + Objeto**: Accion clara
- **Conciso**: Maximo 4 palabras

**Ejemplos:**
- ✅ "Crear Usuario"
- ✅ "Ver Logs"
- ✅ "Configurar Biometria"
- ❌ "crear usuario" (minusculas)
- ❌ "Usuario" (sin verbo)
- ❌ "Configurar el Sistema de Biometria Completo" (muy largo)

## Restricciones Tecnicas

### NO Usar
- ❌ Emojis o caracteres especiales (pueden romper PowerShell)
- ❌ Comillas dobles dentro de strings (usar comillas simples)
- ❌ Estilos CSS complejos (UniversalDashboard tiene limitaciones)
- ❌ JavaScript personalizado (no es necesario)

### SI Usar
- ✅ Caracteres ASCII basicos
- ✅ Comillas simples para strings
- ✅ Estilos inline simples
- ✅ Componentes nativos de UniversalDashboard

### Compatibilidad
- Windows 10/11
- PowerShell 5.1+
- UniversalDashboard.Community
- Navegadores modernos (Chrome, Edge, Firefox)

## Checklist de Calidad

Antes de agregar/modificar codigo, verificar:

- [ ] Colores correctos segun tipo de accion
- [ ] Espaciado consistente ($Spacing.M, $Spacing.L, etc.)
- [ ] Titulo de card en MAYUSCULAS
- [ ] Texto de boton con Capitalize
- [ ] Logging implementado (Write-DashboardLog)
- [ ] Toast messages para feedback
- [ ] Manejo de errores con try/catch
- [ ] Sin caracteres especiales o emojis
- [ ] Codigo indentado correctamente
- [ ] Comentarios donde sea necesario

## Ejemplos Completos

### Ejemplo 1: Seccion Simple con 4 Botones

```powershell
New-UDCard -Title "MANTENIMIENTO GENERAL" -Content {
    New-UDLayout -Columns 2 -Content {
        New-UDButton -Text "Windows Update" -OnClick {
            Show-UDToast -Message "Verificando actualizaciones..." -Duration 2000
            Write-DashboardLog -Accion "Windows Update" -Resultado "Iniciado"
        }
        
        New-UDButton -Text "Limpieza de Disco" -OnClick {
            Show-UDToast -Message "Limpiando disco..." -Duration 2000
            Write-DashboardLog -Accion "Limpieza Disco" -Resultado "Iniciado"
        }
        
        New-UDButton -Text "Verificar Sistema" -OnClick {
            Show-UDToast -Message "Verificando..." -Duration 2000
            Write-DashboardLog -Accion "Verificar Sistema" -Resultado "Iniciado"
        } -Style @{
            'background-color' = $Colors.Success
            'color' = $Colors.TextLight
        }
        
        New-UDButton -Text "Optimizar Rendimiento" -OnClick {
            Show-UDToast -Message "Optimizando..." -Duration 2000
            Write-DashboardLog -Accion "Optimizar" -Resultado "Iniciado"
        } -Style @{
            'background-color' = $Colors.Success
            'color' = $Colors.TextLight
        }
    }
}
```

### Ejemplo 2: Card con Advertencia y Boton Critico

```powershell
New-UDCard -Title "ACCIONES CRITICAS" -Content {
    New-UDElement -Tag 'div' -Attributes @{
        style=@{
            'padding'=$Spacing.L
            'background-color'=$Colors.BgDanger
            'border'="2px solid $($Colors.BorderDanger)"
            'border-radius'='5px'
        }
    } -Content {
        New-UDElement -Tag 'p' -Content {
            "ADVERTENCIA: Estas acciones afectaran el sistema inmediatamente"
        }
        
        New-UDElement -Tag 'div' -Attributes @{
            style=@{
                'margin-top'=$Spacing.M
                'display'='flex'
                'gap'=$Spacing.M
            }
        } -Content {
            New-UDButton -Text "REINICIAR PC" -OnClick {
                Show-UDToast -Message "Reiniciando el equipo en 10 segundos..." -Duration 10000 -BackgroundColor $Colors.Warning
                Write-DashboardLog -Accion "Reiniciar PC" -Resultado "Solicitado"
                Start-Sleep -Seconds 3
                Restart-Computer -Force
            } -Style @{
                'background-color' = $Colors.Danger
                'color' = $Colors.TextLight
                'font-weight' = 'bold'
            }
        }
    }
}
```

---

**Version:** 1.0  
**Ultima Actualizacion:** 06 de Noviembre, 2025  
**Mantenedor:** Equipo Paradise-SystemLabs
