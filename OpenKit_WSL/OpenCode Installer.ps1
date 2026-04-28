#requires -Version 5.1

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DesktopDir = [Environment]::GetFolderPath("Desktop")
$LauncherSrc = Join-Path $ScriptDir "OpenCode Launcher.ps1"
$LauncherDst = Join-Path $DesktopDir "OpenCode Launcher.ps1"

$DefaultModel = "opencode/minimax-m2.5"
$SmallModel = "opencode/minimax-m2.5"

$ConfigDirWsl = '$HOME/.config/opencode'
$AuthFileWsl = '$HOME/.local/share/opencode/auth.json'
$GlobalConfigWsl = '$HOME/.config/opencode/opencode.json'
$ZenConfigWsl = '$HOME/.config/opencode/opencode.zen.json'
$LangInstructionsWsl = '$HOME/.config/opencode/instructions-language.md'
$LangConfigWsl = '$HOME/.config/opencode/opencode.lang.json'

function Pause-AndExit {
  param([int]$Code)
  Read-Host "Pulsa Enter para cerrar... " | Out-Null
  exit $Code
}

function Ask-YesNo {
  param(
    [string]$Prompt,
    [bool]$DefaultYes = $true
  )

  if ($DefaultYes) {
    $raw = Read-Host "$Prompt [S/n]"
    if ([string]::IsNullOrWhiteSpace($raw)) {
      return $true
    }
  } else {
    $raw = Read-Host "$Prompt [s/N]"
    if ([string]::IsNullOrWhiteSpace($raw)) {
      return $false
    }
  }

  switch ($raw.Trim().ToLowerInvariant()) {
    "s" { return $true }
    "y" { return $true }
    "n" { return $false }
    default { return $DefaultYes }
  }
}

function Test-IsAdmin {
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = New-Object Security.Principal.WindowsPrincipal($identity)
  return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
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

function Invoke-WSL {
  param(
    [Parameter(Mandatory = $true)][string]$Distro,
    [Parameter(Mandatory = $true)][string]$Command,
    [switch]$IgnoreErrors
  )

  & wsl.exe -d $Distro -- bash -lc $Command
  $exitCode = $LASTEXITCODE
  if ((-not $IgnoreErrors) -and $exitCode -ne 0) {
    throw "WSL comando fallo con exit code $exitCode"
  }
  return $exitCode
}

Write-Host "========================================"
Write-Host "OpenCode Installer - Windows + WSL"
Write-Host "========================================"
Write-Host "Este asistente preparara WSL y OpenCode"
Write-Host "con configuracion por defecto OpenCode Zen."
Write-Host ""

if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
  Write-Host "ERROR: No se encontro wsl.exe en este sistema."
  Write-Host "Necesitas Windows 10/11 con soporte WSL."
  Pause-AndExit 1
}

$null = & wsl.exe -l -q 2>$null
$wslReady = ($LASTEXITCODE -eq 0)

if (-not $wslReady) {
  Write-Host "WSL no esta listo en este equipo."
  if (-not (Ask-YesNo "Quieres instalar WSL2 y Ubuntu ahora?" $true)) {
    Write-Host "Instalacion cancelada por el usuario."
    Pause-AndExit 0
  }

  if (-not (Test-IsAdmin)) {
    Write-Host "ERROR: Para instalar WSL necesitas abrir PowerShell como Administrador."
    Pause-AndExit 1
  }

  Write-Host ""
  Write-Host "Instalando WSL2 + Ubuntu..."
  & wsl.exe --install -d Ubuntu
  if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Fallo la instalacion de WSL o Ubuntu."
    Pause-AndExit 1
  }

  Write-Host ""
  Write-Host "WSL fue instalado. Si Windows pide reinicio, reinicia ahora."
  Write-Host "Luego abre Ubuntu una vez para crear tu usuario y vuelve a ejecutar este instalador."
  Pause-AndExit 0
}

& wsl.exe --set-default-version 2 *> $null
if ($LASTEXITCODE -ne 0) {
  Write-Host "Aviso: no se pudo forzar WSL2 como default. Continuando..."
}

$DistroName = Get-UbuntuDistro
if (-not $DistroName) {
  Write-Host "No se encontro ninguna distro instalada en WSL."
  if (-not (Ask-YesNo "Quieres instalar Ubuntu ahora?" $true)) {
    Write-Host "Instalacion cancelada por el usuario."
    Pause-AndExit 0
  }

  if (-not (Test-IsAdmin)) {
    Write-Host "ERROR: Para instalar Ubuntu en WSL necesitas PowerShell como Administrador."
    Pause-AndExit 1
  }

  & wsl.exe --install -d Ubuntu
  if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Fallo la instalacion de Ubuntu en WSL."
    Pause-AndExit 1
  }

  $DistroName = Get-UbuntuDistro
  if (-not $DistroName) {
    Write-Host "Ubuntu aun no aparece en WSL."
    Write-Host "Abre Ubuntu una vez, crea tu usuario, y vuelve a ejecutar este instalador."
    Pause-AndExit 0
  }
}

