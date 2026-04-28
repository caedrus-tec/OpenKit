# OpenKit Instaladores (macOS + Windows WSL)

OpenKit esta pensado para facilitar el uso de OpenCode al usuario medio,
con instalacion guiada y launcher de doble clic para abrir proyectos.

## Estructura del repositorio

- `openkit_installer/`: instalador, launcher y desinstalador para macOS.
- `OpenKit_WSL/`: instalador y launcher para Windows usando WSL.
- `memsys3/`: memoria y documentacion interna del proyecto.
- `README.md`: guia general de uso.

## Como empezar

1) En GitHub, descarga el ZIP con el boton verde `Code`.
2) Descomprime el ZIP.
3) Entra a la carpeta descargada.
4) Elige tu plataforma.

### macOS

1) Entra a `openkit_installer/`.
2) Doble clic en `OpenCode Installer.command`.
3) Si macOS lo bloquea, clic derecho > Abrir.
4) Sigue los pasos en Terminal.
5) Al final tendras `OpenCode Launcher.command` en el Escritorio.
6) Doble clic en el launcher, elige carpeta y OpenCode iniciara.

### Windows + WSL

1) Entra a `OpenKit_WSL/`.
2) Ejecuta `OpenCode Installer.ps1`.
   - Si PowerShell bloquea scripts, usa:
     `powershell -ExecutionPolicy Bypass -File ".\OpenCode Installer.ps1"`
3) Sigue el asistente.
4) Al final tendras `OpenCode Launcher.ps1` en el Escritorio.
5) Ejecuta el launcher y elige una carpeta de Windows.
6) OpenCode se abrira en WSL sobre esa misma carpeta (`/mnt/c/...`).

## QA rapido

- macOS: ver `openkit_installer/QA_OPENKIT.txt`
- Windows + WSL: ver `OpenKit_WSL/QA_OPENKIT.txt`

## Si algo falla

- macOS dice "danado" o no deja abrir: ejecuta `xattr -dr com.apple.quarantine "NOMBRE_DE_LA_CARPETA"` y reintenta.
- No aparece el selector de carpetas: revisa permisos de Automatizacion/AppleScript.
- Ollama no abre en modo local: abre la aplicacion manualmente y vuelve a probar.
- WSL no esta inicializado: abre Ubuntu una vez, crea usuario Linux y vuelve a ejecutar el installer.

## Soporte rapido

- Si falta OpenCode: vuelve a ejecutar el installer de tu plataforma.
- Si queres modo local en macOS: el modelo recomendado es `qwen2.5-coder:14b`.
- Config principal: `~/.config/opencode/opencode.json`
- Auth: `~/.local/share/opencode/auth.json`

---

Hecho por Victor, desarrollador freelancer. Gracias por probar OpenKit.
