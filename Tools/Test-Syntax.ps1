# Quick syntax validator
$scriptPath = "C:\ProgramData\WPE-Dashboard\Tools\Mantenimiento-Rapido.ps1"
$errors = @()
$null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $scriptPath -Raw), [ref]$errors)

if ($errors.Count -eq 0) {
    Write-Host "[PASS] Syntax validation: No errors found" -ForegroundColor Green
    exit 0
} else {
    Write-Host "[FAIL] Syntax errors found:" -ForegroundColor Red
    foreach ($err in $errors) {
        Write-Host "  $($err.Message)" -ForegroundColor Yellow
    }
    exit 1
}
