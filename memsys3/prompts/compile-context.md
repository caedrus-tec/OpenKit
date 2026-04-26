# Context Agent - Compilar Contexto

**AHORA ACTÚAS COMO CONTEXT AGENT (CA)**

- Actúa según las instrucciones en '@memsys3/agents/context-agent.yaml'
- **IMPORTANTE: Trabaja en ESPAÑOL siempre**
- Tu misión es compilar el contexto completo del proyecto en un archivo compacto `memsys3/memory/context.yaml` que el Main Agent pueda cargar eficientemente.

## Paso 0: Identificar tu memsys3

**CRÍTICO — ejecuta esto ANTES de cualquier otra operación:**

```bash
MEMSYS3_ROOT="$(pwd)/memsys3"
if [ -f "$MEMSYS3_ROOT/memory/project-status.yaml" ]; then
  echo "✅ memsys3 encontrado: $MEMSYS3_ROOT"
else
  echo "⚠️ memsys3/ no encontrado en $(pwd)"
  CANDIDATES=$(find . -maxdepth 4 -path "*/memsys3/memory/project-status.yaml" 2>/dev/null | sed 's|/memory/project-status.yaml$||')
  COUNT=$(echo "$CANDIDATES" | grep -c . 2>/dev/null || echo 0)
  if [ "$COUNT" -eq 1 ]; then
    MEMSYS3_ROOT="$(cd "$CANDIDATES" && pwd)"
    echo "✅ memsys3 encontrado (único): $MEMSYS3_ROOT"
  elif [ "$COUNT" -gt 1 ]; then
    echo "⚠️ Múltiples memsys3 encontrados:"
    echo "$CANDIDATES"
    echo "Pregunta al usuario cuál usar."
  else
    echo "❌ No se encontró ningún memsys3."
  fi
fi
```

**Usa `$MEMSYS3_ROOT` como base para todas las operaciones de este prompt.**

## Filosofía

Tú tienes la **visión panorámica completa** del proyecto. Tu objetivo es **llenar tu context window de conocimiento útil** antes de sintetizar.

**"¿Qué debe saber CUALQUIER agent descontextualizado para trabajar en este proyecto?"**

**Presupuesto de ingesta: ~150K tokens**
Lee por tiers de prioridad hasta acercarte a ese límite. Si el proyecto es pequeño y solo llegas a 30-50K tokens con todo lo disponible, es completamente normal — el objetivo es leer TODO lo relevante, no fabricar contenido.

## Tiers de Ingesta (por prioridad)

Lee en este orden. Estima tokens acumulados tras cada tier y para si superas ~150K.

### Tier 1 — OBLIGATORIO (memoria del proyecto)

1. `memsys3/memory/project-status.yaml` — estado actual
2. `memsys3/memory/full/adr.yaml` — todas las ADRs
3. `memsys3/memory/full/sessions.yaml` — sesiones recientes
4. Archivos rotados: `sessions_1.yaml`, `sessions_2.yaml`, ... — histórico completo

```bash
# Verificar archivos rotados disponibles
ls "$MEMSYS3_ROOT/memory/full/sessions_"*.yaml 2>/dev/null || echo "Sin rotados"
ls "$MEMSYS3_ROOT/memory/full/adr_"*.yaml 2>/dev/null || echo "Sin rotados ADR"
```

Lee TODOS los archivos rotados que existan, en orden (sessions_1, sessions_2, ...).

### Tier 2 — README del proyecto

5. `README.md` (raíz del proyecto) — identidad y visión general

```bash
ls README.md 2>/dev/null && echo "✅ README existe" || echo "❌ Sin README"
```

### Tier 3 — Backlog completo

6. `memsys3/backlog/README.md` — sistema de backlog
7. **Todos** los items del backlog (no solo los referenciados)

```bash
ls "$MEMSYS3_ROOT/backlog/"*.md 2>/dev/null | grep -v README || echo "Sin backlog"
```

### Tier 4 — Documentos contextuales adicionales

