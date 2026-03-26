# OpenKit Instaladores (macOS + Windows WSL)

OpenKit esta pensado para facilitar el uso de OpenCode al usuario medio (no tecnico),
con instalacion guiada y launcher de doble clic para abrir proyectos.

En este repositorio encontraras dos opciones, segun plataforma.

## Estructura del repositorio

- `OpenKit_Mac/`: instalador y launcher para macOS Sonoma.
- `OpenKit_WSL/`: instalador y launcher para Windows usando WSL.
- `README.md`: guia general de uso.

## Como empezar

1) En GitHub, descarga el ZIP con el boton verde `Code`.
2) Descomprime el ZIP.
3) Entra a la carpeta descargada.
4) Elige tu plataforma:

### macOS (OpenKit_Mac)

1) Entra a `OpenKit_Mac/`.
2) Doble clic en `OpenCode Installer.command`.
3) Si macOS lo bloquea, clic derecho > Abrir.
4) Sigue los pasos en terminal.
5) Al final tendras `OpenCode Launcher.command` en el Escritorio.
6) Doble clic en el launcher, elige carpeta y OpenCode iniciara.

### Windows + WSL (OpenKit_WSL)

1) Entra a `OpenKit_WSL/`.
2) Ejecuta `OpenCode Installer.ps1`.
   - Si PowerShell bloquea scripts, usa:
     `powershell -ExecutionPolicy Bypass -File ".\OpenCode Installer.ps1"`
3) Sigue el asistente (WSL, OpenCode, idioma y config Zen por defecto).
4) Al final tendras `OpenCode Launcher.ps1` en el Escritorio.
5) Ejecuta el launcher y elige una carpeta de Windows.
6) OpenCode se abrira en WSL sobre esa misma carpeta (`/mnt/c/...`), sin copiar archivos.

## QA rapido

- macOS: ver `OpenKit_Mac/QA_OPENKIT.txt`
- Windows + WSL: ver `OpenKit_WSL/QA_OPENKIT.txt`

## Soporte rapido

- Si falta OpenCode: vuelve a ejecutar el installer de tu plataforma.
- Si falla selector de carpeta: revisa permisos del sistema y reintenta.
- Si WSL no esta inicializado: abre Ubuntu una vez, crea usuario Linux y vuelve a ejecutar installer.

---

Hecho por Victor, desarrollador freelancer. Gracias por probar OpenKit.
