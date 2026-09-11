# Hermes Operator

Repositório canônico privado do projeto **Hermes Operator**.

## Base do produto

O núcleo do produto é o **Hermes Agent oficial da Nous Research**. Este projeto não pretende criar um agente de IA do zero nem manter um agente paralelo por padrão.

A estratégia é configurar e estender o Hermes oficial por profiles, skills, policies, `computer_use` e extensões mínimas. Alterações no core/fork somente serão consideradas após uma lacuna real ser comprovada.

## Autoridade

- Autoridade humana final / HUMAN_GATE: **LEANDRO**
- Framework de execução e governança: **MCF v1.1**

## Estado atual

- Project Intent Package: `ALIGNED`
- Intent Alignment Receipt: `PASS`
- Remote Client V1: **QUALIFIED**
- Runtime Hermes canônico: **VPS**
- Notebook: **thin human client**
- MCF Context Fabric: **REGISTERED**
- Estado operacional do runtime/provider/model/sessão: **LIVE_REQUIRED**
- Workstream `remote-client-v1-context-fabric`: **COMPLETE**

O antigo desenho notebook-local de computer-use permanece como contexto histórico e não define o boundary do Remote Client V1. Mudanças futuras de capacidade ou runtime exigem um novo workstream aprovado por LEANDRO.

## Documentos canônicos

- `docs/current-state.md`
- `.mcf/project-capsule.yaml`
- `docs/superpowers/specs/2026-09-10-hermes-remote-client-context-fabric-design.md`
- `docs/evidence/remote-client-v1-acceptance-2026-09-10.md`
- `docs/governance/project-intent-package.md`
- `docs/governance/intent-alignment-receipt.md`
- `docs/missions/MCF-HERMES-PC-001.md`
- `docs/checkpoints/CP-0001.md`
- `docs/evidence/host-baseline-2026-08-17.md`

## Segurança de repositório

Credenciais, tokens, senhas, códigos de autenticação, screenshots privados e evidências brutas do desktop não devem ser versionados. Somente evidências sanitizadas e necessárias entram no Git.
