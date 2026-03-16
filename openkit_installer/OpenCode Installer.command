#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DESKTOP_DIR="$HOME/Desktop"
LAUNCHER_SRC="$SCRIPT_DIR/OpenCode Launcher.command"
LAUNCHER_DST="$DESKTOP_DIR/OpenCode Launcher.command"
AUTH_FILE="$HOME/.local/share/opencode/auth.json"
CONFIG_DIR="$HOME/.config/opencode"
LOCAL_CONFIG_FILE="$CONFIG_DIR/opencode.ollama.json"
LANG_CONFIG_FILE="$CONFIG_DIR/opencode.lang.json"
LANG_INSTRUCTIONS_FILE="$CONFIG_DIR/instructions-language.md"
OLLAMA_MODEL="qwen2.5-coder:14b"
MODEL_SIZE_GB=9
BUFFER_GB=3

ORIGINAL_PATH="$PATH"
if [ "${OPENCODE_DEBUG_PATH:-}" = "1" ]; then
  echo "DEBUG: PATH original: $ORIGINAL_PATH"
fi

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

echo "========================================"
echo "OpenCode Installer - macOS"
echo "========================================"
echo "Este asistente instalara OpenCode via Homebrew"
echo "y guiara el login para dejarlo listo."
echo ""

BREW=""
if command -v brew >/dev/null 2>&1; then
  BREW="$(command -v brew)"
elif [ -x /opt/homebrew/bin/brew ]; then
  BREW="/opt/homebrew/bin/brew"
elif [ -x /usr/local/bin/brew ]; then
  BREW="/usr/local/bin/brew"
fi

if [ -z "$BREW" ]; then
  echo "Homebrew no encontrado."
  echo "Resumen:"
  echo "- Se instalara Homebrew en el sistema"
  echo "- Puede pedir contrasena de administrador"
  echo "- Puede instalar Xcode Command Line Tools"
  echo "- Necesita conexion a Internet"
  read -r -p "Continuar con la instalacion de Homebrew? [S/n] " INSTALL_BREW
  INSTALL_BREW="${INSTALL_BREW:-S}"
  if [ "$INSTALL_BREW" != "S" ] && [ "$INSTALL_BREW" != "s" ] && [ "$INSTALL_BREW" != "Y" ] && [ "$INSTALL_BREW" != "y" ]; then
    echo "Instalacion cancelada por el usuario."
    read -r -p "Pulsa Enter para cerrar... " _
    exit 0
  fi
  echo ""
  echo "Aviso de seguridad:"
  echo "- Se descargara y ejecutara un script de Homebrew desde Internet."
  echo "- Si no confias en la fuente, cancela ahora."
  read -r -p "Continuar con la descarga y ejecucion del script? [S/n] " CONFIRM_BREW_SCRIPT
  CONFIRM_BREW_SCRIPT="${CONFIRM_BREW_SCRIPT:-S}"
  if [ "$CONFIRM_BREW_SCRIPT" != "S" ] && [ "$CONFIRM_BREW_SCRIPT" != "s" ] && [ "$CONFIRM_BREW_SCRIPT" != "Y" ] && [ "$CONFIRM_BREW_SCRIPT" != "y" ]; then
    echo "Instalacion cancelada por el usuario."
    read -r -p "Pulsa Enter para cerrar... " _
    exit 0
  fi
  echo ""
  echo "Descargando instalador de Homebrew..."
  BREW_INSTALLER_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
  BREW_INSTALLER_TMP="$(mktemp -t opencode-brew-install.XXXXXX)"
  if [ ! -f "$BREW_INSTALLER_TMP" ]; then
    echo "ERROR: No se pudo crear un archivo temporal."
    read -r -p "Pulsa Enter para cerrar... " _
    exit 1
  fi
  if ! curl -fsSL "$BREW_INSTALLER_URL" -o "$BREW_INSTALLER_TMP"; then
    echo "ERROR: No se pudo descargar el instalador de Homebrew."
    rm -f "$BREW_INSTALLER_TMP"
    read -r -p "Pulsa Enter para cerrar... " _
    exit 1
  fi
  if [ ! -s "$BREW_INSTALLER_TMP" ]; then
    echo "ERROR: El instalador de Homebrew esta vacio."
    rm -f "$BREW_INSTALLER_TMP"
    read -r -p "Pulsa Enter para cerrar... " _
    exit 1
  fi
  echo "Instalando Homebrew..."
  echo "Puede pedir contrasena y/o instalar Xcode Command Line Tools."
  if ! /bin/bash "$BREW_INSTALLER_TMP"; then
    echo "ERROR: Fallo la instalacion de Homebrew."
    rm -f "$BREW_INSTALLER_TMP"
    read -r -p "Pulsa Enter para cerrar... " _
    exit 1
  fi
  rm -f "$BREW_INSTALLER_TMP"

  if command -v brew >/dev/null 2>&1; then
    BREW="$(command -v brew)"
  elif [ -x /opt/homebrew/bin/brew ]; then
    BREW="/opt/homebrew/bin/brew"
  elif [ -x /usr/local/bin/brew ]; then
    BREW="/usr/local/bin/brew"
  fi