Write-Host ""
Write-Host "Distro detectada: $DistroName"

if (-not (Test-WSLCommand -Distro $DistroName -Command "id -u >/dev/null 2>&1")) {
  Write-Host "ERROR: Ubuntu aun no esta inicializado."
  Write-Host "Abre la app Ubuntu, crea tu usuario Linux y vuelve a ejecutar este instalador."
  Pause-AndExit 1
}

$hasOpenCode = Test-WSLCommand -Distro $DistroName -Command "command -v opencode >/dev/null 2>&1"
if (-not $hasOpenCode) {
  Write-Host ""
  Write-Host "OpenCode no esta instalado en WSL."
  Write-Host "Se descargara y ejecutara el instalador oficial de OpenCode."
  if (-not (Ask-YesNo "Continuar con la instalacion de OpenCode?" $true)) {
    Write-Host "Instalacion cancelada por el usuario."
    Pause-AndExit 0
  }

  $installCmd = @'
set -e
if ! command -v curl >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y curl
fi
TMP_FILE="$(mktemp /tmp/opencode-install.XXXXXX)"
curl -fsSL "https://opencode.ai/install" -o "$TMP_FILE"
if [ ! -s "$TMP_FILE" ]; then
  echo "ERROR: Instalador de OpenCode vacio"
  rm -f "$TMP_FILE"
  exit 1
fi
bash "$TMP_FILE"
rm -f "$TMP_FILE"
'@

  Write-Host ""
  Write-Host "Instalando OpenCode en WSL..."
  try {
    Invoke-WSL -Distro $DistroName -Command $installCmd | Out-Null
  } catch {
    Write-Host "ERROR: Fallo la instalacion de OpenCode en WSL."
    Pause-AndExit 1
  }
}

Write-Host ""
Write-Host "Version instalada de OpenCode:"
& wsl.exe -d $DistroName -- bash -lc "opencode --version"
if ($LASTEXITCODE -ne 0) {
  Write-Host "ERROR: OpenCode no responde correctamente en WSL."
  Pause-AndExit 1
}

$languageConfigured = Test-WSLCommand -Distro $DistroName -Command "test -f $LangInstructionsWsl"
$needsLanguageSetup = -not $languageConfigured

if ($languageConfigured) {
  Write-Host ""
  if (Ask-YesNo "Quieres revisar o cambiar el idioma ahora?" $false) {
    $needsLanguageSetup = $true
  } else {
    $needsLanguageSetup = $false
    Write-Host "Idioma existente mantenido."

    $ensureLangConfigCmd = @'
set -e
mkdir -p "$HOME/.config/opencode"
if [ ! -f "$HOME/.config/opencode/opencode.lang.json" ]; then
  cat > "$HOME/.config/opencode/opencode.lang.json" <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": ["instructions-language.md"]
}
EOF
fi
'@

    try {
      Invoke-WSL -Distro $DistroName -Command $ensureLangConfigCmd | Out-Null
    } catch {
      Write-Host "ERROR: No se pudo asegurar la config de idioma."
      Pause-AndExit 1
    }
  }
}

if ($needsLanguageSetup) {
  Write-Host ""
  Write-Host "Seleccion de idioma para OpenCode"
  Write-Host "1) Espanol (recomendado)"
  Write-Host "2) English"
  Write-Host "3) Catalan"
  Write-Host "4) Otro"
  $langOpt = Read-Host "Elige una opcion [1-4] (por defecto 1)"
  if ([string]::IsNullOrWhiteSpace($langOpt)) {
    $langOpt = "1"
  }

  $languageLabel = "Espanol"
  switch ($langOpt) {
    "1" { $languageLabel = "Espanol" }
    "2" { $languageLabel = "English" }
    "3" { $languageLabel = "Catalan" }
    "4" {
      $custom = Read-Host "Escribe el idioma preferido"
      if (-not [string]::IsNullOrWhiteSpace($custom)) {
        $languageLabel = $custom.Trim()
      }
    }
    default { $languageLabel = "Espanol" }
  }

  $langSetupTemplate = @'
set -e
mkdir -p "$HOME/.config/opencode"
cat > "$HOME/.config/opencode/instructions-language.md" <<'EOF'
Responde siempre en __LANG__.
EOF
cat > "$HOME/.config/opencode/opencode.lang.json" <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": ["instructions-language.md"]
}
EOF
'@
  $langSetupCmd = $langSetupTemplate.Replace("__LANG__", $languageLabel)

  try {
    Invoke-WSL -Distro $DistroName -Command $langSetupCmd | Out-Null
    Write-Host "Idioma configurado: $languageLabel"
  } catch {
    Write-Host "ERROR: No se pudo guardar la configuracion de idioma."
    Pause-AndExit 1
  }
}

$authCheckCmd = @'
if [ -s "$HOME/.local/share/opencode/auth.json" ]; then
  if command -v python3 >/dev/null 2>&1; then
    python3 - <<'PY'
