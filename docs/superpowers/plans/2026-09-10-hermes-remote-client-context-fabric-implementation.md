# Hermes Remote Client + MCF Context Fabric Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expose the single canonical Hermes runtime on the VPS through a one-click notebook client, then register Hermes Operator as a durable project in the MCF Context Fabric.

**Architecture:** The notebook stays a thin client. A repository-owned Bash launcher uses the existing canonical SSH profile and starts `/home/ubuntu/.local/bin/hermes chat` on the VPS with an interactive TTY. Hermes, provider selection, sessions, tools, memory, Qwen, and runtime state remain on the VPS. The Hermes Operator repository owns the launcher, desktop template, capsule, and durable current-state document. The MCF repository owns the Context Fabric registry entry and resolver/schema tests.

**Tech Stack:** Bash, freedesktop `.desktop`, OpenSSH, Git/GitHub, YAML, MCF Context Fabric schemas, Node 24, pnpm 11, TypeScript/Vitest.

**Spec:** `docs/superpowers/specs/2026-09-10-hermes-remote-client-context-fabric-design.md`

## Global Constraints

- Exactly one canonical Hermes runtime: the VPS instance under `/home/ubuntu/.hermes/hermes-agent`.
- Do not install Hermes, Qwen, provider configuration, session state, model state, or Hermes secrets on the notebook.
- Remote Client V1 uses SSH only.
- Use notebook SSH config `/home/leo/.ssh/mcf-vps-control.conf` and host alias `mcf-vps-control`.
- Remote command is `/home/ubuntu/.local/bin/hermes chat`; do not call the legacy `MCF-HERMES-PC-002` controller or relay.
- Do not expose Qwen `:8080`, controller sockets, HTTP, VNC, WebSocket, or new public/Tailscale ports.
- Closing the client must not stop Hermes services, Qwen, TriView, DSHs, 9Router, SentinelX, Docker, Tailscale, GitHub Runner, or the VPS graphical workstation.
- GitHub is canonical; the notebook receives only deployed launcher artifacts, not a project checkout.
- Context Fabric project id is `leon337-hermes-operator`; aliases are `Hermes Operator`, `Hermes Agent`, and `Hermes`.
- Context Fabric operational freshness is `LIVE_REQUIRED`; Git state must never be treated as current runtime health.
- Do not merge the MCF registry entry before the referenced Hermes capsule/current-state/entrypoints exist on the Hermes canonical branch.

---

### Task 1: Add Hermes durable current state and project capsule

**Files:**
- Create: `docs/current-state.md`
- Create: `.mcf/project-capsule.yaml`
- Create: `tests/test_context_contract.sh`

**Interfaces:**
- Produces durable project identity/state consumed by the MCF registry.
- Consumes the MCF capsule schema `schemas/context/project-capsule.schema.json` for cross-repository validation.

- [ ] **Step 1: Write the failing contract test**

Create `tests/test_context_contract.sh`:

```bash
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
grep -F 'VPS' "$CURRENT"
grep -F 'LIVE_REQUIRED' "$CURRENT"
echo PASS
```

- [ ] **Step 2: Run and confirm RED**

```bash
bash tests/test_context_contract.sh
```

Expected: FAIL because the capsule/current-state files do not exist.

- [ ] **Step 3: Create `docs/current-state.md`**

```markdown
# Hermes Operator — Current State

Project ID: `leon337-hermes-operator`
Canonical repository: `leon337/leon337-hermes-operator`
Human authority: `LEANDRO`

## Current workstream

Remote Client V1 + MCF Context Fabric registration.

## Deployment boundary

The canonical Hermes Agent runtime is hosted on the VPS. The notebook is a human client only and reaches the runtime through the canonical SSH control path.

## V1 boundary

Remote Client V1 opens `hermes chat` on the VPS. It does not install another Hermes runtime on the notebook, does not start `MCF-HERMES-PC-002`, and does not expose Qwen or Hermes through a new network service.

## Operational truth

Current provider, model availability, process health, session health, authentication state, and VPS health are `LIVE_REQUIRED`. Repository context is not proof of current runtime state.
```

- [ ] **Step 4: Create the capsule with a real timestamp**

Run:

```bash
OBSERVED_AT="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
mkdir -p .mcf
cat >.mcf/project-capsule.yaml <<EOF
schema_version: 1
project_id: leon337-hermes-operator
purpose: Govern and extend the official Nous Research Hermes Agent as an MCF-controlled autonomous operator while keeping LEANDRO as final human authority.
lifecycle: ACTIVE
snapshot:
  current_workstream: remote-client-v1-context-fabric
  current_status: DESIGN_APPROVED_IMPLEMENTATION_IN_PROGRESS
  next_action: Implement and verify the SSH Remote Client V1, then register the project in the MCF Context Fabric.
  blockers: []
sources:
  current_state: docs/current-state.md
observed_at: "$OBSERVED_AT"
EOF
```

- [ ] **Step 5: Run local contract test**

```bash
chmod +x tests/test_context_contract.sh
bash tests/test_context_contract.sh
```

Expected: `PASS`.

- [ ] **Step 6: Validate the capsule with the actual MCF validator**

Copy the candidate capsule to `/tmp/hermes-project-capsule.yaml`, then from the current MCF checkout run:

```bash
cd apps/rede-social-agentes
pnpm --filter @rsa/server build
HERMES_CAPSULE=/tmp/hermes-project-capsule.yaml node --input-type=module -e '
import { readFileSync } from "node:fs";
import { parse } from "yaml";
import { ContextSchemaValidator } from "./apps/server/dist/mcf-context/context-schema.validator.js";
const validator = new ContextSchemaValidator("../../schemas/context/project-capsule.schema.json");
const result = validator.validate(parse(readFileSync(process.env.HERMES_CAPSULE, "utf8")));
console.log(JSON.stringify(result));
if (!result.valid) process.exit(1);
'
```

Expected: `{"valid":true,"errors":[]}`.

- [ ] **Step 7: Commit**

```bash
git add .mcf/project-capsule.yaml docs/current-state.md tests/test_context_contract.sh
git commit -m "context: add Hermes Operator project capsule"
```

---

### Task 2: Implement the repository-owned SSH remote client

**Files:**
- Create: `client/hermes-remote`
- Create: `tests/test_hermes_remote.sh`

**Interfaces:**
- Produces `client/hermes-remote`, deployed to notebook as `/home/leo/.local/bin/hermes-remote`.
- Consumes `$HOME/.ssh/mcf-vps-control.conf`, alias `mcf-vps-control`, and remote `/home/ubuntu/.local/bin/hermes`.

- [ ] **Step 1: Write the failing launcher test**

Create `tests/test_hermes_remote.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLIENT="$ROOT/client/hermes-remote"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/bin" "$TMP/home/.ssh"
touch "$TMP/home/.ssh/mcf-vps-control.conf"

cat >"$TMP/bin/ssh" <<'SH'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"${SSH_STUB_LOG:?}"
case " $* " in
  *" test -x /home/ubuntu/.local/bin/hermes "*) exit "${SSH_PREFLIGHT_RC:-0}" ;;
  *) exit "${SSH_CHAT_RC:-0}" ;;
esac
SH
chmod +x "$TMP/bin/ssh"

export HOME="$TMP/home"
export PATH="$TMP/bin:/usr/bin:/bin"
export SSH_STUB_LOG="$TMP/ssh.log"

: >"$SSH_STUB_LOG"
"$CLIENT"
grep -F -- "-F $TMP/home/.ssh/mcf-vps-control.conf" "$SSH_STUB_LOG"
grep -F -- 'mcf-vps-control' "$SSH_STUB_LOG"
grep -F -- '/home/ubuntu/.local/bin/hermes chat' "$SSH_STUB_LOG"

: >"$SSH_STUB_LOG"
if SSH_PREFLIGHT_RC=255 "$CLIENT" >"$TMP/out" 2>&1; then exit 1; fi
grep -F 'Não foi possível acessar a VPS pelo SSH canônico.' "$TMP/out"

! grep -E '(BEGIN .*PRIVATE KEY|sk-|token=|api[_-]?key|password=)' "$CLIENT"
echo PASS
```

- [ ] **Step 2: Run and confirm RED**

```bash
bash tests/test_hermes_remote.sh
```

Expected: FAIL because `client/hermes-remote` does not exist.

- [ ] **Step 3: Implement `client/hermes-remote`**

