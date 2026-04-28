# IMPROVEMENT-008: Deploy agnóstico — configurar memoria antes del agente

**Estado:** Propuesto
**Prioridad:** Alta
**Tipo:** Arquitectura / Deploy
**Plazo:** Medio plazo
**Fecha identificación:** 2026-03-10
**Origen:** Propuesta de colaborador (discusión con moderador)

---

## Problema / Necesidad

### Situación actual

`deploy.md` asume Claude Code como agente. Pasos como "configura CLAUDE.md" o "usa newSession.md" están acoplados a un modelo específico. Si el usuario trabaja con Gemini, Codex, un LLM local, o el siguiente modelo que aparezca, el deploy no le sirve tal cual.

Además, actualmente memsys3 se despliega **después** de que el agente ya esté configurado, lo que genera:

- **Memoria dual**: `.claude/memory.md` (auto-memory del agente) compite con `memsys3/memory/` (contexto compilado)
- **CLAUDE.md incoherente**: se genera primero sin saber que memsys3 existe, luego hay que parchearlo
- **Dependencia de Messi**: memsys3 no debería depender de un modelo concreto para funcionar

### Propuesta

Invertir el orden: **primero desplegar memsys3, luego configurar el agente**.

1. `deploy.md` instala memsys3 y genera instrucciones agnósticas
2. El usuario configura su agente (Claude, Gemini, local, etc.) apuntando a memsys3
3. memsys3 provee templates para cada agente conocido (CLAUDE.md, .gemini/, system prompt genérico)
4. La memoria del agente nativo queda subordinada o desactivada

### Beneficios

- memsys3 manda en la memoria desde el día 1
- Sin duplicación de sistemas de memoria
- Agnóstico de modelo: funciona con cualquier LLM que lea Markdown/YAML
- El agente arranca ya sabiendo que memsys3 gestiona el contexto

---

## Puntos a deliberar

1. **¿Cómo interactúa con `/init` de Claude Code?** — ¿Claude Code respeta un CLAUDE.md preexistente o lo sobrescribe?
2. **Templates por agente** — ¿Qué necesita cada agente? CLAUDE.md, .gemini/, system prompt, etc.
3. **Auto-memory del agente** — ¿Desactivar? ¿Redirigir? ¿Dejar solo para cosas técnicas del agente?
4. **Backwards compatibility** — Proyectos existentes con memsys3 ya desplegado post-agente
5. **Scope del cambio** — ¿Solo deploy.md? ¿También newSession.md, endSession.md?
6. **Testing** — ¿Cómo verificar que funciona con múltiples agentes sin acceso a todos?

---

## Impacto

- `memsys3_templates/prompts/deploy.md` — reestructurar flujo completo
- `memsys3_templates/prompts/newSession.md` — posible generalización
- `memsys3_templates/prompts/endSession.md` — posible generalización
- `memsys3_templates/docs/reference.md` — documentar enfoque multi-agente
- Nuevo: templates de configuración por agente (CLAUDE.md template, etc.)
