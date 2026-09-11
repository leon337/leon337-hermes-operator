# Hermes Remote Client + MCF Context Fabric Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expose the single canonical Hermes runtime on the VPS to LEANDRO through a one-click notebook launcher, then register Hermes Operator as a durable project in the MCF Context Fabric.

**Architecture:** The notebook remains a thin client. A repository-owned Bash launcher uses the existing canonical SSH profile to run `hermes chat` on the VPS with an interactive TTY. Hermes, provider selection, sessions, tools, memory, Qwen, and runtime state remain on the VPS. The Hermes Operator repository owns the launcher, desktop template, capsule, and current-state documentation. The MCF repository owns the Context Fabric registry entry and the resolver/schema validation evidence.

**Tech Stack:** Bash, freedesktop `.desktop`, OpenSSH, Git/GitHub, YAML, MCF Context Fabric schemas, Node 24, pnpm 11, TypeScript/Vitest.

**Spec:** `docs/superpowers/specs/2026-09-10-hermes-remote-client-context-fabric-design.md`

## Global Constraints

- Exactly one canonical Hermes runtime: the VPS instance under `/home/ubuntu/.hermes/hermes-agent`.
- Do not install Hermes, Qwen, model configuration, session state, provider credentials, or Hermes secrets on the notebook.
- Remote Client V1 transport is SSH only.
- Use notebook SSH config `/home/leo/.ssh/mcf-vps-control.conf` and host alias `mcf-vps-control`.
- Remote command is `/home/ubuntu/.local/bin/hermes chat`; do not call the legacy `MCF-HERMES-PC-002` controller or relay.
- Do not expose Qwen `:8080`, controller sockets, HTTP, VNC, WebSocket, or new public/Tailscale ports.
- Closing the client must not stop Hermes services, Qwen, TriView, DSHs, 9Router, SentinelX, Docker, Tailscale, GitHub Runner, or the VPS graphical workstation.
- GitHub is the canonical source; the notebook receives only deployed launcher artifacts, not a canonical project checkout.
- Hermes Operator Context Fabric identity is `leon337-hermes-operator` with aliases `Hermes Operator`, `Hermes Agent`, and `Hermes`.
- Context Fabric operational freshness is `LIVE_REQUIRED`; repository state must never claim live provider/session/process health.
- Do not merge the MCF registry entry before the referenced Hermes capsule/current-state/entrypoints exist on the Hermes repository canonical branch.

---

### Task 1: Add Hermes Operator current-state document and Context Fabric capsule

**Files:**
- Create: `docs/current-state.md`
- Create: `.mcf/project-capsule.yaml`
- Test: `tests/test_context_capsule.py`

**Interfaces:**
- Produces: durable project identity and repository-native current state consumed later by the MCF registry entry.
- Consumes: MCF schema `schemas/context/project-capsule.schema.json` from `leon337/multiagent-collaboration-framework`.

- [ ] **Step 1: Create the failing capsule test**

Create `tests/test_context_capsule.py` with a dependency-free structural test so the Hermes repository can validate its own invariant before cross-repository schema validation:

```python
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]
CAPSULE = ROOT / ".mcf" / "project-capsule.yaml"
CURRENT = ROOT / "docs" / "current-state.md"


def test_capsule_identity_and_source_contract():
    data = yaml.safe_load(CAPSULE.read_text())
    assert data["schema_version"] == 1
    assert data["project_id"] == "leon337-hermes-operator"
    assert data["sources"]["current_state"] == "docs/current-state.md"
    assert data["snapshot"]["current_workstream"] == "remote-client-v1-context-fabric"
    assert "provider" not in data["snapshot"]
    assert CURRENT.exists()
```

- [ ] **Step 2: Run the test and confirm RED**

Run from the Hermes Operator implementation worktree:

```bash
python3 -m pytest tests/test_context_capsule.py -q
```

Expected: FAIL because `.mcf/project-capsule.yaml` and `docs/current-state.md` do not exist.

- [ ] **Step 3: Create `docs/current-state.md`**

The document must state only durable/reconciled facts:

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