```bash
#!/usr/bin/env bash
set -euo pipefail

SSH_CONFIG="${HERMES_REMOTE_SSH_CONFIG:-$HOME/.ssh/mcf-vps-control.conf}"
SSH_TARGET="${HERMES_REMOTE_SSH_TARGET:-mcf-vps-control}"

fail() {
  printf '\nHermes Agent — %s\n' "$1" >&2
}

if [[ ! -f "$SSH_CONFIG" ]]; then
  fail "configuração SSH canônica não encontrada em $SSH_CONFIG"
  exit 2
fi

if ! ssh -F "$SSH_CONFIG" -o BatchMode=yes -o ConnectTimeout=8 \
  "$SSH_TARGET" 'test -x /home/ubuntu/.local/bin/hermes'; then
  fail "Não foi possível acessar a VPS pelo SSH canônico."
  exit 3
fi

printf 'Hermes Agent — conectado à VPS.\n'
printf 'Fechar esta janela encerra somente o cliente remoto.\n\n'

exec ssh -tt -F "$SSH_CONFIG" "$SSH_TARGET" \
  'exec /home/ubuntu/.local/bin/hermes chat'
```

- [ ] **Step 4: Run tests and syntax checks**

```bash
chmod +x client/hermes-remote tests/test_hermes_remote.sh
bash -n client/hermes-remote
bash tests/test_hermes_remote.sh
```

Expected: `PASS` and `bash -n` exits 0.

- [ ] **Step 5: Commit**

```bash
git add client/hermes-remote tests/test_hermes_remote.sh
git commit -m "feat: add Hermes SSH remote client"
```

---

### Task 3: Add the one-click desktop entry and deterministic installer

**Files:**
- Create: `client/Hermes Agent.desktop`
- Create: `scripts/deploy-notebook-client.sh`
- Create: `tests/test_notebook_deployment.sh`

**Interfaces:**
- Produces `/home/leo/.local/bin/hermes-remote` and `/home/leo/Área de trabalho/Hermes Agent.desktop`.
- Does not clone the repository on the notebook.

- [ ] **Step 1: Write the failing deployment test**

Create `tests/test_notebook_deployment.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

HOME="$TMP/home" DESKTOP_DIR="$TMP/home/Desktop" \
  bash "$ROOT/scripts/deploy-notebook-client.sh"

test -x "$TMP/home/.local/bin/hermes-remote"
grep -Fx 'Name=Hermes Agent' "$TMP/home/Desktop/Hermes Agent.desktop"
grep -Fx "Exec=$TMP/home/.local/bin/hermes-remote" "$TMP/home/Desktop/Hermes Agent.desktop"
grep -Fx 'Terminal=true' "$TMP/home/Desktop/Hermes Agent.desktop"
echo PASS
```

- [ ] **Step 2: Run and confirm RED**

```bash
bash tests/test_notebook_deployment.sh
```

Expected: FAIL because the deployment script/template do not exist.

- [ ] **Step 3: Create `client/Hermes Agent.desktop`**

```ini
[Desktop Entry]
Type=Application
Name=Hermes Agent
Comment=Conversar com o Hermes canônico na VPS
Exec=/home/leo/.local/bin/hermes-remote
Icon=utilities-terminal
Terminal=true
StartupNotify=true
Categories=Development;Utility;
```

- [ ] **Step 4: Implement `scripts/deploy-notebook-client.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="${DESKTOP_DIR:-$HOME/Desktop}"
CLIENT_DST="$BIN_DIR/hermes-remote"
DESKTOP_DST="$DESKTOP_DIR/Hermes Agent.desktop"

install -d "$BIN_DIR" "$DESKTOP_DIR"
install -m 0755 "$ROOT/client/hermes-remote" "$CLIENT_DST"
sed "s|^Exec=.*$|Exec=$CLIENT_DST|" "$ROOT/client/Hermes Agent.desktop" >"$DESKTOP_DST"
chmod 0755 "$DESKTOP_DST"
printf 'Hermes Remote Client instalado em %s\n' "$CLIENT_DST"
printf 'Atalho instalado em %s\n' "$DESKTOP_DST"
```

- [ ] **Step 5: Run all Hermes repository tests**

