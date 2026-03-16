# End Session - Documenta la Sesión Actual

Tu (DevAgent) debes documentar esta sesión de trabajo en el sistema Memory del proyecto.

## Objetivo

Registrar qué se ha hecho durante esta sesión para que el próximo DevAgent tenga contexto completo.

## Workflow

### 0. Localizar memsys3 (CHECKPOINT CRÍTICO)

**Antes de cualquier operación**, verifica que memsys3 existe y obtén su ruta:

```bash
MEMSYS=$(find . -maxdepth 3 -name "memsys3" -type d 2>/dev/null | grep -v node_modules | head -1)

if [ -z "$MEMSYS" ]; then
  echo "❌ ERROR: memsys3 no encontrado en este proyecto"
  echo "¿Has desplegado memsys3? Ejecuta: @memsys3/prompts/deploy.md"
else
  echo "✅ memsys3 encontrado en: $MEMSYS"
  ls "$MEMSYS/memory/full/sessions.yaml" && echo "✅ sessions.yaml OK" || echo "❌ sessions.yaml no encontrado"
fi
```

**Si el comando no devuelve ruta:** detén la ejecución, memsys3 no está desplegado.

**⚠️ Importante:** Las variables bash NO persisten entre tool calls. Cada bloque de código redefine `MEMSYS` con este mismo `find`.

### 1. Recopilar Evidencias Objetivas

Recopila evidencias de qué se ha hecho:

```bash
# Git (si disponible)
git status && git diff --stat && git log --oneline -5

# Archivos modificados (ajusta -mmin según duración sesión)
find . -type f -mmin -180 -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/dist/*'

# Bash history
history | tail -30
```

**Notas:** Estas evidencias son opcionales pero recomendadas. Si alguna falla, continúa con tu contexto interno.

### 2. Auto-analizar la Sesión

Identifica:
- **Features/Tareas**: Qué has implementado, bugs resueltos, refactorings
- **Problemas Resueltos**: Obstáculos encontrados y cómo los has solucionado
- **Decisiones Tomadas**: Decisiones técnicas o arquitectónicas (importantes → ADR)
- **Tech añadida/eliminada**: Dependencies, tools y por qué
- **Deployments**: URLs, servicios desplegados
- **Gotchas**: Errores críticos, warnings, traps encontrados durante la sesión (con criticidad)
- **Próximos Pasos**: Qué queda pendiente

### 2.5. Evaluar Peso de la Sesión

Antes de documentar, determina la importancia arquitectónica de esta sesión:

**🔴 PESO ALTO (~140 líneas):**
- Creaste/actualizaste ADRs importantes
- Decisiones arquitectónicas fundamentales
- Features críticas del core del proyecto
- Cambios de stack tecnológico
- Bugs críticos con gotchas importantes

**🟡 PESO MEDIO (~95 líneas):**
- Features normales dentro del scope
- Refactorings significativos
- Mejoras de features existentes
- Bugs moderados resueltos

**🟢 PESO BAJO (~70 líneas):**
- Fixes menores, typos, mantenimiento
- Cambios cosméticos (CSS, UI tweaks)
- Trabajo fuera del scope principal
- Setup/configuración inicial

**Ajusta la densidad de documentación según el peso:**

| Peso | Densidad | Qué Incluir | Qué Omitir |
|------|----------|-------------|------------|
| BAJO | ~70 líneas | Highlights concisos (3-5 bullets) | Detalles técnicos, decisiones menores |
| MEDIO | ~95 líneas | Highlights + decisions + gotchas | Contexto extenso, alternativas descartadas |
| ALTO | ~140 líneas | Contexto completo, justificaciones, alternativas | Nada - documenta exhaustivamente |

**Notas importantes:**
- Las líneas son **orientativas, no rígidas** - usa tu criterio según contenido real
- Si dudas entre dos pesos, elige el menor (evita inflar importancia)
- El Context Agent puede auditar y sugerir ajustes (FEATURE-007)

### 3. Comprobar Rotaciones Automáticas

**IMPORTANTE: Rotación flexible según líneas totales**

```bash
MEMSYS=$(find . -maxdepth 3 -name "memsys3" -type d 2>/dev/null | grep -v node_modules | head -1)
wc -l "$MEMSYS/memory/full/sessions.yaml"
```