fi

echo ""
echo "Ajustando PATH con Homebrew para esta sesion..."
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if [ -z "$BREW" ]; then
  echo "ERROR: Homebrew no se pudo instalar."
  read -r -p "Pulsa Enter para cerrar... " _
  exit 1
fi

echo ""
echo "Instalando OpenCode con Homebrew..."
if ! "$BREW" install anomalyco/tap/opencode; then
  echo "ERROR: Fallo la instalacion de OpenCode via Homebrew."
  read -r -p "Pulsa Enter para cerrar... " _
  exit 1
fi

OPENCODE=""
if command -v opencode >/dev/null 2>&1; then
  OPENCODE="$(command -v opencode)"
else
  BREW_PREFIX=""
  if [ -n "$BREW" ]; then
    BREW_PREFIX="$("$BREW" --prefix opencode 2>/dev/null)"
    if [ -z "$BREW_PREFIX" ]; then
      BREW_PREFIX="$("$BREW" --prefix 2>/dev/null)"
    fi
  fi
  if [ -n "$BREW_PREFIX" ] && [ -x "$BREW_PREFIX/bin/opencode" ]; then
    OPENCODE="$BREW_PREFIX/bin/opencode"
  fi
fi

if [ -z "$OPENCODE" ]; then
  echo "ERROR: OpenCode no encontrado despues de instalar."
  read -r -p "Pulsa Enter para cerrar... " _
  exit 1
fi

echo ""
echo "Version instalada de OpenCode:"
if "$OPENCODE" --version >/dev/null 2>&1; then
  "$OPENCODE" --version
else
  "$BREW" info anomalyco/tap/opencode
fi

LANGUAGE_CONFIGURED="false"
FORCE_LANGUAGE_SETUP="false"
if [ -f "$LANG_INSTRUCTIONS_FILE" ]; then
  echo ""
  read -r -p "Quieres revisar o cambiar el idioma ahora? [s/N] " CHANGE_LANG
  CHANGE_LANG="${CHANGE_LANG:-N}"
  if [ "$CHANGE_LANG" = "s" ] || [ "$CHANGE_LANG" = "S" ] || [ "$CHANGE_LANG" = "y" ] || [ "$CHANGE_LANG" = "Y" ]; then
    FORCE_LANGUAGE_SETUP="true"
  else
    LANGUAGE_CONFIGURED="true"
    echo "Idioma existente mantenido."
    if [ ! -f "$LANG_CONFIG_FILE" ]; then
      if ! mkdir -p "$CONFIG_DIR"; then
        echo "ERROR: No se pudo crear el directorio de config: $CONFIG_DIR"
        read -r -p "Pulsa Enter para cerrar... " _
        exit 1
      fi
      if ! cat > "$LANG_CONFIG_FILE" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": ["instructions-language.md"]
}
EOF
      then
        echo "ERROR: No se pudo escribir la config de idioma."
        read -r -p "Pulsa Enter para cerrar... " _
        exit 1
      fi
    fi
  fi
