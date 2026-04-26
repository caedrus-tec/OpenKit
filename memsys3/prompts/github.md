# GitHub - Subir cambios al repositorio

## Instrucciones

- Sube el repo a GitHub en español, sin emojis ni firmas
- Commits atómicos y descriptivos
- **SIEMPRE propón crear tag** (usuario confirma)
- No subas la versión más allá de la 0.x.x hasta que sea estable
- Solo aumenta el minor si hay cambio relevante, en caso contrario aumenta el patch

## ⚠️ IMPORTANTE: Obligatorio usar AskUserQuestion

**SIEMPRE usa la tool `AskUserQuestion` para confirmar la versión del tag.** No escribas las opciones en texto plano — invoca la tool. El usuario debe poder seleccionar la opción interactivamente.

## ⚠️ IMPORTANTE: Commits SIN Firma

**NUNCA añadas firma "Co-Authored-By: Claude" en commits.**

- ❌ MAL: Incluir "Co-Authored-By: Claude Sonnet 4.5" en mensaje
- ✅ BIEN: Commits limpios sin líneas adicionales de autoría

**Razón:** Los commits deben reflejar solo autoría del usuario, no del agente.

## Workflow

### 1. Revisar cambios

```bash
git status
git diff --stat
git log --oneline -10
```

### 2. Analizar cambios desde último tag

**Obtener último tag:**
```bash
git describe --tags --abbrev=0  # Último tag (ej: v0.7.1)
```

**Analizar qué cambió:**
- Sesiones documentadas desde último tag (leer sessions.yaml)
- Features/fixes implementados
- ADRs creadas
- Breaking changes (¿requiere actualizar.md?)

### 3. Proponer versión de tag al usuario

**SIEMPRE propón crear tag** (filosofía memsys3: sesión documentada = progreso significativo)

**Formato de propuesta:**

```
📊 Análisis de cambios desde [ÚLTIMO_TAG]:

- Sesiones documentadas: [N]
  - [FECHA]: [Título sesión 1]
  - [FECHA]: [Título sesión 2]
  ...

- Features nuevas: [N]
- Fixes críticos: [N]
- ADRs creadas: [N] ([IDs])
- Breaking changes: [Sí/No]

---

💡 Propongo: v0.X.Y

Justificación:
- Minor (+0.1.0): [Razón si aplica]
- Patch (+0.0.1): [Razón si aplica]

Mensaje del tag:
"""
Release v0.X.Y: [Resumen breve]

Features:
- [Feature 1] (sesión [fecha])
- [Feature 2] (sesión [fecha])

Fixes:
- [Fix 1]

ADRs: [IDs creadas]
Sessions: [N] desde [ÚLTIMO_TAG]
Breaking changes: [Ninguno/Descripción]
"""

```

Tras mostrar el análisis, usa `AskUserQuestion` para confirmar:

```
AskUserQuestion(
  question: "¿Qué versión creamos?",
  header: "Versión tag",
  options: [
    { label: "v0.X.Y (Patch)", description: "Confirmar la versión propuesta (patch +0.0.1)" },
    { label: "v0.X+1.0 (Minor)", description: "Subir minor en su lugar (+0.1.0)" },
    { label: "Sin tag por ahora", description: "Solo hacer commit, sin crear tag" }
  ]
)
```

**Criterios para Minor vs Patch:**

- **Minor (+0.1.0):** Feature nueva, mejora arquitectónica significativa, múltiples cambios
- **Patch (+0.0.1):** Fixes, mejoras menores, documentación, refactors sin cambio funcional

### 4. Actualizar versiones internas (si usuario confirma tag)

**ANTES de crear el tag, actualizar:**

1. **README.md** (línea `**Versión**: X.Y`)
2. **memsys3/memory/project-status.yaml** (`memsys3_version`)
3. Commit estos cambios de versión

```bash
# Editar archivos con nueva versión
# ...

# ⚠️ Commit SIN Co-Authored-By (NO añadir firma de Claude)
git add README.md memsys3/memory/project-status.yaml
git commit -m "chore: bump version to v0.X.Y"

# Verificar que NO contiene firma
git log -1 --format="%B"
```

### 5. Ejecutar commits y push

**Si usuario confirmó crear tag:**

```bash
# Push commits (incluye bump de versión)
git push origin master

# Crear y subir tag con metadata rica (NO añadir Co-Authored-By)
git tag -a v0.X.Y -m "Release v0.X.Y: [Resumen]

Features:
- [Feature 1] (sesión YYYY-MM-DD)
- [Feature 2] (sesión YYYY-MM-DD)

Fixes:
- [Fix 1]

ADRs: [IDs]
Sessions: [N] desde [ÚLTIMO_TAG]
Breaking changes: [Ninguno/Descripción]"

git push --tags
```

**Si usuario NO quiere tag (solo en casos excepcionales):**

```bash
git add .
git commit -m "[mensaje descriptivo]"
git push origin master
```

### 6. Verificar en GitHub

```bash
# Verificar que commits NO tienen firma
git log -5 --format="%B" | grep -i "co-authored" && echo "❌ ERROR: Firma detectada" || echo "✅ OK: Sin firma"

# Verificar que tag llegó
git ls-remote --tags origin | tail -3

# Verificar último commit
git log -1 --oneline
```

## Notas Importantes

- **Filosofía memsys3:** Si documentaste sesión = hiciste trabajo significativo = merece tag
- **Metadata rica:** Mensaje del tag incluye contexto (sesiones, ADRs, breaking changes)
- **Trazabilidad:** Cada tag = snapshot navegable del proyecto
- **actualizar.md:** Depende de tags para funcionar correctamente
- **SemVer:** Mantener formato v0.X.Y (3 números) estándar
- **No llegar a v1.0.0** hasta considerar el sistema "estable completo"

## Ejemplo Real

```
📊 Análisis de cambios desde v0.7.1:

- Sesiones documentadas: 2
  - 2025-12-09: Comando global deploy-memsys3
  - 2025-12-11: Sistema gestión ADRs

- Features nuevas: 2 (adr.md, deploy global)
- ADRs creadas: 1 (ADR-013)
- Breaking changes: No

---

💡 Propongo: v0.8.0 (minor bump: 2 features significativas)

Mensaje del tag:
"""
Release v0.8.0: Sistema gestión ADRs + comando global deploy

Features:
- Comando global /deploy-memsys3 (sesión 2025-12-09)
- Sistema gestión ADRs con prompt adr.md (sesión 2025-12-11)

ADRs: ADR-013 (consistencia arquitectónica)
Sessions: 2 desde v0.7.1
Breaking changes: Ninguno
"""

❓ ¿Confirmas v0.8.0?
```
<!-- version: 0.1.0 -->
