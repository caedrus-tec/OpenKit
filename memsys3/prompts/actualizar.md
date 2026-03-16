# Actualizar memsys3 - Prompt de Actualización Segura

**AHORA ACTÚAS COMO MAIN AGENT realizando una actualización de memsys3**

- Tu misión es **actualizar la versión de memsys3** en este proyecto de forma segura
- **IMPORTANTE: Trabaja en ESPAÑOL siempre**
- Este prompt complementa `deploy.md` (que es para deployment inicial)

---

## ⚠️ ANTES DE EMPEZAR

### Paso 0a: Verificar working directory

**CRÍTICO — ejecuta esto primero:**

```bash
pwd
ls memsys3/memory/project-status.yaml 2>/dev/null && echo "OK: memsys3/ encontrado" || echo "ERROR: memsys3/ no encontrado en este directorio"

# Guardar ruta absoluta del proyecto (se usa en todo el proceso)
PROJECT_ROOT=$(pwd)
echo "PROJECT_ROOT=$PROJECT_ROOT"

# Limpiar artefactos de ejecuciones anteriores
rm -rf memsys3_update_temp memsys3_templates 2>/dev/null
echo "Artefactos previos limpiados"
```

**Si no encuentra `memsys3/`:** detente. Pregunta al usuario desde qué directorio ejecutar la actualización. No continues hasta confirmarlo.

**Si encuentra `memsys3/`:** continúa con el bootstrap.

**IMPORTANTE:** Todos los pasos siguientes deben usar `$PROJECT_ROOT` como referencia para rutas absolutas. Evita `cd` siempre que sea posible.

### Paso 0b: Bootstrap — actualizar este prompt antes de continuar

```bash
git clone https://github.com/iv0nis/memsys3 memsys3_update_temp
cp memsys3_update_temp/memsys3_templates/prompts/actualizar.md memsys3/prompts/actualizar.md
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
cat memsys3/memory/project-status.yaml | grep -A2 "metadata:"
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
- `memsys3/memory/history/*` (si existe)

### ✅ ACTUALIZAR SIEMPRE (lógica del sistema)

Estos son parte del "motor" de memsys3, se pueden sobrescribir:

**Prompts:**
- `memsys3/prompts/compile-context.md`
- `memsys3/prompts/endSession.md`
- `memsys3/prompts/mind.md`
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

**Visualizador:**
- `memsys3/viz/index.html`
- `memsys3/viz/viewer.js`
- `memsys3/viz/styles.css`
- `memsys3/viz/serve.py`

**Templates:**
- `memsys3/memory/templates/adr-template.yaml`
- `memsys3/memory/templates/sessions-template.yaml`
- `memsys3/memory/templates/context-template.yaml`
- `memsys3/memory/templates/project-status-template.yaml`

**Documentación del sistema:**
- `memsys3/memory/README.md`
- `memsys3/viz/README.md`

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
mkdir -p memsys3/docs/backups

# Migrar backups antiguos de la raíz (si los hay)
for old_backup in memsys3_backup_*/; do
  [ -d "$old_backup" ] && mv "$old_backup" "memsys3/docs/backups/$old_backup" && echo "Migrado: $old_backup"
done

# Crear backup actual (fuera de memsys3/ para evitar auto-recursión)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
rsync -a --exclude='docs/backups' memsys3/ memsys3_backup_temp_$TIMESTAMP/
mv memsys3_backup_temp_$TIMESTAMP memsys3/docs/backups/memsys3_backup_$TIMESTAMP

echo "Backup creado en: memsys3/docs/backups/memsys3_backup_$TIMESTAMP"

# Limpiar backups antiguos (máx 3: 2 anteriores + actual)
cd memsys3/docs/backups
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

## Paso 6: Actualizar Archivos del Sistema

```bash
# Crear directorios necesarios (siempre, antes de copiar nada)
mkdir -p memsys3/docs memsys3/docs/backups memsys3/prompts memsys3/agents memsys3/memory/templates memsys3/viz

# Crear backlog/ si no existe
if [ ! -f memsys3/backlog/README.md ]; then
  mkdir -p memsys3/backlog
  echo "# Backlog" > memsys3/backlog/README.md
  echo "backlog/ creado"
fi
```

### 6.1 Actualizar Prompts y Docs

**Estrategia principal: git diff --name-status**

```bash
CURRENT_VERSION=$(grep "memsys3_version" memsys3/memory/project-status.yaml | head -1 | sed 's/.*: "\(.*\)"/\1/')
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
- **A (añadido) o M (modificado):** cópialo al directorio correspondiente en `memsys3/`
  - `memsys3_templates/prompts/X` → `memsys3/prompts/X`
  - `memsys3_templates/docs/X` → `memsys3/docs/X`
  - `memsys3_templates/agents/X` → `memsys3/agents/X`
  - `memsys3_templates/viz/X` → `memsys3/viz/X`
  - `memsys3_templates/memory/X` → `memsys3/memory/X`
  - **Excepto** `newSession.md` y `main-agent.yaml` → ver pasos 6.2 y 6.3
- **D (eliminado):** borra el archivo correspondiente en `memsys3/`

**Si git diff funciona, NO ejecutes el fallback. Son mutuamente excluyentes.**

---

**Fallback: lista completa (SOLO si git diff falla — error de salida, versión no encontrada)**

```bash
# Copiar prompts actualizados (excepto newSession.md por ahora)
cp memsys3_update_temp/memsys3_templates/prompts/compile-context.md memsys3/prompts/
cp memsys3_update_temp/memsys3_templates/prompts/endSession.md memsys3/prompts/
cp memsys3_update_temp/memsys3_templates/prompts/mind.md memsys3/prompts/
cp memsys3_update_temp/memsys3_templates/prompts/github.md memsys3/prompts/
cp memsys3_update_temp/memsys3_templates/prompts/deploy.md memsys3/prompts/
cp memsys3_update_temp/memsys3_templates/prompts/actualizar.md memsys3/prompts/
cp memsys3_update_temp/memsys3_templates/prompts/adr.md memsys3/prompts/
cp memsys3_update_temp/memsys3_templates/prompts/backlog.md memsys3/prompts/
cp memsys3_update_temp/memsys3_templates/prompts/commands.md memsys3/prompts/
cp memsys3_update_temp/memsys3_templates/prompts/meet.md memsys3/prompts/
cp memsys3_update_temp/memsys3_templates/prompts/agent-identity.md memsys3/prompts/

