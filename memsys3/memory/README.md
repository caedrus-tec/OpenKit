# Memory System - Context Management per Agents

> **Sistema replicable para gestionar el contexto de los AI agents de forma eficiente**

Este sistema está diseñado para optimizar el consumo de tokens de los Development Agents (DevAI) proporcionándoles contexto compacto y relevante del proyecto.

## 🎯 Objetivo

Evitar que los agentes lean decenas de archivos de código para entender el proyecto. En lugar de eso, cargan un único archivo `context.yaml` (máximo 2000 líneas) con toda la información crítica.

## ⚡ Quick Start (Replicar en un nuevo proyecto)

```bash
# 1. Copia la estructura de memsys3/ a tu proyecto
cp -r memsys3/ /path/to/nuevo/proyecto/

# 2. Rellena el project-status.yaml inicial
# Usa memsys3/memory/templates/project-status-template.yaml como base

# 3. Comienza a documentar decisiones y sesiones
# Escribe en memsys3/memory/full/adr.yaml y memsys3/memory/full/sessions.yaml siguiendo los templates

# 4. Compila el contexto cuando sea necesario
# Ejecuta: @memsys3/prompts/compile-context.md

# 5. Visualiza la "mente" de los agentes
cd memsys3/viz
python serve.py
```

## 📁 Estructura

```
memsys3/
├── memory/
│   ├── context.yaml                    # ← DevAI carga esto (compilado)
│   ├── project-status.yaml             # ← Estado actual del proyecto
│   ├── README.md                       # ← Este archivo
│   │
│   ├── viz/                            # ← Visualizador web
│   │   ├── serve.py                    # Servidor mínimo
│   │   ├── index.html                  # Dashboard
│   │   ├── style.css                   # Estilos
│   │   ├── viewer.js                   # Renderizador
│   │   └── README.md                   # Instrucciones
│   │
│   ├── full/                           # ← Documentación completa (input CA)
│   │   ├── adr.yaml                    # Todas las ADRs históricas
│   │   └── sessions.yaml               # Todas las sesiones de trabajo
│   │
│   └── templates/                      # ← Templates reutilizables
│       ├── adr-template.yaml
│       ├── context-template.yaml
│       ├── project-status-template.yaml
│       └── sessions-template.yaml
│
├── agents/
│   └── context-agent.yaml              # Configuración formal del Context Agent
│
└── prompts/
    ├── compile-context.md              # Prompt para ejecutar Context Agent
    └── mind.md                         # Slash command /mind para visualizador
```

## 🔄 Workflow

### 1. Documentar (Humans/DevAI)

Escribe en estos archivos durante el desarrollo:

**`memsys3/memory/full/adr.yaml`** - Decisiones arquitectónicas importantes
- Cuándo: Has tomado una decisión no obvia que afecta el proyecto
- Formato: Usa `memsys3/memory/templates/adr-template.yaml`
- Ejemplo: "Por qué Astro vs React", "Por qué jsPDF vs html2canvas"

**`memsys3/memory/full/sessions.yaml`** - Sesiones de trabajo
- Cuándo: Al final de cada sesión significativa (>1h trabajo)
- Formato: Usa `memsys3/memory/templates/sessions-template.yaml`
- Incluye: features implementadas, problemas resueltos, decisiones, pendientes

**`memsys3/memory/project-status.yaml`** - Estado actual
- Cuándo: Cambia el estado global (nueva feature operativa, nuevo milestone)
- Formato: Ya está creado, solo actualízalo
- No lo hagas crecer demasiado, el CA lo lee entero

### 2. Compilar (Context Agent)

Cuando el contexto crece demasiado o después de sesiones importantes:

```bash
# Executa el Context Agent
@memsys3/prompts/compile-context.md

# O carrega la configuració formal
@memsys3/agents/context-agent.yaml
```

El CA hará:
- Leer **TODO**: `memsys3/memory/full/adr.yaml`, `memsys3/memory/full/sessions.yaml`, `memsys3/memory/project-status.yaml`
- Si > 150K tokens: archivar datos irrelevantes en `memsys3/memory/history/` (no leído)
- Filtrar con criterio inteligente (impacto global, relevancia)
- Generar `memsys3/memory/context.yaml` (máximo 2000 líneas)

### 3. Desarrollar (DevAI)

Los Development Agents solo deben:

```bash
# Cargar context
@memsys3/memory/context.yaml
```

Y ya tienen todo lo que necesitan para empezar a desarrollar.

## 📊 Filosofía del Context Agent

El CA tiene la **visión panorámica completa** del proyecto y decide con criterio inteligente:

**"¿Qué debe saber CUALQUIER agente descontextualizado para trabajar aquí?"**

### Límite ÚNICO
- **Máximo 2000 líneas** en el `context.yaml` final
- **NO límites arbitrarios** para ADRs, sesiones, gotchas, etc.
- El CA decide basándose en **relevancia e impacto global**

### Plan de Contingencia (>150K tokens)
Si los datos en `memsys3/memory/full/` superan 150K tokens:
1. CA identifica ADRs/sesiones **irrelevantes** con criterio
2. Las mueve a `memsys3/memory/history/` (que **NO se lee**)
3. Reduce a ~120K tokens
4. Continúa compilación normal

**Resultado:** Ahorro real de tokens, datos preservados, sistema escalable.

### Criterio de Selección

**Incluye:**
- ADRs con impacto global (afectan todo el proyecto)
- Sesiones recientes con cambios significativos
- Gotchas que rompen desarrollo
- Decisiones no obvias

