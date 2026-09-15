#!/usr/bin/env bash
# Instala resumeet para el usuario actual: binarios en ~/.local/bin,
# agentes por defecto en ~/.config/resumeet/agents (no pisa los existentes).
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
bin="$HOME/.local/bin"
agents="${XDG_CONFIG_HOME:-$HOME/.config}/resumeet/agents"

mkdir -p "$bin" "$agents"
install -m 755 "$here/bin/meet-rec" "$here/bin/meet-merge" "$bin/"
for f in "$here"/agents/*.md; do
  [[ -e "$agents/$(basename "$f")" ]] || cp "$f" "$agents/"
done

missing=()
for c in ffmpeg pactl python3 notify-send; do command -v "$c" >/dev/null || missing+=("$c"); done
command -v whisper-cli >/dev/null || command -v whisper-cpp >/dev/null || missing+=("whisper-cli (whisper-cpp)")
command -v claude >/dev/null || echo "aviso: falta 'claude'; define RESUMEET_LLM con otro comando LLM"
[[ ${#missing[@]} -eq 0 ]] || echo "faltan dependencias: ${missing[*]}"

echo "instalado en $bin/meet-rec"
echo "agentes en $agents"
echo "atajo sugerido (Hyprland): bind = SUPER SHIFT, R, exec, meet-rec"
echo "verifica: meet-rec --self-test"
