# 🛠️ COMANDOS ÚTILES - Dashboard IT

Referencia rápida de comandos PowerShell útiles para gestionar el dashboard.

---

## 🚀 GESTIÓN DEL DASHBOARD

### Iniciar Dashboard
```powershell
# Método 1: Usando el lanzador (recomendado)
.\Iniciar-Dashboard.bat

# Método 2: Manualmente
cd C:\WPE-Dashboard
.\Dashboard.ps1
```

### Detener Dashboard
```powershell
# Método 1: Usando el script
.\Detener-Dashboard.ps1

# Método 2: Manualmente
Get-UDDashboard | Stop-UDDashboard
```

### Ver Dashboards Activos
```powershell
Get-UDDashboard
```

### Reiniciar Dashboard
```powershell
Get-UDDashboard | Stop-UDDashboard
Start-Sleep -Seconds 2
.\Dashboard.ps1
```

---

## 📊 LOGS Y AUDITORÍA

### Ver Logs del Mes Actual
```powershell
$logFile = "C:\WPE-Dashboard\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
Get-Content $logFile
```

### Ver Últimas 30 Líneas
```powershell
$logFile = "C:\WPE-Dashboard\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
Get-Content $logFile -Tail 30
```

### Buscar en Logs
```powershell
$logFile = "C:\WPE-Dashboard\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
Get-Content $logFile | Select-String "Usuario"
```

### Exportar Logs a CSV
```powershell
$logFile = "C:\WPE-Dashboard\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
Get-Content $logFile | ConvertFrom-Csv -Delimiter "]" | Export-Csv "reporte.csv"
```

---

## 🔧 GESTIÓN DE SCRIPTS

### Listar Scripts por Categoría
```powershell
Get-ChildItem "C:\WPE-Dashboard\Scripts\Configuracion" -Filter "*.ps1"
```

### Crear Nuevo Script desde Plantilla
```powershell
$categoria = "Mantenimiento"
$nombreScript = "Mi-Nuevo-Script"
Copy-Item "C:\WPE-Dashboard\Scripts\PLANTILLA-Script.ps1" `
          "C:\WPE-Dashboard\Scripts\$categoria\$nombreScript.ps1"
```

### Probar Script Manualmente
```powershell
cd C:\WPE-Dashboard\Scripts\Configuracion
.\Crear-Usuario-Sistema.ps1 -nombreUsuario "Test" -password "123456" -tipoUsuario "POS"
```

### Validar Sintaxis de Script
```powershell
$script = "C:\WPE-Dashboard\Scripts\Configuracion\Crear-Usuario-Sistema.ps1"
$errors = $null
$null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $script -Raw), [ref]$errors)
$errors
```

---

## 🌐 RED Y CONECTIVIDAD

### Ver IP del Servidor
```powershell
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"}
```

### Probar Acceso al Dashboard
```powershell
# Desde el mismo servidor
Invoke-WebRequest -Uri "http://localhost:10000" -UseBasicParsing

# Desde otra PC (reemplazar IP)
Invoke-WebRequest -Uri "http://192.168.1.100:10000" -UseBasicParsing
```

### Ver Puerto 10000 en Uso
```powershell
Get-NetTCPConnection -LocalPort 10000
```

### Abrir Puerto en Firewall
```powershell
New-NetFirewallRule -DisplayName "Dashboard IT" `
                    -Direction Inbound `
                    -LocalPort 10000 `
                    -Protocol TCP `
                    -Action Allow
```

---

## 👥 GESTIÓN DE USUARIOS

### Listar Usuarios Locales
```powershell
Get-LocalUser
```

### Ver Usuario Específico
```powershell
Get-LocalUser -Name "POS-Merliot"
```

### Eliminar Usuario
```powershell
Remove-LocalUser -Name "NombreUsuario"
```

### Cambiar Password de Usuario
```powershell
$password = ConvertTo-SecureString "NuevaPassword" -AsPlainText -Force
Set-LocalUser -Name "NombreUsuario" -Password $password
```

### Ver Grupos de un Usuario
```powershell
Get-LocalGroup | Where-Object {
    (Get-LocalGroupMember -Group $_.Name).Name -contains "$env:COMPUTERNAME\NombreUsuario"
}
```

---

## 🧹 MANTENIMIENTO

### Limpiar Archivos Temporales
```powershell
Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
```

### Ver Espacio en Disco
```powershell
Get-PSDrive -PSProvider FileSystem
```

### Ver Espacio Detallado
```powershell
Get-Volume
```

### Limpiar Logs Antiguos (más de 6 meses)
```powershell
$fecha = (Get-Date).AddMonths(-6)
Get-ChildItem "C:\WPE-Dashboard\Logs" -Filter "*.log" | 
    Where-Object {$_.LastWriteTime -lt $fecha} | 
    Remove-Item -Force
