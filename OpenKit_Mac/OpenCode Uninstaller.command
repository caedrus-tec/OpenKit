#!/bin/bash

# OpenCode Uninstaller - macOS
# Reverte la instalacion de OpenCode, Ollama y el modelo.
# Mantiene Homebrew intacto.

DESKTOP_LAUNCHER="$HOME/Desktop/OpenCode Launcher.command"
CONFIG_DIR="$HOME/.config/opencode"
AUTH_FILE="$HOME/.local/share/opencode/auth.json"
OLLAMA_MODEL="qwen2.5-coder:14b"

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

echo "========================================"
echo "OpenCode Uninstaller - macOS"
echo "========================================"
echo "Este script eliminara:"
echo "- OpenCode CLI"
echo "- Ollama"
echo "- Modelo local ($OLLAMA_MODEL)"
echo "- Configuracion de OpenCode"
echo "- Archivos de autenticacion"
echo ""
echo "Homebrew se mantendra intacto."
echo ""

read -r -p "Continuar con la desinstalacion? [S/n] " CONFIRM
CONFIRM="${CONFIRM:-S}"
if [ "$CONFIRM" != "S" ] && [ "$CONFIRM" != "s" ] && [ "$CONFIRM" != "Y" ] && [ "$CONFIRM" != "y" ]; then
  echo "Desinstalacion cancelada."
  read -r -p "Pulsa Enter para cerrar... " _
  exit 0
fi

echo ""
echo "1) Desinstalando OpenCode..."
if command -v brew >/dev/null 2>&1; then
  if brew list opencode >/dev/null 2>&1; then
    brew uninstall opencode && echo "   OpenCode eliminado." || echo "   Warning: no se pudo eliminar OpenCode."
  else
    echo "   OpenCode no esta instalado via Homebrew."
  fi
else
  echo "   Warning: Homebrew no encontrado."
fi

echo ""
echo "2) Desinstalando Ollama..."
if command -v brew >/dev/null 2>&1; then
  if brew list --cask ollama >/dev/null 2>&1; then
    brew uninstall --cask ollama && echo "   Ollama eliminado." || echo "   Warning: no se pudo eliminar Ollama."
  else
    echo "   Ollama no esta instalado via Homebrew."
  fi
else
  echo "   Warning: Homebrew no encontrado."
fi

echo ""
echo "3) Eliminando modelo local..."
if command -v ollama >/dev/null 2>&1; then
  if ollama list 2>/dev/null | grep -q "$OLLAMA_MODEL"; then
    ollama rm "$OLLAMA_MODEL" && echo "   Modelo $OLLAMA_MODEL eliminado." || echo "   Warning: no se pudo eliminar el modelo."
  else
    echo "   Modelo $OLLAMA_MODEL no encontrado."
  fi
else
  if [ -d "$HOME/.ollama" ]; then
    echo "   Eliminando directorio .ollama completo..."
    rm -rf "$HOME/.ollama" && echo "   Directorio .ollama eliminado." || echo "   Warning: no se pudo eliminar .ollama."
  else
    echo "   Ollama no esta instalado."
  fi
fi

echo ""
echo "4) Eliminando configuraciones..."
if [ -d "$CONFIG_DIR" ]; then
  CONFIG_FILES=$(ls -1 "$CONFIG_DIR" 2>/dev/null | wc -l)
  if [ "$CONFIG_FILES" -gt 0 ]; then
    echo "   Archivos en $CONFIG_DIR:"
    ls -1 "$CONFIG_DIR" | sed 's/^/     - /'
    read -r -p "   Eliminar directorio completo? [s/N] " DELETE_CONFIG
    DELETE_CONFIG="${DELETE_CONFIG:-N}"
    if [ "$DELETE_CONFIG" = "s" ] || [ "$DELETE_CONFIG" = "S" ] || [ "$DELETE_CONFIG" = "y" ] || [ "$DELETE_CONFIG" = "Y" ]; then
      rm -rf "$CONFIG_DIR" && echo "   Configuracion eliminada." || echo "   Warning: no se pudo eliminar config."
    else
      echo "   Configuracion mantenida."
    fi
  else
    echo "   No hay archivos de configuracion."
  fi
else
  echo "   Directorio de config no existe."
fi

echo ""
echo "5) Eliminando archivos de autenticacion..."
if [ -s "$AUTH_FILE" ]; then
  read -r -p "   Eliminar $AUTH_FILE? [s/N] " DELETE_AUTH
  DELETE_AUTH="${DELETE_AUTH:-N}"
  if [ "$DELETE_AUTH" = "s" ] || [ "$DELETE_AUTH" = "S" ] || [ "$DELETE_AUTH" = "y" ] || [ "$DELETE_AUTH" = "Y" ]; then
    rm -f "$AUTH_FILE" && echo "   Auth eliminado." || echo "   Warning: no se pudo eliminar auth."
  else
    echo "   Auth mantenido."
  fi
else
  echo "   Archivo de auth no existe."
fi

echo ""
echo "6) Eliminando launcher del Escritorio..."
if [ -f "$DESKTOP_LAUNCHER" ]; then
  rm -f "$DESKTOP_LAUNCHER" && echo "   Launcher eliminado." || echo "   Warning: no se pudo eliminar launcher."
else
  echo "   Launcher no existe."
fi

echo ""
echo "========================================"
echo "Desinstalacion completada."
echo "========================================"

read -r -p "Pulsa Enter para cerrar... " _
exit 0