# Script para actualizar metadata de scripts al formato v2.0

$scripts = @(
    @{Path="Scripts\Configuracion\Cambiar-Nombre-PC.ps1"; Name="Cambiar Nombre del PC"; Desc="Cambia el nombre del equipo"; Cat="Configuracion"; Admin="true"; Icon="desktop"; Order=1}
    @{Path="Scripts\Configuracion\Crear-Usuario-Sistema.ps1"; Name="Crear Usuario Sistema"; Desc="Crea un nuevo usuario local"; Cat="Configuracion"; Admin="true"; Icon="user-plus"; Order=2}
    @{Path="Scripts\Mantenimiento\Eliminar-Usuario.ps1"; Name="Eliminar Usuario"; Desc="Elimina un usuario local"; Cat="Mantenimiento"; Admin="true"; Icon="user-minus"; Order=2}
    @{Path="Scripts\POS\Crear-Usuario-POS.ps1"; Name="Crear Usuario POS"; Desc="Crea usuario para sistema POS"; Cat="POS"; Admin="true"; Icon="shopping-cart"; Order=1}
    @{Path="Scripts\POS\Crear-Usuario.ps1"; Name="Crear Usuario"; Desc="Crea usuario generico"; Cat="POS"; Admin="true"; Icon="user"; Order=2}
)

Write-Host "=== ACTUALIZANDO METADATA ===" -ForegroundColor Cyan

foreach($s in $scripts) {
    if(Test-Path $s.Path) {
        $content = Get-Content $s.Path -Raw
        
        # Buscar y reemplazar metadata antigua
        if($content -match '# @Name:') {
            $newMetadata = @"
<# METADATA
Name: $($s.Name)
Description: $($s.Desc)
Category: $($s.Cat)
RequiresAdmin: $($s.Admin)
Icon: $($s.Icon)
Order: $($s.Order)
Enabled: true
#>
"@
            
            # Reemplazar metadata antigua
            $content = $content -replace '(?m)^# @Name:.*\r?\n# @Description:.*\r?\n# @Category:.*\r?\n# @RequiresAdmin:.*\r?\n# @HasForm:.*\r?\n', "$newMetadata`n"
            
            Set-Content $s.Path -Value $content -Encoding UTF8
            Write-Host "[OK] $($s.Path)" -ForegroundColor Green
        }
    }
}

Write-Host "`n[OK] Metadata actualizada" -ForegroundColor Green
