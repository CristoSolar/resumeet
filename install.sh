#!/usr/bin/env bash
# Installs resumeet for the current user: binaries in ~/.local/bin, default
# agents in ~/.config/resumeet/agents (existing ones are never overwritten).
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
bin="$HOME/.local/bin"
agents="${XDG_CONFIG_HOME:-$HOME/.config}/resumeet/agents"

mkdir -p "$bin" "$agents"
install -m 755 "$here/bin/meet-rec" "$here/bin/meet-merge" "$here/bin/meet-view" "$here/bin/resumeet" "$bin/"
for f in "$here"/agents/*.md; do
  [[ -e "$agents/$(basename "$f")" ]] || cp "$f" "$agents/"
done

missing=()
for c in ffmpeg pactl python3 notify-send; do command -v "$c" >/dev/null || missing+=("$c"); done
command -v whisper-cli >/dev/null || command -v whisper-cpp >/dev/null || missing+=("whisper-cli (whisper-cpp)")
command -v claude >/dev/null || echo "note: 'claude' not found; set RESUMEET_LLM to another LLM command"
[[ ${#missing[@]} -eq 0 ]] || echo "missing dependencies: ${missing[*]}"

echo "installed: $bin/{meet-rec,meet-merge,meet-view,resumeet}"
echo "agents in $agents"
echo "suggested shortcut (Hyprland): bind = SUPER SHIFT, R, exec, meet-rec"
echo "check it works: meet-rec --self-test"
