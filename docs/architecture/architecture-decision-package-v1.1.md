# Architecture Decision Package v1.1 — Hermes Operator

Date: **2026-08-19**  
Mission: `MCF-HERMES-PC-001`  
Human authority / HUMAN_GATE: **LEANDRO**  
Status: **APPROVED BY LEANDRO / CANONICAL**  
Implementation: **NOT STARTED**  
Host modification: **NOT AUTHORIZED**

## 1. Architectural objective

Transformar o **Hermes Agent oficial da Nous Research** no operador de computador definido pelo PIP alinhado, usando configuração, profile, skills, policies, hooks e extensões mínimas antes de considerar qualquer alteração do core.

A arquitetura não cria um agente paralelo e não trata `project-memory` como produto-base.

## 2. Core decision

O **Hermes Agent oficial** permanece responsável por:

- agent loop e raciocínio;
- tool calling;
- sessões e memória upstream;
- Hermes Desktop;
- approvals;
- `computer_use`;
- `cua-driver`;
- captura e ações GUI;
- providers/modelos;
- observabilidade upstream.

O Hermes Operator adiciona somente capacidades que o PIP exige e que não estão completas como produto:

1. Operator Profile / Policy;
2. Evidence Layer;
3. Operational Checkpoint;
4. Hard Emergency Stop;
5. Inference Resilience Policy Envelope.

O item 5 deve **reutilizar primeiro** mecanismos nativos do Hermes; não autoriza a criação de um roteador de modelos próprio.

## 3. Candidate architecture

```text
              LEANDRO
                 |
                 v
        HERMES DESKTOP
                 |
                 v
      HERMES AGENT OFICIAL
                 |
        OPERATOR PROFILE
                 |
      +----------+----------+
      |                     |
      v                     v
OPERATOR POLICY       EVIDENCE LAYER
      |                     |
      |                CHECKPOINT
      |                FAILURE BUNDLE
      |
      v
INFERENCE RESILIENCE
      |
      +-- Credential Pools
      +-- Provider Routing
      +-- Fallback Providers
      +-- Capability Policy
      +-- Cost Policy
      |
      v
  MODELO DISPONIVEL
      |
      v
  COMPUTER_USE
      |
      v
   CUA-DRIVER
      |
      v
 LINUX MINT / X11
      |
   +--+--+
   |     |
   v     v
 BRAVE  XED
```

## 4. Operator Profile / Policy

Responsabilidades:

- respeitar escopo da missão;
- foreground deliberado nos três runs de aceitação inicial;
- ação → observação → verificação;
- não repetir cegamente ação no mesmo estado;
- watchdog de progresso;
- recuperação segura de falhas reversíveis;
- HUMAN_GATE quando risco/incerteza exigir;
- leitura visual completa de respostas;
- não usar API/backend/DOM como substituto do primeiro teste GUI;
- produzir relatório em palavras próprias;
- aplicar política de autenticação e dados sensíveis.

A skill upstream de `computer_use` é background-first, mas suporta foreground. Para o primeiro MVP, a política do Hermes Operator exige foreground deliberado como comportamento de validação.

## 5. Evidence Layer

A Evidence Layer deve consumir observabilidade upstream e organizar evidências no contrato do PIP, sem duplicar o runtime de telemetria do Hermes.

Estrutura conceitual:

```text
hello-world/
  run-01/
  run-02/
  run-03/
```

Cada run deverá preservar, quando aplicável:

- missão e identificação do run;
- eventos correlacionáveis;
- screenshots necessários;
- checkpoints;
- relatório final;
- failure bundle em caso de falha controlada.

Princípio: **registrar o necessário, não tudo o que for possível**. Credenciais, tokens, 2FA, senhas e dados privados irrelevantes não devem ser versionados.

## 6. Operational Checkpoint

O checkpoint operacional é distinto da persistência normal de sessão do Hermes.

Deve registrar pelo menos:

- missão;
- run;
- etapa atual;
- estado esperado;
- último estado observado;
- última ação confirmada;
- erro/recuperação pendentes;
- HUMAN_GATE pendente;
- condição segura de retomada.

Retomada nunca autoriza replay cego. O fluxo obrigatório é:

```text
carregar checkpoint
      ->
reobservar a GUI
      ->
comparar realidade x checkpoint
      ->
continuar somente de ponto seguro
```

## 7. Emergency Stop

Dois níveis são reconhecidos:

### Soft Stop

Responsabilidade do Hermes oficial. Usado para cancelamento normal de uma execução.

### Hard Emergency Stop

Responsabilidade do Hermes Operator. Deve garantir:

```text
E-STOP acionado
      ->
latch = STOPPED
      ->
nenhuma NOVA ação GUI do agente
      ->
missão = INTERRUPTED
      ->
estado/evidência preservados
      ->
sem retomada autônoma
      ->
somente LEANDRO libera retomada
```

O mecanismo exato permanece `UNPROVEN` até teste físico. Não há autorização atual para implementá-lo.

## 8. Inference Resilience

Resiliência de inferência é requisito arquitetural de primeira classe.

O Hermes Operator não deve depender conceitualmente de um único:

- modelo;
- provider;
- endpoint;
- credential.

A ordem preferencial é reutilizar capacidades nativas da release estável do Hermes:

1. credential pools;
2. provider routing, quando aplicável;
3. fallback providers;
4. fallback de tarefas auxiliares.

Nossa camada própria adiciona políticas de capacidade, custo e continuidade física, não um router paralelo por padrão.