fi

if [ "$FORCE_LANGUAGE_SETUP" = "true" ] || [ "$LANGUAGE_CONFIGURED" != "true" ]; then
  echo ""
  echo "Seleccion de idioma para OpenCode"
  echo "1) Espanol (recomendado)"
  echo "2) English"
  echo "3) Catalan"
  echo "4) Otro"
  read -r -p "Elige una opcion [1-4] (por defecto 1): " LANG_OPT

  LANG_OPT="${LANG_OPT:-1}"
  LANGUAGE_LABEL="Espanol"

  case "$LANG_OPT" in
    1) LANGUAGE_LABEL="Espanol" ;;
    2) LANGUAGE_LABEL="English" ;;
    3) LANGUAGE_LABEL="Catalan" ;;
    4)
      read -r -p "Escribe el idioma preferido: " CUSTOM_LANG
      if [ -n "$CUSTOM_LANG" ]; then
        LANGUAGE_LABEL="$CUSTOM_LANG"
      fi
      ;;
    *) LANGUAGE_LABEL="Espanol" ;;
  esac

  if ! mkdir -p "$CONFIG_DIR"; then
    echo "ERROR: No se pudo crear el directorio de config: $CONFIG_DIR"
    read -r -p "Pulsa Enter para cerrar... " _
    exit 1
  fi
  if ! cat > "$LANG_INSTRUCTIONS_FILE" << EOF
Responde siempre en $LANGUAGE_LABEL.
EOF
  then
    echo "ERROR: No se pudo escribir instrucciones de idioma."
    read -r -p "Pulsa Enter para cerrar... " _
    exit 1
  fi

  if ! cat > "$LANG_CONFIG_FILE" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": ["instructions-language.md"]
}
EOF
  then
    echo "ERROR: No se pudo escribir la config de idioma."
    read -r -p "Pulsa Enter para cerrar... " _
    exit 1
  fi

  echo "Idioma configurado: $LANGUAGE_LABEL"
fi

HAS_AUTH="false"
AUTH_JSON_OK="false"
if [ -s "$AUTH_FILE" ] && [ -r "$AUTH_FILE" ]; then
  if command -v plutil >/dev/null 2>&1; then
    if plutil -lint "$AUTH_FILE" >/dev/null 2>&1; then
      AUTH_JSON_OK="true"
    fi
  elif command -v python3 >/dev/null 2>&1; then
    if python3 - "$AUTH_FILE" >/dev/null 2>&1 <<'PY'
import json
import sys

path = sys.argv[1]
try:
  with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)
  if isinstance(data, dict) and len(data) > 0:
    sys.exit(0)
except Exception:
  pass

sys.exit(1)
PY
    then
      AUTH_JSON_OK="true"
    fi
  fi
fi

if [ "$AUTH_JSON_OK" = "true" ]; then
  HAS_AUTH="true"
fi

