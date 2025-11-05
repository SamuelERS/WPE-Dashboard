param(
    [string]$Tienda = "Merliot"
)

Write-Host "============================================"
Write-Host "Creando usuario POS para: $Tienda" -ForegroundColor Cyan
Write-Host "============================================"

# Simular creación (luego pondrás código real)
$Username = "POS-$Tienda"
Write-Host "✅ Usuario: $Username" -ForegroundColor Green
Write-Host "✅ Password: 841357" -ForegroundColor Green
Write-Host "✅ Creado exitosamente" -ForegroundColor Green

# Retornar resultado
Write-Output "Usuario $Username creado exitosamente"
