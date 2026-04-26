# Deploy memsys3 - Configura el Sistema Memory para tu Proyecto

Tu (DevAgent) debes configurar memsys3 por primera vez en este proyecto.

## Objetivo

Desplegar la estructura completa de memsys3 al proyecto actual desde GitHub, personalizarla e inicializarla.

## Workflow de Deployment

### Paso 1: Clonar Temporalmente memsys3

El usuario te indicará desde qué directorio trabajas. Normalmente será el directorio raíz de su proyecto.

```bash
# Verificar que no hay deployment previo
if [ -d "memsys3" ]; then
  echo "⚠️  ERROR: memsys3/ ya existe en este proyecto"
  echo ""
  echo "Parece que ya has desplegado memsys3 aquí."
  echo "Si quieres reinstalar, renombra o elimina primero:"
  echo "  mv memsys3 memsys3_backup"
  echo "  # o"
  echo "  rm -rf memsys3"
  exit 1
fi

# Limpiar memsys3_temp si existe de ejecución previa
if [ -d "memsys3_temp" ]; then
  echo "Limpiando memsys3_temp/ de ejecución previa..."
  rm -rf memsys3_temp
fi

# Clonar el repositorio como directorio temporal
git clone https://github.com/iv0nis/memsys3 memsys3_temp
```

### Paso 2: Copiar Estructura a memsys3/

Copia TODA la estructura de memsys3_templates/ al directorio memsys3/ del proyecto:

```bash
# Crear estructura base
mkdir -p memsys3/memory/full
mkdir -p memsys3/memory/templates
mkdir -p memsys3/memory/history
mkdir -p memsys3/prompts
mkdir -p memsys3/agents

# Crear .gitkeep en history/ para que se suba a git
touch memsys3/memory/history/.gitkeep

# Copiar templates
cp memsys3_temp/memsys3_templates/memory/templates/*.yaml memsys3/memory/templates/

# Copiar prompts
cp memsys3_temp/memsys3_templates/prompts/*.md memsys3/prompts/

# Copiar agents
cp memsys3_temp/memsys3_templates/agents/*.yaml memsys3/agents/

# Copiar README
cp memsys3_temp/memsys3_templates/memory/README.md memsys3/memory/

# Crear archivos vacíos memory/full/
cat > memsys3/memory/full/adr.yaml << 'EOF'
# ADR Log - [NOMBRE_PROYECTO]
# Architecture Decision Records del proyecto

adrs: []
EOF

cat > memsys3/memory/full/sessions.yaml << 'EOF'
# Sessions Log - [NOMBRE_PROYECTO]
# Histórico de sesiones de desarrollo

sessions: []
EOF

cat > memsys3/memory/full/operations.log << 'EOF'
# Operations Log - [NOMBRE_PROYECTO]
# Registro automático de operaciones del sistema (actualizar, compilar)
# Formato: YAML append-only, orden cronológico inverso (más reciente primero)
# Rotación: cuando >= 1800 líneas, rotar a operations_N.log (estilo sessions)
# Archivos rotados se pueden borrar libremente (no hay archivado)
# Este archivo NO se lee en newSession ni compile-context — solo consulta bajo demanda

operations: []
EOF
```

### Paso 3: Briefing con el Usuario

Antes de personalizar, lee `memsys3/memory/templates/project-status-template.yaml` para saber qué campos necesitas.

Usa `AskUserQuestion` para recopilar la info en dos fases (máximo 4 preguntas por llamada):

**Fase A — Información esencial** (usa AskUserQuestion):
1. **Nombre del proyecto**: ¿Cómo se llama?
2. **Descripción + objetivo**: ¿Qué hace y cuál es el goal principal?
3. **Fase actual**: Planificación / MVP / Beta / Producción
4. **Idioma del proyecto**: ¿UI y código en qué idioma?