Após qualquer failover de modelo/provider:

```text
preservar checkpoint
      ->
não executar nova ação GUI
      ->
reobservar estado real
      ->
reconciliar checkpoint x realidade
      ->
continuar somente se seguro
```

## 9. Cost policy

Fallback automático só pode consumir recursos previamente autorizados.

Ordem conceitual:

```text
TIER 0  recurso sem novo custo autorizado
   ->
TIER 1  outro recurso ja autorizado sem novo custo
   ->
TIER 2  self-hosted / VPS, se disponivel
   ->
PAID FALLBACK = HUMAN_GATE LEANDRO
```

Nenhuma nova API paga, assinatura ou consumo não autorizado pode ser ativado autonomamente.

## 10. Hello World acceptance flow

```text
START
 -> verificar estado inicial
 -> abrir Brave pela GUI
 -> verificar Brave
 -> acessar ChatGPT pela GUI
 -> verificar sessão autenticada
 -> abrir novo chat
 -> digitar "Hello World"
 -> verificar texto
 -> enviar
 -> aguardar geração
 -> detectar conclusão real
 -> ler resposta inteira
 -> scroll quando necessário
 -> compreender semanticamente
 -> avaliar contra objetivo
 -> abrir Xed pela GUI
 -> escrever relatório próprio
 -> salvar
 -> verificar arquivo
 -> preservar ChatGPT + relatório
 -> SUCCESS
```

Definition of Done: **3 execuções consecutivas completas com sucesso**, iniciando com Brave e editor fechados e ChatGPT já autenticado.

## 11. Deployment boundary

### MVP local

O primeiro Hello World não depende da VPS. O notebook de LEANDRO hospeda o runtime necessário para operar o desktop físico:

- Hermes Agent / Hermes Desktop;
- Operator Profile / Policy;
- `computer_use` / `cua-driver`;
- Brave;
- Xed;
- Hard Emergency Stop futuro;
- evidência/checkpoint local inicial.

### Cloud evolution

`leon337/cloud-infrastructure` é uma plataforma complementar e poderá assumir, quando comprovadamente útil:

- Model Gateway;
- observabilidade central;
- workflows duráveis;
- armazenamento/backup;
- serviços compartilhados;
- outros agentes/executores;
- modelos self-hosted.

A cloud não é dependência do Hello World v1, exceto se o provider de inferência escolhido estiver hospedado nela.

## 12. Implementation order

```text
CONFIGURACAO
   ->
PROFILE / POLICY
   ->
VALIDACAO UPSTREAM
   ->
HOOKS / EXTENSOES MINIMAS
   ->
TESTES
   ->
CODIGO MAIS PROFUNDO somente se gap provado
   ->
ALTERACAO DO CORE somente como ultimo recurso
```

Modificar o core do Hermes exige evidência de que a capacidade necessária não pode ser obtida por configuração, skill, policy, hook, plugin ou extensão compatível.

## 13. Progressive validation

- **V0 — instalação/saúde:** Hermes inicia, `computer_use` existe, `cua-driver` saudável, X11 detectado.
- **V1 — percepção:** capturar desktop e identificar Brave/Xed sem mutação relevante.
- **V2 — ação reversível isolada:** abrir/focar app e verificar resultado.
- **V3 — Brave controlado:** navegação GUI sem ChatGPT.
- **V4 — ChatGPT autenticado:** detectar sessão sem enviar mensagem.
- **V5 — run-00:** ensaio técnico que não conta para DoD.
- **V6 — aceitação:** run-01, run-02 e run-03 consecutivos.

## 14. Rollback principle

Antes de qualquer modificação futura do host:

```text
capturar baseline
 -> registrar versão
 -> registrar caminhos criados
 -> instalar/configurar
 -> validar
```

Em falha relevante: parar, preservar evidência, diagnosticar e fazer rollback quando aplicável. Alteração de driver NVIDIA permanece fora deste pacote.

## 15. Canonical architectural decisions

- **AD-01:** Hermes oficial é o core.
- **AD-02:** nenhum agente paralelo.
- **AD-03:** nenhum fork inicialmente.
- **AD-04:** `computer_use` oficial é o executor GUI primário.
- **AD-05:** primeiro MVP é local; cloud não é dependência do Hello World.
- **AD-06:** foreground é obrigatório nos três runs iniciais.
- **AD-07:** observabilidade upstream será reaproveitada.
- **AD-08:** Evidence Layer e Operational Checkpoint são extensões mínimas.
- **AD-09:** Soft Stop upstream + Hard Emergency Stop do Hermes Operator.
- **AD-10 a AD-15:** detalhadas em `AD-10-15-inference-resilience.md`.

## 16. Unproven items

Continuam exigindo validação física ou configuração posterior:

- comportamento real do CUA no host;
- Brave + perfil autenticado;
- Xed recebendo input sintético;
- qualidade do foreground;
- Hard Emergency Stop físico;
- provider/modelo definitivo;
- detecção do fim da resposta do ChatGPT;
- watchdog aproximado de 60s;
- pressão de RAM/desempenho;
- autostart após login gráfico;
- comportamento completo de failover durante GUI real.

## 17. Permission state after approval

Architecture v1.1 está aprovada e canônica. A permissão operacional **não muda** por causa desta aprovação:

`READ_ONLY / READ_AND_PROPOSE`

Instalação, código executável e alteração do host continuam bloqueados até gate separado de LEANDRO.