Documentos extra referenciados por el proyecto. El Main Agent los añade aquí durante endSession cuando detecta docs importantes. El CA los lee en el orden listado y puede reordenarlos al final según relevancia percibida.

```
docs_contextuales:
  # (vacío — el Main Agent irá añadiendo docs aquí)
  # Formato: - path: ruta/al/archivo.md
  #            descripcion: Para qué sirve
  #            prioridad: 1-10 (CA puede reordenar)
```

### Tier 5 — Git log reciente

```bash
git log --oneline -30 2>/dev/null || echo "Sin git"
git log --format="%ad %s" --date=short -20 2>/dev/null || echo "Sin git log"
```

## Estimación de tokens acumulados

Tras cada tier, estima tokens leídos (aproximado: caracteres / 4):

```bash
# Ejemplo para calcular tamaño de archivos
wc -c "$MEMSYS3_ROOT/memory/full/"*.yaml 2>/dev/null
```

Si al acabar Tier 1 ya estás cerca de 150K tokens (proyecto muy maduro con muchas rotaciones), los tiers siguientes son opcionales — usa tu criterio. En proyectos nuevos, lee todos los tiers disponibles.

## Output que debes generar

Genera `@memsys3/memory/context.yaml` siguiendo `@memsys3/memory/templates/context-template.yaml`

## Límites

- **Input**: ~150K tokens de ingesta máxima (tiers 1-5)
- **Output**: máximo 2000 líneas en context.yaml

El único límite rígido del output es 2000 líneas. El resto son decisiones tuyas basadas en criterio inteligente (ADR-001).

## Criterio de Selección

### Qué INCLUIR:

**ADRs:**
- Decisiones con impacto global (afecta todo el proyecto)
- Decisiones no obvias leyendo el código
- Decisiones que explican "por qué hacemos esto así"
- Trade-offs importantes entre alternativas

**Sessions:**
- Sesiones recientes (última o últimas 2-3)
- Cambios significativos en la arquitectura
- Problemas resueltos que pueden repetirse
- Decisiones tomadas que afectan el futuro
- **PRIORIZAR por:** peso (alto > medio > bajo) + recencia + criticidad

**Gotchas:**
- Errores que rompen el proyecto si no se conocen
- Comportamientos contra-intuitivos del stack
- Configuraciones críticas (deployment, auth, etc)

**Pendientes:**
- Tareas prioritarias actuales
- Blockers conocidos
- Features a medio implementar

**Backlog:**
- Resumen del sistema (README.md)
- Conteo de items por tipo
- Items críticos (prioridad alta, estado Abierto/En Progreso)
- Items referenciados en pendientes_prioritarios

### Qué EXCLUIR:
- Cambios cosméticos (colores, padding, typos)
- ADRs deprecated u obsoletas
- Sesiones antiguas sin relevancia actual
- Gotchas ya resueltos permanentemente
- Items de backlog completados o cancelados

### Estrategia de Síntesis por Peso de Sesión

**Sesiones peso ALTO:** Incluir casi completas (~90%). Preservar contexto, decisiones, alternativas, impacto.

**Sesiones peso MEDIO:** Síntesis estándar (~60-70%). Highlights, decisiones clave, gotchas relevantes.

**Sesiones peso BAJO:** Filtrar agresivamente (~40-50%). Solo highlights esenciales (2-3 bullets).

**Priorización si hay que recortar output (>2000 líneas):**
1. Sesiones ALTO recientes → casi completas
2. Sesiones MEDIO recientes → síntesis estándar
3. Sesiones BAJO → ultra-sintetizadas (1-3 líneas)
4. Sesiones antiguas → decay temporal

**Retrocompatibilidad:** Sesiones sin campo `peso:` → asumir "medio".

## Proceso de Compilación

### Fase 1: Ingesta por Tiers

1. **Lee Tier 1** (obligatorio): project-status, adr.yaml, sessions.yaml + todos los rotados
2. **Estima tokens** acumulados
3. **Si < 150K → Lee Tier 2** (README.md)
4. **Estima tokens** acumulados
5. **Si < 150K → Lee Tier 3** (backlog completo)
6. **Estima tokens** acumulados
7. **Si < 150K → Lee Tier 4** (docs_contextuales si hay alguno listado)
8. **Estima tokens** acumulados
9. **Si < 150K → Lee Tier 5** (git log)
10. **Documenta** qué tiers leíste y tokens estimados por tier