```bash
chmod +x scripts/deploy-notebook-client.sh tests/test_notebook_deployment.sh
bash -n scripts/deploy-notebook-client.sh
bash tests/test_context_contract.sh
bash tests/test_hermes_remote.sh
bash tests/test_notebook_deployment.sh
```

Expected: all PASS.

- [ ] **Step 6: Commit**

```bash
git add 'client/Hermes Agent.desktop' scripts/deploy-notebook-client.sh tests/test_notebook_deployment.sh
git commit -m "feat: add one-click Hermes notebook launcher"
```

---

### Task 4: Clone the governed Hermes Operator project on the VPS and qualify the client

**Locations:**
- VPS checkout: `/home/ubuntu/leon337-hermes-operator`
- Notebook binary: `/home/leo/.local/bin/hermes-remote`
- Notebook desktop entry: `/home/leo/Área de trabalho/Hermes Agent.desktop`
- Evidence: `docs/evidence/remote-client-v1-acceptance-2026-09-10.md`

**Interfaces:**
- Consumes the GitHub implementation branch after Tasks 1–3 pass.
- Produces the operational thin client while the Hermes runtime remains on the VPS.

- [ ] **Step 1: Verify SSH/Hermes preconditions read-only**

On the notebook:

```bash
test -f /home/leo/.ssh/mcf-vps-control.conf
ssh -F /home/leo/.ssh/mcf-vps-control.conf -o BatchMode=yes -o ConnectTimeout=8 \
  mcf-vps-control 'test -x /home/ubuntu/.local/bin/hermes && echo HERMES_REMOTE_PRECHECK_OK'
```

Expected: `HERMES_REMOTE_PRECHECK_OK`.

- [ ] **Step 2: Verify GitHub access from the VPS**

```bash
ssh -F /home/leo/.ssh/mcf-vps-control.conf mcf-vps-control \
  'git ls-remote https://github.com/leon337/leon337-hermes-operator.git HEAD >/dev/null && echo GITHUB_ACCESS_OK'
```

Expected: `GITHUB_ACCESS_OK`. If authentication is required, stop at `GITHUB_AUTH_REQUIRED`; do not copy a notebook checkout as a workaround.

- [ ] **Step 3: Clone from GitHub on the VPS**

When the directory is absent:

```bash
ssh -F /home/leo/.ssh/mcf-vps-control.conf mcf-vps-control \
  'git clone https://github.com/leon337/leon337-hermes-operator.git /home/ubuntu/leon337-hermes-operator'
```

Then verify `origin`, fetch, and check out the approved implementation commit/branch. Never replace this with a copied working tree.

- [ ] **Step 4: Pull only deployment artifacts to a temporary notebook directory**

```bash
TMP="$(mktemp -d)"
ssh -F /home/leo/.ssh/mcf-vps-control.conf mcf-vps-control \
  'cd /home/ubuntu/leon337-hermes-operator && tar -cf - client scripts/deploy-notebook-client.sh' \
  | tar -xf - -C "$TMP"
HOME=/home/leo DESKTOP_DIR='/home/leo/Área de trabalho' \
  bash "$TMP/scripts/deploy-notebook-client.sh"
rm -rf "$TMP"
```

- [ ] **Step 5: End-to-end user-flow test**

Double-click **Hermes Agent** and verify:

1. a visible notebook terminal opens;
2. VPS process inspection confirms `/home/ubuntu/.local/bin/hermes chat` runs on the VPS;
3. the notebook has no Hermes runtime installed by this work;
4. send `Responda exatamente HERMES_REMOTE_V1_OK`;
5. verify `HERMES_REMOTE_V1_OK` is returned;
6. inspect provider/model using a separate non-secret read-only Hermes status/config command;
7. close only the client terminal;
8. confirm persistent VPS services remain alive.

- [ ] **Step 6: Failure-path test**

```bash
HERMES_REMOTE_SSH_CONFIG=/tmp/nonexistent-hermes-ssh-config \
  /home/leo/.local/bin/hermes-remote
```

Expected: clear Portuguese error and non-zero exit, with no alternate host/provider path.

- [ ] **Step 7: Record sanitized acceptance evidence**

Create `docs/evidence/remote-client-v1-acceptance-2026-09-10.md` with:

