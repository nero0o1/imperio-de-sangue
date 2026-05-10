# 12_OPEN_QUESTIONS.md

# Império de Sangue — Perguntas em Aberto

| Campo | Valor |
|---|---|
| Documento | Perguntas em Aberto |
| Projeto | Império de Sangue |
| Versão do documento | 1.0 |
| Marco coberto | Marco 0.1 — Primeira invasão jogável |
| Engine alvo | Godot 4.x |
| Linguagem alvo | GDScript |
| Documento anterior | 11_DECISION_LOG.md |
| Próximo documento natural | 13_CHANGELOG.md |
| Finalidade | Registrar dúvidas ainda não decididas antes que virem escopo oculto ou implementação confusa |
| Status | Registro inicial de perguntas abertas |

> Este documento existe para separar dúvida de decisão.  
> Dúvida não resolvida não deve virar código definitivo sem passar por decisão registrada.

---

## 1. Finalidade do documento

Este arquivo registra perguntas ainda não respondidas sobre **Império de Sangue**.

Ele cobre tanto dúvidas de **design do jogo** quanto dúvidas **técnicas de implementação**.

Ele responde:

```text
O que ainda não foi decidido?
Qual pergunta bloqueia implementação?
Qual pergunta pode esperar?
Qual pergunta precisa virar decisão no 11_DECISION_LOG.md?
Qual pergunta precisa de teste no 07_TEST_PLAN.md?
Qual pergunta pode ser respondida depois do Marco 0.1?
```

Objetivo principal:

```text
Evitar que incertezas virem código improvisado, escopo escondido ou retrabalho.
```

---

## 2. Como usar este documento

Toda pergunta deve ser classificada por:

```text
ID;
categoria;
prioridade;
status;
impacto;
documento relacionado;
critério para resposta;
próxima ação.
```

### 2.1 Regra principal

```text
Pergunta crítica respondida deve virar decisão no 11_DECISION_LOG.md.
Pergunta que gera tarefa deve virar item no 05_BACKLOG.md.
Pergunta que gera risco deve virar item no 10_RISK_REGISTER.md.
Pergunta que gera teste deve virar caso no 07_TEST_PLAN.md.
```

---

## 3. Status das perguntas

| Status | Significado |
|---|---|
| OPEN | Pergunta aberta |
| INVESTIGATING | Em análise ou teste |
| ANSWERED | Respondida, mas ainda não virou decisão |
| DECIDED | Respondida e registrada no decision log |
| DEFERRED | Adiada para marco futuro |
| BLOCKED | Depende de outra resposta |
| CANCELLED | Não é mais relevante |

---

## 4. Prioridade das perguntas

| Prioridade | Significado | Ação |
|---|---|---|
| P0 | Bloqueia implementação do Marco 0.1 | Responder antes de continuar a wave afetada |
| P1 | Afeta sistema obrigatório | Responder antes de fechar Marco 0.1 |
| P2 | Afeta qualidade ou clareza | Responder quando o loop estiver jogável |
| P3 | Melhoria futura | Adiar |
| PX | Fora do escopo atual | Mover para marco futuro |

---

## 5. Matriz geral de perguntas em aberto