**Fase B — Stack y URLs** (segunda llamada AskUserQuestion si la info no quedó clara):
1. **Frontend**: Framework + versión
2. **Backend**: Tecnología (si aplica)
3. **Deployment platform**: Vercel, Railway, VPS, etc.
4. **URLs**: Producción y staging (si existen)

Si el usuario responde todo en texto libre en la primera fase, no es necesaria la segunda llamada.

### Paso 4: Registrar Versión de memsys3

Obtén la versión y commit del repositorio clonado:

```bash
cd memsys3_temp
MEMSYS3_VERSION=$(git describe --tags --always)
MEMSYS3_COMMIT=$(git log -1 --format=%h)
cd ..
```

### Paso 5: Crear project-status.yaml

> ⚠️ **IMPORTANTE:** Este archivo va en `memsys3/memory/` (raíz de memory),
> **NO** en `memsys3/memory/full/` como `adr.yaml` y `sessions.yaml`.

Con la info recopilada, crea `memsys3/memory/project-status.yaml`:

```yaml
# Project Status - [NOMBRE_PROYECTO]

metadata:
  ultima_actualizacion: "[FECHA_HOY]"
  actualizado_por: "Claude (Initial Deployment)"
  fase: "[FASE]"
  memsys3_version: "[MEMSYS3_VERSION obtenida en Paso 4]"
  memsys3_deployed: "[FECHA_HOY]"

vision_general:
  que_es: "[DESCRIPCION_1_LINEA]"
  objetivo: "[OBJETIVO_PRINCIPAL]"
  cliente: "[CLIENTE_O_STAKEHOLDER_SI_APLICA]"

estado_actual:
  fase: "[FASE_ACTUAL]"
  ultima_feature: "Deployment inicial de memsys3"
  siguiente_milestone: "[PROXIMO_OBJETIVO]"

features: {}

stack_tecnologico:
  frontend:
    framework: "[FRAMEWORK]"
    # Añade campos según respuesta usuario

  backend:
    # Si aplica

  deploy:
    platform: "[PLATFORM]"

urls:
  # production: "[URL_SI_EXISTE]"
  # staging: "[URL_SI_EXISTE]"

pendientes_prioritarios:
  # Si user ha mencionado tareas, añádelas
  # De lo contrario deja vacío

decisiones_clave: {}
convenciones_codigo: {}
historico_sesiones: []
```

### Paso 6: Personalizar prompts/newSession.md

Edita `memsys3/prompts/newSession.md` con la información del proyecto:

```markdown
- En este proyecto trabajaremos en [DESCRIPCION_DEL_PROYECTO].
- Actúa según las instrucciones en '@memsys3/agents/main-agent.yaml'
- [COMPORTAMIENTO_ESPECIFICO_SI_USER_HA_PEDIDO]
- Lee @memsys3/memory/project-status.yaml y @memsys3/memory/context.yaml
```

### Paso 7: Personalizar agents/main-agent.yaml (opcional)

Si el usuario ha especificado algo particular sobre el comportamiento del agente, añádelo:

```yaml
comportamiento_especific:
  [SI_USER_HA_PEDIDO]: "[INSTRUCCION]"
```

### Paso 8: Configurar .gitignore (Incluir memsys3 en GitHub)

**IMPORTANTE:** Usa `AskUserQuestion` para preguntar al usuario si quiere incluir memsys3/ en git.

**Razón para INCLUIR (recomendado):**
- Evita perder el contexto si cambias de máquina o el directorio se mueve
- Las @ menciones funcionan normalmente (`@memsys3/prompts/newSession.md`)
- Permite compartir contexto con el equipo si el repo es privado
- El historial de sesiones y decisiones queda respaldado

**Razón para excluir:**
- Si el repositorio es público y el contexto contiene información sensible
- Si prefieres que sea estrictamente local

Usa `AskUserQuestion` con esta pregunta:

```
¿Quieres incluir memsys3/ en git?

A) Sí, incluir memsys3/ en git (RECOMENDADO)
   - Las @ menciones funcionarán normalmente
   - El contexto queda respaldado y no se pierde
   - Necesario si el repo es privado y trabajas en equipo

B) No, excluir memsys3/ de git
   - memsys3/ solo existirá en tu máquina local
   ⚠️ Las @ menciones NO funcionarán (limitación de Claude Code con archivos ignorados)
   ⚠️ Riesgo de perder contexto si mueves el directorio o cambias de máquina
```

**Si el usuario elige OPCIÓN A (recomendado):**

- No modificar .gitignore
- Verificar que memsys3/ NO está en .gitignore:
  ```bash
  grep -q "memsys3" .gitignore 2>/dev/null && echo "⚠️ memsys3 está en .gitignore, considera eliminarlo" || echo "✅ memsys3 no está excluido"
  ```
- Si estaba excluido previamente, ofrecer eliminarlo del .gitignore

**Si el usuario elige OPCIÓN B:**

1. Lee el .gitignore existente (si existe):
   ```bash
   cat .gitignore 2>/dev/null || echo "# .gitignore no existe, se creará"
   ```

2. Si NO está excluido, agrégalo al .gitignore:
   - Si .gitignore existe → usa Edit tool para agregar al final:
     ```
     # memsys3 - Sistema de gestión de contexto (local only)
     memsys3/
     ```
   - Si .gitignore NO existe → usa Write tool para crearlo:
     ```
     # memsys3 - Sistema de gestión de contexto (local only)
     memsys3/
     ```

3. Informa la limitación:
   > ⚠️ Con esta opción las @ menciones no funcionarán. Usa instrucciones directas:
   > - "Ejecuta memsys3/prompts/newSession.md"
   > - "Lee y ejecuta memsys3/prompts/compile-context.md"

### Paso 9: Eliminar Clone Temporal

```bash
rm -rf memsys3_temp
```

### Paso 10: Informar al Usuario

Confirma que el deployment se ha completado correctamente:

```
✅ memsys3 deployment completado!

Estructura creada:
- memsys3/memory/full/ (adr.yaml, sessions.yaml, operations.log inicializados)
- memsys3/memory/templates/ (guías permanentes)
- memsys3/memory/history/ (para Plan Contingencia)
- memsys3/prompts/ (newSession, endSession, compile-context, etc.)
- memsys3/agents/ (main-agent, context-agent)

Archivos personalizados:
- memsys3/memory/project-status.yaml
- memsys3/prompts/newSession.md

Próximos pasos:
1. Compila context inicial: @memsys3/prompts/compile-context.md
2. Comienza a trabajar con sesiones: @memsys3/prompts/newSession.md

Escalabilidad automática:
📈 Rotación automática: >1800 líneas → sessions_N.yaml, adr_N.yaml
📦 Plan Contingencia: >150K tokens → archivado a history/
🔍 Context compilado: máximo 2000 líneas por sesión
```

## Notas Importantes

- **Templates permanentes**: `memory/templates/` son guías que Main-Agent consultará durante endSession. NO los borres.
- **Clone temporal**: memsys3_temp/ se borra después de copiar. Es solo para deployment.
- **Personalización mínima**: Solo project-status.yaml y newSession.md necesitan personalización. Resto de archivos son agnósticos.
- **Idioma**: Pregunta al usuario qué idioma quiere para la interfaz y el código.

## Troubleshooting

**"git clone falla":**
- Verifica conexión a internet
- Comprueba que git está instalado: `git --version`

**"mkdir falla":**
- Verifica que estás en el directorio correcto del proyecto
- Comprueba permisos de escritura

**"Templates no se copian":**
- Verifica que memsys3_temp/ existe
- Comprueba que la ruta memsys3_temp/memsys3_templates/ tiene los archivos

---

**Deployment completado. El sistema está listo para usar.**
<!-- version: 0.1.0 -->
