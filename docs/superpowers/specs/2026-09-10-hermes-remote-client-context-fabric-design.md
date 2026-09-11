# Hermes Remote Client + MCF Context Fabric — Design

Date: **2026-09-10**  
Project: **Hermes Operator**  
Canonical repository: `leon337/leon337-hermes-operator`  
Human authority / HUMAN_GATE: **LEANDRO**  
Status: **APPROVED DESIGN — IMPLEMENTATION NOT STARTED**

## 1. Objective

Provide LEANDRO with a simple desktop entry on the notebook that opens an interactive conversation with the single canonical Hermes Agent runtime hosted on the VPS.

The notebook is a client only. Hermes Agent, its sessions, tools, provider selection, and the local Qwen provider remain on the VPS.

The first version must not automatically start the legacy mission `MCF-HERMES-PC-002` and must not create a second Hermes installation on the notebook.

## 2. Reconciled current state

The product core remains the official Nous Research Hermes Agent. Hermes Operator extends and governs that upstream product rather than rebuilding it.

Current VPS runtime includes:

- Hermes Agent under `/home/ubuntu/.hermes/hermes-agent`;
- `hermes-controller.service`, currently tied to the legacy resident qualification flow;
- `hermes-provider.service`, serving the local Qwen provider on `127.0.0.1:8080`;
- historical `mcf-hermes-relay`, scoped to old qualification operations rather than generic interactive chat.

The existing `mcf-hermes-relay` is not the transport for Remote Client V1.

## 3. Architectural decision

Remote Client V1 uses the canonical SSH control path from the notebook to the VPS and launches `hermes chat` on the VPS.

```text
NOTEBOOK
  |
  | desktop launcher
  v
Hermes Remote Client
  |
  | canonical SSH transport
  v
VPS
  |
  +--> official Hermes Agent
          |
          +--> configured primary provider
          |
          +--> local Qwen provider on 127.0.0.1:8080 when selected/fallback applies
```

There is exactly one canonical Hermes runtime. No Hermes runtime, model, provider configuration, session store, or agent memory is duplicated onto the notebook.

## 4. User experience

The notebook desktop exposes one entry named **Hermes Agent**.

On launch it must:

1. verify the canonical VPS SSH path is reachable;
2. open a human-visible terminal;
3. start an interactive SSH session that directly executes `hermes chat` on the VPS;
4. leave the user in the Hermes conversation until the terminal is closed or Hermes exits;
5. display a human-readable failure when SSH or the remote Hermes command is unavailable.

Closing the terminal closes only the client connection. It must not stop Hermes services, Qwen, TriView, DSHs, 9Router, SentinelX, Docker, Tailscale, GitHub Runner, or the VPS graphical workstation.

## 5. Transport and security boundary

SSH is the only Remote Client V1 transport.

Requirements:

- reuse the existing canonical SSH configuration and authentication path;
- do not expose Hermes, Qwen `:8080`, controller sockets, or new HTTP/VNC ports to the LAN, Tailscale network, or public internet;
- do not copy provider credentials, OAuth material, model configuration, session state, or Hermes secrets to the notebook;
- do not embed passwords, tokens, OTPs, SSH private-key material, or API keys in launcher files;
- remote execution is limited to the intended interactive Hermes entrypoint;
- the client must fail closed if the canonical SSH target cannot be reached.

## 6. Provider behavior

Remote Client V1 does not implement model routing.

`hermes chat` uses the provider/model configuration already governed by Hermes on the VPS. The client does not force Codex, Qwen, or any particular model.

The local Qwen provider remains VPS-local and is not tunneled to the notebook as part of V1.

Provider status may be shown later by the graphical client, but V1 is only an interactive terminal bridge.

## 7. Legacy mission boundary

`MCF-HERMES-PC-002` is historical runtime state from the resident computer-use qualification effort.

Remote Client V1 must not:

- call the legacy controller `start` operation;
- execute the old `hello_world_gui` relay operation;
- automatically enable `computer_use`;
- restore or resume the failed qualification job;
- treat the legacy controller as the generic Hermes chat interface.

The old services remain untouched by this implementation unless a later, separately approved reconciliation changes their lifecycle.

## 8. Canonical repository and deployment flow

GitHub remains the source of truth.

The implementation belongs in `leon337/leon337-hermes-operator`. The notebook does not become the canonical repository host.

Deployment flow:

```text
GitHub: leon337/leon337-hermes-operator
       |
       | clone/pull
       v
VPS: canonical project checkout
       |
       | produces/defines client contract and remote entrypoint
       v
Notebook: minimal launcher + desktop entry only
```

