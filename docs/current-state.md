# Hermes Operator — Current State

Project ID: `leon337-hermes-operator`  
Canonical repository: `leon337/leon337-hermes-operator`  
Human authority / HUMAN_GATE: **LEANDRO**  
Current workstream: `remote-client-v1-context-fabric`

## Durable deployment boundary

The canonical Hermes Agent runtime remains on the VPS. The notebook is a human client only and reaches Hermes through the fixed canonical SSH control path defined by Remote Client V1.

The earlier notebook-local computer-use MVP remains historical context. It is not the deployment target for this workstream. TriView control is also not the purpose of Remote Client V1.

Remote Client V1 must not auto-start, restore, or resume `MCF-HERMES-PC-002` and must not use the historical relay as the generic Hermes chat transport.

## Operational freshness

Runtime, provider, model, session, authentication, process health, and related VPS operational facts are `LIVE_REQUIRED`. Git records durable project context; it does not prove current runtime health.

## Qualified implementation state

Remote Client V1 Tasks 1–4 are qualified. The live acceptance evidence is recorded in `docs/evidence/remote-client-v1-acceptance-2026-09-10.md` and includes the notebook thin-client deployment, GitHub read-only deploy-key gate, successful `HERMES_REMOTE_V1_OK` probe, service/listener safety checks, and cleanup of the acceptance-run side effect.

The dated acceptance run observed model `qwen3.5-2b`; that observation is evidence only and does not replace the `LIVE_REQUIRED` rule.

The next governed sequence is: merge the qualified Hermes implementation to `main`, update the VPS checkout from GitHub `main`, then complete and verify the separate MCF Context Fabric registry integration.

## Governing invariant

**GitHub defines; MCF discovers and governs context; VPS runs Hermes; notebook provides human access.**