Current provider, model availability, process health, session health, authentication state, and VPS health require live observation. Repository context must not be treated as proof of current runtime state.
```

- [ ] **Step 4: Create `.mcf/project-capsule.yaml` using a real observation timestamp**

Generate the timestamp first:

```bash
OBSERVED_AT="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
```

Then write:

```yaml
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
observed_at: "${OBSERVED_AT}"
```

The actual file must contain the concrete RFC 3339 timestamp value, not the shell expression.

- [ ] **Step 5: Run the local structural test and schema validation**

Run:

```bash
python3 -m pytest tests/test_context_capsule.py -q
```

Then, using the current MCF checkout, validate the capsule with the existing `ContextSchemaValidator` by copying only the candidate YAML into a temporary fixture or invoking the validator from a small one-off Node command inside `apps/rede-social-agentes`.

Expected: capsule validates against `schemas/context/project-capsule.schema.json` with `{ valid: true, errors: [] }`.

- [ ] **Step 6: Commit**

```bash
git add .mcf/project-capsule.yaml docs/current-state.md tests/test_context_capsule.py
git commit -m "context: add Hermes Operator project capsule"
```

---

### Task 2: Implement the repository-owned SSH remote client

**Files:**
- Create: `client/hermes-remote`
- Create: `tests/test_hermes_remote.sh`

**Interfaces:**
- Produces: executable `client/hermes-remote` deployed to notebook as `/home/leo/.local/bin/hermes-remote`.
- Consumes: `/home/leo/.ssh/mcf-vps-control.conf`, SSH alias `mcf-vps-control`, remote executable `/home/ubuntu/.local/bin/hermes`.

- [ ] **Step 1: Write failing shell tests**

Create `tests/test_hermes_remote.sh` that runs the launcher against stubbed `ssh` binaries injected through `PATH`. Cover four behaviors:

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
grep -F -- '-F '"$TMP/home/.ssh/mcf-vps-control.conf" "$SSH_STUB_LOG"
grep -F -- 'mcf-vps-control' "$SSH_STUB_LOG"
grep -F -- '/home/ubuntu/.local/bin/hermes chat' "$SSH_STUB_LOG"

: >"$SSH_STUB_LOG"
SSH_PREFLIGHT_RC=255 "$CLIENT" >"$TMP/out" 2>&1 && exit 1 || true
grep -F 'Não foi possível acessar a VPS pelo SSH canônico.' "$TMP/out"

! grep -E '(BEGIN .*PRIVATE KEY|sk-|token=|api[_-]?key|password=)' "$CLIENT"

echo PASS
```

- [ ] **Step 2: Run the test and confirm RED**

```bash
bash tests/test_hermes_remote.sh
```

Expected: FAIL because `client/hermes-remote` does not exist.

- [ ] **Step 3: Implement the minimal client**

Create `client/hermes-remote`:

```bash
#!/usr/bin/env bash
set -euo pipefail

SSH_CONFIG="${HERMES_REMOTE_SSH_CONFIG:-$HOME/.ssh/mcf-vps-control.conf}"
SSH_TARGET="${HERMES_REMOTE_SSH_TARGET:-mcf-vps-control}"
REMOTE_HERMES="/home/ubuntu/.local/bin/hermes"

fail() {
  printf '\nHermes Agent — %s\n' "$1" >&2
  return 1
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

Do not add fallback hosts, direct IPs, local Hermes execution, provider overrides, or legacy relay calls.

- [ ] **Step 4: Run tests and static checks**

```bash
chmod +x client/hermes-remote tests/test_hermes_remote.sh
bash -n client/hermes-remote
shellcheck client/hermes-remote tests/test_hermes_remote.sh 2>/dev/null || true
bash tests/test_hermes_remote.sh
```

Expected: `PASS` from the contract test; `bash -n` exits 0. If `shellcheck` is installed, fix any real warnings in the files touched by this task.

- [ ] **Step 5: Commit**

```bash
git add client/hermes-remote tests/test_hermes_remote.sh
git commit -m "feat: add Hermes SSH remote client"
```

---

### Task 3: Add one-click notebook desktop entry and governed deployment contract

**Files:**
- Create: `client/Hermes Agent.desktop`
- Create: `scripts/deploy-notebook-client.sh`
- Create: `tests/test_notebook_deployment.sh`

**Interfaces:**
- Produces notebook artifacts `/home/leo/.local/bin/hermes-remote` and `/home/leo/Área de trabalho/Hermes Agent.desktop`.
- Consumes repository artifacts from the canonical VPS checkout; does not clone the repository on the notebook.

- [ ] **Step 1: Write the failing deployment test**

The test must deploy into a temporary fake home and assert executable/desktop metadata without touching the real notebook desktop:

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

HOME="$TMP/home" DESKTOP_DIR="$TMP/home/Desktop" \
  bash "$ROOT/scripts/deploy-notebook-client.sh"

test -x "$TMP/home/.local/bin/hermes-remote"
grep -F 'Name=Hermes Agent' "$TMP/home/Desktop/Hermes Agent.desktop"
grep -F 'Exec='"$TMP/home/.local/bin/hermes-remote" "$TMP/home/Desktop/Hermes Agent.desktop"
grep -F 'Terminal=true' "$TMP/home/Desktop/Hermes Agent.desktop"
echo PASS
```

- [ ] **Step 2: Run the test and confirm RED**

```bash
bash tests/test_notebook_deployment.sh
```

Expected: FAIL because the deployment script/template do not exist.

- [ ] **Step 3: Create the desktop template**

Create `client/Hermes Agent.desktop` as the repository template:

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

- [ ] **Step 4: Implement deployment script**

Create `scripts/deploy-notebook-client.sh` that copies the repository-owned artifacts into the current user home, supports `DESKTOP_DIR`, creates parent directories, applies mode `0755` to the client and desktop entry, and rewrites only the `Exec=` path to the actual `$HOME/.local/bin/hermes-remote` when running in tests or another authorized user environment.

Do not create SSH keys, modify SSH config, install packages, or copy repository history to the notebook.

- [ ] **Step 5: Run tests**

```bash
bash -n scripts/deploy-notebook-client.sh
bash tests/test_notebook_deployment.sh
bash tests/test_hermes_remote.sh
python3 -m pytest tests/test_context_capsule.py -q
```

Expected: all PASS.

- [ ] **Step 6: Commit**

```bash
git add 'client/Hermes Agent.desktop' scripts/deploy-notebook-client.sh tests/test_notebook_deployment.sh
git commit -m "feat: add one-click Hermes notebook launcher"
```

---

### Task 4: Materialize the canonical Hermes Operator checkout on the VPS and deploy the thin client

**Files/locations:**
- VPS checkout: `/home/ubuntu/leon337-hermes-operator`
- Notebook executable: `/home/leo/.local/bin/hermes-remote`
- Notebook desktop entry: `/home/leo/Área de trabalho/Hermes Agent.desktop`
- Evidence: `docs/evidence/remote-client-v1-acceptance-2026-09-10.md`

**Interfaces:**
- Consumes: GitHub branch/PR after Tasks 1–3 pass.
- Produces: operational thin client with no second notebook Hermes installation.

- [ ] **Step 1: Verify preconditions read-only**

On notebook:

```bash
test -f /home/leo/.ssh/mcf-vps-control.conf
ssh -F /home/leo/.ssh/mcf-vps-control.conf -o BatchMode=yes -o ConnectTimeout=8 \
  mcf-vps-control 'test -x /home/ubuntu/.local/bin/hermes && echo HERMES_REMOTE_PRECHECK_OK'
```

Expected: `HERMES_REMOTE_PRECHECK_OK`.

- [ ] **Step 2: Clone the governed project on the VPS from GitHub**

Use the existing authorized GitHub authentication path on the VPS. The canonical checkout location is:

```bash
/home/ubuntu/leon337-hermes-operator
```

If absent, clone `leon337/leon337-hermes-operator`; if present, verify its `origin` before any pull. Check out the approved implementation branch/commit. Do not copy a notebook working tree to the VPS.