import json
import pathlib
import sys

path = pathlib.Path.home() / ".local" / "share" / "opencode" / "auth.json"
try:
  data = json.loads(path.read_text(encoding="utf-8"))
  if isinstance(data, dict) and len(data) > 0:
    sys.exit(0)
except Exception:
  pass
sys.exit(1)
PY
  else
    exit 0
  fi
else
  exit 1
fi
'@

$hasAuth = Test-WSLCommand -Distro $DistroName -Command $authCheckCmd
if (-not $hasAuth) {
  Write-Host ""
  Write-Host "No se detectaron credenciales validas de OpenCode en WSL."
  Write-Host "Para usar OpenCode Zen necesitas iniciar login."
  if (Ask-YesNo "Quieres iniciar login ahora con 'opencode auth login'?" $true) {
    & wsl.exe -d $DistroName -- bash -lc "opencode auth login"
    if ($LASTEXITCODE -ne 0) {
      Write-Host "Aviso: login no completado. Puedes hacerlo luego con: opencode auth login"
    }
  } else {
    Write-Host "Login omitido por ahora. Puedes hacerlo luego con: opencode auth login"
  }
}

$globalExists = Test-WSLCommand -Distro $DistroName -Command "test -f $GlobalConfigWsl"
$targetConfig = if ($globalExists) { $ZenConfigWsl } else { $GlobalConfigWsl }

Write-Host ""
Write-Host "Configurando modelo por defecto de OpenCode Zen"
Write-Host "Modelo: $DefaultModel"
Write-Host "Archivo destino: $targetConfig"

$replaceConfig = $true
$targetExists = Test-WSLCommand -Distro $DistroName -Command "test -f $targetConfig"
if ($targetExists) {
  $replaceConfig = Ask-YesNo "Ya existe $targetConfig. Reemplazar?" $false
}

if ($replaceConfig) {
  $configTemplate = @'
set -e
mkdir -p "$HOME/.config/opencode"
TARGET="__TARGET__"
if [ -f "$TARGET" ]; then
  TS="$(date +%Y%m%d-%H%M%S)"
  cp -f "$TARGET" "${TARGET}.bak-$TS"
fi
cat > "$TARGET" <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": ["instructions-language.md"],
  "model": "__MODEL__",
  "small_model": "__SMALL_MODEL__"
}
EOF
'@

  $configCmd = $configTemplate.Replace("__TARGET__", $targetConfig).Replace("__MODEL__", $DefaultModel).Replace("__SMALL_MODEL__", $SmallModel)

  try {
    Invoke-WSL -Distro $DistroName -Command $configCmd | Out-Null
    Write-Host "Config guardada en: $targetConfig"
  } catch {
    Write-Host "ERROR: No se pudo escribir la config de OpenCode."
    Pause-AndExit 1
  }
} else {
  Write-Host "Se mantiene la config existente."
}

Write-Host ""
if (Test-Path $LauncherSrc) {
  $copyLauncher = $true
  if (Test-Path $LauncherDst) {
    $copyLauncher = Ask-YesNo "Ya existe el launcher en el Escritorio. Reemplazar?" $false
    if ($copyLauncher) {
      $backupTs = Get-Date -Format "yyyyMMdd-HHmmss"
      try {
        Copy-Item -Path $LauncherDst -Destination ("{0}.bak-{1}" -f $LauncherDst, $backupTs) -Force
      } catch {
        Write-Host "ERROR: No se pudo crear backup del launcher actual."
        $copyLauncher = $false
      }
    }
  }

  if ($copyLauncher) {
    try {
      Copy-Item -Path $LauncherSrc -Destination $LauncherDst -Force
      Unblock-File -Path $LauncherDst -ErrorAction SilentlyContinue
      Write-Host "Launcher copiado al Escritorio:"
      Write-Host "  $LauncherDst"
    } catch {
      Write-Host "ERROR: No se pudo copiar el launcher al Escritorio."
    }
  } else {
    Write-Host "Se mantiene el launcher existente."
  }
} else {
  Write-Host "Aviso: aun no existe OpenCode Launcher.ps1 en esta carpeta."
}

Write-Host ""
Write-Host "Verificando estado final en WSL..."
& wsl.exe -d $DistroName -- bash -lc "opencode --version"
if ($LASTEXITCODE -ne 0) {
  Write-Host "ERROR: opencode --version fallo al final de la instalacion."
  Pause-AndExit 1
}

& wsl.exe -d $DistroName -- bash -lc "opencode auth list" *> $null
if ($LASTEXITCODE -ne 0) {
  Write-Host "Aviso: no se pudieron listar credenciales."
  Write-Host "Si falta login, ejecuta en WSL: opencode auth login"
}

Write-Host ""
Write-Host "Listo. OpenCode en WSL esta preparado."
Write-Host "Siguiente paso: abrir el launcher y seleccionar tu carpeta de trabajo de Windows."
Pause-AndExit 0
