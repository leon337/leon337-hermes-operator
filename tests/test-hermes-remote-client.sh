#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLIENT="$ROOT/scripts/hermes-remote-client.sh"
test -f "$CLIENT"
bash -n "$CLIENT"
grep -F 'SSH_CONFIG="/home/leo/.ssh/mcf-vps-control.conf"' "$CLIENT"
grep -F 'SSH_TARGET="mcf-vps-control"' "$CLIENT"
grep -F 'REMOTE_HERMES="/home/ubuntu/.local/bin/hermes"' "$CLIENT"
grep -F 'BatchMode=yes' "$CLIENT"
grep -F 'ConnectTimeout=8' "$CLIENT"
grep -F 'ClearAllForwardings=yes' "$CLIENT"
grep -F 'ControlMaster=no' "$CLIENT"
grep -F 'ControlPath=none' "$CLIENT"
test "$(grep -F -c '"${SSH_COMMON[@]}"' "$CLIENT")" -ge 2
! grep -Eq 'HERMES_REMOTE_SSH_(CONFIG|TARGET)|LocalForward|RemoteForward|DynamicForward|MCF-HERMES-PC-002|mcf-hermes-relay' "$CLIENT"
! grep -E '(BEGIN .*PRIVATE KEY|sk-[A-Za-z0-9]|token=|api[_-]?key=|password=)' "$CLIENT"
echo PASS