**Excluye (y archiva si > 150K):**
- ADRs deprecated o demasiado específicas
- Sesiones >6 meses sin relevancia
- Cambios cosméticos
- Detalles visibles en el código

## 🚀 Cuándo Ejecutar el CA

**Ejecuta el Context Agent cuando:**
- ✅ Has completado una sesión grande (>2h trabajo)
- ✅ Has añadido 3+ ADRs nuevas
- ✅ `full/sessions.yaml` tiene >10 sesiones
- ✅ Notas que `context.yaml` está obsoleto

**NO hace falta ejecutarlo si:**
- ❌ Solo has cambiado una línea de código
- ❌ Fixes menores o typos
- ❌ `context.yaml` tiene menos de 1 semana

## 💡 Mejores Prácticas

### Para Documentar

**✅ Hacer:**
- Documenta decisiones no obvias
- Sé conciso pero completo
- Usa el formato de los templates
- Añade sesiones después de trabajo significativo
- Linkea ADRs desde sesiones si es necesario

**❌ Evitar:**
- Documentar cada pequeño cambio
- Duplicar información entre archivos
- Descripciones vagas ("mejorado sistema")
- Demasiado detalle técnico ("cambiado padding 10px→12px")

### Para Compilar

**✅ Hacer:**
- Ejecuta CA regularmente (semanalmente o después de sesiones grandes)
- Revisa que `context.yaml` tenga sentido
- Comprueba que no supera 2000 líneas
- Deja que el CA decida qué archivar (si >150K tokens)

**❌ Evitar:**
- Editar `context.yaml` manualmente (siempre vía CA)
- Ejecutar CA después de cada pequeño cambio
- Ignorar notas de compilación del CA
- Borrar `history/` (datos archivados)

## 🔧 Mantenimiento

### Rotación Automática (>1800 líneas)

Cuando `sessions.yaml` o `adr.yaml` superan 1800 líneas:
- **endSession.md** detecta automáticamente
- Hace rotación segura: `sessions.yaml` → `sessions_N.yaml`
- Crea nuevo archivo vacío para continuar
- **No se pierden datos**, quedan en `sessions_1.yaml`, `sessions_2.yaml`, etc.

**Context Agent lee todos los archivos** (`sessions.yaml` + `sessions_*.yaml`) hasta que total >150K tokens, entonces archiva irrelevantes en `history/`.

### Archivado Inteligente (>150K tokens)

Si el CA detecta >150K tokens totales:
- Mueve ADRs/sesiones irrelevantes a `memory/history/`
- `history/` **NO se lee** → ahorro real
- Datos preservados, recuperables si es necesario

### Periodicidad

- **Context Agent**: Ejecuta después de sesiones importantes
- **Rotación**: Automática cuando >1800 líneas
- **Archivado**: Automático del CA cuando >150K tokens
- **Revisión manual**: Opcional cada 6-12 meses para limpiar `history/`

## 📝 Ejemplos

### Ejemplo 1: Nueva Feature Grande

1. Desarrollas feature durante 3h
2. Al final, escribes en `memsys3/memory/full/sessions.yaml`:
   ```yaml
   sessions:
     - id: "2025-10-23"
       titol: "Sistema d'Exportació de Documents"
       features_implementades:
         - nom: "Exportació PDF"
           descripcio: "Text real amb Llibreria X, format professional..."
       decisions_preses:
         - decisio: "jsPDF vs html2canvas"
           justificacio: "Millor qualitat de text"
   ```
3. Si decidiste algo arquitectónico, añade ADR en `memsys3/memory/full/adr.yaml`
4. Ejecutas `@memsys3/prompts/compile-context.md`
5. `memsys3/memory/context.yaml` se actualiza con info nueva

### Ejemplo 2: DevAI Nuevo

1. Nuevo agente carga `@memsys3/memory/context.yaml`
2. En ~1500 tokens entiende:
   - Qué es el proyecto
   - Qué funciona y qué no
   - Decisiones clave tomadas
   - Última sesión (qué se tocó)
   - Gotchas a vigilar
3. Puede empezar a desarrollar inmediatamente

## 🆘 Troubleshooting

**P: context.yaml está obsoleto**
R: Ejecuta `@memsys3/prompts/compile-context.md`

**P: CA incluye demasiadas/pocas ADRs**
R: Ajusta límites y criterios en `memsys3/prompts/compile-context.md`

**P: DevAI dice que le falta contexto**
R: Quizás necesita código específico. El CA solo da visión general, no sustituye leer código cuando es necesario.

**P: memsys3/memory/full/sessions.yaml es inmenso**
R: Normal después de meses. El CA solo toma la última sesión para `memsys3/memory/context.yaml`. Si molesta, puedes archivar sesiones antiguas.

## 🎨 Visualizador Web

Interfaz visual para ver la "mente" de los agentes.

**Ejecutar:**
```bash
# Opción 1: Slash command
/mind

# Opción 2: Prompt directo
@memsys3/prompts/mind.md

# Opción 3: Manual
cd memsys3/viz
python serve.py
```

**Pestañas disponibles:**
- 🤖 **Agent View**: Lo que ve DevAI (contexto compilado)
- 📚 **Full History**: Todo el histórico de ADRs y sesiones
- 📊 **Project Status**: Estado completo del proyecto
- 📈 **Stats**: Métricas de compilación

**Uso:** Ideal para hacer revisiones visuales del contexto, detectar gaps, o presentar el estado del proyecto.

**Documentación completa:** Ver `memsys3/viz/README.md`

---

**Creado**: 2025-10-23
**Versión**: 1.0
**Mantenedores**: Sistema automatizado + humanos