if [ "$HAS_AUTH" = "false" ]; then
  echo ""
  echo "No se detectaron credenciales de proveedor."
  read -r -p "Quieres usar modo local con Ollama y el modelo recomendado ($OLLAMA_MODEL)? [S/n] " USE_OLLAMA
  USE_OLLAMA="${USE_OLLAMA:-S}"

  if [ "$USE_OLLAMA" = "S" ] || [ "$USE_OLLAMA" = "s" ] || [ "$USE_OLLAMA" = "Y" ] || [ "$USE_OLLAMA" = "y" ]; then
    if ! command -v ollama >/dev/null 2>&1; then
      echo ""
      echo "Instalando Ollama..."
      if ! "$BREW" install --cask ollama; then
        echo "ERROR: Fallo la instalacion de Ollama."
        read -r -p "Pulsa Enter para cerrar... " _
        exit 1
      fi
    fi

    if ! command -v ollama >/dev/null 2>&1; then
      echo "ERROR: Ollama no se pudo instalar."
      read -r -p "Pulsa Enter para cerrar... " _
      exit 1
    fi

    echo ""
    echo "Iniciando Ollama..."
    open -a Ollama >/dev/null 2>&1 || true
    sleep 2

    echo ""
    MODEL_REQUIRED_GB=$((MODEL_SIZE_GB + BUFFER_GB))
    REQUIRED_FREE_KB=$((MODEL_REQUIRED_GB * 1024 * 1024))
    OLLAMA_MODELS_DIR=""
    if [ -n "${OLLAMA_MODELS:-}" ]; then
      OLLAMA_MODELS_DIR="$OLLAMA_MODELS"
    elif [ -n "${OLLAMA_HOME:-}" ]; then
      OLLAMA_MODELS_DIR="$OLLAMA_HOME/models"
    else
      OLLAMA_MODELS_DIR="$HOME/.ollama/models"
    fi
    CHECK_PATH="$OLLAMA_MODELS_DIR"
    if [ ! -d "$CHECK_PATH" ]; then
      CHECK_PATH="$(dirname "$CHECK_PATH")"
    fi

    FREE_KB=""
    if df -k "$CHECK_PATH" >/dev/null 2>&1; then
      FREE_KB="$(df -k "$CHECK_PATH" | awk 'NR==2 {print $4}')"
    fi
    case "$FREE_KB" in
      ''|*[!0-9]*)
        echo ""
        echo "Aviso: no se pudo verificar el espacio libre en disco."
        read -r -p "Continuar con la descarga? [s/N] " CONTINUE_UNKNOWN_SPACE
        CONTINUE_UNKNOWN_SPACE="${CONTINUE_UNKNOWN_SPACE:-N}"
        if [ "$CONTINUE_UNKNOWN_SPACE" != "s" ] && [ "$CONTINUE_UNKNOWN_SPACE" != "S" ] && [ "$CONTINUE_UNKNOWN_SPACE" != "y" ] && [ "$CONTINUE_UNKNOWN_SPACE" != "Y" ]; then
          echo "Operacion cancelada por no poder verificar espacio."
          read -r -p "Pulsa Enter para cerrar... " _
          exit 1
        fi
        ;;
      *)
        if [ "$FREE_KB" -lt "$REQUIRED_FREE_KB" ]; then
          FREE_GB=$((FREE_KB / 1024 / 1024))
          echo ""
          echo "Aviso: poco espacio libre (~${FREE_GB} GB)."
          echo "Recomendado: al menos ${MODEL_REQUIRED_GB} GB libres para el modelo."
          read -r -p "Continuar con la descarga? [s/N] " CONTINUE_PULL
          CONTINUE_PULL="${CONTINUE_PULL:-N}"
          if [ "$CONTINUE_PULL" != "s" ] && [ "$CONTINUE_PULL" != "S" ] && [ "$CONTINUE_PULL" != "y" ] && [ "$CONTINUE_PULL" != "Y" ]; then
            echo "Operacion cancelada por poco espacio."
            read -r -p "Pulsa Enter para cerrar... " _
            exit 1
          fi
        fi
        ;;
    esac

    echo ""
    echo "Antes de descargar el modelo local:"
    echo "- Tamano del modelo: ~8-9 GB"
    echo "- Espacio total recomendado: ${MODEL_REQUIRED_GB} GB"
    echo "- Tiempo estimado: 10-40 min (segun tu conexion)"
    read -r -p "Quieres iniciar la descarga ahora? [S/n] " CONFIRM_PULL
    CONFIRM_PULL="${CONFIRM_PULL:-S}"
    if [ "$CONFIRM_PULL" != "S" ] && [ "$CONFIRM_PULL" != "s" ] && [ "$CONFIRM_PULL" != "Y" ] && [ "$CONFIRM_PULL" != "y" ]; then
      echo "Descarga cancelada por el usuario."
      read -r -p "Pulsa Enter para cerrar... " _
      exit 0
    fi

    echo ""
    echo "Descargando modelo local ($OLLAMA_MODEL). Esto puede tardar..."
    if ! ollama pull "$OLLAMA_MODEL"; then
      echo "ERROR: No se pudo descargar el modelo $OLLAMA_MODEL."
      read -r -p "Pulsa Enter para cerrar... " _
      exit 1
    fi

    echo ""
    echo "Configurando OpenCode para usar Ollama por defecto..."
    if ! mkdir -p "$CONFIG_DIR"; then
      echo "ERROR: No se pudo crear el directorio de config: $CONFIG_DIR"
      read -r -p "Pulsa Enter para cerrar... " _
      exit 1
    fi
    TARGET_CONFIG="$LOCAL_CONFIG_FILE"
    if [ ! -f "$CONFIG_DIR/opencode.json" ]; then
      TARGET_CONFIG="$CONFIG_DIR/opencode.json"
    fi
    echo ""
    echo "Resumen de cambios en config:"
    echo "Archivo destino: $TARGET_CONFIG"
    echo "Modo: local (Ollama)"
    echo "Modelo: $OLLAMA_MODEL"
    echo "Provider: Ollama (baseURL http://localhost:11434/v1)"
    echo "Instrucciones: instructions-language.md"
    WRITE_CONFIG="true"
    if [ -f "$TARGET_CONFIG" ]; then
      read -r -p "Ya existe la config $TARGET_CONFIG. Reemplazar? [s/N] " REPLACE_CONFIG
      REPLACE_CONFIG="${REPLACE_CONFIG:-N}"
      if [ "$REPLACE_CONFIG" = "s" ] || [ "$REPLACE_CONFIG" = "S" ] || [ "$REPLACE_CONFIG" = "y" ] || [ "$REPLACE_CONFIG" = "Y" ]; then
        BACKUP_TS="$(date +%Y%m%d-%H%M%S)"
        if ! cp -f "$TARGET_CONFIG" "${TARGET_CONFIG}.bak-$BACKUP_TS"; then
          echo "ERROR: No se pudo crear backup de la config."
          read -r -p "Pulsa Enter para cerrar... " _
          exit 1
        fi
      else
        WRITE_CONFIG="false"
      fi
    fi

    if [ "$WRITE_CONFIG" = "true" ]; then
      if ! cat > "$TARGET_CONFIG" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": ["instructions-language.md"],
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama (local)",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "qwen2.5-coder:14b": {
          "name": "Qwen2.5 Coder 14B (local)"
        }
      }
    }
  },
  "model": "ollama/qwen2.5-coder:14b",
  "small_model": "ollama/qwen2.5-coder:14b"
}
EOF
      then
        echo "ERROR: No se pudo escribir la config de OpenCode."
        read -r -p "Pulsa Enter para cerrar... " _
        exit 1
      fi
      echo "Config guardada en: $TARGET_CONFIG"
    else
      echo "Se mantiene la config existente."
    fi
  else
    echo ""
    echo "Quieres configurar proveedor remoto ahora?"
    echo "1) Si, iniciar login ahora"
    echo "2) No, omitir por ahora (puedo hacerlo luego)"
    echo "3) Ver instrucciones para hacerlo luego"
    read -r -p "Opcion [1-3] (por defecto 2): " SET_REMOTE_OPT
    SET_REMOTE_OPT="${SET_REMOTE_OPT:-2}"

    if [ "$SET_REMOTE_OPT" = "1" ]; then
      echo ""
      echo "Elige proveedor remoto:"
      echo "1) OpenCode Zen"
      echo "2) OpenAI"
      echo "3) Anthropic"
      echo "4) GitHub Copilot"
      echo "5) Otro"
      read -r -p "Opcion [1-5] (por defecto 1): " PROVIDER_OPT
      PROVIDER_OPT="${PROVIDER_OPT:-1}"

      case "$PROVIDER_OPT" in
        1) open "https://opencode.ai/auth" ;;
        2) open "https://platform.openai.com/api-keys" ;;
        3) open "https://console.anthropic.com/account/keys" ;;
        4) open "https://github.com/login/device" ;;
        5) ;;
        *) open "https://opencode.ai/auth" ;;
      esac

      echo ""
      echo "Cuando tengas las credenciales, vuelve aqui."
      read -r -p "Pulsa Enter para iniciar 'opencode auth login'... " _

      "$OPENCODE" auth login
    elif [ "$SET_REMOTE_OPT" = "3" ]; then
      echo ""
      echo "Instrucciones:"
      echo "- Ejecuta: opencode auth login"
      echo "- Luego revisa: opencode auth list"
    else
      echo ""
      echo "Login remoto omitido. Puedes hacerlo luego:"
      echo "- Ejecuta: opencode auth login"
      echo "- Luego revisa: opencode auth list"
    fi
  fi
