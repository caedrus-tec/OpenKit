# OpenKit Instalador (macOS Sonoma)

Objetivo: instalar OpenCode y dejar un acceso directo en el Escritorio para abrir
proyectos con doble clic y Terminal visible.

Este documento es la guia principal para usuarios de prueba.

## Ciclo completo (de GitHub a primer uso)

1) :inbox_tray: En GitHub, abre el repositorio y descarga el ZIP con el boton verde "Code".
2) :package: Descomprime el ZIP en tu Mac.
3) :open_file_folder: Entra a la carpeta descargada.
   Nota: GitHub suele cambiar el nombre de la carpeta al descomprimir el ZIP.
4) :hammer_and_wrench: Doble clic en `OpenCode Installer.command`.
5) :unlock: Si macOS lo bloquea, clic derecho > Abrir.
6) :speech_balloon: Sigue los pasos en la Terminal (Homebrew, idioma, modo local o remoto, descarga de modelo si aplica).
7) :desktop_computer: Al final veras `OpenCode Launcher.command` en el Escritorio.
8) :rocket: Doble clic en el acceso directo `OpenCode Launcher.command`, elige una carpeta, y OpenCode se abre en esa carpeta.

Sugerencia para tu primer mensaje en OpenCode: "Resume este proyecto y lista los archivos principales."

## Si algo falla (soluciones rapidas)

- :warning: macOS dice "danado" o no deja abrir: abre Terminal y ejecuta `xattr -dr com.apple.quarantine "NOMBRE_DE_LA_CARPETA"`, luego reintenta.
- :warning: macOS vuelve a bloquear: clic derecho > Abrir y confirma.
- :warning: No aparece el selector de carpetas: revisa permisos de Automatizacion/AppleScript y reintenta.
- :warning: Ollama no abre en modo local: abre la aplicacion Ollama manualmente y vuelve a abrir el acceso directo.
- :warning: OpenCode no esta instalado: ejecuta de nuevo `OpenCode Installer.command`.

## Modo local (Ollama)

- Modelo recomendado: `qwen2.5-coder:14b`
- Espacio del modelo: ~8-9 GB
- Total aproximado (Ollama + OpenCode + modelo): ~9-11 GB
- Espacio libre recomendado para descargar: ~12 GB

## Datos y configuracion (para soporte)

- Autenticacion: `~/.local/share/opencode/auth.json`
- Configuracion principal: `~/.config/opencode/opencode.json`
- Configuracion local (si existe principal): `~/.config/opencode/opencode.ollama.json`
- Idioma: `~/.config/opencode/instructions-language.md`
- Configuracion de idioma remoto: `~/.config/opencode/opencode.lang.json`
- Preferencia instalador (sin pausa): `~/.config/opencode/installer-no-pause`
- Acceso directo: `~/Desktop/OpenCode Launcher.command`

---

Hecho por Victor, desarrollador freelancer. Gracias por probar OpenKit.