- [ ] **Step 3: Deploy notebook artifacts from the VPS checkout**

From the notebook, pull only the required source artifacts from the VPS checkout into a temporary directory with `scp -F /home/leo/.ssh/mcf-vps-control.conf`, then run `scripts/deploy-notebook-client.sh` locally. Remove the temporary deployment copy after verification.

- [ ] **Step 4: End-to-end test the icon path**

Double-click **Hermes Agent** from the notebook desktop and verify:

1. a visible local terminal opens;
2. `hermes chat` runs on the VPS, confirmed by process ownership/command on the VPS;
3. the notebook has no newly installed Hermes runtime;
4. send a benign test message: `Responda exatamente HERMES_REMOTE_V1_OK`;
5. verify the response;
6. observe provider/model using a non-secret Hermes status/config command in a separate read-only check;
7. close the client terminal;
8. confirm `hermes-provider.service`, `hermes-controller.service`, TriView, 9Router, SentinelX, DSHs, Docker, Tailscale, and GitHub Runner remain alive.

- [ ] **Step 5: Test failure behavior without changing real SSH state**

Run the installed client with:

```bash
HERMES_REMOTE_SSH_CONFIG=/tmp/nonexistent-hermes-ssh-config \
  /home/leo/.local/bin/hermes-remote
```

Expected: visible Portuguese error and non-zero exit; no fallback connection attempt.

- [ ] **Step 6: Record sanitized acceptance evidence**

Create `docs/evidence/remote-client-v1-acceptance-2026-09-10.md` containing only command names, PASS/FAIL results, process location (VPS vs notebook), provider/model name if non-secret, and service-health checks. Do not record tokens, OAuth data, session contents beyond the benign test string, SSH private-key material, or private runtime logs.

- [ ] **Step 7: Commit**

```bash
git add docs/evidence/remote-client-v1-acceptance-2026-09-10.md
git commit -m "evidence: qualify Hermes Remote Client V1"
```

---

### Task 5: Register Hermes Operator in the MCF Context Fabric

**Repository:** `leon337/multiagent-collaboration-framework`

**Files:**
- Create: `context/projects/leon337-hermes-operator.yaml`
- Modify: `apps/rede-social-agentes/apps/server/src/mcf-context/mcf-context-fixtures.test.ts`
- Modify: `apps/rede-social-agentes/apps/server/src/mcf-context/project-resolver.test.ts`

**Interfaces:**
- Consumes: merged Hermes Operator capsule and canonical entrypoints.
- Produces: durable Context Fabric discovery for canonical id, repository, and approved aliases.

- [ ] **Step 1: Create an isolated MCF branch/worktree from current `main`**

Branch name:

```text
feat/context-register-hermes-operator
```

Verify the base SHA against current GitHub `main` before editing.

- [ ] **Step 2: Write failing fixture/resolver tests**

Extend `mcf-context-fixtures.test.ts` to load `context/projects/leon337-hermes-operator.yaml`, assert the exact project id/repository/aliases/owner/capsule path/freshness, and validate it with `project-registry-entry.schema.json`.

Extend `project-resolver.test.ts` with one focused test that constructs the Hermes entry and verifies all of these hints resolve to `leon337-hermes-operator`:

```text
leon337-hermes-operator
leon337/leon337-hermes-operator
Hermes Operator
Hermes Agent
Hermes
```

- [ ] **Step 3: Run the focused tests and confirm RED**

From `apps/rede-social-agentes`:

```bash
pnpm --filter @rsa/server test -- \
  src/mcf-context/mcf-context-fixtures.test.ts \
  src/mcf-context/project-resolver.test.ts
```

If the package script does not forward file arguments under this pnpm/vitest version, run:

```bash
pnpm exec vitest run \
  apps/server/src/mcf-context/mcf-context-fixtures.test.ts \
  apps/server/src/mcf-context/project-resolver.test.ts
```

Expected: FAIL because the Hermes registry file does not yet exist.

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

- [ ] **Step 5: Run focused and repository verification**

Run:

