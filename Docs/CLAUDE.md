# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

WPE-Dashboard is a PowerShell-based IT automation web dashboard for Acuarios Paradise. It provides a centralized web interface for executing Windows administration scripts across multiple business functions. Built with UniversalDashboard.Community v2.9.0, it runs as a local web server on port 10000.

**Technology Stack:**
- Language: PowerShell 5.1+
- Framework: UniversalDashboard.Community v2.9.0
- Runtime: Windows 10/11 or Windows Server 2016+
- No build tools, package managers, or compilation required

**Current Status:** Version 1.1, early production (30% complete, 2 of ~50 scripts migrated from Notion)

---

## ⚠️ CRITICAL CONCEPT: LOCAL Execution Model

**THIS DASHBOARD IS A LOCAL AUTOMATION TOOL, NOT A REMOTE MANAGEMENT SYSTEM**

### Fundamental Rule
- All scripts execute on the machine WHERE the dashboard is running
- `New-LocalUser` creates users on the LOCAL PC running the dashboard
- Does NOT create users remotely on other machines
- To configure multiple PCs, run the dashboard ON each target PC

### Correct Usage Example
```
Scenario: Create user on VM "DESKTOP-VHIMC05"

❌ INCORRECT:
1. Connected to HOST "DESKTOP-VHIMQ05"
2. Run dashboard on HOST
3. Create user from web interface
4. RESULT: User created on HOST, NOT on VM

✅ CORRECT:
1. Connect via RDP to VM "DESKTOP-VHIMC05"
2. Run dashboard ON the VM: \\server\WPE-Dashboard\Iniciar-Dashboard.bat
3. Create user from web interface
4. RESULT: User created on VM correctly
```

### Recommended Deployment
```powershell
# Option 1: Network shared folder (RECOMMENDED)
\\server\WPE-Dashboard\Iniciar-Dashboard.bat

# Option 2: Local copy on each PC
C:\WPE-Dashboard\Iniciar-Dashboard.bat
```

**Benefit of Option 1:** Maintain a single copy of the dashboard, execute from network on each target PC

---

## Running the Dashboard

```batch
# Start dashboard (recommended - auto-elevates to admin)
Iniciar-Dashboard.bat

# From PowerShell as Administrator
.\Dashboard.ps1

# Stop dashboard
.\Detener-Dashboard.ps1

# Or manually
Get-UDDashboard | Stop-UDDashboard
```

**Access:** http://localhost:10000 (or http://[server-ip]:10000 from network)

## Development Workflow

### Adding New Scripts

1. **Copy the template:**
```powershell
Copy-Item "Scripts\PLANTILLA-Script.ps1" "Scripts\[Category]\New-Script.ps1"
```

2. **Edit metadata block** (used for future auto-loading):
```powershell
# @Name: Display Name
# @Description: What the script does
# @RequiresAdmin: true/false
# @HasForm: true/false
# @FormField: fieldName|Placeholder text|textbox
# @FormField: fieldName2|Another field|select:Option1,Option2
```

3. **Implement logic** following the template pattern (see Script Structure section)

4. **Test standalone:**
```powershell
.\Scripts\[Category]\New-Script.ps1 -param "value"
```

5. **Currently:** Manually add button to [Dashboard.ps1](Dashboard.ps1) (auto-loading not yet implemented)

6. **Restart dashboard** to see changes:
```powershell
.\Detener-Dashboard.ps1
.\Iniciar-Dashboard.bat
```

### Script Categories

Scripts are organized into 6 functional categories (map to folder names):

- **Configuracion** - Initial system setup (user creation, software installation)
- **Mantenimiento** - System maintenance (cleanup, updates, optimization)
- **POS** - Point of sale operations
- **Diseno** - Graphic design tools (Adobe, calibration, printers)
- **Atencion-Al-Cliente** - Customer service (CRM, softphone, workstations)
- **Auditoria** - Logs, reports, audit history

## Architecture

### Single-Page Application Pattern

The dashboard is a monolithic single-page web application with no routing. All functionality is presented on one page using UniversalDashboard cards and modal dialogs.

**UI Structure:**
- Each category = `New-UDCard` component
- Each action = `New-UDButton` with `-OnClick` scriptblock
- User input = `Show-UDModal` with `New-UDInput`
- Feedback = `Show-UDToast` notifications

### Script Structure (Metadata-Driven)

All scripts follow a standardized pattern:

```powershell
# Metadata block (comment-based)
# @Name: Display Name
# @Description: Brief description
# @RequiresAdmin: true/false
# @HasForm: true/false
# @FormField: name|placeholder|type

# Parameters
param(
    [string]$paramName
)

# Logging function
function Write-ScriptLog {
    param([string]$Mensaje)
    $LogFile = "C:\WPE-Dashboard\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log"
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$Timestamp] $Mensaje"
}

# Main logic
try {
    # Auto-detect PC name
    $nombrePC = $env:COMPUTERNAME

    # Validate inputs
    if ([string]::IsNullOrWhiteSpace($paramName)) {
        throw "Error: parameter required"
    }

    # Execute logic
    # ...

    # Log success
    Write-ScriptLog "Action - Success"

    # Return structured result
    return @{
        Success = $true
        Message = "Operation completed successfully"
    }

} catch {
    Write-ScriptLog "Action - Error: $_"
    return @{
        Success = $false
        Message = "Error: $_"
    }
}
```

**Key Conventions:**
- Always return hashtable with `Success` (boolean) and `Message` (string)
- Use `Write-ScriptLog` for all significant actions
- Auto-detect environment using `$env:COMPUTERNAME`
- Validate all inputs before execution
- Use try-catch for error handling

### Auto-Detection Pattern

Scripts automatically detect the computer name and can infer the store location:

```powershell
$nombrePC = $env:COMPUTERNAME

# Store name detection (multi-location business)
if ($nombrePC -match 'MERLIOT') {
    $NombreTienda = "Merliot"
} elseif ($nombrePC -match 'HEROES') {
    $NombreTienda = "Heroes"
}
```

### Centralized Logging

All actions are logged to monthly log files:
- Location: `C:\WPE-Dashboard\Logs\dashboard-YYYY-MM.log`
- Format: `[YYYY-MM-DD HH:MM:SS] Action - Result`
- Automatic monthly rotation based on filename

**View logs:**
```powershell
# Current month
Get-Content "C:\WPE-Dashboard\Logs\dashboard-$(Get-Date -Format 'yyyy-MM').log" -Tail 30

# All logs
Get-ChildItem C:\WPE-Dashboard\Logs\*.log
```

## Key Files

- [Dashboard.ps1](Dashboard.ps1) - Main application (69 lines), defines UI and starts server on port 10000
- [Iniciar-Dashboard.bat](Iniciar-Dashboard.bat) - Launcher with UAC elevation
- [Scripts/PLANTILLA-Script.ps1](Scripts/PLANTILLA-Script.ps1) - Template for all new scripts
- [Scripts/ScriptLoader.ps1](Scripts/ScriptLoader.ps1) - Future auto-loading system (not yet integrated)
- [GUIA-AGREGAR-SCRIPTS.md](GUIA-AGREGAR-SCRIPTS.md) - Detailed guide for adding scripts (Spanish)

## Important Notes

### Current Limitations

- **Manual integration required:** Scripts must be manually added to [Dashboard.ps1](Dashboard.ps1) (auto-loading via ScriptLoader.ps1 is planned but not implemented)
- **No hot reload:** Dashboard must be restarted to see code changes
- **No automated testing:** All testing is manual
- **No version control:** Project does not use Git
- **Most categories empty:** Only 2 scripts migrated so far, ~48 remaining from Notion

### Configuration

Configuration is hardcoded in [Dashboard.ps1](Dashboard.ps1):
- Port 10000 (line 69)
- Log path pattern
- Script categories

No external config files (JSON, YAML, etc.)

### Language

- All user-facing content, documentation, and code comments are in Spanish
- Variable names use Spanish (camelCase)
- Function names use PowerShell conventions (Verb-Noun)

### Security Model

- Dashboard requires administrator privileges for most operations
- No authentication (trusted local network model)
- All administrative actions are logged
- Scripts check for admin rights when `@RequiresAdmin: true`

## Common Tasks

**Test a script directly:**
```powershell
.\Scripts\POS\Crear-Usuario-POS.ps1 -nombreUsuario "TestUser"
```

**Debug dashboard startup:**
```powershell
# Check if port 10000 is in use
Get-NetTCPConnection -LocalPort 10000

# View UniversalDashboard module
Get-Module UniversalDashboard.Community -ListAvailable
```

**Verify prerequisites:**
```powershell
.\Verificar-Sistema.ps1
```

## Project Structure

```
C:\WPE-Dashboard\
├── Dashboard.ps1              # Main application
├── Iniciar-Dashboard.bat      # Launcher
├── Detener-Dashboard.ps1      # Stop utility
├── Verificar-Sistema.ps1      # System verification
│
├── Scripts\
│   ├── PLANTILLA-Script.ps1   # Template
│   ├── ScriptLoader.ps1       # Auto-loader (future)
│   ├── Configuracion\         # Setup scripts
│   ├── Mantenimiento\         # Maintenance scripts
│   ├── POS\                   # Point of sale scripts
│   ├── Diseno\                # Design scripts (empty)
│   ├── Atencion-Al-Cliente\   # Customer service (empty)
│   └── Auditoria\             # Audit scripts (empty)
│
└── Logs\                      # Monthly log files
```

See [GUIA-AGREGAR-SCRIPTS.md](GUIA-AGREGAR-SCRIPTS.md) for detailed script migration guide.
