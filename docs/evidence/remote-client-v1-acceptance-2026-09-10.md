# Remote Client V1 — Live Acceptance Evidence

Execution date: 2026-09-11 UTC  
Branch: `feat/hermes-remote-client-v1`  
Qualified implementation HEAD before evidence commit: `82177d45c4eff6bee524956d32e1d2a69f312376`

## Result

**REMOTE_CLIENT_V1_ACCEPTANCE: PASS**

## Verified live boundary

- Canonical Hermes runtime: VPS `/home/ubuntu/.hermes/hermes-agent`.
- Notebook role: thin human client only.
- Production client uses exactly `/home/leo/.ssh/mcf-vps-control.conf`, target `mcf-vps-control`, and `/home/ubuntu/.local/bin/hermes chat`.
- SSH client options observed from the repository contract: `BatchMode=yes`, `ConnectTimeout=8`, `ClearAllForwardings=yes`, `ControlMaster=no`, `ControlPath=none`.
- Private repository access on VPS was enabled with a repository-specific read-only deploy key. No notebook private key or general-purpose token was copied to the VPS.
- VPS checkout was cloned directly from GitHub into `/home/ubuntu/leon337-hermes-operator` and pinned to the approved implementation HEAD for qualification.

## Acceptance probes

- Repository tests on the VPS: PASS for context contract, fixed SSH client contract, and notebook deployment contract.
- Notebook deployment: PASS; installed `/home/leo/.local/bin/hermes-remote-client` and `Hermes Agent.desktop` in the resolved notebook desktop directory.
- Notebook→VPS preflight: `HERMES_REMOTE_PREFLIGHT_PASS`.
- Interactive Hermes chat opened successfully on the VPS.
- Benign probe: `Responda exatamente HERMES_REMOTE_V1_OK`.
- Recorded assistant response: `HERMES_REMOTE_V1_OK`.
- Live model name observed during this acceptance run: `qwen3.5-2b`. This is `LIVE_REQUIRED` operational state, not durable Git truth.

## Safety checks

- No Hermes runtime process was present on the notebook after the client was closed.
- The acceptance chat process on the VPS was terminated without stopping persistent services.
- `hermes-provider.service` and `hermes-controller.service` remained active after client closure; both had been active since 2026-09-08 05:14:57 -03, predating this acceptance run, so Remote Client V1 did not auto-start them.
- Provider listener remained local-only at `127.0.0.1:8080`.
- Existing TriView/relay listeners remained local-only at `127.0.0.1:9221`, `:9222`, `:9223`, and `:17600`.
- No LocalForward, RemoteForward, DynamicForward, public listener, or Tailscale listener was introduced by the client.
- No legacy relay was used as the generic Hermes chat transport.

## Acceptance-run cleanup note

During the benign probe, Hermes invoked a tool and created `/home/ubuntu/responda_exatamente_hermes_remote_v1_ok.py` before returning the requested exact response. That file was an unintended probe side effect and was removed immediately after verification. This does not change the Remote Client transport qualification, but it is retained here as behavioral evidence for future Hermes policy/tool-governance work.

## Gate

Task 4 is qualified. Next safe order: refresh durable project state, run final repository tests, merge the Hermes implementation to `main`, update the VPS checkout from GitHub `main`, then proceed with the separate MCF Context Fabric registry change.