| ID | Categoria | Pergunta | Prioridade | Status | Impacto | Documento relacionado | Próxima ação |
|---|---|---|---|---|---:|---|---|
| Q-001 | Design | O núcleo do assentamento será fundado pelo jogador ou já começa ativo? | P1 | OPEN | 7 | 02/03 | Definir antes da Wave 3 |
| Q-002 | Design | A primeira onda começa automaticamente por tempo ou manualmente por debug? | P1 | OPEN | 7 | 02/05/07 | Definir antes da Wave 5 |
| Q-003 | Design | O jogador pode atacar inimigos no Marco 0.1 ou só comandar defesa? | P1 | OPEN | 8 | 02/03 | Definir antes da Wave 4 |
| Q-004 | Design | A barricada bloqueia caminho ou apenas absorve dano? | P1 | OPEN | 8 | 02/04 | Definir antes da Wave 3 |
| Q-005 | Design | O NPC defensor causa dano, bloqueia inimigo ou faz os dois? | P1 | OPEN | 8 | 02/04 | Definir antes da Wave 7 |
| Q-006 | Design | O NPC coletor coleta de WoodNode real ou ponto abstrato de coleta? | P1 | OPEN | 7 | 03/04 | Definir antes da Wave 6 |
| Q-007 | Técnico | Usar CharacterBody3D para Player e EnemyBasic? | P1 | OPEN | 7 | 03 | Confirmar durante Wave 1 e Wave 4 |
| Q-008 | Técnico | Usar NavigationAgent3D ou movimento direto no EnemyBasic? | P1 | OPEN | 8 | 03/04/10 | Definir na Wave 4 |
| Q-009 | Técnico | Conectar sinais via editor ou via script no Main.gd? | P1 | OPEN | 6 | 03/04/08 | Escolher padrão inicial |
| Q-010 | Técnico | O HUD lê Autoloads diretamente ou só recebe sinais? | P1 | OPEN | 6 | 04 | Confirmar antes da Wave 8 |
| Q-011 | Escopo | Magia simples entra no Marco 0.1 ou fica para 0.2? | P2 | OPEN | 6 | 02/10 | Provável adiar |
| Q-012 | Escopo | Reparo de barricada/núcleo entra no Marco 0.1? | P2 | OPEN | 5 | 02/05 | Só entrar se loop estiver estável |
| Q-013 | Balanceamento | Qual custo inicial da barricada? | P1 | OPEN | 6 | 02/07 | Começar com 5 madeira |
| Q-014 | Balanceamento | Quantos inimigos na primeira onda? | P1 | OPEN | 7 | 02/07 | Começar com 3 a 5 |
| Q-015 | Balanceamento | Qual vida inicial do núcleo? | P1 | OPEN | 7 | 02/07 | Começar com 100 |
| Q-016 | UX | Como comunicar que a onda começou? | P1 | OPEN | 6 | 07/08 | HUD textual temporária |
| Q-017 | UX | Como comunicar madeira insuficiente? | P1 | OPEN | 6 | 07 | Mensagem textual simples |
| Q-018 | UX | Como o jogador entende que NPC foi atribuído? | P1 | OPEN | 7 | 07 | Feedback textual/estado visual simples |
| Q-019 | Assets | Quais assets podem ser apenas cubos/cápsulas no Marco 0.1? | P1 | OPEN | 5 | 09 | Usar placeholders amplamente |
| Q-020 | Assets | Algum asset externo será usado antes do loop funcionar? | P2 | OPEN | 6 | 09/10 | Provável não |
| Q-021 | IA/Codex | Codex deve gerar um arquivo por vez ou múltiplos arquivos por tarefa? | P1 | OPEN | 7 | 06 | Preferir um arquivo por vez no início |
| Q-022 | IA/Codex | IA pode sugerir refatoração antes do loop completo funcionar? | P2 | OPEN | 6 | 06/10 | Só refatoração local |
| Q-023 | Teste | Qual é a primeira definição de sessão completa? | P1 | OPEN | 8 | 07 | Usar TC-020 |
| Q-024 | Organização | Quando parar de criar documentos e iniciar implementação? | P0 | OPEN | 10 | 05/10 | Após documentos base e revisão mínima |

---

## 6. Perguntas de design do jogo

### Q-001 — Núcleo fundado ou ativo no início?

| Campo | Valor |
|---|---|
| Pergunta | O núcleo do assentamento será fundado pelo jogador ou já começa ativo? |
| Prioridade | P1 |
| Status | OPEN |
| Impacto | 7 |
| Opção A | Núcleo já começa ativo |
| Opção B | Jogador funda/ativa o núcleo |
| Prós da A | Mais simples, reduz UI e fluxo inicial |
| Contras da A | Menos sensação de fundar assentamento |
| Prós da B | Reforça fantasia de construir reino |
| Contras da B | Adiciona interação inicial extra |
| Recomendação provisória | Núcleo começa ativo no Marco 0.1 |
| Critério para resposta | Escolher a opção que menos atrase Wave 3 |

### Q-002 — Onda automática ou manual/debug?

| Campo | Valor |
|---|---|
| Pergunta | A primeira onda começa automaticamente por tempo ou manualmente por debug? |
| Prioridade | P1 |
| Status | OPEN |
| Impacto | 7 |
| Opção A | Início manual por tecla/debug |
| Opção B | Início automático após 8–12 minutos |
| Recomendação provisória | Implementar manual primeiro; automático depois |
| Critério para resposta | Permitir teste rápido na Wave 5 |

