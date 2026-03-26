#requires -Version 5.1

$ErrorActionPreference = "Stop"

function Pause-AndExit {
  param([int]$Code)
  Read-Host "Pulsa Enter para cerrar... " | Out-Null
  exit $Code
}

function Get-UbuntuDistro {
  $allDistros = (& wsl.exe -l -q 2>$null | ForEach-Object { $_.Trim() } | Where-Object { $_ })
  if (-not $allDistros) {
    return $null
  }

  $ubuntu = $allDistros | Where-Object { $_ -match '^Ubuntu' } | Select-Object -First 1
  if ($ubuntu) {
    return $ubuntu
  }

  return $allDistros[0]
}

function Test-WSLCommand {
  param(
    [Parameter(Mandatory = $true)][string]$Distro,
    [Parameter(Mandatory = $true)][string]$Command
  )

  & wsl.exe -d $Distro -- bash -lc $Command *> $null
  return ($LASTEXITCODE -eq 0)
}

function Escape-BashSingleQuoted {
  param([Parameter(Mandatory = $true)][string]$Value)
  return ($Value -replace "'", "'\"'\"'")
}

function Select-WorkFolder {
  try {
    Add-Type -AssemblyName System.Windows.Forms | Out-Null
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Selecciona tu carpeta de trabajo"
    $dialog.ShowNewFolderButton = $true
    $dialog.SelectedPath = [Environment]::GetFolderPath("Desktop")
    $result = $dialog.ShowDialog()
    if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
      return $null
    }
    return $dialog.SelectedPath
  } catch {
    Write-Host "Aviso: no se pudo abrir el selector grafico."
    Write-Host "Usaremos entrada manual de ruta."
    $manualPath = Read-Host "Escribe la ruta de tu carpeta de trabajo en Windows"
    if ([string]::IsNullOrWhiteSpace($manualPath)) {
      return $null
    }
    return $manualPath.Trim()
  }
}

Write-Host "========================================"
Write-Host "OpenCode Launcher - Windows + WSL"
Write-Host "========================================"
Write-Host "Este launcher abre OpenCode en tu carpeta"
Write-Host "de Windows sin copiar archivos a WSL."
Write-Host "Puedes elegir Desktop, Documents u otra carpeta local."
Write-Host ""

if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
  Write-Host "ERROR: No se encontro wsl.exe."
  Write-Host "Ejecuta primero el instalador de OpenKit_WSL."
  Pause-AndExit 1
}

$DistroName = Get-UbuntuDistro
if (-not $DistroName) {
  Write-Host "ERROR: No se encontro ninguna distro en WSL."
  Write-Host "Ejecuta primero OpenCode Installer.ps1 para preparar Ubuntu."
  Pause-AndExit 1
}

if (-not (Test-WSLCommand -Distro $DistroName -Command "id -u >/dev/null 2>&1")) {
  Write-Host "ERROR: La distro WSL no esta inicializada."
  Write-Host "Abre Ubuntu una vez para crear tu usuario Linux y vuelve a intentar."
  Pause-AndExit 1
}

if (-not (Test-WSLCommand -Distro $DistroName -Command "command -v opencode >/dev/null 2>&1")) {
  Write-Host "ERROR: OpenCode no esta instalado en WSL."
  Write-Host "Ejecuta primero OpenCode Installer.ps1."
  Pause-AndExit 1
}

$FolderPath = Select-WorkFolder
if ([string]::IsNullOrWhiteSpace($FolderPath)) {
  Write-Host "Cancelado por el usuario."
  Write-Host "No se realizaron cambios."
  exit 0
}

if (-not (Test-Path -LiteralPath $FolderPath -PathType Container)) {
  Write-Host "ERROR: La carpeta no existe o no es accesible."
  Pause-AndExit 1
}

try {
  Get-ChildItem -LiteralPath $FolderPath -Force -ErrorAction Stop | Out-Null
} catch {
  Write-Host "ERROR: No tienes permisos para acceder a la carpeta."
  Pause-AndExit 1
}

try {
  Start-Process -FilePath "explorer.exe" -ArgumentList $FolderPath -ErrorAction Stop | Out-Null
} catch {
  Write-Host "Aviso: no se pudo abrir la carpeta en el Explorador de Windows."
  Write-Host "Continuando con el inicio de OpenCode..."
}

$WslFolder = (& wsl.exe -d $DistroName -- wslpath -a -u $FolderPath 2>$null | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($WslFolder)) {
  Write-Host "ERROR: No se pudo convertir la ruta a formato WSL."
  Write-Host "Selecciona una carpeta local (ejemplo: C:\Users\TuUsuario\Proyecto)."
  Pause-AndExit 1
}

$WslFolderEscaped = Escape-BashSingleQuoted -Value $WslFolder

$launchTemplate = @'
TARGET_DIR='__TARGET_DIR__'

if [ -f "$HOME/.config/opencode/opencode.zen.json" ]; then
  export OPENCODE_CONFIG="$HOME/.config/opencode/opencode.zen.json"
elif [ -f "$HOME/.config/opencode/opencode.lang.json" ]; then
  export OPENCODE_CONFIG="$HOME/.config/opencode/opencode.lang.json"
elif [ -f "$HOME/.config/opencode/opencode.json" ]; then
  export OPENCODE_CONFIG="$HOME/.config/opencode/opencode.json"
fi

if [ ! -d "$TARGET_DIR" ]; then
  echo "ERROR: La carpeta seleccionada no esta disponible en WSL."
  exit 1
fi

cd "$TARGET_DIR" || exit 1
exec opencode
'@

$launchCmd = $launchTemplate.Replace("__TARGET_DIR__", $WslFolderEscaped)

Write-Host ""
Write-Host "Distro: $DistroName"
Write-Host "Carpeta Windows: $FolderPath"
Write-Host "Carpeta WSL: $WslFolder"
Write-Host ""
Write-Host "Iniciando OpenCode..."
Write-Host "Cuando cierres OpenCode, volveras a esta ventana."

& wsl.exe -d $DistroName -- bash -lc $launchCmd
$launchExit = $LASTEXITCODE

if ($launchExit -ne 0) {
  Write-Host ""
  Write-Host "ERROR: OpenCode termino con codigo $launchExit"
  Pause-AndExit 1
}

Write-Host ""
Write-Host "Sesion finalizada."
