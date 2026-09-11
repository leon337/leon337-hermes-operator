# Hermes Remote Client + MCF Context Fabric Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expose the single canonical Hermes runtime on the VPS through a one-click notebook client, then register Hermes Operator as a durable project in the MCF Context Fabric.

**Architecture:** The notebook is a thin client. A repository-owned Bash launcher uses exactly `/home/leo/.ssh/mcf-vps-control.conf` and `mcf-vps-control`, disables SSH forwarding/multiplexing for the client connection, and runs `/home/ubuntu/.local/bin/hermes chat` on the VPS. Hermes runtime/provider/session/tool state stays on the VPS. Hermes Operator owns the launcher, desktop template, capsule and durable state; MCF owns Context Fabric registration.

**Tech Stack:** Bash, freedesktop `.desktop`, OpenSSH, Git/GitHub, YAML, MCF Context Fabric, Node 24, pnpm 11, TypeScript/Vitest.

**Spec:** `docs/superpowers/specs/2026-09-10-hermes-remote-client-context-fabric-design.md`

## Global Constraints

- One canonical Hermes runtime only: VPS.
- No Hermes/Qwen/provider/session/model state installed on notebook.
- Production SSH config is exactly `/home/leo/.ssh/mcf-vps-control.conf`; target is exactly `mcf-vps-control`; no runtime override exists.
- Remote command is exactly `/home/ubuntu/.local/bin/hermes chat`.
- Both preflight and interactive SSH use `BatchMode=yes`, `ConnectTimeout=8`, `ClearAllForwardings=yes`, `ControlMaster=no`, and `ControlPath=none`.
- No new LocalForward/RemoteForward/DynamicForward/public/Tailscale listener.
- Never call or auto-resume `MCF-HERMES-PC-002` or the legacy relay.
- Closing the client must not stop persistent VPS services.
- GitHub is canonical; notebook receives only derived deployment artifacts.
- Context Fabric identity: `leon337-hermes-operator`; aliases `Hermes Operator`, `Hermes Agent`, `Hermes`; owner `LEANDRO`; freshness `LIVE_REQUIRED` / `DURABLE`.
- Runtime/provider/session health is never inferred from Git.
- Do not merge the MCF registry entry before Hermes capsule/current-state/entrypoints exist on Hermes `main`.

---

### Task 1: Add durable current state and project capsule

**Files:**
- Create: `docs/current-state.md`
- Create: `.mcf/project-capsule.yaml`
- Create: `tests/test-context-contract.sh`

**Interfaces:** Produces repository-native durable context consumed by the MCF registry.

- [ ] **Step 1: Write the failing contract test**

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
grep -F 'LIVE_REQUIRED' "$CURRENT"
echo PASS
```

- [ ] **Step 2: Run RED**

Run `bash tests/test-context-contract.sh`. Expected: FAIL because candidate files do not exist.

- [ ] **Step 3: Create `docs/current-state.md`**

It must state: project id/repository/LEANDRO authority; workstream `remote-client-v1-context-fabric`; VPS runtime + notebook client boundary; old notebook-local computer-use design is historical; TriView control is not this V1 purpose; `MCF-HERMES-PC-002` is not auto-resumed; runtime/provider/model/session/auth health is `LIVE_REQUIRED`.

- [ ] **Step 4: Create capsule with a real UTC timestamp**

```yaml
schema_version: 1
project_id: leon337-hermes-operator
purpose: Govern and extend the official Nous Research Hermes Agent as an MCF-controlled autonomous operator while keeping LEANDRO as final human authority.
lifecycle: ACTIVE
snapshot:
  current_workstream: remote-client-v1-context-fabric
  current_status: DESIGN_APPROVED_IMPLEMENTATION_IN_PROGRESS
  next_action: Implement and verify Remote Client V1, then register Hermes Operator in the MCF Context Fabric.
  blockers: []
sources:
  current_state: docs/current-state.md
observed_at: "<real RFC3339 UTC timestamp captured at materialization>"
```

- [ ] **Step 5: Verify and commit**

Run `bash tests/test-context-contract.sh`, then validate the YAML against current MCF `schemas/context/project-capsule.schema.json` using the existing `ContextSchemaValidator`. Expected: both PASS. Commit message: `context: add Hermes Operator project capsule`.

---

### Task 2: Implement fixed SSH Remote Client V1

**Files:**
- Create: `scripts/hermes-remote-client.sh`
- Create: `tests/test-hermes-remote-client.sh`

**Interfaces:** Produces the notebook launcher source deployed as `/home/leo/.local/bin/hermes-remote-client`.

- [ ] **Step 1: Write failing security/contract test**

```bash
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
```

- [ ] **Step 2: Run RED**

Run `bash tests/test-hermes-remote-client.sh`. Expected: FAIL because launcher does not exist.

- [ ] **Step 3: Implement `scripts/hermes-remote-client.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