```bash
cd apps/rede-social-agentes
pnpm exec vitest run \
  apps/server/src/mcf-context/context-schema.validator.test.ts \
  apps/server/src/mcf-context/mcf-context-fixtures.test.ts \
  apps/server/src/mcf-context/project-resolver.test.ts
pnpm format:check
pnpm typecheck
```

If time/cost permits before PR, run the full workspace gate:

```bash
pnpm verify
```

Expected: all focused Context Fabric tests PASS and no unrelated regression introduced by the new registry entry.

- [ ] **Step 6: Commit and open MCF PR**

```bash
git add context/projects/leon337-hermes-operator.yaml \
  apps/rede-social-agentes/apps/server/src/mcf-context/mcf-context-fixtures.test.ts \
  apps/rede-social-agentes/apps/server/src/mcf-context/project-resolver.test.ts
git commit -m "context: register Hermes Operator"
```

Open a PR to `main` titled:

```text
Context: register Hermes Operator
```

The PR description must state that operational state remains `LIVE_REQUIRED` and that the registry entry does not authorize Hermes material actions.

---

### Task 6: Final reconciliation, merge order, and acceptance

**Files:**
- Update: `docs/current-state.md`
- Update: `.mcf/project-capsule.yaml`
- Update: Hermes Operator PR description
- Review: MCF registry PR

**Interfaces:**
- Produces: canonical GitHub state aligned with deployed runtime and Context Fabric discovery.

- [ ] **Step 1: Merge/order gate**

Use this order:

```text
1. Hermes Operator tests + remote-client acceptance PASS
2. Hermes Operator PR merged to main
3. VPS canonical checkout updated from GitHub main
4. MCF registry branch rebased/validated against current MCF main
5. MCF Context Fabric PR reviewed and merged
6. Live Context Fabric resolution checked
```

Do not merge the MCF registration before step 2.

- [ ] **Step 2: Update Hermes durable current state after successful acceptance**

Change the durable status to indicate Remote Client V1 is implemented and qualified, while keeping live runtime facts behind `LIVE_REQUIRED`.

Update `.mcf/project-capsule.yaml` with a new real `observed_at` timestamp and a durable snapshot such as:

```yaml
snapshot:
  current_workstream: remote-client-v1-context-fabric
  current_status: REMOTE_CLIENT_V1_QUALIFIED_CONTEXT_REGISTRATION_IN_PROGRESS
  next_action: Complete and verify the MCF Context Fabric registry integration.
  blockers: []
```

- [ ] **Step 3: Verify Context Fabric resolution after registry merge**

Use the MCF resolver/recovery path to check the canonical id plus aliases:

```text
leon337-hermes-operator
Hermes Operator
Hermes Agent
Hermes
```

Expected: each resolves to `project_id=leon337-hermes-operator`; runtime health remains a live-verification concern.

- [ ] **Step 4: Final service-safety check**

Verify the same critical services observed before deployment remain available and that no new public listener was created by Remote Client V1. Specifically confirm no new public/Tailscale listener for Hermes/Qwen/controller was introduced.

- [ ] **Step 5: Final commit/PR evidence**

Commit the final current-state/capsule refresh to the Hermes Operator PR or a small follow-up PR if the implementation PR has already merged. Record the MCF registry commit/PR reference in sanitized project evidence.

## Final Definition of Done

Remote Client V1 is complete only when:

- the **Hermes Agent** desktop icon on the notebook opens a terminal that runs `hermes chat` on the VPS;
- the notebook contains no second Hermes runtime created by this work;
- the canonical Hermes runtime remains on the VPS;
- the user can send and receive a benign chat message;
- provider/model can be observed without exposing credentials;
- closing the client does not stop persistent services;
- failure of the canonical SSH path is explicit and fail-closed;
- Hermes Operator contains a valid `.mcf/project-capsule.yaml` and durable current-state document;
- MCF contains `context/projects/leon337-hermes-operator.yaml` validated by the current schema;
- the MCF resolver resolves the canonical id, repository, and approved aliases;
- operational health remains `LIVE_REQUIRED` and is never inferred from Git state.
