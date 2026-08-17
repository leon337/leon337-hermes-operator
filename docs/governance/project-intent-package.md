# Project Intent Package — Hermes Operator

Status: **ALIGNED**  
Human authority: **LEANDRO**  
Base product: **Hermes Agent oficial da Nous Research**  
Create agent from zero: **NO**

## Original intent

Criar um Hermes capaz de operar o computador de LEANDRO autonomamente pela interface gráfica, de maneira semelhante a um usuário humano, usando como núcleo o Hermes Agent oficial.

## Intent dimensions

### 1. PROBLEM
LEANDRO precisa hoje executar manualmente tarefas de GUI: abrir apps, navegar, clicar, digitar, esperar, interpretar resultados e decidir o próximo passo. Hermes deve assumir essa operação.

### 2. MOTIVATION
Transformar Hermes em um operador autônomo do computador, permitindo que LEANDRO defina a finalidade enquanto Hermes assume o trabalho operacional dentro do escopo autorizado.

### 3. DESIRED_OUTCOME
Hermes recebe um objetivo, observa o computador, entende o estado, decide a próxima ação, age pela GUI, observa o resultado, espera quando necessário, compreende, verifica progresso, corrige e continua até concluir ou atingir um limite que exija LEANDRO.

### 4. TARGET_USERS
MVP inicial: somente **LEANDRO** como usuário autorizado e HUMAN_GATE. Expansão para outros usuários não faz parte do primeiro escopo.

### 5. CRITICAL_USER_JOURNEYS
Primeiro marco: com Brave e editor fechados e sessão do ChatGPT já autenticada, Hermes abre Brave, acessa ChatGPT, inicia novo chat, envia `Hello World`, espera a resposta terminar completamente, lê a resposta inteira, compreende semanticamente, avalia contra o objetivo, abre um editor simples, escreve com as próprias palavras o que entendeu, salva e verifica o arquivo.

Visão de evolução imediata: continuidade multi-chat no ChatGPT, transportando somente o contexto necessário entre chats até cumprir um objetivo definido.

### 6. MUST_HAVE
- Operação visual por GUI.
- Mouse, teclado e atalhos humanos normais.
- Brave no primeiro marco.
- ChatGPT pela GUI; API/backend/DOM não podem substituir o teste visual.
- Espera e detecção de conclusão de resposta.
- Leitura de respostas maiores que uma tela, com scroll controlado.
- Compreensão semântica e avaliação do resultado.
- Operação de um segundo aplicativo local.
- Relatório em palavras próprias.
- Persistência e verificação do arquivo.
- Logs, screenshots, checkpoints e failure bundle.
- Watchdog de progresso.
- Recuperação segura de falhas reversíveis.
- Emergency Stop.

### 7. SHOULD_HAVE
- Recuperação autônoma de pequenos imprevistos.
- Retomada segura por checkpoint.
- Observabilidade detalhada.
- Organização automática de evidências.
- Limpeza controlada.
- Hermes residente após login gráfico.
- Interface local conversacional.

### 8. NON_GOALS
No primeiro MVP não é objetivo: generalizar para qualquer computador/SO/navegador; multiusuário; Telegram/WhatsApp/voz/remoto; armazenar ou digitar senhas; contornar autenticação; operar livremente outras contas; compras/contratos/publicação; iniciar novas finalidades sozinho; substituir o fluxo visual por API, backend, DOM ou terminal.

### 9. PRIORITIES_AND_TRADEOFFS
Prioridade: **1) correção, 2) compreensão, 3) verificação, 4) velocidade**. Primeiro fazer certo; depois otimizar velocidade sem perder confiabilidade.

### 10. BUSINESS_RULES
- LEANDRO define o quê; Hermes decide como executar dentro das permissões da missão.
- Hermes não inicia uma nova missão/objetivo sozinho.
- Baixo risco e reversível: pode agir autonomamente com evidência razoável e verificar depois.
- Médio risco: deve obter evidência adicional; se persistir incerteza relevante, parar.
- Alto risco/sensível/irreversível/fora do escopo: HUMAN_GATE de LEANDRO.
- Não repetir cegamente a mesma ação no mesmo estado com os mesmos parâmetros.

### 11. DATA_AND_SENSITIVITY
Princípio: **registrar o necessário, não tudo o que for possível**. Evitar preservar senhas, códigos de autenticação, tokens, chaves, credenciais ou dados privados irrelevantes. Evidências são privadas e não devem ser publicadas/enviadas a terceiros sem autorização.

