#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEPLOY="$ROOT/scripts/deploy-notebook-client.sh"
TEMPLATE="$ROOT/packaging/linux/hermes-agent-remote.desktop"
test -f "$DEPLOY"
test -f "$TEMPLATE"
bash -n "$DEPLOY"
FAKE_HOME="$(mktemp -d)"
trap 'rm -rf "$FAKE_HOME"' EXIT
FAKE_DESKTOP="$FAKE_HOME/Desktop"
HOME="$FAKE_HOME" DESKTOP_DIR="$FAKE_DESKTOP" bash "$DEPLOY"
CLIENT="$FAKE_HOME/.local/bin/hermes-remote-client"
DESKTOP="$FAKE_DESKTOP/Hermes Agent.desktop"
test -x "$CLIENT"
test -f "$DESKTOP"
grep -Fx 'Name=Hermes Agent' "$DESKTOP"
grep -Fx 'Terminal=true' "$DESKTOP"
grep -Fx "Exec=$CLIENT" "$DESKTOP"
test ! -e "$FAKE_HOME/.ssh"
test ! -e "$FAKE_HOME/leon337-hermes-operator/.git"
! find "$FAKE_HOME" -type d -name .git -print -quit | grep -q .
echo PASS
