# memsys3 — Referencia Técnica

Sistema de gestión de contexto para agentes de IA. Proporciona memoria persistente entre sesiones, documentación estructurada y protocolos de colaboración multi-agente. Agnóstico de modelo: funciona con Claude, Gemini, Codex o cualquier LLM que entienda Markdown.

---

## Sistema de Memoria

El Context Agent lee todo el histórico y genera `context.yaml` — un archivo compacto (~2500-3000 tokens, máx 2000 líneas) que cualquier agente carga al iniciar sesión.

### Archivos

```
memsys3/memory/
├── context.yaml          — contexto compilado (lo que lee el agente)
├── project-status.yaml   — estado actual del proyecto
└── full/
    ├── sessions.yaml     — histórico de sesiones
    ├── adr.yaml          — decisiones arquitectónicas
    └── sessions_N.yaml   — rotaciones anteriores
```

### Flujo

1. **Desarrollar** — el agente trabaja y documenta con `endSession.md`
2. **Compilar** — el Context Agent ejecuta `compile-context.md` y genera `context.yaml`
3. **Iniciar** — el agente carga `newSession.md` que lee `context.yaml`

### Rotación automática (>1800 líneas)

Cuando `sessions.yaml` o `adr.yaml` superan 1800 líneas, se rotan: `sessions.yaml` → `sessions_N.yaml`, y se crea uno nuevo vacío. El Context Agent lee todos los archivos rotados hasta detectar >150K tokens.

### Plan de Contingencia (>150K tokens)

Cuando el histórico supera 150K tokens, el Context Agent archiva datos irrelevantes a `memory/history/` (no se lee), reduciendo a ~120K tokens.

### Pesos de sesión

| Peso | Líneas → context | Cuándo |
|------|-------------------|--------|
| ALTO | ~140 → ~35 | ADRs, decisiones arquitectónicas, features críticas |
| MEDIO | ~95 → ~20 | Features normales, refactorings |
| BAJO | ~70 → ~8 | Fixes menores, mantenimiento |

Sesiones sin campo `peso` se tratan como peso medio.

---

## Sessions y ADRs

### Sessions

Cada sesión se documenta en `memsys3/memory/full/sessions.yaml` al final con `endSession.md`.

Campos: `id`, `data`, `duracion`, `peso`, `titulo`, `highlights`, `features_implementadas`, `problemas_resueltos`, `decisions_presas`, `gotchas`, `proximos_pasos`.

**Gotchas:** errores críticos, warnings o traps. El Context Agent extrae los top 5 más críticos en `context.yaml` (máx 150 chars cada uno). Solo documentar los que rompen el sistema, son contra-intuitivos o se repiten.

Siempre usar `Edit tool` para añadir al principio del array — nunca `Write tool` (sobrescribiría el histórico).

### ADRs (Architecture Decision Records)

Decisiones arquitectónicas en `memsys3/memory/full/adr.yaml`. Crear ADR cuando: elegir librería/framework, cambiar arquitectura, decidir patrón de diseño, cambiar stack.

Campos: `id` (ADR-XXX), `titol`, `data`, `estat` (accepted/deprecated/superseded_by), `area`, `context`, `decisio`, `alternatives`, `consequencies`.

### Project Status

`project-status.yaml` documenta fase, features operativas, stack, URLs y pendientes. Se actualiza al final de cada sesión relevante. El bloque `metadata` incluye `memsys3_version` y `memsys3_deployed`.

---

## Backlog

Trabajo futuro en `memsys3/backlog/`, un archivo Markdown por item.

**Prefijos:** `ISSUE-XXX` (bugs), `FEATURE-XXX` (nueva funcionalidad), `IMPROVEMENT-XXX` (mejora), `SPEC-XXX` (especificación), `BLUEPRINT-XXX` (diseño alto nivel), `EXPLORATION-XXX` (investigación).

**Estados:** Propuesto → Abierto → En Progreso → Completado / Cancelado / Rechazado / Bloqueado. Nunca borrar items completados.

Gestionar con `@memsys3/prompts/backlog.md`. Los pendientes prioritarios se reflejan en `project-status.yaml` y en `context.yaml`.

---

## Meets

Reuniones colaborativas entre agentes mediante archivo Markdown compartido con turnos y polling.

**Cuándo:** dos agentes tocan el mismo código, conflicto que requiere coordinación, decisión multi-agente, análisis forense. **No usar** si el moderador puede resolver por chat.