### Q-003 — Jogador ataca ou apenas comanda?

| Campo | Valor |
|---|---|
| Pergunta | O jogador pode atacar inimigos no Marco 0.1 ou só comandar defesa? |
| Prioridade | P1 |
| Status | OPEN |
| Impacto | 8 |
| Opção A | Jogador ataca com ação simples |
| Opção B | Jogador apenas prepara base/NPCs |
| Recomendação provisória | Permitir ataque simples para reduzir frustração no teste |
| Critério para resposta | Se ataque atrasar Wave 4, reduzir para dano simples por alcance/raycast |

### Q-004 — Barricada bloqueia ou absorve dano?

| Campo | Valor |
|---|---|
| Pergunta | A barricada bloqueia caminho ou apenas absorve dano? |
| Prioridade | P1 |
| Status | OPEN |
| Impacto | 8 |
| Opção A | Bloqueia caminho fisicamente |
| Opção B | Absorve dano como alvo prioritário |
| Recomendação provisória | Absorver dano primeiro; bloquear caminho depois se simples |
| Critério para resposta | Escolher a menor implementação que prove utilidade da construção |

### Q-005 — Papel exato do NPC defensor

| Campo | Valor |
|---|---|
| Pergunta | O NPC defensor causa dano, bloqueia inimigo ou faz os dois? |
| Prioridade | P1 |
| Status | OPEN |
| Impacto | 8 |
| Recomendação provisória | Causar dano simples em inimigo próximo |
| Critério para resposta | O jogador deve perceber melhora ao usar defensor |

### Q-006 — Coleta real ou abstrata para NPC coletor?

| Campo | Valor |
|---|---|
| Pergunta | O NPC coletor coleta de WoodNode real ou ponto abstrato de coleta? |
| Prioridade | P1 |
| Status | OPEN |
| Impacto | 7 |
| Recomendação provisória | Usar ponto abstrato de coleta no início |
| Critério para resposta | Evitar pathfinding complexo e validar economia primeiro |

---

## 7. Perguntas técnicas

### Q-007 — CharacterBody3D para Player e EnemyBasic?

| Campo | Valor |
|---|---|
| Pergunta | Usar CharacterBody3D para Player e EnemyBasic? |
| Prioridade | P1 |
| Status | OPEN |
| Impacto | 7 |
| Recomendação provisória | Sim para Player; EnemyBasic pode começar com CharacterBody3D ou Node3D simples |
| Critério para resposta | Se física atrapalhar inimigo, usar movimento direto com Node3D temporário |

### Q-008 — NavigationAgent3D ou movimento direto?

| Campo | Valor |
|---|---|
| Pergunta | Usar NavigationAgent3D ou movimento direto no EnemyBasic? |
| Prioridade | P1 |
| Status | OPEN |
| Impacto | 8 |
| Recomendação provisória | Movimento direto para o alvo no Marco 0.1 |
| Critério para resposta | Se rota simples funcionar, não usar navegação avançada ainda |

### Q-009 — Sinais via editor ou via script?

| Campo | Valor |
|---|---|
| Pergunta | Conectar sinais via editor ou via script no Main.gd? |
| Prioridade | P1 |
| Status | OPEN |
| Impacto | 6 |
| Recomendação provisória | Conexões críticas via Main.gd para rastreabilidade |
| Critério para resposta | Preferir o método mais fácil de revisar e reproduzir |

### Q-010 — HUD lê Autoload ou só recebe sinais?

| Campo | Valor |
|---|---|
| Pergunta | O HUD lê Autoloads diretamente ou só recebe sinais? |
| Prioridade | P1 |
| Status | OPEN |
| Impacto | 6 |
| Recomendação provisória | Receber sinais para atualização; leitura inicial direta é aceitável no _ready |
| Critério para resposta | HUD não pode decidir regra de jogo |

---

## 8. Perguntas de escopo

### Q-011 — Magia simples entra no Marco 0.1?

| Campo | Valor |
|---|---|
| Pergunta | Magia simples entra no Marco 0.1 ou fica para 0.2? |
| Prioridade | P2 |
| Status | OPEN |
| Impacto | 6 |
| Recomendação provisória | Fica para Marco 0.2 |
| Critério para resposta | Só considerar se loop mínimo já estiver funcionando |

