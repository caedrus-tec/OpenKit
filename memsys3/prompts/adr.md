# Gestionar Architecture Decision Records (ADRs)

**Contexto:** Los ADRs (`memsys3/memory/full/adr.yaml`) documentan decisiones arquitectónicas del proyecto: qué decidimos, por qué, qué alternativas consideramos y qué impacto tiene.

**Tu tarea:**

## 1. Consultar ADRs

Si el usuario quiere ver el estado de las ADRs:
1. Lee `memsys3/memory/full/adr.yaml`
2. Lee `memsys3/memory/templates/adr-template.yaml` para entender la estructura
3. Muestra: ID, título, área, estado, fecha de cada ADR
4. Opcional: filtrar por área o estado si el usuario lo pide

## 2. Crear Nuevo ADR

Si el usuario quiere crear un ADR:
1. Lee `memsys3/memory/templates/adr-template.yaml` para entender la estructura completa
2. Verifica el último ID numérico usado en `adr.yaml`
3. Crea la nueva ADR con el siguiente ID secuencial
4. Incluye todas las secciones:
   - **id**: Número secuencial (001, 002, ...)
   - **titulo**: Descripción clara de la decisión
   - **data**: Fecha formato YYYY-MM-DD
   - **estado**: Estado actual (ver leyenda abajo)
   - **area**: Área afectada (ver leyenda abajo)
   - **context**: Contexto y problema que motivó la decisión
   - **decision**: Qué se decidió hacer
   - **alternatives**: Alternativas consideradas (nombre, pros, contras, por qué descartada)
   - **consequencies**: Consecuencias positivas, negativas e impacto
   - **notes**: Información adicional (opcional)
5. Añade al final de `adr.yaml` (NO borres ADRs antiguas)
6. Actualiza el índice al final del archivo

## 3. Actualizar ADR Existente

Si el usuario quiere actualizar un ADR:
1. Lee `memsys3/memory/full/adr.yaml`
2. Localiza la ADR por ID
3. Actualiza el campo correspondiente:
   - **estado**: Si cambió de accepted → deprecated/superseded_by
   - **notes**: Agregar información adicional
   - **consequencies**: Actualizar impacto real tras implementación
4. NO cambies: id, titulo, data, context, decision, alternatives (son históricos)
5. Si una decisión fue sustituida, usa `superseded_by: "XXX"` apuntando al nuevo ADR

---

## Leyenda de Estados

- **accepted**: Decisión aceptada y activa
- **deprecated**: Decisión obsoleta, ya no se aplica
- **superseded_by**: Decisión sustituida por otra ADR (especificar ID)

## Leyenda de Áreas

**Técnicas:**
- **arquitectura**: Decisiones de diseño arquitectónico del sistema
- **frontend**: Decisiones sobre tecnología/patrones frontend
- **backend**: Decisiones sobre tecnología/patrones backend
- **infrastructure**: Decisiones sobre despliegue, hosting, CI/CD
- **escalabilidad**: Decisiones sobre cómo escalar el sistema
- **format**: Decisiones sobre formatos de datos (YAML, JSON, etc.)

**Proceso:**
- **workflow**: Decisiones sobre flujo de trabajo del equipo
- **documentación**: Decisiones sobre cómo documentar el proyecto
- **usabilidad**: Decisiones sobre experiencia de usuario/desarrollador
- **process**: Decisiones sobre procesos de desarrollo

Ver `memsys3/memory/templates/adr-template.yaml` para estructura completa y ejemplos.