# Limpiar docs/*.md antiguos y copiar los nuevos
rm -f memsys3/docs/*.md
cp -r memsys3_update_temp/memsys3_templates/docs/* memsys3/docs/ 2>/dev/null || true
echo "docs/ actualizada (limpieza + copia)"
```

### 6.2 Revisar newSession.md

```bash
# Comparar versiones
diff memsys3/prompts/newSession.md memsys3_update_temp/memsys3_templates/prompts/newSession.md
```

**Si hay diferencias:**
- Lee ambas versiones
- Conserva personalizaciones del proyecto (descripciones específicas, contexto único)
- Aplica mejoras estructurales de la nueva versión
- Edita manualmente si es necesario

**Si NO hay diferencias (archivo base sin personalizar):**
```bash
cp memsys3_update_temp/memsys3_templates/prompts/newSession.md memsys3/prompts/
```

### 6.3 Actualizar Agents

```bash
# Context Agent (siempre actualizar)
cp memsys3_update_temp/memsys3_templates/agents/context-agent.yaml memsys3/agents/

# Main Agent (revisar personalizaciones)
diff memsys3/agents/main-agent.yaml memsys3_update_temp/memsys3_templates/agents/main-agent.yaml
```

**Estrategia main-agent.yaml:** igual que newSession.md (conservar personalizaciones + aplicar mejoras)

### 6.4 Actualizar Templates

```bash
cp memsys3_update_temp/memsys3_templates/memory/templates/*.yaml memsys3/memory/templates/
```

### 6.5 Actualizar Visualizador

**IMPORTANTE:** Verificar ubicación según versión.

**Si tienes memsys3/memory/viz/ (versión antigua):**
```bash
# Mover a raíz (nueva ubicación según ADR-009)
mkdir -p memsys3/viz
cp memsys3_update_temp/memsys3_templates/viz/* memsys3/viz/

# Opcional: borrar ubicación antigua (después de verificar que funciona)
# rm -rf memsys3/memory/viz/
```

**Si ya tienes memsys3/viz/ (versión nueva):**
```bash
cp memsys3_update_temp/memsys3_templates/viz/* memsys3/viz/
```

### 6.6 Crear history/ si no existe

```bash
# Crear directorio para Plan de Contingencia (si no existe)
mkdir -p memsys3/memory/history
touch memsys3/memory/history/.gitkeep
```

### 6.7 Actualizar Documentación del Sistema

```bash
cp memsys3_update_temp/memsys3_templates/memory/README.md memsys3/memory/
cp memsys3_update_temp/memsys3_templates/viz/README.md memsys3/viz/ 2>/dev/null || true
```

---

## Paso 7: Actualizar Metadata de Versión

**Hacer esto ANTES de limpiar el clone temporal** (necesitas NEW_VERSION del Paso 3).

Edita `memsys3/memory/project-status.yaml`:

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
grep "memsys3_version" memsys3/memory/project-status.yaml
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

### 9.2 Verificar Visualizador

```bash
@memsys3/prompts/mind.md
```

**Verifica:**
- ✅ Servidor arranca sin errores
- ✅ Dashboard se ve correctamente en http://localhost:8000
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

## Paso 11: Commit de Actualización (Opcional)

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

## Paso 12: Eliminar Backup (Después de Validar)

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

### Problema: "viz/ no se encuentra"

**Causa:** Versión antigua con viz en `memory/viz/` vs nueva ubicación `viz/`

**Solución:** Ver Paso 6.5 (mover de memory/viz/ a viz/)

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

## 📊 Checklist Final

Antes de dar por terminada la actualización, verifica:

- [ ] Backup creado en `memsys3/docs/backups/memsys3_backup_$TIMESTAMP`
- [ ] Archivos del sistema actualizados (prompts, agents, templates, viz)
- [ ] `docs/` copiada (`ls memsys3/docs/reference.md`)
- [ ] `backlog/` existe (`ls memsys3/backlog/`)
- [ ] history/ creado (si no existía)
- [ ] Versión actualizada en `project-status.yaml` metadata (`grep memsys3_version memsys3/memory/project-status.yaml` muestra versión nueva)
- [ ] Clone temporal borrado (memsys3_update_temp)
- [ ] compile-context.md ejecutado exitosamente
- [ ] Visualizador funciona (mind.md)
- [ ] newSession.md funciona (nueva instancia)
- [ ] Actualización documentada en sessions.yaml
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