### Q-012 — Reparo entra no Marco 0.1?

| Campo | Valor |
|---|---|
| Pergunta | Reparo de barricada/núcleo entra no Marco 0.1? |
| Prioridade | P2 |
| Status | OPEN |
| Impacto | 5 |
| Recomendação provisória | Adiar, salvo se necessário para balanceamento básico |
| Critério para resposta | Se derrota ficar inevitável, considerar reparo simples |

---

## 9. Perguntas de balanceamento

### Q-013 — Custo inicial da barricada

| Campo | Valor |
|---|---|
| Pergunta | Qual custo inicial da barricada? |
| Prioridade | P1 |
| Status | OPEN |
| Impacto | 6 |
| Recomendação provisória | 5 madeira |
| Critério para resposta | Jogador deve conseguir construir antes da onda sem grind longo |

### Q-014 — Quantos inimigos na primeira onda?

| Campo | Valor |
|---|---|
| Pergunta | Quantos inimigos na primeira onda? |
| Prioridade | P1 |
| Status | OPEN |
| Impacto | 7 |
| Recomendação provisória | 3 a 5 inimigos |
| Critério para resposta | Vitória e derrota precisam ser possíveis |

### Q-015 — Vida inicial do núcleo

| Campo | Valor |
|---|---|
| Pergunta | Qual vida inicial do núcleo? |
| Prioridade | P1 |
| Status | OPEN |
| Impacto | 7 |
| Recomendação provisória | 100 |
| Critério para resposta | Núcleo deve sobreviver com preparação e cair sem preparação |

---

## 10. Perguntas de UX e clareza

### Q-016 — Como comunicar início da onda?

| Campo | Valor |
|---|---|
| Pergunta | Como comunicar que a onda começou? |
| Prioridade | P1 |
| Status | OPEN |
| Impacto | 6 |
| Recomendação provisória | Mensagem textual no HUD: “Onda iniciada” |
| Critério para resposta | Jogador deve perceber ameaça sem áudio ou cutscene |

### Q-017 — Como comunicar madeira insuficiente?

| Campo | Valor |
|---|---|
| Pergunta | Como comunicar madeira insuficiente? |
| Prioridade | P1 |
| Status | OPEN |
| Impacto | 6 |
| Recomendação provisória | Texto temporário no HUD |
| Critério para resposta | Jogador entende por que construção falhou |

### Q-018 — Como comunicar NPC atribuído?

| Campo | Valor |
|---|---|
| Pergunta | Como o jogador entende que NPC foi atribuído? |
| Prioridade | P1 |
| Status | OPEN |
| Impacto | 7 |
| Recomendação provisória | Texto no HUD + mudança simples de estado/posição do NPC |
| Critério para resposta | Jogador percebe ação do NPC sem precisar debug |

---

## 11. Perguntas de assets e licença

### Q-019 — O que será placeholder?

| Campo | Valor |
|---|---|
| Pergunta | Quais assets podem ser apenas cubos/cápsulas no Marco 0.1? |
| Prioridade | P1 |
| Status | OPEN |
| Impacto | 5 |
| Recomendação provisória | Player, inimigo, NPCs, núcleo e barricada podem começar como placeholders |
| Critério para resposta | Se o asset não altera entendimento da mecânica, usar placeholder |

### Q-020 — Usar asset externo antes do loop funcionar?

| Campo | Valor |
|---|---|
| Pergunta | Algum asset externo será usado antes do loop funcionar? |
| Prioridade | P2 |
| Status | OPEN |
| Impacto | 6 |
| Recomendação provisória | Não usar, salvo CC0 simples e registrado |
| Critério para resposta | Evitar risco jurídico e atraso visual |

---

## 12. Perguntas de IA/Codex

### Q-021 — Um arquivo por vez ou múltiplos arquivos?

| Campo | Valor |
|---|---|
| Pergunta | Codex deve gerar um arquivo por vez ou múltiplos arquivos por tarefa? |
| Prioridade | P1 |
| Status | OPEN |
| Impacto | 7 |
| Recomendação provisória | Um arquivo por vez até o loop mínimo estabilizar |
| Critério para resposta | Reduzir dificuldade de debug e revisão |

### Q-022 — IA pode refatorar antes do loop funcionar?

