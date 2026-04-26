# Actualizar memsys3 - Prompt de Actualización Segura

**AHORA ACTÚAS COMO MAIN AGENT realizando una actualización de memsys3**

- Tu misión es **actualizar la versión de memsys3** en este proyecto de forma segura
- **IMPORTANTE: Trabaja en ESPAÑOL siempre**
- Este prompt complementa `deploy.md` (que es para deployment inicial)

---

## ⚠️ ANTES DE EMPEZAR

### Paso 0a: Identificar tu memsys3

**CRÍTICO — ejecuta esto ANTES de cualquier otra operación:**

```bash
PROJECT_ROOT=$(pwd)
MEMSYS3_ROOT="$PROJECT_ROOT/memsys3"

if [ -f "$MEMSYS3_ROOT/memory/project-status.yaml" ]; then
  echo "✅ memsys3 encontrado: $MEMSYS3_ROOT"
  grep "memsys3_version" "$MEMSYS3_ROOT/memory/project-status.yaml" | head -1
else
  echo "⚠️ memsys3/ no encontrado en $(pwd)"
  echo "Buscando memsys3/ disponibles (máx profundidad 4)..."
  CANDIDATES=$(find . -maxdepth 4 -path "*/memsys3/memory/project-status.yaml" 2>/dev/null | sed 's|/memory/project-status.yaml$||')
  COUNT=$(echo "$CANDIDATES" | grep -c . 2>/dev/null || echo 0)
  if [ "$COUNT" -eq 1 ]; then
    MEMSYS3_ROOT="$(cd "$CANDIDATES" && pwd)"
    echo "✅ memsys3 encontrado (único): $MEMSYS3_ROOT"
  elif [ "$COUNT" -gt 1 ]; then
    echo "⚠️ Múltiples memsys3 encontrados:"
    echo "$CANDIDATES"
    echo "Pregunta al usuario cuál usar para esta actualización."
  else
    echo "❌ No se encontró ningún memsys3. ¿Has desplegado memsys3? Usa @memsys3/prompts/deploy.md"
  fi
fi

# Limpiar artefactos de ejecuciones anteriores
rm -rf memsys3_update_temp memsys3_templates 2>/dev/null
echo "Artefactos previos limpiados"
echo "PROJECT_ROOT=$PROJECT_ROOT"
echo "MEMSYS3_ROOT=$MEMSYS3_ROOT"
```

**Si no encuentra memsys3 o hay múltiples:** detente. Pregunta al usuario y NO continúes hasta confirmarlo.

**Si encuentra memsys3:** continúa con el bootstrap.

**IMPORTANTE:** Todos los pasos siguientes deben usar `$MEMSYS3_ROOT` para referirse a memsys3 y `$PROJECT_ROOT` para la raíz del proyecto. Evita `cd` siempre que sea posible.

> **Nota sobre monorepos/submodules:** Un proyecto puede contener múltiples instancias de memsys3 (monorepo, submodules, workspaces). La detección automática prioriza `$(pwd)/memsys3`. Si hay ambigüedad, el usuario decide.

### Paso 0b: Bootstrap — actualizar este prompt antes de continuar

```bash
git clone https://github.com/iv0nis/memsys3 memsys3_update_temp
cp memsys3_update_temp/memsys3_templates/prompts/actualizar.md "$MEMSYS3_ROOT/prompts/actualizar.md"
echo "actualizar.md actualizado a la versión del repo"
```

**Ahora lee `memsys3/prompts/actualizar.md` y continúa desde el Paso 1 de ese archivo.** El resto de este prompt puede estar desactualizado.

---

**Verifica que estás en el proyecto correcto:**
1. Este proyecto YA tiene memsys3 instalado (carpeta `memsys3/`)
2. Si NO tiene memsys3, usa `@memsys3/prompts/deploy.md` en su lugar

---

## 🚨 PASO 0: Detectar Estructura Antigua Incompatible

**CRÍTICO:** Antes de actualizar, debemos verificar si existe una estructura antigua PRE-ADR-006 (pre-v0.2.0).

### Detectar estructura antigua

Ejecuta:

```bash
# Verificar si existe carpeta /memory en raíz (NO dentro de memsys3/)
ls -la memory/ 2>/dev/null && echo "⚠️ ESTRUCTURA ANTIGUA DETECTADA" || echo "✅ Estructura nueva OK"

# Verificar si memsys3/ existe
ls -la memsys3/ 2>/dev/null && echo "✅ memsys3/ existe" || echo "❌ memsys3/ NO existe"
```

**Escenarios posibles:**

### Escenario A: Solo `/memory` (estructura pre-ADR-006)

```
proyecto/
├── memory/           ← Estructura antigua (sin prefijo memsys3/)
│   ├── full/
│   ├── templates/
│   ├── prompts/
│   └── project-status.yaml
└── (NO hay memsys3/)
```

**Diagnóstico:** Sistema de memoria antigua, **incompatible** con memsys3 actual.

**Acción:** **NO usar actualizar.md**. Esto requiere **migración completa**:
1. Backup completo de `/memory`
2. Ejecutar `@memsys3/prompts/deploy.md` (deployment desde cero)
3. Migrar datos manualmente:
   - Copiar `memory/full/sessions.yaml` → `memsys3/memory/full/`
   - Copiar `memory/full/adr.yaml` → `memsys3/memory/full/`
   - Copiar `memory/project-status.yaml` → `memsys3/memory/` (agregar campos versión)
4. Borrar `/memory` antigua después de validar

### Escenario B: `/memory` + `/memsys3` coexistiendo

```
proyecto/
├── memory/           ← Estructura antigua CON DATOS REALES
│   ├── full/
│   └── project-status.yaml
└── memsys3/          ← Estructura nueva PERO con datos template sin personalizar
    └── memory/
```

**Diagnóstico:** Deployment inicial se hizo INCORRECTAMENTE. Se desplegó memsys3/ pero NO se migraron datos de /memory.

**🚨 ESTO ES LO QUE PASÓ EN deCastro_inmobiliaria**

**Síntomas:**
- `/memory/project-status.yaml` tiene datos del proyecto real
- `/memsys3/memory/project-status.yaml` tiene datos copiados del template memsys3 (descripciones genéricas, "Sistema de gestió de context...", etc.)

**Acción:** **Migración de datos antes de actualizar**:

```bash
# 1. Backup de ambas estructuras
cp -r memory memory_backup_old_$(date +%Y%m%d)
cp -r memsys3 memsys3_backup_$(date +%Y%m%d)

# 2. Migrar datos REALES de /memory a /memsys3/memory
cp memory/full/sessions.yaml memsys3/memory/full/
cp memory/full/adr.yaml memsys3/memory/full/
cp memory/project-status.yaml memsys3/memory/

# 3. Agregar campos de versión a memsys3/memory/project-status.yaml
# (editar manualmente metadata: agregar memsys3_version, memsys3_deployed)

# 4. AHORA SÍ, continuar con actualizar.md desde Paso 1
```

**Después de validar que funciona:**
```bash
# Borrar estructura antigua (solo después de validar)
rm -rf memory_backup_old_* memory/
```

### Escenario C: Solo `/memsys3` (estructura nueva)

```
proyecto/
└── memsys3/          ← Estructura correcta
    └── memory/
        ├── full/
        ├── templates/
        └── project-status.yaml (con memsys3_version)
```

**Diagnóstico:** Estructura correcta, deployment hecho correctamente.

**Acción:** ✅ Continuar con **Paso 1** normalmente.

---

## Paso 1: Verificar Versión Actual

Lee el archivo del proyecto:

```bash
cat "$MEMSYS3_ROOT/memory/project-status.yaml" | grep -A2 "metadata:"
```

**Busca los campos:**
- `memsys3_version`: Versión actual instalada
- `memsys3_deployed`: Fecha del último deployment/actualización

**Si NO existen estos campos:**
- Significa que tienes una versión muy antigua (pre-v0.5.0)
- La actualización será más compleja (muchos cambios estructurales)

**Anota la versión actual aquí:** `[VERSIÓN_ACTUAL]`

---

## Paso 2: Verificar Última Versión Disponible

Consulta GitHub para ver la última versión:

```bash
git ls-remote --tags https://github.com/iv0nis/memsys3 | tail -5
```

**Identifica la última versión estable (tag más reciente):** `[VERSIÓN_NUEVA]`

