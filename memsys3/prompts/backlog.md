# Gestionar Backlog del Proyecto

**Contexto:** El backlog (`memsys3/backlog/`) organiza trabajo futuro del proyecto (issues, features, specs, blueprints, mejoras, exploraciones).

## 0. Verificar que existe el backlog

```bash
ls memsys3/backlog/README.md 2>/dev/null && echo "OK" || echo "NO EXISTE"
```

Si no existe, créalo antes de continuar:

```bash
mkdir -p memsys3/backlog
```

Luego crea `memsys3/backlog/README.md` copiando el contenido de `memsys3_update_temp/memsys3_templates/backlog/README.md` si está disponible, o bien crea uno mínimo con esta estructura:

```markdown
# Backlog del Proyecto

## Códigos
- **ISSUE-XXX**: Problemas técnicos, bugs, tech debt
- **FEATURE-XXX**: Nueva funcionalidad
- **IMPROVEMENT-XXX**: Mejora de funcionalidad existente
- **SPEC-XXX**: Especificación técnica detallada
- **BLUEPRINT-XXX**: Diseño arquitectónico alto nivel
- **EXPLORATION-XXX**: Investigación sin solución clara

## Estados
Propuesto → Abierto → En Progreso → Completado / Cancelado / Rechazado / Bloqueado
```

**Tu tarea:**

## 1. Consultar Backlog
Si el usuario quiere ver el estado del backlog:
1. Lee `memsys3/backlog/README.md` para entender el sistema
2. Lista los ítems actuales en `memsys3/backlog/` (excluye README.md)
3. Muestra: prefijo, título, estado, prioridad de cada ítem

## 2. Crear Nuevo Item
Si el usuario quiere crear un item:
1. Pregunta qué tipo de item quiere crear (usa la leyenda abajo)
2. Lee `memsys3/backlog/README.md` para entender estructura de documentos
3. Verifica numeración existente del prefijo elegido
4. Crea el archivo `memsys3/backlog/[PREFIJO]-[NUMERO]-[nombre].md` con estructura correcta
5. Incluye: Estado, Prioridad, Tipo, Plazo, Fecha, Problema/Propuesta, Referencias

## 3. Actualizar Item Existente
Si el usuario quiere actualizar un item:
1. Lee el archivo del item
2. Actualiza el campo correspondiente (Estado, Prioridad, etc.)
3. Agrega información en la sección apropiada

---

## Leyenda de Códigos

- **ISSUE-XXX**: Problemas técnicos, bugs, tech debt
- **FEATURE-XXX**: Nueva funcionalidad a implementar
- **SPEC-XXX**: Especificaciones técnicas detalladas
- **BLUEPRINT-XXX**: Diseño arquitectónico de alto nivel
- **IMPROVEMENT-XXX**: Mejoras de funcionalidad existente
- **EXPLORATION-XXX**: Investigación sin solución clara

Ver `memsys3/backlog/README.md` para workflow completo y estructura de documentos.