### 12. ROLES_AND_PERMISSIONS
- Autoridade humana: LEANDRO.
- Sessões já autenticadas podem ser usadas.
- Hermes não deve conhecer, armazenar ou digitar senha, nem contornar autenticação.
- Se autenticação expirar: detectar, registrar, pausar, pedir LEANDRO, aguardar autenticação humana e só então retomar.
- No primeiro MVP, agir como LEANDRO é autorizado somente dentro da sessão privada do ChatGPT e para a missão autorizada.

### 13. AUTOMATION_LEVEL
Hermes permanece residente após o login gráfico e aguarda missões. Sem missão: aguarda. Missão explicitamente autorizada: alta autonomia dentro do escopo. Nenhuma nova finalidade é iniciada autonomamente.

### 14. INTEGRATIONS
Primeiro marco: SO atual, Brave, ChatGPT, editor local simples, sistema de arquivos, logs, screenshots. Terminal apenas auxiliar para diagnóstico/estado/processo/recuperação segura; não substitui as etapas GUI do teste.

### 15. PLATFORM_AND_USAGE_CONTEXT
Primeira versão no computador atual de LEANDRO, sessão gráfica Linux/X11, Brave, execução visível. Durante as execuções iniciais, Hermes terá controle operacional exclusivo da GUI; LEANDRO observa e mantém Emergency Stop.

### 16. COST_AND_RESOURCE_CONSTRAINTS
Custo adicional zero sempre que tecnicamente possível. Priorizar software livre/open source/local/já disponível/gratuito. Nenhuma assinatura ou API paga sem decisão prévia de LEANDRO.

### 17. QUALITY_EXPECTATIONS
Ação executada não é prova de sucesso. Fluxo esperado: **ação → observação → verificação**. Em incerteza: observar mais → obter evidência → reavaliar. Quanto maior o impacto potencial do erro, maior a confiança exigida.

### 18. FAILURE_TOLERANCE
Erros simples, locais e reversíveis podem ser corrigidos autonomamente após registrar, reobservar, corrigir e verificar. Se o erro já tiver impacto relevante/sensível: preservar evidência e HUMAN_GATE. Watchdog distingue espera justificada de ausência de progresso. Aproximadamente 60s sem progresso relevante pode iniciar diagnóstico, sujeito a calibração por evidência real.

### 19. DEFINITION_OF_DONE
Primeiro marco validado somente após **3 execuções consecutivas completas com sucesso**, cada uma iniciando com Brave e editor fechados e ChatGPT já autenticado. Cada run deve completar todo o fluxo Hello World, produzir relatório próprio, salvar/verificar arquivo, gerar evidências e preservar estado para inspeção.

Relatório mínimo: `MISSÃO`, `RESPOSTA ENTENDIDA`, `AVALIAÇÃO`, `RESULTADO: SUCESSO|FALHA`.

### 20. FUTURE_VISION
Após o Hello World, aprofundar continuidade dentro do ChatGPT antes de ampliar para muitos apps: iniciar chat, enviar instrução, esperar, ler, compreender, avaliar, abrir segundo chat, transportar somente contexto necessário e continuar até atingir o objetivo.

## Human decisions
Decisões Q1–Q46 do bootstrap foram consolidadas neste documento. O ponto arquitetural adicional confirmado é que o núcleo será o **Hermes Agent oficial**, não um agente desenvolvido do zero.

## Technical delegations
Permanecem técnicas e não alteram a intenção: mecanismo final de GUI, profile, skill, formato de logs, caminho físico de evidências, autostart, implementação do Emergency Stop, política técnica de redaction, modelo/provider, persistência e runtime.

## Assumptions
- O primeiro ambiente é o computador atual de LEANDRO.
- Brave e um editor simples já estão disponíveis.
- A sessão do ChatGPT estará autenticada pelo humano antes do teste.

## Unknowns
Há unknowns técnicos, mas nenhum unknown de intenção bloqueador identificado no alinhamento.

## Blockers
Nenhum blocker de intenção. Implementação permanece bloqueada até conclusão da reconciliação MCF e gate técnico aplicável.

## Conflicts
Nenhum conflito material de intenção aberto.

## Readiness
`ALIGNED`
