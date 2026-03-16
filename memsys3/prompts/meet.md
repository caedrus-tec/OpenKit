# meet.md — Reuniones entre Agentes

Usa este prompt cuando necesites coordinar o investigar algo con otro agente.

---

## Antes de empezar

**¿Qué tipo de reunión necesitas?**

- **Coordinación** (repartir tareas, resolver conflictos de trabajo paralelo, decisiones compartidas) → lee solo las secciones **Protocolo común** y **Modo coordinación**
- **Investigación** (bug crítico, incidente, algo que salió mal y necesita análisis forense) → lee el documento completo

---

## 1. Protocolo común

Aplica a todos los tipos de reunión.

### ¿Cuándo usar una reunión formal?

**SÍ** — cuando:
- Dos agentes van a tocar el mismo código o ficheros en paralelo
- Hay un conflicto o solapamiento detectado que requiere coordinación explícita
- Se necesita una decisión que afecta a múltiples agentes o proyectos
- Un bug crítico requiere análisis conjunto

**NO** — cuando:
- El moderador puede resolver el conflicto directamente por chat
- Es una pregunta puntual que no requiere turnos
- Un solo agente tiene toda la información necesaria

### Naming y ubicación del archivo

```
memsys3/docs/meets/YYYYMMDD_N.md
```
- `YYYY` año, `MM` mes, `DD` día, `N` número de reunión del día
- El archivo va en el proyecto **dueño del tema** discutido
- Si el tema es transversal sin dueño claro: el moderador decide antes de crear el archivo

**Header estándar:**
```markdown
# Reunión YYYYMMDD_N — [Objetivo en una línea]

**Fecha:** YYYY-MM-DD
**Agentes:** [Agent A (proyecto)], [Agent B (proyecto)]
**Moderador:** [nombre]
**Objetivo:** [Qué se quiere conseguir]
```

**Identificación de agentes:**
- Mismo proyecto: `Agent A`, `Agent B`
- Proyectos distintos: `Agent A (proyecto)`, `Agent B (proyecto)`

> **Nota:** `Agent A`, `Agent B`, etc. son el nombre que el moderador asigna a cada sesión de Claude Code al convocarla. No es un ID técnico del sistema — es simplemente la identidad conversacional para esta reunión. Si no recuerdas quién eres, pregunta al moderador.

### Sistema de turnos

**Formato de cada turno:**
```markdown
## [Agent X (proyecto)] → [Agent Y (proyecto)]

[Contenido]

Tu turno, [Agent Y].
```

**Reglas:**
- El header SIEMPRE apunta al agente destinatario: `→ [Agent Y]`
- Nunca usar `→ Ivonis` o `→ Moderador` durante turnos activos — eso es para el resumen en chat
- Para cerrar tu participación sin esperar más turnos: escribe `CIERRE` al final de tu sección
- Cuando ambos agentes cierran, el moderador escribe la Decisión

### Checklist obligatorio tras cada turno

Cada vez que escribes un turno en el archivo, ejecutas estos 3 pasos **siempre, en este orden, sin excepciones**:

**1. ESCRIBIR** — tu turno en el archivo con header `## Agent X → Agent Y`

**2. RESUMIR** — envía al moderador en chat:

```
CTA: [Turno a Agent Y / Pregunta directa a ti / CIERRE]
Detalle: [Qué propuse, qué cambié, qué quedó sin resolver]
Polling: lanzado (bg task ID: [ID]) esperando respuesta de Agent Y
```

Al escribir `CIERRE`, añade también:

```
TL;DR: [1-2 líneas de qué se acordó]
Decisión propuesta: [texto listo para escribir en el archivo si el moderador confirma]
Pendiente: [próximo paso + responsable]
```

**3. POLLING** — inmediatamente después del resumen, lanza en background:

```bash
FILE="memsys3/docs/meets/YYYYMMDD_N.md"
# Primero verificar si el otro agente ya respondió
tail -60 "$FILE"
```

Si ya respondió → responde directamente, sin polling.

Si no respondió → lanza polling en background (`run_in_background: true`):

```bash
INITIAL=$(grep -c "^## Agent [DESTINO]" "$FILE" | tr -d '[:space:]')
for i in $(seq 1 40); do
  current=$(grep -c "^## Agent [DESTINO]" "$FILE" | tr -d '[:space:]')
  if [ "$current" -gt "$INITIAL" ]; then
    tail -60 "$FILE"
    exit 0
  fi
  sleep 15
done
echo "Timeout — verificar si el otro agente respondió"
```

Adaptar `[DESTINO]` al nombre del agente que esperas. El task ID del background process va en el campo `Polling:` del resumen.

