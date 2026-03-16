# Mind - Visualiza la Memoria de los Agents

Ejecuta el Memory Visualizer para ver la "mente" de los agentes de forma visual.

## Tarea

1. Navega al directorio del visualizador
2. Ejecuta el servidor Python
3. El navegador se abrirá automáticamente mostrando el dashboard

## Instrucciones

Ejecuta el siguiente comando:

```bash
cd memsys3/viz && python3 serve.py
```

**Importante:**
- El servidor quedará en ejecución (background)
- Se abrirá automáticamente http://localhost:8080
- Muestra mensaje al usuario confirmando que el visualizador está abierto
- Para detenerlo, el usuario puede hacer Ctrl+C en el terminal

## Qué verá el usuario

El dashboard con 4 pestañas:
- 🤖 **Agent View**: Contexto compilado que ve DevAI
- 📚 **Full History**: Todo el histórico de ADRs y sesiones
- 📊 **Project Status**: Estado completo del proyecto
- 📈 **Stats**: Métricas de compilación y tokens

## Notas

- Si el puerto 8080 está ocupado, el servidor fallará
- Si `context.yaml` no existe, Agent View mostrará error (normal si CA aún no se ha ejecutado)
- El visualizador lee los YAMLs en tiempo real, refresca la página para actualizar