```

---

## 🔍 DIAGNÓSTICO

### Verificar Módulo Universal Dashboard
```powershell
Get-Module -ListAvailable -Name UniversalDashboard*
```

### Verificar Versión de PowerShell
```powershell
$PSVersionTable
```

### Ver Procesos de PowerShell
```powershell
Get-Process -Name powershell*
```

### Ver Uso de Recursos
```powershell
Get-Process -Name powershell* | Select-Object Name, CPU, WorkingSet
```

### Verificar Permisos de Administrador
```powershell
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    Write-Host "Ejecutando como Administrador" -ForegroundColor Green
} else {
    Write-Host "NO tienes permisos de Administrador" -ForegroundColor Red
}
```

---

## 📦 BACKUP Y RESTAURACIÓN

### Backup del Dashboard
```powershell
$fecha = Get-Date -Format "yyyy-MM-dd"
$backup = "C:\Backups\Dashboard-$fecha.zip"
Compress-Archive -Path "C:\WPE-Dashboard\*" -DestinationPath $backup
```

### Backup Solo de Scripts
```powershell
$fecha = Get-Date -Format "yyyy-MM-dd"
$backup = "C:\Backups\Scripts-$fecha.zip"
Compress-Archive -Path "C:\WPE-Dashboard\Scripts\*" -DestinationPath $backup
```

### Restaurar desde Backup
```powershell
Expand-Archive -Path "C:\Backups\Dashboard-2025-11-04.zip" -DestinationPath "C:\WPE-Dashboard-Restaurado"
```

---

## 🔄 ACTUALIZACIÓN Y DESARROLLO

### Ver Cambios Recientes
```powershell
Get-ChildItem "C:\WPE-Dashboard" -Recurse | 
    Where-Object {$_.LastWriteTime -gt (Get-Date).AddDays(-7)} | 
    Sort-Object LastWriteTime -Descending
```

### Comparar Dos Versiones de Script
```powershell
Compare-Object (Get-Content "script-v1.ps1") (Get-Content "script-v2.ps1")
```

### Exportar Estructura del Proyecto
```powershell
Get-ChildItem "C:\WPE-Dashboard" -Recurse | 
    Select-Object FullName, Length, LastWriteTime | 
    Export-Csv "estructura-proyecto.csv"
```

---

## 🎯 SCRIPTS ÚTILES ONE-LINERS

### Contar Scripts por Categoría
```powershell
Get-ChildItem "C:\WPE-Dashboard\Scripts" -Directory | ForEach-Object {
    [PSCustomObject]@{
        Categoria = $_.Name
        Scripts = (Get-ChildItem $_.FullName -Filter "*.ps1" | Measure-Object).Count
    }
}
```

### Ver Tamaño de Logs
```powershell
Get-ChildItem "C:\WPE-Dashboard\Logs" -Filter "*.log" | 
    Measure-Object -Property Length -Sum | 
    Select-Object @{Name="TotalMB";Expression={[math]::Round($_.Sum/1MB, 2)}}
```

### Verificar Sintaxis de Todos los Scripts
```powershell
Get-ChildItem "C:\WPE-Dashboard\Scripts" -Recurse -Filter "*.ps1" | ForEach-Object {
    $errors = $null
    $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $_.FullName -Raw), [ref]$errors)
    if ($errors) {
        Write-Host "Errores en: $($_.Name)" -ForegroundColor Red
        $errors
    }
}
```

---

## 🆘 SOLUCIÓN RÁPIDA DE PROBLEMAS

### Dashboard No Inicia
```powershell
# 1. Detener todos los dashboards
Get-UDDashboard | Stop-UDDashboard

# 2. Verificar puerto
Get-NetTCPConnection -LocalPort 10000

# 3. Reiniciar
.\Dashboard.ps1
```

### Error de Permisos
```powershell
# Verificar si eres admin
([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Si no, reiniciar PowerShell como admin
Start-Process powershell -Verb RunAs
```

### Módulo No Encontrado
```powershell
# Reinstalar Universal Dashboard
Install-Module -Name UniversalDashboard.Community -Force
```

---

## 📚 REFERENCIAS

- **Documentación PowerShell:** https://docs.microsoft.com/powershell
- **Universal Dashboard:** https://ironmansoftware.com/powershell-universal-dashboard
- **Guía del Proyecto:** `README.md`

---

**Última actualización:** Noviembre 2025  
**Versión Dashboard:** 1.1