**Escenario A: 1800 < líneas < 2000** (Rotación LITE después de documentar)
```bash
MEMSYS=$(find . -maxdepth 3 -name "memsys3" -type d 2>/dev/null | grep -v node_modules | head -1)
# 1. Documentar sesión normalmente en sessions.yaml (paso 4)
# 2. DESPUÉS de documentar, si supera 1800 líneas:
ls "$MEMSYS/memory/full/sessions_"*.yaml 2>/dev/null  # Encontrar próximo número
cp "$MEMSYS/memory/full/sessions.yaml" "$MEMSYS/memory/full/sessions_N.yaml"  # Copiar completo
wc -l "$MEMSYS/memory/full/sessions_N.yaml"  # Verificar (debe incluir sesión actual)
# 3. Crear nuevo sessions.yaml VACÍO (solo header YAML):
# sessions:
```

**Escenario B: líneas > 2000** (Rotación PRE-documentar)
```bash
MEMSYS=$(find . -maxdepth 3 -name "memsys3" -type d 2>/dev/null | grep -v node_modules | head -1)
# 1. ANTES de documentar, rotar:
ls "$MEMSYS/memory/full/sessions_"*.yaml 2>/dev/null  # Encontrar próximo número
cp "$MEMSYS/memory/full/sessions.yaml" "$MEMSYS/memory/full/sessions_N.yaml"  # Copiar
wc -l "$MEMSYS/memory/full/sessions_N.yaml"  # Verificar (sin sesión actual)
# 2. Crear nuevo sessions.yaml vacío (solo header YAML)
# 3. Documentar sesión actual en sessions.yaml NUEVO (desde cero)
```

**adr.yaml (mismo proceso):**
```bash
MEMSYS=$(find . -maxdepth 3 -name "memsys3" -type d 2>/dev/null | grep -v node_modules | head -1)
wc -l "$MEMSYS/memory/full/adr.yaml"
# Aplicar Escenario A o B según líneas
```

**Ventajas rotación flexible:**
- ✅ No rotación rígida en 1800 (aprovecha espacio 1800-2000)
- ✅ Evita duplicación (sesión actual solo en un archivo)
- ✅ Solo rota cuando REALMENTE necesario (>2000)

### 4. Documentar

**A. Añadir Sesión a `memsys3/memory/full/sessions.yaml`:**

Usa **Edit tool** para añadir tu sesión al PRINCIPIO del array:

```
old_string: "sessions:"
new_string: "sessions:
  - id: YYYY-MM-DD-titulo-descriptivo
    data: YYYY-MM-DD
    duracion: ~Xh
    peso: bajo|medio|alto  # Evaluado en PASO 2.5
    titulo: Título conciso
    highlights:
      - [tu contenido aquí]
    ..."
```

⚠️ **NO uses Write tool** → sobrescribiría todas las sesiones previas y rompería el sistema de memoria del proyecto.

**Guía de contenido según peso:**

- **Peso BAJO (~70 líneas):**
  - Solo highlights (3-5 bullets concisos)
  - Omitir secciones features_implementadas, problemas_resueltos si son triviales
  - Mención breve de próximos_pasos

- **Peso MEDIO (~95 líneas):**
  - Usa `memsys3/memory/templates/sessions-template.yaml` como referencia
  - Highlights + features_implementadas + problemas_resueltos + decisions
  - Secciones completas pero sin contexto extenso
  - Gotchas solo si son relevantes

- **Peso ALTO (~140 líneas):**
  - Documentación exhaustiva y completa
  - Contexto de decisiones (por qué, alternativas consideradas)
  - Justificaciones detalladas, trade-offs aceptados
  - Vincular con ADRs creadas (campo adr_relacionada)

**General (todos los pesos):**
- ID y data: YYYY-MM-DD de hoy
- Título descriptivo y conciso
- **⚠️ NO crear archivos detallados en `memory/history/`** - toda la info va DIRECTAMENTE en sessions.yaml
- **Importante**: `memory/history/` es SOLO para archivado del Plan de Contingencia (cuando full/ supera 150K tokens), NO para sesiones normales
- **IMPORTANTE - Gotchas**: Si has encontrado errores críticos, warnings o traps:
  - Documentarlos en el campo `gotchas:` de la sesión
  - Incluir: `tipus`, `problema`, `solucio`, `criticitat` (alta|media|baja)
  - Solo gotchas relevantes (errores que rompen, contra-intuitivos, recurrentes)
  - Context-Agent extraerá los top 5 más críticos de TODAS las sesiones

