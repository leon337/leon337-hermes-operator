#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_CLIENT="$ROOT/scripts/hermes-remote-client.sh"
DESKTOP_TEMPLATE="$ROOT/packaging/linux/hermes-agent-remote.desktop"
TARGET_CLIENT="$HOME/.local/bin/hermes-remote-client"

if [[ -n "${DESKTOP_DIR:-}" ]]; then
  resolved_desktop="$DESKTOP_DIR"
elif command -v xdg-user-dir >/dev/null 2>&1; then
  resolved_desktop="$(xdg-user-dir DESKTOP 2>/dev/null || true)"
  if [[ -z "$resolved_desktop" ]]; then
    resolved_desktop="/home/leo/Área de trabalho"
  fi
else
  resolved_desktop="/home/leo/Área de trabalho"
fi

TARGET_DESKTOP="$resolved_desktop/Hermes Agent.desktop"

[[ -f "$SOURCE_CLIENT" ]] || { printf 'Hermes deploy — launcher source missing.\n' >&2; exit 2; }
[[ -f "$DESKTOP_TEMPLATE" ]] || { printf 'Hermes deploy — desktop template missing.\n' >&2; exit 3; }

install -d -m 0755 "$(dirname "$TARGET_CLIENT")" "$resolved_desktop"
install -m 0755 "$SOURCE_CLIENT" "$TARGET_CLIENT"

tmp_desktop="$(mktemp)"
trap 'rm -f "$tmp_desktop"' EXIT
awk -v exec_path="$TARGET_CLIENT" '
  /^Exec=/ { print "Exec=" exec_path; next }
  { print }
' "$DESKTOP_TEMPLATE" > "$tmp_desktop"
install -m 0755 "$tmp_desktop" "$TARGET_DESKTOP"

printf 'Hermes Agent client deployed:\n  %s\n  %s\n' "$TARGET_CLIENT" "$TARGET_DESKTOP"