**¿Vale la pena actualizar?**
- Si la diferencia es < 2 versiones patch (ej: v0.5.1 → v0.5.2): actualización menor
- Si la diferencia es >= 1 versión minor (ej: v0.4.0 → v0.5.0): actualización importante
- Si es >= 1 versión major (ej: v0.x → v1.x): actualización crítica (revisar CHANGELOG)

---

## Paso 2.5: Elegir Modo de Actualización

Usa `AskUserQuestion` para preguntar al usuario:

```
AskUserQuestion(
  question: "¿Qué modo de actualización prefieres?",
  header: "Modo",
  options: [
    { label: "Rápida (Recomendado)", description: "Usa git diff para detectar cambios. Eficiente en tokens." },
    { label: "Extendida", description: "Lanza un subagente que se contextualiza con el memsys3 de desarrollo (lee sessions, ADRs, context.yaml del repo) para entender QUÉ cambió y POR QUÉ. Consume más tokens pero da mejor comprensión de los cambios." }
  ]
)
```

**Si el usuario elige "Extendida":**

Lanza un subagente (Agent tool) con este prompt:

```
Carga el contexto del proyecto memsys3 desde el repo clonado en memsys3_update_temp/:

1. Lee memsys3_update_temp/memsys3/prompts/newSession.md y sigue sus instrucciones,
   pero usando memsys3_update_temp/memsys3/ como raíz (en lugar de ./memsys3/)
2. Una vez contextualizado, analiza qué cambió entre [VERSION_ACTUAL] y [VERSION_NUEVA]:
   - git log --oneline [VERSION_ACTUAL]..[VERSION_NUEVA] en memsys3_update_temp/
   - Cruza los commits con las sesiones documentadas en sessions.yaml
   - Identifica: features nuevas, breaking changes, archivos eliminados, decisiones arquitectónicas
3. Devuelve un informe estructurado:
   - Cambios críticos que afectan al proyecto del usuario
   - Breaking changes y cómo mitigarlos
   - Archivos nuevos/eliminados/modificados con contexto de por qué
   - Recomendaciones para la actualización
```

Espera el resultado del subagente y úsalo para guiar los pasos siguientes con mejor comprensión.

**Si el usuario elige "Rápida":** Continúa directamente con Paso 3.

---

## Paso 3: Clonar Nueva Versión Temporalmente

**IMPORTANTE:** NO borres nada aún, solo clona para comparar.

```bash
# Si el bootstrap (Paso 0b) ya clonó el repo, reutilizarlo — no clonar de nuevo
if [ -d "memsys3_update_temp" ]; then
  echo "Reutilizando clone del bootstrap"
else
  git clone https://github.com/iv0nis/memsys3 memsys3_update_temp
fi

cd memsys3_update_temp

# Obtener versión exacta
NEW_VERSION=$(git describe --tags --always)
NEW_COMMIT=$(git log -1 --format=%h)

echo "Nueva versión: $NEW_VERSION (commit: $NEW_COMMIT)"

cd ..
```

> **Nota:** Si `memsys3_update_temp/memsys3_templates/prompts/actualizar.md` difiere del archivo que estás leyendo ahora, usa el del repo clonado como referencia — tiene la versión más reciente.

---

## Paso 4: Categorizar Archivos Según Estrategia

### 🚫 NUNCA SOBRESCRIBIR (datos del proyecto actual)

Estos archivos contienen el histórico y estado del proyecto. **JAMÁS los toques:**

- `memsys3/memory/full/adr.yaml`
- `memsys3/memory/full/sessions.yaml`
- `memsys3/memory/full/sessions_*.yaml` (si hay rotaciones)
- `memsys3/memory/full/adr_*.yaml` (si hay rotaciones)
- `memsys3/memory/project-status.yaml` (excepto metadata de versión)
- `memsys3/memory/context.yaml` (se regenera con compile-context)
- `memsys3/memory/full/operations.log` (log de operaciones)
- `memsys3/memory/full/operations_*.log` (si hay rotaciones)
- `memsys3/memory/history/*` (si existe)

### ✅ ACTUALIZAR SIEMPRE (lógica del sistema)

Estos son parte del "motor" de memsys3, se pueden sobrescribir:

**Prompts:**
- `memsys3/prompts/compile-context.md`
- `memsys3/prompts/endSession.md`
- `memsys3/prompts/github.md`
- `memsys3/prompts/deploy.md`
- `memsys3/prompts/actualizar.md` ← (este mismo archivo)
- `memsys3/prompts/adr.md`
- `memsys3/prompts/backlog.md`
- `memsys3/prompts/commands.md`
- `memsys3/prompts/meet.md`
- `memsys3/prompts/agent-identity.md`

**Agents:**
- `memsys3/agents/context-agent.yaml`

**Templates:**
- `memsys3/memory/templates/adr-template.yaml`
- `memsys3/memory/templates/sessions-template.yaml`
- `memsys3/memory/templates/context-template.yaml`
- `memsys3/memory/templates/project-status-template.yaml`

**Documentación del sistema:**
- `memsys3/memory/README.md`

### 🔍 REVISAR MANUALMENTE (puede haber personalizaciones)

Estos archivos pueden haber sido personalizados por el usuario:

- `memsys3/prompts/newSession.md` → Puede tener contexto específico del proyecto
- `memsys3/agents/main-agent.yaml` → Puede tener responsabilidades personalizadas

**Estrategia:**
1. Hacer diff entre versión actual y nueva
2. Si NO hay cambios del usuario → sobrescribir
3. Si HAY cambios del usuario → hacer merge manual (conservar personalizaciones + aplicar mejoras)

---

## Paso 5: Crear Backup de Seguridad

Antes de tocar NADA, crea un backup:

```bash
# Crear directorio de backups si no existe
mkdir -p "$MEMSYS3_ROOT/docs/backups"

# Migrar backups antiguos de la raíz (si los hay)
for old_backup in memsys3_backup_*/; do
  [ -d "$old_backup" ] && mv "$old_backup" "$MEMSYS3_ROOT/docs/backups/$old_backup" && echo "Migrado: $old_backup"
done

# Crear backup actual (fuera de memsys3/ para evitar auto-recursión)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
rsync -a --exclude='docs/backups' "$MEMSYS3_ROOT/" memsys3_backup_temp_$TIMESTAMP/
mv memsys3_backup_temp_$TIMESTAMP "$MEMSYS3_ROOT/docs/backups/memsys3_backup_$TIMESTAMP"

echo "Backup creado en: $MEMSYS3_ROOT/docs/backups/memsys3_backup_$TIMESTAMP"

# Limpiar backups antiguos (máx 3: 2 anteriores + actual)
cd "$MEMSYS3_ROOT/docs/backups"
ls -dt memsys3_backup_* | tail -n +4 | xargs rm -rf
echo "Backups antiguos limpiados (máx 3)"
cd -
```

**CRÍTICO:** Si algo sale mal, puedes restaurar con:
```bash
cp -r memsys3/docs/backups/memsys3_backup_$TIMESTAMP memsys3_restored
# Luego renombrar memsys3_restored a memsys3 si es necesario
```

---

## Paso 5.5: Detectar Archivos Custom del Proyecto

**Antes de actualizar, identifica archivos que el usuario creó y NO pertenecen al template.**

```bash
echo "=== Detectando archivos custom del proyecto ==="
echo "MEMSYS3_ROOT=$MEMSYS3_ROOT"

for dir in prompts agents docs; do
  if [ -d "$MEMSYS3_ROOT/$dir" ]; then
    find "$MEMSYS3_ROOT/$dir" -type f | while read f; do
      relative="${f#$MEMSYS3_ROOT/}"
      if [ ! -f "memsys3_update_temp/memsys3_templates/$relative" ]; then
        echo "  CUSTOM: $relative"
      fi
    done
  fi
done

echo ""
echo "Los archivos CUSTOM se preservarán intactos durante la actualización."
echo "=== Fin detección ==="
```

**Si hay archivos custom:** No requiere acción. La actualización solo tocará archivos del template.

**Si detectas un archivo que existe tanto en el proyecto como en el template nuevo, pero NO existía en la versión anterior del template** (puedes verificar en el backup): es un potencial conflicto. En ese caso:

```
⚠️ CONFLICTO: [archivo] existe en tu proyecto Y en el template nuevo.
   Se preserva tu versión. Revisa manualmente si quieres la del template.
```

**Principio:** En caso de duda, preservar lo del usuario. Lo del template siempre se puede recuperar del repo.

