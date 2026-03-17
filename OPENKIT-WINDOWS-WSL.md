# Manual de trabajo - OpenKit Windows + WSL

Este documento es el manual operativo para el proximo agente. Objetivo: definir e implementar un flujo OpenKit para Windows que priorice estabilidad y rendimiento usando WSL. El proyecto debe vivir en el filesystem de WSL (no en /mnt/c). Windows solo se usa para importar carpetas al inicio y exportar resultados al final.

## Principios y criterios

- Estabilidad y rendimiento por encima de comodidad visual.
- Evitar trabajo directo en `/mnt/c` por rendimiento, permisos, symlinks y case-sensitivity.
- Exportar solo resultados finales al Escritorio de Windows.
- Mensajes en Espanol ASCII (sin acentos) y con prompts cortos.
- Terminal visible, defaults seguros, sin acciones destructivas silenciosas.

## Resultado esperado (alto nivel)

1) Installer en Windows prepara WSL2, instala OpenCode dentro de WSL y configura idioma/opciones.
2) Launcher en Windows permite:
   - Importar carpeta Windows -> WSL.
   - Abrir proyecto ya importado en OpenCode (dentro de WSL).
   - Exportar resultados a Escritorio de Windows.

## Estructura propuesta de archivos

- `openkit_installer/OpenCode Installer.ps1` (Windows)
- `openkit_installer/OpenCode Launcher.ps1` o `.cmd`
- `openkit_installer/wsl/install-opencode.sh` (script ejecutado dentro de WSL)

## Flujo detallado por bloques (equivalente al installer macOS)

### Bloque A - Deteccion e instalacion de WSL

Objetivo: asegurar WSL2 con Ubuntu listo.

Acciones:
- Verificar `wsl --status`. Si falla, informar y pedir permisos admin.
- Forzar WSL2: `wsl --set-default-version 2`.
- Verificar distro Ubuntu:
  - Si no existe: `wsl --install -d Ubuntu`.
  - Avisar que puede requerir reinicio y primera ejecucion para crear usuario.

Mensajes recomendados:
- "WSL no esta instalado. Se instalara WSL2 y Ubuntu. Esto puede requerir reinicio."
- "Abre Ubuntu una vez para crear tu usuario y vuelve aqui."

### Bloque B - Instalacion de OpenCode en WSL

Objetivo: instalar OpenCode y verificar version dentro de WSL.

Acciones:
- Ejecutar un script bash en WSL, por ejemplo:
  - Descargar instalador a temporal.
  - Confirmacion previa de seguridad.
  - Ejecutar instalacion.
- Verificar `opencode --version` con `wsl -d Ubuntu -- bash -lc 'opencode --version'`.

### Bloque C - Idioma

Objetivo: configurar idioma en WSL sin sobrescribir si ya existe.

Acciones:
- Usar rutas WSL: `~/.config/opencode/instructions-language.md` y `opencode.lang.json`.
- Si ya existe idioma, preguntar si se desea cambiar.
- Escribir JSON con `$schema` y `instructions`.

### Bloque D - Auth y modo local (Ollama)

Objetivo: habilitar modo local si no hay credenciales.

Acciones:
- Validar `~/.local/share/opencode/auth.json` dentro de WSL (python3 si existe).
- Si no hay auth, ofrecer modo local con Ollama.

Decision recomendada (estabilidad): instalar Ollama en WSL.
- Instalar Ollama en WSL (con prompts y validaciones).
- Iniciar `ollama serve` (o `systemd` si WSL lo soporta).
- Verificar espacio libre con `df -k` en `~/.ollama/models`.

Configurar OpenCode:
- Escribir `opencode.json` o `opencode.ollama.json` segun reglas actuales.
- Provider `ollama` con `baseURL` `http://localhost:11434/v1`.

### Bloque E - Login remoto opcional

Objetivo: permitir login remoto si el usuario lo prefiere.

Acciones:
- Mostrar URLs con `Start-Process` (PowerShell) o `cmd.exe /c start`.
- Ejecutar `opencode auth login` dentro de WSL.

### Bloque F - Launcher Windows (import/open/export)

Objetivo: flujo simple para usuarios no tecnicos.

#### Importar
- Selector de carpeta en Windows.
- Copiar a WSL:
  - Destino: `/home/<user>/openkit-workspaces/<nombre>`.
- Guardar metadata:
  - Archivo `.openkit-meta.json` con:
    - `source_windows_path`
    - `import_ts`
    - `wsl_path`

#### Abrir
- Listar proyectos importados.
- Ejecutar `opencode` en WSL con `cd` al path.

#### Exportar resultados
- Buscar carpetas comunes: `dist/`, `out/`, `build/`, `export/`.
- Si existe una, copiar a `Desktop/OpenKit-Export-YYYYMMDD-HHMM`.
- Si no existe, permitir seleccionar carpeta a exportar.

### Bloque G - Onboarding final

Mensajes clave:
- "Tu proyecto vive en WSL para mayor estabilidad y velocidad."
- "No edites la carpeta original en Windows."
- "Para compartir resultados usa Exportar."

## Cambios recomendados en README

- Agregar seccion Windows + WSL con pasos de instalacion.
- Explicar el flujo de importacion/exportacion.
- Aclarar que el proyecto vive en WSL.

## Checklist de verificacion (para la sesion)

- [ ] WSL2 instalado y Ubuntu inicializado.
- [ ] OpenCode instalado en WSL y `opencode --version` ok.
- [ ] Idioma configurado en WSL.
- [ ] Launcher importa carpeta Windows y abre OpenCode en WSL.
- [ ] Exportar resultados copia archivos al Escritorio de Windows.
- [ ] Mensajes en Espanol ASCII y prompts claros.

## Riesgos y mitigaciones

- Usuario edita carpeta en Windows -> onboarding + warning claro.
- Doble uso de disco -> explicar que la copia en WSL es necesaria.
- Problemas de permisos -> mantener todo en WSL.

## Decisiones pendientes (si hace falta)

- Distro default: Ubuntu 22.04 vs 24.04.
- Metodo Ollama: WSL vs Windows (recomendado WSL por estabilidad).
- Ubicacion del flag de "no pausa" (Windows o WSL).
