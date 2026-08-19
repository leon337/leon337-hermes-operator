# Hermes Operator ↔ Cloud Infrastructure Boundary

Date: **2026-08-19**  
Status: **CANONICAL**  
Related repositories:

- Hermes Operator: `leon337/leon337-hermes-operator`
- Cloud Infrastructure: `leon337/cloud-infrastructure`

## Purpose

Definir a fronteira entre o produto Hermes Operator e a infraestrutura cloud sem duplicar responsabilidades e sem transformar a VPS em dependência do primeiro Hello World.

## Hermes Operator owns

- PIP e decisões específicas do produto;
- Operator Profile / Policy;
- regras de GUI e comportamento humano observável;
- integração local com `computer_use` / `cua-driver`;
- Hard Emergency Stop;
- Operational Checkpoint específico de missão GUI;
- Evidence Layer específica do produto;
- critérios de aceitação Hello World;
- matriz de capacidades e deployment do operador;
- validação física no computador de LEANDRO.

## Cloud Infrastructure owns

Quando implementadas e aprovadas naquele projeto, a plataforma cloud poderá fornecer:

- compute compartilhado;
- Model Gateway;
- workflows duráveis;
- observabilidade central;
- armazenamento e backup;
- rede e isolamento;
- secrets infrastructure;
- serviços compartilhados;
- executores/agentes headless;
- modelos self-hosted;
- adapters para Hermes/Codex/outros executores.

## MVP boundary

O primeiro Hello World deve continuar possível com a camada operacional local, sem depender da disponibilidade da VPS, salvo quando o provider de inferência escolhido estiver hospedado nela.

```text
LINUX MINT DE LEANDRO

Hermes Agent / Desktop
Operator Policy
computer_use / cua-driver
Brave
Xed
checkpoint/evidência local
Hard E-Stop futuro
```

A VPS não executa o clique no desktop físico de LEANDRO no MVP.

## Future hybrid topology

Arquitetura futura possível:

```text
                  HERMES OPERATOR
                       |
              +--------+--------+
              |                 |
              v                 v
       LOCAL GUI RUNTIME     CLOUD SERVICES
              |                 |
              |          Model Gateway
              |          Observability
              |          Workflows
              |          Storage
              |          Self-hosted models
              |                 |
              +--------+--------+
                       |
                  secure bridge
```

Qualquer bridge cloud ↔ local deve ser explícita, autenticada, observável e fail-closed. Ela não é requisito do Hello World inicial.

## Inference relationship

No MVP, o Hermes deve primeiro reutilizar suas capacidades nativas de resiliência:

- Credential Pools;
- Provider Routing;
- Fallback Providers;
- Auxiliary Fallback.

O Model Gateway da Cloud Infrastructure é evolução posterior para centralizar políticas, quotas, providers, orçamento e self-hosted inference quando houver benefício comprovado.

Não criar gateway duplicado dentro do repositório Hermes Operator.

## Repository rule

Não copiar para `leon337-hermes-operator` componentes pertencentes à plataforma cloud, como stacks de deployment, redes, secrets management ou serviços genéricos, salvo quando um pequeno adapter específico do produto for necessário e sua fronteira estiver documentada.

Da mesma forma, não mover políticas específicas do Hermes Operator para `cloud-infrastructure` apenas por serem executadas na VPS.

## Failure boundary

Se a VPS ficar indisponível:

- o runtime GUI local deve permanecer seguro;
- nenhuma ação física deve ser repetida cegamente;
- checkpoint/evidência devem permitir retomada posterior;
- se o provider ativo dependia da VPS e não houver fallback autorizado, a missão entra em `WAITING` em vez de improvisar outro recurso pago.

## Current decision

- Cloud Infrastructure: **formal architectural dependency for future capabilities**.
- Cloud Infrastructure: **not a hard dependency for Hello World v1**.
- Model Gateway: **future candidate, not current implementation requirement**.
- Cross-machine GUI control: **UNPROVEN / not part of MVP**.