---

## Paso 6: Actualizar Archivos del Sistema

```bash
# Crear directorios necesarios (siempre, antes de copiar nada)
mkdir -p "$MEMSYS3_ROOT/docs" "$MEMSYS3_ROOT/docs/backups" "$MEMSYS3_ROOT/prompts" "$MEMSYS3_ROOT/agents" "$MEMSYS3_ROOT/memory/templates"

# Crear backlog/ si no existe
if [ ! -f "$MEMSYS3_ROOT/backlog/README.md" ]; then
  mkdir -p "$MEMSYS3_ROOT/backlog"
  echo "# Backlog" > "$MEMSYS3_ROOT/backlog/README.md"
  echo "backlog/ creado"
fi
```

### 6.1 Actualizar Prompts y Docs

**Estrategia principal: git diff --name-status**

```bash
CURRENT_VERSION=$(grep "memsys3_version" "$MEMSYS3_ROOT/memory/project-status.yaml" | head -1 | sed 's/.*: "\(.*\)"/\1/')
echo "Versión actual: $CURRENT_VERSION"

# Ver qué archivos cambiaron, con estado (A=añadido, M=modificado, D=eliminado)
git -C memsys3_update_temp diff --name-status $CURRENT_VERSION HEAD -- memsys3_templates/
```

**Resumen antes de ejecutar (checkpoint):**
Cuenta y muestra al moderador:
```
Archivos a copiar (A/M): X
Archivos a borrar (D): Y
```

**Para cada archivo listado:**
- **A (añadido):** verificar primero si ya existe en `memsys3/` del proyecto.
  - Si existe → es un archivo custom del usuario con el mismo nombre → **CONFLICTO**: preservar del usuario y avisar `⚠️ CONFLICTO: [archivo] existe en tu proyecto Y en el template nuevo. Se preserva tu versión.`
  - Si no existe → copiar normalmente.
- **M (modificado):** cópialo al directorio correspondiente en `memsys3/`
  - `memsys3_templates/prompts/X` → `memsys3/prompts/X`
  - `memsys3_templates/docs/X` → `memsys3/docs/X`
  - `memsys3_templates/agents/X` → `memsys3/agents/X`
  - `memsys3_templates/memory/X` → `memsys3/memory/X`
  - **Excepto** `newSession.md` y `main-agent.yaml` → ver pasos 6.2 y 6.3
- **D (eliminado):** borra el archivo correspondiente en `memsys3/`

**IMPORTANTE:** Los archivos custom detectados en Paso 5.5 NO se tocan en ningún caso.

**Si git diff funciona, NO ejecutes el fallback. Son mutuamente excluyentes.**

---

**Fallback: copia dinámica (SOLO si git diff falla — error de salida, versión no encontrada)**

```bash
# Copiar prompts recursivamente (excepto newSession.md → merge manual en 6.2)
find memsys3_update_temp/memsys3_templates/prompts/ -type f | while read f; do
  relative="${f#memsys3_update_temp/memsys3_templates/}"
  fname=$(basename "$f")
  if [ "$fname" != "newSession.md" ]; then
    mkdir -p "$MEMSYS3_ROOT/$(dirname "$relative")"
    cp "$f" "$MEMSYS3_ROOT/$relative"
  fi
done
echo "Prompts actualizados (dinámico)"

# Copiar docs (sin borrar — preserva archivos custom del proyecto)
find memsys3_update_temp/memsys3_templates/docs/ -type f | while read f; do
  relative="${f#memsys3_update_temp/memsys3_templates/}"
  mkdir -p "$MEMSYS3_ROOT/$(dirname "$relative")"
  cp "$f" "$MEMSYS3_ROOT/$relative"
done
echo "Docs actualizados (sin borrar custom)"
```

> **⚠️ NUNCA hacer `rm -f memsys3/docs/*.md` ni borrar carpetas enteras.** Eso destruye archivos custom del proyecto. Solo sobrescribir archivos que vienen del template.

### 6.2 Revisar newSession.md

```bash
# Comparar versiones
diff "$MEMSYS3_ROOT/prompts/newSession.md" memsys3_update_temp/memsys3_templates/prompts/newSession.md
```