El moderador confirma con "sí/no". Si confirma, el convocante escribe la `## Decisión` en el archivo.

### Briefing

Puede darse por chat (es lo natural). Lo importante: que quede incorporado al archivo. Dos opciones:
- El moderador lo escribe en la sección `## Briefing (Moderador)` antes de convocar
- Cada agente resume al inicio de su turno lo que entendió del briefing recibido por chat

### Guardar en sessions.yaml

No duplicar contenido. En sessions.yaml de cada proyecto afectado:

```yaml
highlights:
  - "Reunión [tipo] con [Agente] sobre [tema] → memsys3/docs/meets/YYYYMMDD_N.md"
  - "[Resultado principal]"
```

### Troubleshooting

**Reunión interrumpida**: el archivo queda como estaba. El agente que retoma lee desde el último `---` y continúa.

**Polling con timeout**: verificar que el otro agente recibió el turno. Relanzar el polling si es necesario.

**Múltiples reuniones en un día**: usar `_2`, `_3`... en el nombre del archivo.

**Header mal formateado / polling no detecta**: verificar que el header empieza exactamente con `## Agent` en la primera columna, sin espacios previos.

---

## 2. Modo coordinación

Para: reparto de tareas, conflictos de trabajo paralelo, decisiones compartidas, diseño conjunto.

### Flujo del moderador

**PASO 1 — Crear el archivo y escribir el briefing**

El agente convocante crea `memsys3/docs/meets/YYYYMMDD_N.md` con:
1. Header estándar (Protocolo común)
2. Sección `## Briefing` con objetivo, contexto y pregunta a deliberar

El briefing debe ser suficiente para que el otro agente entienda todo sin necesitar contexto adicional por chat.

```markdown
## Briefing

**Objetivo:** [Qué se quiere decidir]
**Contexto:** [Información necesaria para deliberar]
**Pregunta:** [Qué debe responder/proponer el otro agente]
```

**PASO 2 — Convocar**

Basta con pasar el path al otro agente — el archivo contiene todo el contexto:

```
memsys3/docs/meets/YYYYMMDD_N.md
```

**PASO 3 — Esperar turnos**

Los agentes se coordinan solos via polling. El moderador solo interviene si hay un bloqueo o si le preguntan directamente.

**PASO 4 — Decisión**

Cuando todos los agentes han escrito `CIERRE`, el convocante propone la Decisión en el chat (ver Resumen en chat). El moderador confirma con "sí/no". Si confirma, el convocante escribe en el archivo:

```markdown
## Decisión (Moderador)

[Resolución final, próximos pasos, qué hace cada agente]

**Fecha cierre:** YYYY-MM-DD
```

---

## 3. Modo investigación

Para: bugs críticos, incidentes, análisis forense multi-agente, post-mortems, decisiones arquitectónicas con múltiples alternativas.

### Roles

**Investigador** — plantea el problema, hace preguntas diagnósticas, propone solución
**Investigado** — responde honestamente, reconstruye secuencia, evalúa solución

**Detección automática de rol:**
- "investiga a [agente]" o "analiza [problema]" → tú = Investigador
- "responde a [agente]" o "reunión con [agente]" sobre algo que hiciste → tú = Investigado
- No especificado → preguntar: "¿Actúo como Investigador o Investigado?"

---

### PASO 1: Recopilar contexto antes de iniciar

**Si eres Investigador:**
1. Leer archivos afectados y cambios recientes (`git log --oneline -10`, `git diff --stat HEAD~5..HEAD`)
2. Identificar evidencias: qué archivos afectados, cuándo ocurrió, qué debería pasar vs qué pasó
3. Preparar 5-6 preguntas diagnósticas (temporales, técnicas, procesales, psicológicas)

**Si eres Investigado:**
1. Reconstruir secuencia honestamente: comandos ejecutados, archivos modificados, punto de fallo
2. Analizar razonamiento: qué pensabas, qué asumiste, qué malinterpretaste
3. Identificar causa raíz: por qué hiciste lo que hiciste, qué habría prevenido el error

---

### PASO 2: Ejecutar las 6 fases

#### Fase 1 — Apertura (Investigador)

```markdown
## [Investigador] → [Investigado]

Hola. He identificado que [problema/incidente brevemente].

Para entender qué ocurrió, necesito tu ayuda con estas preguntas:

1. **¿Cuándo ocurrió?** [Detalle temporal específico]
2. **¿Qué herramienta/comando usaste?** [Detalle técnico]
3. **¿Leíste [archivo] antes de [acción]?** [Verificación proceso]
4. **¿Qué pensabas en ese momento?** [Razonamiento]
5. **¿Qué contenía [archivo] antes?** [Estado previo]
6. **[Pregunta adicional contextual]**

Tu turno, [Investigado].
```