SSH_CONFIG="/home/leo/.ssh/mcf-vps-control.conf"
SSH_TARGET="mcf-vps-control"
REMOTE_HERMES="/home/ubuntu/.local/bin/hermes"
SSH_COMMON=(
  -F "$SSH_CONFIG"
  -o BatchMode=yes
  -o ConnectTimeout=8
  -o ClearAllForwardings=yes
  -o ControlMaster=no
  -o ControlPath=none
)

fail() { printf '\nHermes Agent — %s\n' "$1" >&2; }

if [[ ! -f "$SSH_CONFIG" ]]; then
  fail "configuração SSH canônica não encontrada em $SSH_CONFIG"
  exit 2
fi

if ! ssh "${SSH_COMMON[@]}" "$SSH_TARGET" "test -x $REMOTE_HERMES"; then
  fail "Não foi possível acessar a VPS pelo SSH canônico ou o Hermes remoto não está disponível."
  exit 3
fi

printf 'Hermes Agent — conectado à VPS.\n'
printf 'Fechar esta janela encerra somente o cliente remoto.\n\n'
exec ssh -tt "${SSH_COMMON[@]}" "$SSH_TARGET" "exec $REMOTE_HERMES chat"
```

- [ ] **Step 4: Verify and commit**

Run `chmod +x scripts/hermes-remote-client.sh tests/test-hermes-remote-client.sh`, `bash -n scripts/hermes-remote-client.sh`, and `bash tests/test-hermes-remote-client.sh`. Expected: PASS. Commit: `feat: add fixed Hermes SSH remote client`.

---

### Task 3: Add one-click desktop template and deterministic deployment

**Files:**
- Create: `packaging/linux/hermes-agent-remote.desktop`
- Create: `scripts/deploy-notebook-client.sh`
- Create: `tests/test-notebook-deployment.sh`

**Interfaces:** Produces only `/home/leo/.local/bin/hermes-remote-client` and the notebook `Hermes Agent.desktop`; no project checkout on notebook.

- [ ] **Step 1: Write failing deployment test**

Use a temporary fake home and assert: deployed launcher is executable; desktop entry has `Name=Hermes Agent`, `Terminal=true`, and `Exec=<fake-home>/.local/bin/hermes-remote-client`; no `.git` directory/project checkout is created.

- [ ] **Step 2: Run RED**

Run `bash tests/test-notebook-deployment.sh`. Expected: FAIL before template/deployer exist.

- [ ] **Step 3: Create desktop template**

```ini
[Desktop Entry]
Type=Application
Name=Hermes Agent
Comment=Conversar com o Hermes canônico na VPS
Exec=/home/leo/.local/bin/hermes-remote-client
Icon=utilities-terminal
Terminal=true
StartupNotify=true
Categories=Development;Utility;
```

- [ ] **Step 4: Implement deployer**

`scripts/deploy-notebook-client.sh` must resolve `DESKTOP_DIR` from explicit test input or `xdg-user-dir DESKTOP` with `/home/leo/Área de trabalho` as the current production fallback, copy `scripts/hermes-remote-client.sh` to `$HOME/.local/bin/hermes-remote-client`, render only the desktop `Exec=` path, and never create/modify SSH keys, SSH config, packages, or repository checkout.

- [ ] **Step 5: Verify and commit**

Run all three Hermes shell tests plus `bash -n` on scripts. Expected: PASS. Commit: `feat: add one-click Hermes notebook launcher`.

---

### Task 4: Materialize the GitHub checkout on VPS and qualify live client

**Locations:**
- VPS checkout: `/home/ubuntu/leon337-hermes-operator`
- Notebook launcher: `/home/leo/.local/bin/hermes-remote-client`
- Notebook desktop entry: resolved XDG desktop / `Hermes Agent.desktop`
- Evidence: `docs/evidence/remote-client-v1-acceptance-2026-09-10.md`

- [ ] **Step 1: Verify notebook→VPS preconditions read-only**

Confirm `/home/leo/.ssh/mcf-vps-control.conf` exists and a fail-closed SSH command with the production SSH options can prove `/home/ubuntu/.local/bin/hermes` executable.

- [ ] **Step 2: GitHub authentication gate**

From the VPS, run a read-only `git ls-remote` against `leon337/leon337-hermes-operator`. If private-repository authentication is unavailable, stop at `GITHUB_AUTH_REQUIRED`. **Do not copy the notebook repository, private keys, tokens, or enable SSH agent forwarding without a separate explicit human authorization.**

- [ ] **Step 3: Clone from GitHub only after the auth gate passes**

Clone/fetch the approved Hermes branch directly from GitHub into `/home/ubuntu/leon337-hermes-operator`, verify `origin`, then use an isolated implementation worktree. Never seed it from notebook filesystem state.

- [ ] **Step 4: Deploy derived artifacts to notebook**

Stream only `scripts/hermes-remote-client.sh`, `packaging/linux/hermes-agent-remote.desktop`, and `scripts/deploy-notebook-client.sh` from the VPS checkout to a temporary notebook directory, run deployer, then remove the temporary directory.

- [ ] **Step 5: End-to-end acceptance**

Double-click **Hermes Agent**. Verify a visible notebook terminal opens; process inspection proves `/home/ubuntu/.local/bin/hermes chat` executes on VPS; send benign probe `Responda exatamente HERMES_REMOTE_V1_OK`; verify response; inspect provider/model separately through a sanitized read-only command; close only the client; confirm persistent VPS services remain alive; compare listeners before/after and verify the client created no forwarding listener.

- [ ] **Step 6: Record sanitized evidence and commit**

Evidence must include: canonical runtime VPS; notebook thin client; fixed SSH config/alias; remote command; benign probe PASS/FAIL; no duplicate notebook Hermes; no legacy auto-start; no client-created listener; persistent service safety; live provider/model name only if safely observed. Never store credentials/private conversation content. Commit: `evidence: qualify Hermes Remote Client V1`.

---

### Task 5: Register Hermes Operator in MCF Context Fabric

**Repository:** `leon337/multiagent-collaboration-framework`

**Files:**
- Create: `context/projects/leon337-hermes-operator.yaml`
- Create: `apps/rede-social-agentes/apps/server/src/mcf-context/hermes-operator-registry.test.ts`

- [ ] **Step 1: Create isolated MCF branch/worktree**

Branch `feat/context-register-hermes-operator` from current MCF `main`.

- [ ] **Step 2: Write failing test**

The test must load the registry YAML, validate it with `ContextSchemaValidator`, assert `REGISTERED`, canonical repository, owner, `LIVE_REQUIRED`/`DURABLE`, and resolve all of: `leon337-hermes-operator`, `leon337/leon337-hermes-operator`, `Hermes Operator`, `Hermes Agent`, `Hermes` through `resolveProject`.

- [ ] **Step 3: Run RED**

Run focused Vitest. Expected: FAIL because registry entry does not exist.

- [ ] **Step 4: Create registry entry**

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

- [ ] **Step 5: Verify and commit**

Run focused registry test, existing context-schema validator tests, project-resolver tests, server typecheck, workspace format check and lint. Expected: all exit 0. Commit `context: register Hermes Operator`. Open a separate MCF PR stating explicitly that Git context cannot authorize/prove live Hermes operations.

---

### Task 6: Final reconciliation and safe merge order

**Files:** update `docs/current-state.md` and `.mcf/project-capsule.yaml`; review Hermes PR and MCF PR.

- [ ] **Step 1: Enforce order**

```text
1. Hermes repository tests PASS
2. Remote Client V1 live acceptance PASS
3. Hermes Operator PR merges to main
4. VPS checkout updates from GitHub main
5. MCF registry branch rebases/validates against current MCF main
6. MCF Context Fabric PR merges
7. Live Context Fabric resolution is verified
```

- [ ] **Step 2: Refresh durable state**

After qualification, set capsule snapshot status to `REMOTE_CLIENT_V1_QUALIFIED_CONTEXT_REGISTRATION_IN_PROGRESS`, next action `Complete and verify the MCF Context Fabric registry integration.`, blockers from actual observation, and a fresh real UTC `observed_at`. Update `docs/current-state.md` consistently.

- [ ] **Step 3: Re-run Hermes tests and MCF focused tests**

All must PASS before merge.

- [ ] **Step 4: Final live safety check**

Verify no new Hermes/Qwen/controller/listener was introduced by Remote Client, persistent services remain available, and final report separates durable Git state from live observations.

## Final Definition of Done

- Notebook icon **Hermes Agent** opens a visible terminal running Hermes chat on the VPS.
- No second Hermes runtime exists on notebook due to this work.
- SSH config/target are fixed and cannot be overridden at runtime.
- Both SSH phases are fail-closed and disable forwarding/multiplexing.
- No new client forwarding listener exists.
- Benign end-to-end message succeeds.
- Closing client leaves persistent VPS services running.
- Hermes Operator has valid Capsule/current-state and Context Fabric entrypoints.
- MCF has schema-valid `context/projects/leon337-hermes-operator.yaml` and alias resolution tests.
- Operational state stays `LIVE_REQUIRED` and is never inferred from Git.