| Campo | Valor |
|---|---|
| Pergunta | IA pode sugerir refatoração antes do loop completo funcionar? |
| Prioridade | P2 |
| Status | OPEN |
| Impacto | 6 |
| Recomendação provisória | Só refatoração local e pequena |
| Critério para resposta | Refatoração não pode substituir implementação do backlog |

---

## 13. Perguntas que bloqueiam implementação

Perguntas P0/P1 que devem ser resolvidas antes de avançar muito:

```text
Q-001 — Núcleo ativo ou fundado?
Q-002 — Onda manual ou automática?
Q-003 — Jogador ataca ou apenas comanda?
Q-004 — Barricada bloqueia ou absorve dano?
Q-005 — Papel exato do NPC defensor.
Q-006 — Coleta real ou abstrata do NPC coletor.
Q-008 — NavigationAgent3D ou movimento direto.
Q-009 — Conexões de sinais via editor ou script.
Q-010 — HUD por sinais ou leitura direta.
Q-024 — Quando parar de documentar e iniciar implementação.
```

---

## 14. Perguntas que podem esperar

Estas perguntas não devem bloquear Wave 0 a Wave 5:

```text
Q-011 — Magia simples.
Q-012 — Reparo.
Q-020 — Asset externo antes do loop.
Q-022 — Refatoração com IA.
```

Regra:

```text
Se a pergunta não bloqueia a primeira invasão jogável, ela pode esperar.
```

---

## 15. Critérios para responder uma pergunta

Uma pergunta só deve ser marcada como ANSWERED quando tiver:

```text
resposta objetiva;
motivo;
impacto no Marco 0.1;
documento afetado;
se gera tarefa, ID no backlog;
se gera decisão, ID no decision log;
se gera risco, ID no risk register;
se gera teste, ID no test plan.
```

---

## 16. Fluxo: pergunta respondida vira decisão

```text
Pergunta OPEN
→ análise curta
→ resposta provisória
→ teste ou comparação de alternativas, se necessário
→ decisão registrada no 11_DECISION_LOG.md
→ atualização de backlog/teste/risco, se aplicável
→ status DECIDED
```

### 16.1 Regra

```text
Pergunta crítica não deve ser resolvida apenas dentro do código.
Ela precisa virar decisão registrada.
```

---

## 17. Template curto de pergunta

```text
ID:
Categoria:
Pergunta:
Prioridade:
Status:
Impacto: 0–10
Documento relacionado:
Recomendação provisória:
Critério para resposta:
Próxima ação:
```

---

## 18. Template completo de pergunta

```text
ID:
Data:
Categoria: Design / Técnico / Escopo / Balanceamento / UX / Assets / IA / Teste / Organização
Pergunta:
Contexto:
Por que importa:
Prioridade: P0/P1/P2/P3/PX
Status: OPEN / INVESTIGATING / ANSWERED / DECIDED / DEFERRED / BLOCKED / CANCELLED
Impacto: 0–10

Alternativas:
A)
B)
C)

Prós da alternativa A:
-
-

Contras da alternativa A:
-
-

Recomendação provisória:
Critério para resposta:
Teste necessário:
Documento afetado:
Decisão relacionada:
Risco relacionado:
Tarefa relacionada:
Próxima ação:
```

---

## 19. Checklist semanal de perguntas

```text
[ ] Existe pergunta P0 ainda aberta?
[ ] Existe pergunta P1 bloqueando wave atual?
[ ] Alguma pergunta já foi respondida, mas não virou decisão?
[ ] Alguma pergunta virou tarefa no backlog?
[ ] Alguma pergunta revelou risco novo?
[ ] Alguma pergunta pode ser adiada para Marco 0.2?
[ ] Alguma dúvida está sendo resolvida diretamente no código sem registro?
[ ] O projeto já pode sair de documentação e entrar em implementação?
```

---

## 20. Resumo final das perguntas em aberto

```text
O 12_OPEN_QUESTIONS.md separa dúvida de decisão.
Ele cobre perguntas de design e perguntas técnicas.
Perguntas P0/P1 devem ser respondidas antes de avançar a wave afetada.
Perguntas respondidas precisam virar decisão no 11_DECISION_LOG.md quando impactarem escopo, arquitetura, teste, risco ou backlog.
O objetivo é evitar escopo oculto, improviso técnico e retrabalho.
```