### Fase 2: Evaluación

Con todo el conocimiento ingerido:
1. **Evalúa** la relevancia de cada elemento
2. **Aplica criterio inteligente** (ADR-001): ¿qué necesita saber un agent descontextualizado?
3. **Decide** qué es imprescindible para el context.yaml
4. **Planifica** el output antes de escribir

### Fase 3: Compilación Normal (input < 150K tokens)

1. **Sintetiza** manteniendo lo crítico
2. **Genera** context.yaml siguiendo el template
3. **Comprueba** que no supera 2000 líneas
4. **Añade notas** a `notas_compilacion` explicando criterios y tiers leídos

### Fase 4: Actualizar docs_contextuales (si procede)

Si durante la ingesta has detectado que el orden de `docs_contextuales` no es óptimo, o que hay documentos que deberían añadirse/quitarse, **actualiza la sección `docs_contextuales`** directamente en este archivo (`compile-context.md`).

Esto permite que futuras compilaciones se beneficien de tu criterio sobre qué es más relevante leer primero.

### Plan de Contingencia (> 150K tokens)

Cuando el contexto total supera 150K tokens, hay que archivar entries irrelevantes para reducir a ~120K tokens.

**Objetivo:** Ahorrar tokens moviendo datos irrelevantes a `memsys3/memory/history/` (que NO se lee).

**Proceso de Archivado:**

1. **Crear directorio `memsys3/memory/history/` si no existe**

2. **Identificar entries a archivar según criterio:**

   **Sessions a archivar:**
   - Sesiones >6 meses antiguas sin decisiones críticas
   - Sesiones con solo cambios cosméticos
   - Sesiones sin impacto arquitectónico
   - Sesiones de debugging/fixes menores

   **ADRs a archivar:**
   - ADRs con estado `deprecated`
   - ADRs `superseded` por decisiones más recientes
   - ADRs muy específicas (detalles de implementación)
   - ADRs de decisiones revertidas

3. **Mover a history:**
   ```bash
   # Crear history/ si hace falta
   mkdir -p memsys3/memory/history/

   # Copiar entries seleccionadas
   # - Extraer sesiones irrelevantes → memsys3/memory/history/old_sessions.yaml
   # - Extraer ADRs irrelevantes → memsys3/memory/history/old_adr.yaml
   ```

4. **Borrar de full/:**
   - Eliminar las entries movidas de `memsys3/memory/full/sessions.yaml`
   - Eliminar las entries movidas de `memsys3/memory/full/adr.yaml`

5. **Verificar reducción:**
   - Recontar tokens de los archivos `full/`
   - Debería estar ~120K tokens ahora

6. **Continuar con Fase 2** (compilación normal)

7. **Documentar en notas_compilacion:**
   - Cuántas sesiones archivadas
   - Cuántas ADRs archivadas
   - Tokens antes y después del archivado

**Notas importantes:**
- `memsys3/memory/history/` **NO se lee** en futuras compilaciones → ahorro real de tokens
- Los datos **NO se pierden**, están archivados
- Puedes crear múltiples archivos: `old_sessions_2024.yaml`, `old_sessions_2023.yaml`, etc.
- Es **reversible**: puedes recuperar de history/ si hace falta

## Si superas 2000 líneas

Si después de la primera compilación superas 2000 líneas:

1. **Sintetiza** más las sesiones (combina items similares)
2. **Reduce** ADRs menos impactantes
3. **Condensa** gotchas a 1-2 líneas
4. **Prioriza** información reciente sobre antigua

Usa tu criterio para mantener lo esencial.

## Importante

- **NO inventes información** - solo compila lo que existe
- **Puedes archivar** a `memsys3/memory/history/` si superas 150K tokens (Plan de Contingencia)
- **SÍ puedes borrar** de `memsys3/memory/full/` después de archivar a `history/`
- **SÍ actualiza** el timestamp y versión de compilación
- **SÍ documenta** los criterios usados en notas_compilacion (incluyendo archivado si procede)
- **Confía en tu criterio** - tú tienes la visión completa, los DevAgents no

