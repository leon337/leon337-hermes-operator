# Mission Contract — MCF-HERMES-PC-002

## Identity

Mission ID: `MCF-HERMES-PC-002`  
Project: **Hermes Operator**  
Human authority / HUMAN_GATE: **LEANDRO**  
Orchestrator: **MESTRE**  
Risk class: **C**  
Status: **ACTIVE — IMPLEMENTATION / QUALIFICATION**

## Human goal

Transformar o Hermes já instalado na VPS em um **operador residente, persistente e independente da continuidade do SentinelX**, usando o SentinelX somente como plano de controle/telemetria, e qualificar o primeiro marco GUI de ponta a ponta.

Autorização consumida em 2026-08-24: LEANDRO aprovou explicitamente a recomendação arquitetural e declarou que ela passa a ser a missão vigente.

## Objective

Materializar e provar esta arquitetura:

```text
LEANDRO
  ↓ objetivo / gate
MESTRE + MCF
  ↓ coordenação
SentinelX
  ↓ start / stop / status / evidence
Hermes Operator residente na VPS
  ├─ runtime local persistente
  ├─ cérebro/tool-calling adequado
  ├─ checkpoints + watchdog + recovery
  └─ evidence bundle sanitizado
        ↓
      GUI Linux/X11
        ↓
      Brave
        ↓
      ChatGPT
```

A queda ou reconexão do SentinelX **não pode interromper uma missão já iniciada**. O trabalho deve continuar localmente na VPS e ser reconciliado quando o canal voltar.

## Implementation scope autorizado

Dentro desta missão, MESTRE pode executar sem novo HUMAN_GATE:

- modificar configuração user-space do Hermes sob `/home/ubuntu`;
- instalar/configurar serviços `systemd --user` do operador, relay/controlador e provider local;
- trocar/ajustar modelo local gratuito quando necessário para confiabilidade/latência;
- criar runtime persistente, fila/job state, watchdog, checkpoints, logs e evidências sanitizadas;
- iniciar/parar/reiniciar processos user-space da missão;
- operar Brave/editor pela GUI exclusivamente durante o PIP;
- criar branches, commits, workflows e evidências privadas necessárias nos repositórios do projeto/infra;
- executar probes, diagnósticos, recovery reversível e as três execuções de qualificação.

## Boundaries que continuam exigindo HUMAN_GATE

- qualquer login, senha, código MFA, captcha ou reautenticação do ChatGPT;
- armazenar, digitar, copiar ou expor credenciais/tokens/chaves;
- contratar serviço pago ou consumir API paga não previamente autorizada;
- restaurar sudo genérico, `NOPASSWD: ALL`, ou ampliar privilégio de forma ampla;
- ação pública, compra, contrato, publicação externa ou operação fora da finalidade desta missão;
- mudança destrutiva/irreversível relevante no host.

## Operating rule

`HUMAN_AUTHORITY != HUMAN_OPERATION`.

LEANDRO decide finalidade e gates. MESTRE/agentes executam o trabalho técnico. LEANDRO não deve ser usado como terminal humano salvo quando a própria fronteira de autoridade humana for indispensável (por exemplo, autenticação interativa).

## Runtime acceptance criteria

O operador residente só é considerado pronto quando houver evidência de que:

1. Hermes, relay/controlador e provider necessários iniciam como serviços do usuário `ubuntu` ou mecanismo equivalente persistente após login gráfico.
2. SentinelX pode iniciar uma missão e receber `job_id`/estado sem manter conexão aberta durante toda a execução.
3. Desconexão temporária do SentinelX não encerra o job local.
4. Estado de missão é persistido localmente com pelo menos `ID`, `phase`, `started_at`, `last_progress_at`, `result`, `failure`/`gate`.
5. Existe watchdog que distingue espera legítima de ausência de progresso e produz diagnóstico antes de recovery.
6. Existe Emergency Stop técnico para abortar o job sem matar indiscriminadamente processos externos.
7. Logs/evidências não preservam senhas, tokens ou dados privados irrelevantes.
8. O modelo/driver consegue tool-calling e `computer_use` em tempo operacional aceitável.

## Qualification — Hello World

Cada run deve iniciar com Brave e editor fechados e ChatGPT já autenticado e completar exclusivamente pela GUI:

1. abrir Brave;
2. acessar ChatGPT;
3. iniciar novo chat;
4. enviar exatamente `Hello World`;
5. aguardar conclusão completa da resposta;
6. ler/compreender a resposta inteira;
7. abrir editor gráfico;
8. escrever relatório em palavras próprias com `MISSÃO`, `RESPOSTA ENTENDIDA`, `AVALIAÇÃO`, `RESULTADO: SUCESSO`;
9. salvar pelo fluxo gráfico;
10. verificar conteúdo e persistência;
11. preservar evidência sanitizada.

Definition of Done desta missão: **3 execuções consecutivas completas com sucesso**, sem substituição das etapas GUI por API/backend/DOM/terminal.

## Failure policy

Falha reversível: registrar → reobservar → diagnosticar → corrigir → verificar → continuar.  
Falha de autenticação/sensível: preservar estado e retornar `HUMAN_GATE`.  
Não declarar sucesso por mera tentativa ou por processo iniciado.

## Communication rule

MESTRE não deve interromper a missão para relatar progresso intermediário. Retornar a LEANDRO somente quando:

- a Definition of Done for satisfeita; ou
- surgir HUMAN_GATE real dentro dos boundaries acima; ou
- existir blocker externo não recuperável com os canais técnicos disponíveis.
