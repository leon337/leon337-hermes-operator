# Architectural Decisions AD-10 to AD-15 — Inference Resilience

Date: **2026-08-19**  
Status: **APPROVED BY LEANDRO / CANONICAL**  
Applies to: `MCF-HERMES-PC-001`

## AD-10 — Inference Resilience

Hermes Operator não dependerá arquiteturalmente de um único modelo, provider, endpoint ou credential.

A implementação inicial deve priorizar mecanismos nativos do Hermes Agent oficial antes de qualquer router próprio.

Mecanismos upstream considerados parte do envelope:

1. Credential Pools;
2. Provider Routing, quando suportado pelo provider agregador;
3. Fallback Providers;
4. Auxiliary Task Fallback.

Um roteador próprio só poderá ser considerado se um gap real e reproduzido permanecer após configuração e validação dessas capacidades.

## AD-11 — Credential Pool First

Quando houver múltiplas credenciais legitimamente autorizadas para o mesmo provider, o Hermes deve preferir a rotação nativa de credenciais antes de trocar para outro provider/modelo.

Regras:

- somente credenciais pertencentes a contas/recursos autorizados por LEANDRO;
- não usar pools para contornar termos, quotas contratuais ou controles do provider;
- rate limit, quota, billing/auth failure devem seguir o comportamento nativo suportado;
- se todas as credenciais elegíveis estiverem indisponíveis, pode-se avançar para fallback cross-provider conforme política.

## AD-12 — Cross-provider Fallback

O Hermes Operator deve permitir uma cadeia ordenada de `provider:model` previamente autorizados para continuidade de missão.

Conceito:

```text
PRIMARY
  -> Fallback 1
  -> Fallback 2
  -> ...
  -> WAITING / HUMAN_GATE
```

Fallback automático é permitido apenas entre recursos já autorizados e dentro da política de custo.

Não é permitido iniciar espontaneamente um provider pago novo ou contratar serviço adicional.

## AD-13 — Capability-aware Fallback

Um modelo substituto só pode assumir uma etapa quando possuir as capacidades necessárias para aquela etapa.

A política deve considerar, conforme o caso:

- tool calling;
- visão/entrada de imagem;
- contexto suficiente;
- parâmetros requeridos;
- compatibilidade com o fluxo de `computer_use`;
- qualidade mínima para compreensão/verificação;
- requisitos de privacidade e dados.

`provider_routing.require_parameters` e recursos semelhantes são sinais úteis, mas não substituem a política de capacidades do Hermes Operator.

Quando nenhuma alternativa compatível existir, a missão deve parar em estado seguro e preservado.

## AD-14 — Failover Requires Re-observation

Troca de modelo/provider nunca autoriza replay cego de ação física.

Após qualquer failover durante uma missão GUI:

```text
preservar checkpoint
      ->
não iniciar nova ação GUI
      ->
reobservar o desktop
      ->
reconciliar estado real x checkpoint
      ->
continuar somente de ponto seguro
```

Exemplo: se o modelo anterior enviou uma mensagem antes de falhar, o modelo substituto deve confirmar visualmente o estado antes de considerar reenviar.

Esta decisão conecta diretamente Inference Resilience, Evidence Layer e Operational Checkpoint.

## AD-15 — Cost-aware Fallback

Resiliência não pode criar custo novo sem autorização humana.

Tiers conceituais:

```text
TIER 0
recurso sem novo custo
já autorizado

TIER 1
outro recurso sem novo custo
já autorizado

TIER 2
self-hosted / VPS
quando disponível e adequado

PAID FALLBACK
HUMAN_GATE LEANDRO
```

A ordem final de providers/modelos será configurada posteriormente com base em capacidade, disponibilidade, custo, privacidade e limites reais.

## Upstream evidence baseline

A release estável `v2026.8.16` do Hermes documenta:

- Credential Pools com rotação e recuperação de rate limit;
- Fallback Providers com failover cross-provider;
- gatilho de fallback para HTTP 429 após retries aplicáveis;
- preservação de histórico/contexto durante troca de provider/modelo;
- Provider Routing para OpenRouter/Nous Portal;
- fallbacks independentes para tarefas auxiliares.

Esses mecanismos devem ser validados na instalação real antes de qualquer extensão própria.

## Non-goals of this decision set

AD-10 a AD-15 não autorizam:

- criar Model Gateway agora;
- criar router próprio agora;
- adicionar credenciais;
- cadastrar providers;
- gerar custos;
- alterar `config.yaml` no host;
- instalar Hermes;
- executar missão física.
