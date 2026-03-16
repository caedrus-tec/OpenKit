#!/bin/bash

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

LOCAL_CONFIG_FILE="$HOME/.config/opencode/opencode.ollama.json"
LANG_CONFIG_FILE="$HOME/.config/opencode/opencode.lang.json"
GLOBAL_CONFIG_FILE="$HOME/.config/opencode/opencode.json"

if [ -f "$LOCAL_CONFIG_FILE" ]; then
  export OPENCODE_CONFIG="$LOCAL_CONFIG_FILE"
elif [ -f "$LANG_CONFIG_FILE" ]; then
  export OPENCODE_CONFIG="$LANG_CONFIG_FILE"
elif [ -f "$GLOBAL_CONFIG_FILE" ]; then
  export OPENCODE_CONFIG="$GLOBAL_CONFIG_FILE"
fi

if [ -f "$LOCAL_CONFIG_FILE" ]; then
  if ! open -a Ollama >/dev/null 2>&1; then
    echo "Aviso: no se pudo abrir Ollama. Si usas modo local, inicia Ollama manualmente."
  fi
elif [ -f "$GLOBAL_CONFIG_FILE" ]; then
  if [ -r "$GLOBAL_CONFIG_FILE" ]; then
    if grep -q '"ollama"' "$GLOBAL_CONFIG_FILE"; then
      if ! open -a Ollama >/dev/null 2>&1; then
        echo "Aviso: no se pudo abrir Ollama. Si usas modo local, inicia Ollama manualmente."
      fi
    fi
  else
    echo "Aviso: no se pudo leer la config global para detectar Ollama."
  fi
fi

OSASCRIPT_OUT="$(osascript -e 'POSIX path of (choose folder with prompt "Selecciona tu carpeta de trabajo")' 2>&1)"
OSASCRIPT_STATUS=$?
if [ "$OSASCRIPT_STATUS" -ne 0 ]; then
  case "$OSASCRIPT_OUT" in
    *"User canceled"*|*"(-128)"*)
      echo "Cancelado."
      exit 0
      ;;
    *)
      echo "ERROR: No se pudo abrir el selector de carpetas."
      echo "Revisa permisos de Automatizacion/AppleScript."
      read -r -p "Pulsa Enter para cerrar... " _
      exit 1
      ;;
  esac
fi

FOLDER_PATH="$OSASCRIPT_OUT"
if [ -z "$FOLDER_PATH" ]; then
  echo "ERROR: No se selecciono ninguna carpeta."
  read -r -p "Pulsa Enter para cerrar... " _
  exit 1
fi

if [ ! -d "$FOLDER_PATH" ]; then
  echo "ERROR: La carpeta no existe o no es accesible."
  read -r -p "Pulsa Enter para cerrar... " _
  exit 1
fi

if [ ! -r "$FOLDER_PATH" ] || [ ! -x "$FOLDER_PATH" ]; then
  echo "ERROR: No tienes permisos para acceder a la carpeta."
  read -r -p "Pulsa Enter para cerrar... " _
  exit 1
fi

if ! open "$FOLDER_PATH" >/dev/null 2>&1; then
  echo "Aviso: no se pudo abrir la carpeta en Finder."
fi

OPENCODE=""
if command -v opencode >/dev/null 2>&1; then
  OPENCODE="$(command -v opencode)"
elif [ -x /opt/homebrew/bin/opencode ]; then
  OPENCODE="/opt/homebrew/bin/opencode"
elif [ -x /usr/local/bin/opencode ]; then
  OPENCODE="/usr/local/bin/opencode"
fi

if [ -z "$OPENCODE" ]; then
  echo "OpenCode no esta instalado. Ejecuta primero OpenCode Installer." 
  read -r -p "Pulsa Enter para cerrar... " _
  exit 1
fi

if ! cd "$FOLDER_PATH"; then
  echo "ERROR: No se pudo entrar en la carpeta seleccionada."
  read -r -p "Pulsa Enter para cerrar... " _
  exit 1
fi
"$OPENCODE"
