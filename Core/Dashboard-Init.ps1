# ============================================
# DASHBOARD INIT - INICIALIZACION v1.0.1-LTS
# ============================================
# Version: 1.0.1-LTS (v1.0.1-LTS-Hybrid)
# Arquitectura: v1.0.1 (dot-sourcing) - Coexiste con v2.0
# Propósito: Inicializar dashboard con validaciones y carga de módulos
# Estado: FUNCIONAL - Preservado en arquitectura híbrida
# Fecha: 2025-11-08
# Caso: 10 - Restauración Modular v2.0

<#
.SYNOPSIS
    Inicializador del dashboard v1.0.1-LTS

.DESCRIPTION
    Maneja toda la inicialización del dashboard:
    - Validación de JSON
    - Carga de configuración desde dashboard-config.json
    - Verificación de módulos UniversalDashboard
    - Importación de utilidades

    Parte de la arquitectura híbrida v1.0.1-LTS + v2.0

.NOTES
    Version: 1.0.1-LTS
    Arquitectura: v1.0.1 (preservado)
    Este módulo debe cargarse primero (dot-sourcing)
    Estado: FUNCIONAL - Coexiste con v2.0
    Funciones: 4 (Initialize-DashboardConfig, Get-DashboardColors,
               Get-CategoriesConfig, Initialize-UniversalDashboard)
#>

# ============================================
# FUNCIONES DE VALIDACION
# ============================================

function Test-JsonConfig {
    <#
    .SYNOPSIS
        Valida un archivo JSON
    
    .PARAMETER Path
        Ruta al archivo JSON
    
    .PARAMETER Name
        Nombre descriptivo del archivo
    
    .OUTPUTS
        Objeto JSON si es valido, $false si no
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,
        
        [Parameter(Mandatory=$true)]
        [string]$Name
    )
    
    if (-not (Test-Path $Path)) {
        Write-Host "[ERROR] Archivo de configuracion no encontrado: $Name" -ForegroundColor Red
        Write-Host "  Ruta esperada: $Path" -ForegroundColor Gray
        return $false
    }
    
    try {
        $content = Get-Content $Path -Raw -ErrorAction Stop
        $json = $content | ConvertFrom-Json -ErrorAction Stop
        return $json
    } catch {
        Write-Host "[ERROR] JSON invalido en $Name" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Gray
        Write-Host "  Linea: $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Gray
        return $false
    }
}

function Initialize-DashboardConfig {
    <#
    .SYNOPSIS
        Inicializa y valida la configuracion del dashboard
    
    .OUTPUTS
        Hashtable con configuracion validada
    #>
    
    Write-Host "`n[INFO] Validando configuracion..." -ForegroundColor Cyan
    
    # Validar dashboard-config.json
    $configPath = Join-Path $Global:DashboardRoot "Config\dashboard-config.json"
    $dashConfig = Test-JsonConfig -Path $configPath -Name "dashboard-config.json"

    if ($dashConfig -eq $false) {
        Write-Host "`n[CRITICO] No se puede iniciar el dashboard sin configuracion valida" -ForegroundColor Red
        Write-Host "Soluciones:" -ForegroundColor Yellow
        Write-Host "  1. Verifica que exista: $configPath" -ForegroundColor White
        Write-Host "  2. Valida la sintaxis JSON en: https://jsonlint.com/" -ForegroundColor White
        Write-Host "  3. Restaura desde backup si es necesario" -ForegroundColor White
        Write-DashboardLog -Message "Dashboard detenido: JSON invalido" -Level "Critical" -Component "Init"
        pause
        exit 1
    }

    # Convertir PSCustomObject a Hashtable para compatibilidad con funciones tipadas
    $dashConfig = ConvertTo-Hashtable $dashConfig

    # Validar estructura del JSON
    try {
        if (-not $dashConfig.ui) { throw "Falta seccion 'ui'" }
        if (-not $dashConfig.ui.colors) { throw "Falta seccion 'ui.colors'" }
        if (-not $dashConfig.ui.spacing) { throw "Falta seccion 'ui.spacing'" }

        Write-Host "[OK] Configuracion JSON validada" -ForegroundColor Green
        Write-DashboardLog -Message "Configuracion JSON cargada exitosamente" -Level "Info" -Component "Init"

        return $dashConfig
        
    } catch {
        Write-Host "[ERROR] Estructura JSON invalida: $_" -ForegroundColor Red
        Write-Host "El archivo JSON existe pero le faltan campos requeridos" -ForegroundColor Yellow
        Write-DashboardLog -Message "JSON con estructura invalida: $_" -Level "Error" -Component "Init"
        pause
        exit 1
    }
}