**Tono:** profesional, curioso, NO acusatorio. Preguntas específicas, nunca vagas.

---

#### Fase 2 — Respuesta honesta (Investigado)

```markdown
## [Investigado] → [Investigador]

Gracias por tu análisis. Respondo honestamente:

**1. ¿Cuándo ocurrió?**
[Detección / momento exacto / contexto]

**2. ¿Qué herramienta/comando usaste?**
[Comandos específicos y por qué]

**3. ¿Leíste [archivo]?**
[SÍ con detalles / NO / Parcialmente + por qué]

**4. ¿Qué pensabas?**
[Razonamiento: qué asumiste, qué entendiste]

**5. ¿Qué contenía [archivo] antes?**
[Estado previo]

---

## Análisis de lo que ocurrió

1. **Estado inicial:** [descripción]
2. **Acción ejecutada:** [qué hice específicamente]
3. **Punto de fallo:** [dónde/cuándo falló]
4. **Consecuencias:** [impacto observado]

**Hipótesis causa raíz:** [por qué ocurrió — instrucción ambigua, hábito, malinterpretación]

---

## Mitigación realizada

- ✅ [Acción mitigadora] / ⚠️ Sin mitigación aún

## Compromiso para evitar recurrencia

1. [Acción preventiva concreta]
2. [Acción preventiva concreta]

Tu turno, [Investigador].
```

**Principios:** transparencia radical, NO defensivo, admitir errores abiertamente.

---

#### Fase 3 — Análisis profundo (Investigador)

```markdown
## [Investigador] → [Investigado]

Gracias por tu transparencia. [Validación positiva específica.]

**Validación de tu análisis:**
- ✅ [Punto validado]
- ✅ [Punto validado]
- ⚠️ [Matiz si necesario]

---

## Análisis profundo

He analizado `[archivo]` completo y encontré el problema:

**Instrucción actual ([archivo] línea X-Y):**
[Copiar texto problemático]

**Problemas:**
1. ❌ NO especifica [aspecto crítico]
2. ❌ Asume que [suposición incorrecta]

Sin [elemento faltante], un agente puede [comportamiento erróneo] honestamente pensando que [razonamiento].

---

## Solución propuesta

[Descripción del fix — simple o multi-capa]

```markdown
[Cambio específico]
```

¿Esta instrucción habría prevenido el problema? ¿Algo que añadir?

Tu turno, [Investigado].
```

---

#### Fase 4 — Evaluación (Investigado)

```markdown
## [Investigado] → [Investigador]

**¿Habría prevenido el problema? SÍ/PARCIALMENTE/NO, porque:**
[Evaluación razonada]

## Sugerencias adicionales

### 1. [Sugerencia]
[Ejemplo concreto]
**Ventaja:** [beneficio]

## Priorización
1. Tu solución (crítico) ← implementar inmediatamente
2. [Sugerencia X] ← [razón]

Tu turno, [Investigador].
```

---

#### Fase 5 — Implementación (Investigador)

```markdown
## [Investigador] → [Investigado]

## ✅ Fix implementado

**Archivos modificados:**
1. ✅ `[ruta/archivo]` — [descripción]

**Cambio implementado:**
[Código/texto nuevo]

## Decisiones sobre sugerencias
- **[Sugerencia 1]:** SÍ/NO implementada — [razón]

**Principio:** [Filosofía que guió las decisiones]

## Próximos pasos
1. [ISSUE-XXX]: marcado como completado
2. Fix incluido en próxima release

Tu turno, [Investigado].
```

---

#### Fase 6 — Cierre formal (Investigado)

```markdown
## [Investigado] → [Investigador]

## ✅ Conformidad con la implementación

- ✅ [Aspecto validado]
- ✅ [Razón conformidad]

## Impacto
- ✅ [Impacto en mi proyecto]
- ✅ [Mejora para el ecosistema]

**Aprendizaje clave:** [Lección específica]

**Reunión formalmente cerrada.**

CIERRE
```

---

### Elementos visuales

| Emoji | Uso |
|-------|-----|
| ✅ | Validado, correcto, logros |
| ❌ | Problema identificado |
| ⚠️ | Warning, riesgo |
| 💡 | Insight, lección |
| 📊 | Análisis, métricas |

Máximo 3-5 emojis por sección. Para categorización, no decoración.

---

**Versión:** 2.0
**Sistema:** memsys3
**Reemplaza:** meet-coord.md (v1.0) + meet-research.md
