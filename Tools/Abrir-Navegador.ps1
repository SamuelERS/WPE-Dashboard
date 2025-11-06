# ============================================
# ABRIR DASHBOARD EN NAVEGADOR MODERNO
# ============================================
# Evita Internet Explorer y prioriza navegadores modernos
# Paradise-SystemLabs Dashboard

param(
    [string]$URL = "http://localhost:10000"
)

# Prioridad de navegadores (del más preferido al menos)
$navegadores = @(
    # Microsoft Edge (Chromium) - Predeterminado en Windows 10/11
    @{
        Nombre = "Microsoft Edge"
        Ejecutable = "msedge.exe"
        Rutas = @(
            "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
            "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
            "$env:LOCALAPPDATA\Microsoft\Edge\Application\msedge.exe"
        )
    },
    # Google Chrome
    @{
        Nombre = "Google Chrome"
        Ejecutable = "chrome.exe"
        Rutas = @(
            "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
            "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
            "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
        )
    },
    # Mozilla Firefox
    @{
        Nombre = "Mozilla Firefox"
        Ejecutable = "firefox.exe"
        Rutas = @(
            "${env:ProgramFiles(x86)}\Mozilla Firefox\firefox.exe",
            "$env:ProgramFiles\Mozilla Firefox\firefox.exe"
        )
    }
)

# Buscar navegador disponible
$navegadorEncontrado = $null
foreach ($nav in $navegadores) {
    foreach ($ruta in $nav.Rutas) {
        if (Test-Path $ruta) {
            $navegadorEncontrado = @{
                Nombre = $nav.Nombre
                Ruta = $ruta
            }
            break
        }
    }
    if ($navegadorEncontrado) { break }
}

# Abrir navegador
if ($navegadorEncontrado) {
    Write-Host "[INFO] Abriendo $($navegadorEncontrado.Nombre)..." -ForegroundColor Cyan
    try {
        Start-Process -FilePath $navegadorEncontrado.Ruta -ArgumentList $URL -ErrorAction Stop
    } catch {
        Write-Host "[WARN] Error al abrir $($navegadorEncontrado.Nombre): $_" -ForegroundColor Yellow
        Write-Host "[INFO] Intentando con navegador predeterminado..." -ForegroundColor Cyan
        Start-Process $URL
    }
} else {
    Write-Host "[WARN] No se encontro Edge, Chrome o Firefox" -ForegroundColor Yellow
    Write-Host "[INFO] Abriendo navegador predeterminado..." -ForegroundColor Cyan
    Write-Host "[RECOMENDACION] Instala Microsoft Edge para mejor experiencia" -ForegroundColor Yellow
    Start-Process $URL
}