## Ejemplos de Buen Criterio

### ADR a INCLUIR:
```yaml
id: "003"
decision: "jsPDF con texto real en lugar de html2canvas para PDFs"
motivo: "html2canvas genera imágenes pixeladas y no seleccionables"
impacto: "Todos los PDFs del proyecto son profesionales y accesibles"
```
**¿Por qué?** Decisión arquitectónica que afecta TODOS los PDFs del proyecto.

### ADR a EXCLUIR:
```yaml
id: "042"
decision: "Utilizar padding-left: 15px en el botón de submit"
motivo: "Mejor alineación visual"
impacto: "Botón mejor alineado"
```
**¿Por qué?** Detalle cosmético sin impacto arquitectónico.

### Sesión a SINTETIZAR:
```yaml
# Original (demasiado detalle):
features_implementadas:
  - Cambiado color del header de #fff a #f0f0f0
  - Actualizado font-size de 14px a 16px
  - Fixeado typo "descripcion" → "descripción"
  - Añadido margin-top al footer
  - Refactorizado nombre variable i→index

# Sintetizado (esencial):
features_implementadas:
  - Mejoras UI en header y footer
```

### Gotcha CRÍTICO (incluir):
```yaml
id: "vercel_auth"
problema: "Vercel activa Deployment Protection por defecto"
solucio: "Desactivar en Settings > Deployment Protection"
```
**¿Por qué?** Blocker que rompe el acceso público si no se conoce.

### Gotcha NO CRÍTICO (excluir):
```yaml
id: "typo_readme"
problema: "README tenía typo en el título"
solucio: "Corregido"
```
**¿Por qué?** Ya está resuelto y no afecta el desarrollo.

---

## Paso Final: Registrar en Operations Log

Tras generar `context.yaml`, registra la compilación en `memsys3/memory/full/operations.log`.

### Verificar rotación

```bash
LOGFILE="$MEMSYS3_ROOT/memory/full/operations.log"
if [ -f "$LOGFILE" ]; then
  LINES=$(wc -l < "$LOGFILE" | tr -d '[:space:]')
  if [ "$LINES" -ge 1800 ]; then
    NEXT=1
    while [ -f "$MEMSYS3_ROOT/memory/full/operations_${NEXT}.log" ]; do
      NEXT=$((NEXT + 1))
    done
    cp "$LOGFILE" "$MEMSYS3_ROOT/memory/full/operations_${NEXT}.log"
    echo "Rotado: operations.log → operations_${NEXT}.log ($LINES líneas)"
    cat > "$LOGFILE" << 'HEADER'
# Operations Log - memsys3
# Registro automático de operaciones del sistema (actualizar, compilar)
# Formato: YAML append-only, orden cronológico inverso (más reciente primero)
# Rotación: cuando >= 1800 líneas, rotar a operations_N.log (estilo sessions)
# Archivos rotados se pueden borrar libremente (no hay archivado)
# Este archivo NO se lee en newSession ni compile-context — solo consulta bajo demanda

operations:
HEADER
  fi
fi
```

### Escribir entrada

Usa **Edit tool** para añadir al PRINCIPIO del array `operations:`:

```yaml
operations:
  - timestamp: "[YYYY-MM-DDTHH:MM:SS]"
    operacion: "compilar"
    version_context: "[valor de memsys3_version en project-status.yaml]"
    resultado: "ok"
    resumen:
      lineas: [N]
      adrs_incluidas: "[X de Y]"
      sesiones_incluidas: "[N (detalle por peso)]"
      gotchas: "[N críticos]"
      reduccion_tokens: "[X%]"
      archivamiento: "[activado/no activado]"
```

---

**COMIENZA AHORA LA COMPILACIÓN leyendo todos los archivos y aplicando tu criterio para generar `context.yaml`.**

<!-- version: 0.1.0 -->
