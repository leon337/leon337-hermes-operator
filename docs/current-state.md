# Hermes Operator — Current State

Project ID: `leon337-hermes-operator`  
Canonical repository: `leon337/leon337-hermes-operator`  
Human authority / HUMAN_GATE: **LEANDRO**  
Current workstream: `remote-client-v1-context-fabric`  
Workstream status: **QUALIFIED / COMPLETE**

## Durable deployment boundary

The canonical Hermes Agent runtime remains on the VPS. The notebook is a human client only and reaches Hermes through the fixed canonical SSH control path defined by Remote Client V1.

The earlier notebook-local computer-use MVP remains historical context. It is not the deployment target for this workstream. TriView control is also not the purpose of Remote Client V1.

Remote Client V1 must not auto-start, restore, or resume `MCF-HERMES-PC-002` and must not use the historical relay as the generic Hermes chat transport.

## Operational freshness

Runtime, provider, model, session, authentication, process health, and related VPS operational facts are `LIVE_REQUIRED`. Git records durable project context; it does not prove current runtime health.

## Qualified implementation state

Remote Client V1 Tasks 1–4 are qualified. The live acceptance evidence is recorded in `docs/evidence/remote-client-v1-acceptance-2026-09-10.md` and includes the notebook thin-client deployment, GitHub read-only deploy-key gate, successful `HERMES_REMOTE_V1_OK` probe, service/listener safety checks, and cleanup of the acceptance-run side effect.

The qualified Hermes implementation was merged to `main` at `4fefd6e6593cc74e8f6e7e9ca5a9e506aa3df23c`, and the canonical VPS checkout was verified at that exact commit.

The MCF Context Fabric registration was merged through PR #204 at MCF commit `632921eef5ab6ff8e414a0024fb8f00983442844`. Resolution on merged MCF `main` passed for project id `leon337-hermes-operator`, canonical repository `leon337/leon337-hermes-operator`, and aliases `Hermes Operator`, `Hermes Agent`, and `Hermes`.

The final live safety observation at `2026-09-11T18:32:11Z` found `hermes-provider.service` and `hermes-controller.service` active with activation timestamps predating this workstream, provider listener `127.0.0.1:8080` local-only, existing TriView/relay listeners local-only, no residual interactive `hermes chat` process, and the acceptance probe side-effect file absent. These are dated observations only and do not replace the `LIVE_REQUIRED` rule.

The dated Remote Client acceptance observed model `qwen3.5-2b`; that observation is evidence only and does not establish current provider/model truth.

## Next action

No further action is required inside the `remote-client-v1-context-fabric` workstream. Any subsequent Hermes Operator capability or runtime change requires a separately approved workstream and fresh live-state validation.

## Governing invariant

**GitHub defines; MCF discovers and governs context; VPS runs Hermes; notebook provides human access.**