The implementation plan must define an isolated branch/worktree workflow and verification before any merge or deployment.

## 9. MCF Context Fabric registration

Hermes Operator must be registered as a durable project in the MCF Context Fabric after the repository contains a valid project capsule.

The MCF registry entry will be created at:

`context/projects/leon337-hermes-operator.yaml`

It must conform to `schemas/context/project-registry-entry.schema.json` and contain only schema-supported fields.

Planned registry identity:

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
    - docs/architecture/architecture-decision-package-v1.1.md
    - docs/superpowers/specs/2026-09-10-hermes-remote-client-context-fabric-design.md

freshness:
  operational_state: LIVE_REQUIRED
  project_identity: DURABLE
```

Operational state is `LIVE_REQUIRED`: Context Fabric may recover durable project identity and documentation, but current runtime/provider/session health must be obtained from live observation rather than inferred from repository state.

## 10. Hermes project capsule

The Hermes Operator repository currently needs a Context Fabric project capsule at:

`.mcf/project-capsule.yaml`

It must conform to `schemas/context/project-capsule.schema.json` and use project id `leon337-hermes-operator`.

The capsule will describe the current workstream as Remote Client V1 + Context Fabric integration, record that the VPS remains the canonical runtime, and point `sources.current_state` to a versioned repository document describing current project state.

No live process status, current model availability, authentication state, or transient VPS health may be claimed from the capsule without a live observation.

## 11. Context Fabric boundary

Context Fabric registers and recovers project identity/context. It does not become the transport that carries interactive Hermes chat traffic.

```text
Context Fabric
  -> discovers Hermes Operator
  -> resolves canonical repository / capsule / entrypoints
  -> requires live evidence for operational state

SSH Remote Client
  -> carries the human interactive terminal session
  -> reaches the existing Hermes runtime on the VPS
```

These responsibilities must remain separate.

## 12. V1 components

The implementation will introduce only the minimum components required:

- a repository-owned remote-client launcher script or launcher template;
- tests for target resolution, remote command construction, failure behavior, and absence of embedded secrets;
- a notebook `.desktop` entry deployed from the governed implementation;
- `.mcf/project-capsule.yaml` in Hermes Operator;
- a current-state document referenced by the capsule;
- the MCF `context/projects/leon337-hermes-operator.yaml` registry entry;
- schema validation evidence for capsule and registry entry.

A graphical Hermes client is explicitly deferred to V2.

## 13. Error handling

Remote Client V1 must distinguish at least these failure classes:

- canonical SSH target/config unavailable;
- VPS unreachable;
- authentication failure;
- remote `hermes` executable unavailable;
- `hermes chat` exits with an error;
- local terminal emulator unavailable.

Failures must be visible to LEANDRO in plain language. The launcher must not silently fall back to a different host, direct public port, local Hermes installation, or legacy relay.

## 14. Verification and acceptance

V1 is accepted only when all of the following are verified:

1. the launcher originates from the canonical Hermes Operator implementation;
2. the notebook has no second Hermes Agent installation created by this work;
3. one desktop click opens a visible terminal and reaches the VPS via the canonical SSH path;
4. `hermes chat` is running on the VPS, not the notebook;
5. a normal user message receives a Hermes response;
6. the active provider/model can be observed without exposing credentials;
7. closing the client does not stop persistent VPS services;
8. unavailable SSH produces a clear error and no alternate unsafe path;
9. `.mcf/project-capsule.yaml` validates against the current MCF capsule schema;
10. `context/projects/leon337-hermes-operator.yaml` validates against the current MCF registry-entry schema;
11. Context Fabric resolves Hermes Operator by canonical id and at least the approved aliases;
12. live runtime state remains explicitly separate from durable repository context.

## 15. Non-goals for V1

V1 does not include:

- graphical chat UI;
- notebook-side Hermes installation;
- notebook-side Qwen runtime;
- new public network service;
- replacement of SSH by HTTP/WebSocket/MCP;
- automated startup of `MCF-HERMES-PC-002`;
- redesign of Qwen residency policy;
- removal or shutdown of existing Hermes services;
- model/provider router implementation;
- changes to TriView control.

## 16. V2 direction

After V1 proves the remote interaction boundary, a graphical notebook client may be built on a separately approved interface. V2 may expose status, conversation, mission history, evidence, and provider visibility, but it must preserve the same rule: the VPS hosts the canonical Hermes runtime and the notebook remains a client.

## 17. Governing invariant

**GitHub defines; MCF discovers and governs context; VPS runs Hermes; notebook provides human access.**