**Naming:** `memsys3/docs/meets/YYYYMMDD_N.md`

**Flujo:** convocante crea archivo con briefing → moderador pasa el path → agentes se turnan escribiendo → polling autónomo entre turnos → ambos escriben CIERRE → moderador escribe Decisión.

**Checklist obligatorio tras cada turno:** (1) ESCRIBIR turno en archivo, (2) RESUMIR en chat con CTA + Detalle + Polling, (3) POLLING en background esperando al otro agente.

Referencia completa: `@memsys3/prompts/meet.md`

---

## Agent Identity

El `agent_id` es el nombre que el moderador asigna a una sesión: `Agent A`, `Agent B`, etc. Identidad conversacional, no ID técnico.

**Uso:** reuniones, documentación de sesiones paralelas, trabajo multi-agente simultáneo.

**Persistencia entre compacts:** `echo "Agent B" > /tmp/memsys3_agent_b.md`. Se verifica en `endSession` (paso 4.5). Si se pierde (reinicio), el moderador lo reasigna.

**Alcance:** específico de la sesión, no del proyecto.

Asignar con `@memsys3/prompts/agent-identity.md`.

---

## Deployment y Actualización

### Instalación inicial

`@memsys3/prompts/deploy.md` — clona, copia estructura, briefing con usuario, personaliza `project-status.yaml` y `newSession.md`, configura `.gitignore`.

### Actualización

`@memsys3/prompts/actualizar.md` — bootstrap (sobrescribe prompt local con versión del repo), verifica working directory, backup con rsync, copia archivos del sistema, preserva histórico.

### Migración de proyectos (preservar historial Claude Code)

> Aplica a **Claude Code CLI**. claude.ai guarda historial en la nube y no necesita migración.

Claude Code guarda sesiones en `~/.claude/projects/[hash-del-path]/`. El hash se genera reemplazando `/` por `-` en la ruta absoluta del proyecto. Dentro hay `.jsonl` (transcripciones) y `memory/` (MEMORY.md).

**Pasos:**

0. Identificar el hash actual:
   ```bash
   ls ~/.claude/projects/ | grep nombre-proyecto
   ```
1. Copiar proyecto al nuevo path (NO mover — mantener fallback)
2. Calcular hash del nuevo path (mismo algoritmo: `/` → `-`)
3. Copiar historial:
   ```bash
   cp -r ~/.claude/projects/[hash-antiguo]/. ~/.claude/projects/[hash-nuevo]/
   ```
4. Abrir Claude Code desde el nuevo path
5. Verificar con `/resume` que el historial está disponible
6. Eliminar path antiguo solo tras verificación

**Ejemplo completo:**
```bash
# Proyecto original: /mnt/c/Users/User/Documents/Mi Proyecto/
# Proyecto nuevo: /home/user/mi-proyecto/

# Paso 0: identificar hash
ls ~/.claude/projects/ | grep "Mi-Proyecto"
# → -mnt-c-Users-User-Documents-Mi-Proyecto

# Paso 1: copiar proyecto
cp -r "/mnt/c/Users/User/Documents/Mi Proyecto/." /home/user/mi-proyecto/

# Paso 3: copiar historial Claude Code
cp -r ~/.claude/projects/-mnt-c-Users-User-Documents-Mi-Proyecto/. \
      ~/.claude/projects/-home-user-mi-proyecto/

# Paso 4-5: verificar
cd /home/user/mi-proyecto && claude
# Dentro de Claude Code: /resume → debería mostrar sesiones anteriores
```

**Edge cases:**
- Espacios en path → guiones en hash
- Hash de destino preexistente → historiales se mezclan, no se pierden
- `memory/` se incluye en la copia (es parte de la carpeta del hash)

**Limitaciones:** solo verificado en Linux/WSL. macOS: misma estructura esperada (no verificado). Windows nativo: convención de hash desconocida.

### Privacidad

Opción A (recomendado): excluir `memsys3/` de git (contexto privado). Opción B: incluir (compartir entre equipo).

---

## Herramientas Opcionales (Claude Code)

### Statusline

Muestra modelo y uso de contexto en la línea de estado. Se configura en `~/.claude/settings.json` apuntando a `~/.claude/statusline.sh`. Se actualiza con mensajes regulares del usuario.

### Comandos globales

`@memsys3/prompts/commands.md` instala en `~/.claude/commands/`:
- `/deploy-memsys3` — deployment inicial
- `/actualizar-memsys3` — actualización
<!-- version: 0.1.0 -->