**Si hay diferencias:**
- Lee ambas versiones
- Conserva personalizaciones del proyecto (descripciones específicas, contexto único)
- Aplica mejoras estructurales de la nueva versión
- Edita manualmente si es necesario

**Si NO hay diferencias (archivo base sin personalizar):**
```bash
cp memsys3_update_temp/memsys3_templates/prompts/newSession.md "$MEMSYS3_ROOT/prompts/"
```

### 6.3 Actualizar Agents

```bash
# Context Agent (siempre actualizar)
cp memsys3_update_temp/memsys3_templates/agents/context-agent.yaml "$MEMSYS3_ROOT/agents/"

# Main Agent (revisar personalizaciones)
diff "$MEMSYS3_ROOT/agents/main-agent.yaml" memsys3_update_temp/memsys3_templates/agents/main-agent.yaml
```

**Estrategia main-agent.yaml:** igual que newSession.md (conservar personalizaciones + aplicar mejoras)

> **Nota:** Los archivos custom en `agents/` detectados en Paso 5.5 (ej: `dev-agent.yaml`) no se tocan.

### 6.4 Actualizar Templates

```bash
cp memsys3_update_temp/memsys3_templates/memory/templates/*.yaml "$MEMSYS3_ROOT/memory/templates/"
```

### 6.5 Crear history/ si no existe

```bash
# Crear directorio para Plan de Contingencia (si no existe)
mkdir -p "$MEMSYS3_ROOT/memory/history"
touch "$MEMSYS3_ROOT/memory/history/.gitkeep"
```

### 6.7 Actualizar Documentación del Sistema

```bash
cp memsys3_update_temp/memsys3_templates/memory/README.md "$MEMSYS3_ROOT/memory/"
```

---

## Paso 7: Actualizar Metadata de Versión

**Hacer esto ANTES de limpiar el clone temporal** (necesitas NEW_VERSION del Paso 3).

Edita `$MEMSYS3_ROOT/memory/project-status.yaml`:

**Actualizar solo el bloque metadata:**

```yaml
metadata:
  ultima_actualizacion: "[FECHA_HOY]"  # Formato: 2025-11-12
  actualizado_por: "Claude (Actualización memsys3 [VERSIÓN_ACTUAL] → [VERSIÓN_NUEVA])"
  fase: "[FASE_ACTUAL_DEL_PROYECTO]"  # NO cambiar, conservar la del proyecto
  memsys3_version: "[VERSIÓN_NUEVA]"  # Ejemplo: v0.5.0 (commit: abc1234)
  memsys3_deployed: "[FECHA_HOY]"
```

**IMPORTANTE:**
- NO toques `visio_general`, `estat_actual`, `features`, `stack_tecnologic`, etc.
- Solo actualiza el bloque `metadata`

**Verificar que el cambio se aplicó:**
```bash
grep "memsys3_version" "$MEMSYS3_ROOT/memory/project-status.yaml"
# Debe mostrar la versión NUEVA, no la anterior
```

---

## Paso 8: Limpiar Archivos Temporales

```bash
# Borrar clone temporal (ruta absoluta para evitar fallo si cwd cambió)
rm -rf "$PROJECT_ROOT/memsys3_update_temp"

echo "Clone temporal eliminado"
```

**NO borres el backup aún** (`memsys3/docs/backups/memsys3_backup_$TIMESTAMP`). Lo borraremos después de verificar.

---

## Paso 9: Verificar que Todo Funciona

### 9.1 Verificar Compilación de Contexto

Ejecuta en una **NUEVA INSTANCIA** (para no saturar tokens):

```bash
@memsys3/prompts/compile-context.md
```

**Verifica:**
- ✅ Se genera `memsys3/memory/context.yaml`
- ✅ No hay errores de campos faltantes
- ✅ context.yaml tiene < 2000 líneas
- ✅ notas_compilacion documenta el proceso

- ✅ Las 4 pestañas funcionan (Overview, ADRs, Sessions, Gotchas)

### 9.3 Probar newSession

En una **NUEVA INSTANCIA**:

```bash
@memsys3/prompts/newSession.md
```

**Verifica:**
- ✅ Carga el contexto correctamente
- ✅ No hay errores de rutas
- ✅ Muestra información relevante del proyecto

---

