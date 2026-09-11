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

## Current implementation scope

Tasks 1–3 implement repository-native durable context, the fixed SSH notebook client, and deterministic notebook deployment artifacts. Live VPS qualification, deployment into runtime, MCF registry changes, and Task 4+ remain outside this implementation scope.

## Governing invariant

**GitHub defines; MCF discovers and governs context; VPS runs Hermes; notebook provides human access.**