**B. Crear ADRs si hace falta (en `memsys3/memory/full/adr.yaml`):**

Solo si has tomado **decisiones arquitectónicas importantes**:
- Elegir librería/framework en lugar de otro
- Cambiar arquitectura del sistema
- Decidir patrón de diseño
- Cambiar stack tecnológico

**NO crear ADR para:**
- Cambios cosméticos (colores, padding)
- Validaciones de formularios
- Bugs menores
- Refactorings de funciones

Si creas ADR:
1. Comprobar rotación adr.yaml (paso 3)
2. Usar `memsys3/memory/templates/adr-template.yaml`
3. Linkear ADR desde sesión (campo `adr_relacionada`)

**C. Actualizar `memsys3/memory/project-status.yaml`:**
- `metadata.ultima_actualitzacio`: Fecha de hoy
- `metadata.actualitzat_per`: "Claude (Session [Título])"
- `estat_actual.ultima_feature`: Si has completado feature
- `features`: Cambiar `estat: operatiu` si se ha completado
- `historic_sessions`: Añadir entrada resumida
- `pendientes_prioritarios`: Actualizar según próximos pasos

### 4.5. Persistir agent_id (si aplica)

Si tienes un `agent_id` asignado en esta sesión (ej: "Agent B", "Agent A"), verifica que esté guardado:

```bash
# Verifica que esté guardado (persiste entre sesiones y compacts)
cat ~/.claude/memsys3_agent_id 2>/dev/null || echo "Agent B" > ~/.claude/memsys3_agent_id
```

Esto garantiza que tras un `/compact` o reinicio puedas recuperar tu identidad leyendo ese archivo.

### 5. Verificar estado de compile-context

```bash
MEMSYS=$(find . -maxdepth 3 -name "memsys3" -type d 2>/dev/null | grep -v node_modules | head -1)
ultima=$(grep "ultima_compilacion:" "$MEMSYS/memory/context.yaml" | head -1 | sed 's/.*"\(.*\)".*/\1/')
sesiones_sin_compilar=$(grep "^  - id:" "$MEMSYS/memory/full/sessions.yaml" | awk -F'"' '{print $2}' | while read id; do
  fecha=$(echo "$id" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}')
  [ "$fecha" \> "$ultima" ] && echo "$id"
done | wc -l)
echo "Ultima compilacion: $ultima"
echo "Sesiones sin compilar: $sesiones_sin_compilar"
[ "$sesiones_sin_compilar" -ge 5 ] && echo "AVISO: 5+ sesiones sin compilar" || echo "OK"
```

Si hay 5 o más sesiones sin compilar, avisar al usuario:

```
⚠️ context.yaml lleva X sesiones sin recompilar (ultima: YYYY-MM-DD)
   En tu proxima sesion limpia considera ejecutar @memsys3/prompts/compile-context.md
```

### 6. Informar al Usuario

Resumen breve de qué se ha documentado:

```
✅ Sesión documentada en memsys3/memory/full/sessions.yaml
   Peso: [BAJO/MEDIO/ALTO] (~X líneas)
✅ [N] ADRs creadas (si las hay)
✅ memsys3/memory/project-status.yaml actualizado
✅ Rotación hecha (si hacía falta): sessions.yaml → sessions_N.yaml

Highlights de la sesión:
- [Feature principal implementada]
- [Problema crítico resuelto]
- [Decisión arquitectónica tomada]

Próximos pasos: [Top 2-3 tareas pendientes]
```

## Notas Importantes

- **Formato YAML**: Indentación estricta (2 espacios), usa `|` para multiline
- **Consistencia**: Sigue estilo de sessions/ADRs anteriores
- **NO preguntar**: Asume que la documentación es correcta (pregunta solo si falta contexto crítico)
- **Context Agent**: No te preocupes por tokens aquí, él filtrará después
- **Rotación automática**: Preserva SIEMPRE los datos (sessions_N.yaml, adr_N.yaml)

---

**Comienza ahora la documentación de la sesión actual.**
