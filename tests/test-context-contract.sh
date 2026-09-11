#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CAPSULE="$ROOT/.mcf/project-capsule.yaml"
CURRENT="$ROOT/docs/current-state.md"
test -f "$CAPSULE"
test -f "$CURRENT"
grep -Fx 'project_id: leon337-hermes-operator' "$CAPSULE"
grep -Fx '  current_workstream: remote-client-v1-context-fabric' "$CAPSULE"
grep -Fx '  current_state: docs/current-state.md' "$CAPSULE"
! grep -Eq '(^|[[:space:]])(provider|health|authentication_state|session_health):' "$CAPSULE"
grep -F 'LIVE_REQUIRED' "$CURRENT"
echo PASS