## Paso 10: Documentar Actualización en sessions.yaml

Usa el template de sessions para documentar esta actualización:

**Campos clave a documentar:**
```yaml
- id: "YYYY-MM-DD-actualizacion-memsys3"
  data: "[FECHA_HOY]"
  duracion: "~Xh"
  titulo: "Actualización memsys3 [VERSIÓN_ACTUAL] → [VERSIÓN_NUEVA]"

  features_implementadas:
    - "Actualizado memsys3 de [VERSIÓN_ACTUAL] a [VERSIÓN_NUEVA]"
    - "[LISTA_DE_ARCHIVOS_ACTUALIZADOS]"
    - "[MEJORAS_PRINCIPALES]"

  problemas_resueltos:
    - "[SI_HUBO_CONFLICTOS_O_PROBLEMAS]"

  decisions_tomadas:
    - "[SI_HUBO_QUE_HACER_MERGE_MANUAL]"

  gotchas_documentados:
    - tipo: "warning"
      problema: "[SI_ENCONTRASTE_ALGO_RARO]"
      solucion: "[CÓMO_LO_RESOLVISTE]"
      criticidad: "media"

  proximos_pasos:
    - "Validar funcionamiento en próximas sesiones de desarrollo"
```

**Añade esta entry al principio de `memsys3/memory/full/sessions.yaml`**

---

## Paso 11: Registrar en Operations Log

Registra esta actualización en `memsys3/memory/full/operations.log` para trazabilidad.

### 11.1 Verificar rotación

```bash
LOGFILE="$MEMSYS3_ROOT/memory/full/operations.log"
if [ -f "$LOGFILE" ]; then
  LINES=$(wc -l < "$LOGFILE" | tr -d '[:space:]')
  if [ "$LINES" -ge 1800 ]; then
    # Encontrar próximo número de rotación
    NEXT=1
    while [ -f "$MEMSYS3_ROOT/memory/full/operations_${NEXT}.log" ]; do
      NEXT=$((NEXT + 1))
    done
    cp "$LOGFILE" "$MEMSYS3_ROOT/memory/full/operations_${NEXT}.log"
    echo "Rotado: operations.log → operations_${NEXT}.log ($LINES líneas)"
    # Crear nuevo operations.log vacío
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
else
  echo "operations.log no existe, se creará"
fi
```

### 11.2 Escribir entrada

Usa **Edit tool** para añadir la entrada al PRINCIPIO del array `operations:` con el resumen estructurado de la actualización:

```yaml
operations:
  - timestamp: "[YYYY-MM-DDTHH:MM:SS]"
    operacion: "actualizar"
    version_origen: "[VERSIÓN_ACTUAL]"
    version_destino: "[VERSIÓN_NUEVA]"
    resultado: "ok"  # o "error: <detalle>"
    resumen:
      nuevos: "[N archivos (lista)]"
      actualizados: "[N archivos (lista)]"
      eliminados: "[N archivos (lista)]"
      merge_manual: "[archivos con merge manual, si los hubo]"
      preservados: "[archivos custom preservados]"
      backup: "[ruta del backup creado]"
      pendientes_validacion:
        - "[pendiente 1]"
        - "[pendiente 2]"
```

**El resumen debe reflejar lo que realmente ocurrió en esta actualización** — usa la misma información que mostrarías al usuario en el resumen final.

---

## Paso 12: Commit de Actualización (Opcional)

Si el proyecto usa git:

```bash
git add memsys3/
git commit -m "actualizar: memsys3 [VERSIÓN_ACTUAL] → [VERSIÓN_NUEVA]

- Prompts actualizados (compile-context, endSession, etc.)
- Agents actualizados (context-agent.yaml)
- Templates actualizados
- Visualizador actualizado
- history/ creado (Plan Contingencia)
- Metadata versión actualizada en project-status.yaml"
```

---

## Paso 13: Eliminar Backup (Después de Validar)

**SOLO después de validar que todo funciona correctamente** (mínimo 1-2 sesiones de uso):

```bash
rm -rf memsys3/docs/backups/memsys3_backup_$TIMESTAMP
```

---

## 🚨 Resolución de Problemas

### Problema: "Campo X no existe en project-status.yaml"

**Causa:** Versión muy antigua sin campos nuevos.