```markdown
# Hermes Remote Client V1 — Acceptance Evidence

- Canonical runtime location: VPS
- Notebook role: thin SSH client
- Canonical SSH alias: `mcf-vps-control`
- Remote command: `/home/ubuntu/.local/bin/hermes chat`
- Benign response probe: `HERMES_REMOTE_V1_OK`
- Notebook duplicate Hermes runtime: NOT CREATED
- Legacy `MCF-HERMES-PC-002` auto-start: NOT USED
- New public/Tailscale listener: NOT CREATED
- Persistent service safety check: PASS
- SSH failure path: FAIL-CLOSED / PASS
```

Append only sanitized provider/model name and PASS/FAIL observations; do not store credentials, OAuth data, private keys, tokens, or private conversation contents.

- [ ] **Step 8: Commit evidence**

```bash
git add docs/evidence/remote-client-v1-acceptance-2026-09-10.md
git commit -m "evidence: qualify Hermes Remote Client V1"
```

---

### Task 5: Register Hermes Operator in the MCF Context Fabric

**Repository:** `leon337/multiagent-collaboration-framework`

**Files:**
- Create: `context/projects/leon337-hermes-operator.yaml`
- Create: `apps/rede-social-agentes/apps/server/src/mcf-context/hermes-operator-registry.test.ts`

**Interfaces:**
- Consumes the merged Hermes Operator capsule/current-state/entrypoints.
- Produces durable Context Fabric discovery and alias resolution.

- [ ] **Step 1: Create isolated MCF branch/worktree**

Branch:

```text
feat/context-register-hermes-operator
```

Create it from the current GitHub `main` SHA and use a separate worktree so no other MCF work is mixed into this change.

- [ ] **Step 2: Write the failing MCF test**

Create `apps/rede-social-agentes/apps/server/src/mcf-context/hermes-operator-registry.test.ts`:

```ts
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';

import type { McfProjectRegistryEntry } from '@rsa/contracts';
import { parse } from 'yaml';
import { describe, expect, it } from 'vitest';

import { ContextSchemaValidator } from './context-schema.validator.js';
import { resolveProject } from './project-resolver.js';

const root = fileURLToPath(new URL('../../../../../../', import.meta.url));
const registryPath = join(root, 'context/projects/leon337-hermes-operator.yaml');
const schemaPath = join(root, 'schemas/context/project-registry-entry.schema.json');

function entry(): McfProjectRegistryEntry {
  return parse(readFileSync(registryPath, 'utf8')) as McfProjectRegistryEntry;
}

describe('Hermes Operator Context Fabric registration', () => {
  it('validates the canonical registry entry', () => {
    const value = entry();
    const validator = new ContextSchemaValidator(schemaPath);
    expect(validator.validate(value)).toEqual({ valid: true, errors: [] });
    expect(value).toMatchObject({
      project: { id: 'leon337-hermes-operator', lifecycle: 'REGISTERED' },
      identity: { canonical_repository: 'leon337/leon337-hermes-operator' },
      ownership: { project_owner: 'LEANDRO' },
      freshness: { operational_state: 'LIVE_REQUIRED', project_identity: 'DURABLE' },
    });
  });

  it('resolves canonical id, repository, and approved aliases', () => {
    const value = entry();
    for (const hint of [
      'leon337-hermes-operator',
      'leon337/leon337-hermes-operator',
      'Hermes Operator',
      'Hermes Agent',
      'Hermes',
    ]) {
      expect(resolveProject([value], hint)).toMatchObject({
        outcome: 'RESOLVED',
        project_id: 'leon337-hermes-operator',
      });
    }
  });
});
```

- [ ] **Step 3: Run and confirm RED**

```bash
cd apps/rede-social-agentes/apps/server
pnpm exec vitest run src/mcf-context/hermes-operator-registry.test.ts
```

Expected: FAIL because `context/projects/leon337-hermes-operator.yaml` does not exist.

- [ ] **Step 4: Create the registry entry**

Create `context/projects/leon337-hermes-operator.yaml`:

```yaml
schema_version: 1

project:
  id: leon337-hermes-operator
  lifecycle: REGISTERED

identity:
  canonical_repository: leon337/leon337-hermes-operator
  aliases:
    - Hermes Operator
    - Hermes Agent
    - Hermes

ownership:
  project_owner: LEANDRO

context:
  capsule_path: .mcf/project-capsule.yaml
  canonical_entrypoints:
    - README.md
    - docs/current-state.md
    - docs/architecture/architecture-decision-package-v1.1.md
    - docs/superpowers/specs/2026-09-10-hermes-remote-client-context-fabric-design.md

freshness:
  operational_state: LIVE_REQUIRED
  project_identity: DURABLE
```

- [ ] **Step 5: Run focused MCF verification**

```bash
cd apps/rede-social-agentes/apps/server
pnpm exec vitest run \
  src/mcf-context/hermes-operator-registry.test.ts \
  src/mcf-context/context-schema.validator.test.ts \
  src/mcf-context/project-resolver.test.ts
pnpm run typecheck
```

Then from `apps/rede-social-agentes` run:

```bash
pnpm format:check
pnpm lint
```

Expected: all commands exit 0.

- [ ] **Step 6: Commit and open MCF PR**

```bash
git add context/projects/leon337-hermes-operator.yaml \
  apps/rede-social-agentes/apps/server/src/mcf-context/hermes-operator-registry.test.ts
git commit -m "context: register Hermes Operator"
```

Open PR title:

```text
Context: register Hermes Operator
```

PR body must explicitly state that `LIVE_REQUIRED` prevents repository state from authorizing or proving live Hermes operations.

---

### Task 6: Reconcile final state and merge in safe order

**Files:**
- Update: `docs/current-state.md`
- Update: `.mcf/project-capsule.yaml`
- Review: Hermes Operator PR and MCF Context Fabric PR

**Interfaces:**
- Produces final canonical GitHub state aligned with deployed runtime and Context Fabric discovery.

- [ ] **Step 1: Enforce merge order**

Use exactly this order:

```text
1. Hermes repository tests PASS
2. Remote Client V1 live acceptance PASS
3. Hermes Operator PR merges to main
4. VPS checkout updates from GitHub main
5. MCF registry branch rebases/validates against current MCF main
6. MCF Context Fabric PR merges
7. Live Context Fabric resolution is verified
```

- [ ] **Step 2: Refresh durable Hermes state after qualification**

Update `docs/current-state.md` to state that Remote Client V1 is qualified and Context Fabric registration is the active integration step.

Refresh `.mcf/project-capsule.yaml` with a real UTC timestamp and exactly this durable snapshot:

```yaml
snapshot:
  current_workstream: remote-client-v1-context-fabric
  current_status: REMOTE_CLIENT_V1_QUALIFIED_CONTEXT_REGISTRATION_IN_PROGRESS
  next_action: Complete and verify the MCF Context Fabric registry integration.
  blockers: []
```

- [ ] **Step 3: Re-run Hermes capsule and client tests**

```bash
bash tests/test_context_contract.sh
bash tests/test_hermes_remote.sh
bash tests/test_notebook_deployment.sh
```

Expected: all PASS.

- [ ] **Step 4: Verify Context Fabric after registry merge**

Run the dedicated MCF test against merged `main`:

```bash
cd apps/rede-social-agentes/apps/server
pnpm exec vitest run src/mcf-context/hermes-operator-registry.test.ts
```

Expected: PASS for canonical id, repository, and all three aliases.

- [ ] **Step 5: Final live safety check**

Verify no new listener was introduced for Hermes/Qwen/controller, and confirm the existing critical services remain available. The final report must separate durable Git state from live observations.

## Final Definition of Done

- Notebook icon **Hermes Agent** opens a visible terminal that runs `hermes chat` on the VPS.
- No second Hermes runtime is installed on the notebook.
- The canonical Hermes runtime remains on the VPS.
- A benign user message completes end-to-end.
- Provider/model can be observed without exposing credentials.
- Closing the client leaves persistent VPS services running.
- Canonical SSH failure is explicit and fail-closed.
- Hermes Operator contains a valid `.mcf/project-capsule.yaml` and durable current-state document.
- MCF contains `context/projects/leon337-hermes-operator.yaml` validated by the current schema.
- Context Fabric resolves canonical id, repository, and aliases `Hermes Operator`, `Hermes Agent`, and `Hermes`.
- Operational health remains `LIVE_REQUIRED` and is never inferred from Git state.
