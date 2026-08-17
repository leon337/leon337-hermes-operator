# Mission Contract — MCF-HERMES-PC-001

## Identity

Mission ID: `MCF-HERMES-PC-001`  
Project: **Hermes Operator**  
Human authority: **LEANDRO**  
Risk class: **C**  
Status: **ACTIVE — RECONCILIATION / TECHNICAL RECONNAISSANCE**

## Objective

Produzir, com base em evidência real, a arquitetura e o plano mínimo para transformar o **Hermes Agent oficial da Nous Research** no operador de computador definido pelo PIP alinhado, evitando agente paralelo, fork ou reconstrução desnecessária.

## Scope

Inclui nesta missão:

- estabelecer continuidade canônica no repositório privado;
- verificar o host atual e suas restrições;
- verificar capacidades oficiais do Hermes necessárias ao Hello World;
- identificar gaps reais;
- propor arquitetura mínima;
- preparar instalação/teste controlados para gate posterior.

Não inclui, sem gate adicional:

- instalar Hermes;
- alterar drivers/GPU;
- executar Hello World físico;
- modificar o core do Hermes;
- criar fork;
- contratar serviços pagos;
- armazenar credenciais;
- publicar evidências privadas.

## Acceptance criteria

A missão de reconhecimento estará pronta para gate quando existir evidência verificável de:

1. PIP e alignment receipt persistidos no repositório canônico.
2. Baseline sanitizado do host persistido.
3. Versão/base oficial do Hermes identificada.
4. Capacidades necessárias ao Hello World mapeadas como `EXISTS`, `NEEDS_CONFIGURATION`, `NEEDS_EXTENSION` ou `UNPROVEN`.
5. Gaps reais registrados sem pressupor implementação.
6. Arquitetura mínima proposta com Hermes oficial como núcleo.
7. Riscos, custos e dependências externas explicitados.
8. Próximo gate humano/operacional claramente definido antes de qualquer modificação do host.

## Governing decisions

- Hermes Agent oficial é o núcleo.
- Não criar agente paralelo.
- Não fazer fork por padrão.
- Não reconstruir UI/computer-use se upstream já satisfizer a necessidade.
- `project-memory` é somente referência técnica; reutilização deve ser seletiva e justificada.
- Confiabilidade > velocidade.
- HUMAN_GATE = LEANDRO.

## Permission envelope

Estado atual: `READ_ONLY / READ_AND_PROPOSE`.

Qualquer ação que modifique o host exige novo gate explícito de LEANDRO.

## Evidence policy

Versionar somente evidência sanitizada e necessária. Credenciais, tokens, screenshots pessoais e logs brutos sensíveis ficam fora do Git.