**Solución:**
1. Compara `project-status.yaml` actual con template nuevo
2. Añade campos faltantes manualmente (siguiendo estructura del template)
3. NO copies todo el template (perderías datos del proyecto)

### Problema: "Conflicto en newSession.md - personalizaciones vs mejoras"

**Solución:**
1. Lee ambas versiones completas
2. Identifica qué líneas son personalizaciones del proyecto (descripciones únicas)
3. Identifica qué líneas son mejoras estructurales (nuevas instrucciones)
4. Crea versión híbrida: conserva personalizaciones + aplica mejoras

### Problema: "context.yaml no compila - errores de campos"

**Causa:** context-agent.yaml nuevo espera campos que project-status.yaml antiguo no tiene.

**Solución:**
1. Lee el error específico (¿qué campo falta?)
2. Añade campo faltante a project-status.yaml siguiendo template
3. Re-ejecuta compile-context.md

---

## Paso 14: Actualizar file_version de archivos tocados

Cada archivo de infraestructura memsys3 tiene un `file_version` (formato `0.Y.Z`):
- Archivos `.md`: última línea `<!-- version: X.Y.Z -->`
- Archivos `.yaml` en agents/: campo `file_version: "X.Y.Z"`
- Archivos `.yaml` en memory/templates/: primera línea `# version: X.Y.Z`

**Para cada archivo copiado/modificado en los pasos anteriores:**

1. Lee el `file_version` del archivo nuevo (del repo clonado)
2. Ese ES el file_version correcto — ya viene actualizado desde el repo
3. No necesitas hacer nada extra: el file_version viaja con el archivo

**Registrar en operations.log:**

Usa **Edit tool** para añadir al PRINCIPIO del array `operations:` en `$MEMSYS3_ROOT/memory/full/operations.log`:

```yaml
operations:
  - timestamp: "[YYYY-MM-DDTHH:MM:SS]"
    operacion: "actualizar"
    version_anterior: "[VERSION_ACTUAL]"
    version_nueva: "[VERSION_NUEVA]"
    resultado: "ok"
    archivos_actualizados:
      - archivo: "prompts/compile-context.md"
        file_version: "0.2.0"
      - archivo: "agents/context-agent.yaml"
        file_version: "0.1.0"
      # ... (listar todos los archivos tocados con su file_version)
    resumen: "Actualización memsys3 [VERSION_ACTUAL] → [VERSION_NUEVA]. [N] archivos actualizados."
```

> **Nota:** Esta entrada complementa la del Paso 11. Si ya escribiste la entrada del Paso 11, **amplíala** añadiendo el campo `archivos_actualizados` con los file_version. No dupliques entradas — una sola entrada por operación de actualización.

---

## 📊 Checklist Final

Antes de dar por terminada la actualización, verifica:

- [ ] Backup creado en `memsys3/docs/backups/memsys3_backup_$TIMESTAMP`
- [ ] Archivos del sistema actualizados (prompts, agents, templates)
- [ ] `docs/` copiada (`ls memsys3/docs/reference.md`)
- [ ] `backlog/` existe (`ls memsys3/backlog/`)
- [ ] history/ creado (si no existía)
- [ ] Versión actualizada en `project-status.yaml` metadata (`grep memsys3_version memsys3/memory/project-status.yaml` muestra versión nueva)
- [ ] Clone temporal borrado (memsys3_update_temp)
- [ ] compile-context.md ejecutado exitosamente
- [ ] newSession.md funciona (nueva instancia)
- [ ] Actualización documentada en sessions.yaml
- [ ] Operación registrada en `memsys3/memory/full/operations.log`
- [ ] `archivos_actualizados` con `file_version` registrados en operations.log (Paso 14)
- [ ] (Opcional) Commit creado
- [ ] Backup borrado (después de 1-2 sesiones de validación)

---

## 🔗 Referencias

- Prompt relacionado: `@memsys3/prompts/deploy.md` (para deployment inicial)
- ADR relacionada: ADR-009 (templates permanentes, estructura)
- Backlog: FEATURE-002 (este prompt)

---

**¡Actualización completada!** 🎉

El sistema memsys3 de este proyecto ahora está actualizado a la última versión, conservando todos los datos históricos y personalizaciones.
<!-- version: 0.1.0 -->