fi

echo ""
echo "Verificando instalacion..."
"$OPENCODE" --version
if "$OPENCODE" auth list; then
  :
else
  echo "Aviso: no se pudo listar credenciales (opencode auth list fallo)."
  echo "Si vas a usar proveedor remoto, ejecuta: opencode auth login"
fi

echo ""
if [ -f "$LAUNCHER_SRC" ]; then
  SKIP_LAUNCHER_COPY="false"
  if [ -f "$LAUNCHER_DST" ]; then
    read -r -p "Ya existe el launcher en el Escritorio. Reemplazarlo? [s/N] " REPLACE_LAUNCHER
    REPLACE_LAUNCHER="${REPLACE_LAUNCHER:-N}"
    if [ "$REPLACE_LAUNCHER" != "s" ] && [ "$REPLACE_LAUNCHER" != "S" ] && [ "$REPLACE_LAUNCHER" != "y" ] && [ "$REPLACE_LAUNCHER" != "Y" ]; then
      echo "Se mantiene el launcher existente."
      SKIP_LAUNCHER_COPY="true"
    else
      BACKUP_TS="$(date +%Y%m%d-%H%M%S)"
      if ! cp -f "$LAUNCHER_DST" "${LAUNCHER_DST}.bak-$BACKUP_TS"; then
        echo "ERROR: No se pudo crear backup del launcher existente."
        SKIP_LAUNCHER_COPY="true"
      fi
    fi
  fi
  if [ "$SKIP_LAUNCHER_COPY" != "true" ]; then
    if ! cp -f "$LAUNCHER_SRC" "$LAUNCHER_DST"; then
      echo "ERROR: No se pudo copiar el launcher al Escritorio."
    elif ! chmod +x "$LAUNCHER_DST"; then
      echo "ERROR: No se pudo marcar ejecutable el launcher."
    else
      echo "Acceso directo creado en el Escritorio:"
      echo "  $LAUNCHER_DST"
    fi
  fi
else
  echo "Aviso: no se encontro el launcher en: $LAUNCHER_SRC"
fi

echo ""
echo "Listo. Puedes abrir el launcher para elegir carpeta y arrancar OpenCode."
NO_PAUSE_FILE="$CONFIG_DIR/installer-no-pause"
if [ -f "$NO_PAUSE_FILE" ]; then
  echo "Cerrando sin pausa (modo avanzado)."
  exit 0
fi

read -r -p "Pulsa Enter para cerrar (o escribe s para no mostrar esta pausa) ... " CLOSE_OPT
if [ "$CLOSE_OPT" = "s" ] || [ "$CLOSE_OPT" = "S" ] || [ "$CLOSE_OPT" = "y" ] || [ "$CLOSE_OPT" = "Y" ]; then
  mkdir -p "$CONFIG_DIR"
  touch "$NO_PAUSE_FILE"
  echo "OK, en futuras ejecuciones se cerrara sin pausa."
fi
