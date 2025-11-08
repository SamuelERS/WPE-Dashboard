# ===================================================================
# Test Unitarios - Modularización v2.0
# Paradise Dashboard - Caso 10
# ===================================================================
#
# Descripción:
#   Tests unitarios con Pester para validar módulos v2.0
#
# Uso:
#   Invoke-Pester .\05_Test_Unitarios_Modularizacion.ps1 -Verbose
#
# Requisitos:
#   - Pester 5.x (Install-Module -Name Pester -Force)
#   - UniversalDashboard.Community v2.9.0
#   - PowerShell 5.1+
#
# Autor: Paradise-SystemLabs
# Fecha: 2025-11-08
# ===================================================================

BeforeAll {
    # Importar UniversalDashboard si no está cargado
    if (-not (Get-Module -Name UniversalDashboard.Community)) {
        Import-Module UniversalDashboard.Community -ErrorAction SilentlyContinue
    }

    # Path al módulo
    $ModulePath = Join-Path $PSScriptRoot "..\..\Modules\DashboardContent.psm1"
}

Describe "Módulo DashboardContent.psm1 - Validaciones Básicas" {

    Context "Existencia y estructura" {

        It "Archivo del módulo existe" {
            $ModulePath | Should -Exist
        }

        It "Módulo se importa sin errores" {
            { Import-Module $ModulePath -Force -ErrorAction Stop } | Should -Not -Throw
        }

        It "Función New-DashboardContent está exportada" {
            $functions = (Get-Module DashboardContent).ExportedFunctions.Keys
            $functions | Should -Contain "New-DashboardContent"
        }
    }

    Context "Funcionalidad básica" {

        BeforeAll {
            Import-Module $ModulePath -Force
        }

        It "Función New-DashboardContent existe y es ejecutable" {
            Get-Command New-DashboardContent -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }

        It "Función retorna contenido válido (no nulo)" {
            $result = New-DashboardContent
            $result | Should -Not -BeNullOrEmpty
        }

        It "Función no lanza excepciones" {
            { New-DashboardContent } | Should -Not -Throw
        }
    }

    Context "Compatibilidad UniversalDashboard" {

        BeforeAll {
            Import-Module $ModulePath -Force
        }

        It "Módulo UniversalDashboard está disponible" {
            Get-Module -Name UniversalDashboard* | Should -Not -BeNullOrEmpty
        }

        It "Función New-UDColumn es accesible (requerida por módulo)" {
            Get-Command New-UDColumn -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }

        It "Función New-UDCard es accesible" {
            Get-Command New-UDCard -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }
    }
}

Describe "Integración en Dashboard.ps1" {

    Context "Carga del módulo desde Dashboard" {

        It "Dashboard.ps1 contiene lógica de import del módulo v2.0" {
            $dashboardPath = Join-Path $PSScriptRoot "..\..\Dashboard.ps1"
            $content = Get-Content $dashboardPath -Raw
            $content | Should -Match "Modules\\DashboardContent.psm1"
        }

        It "Dashboard.ps1 maneja ausencia del módulo gracefully" {
            $dashboardPath = Join-Path $PSScriptRoot "..\..\Dashboard.ps1"
            $content = Get-Content $dashboardPath -Raw
            $content | Should -Match "Test-Path.*modulePath"
        }

        It "Dashboard.ps1 define variable global ModuleV2Loaded" {
            $dashboardPath = Join-Path $PSScriptRoot "..\..\Dashboard.ps1"
            $content = Get-Content $dashboardPath -Raw
            $content | Should -Match '\$Global:ModuleV2Loaded'
        }
    }
}

Describe "Arquitectura Híbrida - Coexistencia v1.0.1 + v2.0" {

    Context "Preservación de v1.0.1-LTS" {

        It "Carpeta Core/ existe (v1.0.1)" {
            Test-Path (Join-Path $PSScriptRoot "..\..\Core") | Should -Be $true
        }

        It "Carpeta UI/ existe (v1.0.1)" {
            Test-Path (Join-Path $PSScriptRoot "..\..\UI") | Should -Be $true
        }

        It "Carpeta Utils/ existe (v1.0.1)" {
            Test-Path (Join-Path $PSScriptRoot "..\..\Utils") | Should -Be $true
        }

        It "Dashboard-UI.ps1 no fue modificado destructivamente" {
            $uiPath = Join-Path $PSScriptRoot "..\..\UI\Dashboard-UI.ps1"
            Test-Path $uiPath | Should -Be $true
            (Get-Content $uiPath).Count | Should -BeGreaterThan 700
        }
    }

    Context "Nueva estructura v2.0" {

        It "Carpeta Modules/ existe" {
            Test-Path (Join-Path $PSScriptRoot "..\..\Modules") | Should -Be $true
        }

        It "DashboardContent.psm1 existe en Modules/" {
            Test-Path (Join-Path $PSScriptRoot "..\..\Modules\DashboardContent.psm1") | Should -Be $true
        }

        It "Documentación Caso_10 existe" {
            Test-Path (Join-Path $PSScriptRoot "..\Caso_10_Restauracion_Modular_v2.0") | Should -Be $true
        }
    }

    Context "Backup de seguridad" {

        It "Existe al menos un backup v1.0.1-LTS" {
            $backups = Get-ChildItem (Join-Path $PSScriptRoot "..\..") -Filter "Backup-v1.0.1-LTS-*" -Directory
            $backups | Should -Not -BeNullOrEmpty
        }

        It "Backup contiene BACKUP_INFO.txt" {
            $backups = Get-ChildItem (Join-Path $PSScriptRoot "..\..") -Filter "Backup-v1.0.1-LTS-*" -Directory | Select-Object -First 1
            if ($backups) {
                Test-Path (Join-Path $backups.FullName "BACKUP_INFO.txt") | Should -Be $true
            }
        }
    }
}

# ===================================================================
# Tests de Regresión - Validar que v1.0.1 sigue funcional
# ===================================================================

Describe "Regresión v1.0.1-LTS - Funcionalidad preservada" {

    Context "Módulos Core v1.0.1" {

        It "Dashboard-Init.ps1 existe" {
            Test-Path (Join-Path $PSScriptRoot "..\..\Core\Dashboard-Init.ps1") | Should -Be $true
        }

        It "ScriptLoader.ps1 existe" {
            Test-Path (Join-Path $PSScriptRoot "..\..\Core\ScriptLoader.ps1") | Should -Be $true
        }
    }

    Context "Configuración" {

        It "dashboard-config.json existe" {
            Test-Path (Join-Path $PSScriptRoot "..\..\Config\dashboard-config.json") | Should -Be $true
        }

        It "Configuración contiene colores Paradise" {
            $configPath = Join-Path $PSScriptRoot "..\..\Config\dashboard-config.json"
            $config = Get-Content $configPath -Raw | ConvertFrom-Json
            $config.colorsParadise | Should -Not -BeNullOrEmpty
        }
    }
}

# ===================================================================
# Fin de tests
# ===================================================================

AfterAll {
    Write-Host "`n============================================" -ForegroundColor Cyan
    Write-Host "  Tests Unitarios - Modularización v2.0" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "Caso 10 - Paradise-SystemLabs" -ForegroundColor White
    Write-Host "Para más información: Docs/Caso_10_Restauracion_Modular_v2.0/" -ForegroundColor Gray
    Write-Host "============================================`n" -ForegroundColor Cyan
}
