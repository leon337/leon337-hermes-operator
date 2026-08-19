# Capability + Deployment Matrix v1 — Hermes Operator

Date: **2026-08-19**  
Status: **CANONICAL**  
Mission: `MCF-HERMES-PC-001`

## Classification

- `EXISTS`: capability exists upstream.
- `NEEDS_CONFIGURATION`: upstream exists but requires explicit configuration/policy.
- `NEEDS_EXTENSION`: upstream foundation exists, but Hermes Operator needs a small product-specific layer.
- `PARTIALLY_EXISTS`: some semantics exist but do not yet satisfy the PIP completely.
- `UNPROVEN`: requires physical/runtime validation.
- `BLOCKED`: cannot proceed safely without a dependency or human gate.

## Matrix

| Requirement | Upstream / current capability | Classification | Primary location | Validation / next proof |
|---|---|---|---|---|
| GUI desktop control | `computer_use` + `cua-driver` | `EXISTS` | Local | Physical validation on Linux Mint/X11 |
| Brave discovery/control | Linux app/window targeting; Brave installed at `/usr/bin/brave-browser` | `EXISTS / UNPROVEN` | Local | Validate capture, focus and input |
| Existing authenticated ChatGPT session | Existing-profile grant exists upstream | `NEEDS_CONFIGURATION` | Local | Explicit grant + safe attach validation |
| Foreground-visible operation | `delivery_mode=foreground`, optional bring-to-front | `NEEDS_CONFIGURATION` | Local | Prove visible behavior in Brave/Xed |
| Read long response with controlled scroll | capture + scroll + verification | `EXISTS / UNPROVEN` | Local | Validate full-response visual reading |
| Detect ChatGPT generation complete | no product-specific detector proven | `UNPROVEN` | Local policy | Define behavior and test against real ChatGPT |
| Semantic understanding/evaluation | model reasoning | `EXISTS VIA MODEL` | Runtime/provider | Validate chosen model quality |
| Xed operation | generic GUI actions; Xed installed | `UNPROVEN` | Local | Physical typing/save/readback test |
| Session persistence | Hermes session/state | `EXISTS` | Local/runtime | Verify expected resume behavior |
| Operator checkpoint | session persistence alone is insufficient | `NEEDS_EXTENSION` | Local product layer | Define schema and recovery semantics |
| Observer telemetry | session/model/tool lifecycle hooks | `EXISTS` | Hermes upstream | Validate events in installed release |
| Evidence package | screenshots + telemetry foundation | `NEEDS_EXTENSION` | Local product layer | Build minimal evidence organizer later |
| Soft Stop | Hermes Desktop/runtime cancel | `PARTIALLY_EXISTS` | Hermes upstream | Test normal interruption semantics |
| Hard Emergency Stop | no complete PIP-level latch proven | `NEEDS_EXTENSION / UNPROVEN` | Local product layer | Design + physical test before acceptance |
| Watchdog / no-progress handling | general waits/retries exist; PIP policy is specific | `NEEDS_CONFIGURATION / EXTENSION` | Operator policy | Validate ~60s diagnosis behavior |
| Safe self-correction | Hermes reasoning + GUI verification | `NEEDS_CONFIGURATION` | Operator policy | Test local reversible failures |
| Autostart after graphical login | final mechanism not yet selected | `UNPROVEN` | Local | Inspect official Linux option before implementing |
| Provider/model plugability | multiple providers/custom endpoints | `EXISTS` | Runtime/provider | Select configuration at later gate |
| Credential rotation | Credential Pools | `EXISTS` | Hermes upstream | Configure only with authorized credentials |
| Cross-provider failover | Fallback Providers | `EXISTS` | Hermes upstream | Validate HTTP 429/failure behavior |
| Provider routing | OpenRouter/Nous routing preferences | `EXISTS` | Provider layer | Use only when selected provider supports it |
| Auxiliary task fallback | task-specific fallback chains | `EXISTS` | Hermes upstream | Verify vision/compression routes |
| Capability-aware failover | generic fallback does not fully encode Operator mission requirements | `NEEDS_CONFIGURATION / EXTENSION` | Operator policy | Define compatibility criteria per mission step |
| Cost-aware failover | Hermes can route/fallback; Operator cost policy is project-specific | `NEEDS_CONFIGURATION` | Operator policy | Enforce authorized tiers and HUMAN_GATE for new spend |
| Reobserve after model failover | not an upstream GUI mission guarantee | `NEEDS_EXTENSION / POLICY` | Operator checkpoint/policy | Mandatory before any new physical action |
| Cloud Model Gateway | planned in `cloud-infrastructure` | `UNPROVEN / FUTURE` | VPS | Not required for Hello World v1 |
| Central observability/workflows | planned cloud capabilities | `FUTURE` | VPS | Integrate after local MVP value is proven |
| Cross-machine GUI bridge | no current requirement/proof | `UNPROVEN / FUTURE` | Hybrid | Do not implement for Hello World v1 |

## Deployment summary

### Local — required for MVP

```text
Hermes Agent / Hermes Desktop
Operator Profile / Policy
computer_use / cua-driver
Brave
Xed
Operational Checkpoint
Evidence Layer
Hard Emergency Stop future implementation
```

### Provider / inference — plugable

```text
Primary provider:model
  -> authorized credential pool
  -> provider routing when applicable
  -> authorized fallback provider:model
  -> WAITING / HUMAN_GATE if no safe valid route
```

### VPS — future / non-blocking for Hello World

```text
Model Gateway
central observability
durable workflows
storage/backup
shared services
self-hosted models
other executors/agents
```

## Critical rules

1. GUI mutation must remain local to the physical desktop in the initial MVP.
2. API/backend/DOM routes cannot substitute the first GUI acceptance test.
3. Fallback model/provider does not authorize replay of a previous GUI mutation.
4. After failover, checkpoint + fresh GUI observation are mandatory before continuing.
5. Paid fallback or a new billing path requires LEANDRO HUMAN_GATE.
6. NVIDIA changes are not a dependency of the initial architecture.
7. No fork or core modification is justified by this matrix at this time.

## Physical unknowns carried forward

- `cua-driver` behavior on the exact X11/XFCE host;
- Brave signed-in profile attach;
- foreground action reliability;
- Xed synthetic input;
- visual end-of-generation detection in ChatGPT;
- Hard Emergency Stop timing and blocking semantics;
- actual RAM/performance envelope;
- provider/model quality and quota behavior;
- failover during a live GUI mission;
- autostart after graphical login.
