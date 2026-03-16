# Memory Visualizer

Interfaz web para visualizar la "mente" de los agentes - el contexto, ADRs, sesiones y status del proyecto.

## 🚀 Uso Rápido

```bash
# Desde la raíz del proyecto:
cd memsys3/viz
python3 serve.py

# O si ya estás en memsys3/:
cd viz
python3 serve.py
```

Se abrirá automáticamente en el navegador en `http://localhost:8080`

## 📊 ¿Qué muestra?

### 🤖 Agent View
El contexto compilado que cargan los Development Agents:
- Project info
- Features operativas
- ADRs relevantes (filtradas por el CA)
- Última sesión resumida
- Gotchas críticos
- Pendientes prioritarios

### 📚 Full History
Todo el histórico completo:
- Todas las ADRs escritas
- Todas las sesiones de trabajo

### 📊 Project Status
Estado actual completo del proyecto con features, stack, URLs, etc.

### 📈 Stats
Estadísticas de compilación:
- Cuántos tokens tiene el contexto
- Cuántas ADRs se han filtrado
- Última compilación
- Notas del Context Agent

## 🛠 Requisitos

- Python 3.x (viene preinstalado en la mayoría de sistemas)

## 🔧 Troubleshooting

**¿Port 8080 ocupado?**
Edita `serve.py` y cambia `PORT = 8080` a otro puerto.

**¿Error "No module named..."?**
El servidor usa solo librerías estándar de Python, no hace falta instalar nada.

**¿Pestañas vacías?**
- Asegúrate de que existen los archivos YAMLs/MD en `memory/`
- Comprueba la consola del navegador por errores

**¿"context.yaml not found"?**
Normal si aún no has ejecutado el Context Agent. Ejecuta `@memsys3/prompts/compile-context.md` primero.

## 📁 Archivos

- `serve.py` - Servidor HTTP mínimo
- `index.html` - Dashboard con pestañas
- `style.css` - Dark theme moderno
- `viewer.js` - Carga y renderiza YAMLs
- `README.md` - Este archivo

## 🎨 Personalización

Puedes modificar:
- **Colores**: Edita las variables CSS en `style.css`
- **Puerto**: Cambia `PORT` en `serve.py`
- **Layout**: Modifica `index.html` y `viewer.js`

## 📝 Notas

- El visualizador lee los YAMLs **directamente** vía fetch()
- **No modifica** ningún archivo, solo lectura
- Se refresca automáticamente al recargar la página
- Simple YAML parser integrado (no hace falta dependencias)