function Initialize-UniversalDashboard {
    <#
    .SYNOPSIS
        Verifica e instala UniversalDashboard si es necesario
    
    .OUTPUTS
        $true si el modulo esta disponible
    #>
    
    Write-Host "`n[INFO] Verificando UniversalDashboard..." -ForegroundColor Cyan
    
    $moduloDisponible = Get-Module -ListAvailable -Name UniversalDashboard.Community
    
    if (-not $moduloDisponible) {
        Write-Host "[ADVERTENCIA] UniversalDashboard.Community no esta instalado" -ForegroundColor Yellow
        Write-Host "[INFO] Iniciando instalacion automatica..." -ForegroundColor Cyan
        
        # Verificar permisos de administrador
        $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        
        if ($isAdmin) {
            try {
                Write-Host "[INFO] Instalando UniversalDashboard.Community..." -ForegroundColor Cyan
                Write-Host "[INFO] Esto puede tardar varios minutos. Por favor espera..." -ForegroundColor Yellow
                
                # Configurar PSGallery como confiable temporalmente
                $repoPolicy = Get-PSRepository -Name PSGallery | Select-Object -ExpandProperty InstallationPolicy
                if ($repoPolicy -ne "Trusted") {
                    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
                }
                
                # Instalar módulo
                Install-Module -Name UniversalDashboard.Community -RequiredVersion 2.9.0 -Scope AllUsers -Force -AllowClobber -ErrorAction Stop
                
                # Restaurar política original
                if ($repoPolicy -ne "Trusted") {
                    Set-PSRepository -Name PSGallery -InstallationPolicy $repoPolicy
                }
                
                Write-Host "[OK] Modulo instalado exitosamente" -ForegroundColor Green
                Write-DashboardLog -Message "UniversalDashboard instalado automaticamente" -Level "Info" -Component "Init"
                
            } catch {
                Write-Host "[ERROR] No se pudo instalar automaticamente: $_" -ForegroundColor Red
                Write-Host "`nPor favor ejecuta manualmente:" -ForegroundColor Yellow
                Write-Host ".\Instalar-Dependencias.bat" -ForegroundColor White
                Write-DashboardLog -Message "Error al instalar UniversalDashboard: $_" -Level "Error" -Component "Init"
                pause
                exit 1
            }
        } else {
            Write-Host "[ERROR] Se requieren permisos de administrador para instalar" -ForegroundColor Red
            Write-Host "`nPor favor ejecuta como administrador:" -ForegroundColor Yellow
            Write-Host ".\Instalar-Dependencias.bat" -ForegroundColor White
            pause
            exit 1
        }
    } else {
        Write-Host "[OK] UniversalDashboard.Community disponible" -ForegroundColor Green
    }
    
    # Importar módulo
    try {
        Import-Module UniversalDashboard.Community -ErrorAction Stop
        Write-Host "[OK] UniversalDashboard.Community importado" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "[ERROR] No se pudo importar UniversalDashboard: $_" -ForegroundColor Red
        Write-DashboardLog -Message "Error al importar UniversalDashboard: $_" -Level "Error" -Component "Init"
        pause
        exit 1
    }
}

function Get-DashboardColors {
    <#
    .SYNOPSIS
        Extrae colores de la configuracion
    
    .PARAMETER Config
        Objeto de configuracion
    
    .OUTPUTS
        Hashtable con colores
    #>
    param(
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    return @{
        Primary = $Config.ui.colors.primary
        Success = $Config.ui.colors.success
        Warning = $Config.ui.colors.warning
        Danger = $Config.ui.colors.danger
    }
}

function Get-DashboardSpacing {
    <#
    .SYNOPSIS
        Extrae espaciado de la configuracion

    .PARAMETER Config
        Objeto de configuracion

    .OUTPUTS
        Hashtable con espaciado
    #>
    param(
        [Parameter(Mandatory=$true)]
        $Config
    )

    return @{
        XS = $Config.ui.spacing.xs
        S = $Config.ui.spacing.s
        M = $Config.ui.spacing.m
        L = $Config.ui.spacing.l
        XL = $Config.ui.spacing.xl
    }
}

function ConvertTo-Hashtable {
    <#
    .SYNOPSIS
        Convierte PSCustomObject a Hashtable recursivamente

    .DESCRIPTION
        Necesario para convertir objetos JSON (PSCustomObject) a Hashtables
        que puedan ser pasados a funciones que esperan hashtables tipados

    .PARAMETER InputObject
        Objeto a convertir (PSCustomObject, array, o primitivo)

    .OUTPUTS
        Hashtable, array de hashtables, o valor primitivo

    .NOTES
        Agregado en v1.0.1-LTS para soporte de Paradise Design
    #>
    param(
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    if ($null -eq $InputObject) {
        return $null
    }

    # Si es una coleccion (array), convertir cada elemento
    if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
        $collection = @()
        foreach ($object in $InputObject) {
            $collection += ConvertTo-Hashtable $object
        }
        return $collection
    }

    # Si es un PSObject, convertir a hashtable
    if ($InputObject -is [psobject]) {
        $hash = @{}
        foreach ($property in $InputObject.PSObject.Properties) {
            $hash[$property.Name] = ConvertTo-Hashtable $property.Value
        }
        return $hash
    }

    # Si es un tipo primitivo, retornar tal cual
    return $InputObject
}

# ============================================
# FUNCIONES EXPORTADAS (dot-sourced)
# ============================================
# Las siguientes funciones estan disponibles:
# - Test-JsonConfig
# - Initialize-DashboardConfig
# - Initialize-UniversalDashboard
# - Get-DashboardColors
# - Get-DashboardSpacing
# - ConvertTo-Hashtable

Write-DashboardLog -Message "Dashboard-Init 2.0 cargado exitosamente" -Level "Info" -Component "Init"
