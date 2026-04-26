# migrate.md — Migrar proyecto preservando historial Claude Code

> Aplica a **Claude Code CLI**. claude.ai guarda historial en la nube y no necesita migración.

## Cómo funciona el historial

Claude Code guarda sesiones en `~/.claude/projects/[hash-del-path]/`. El hash se genera reemplazando `/` por `-` en la ruta absoluta del proyecto.

Contenido de la carpeta:
- `.jsonl` — transcripciones de sesiones
- `memory/` — MEMORY.md del proyecto

## Instrucciones

### 1. Identificar el hash actual

```bash
ls ~/.claude/projects/ | grep nombre-proyecto
```

### 2. Confirmar con el usuario

Pregunta:
- **Path origen** (proyecto actual)
- **Path destino** (dónde quiere moverlo)

### 3. Copiar proyecto

```bash
# SIEMPRE copiar, NO mover — mantener fallback
cp -r "[path-origen]/." "[path-destino]/"
```

### 4. Calcular hash del nuevo path

Algoritmo: reemplazar `/` por `-` en el path absoluto de destino.

Ejemplo: `/home/user/mi-proyecto/` → `-home-user-mi-proyecto`

### 5. Copiar historial de Claude Code

```bash
cp -r ~/.claude/projects/[hash-antiguo]/. ~/.claude/projects/[hash-nuevo]/
```

### 6. Verificar

```bash
cd "[path-destino]" && claude
# Dentro de Claude Code: /resume → debería mostrar sesiones anteriores
```

### 7. Limpieza (solo tras verificación)

Confirmar con el usuario antes de eliminar:
- El proyecto en el path antiguo
- La carpeta `~/.claude/projects/[hash-antiguo]/`

## Edge cases

- Espacios en path → guiones en hash
- Hash de destino preexistente (porque se abrió Claude Code antes de copiar) → historiales se mezclan, no se pierden
- `memory/` se incluye en la copia (es parte de la carpeta del hash)
- Si el proyecto tiene memsys3, verificar que `memsys3/` se copió correctamente

## Limitaciones

- Solo verificado en Linux/WSL
- macOS: misma estructura esperada (no verificado)
- Windows nativo: convención de hash desconocida
<!-- version: 0.1.0 -->
