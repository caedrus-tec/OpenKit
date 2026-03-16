# OpenKit

OpenKit es un instalador y acceso directo para OpenCode CLI en macOS. Su objetivo es
dar una experiencia simple para usuarios no tecnicos: doble clic, Terminal
visible y pasos guiados.

## Objetivos de experiencia de uso

- Terminal visible en todo momento
- Mensajes en espanol (ASCII, sin acentos)
- Valores por defecto seguros; sin acciones destructivas silenciosas
- Flujo lineal y claro para usuarios no tecnicos

## Estado del proyecto

- Ver estado actualizado en `memsys3/memory/project-status.yaml`

## Estructura del repositorio

- `openkit_installer/`: scripts de instalacion y acceso directo para macOS
- `memsys3/`: memoria persistente para contexto del agente

## Ciclo de distribucion (GitHub)

Este repositorio es el remoto de desarrollo y correcciones de OpenKit. Los usuarios de prueba usan la
carpeta `openkit_installer/` descargada desde GitHub.

Flujo:

1) Actualizamos scripts y documentacion en `openkit_installer/`.
2) Subimos cambios a `https://github.com/caedrus-tec/OpenKit.git`.
3) El usuario de prueba descarga el ZIP del repositorio desde GitHub.
4) Entra a `openkit_installer/` y sigue `openkit_installer/README.md`.

Nota: no se comparte un ZIP externo; GitHub genera el ZIP automaticamente.

## Uso rapido (desarrollo)

1) Abre `openkit_installer/OpenCode Installer.command`
2) Sigue los pasos en la Terminal
3) Se copiara el acceso directo al Escritorio
4) Abre `~/Desktop/OpenCode Launcher.command` y elige una carpeta

Para guia paso a paso para usuarios de prueba, ver `openkit_installer/README.md`.

## Configuracion y datos

- Autenticacion: `~/.local/share/opencode/auth.json`
- Configuracion principal: `~/.config/opencode/opencode.json`
- Configuracion local (si existe principal): `~/.config/opencode/opencode.ollama.json`
- Idioma: `~/.config/opencode/instructions-language.md`
- Configuracion de idioma remoto: `~/.config/opencode/opencode.lang.json`
- Preferencia instalador (sin pausa): `~/.config/opencode/installer-no-pause`
- Acceso directo: `~/Desktop/OpenCode Launcher.command`

## Modo local (Ollama)

- Modelo por defecto: `qwen2.5-coder:14b`
- Tamano del modelo: ~8-9 GB
- Total estimado (Ollama + OpenCode + modelo): ~9-11 GB
- Espacio libre recomendado para descargar el modelo: ~12 GB

## Pruebas basicas

No hay sistema de pruebas. Para verificacion basica:

```bash
bash -n "openkit_installer/OpenCode Installer.command"
bash -n "openkit_installer/OpenCode Launcher.command"
```

## Notas para agentes (memsys3)

memsys3 es una herramienta de memoria persistente para dar contexto al agente.
No es el producto; el foco principal es OpenKit.

- Iniciar sesion con `@memsys3/prompts/newSession.md`
- Registrar cambios en `memsys3/memory/full/sessions.yaml`
- Mantener `memsys3/memory/project-status.yaml` actualizado
- Si hay decisiones importantes, agregar ADR en `memsys3/memory/full/adr.yaml`
- Compilar contexto con `@memsys3/prompts/compile-context.md` cuando aplique

## Convenciones clave para scripts

- Mantener `#!/bin/bash`
- Citar rutas y variables: `"$VAR"`
- Usar `command -v` para detectar herramientas
- Usar `read -r -p` para preguntas
- Forzar PATH con `/opt/homebrew/bin` y `/usr/local/bin`
- No sobrescribir configuraciones del usuario sin comprobaciones
