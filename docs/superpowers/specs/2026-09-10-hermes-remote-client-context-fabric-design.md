# Hermes Remote Client + MCF Context Fabric — Design

Date: **2026-09-10**  
Project: **Hermes Operator**  
Canonical repository: `leon337/leon337-hermes-operator`  
Human authority / HUMAN_GATE: **LEANDRO**  
Status: **APPROVED DESIGN — SOFIA REVIEW RECONCILED — IMPLEMENTATION NOT STARTED**

## 1. Objective

Provide LEANDRO with a simple desktop entry on the notebook that opens an interactive conversation with the single canonical Hermes Agent runtime hosted on the VPS.

The notebook is a client only. Hermes Agent, its sessions, tools, provider selection, model state, and agent memory remain on the VPS. Remote Client V1 must not automatically start the legacy mission `MCF-HERMES-PC-002` and must not create a second Hermes installation on the notebook.

## 2. Operational snapshot — not durable truth

The following facts are a **live observation snapshot**, not durable project truth and not proof of future health.

Observed at: `2026-09-11T02:52:32Z`  
Provenance: live read-only inspection of the VPS initiated through the canonical notebook-to-VPS SSH control path.

Observed values:

- `/home/ubuntu/.local/bin/hermes`: `PRESENT`;
- `hermes-controller.service`: `inactive`;
- `hermes-provider.service`: `inactive`;
- TCP listener on VPS `:8080`: `PRESENT`.

These observations may become stale immediately. They must not be promoted to current truth from Git, a Capsule, or this document. Provider ownership, process health, current model, authentication state, and session state are `LIVE_REQUIRED` and require fresh observation when an operation depends on them.

The historical `mcf-hermes-relay` belongs to the old qualification workstream and is not the transport for Remote Client V1.

### 2.1 Decision precedence and reconciliation with August architecture

The August 2026 Project Intent Package and Architecture v1.1 established the original computer-use MVP as local to LEANDRO's notebook. The human decision of 2026-09-10 changes only the **current deployment boundary** for the Remote Client workstream:

- canonical Hermes runtime remains on the VPS;
- notebook becomes a human client for Hermes;
- the previous notebook-local computer-use MVP remains historical context, not the Remote Client V1 deployment target;
- the official Hermes Agent remains the product core; no parallel agent or fork is created by default.

For current-state recovery, this design plus `docs/current-state.md` take precedence over older deployment-location statements. Historical documents are not rewritten to erase the earlier decision.

## 3. Architectural decision

Remote Client V1 uses only the canonical SSH control path from the notebook to the VPS and launches `/home/ubuntu/.local/bin/hermes chat` on the VPS.

```text
NOTEBOOK
  |
  | desktop launcher
  v
Hermes Remote Client
  |
  | canonical SSH transport only
  v
VPS
  |
  +--> official Hermes Agent runtime
          |
          +--> provider/model routing remains VPS-side
```

There is exactly one canonical Hermes runtime. No Hermes runtime, model, provider configuration, session store, or agent memory is duplicated onto the notebook.

## 4. User experience

The notebook desktop exposes one entry named **Hermes Agent**.

On launch it must:

1. verify the fixed canonical VPS SSH path is reachable;
2. open a human-visible terminal;
3. start an interactive SSH session that directly executes `/home/ubuntu/.local/bin/hermes chat` on the VPS;
4. leave LEANDRO in the Hermes conversation until the terminal is closed or Hermes exits;
5. display a human-readable failure when the SSH path or remote Hermes command is unavailable.

Closing the terminal closes only the client connection. It must not stop Hermes-related persistent services, Qwen, TriView, DSHs, 9Router, SentinelX, Docker, Tailscale, GitHub Runner, or the VPS graphical workstation.

## 5. Canonical SSH and security boundary

SSH is the only Remote Client V1 transport.

The production launcher has two immutable connection identities:

```text
SSH config: /home/leo/.ssh/mcf-vps-control.conf
SSH target: mcf-vps-control
```

Remote Client V1 must not expose runtime configuration, environment variables, command-line flags, or fallback logic that can replace either value.

Both the preflight connection and the interactive `hermes chat` connection must apply the same fail-closed policy:

- `BatchMode=yes`;
- `ConnectTimeout=8`;
- `ClearAllForwardings=yes`;
- connection multiplexing disabled for this client (`ControlMaster=no` and `ControlPath=none`) so the client does not create or depend on a multiplexed control connection;
- no `LocalForward`, `RemoteForward`, or `DynamicForward` opened by the Remote Client, even if the canonical SSH profile contains forwarding directives;
- no password/token/OTP/private-key material embedded in launcher files;
- no alternate direct IP, alternate host, local Hermes fallback, legacy relay fallback, HTTP/WebSocket/VNC transport, or public/Tailscale listener.

The client reuses the notebook's existing authorized SSH authentication path. It must not copy authentication material to the VPS or repository.

## 6. Provider behavior

Remote Client V1 does not implement model routing and does not assert which provider is live.

`hermes chat` uses whatever provider/model configuration is valid on the VPS at execution time. Current provider/model identity is `LIVE_REQUIRED` and may be observed separately without exposing credentials.

No model endpoint is tunneled to the notebook as part of V1.

## 7. Legacy mission boundary

`MCF-HERMES-PC-002` is historical runtime state from the resident computer-use qualification effort.

Remote Client V1 must not:

- call the legacy controller `start` operation;
- execute the old `hello_world_gui` relay operation;
- automatically enable `computer_use`;
- restore or resume the failed qualification job;
- treat the legacy controller or relay as the generic Hermes chat interface.

Existing legacy services are not removed or redesigned by this workstream.

## 8. Canonical repository and deployment flow

GitHub remains the source of truth.

The implementation belongs in `leon337/leon337-hermes-operator`. The notebook does not become the canonical repository host.

```text
GitHub: leon337/leon337-hermes-operator
       |
       | clone/pull
       v
VPS: canonical project checkout
       |
       | source/tests/deployment package
       v
Notebook: derived launcher + desktop entry only
```

Implementation must use an isolated branch/worktree, tests before deployment, and commits before a runtime copy is treated as canonical.

## 9. MCF Context Fabric registration

Hermes Operator must be registered as a durable project in the MCF Context Fabric only after the Hermes repository contains a valid capsule and referenced entrypoints on its canonical branch.

MCF path:

`context/projects/leon337-hermes-operator.yaml`

Registry contract:

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

Context Fabric recovers identity and durable context. It is not the transport for interactive Hermes chat and must not infer current runtime/provider/session health from Git.

## 10. Hermes project capsule

Hermes Operator must contain `.mcf/project-capsule.yaml`, valid against the current MCF `project-capsule` schema, with `project_id: leon337-hermes-operator`.

The capsule records the current Remote Client V1 + Context Fabric workstream, a concrete observation timestamp, actual blockers observed at materialization time, and `sources.current_state: docs/current-state.md`.

It must not encode transient provider health, current model, authentication state, process health, or session health as durable truth.

## 11. Current-state document

Implementation creates `docs/current-state.md` as the durable human-readable reconciliation point. It must state:

- original computer-use objective remains historical context;
- TriView control is no longer the reason for Remote Client V1;
- current deployment boundary is VPS runtime + notebook client;
- `MCF-HERMES-PC-002` is not auto-resumed;
- provider/model/runtime health is `LIVE_REQUIRED`;
- live facts are observations, not durable Git truth.

## 12. Context Fabric boundary

```text
Context Fabric
  -> discovers Hermes Operator
  -> resolves canonical repository / capsule / entrypoints
  -> requires live evidence for operational state

SSH Remote Client
  -> carries the human interactive terminal session
  -> reaches the Hermes runtime on the VPS
```

These responsibilities remain separate.

## 13. V1 components and exact ownership

Repository-owned implementation artifacts use exactly these paths:

- `scripts/hermes-remote-client.sh` — notebook-side launcher logic and fixed canonical SSH invocation;
- `packaging/linux/hermes-agent-remote.desktop` — versioned desktop-entry template;
- `scripts/deploy-notebook-client.sh` — deterministic deployment of derived client artifacts;
- `tests/test-hermes-remote-client.sh` — launcher/security contract tests;
- `tests/test-notebook-deployment.sh` — deployment contract tests;
- `tests/test-context-contract.sh` — Capsule/current-state contract test;
- `.mcf/project-capsule.yaml` — Hermes Operator Context Fabric capsule;
- `docs/current-state.md` — durable current-state reconciliation document.

MCF-owned integration artifacts:

- `context/projects/leon337-hermes-operator.yaml`;
- focused Context Fabric test for validation and alias resolution.

Notebook deployment artifacts are derived copies only:

- `/home/leo/.local/bin/hermes-remote-client`;
- `Hermes Agent.desktop` in the notebook desktop directory resolved by XDG, with `/home/leo/Área de trabalho` as the current expected desktop path.

A graphical Hermes client is deferred to V2.

## 14. Error handling

Remote Client V1 must distinguish and report at least:

- canonical SSH config missing;
- VPS unreachable or SSH authentication unavailable;
- remote Hermes executable unavailable;
- `hermes chat` exits with an error;
- local terminal/desktop-launch failure at deployment/use time.

The launcher must fail closed and must not silently use another host, another SSH config, direct public access, local Hermes, or the legacy relay.

## 15. Verification and acceptance

V1 is accepted only when all are verified:

1. launcher originates from the canonical Hermes Operator implementation;
2. notebook has no second Hermes Agent installation created by this work;
3. one desktop click opens a visible terminal and reaches the VPS using exactly `/home/leo/.ssh/mcf-vps-control.conf` + `mcf-vps-control`;
4. both preflight and chat connections use the same fail-closed SSH policy and `ClearAllForwardings=yes`;
5. no Remote Client forwarding listener is created;
6. `/home/ubuntu/.local/bin/hermes chat` runs on the VPS, not notebook;
7. a benign user message receives a Hermes response;
8. provider/model may be observed live without exposing credentials;
9. closing the client does not stop persistent VPS services;
10. canonical SSH failure is clear and has no alternate path;
11. `.mcf/project-capsule.yaml` validates against current MCF capsule schema;
12. `context/projects/leon337-hermes-operator.yaml` validates against current registry-entry schema;
13. Context Fabric resolves canonical id/repository and aliases `Hermes Operator`, `Hermes Agent`, `Hermes`;
14. operational state remains `LIVE_REQUIRED` and is not inferred from Git;
15. `docs/current-state.md` reconciles the old notebook-local deployment statement versus the VPS-runtime decision;
16. all production artifact paths match Section 13 exactly.

## 16. Non-goals for V1

V1 does not include:

- graphical chat UI;
- notebook-side Hermes installation;
- notebook-side model runtime;
- new public or Tailscale network service;
- HTTP/WebSocket/MCP transport;
- automated startup of `MCF-HERMES-PC-002`;
- redesign of model residency policy;
- removal/shutdown of existing Hermes services;
- model/provider router implementation;
- changes to TriView control.

## 17. V2 direction

After V1 proves the remote interaction boundary, a separately approved graphical notebook client may expose status, conversation, mission history, evidence, and provider visibility while preserving the same invariant: VPS hosts the canonical Hermes runtime; notebook remains a client.

## 18. Governing invariant

**GitHub defines; MCF discovers and governs context; VPS runs Hermes; notebook provides human access.**
