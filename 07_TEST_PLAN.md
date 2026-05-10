# 07_TEST_PLAN.md

# Império de Sangue — Plano de Testes

| Campo | Valor |
|---|---|
| Documento | Plano de Testes |
| Projeto | Império de Sangue |
| Versão do documento | 1.0 |
| Marco coberto | Marco 0.1 — Primeira invasão jogável |
| Engine alvo | Godot 4.x |
| Linguagem alvo | GDScript |
| Documento anterior | 06_AI_CODEX_RULES.md |
| Próximo documento natural | 08_BUILD_NOTES.md |
| Finalidade | Validar manualmente se o protótipo cumpre o escopo do Marco 0.1 |
| Status | Plano inicial de QA manual |

> Este documento define como testar o protótipo.  
> O objetivo não é testar um jogo completo; é validar a primeira invasão jogável com coleta, construção, NPCs, inimigo, onda, vitória e derrota.

---

## 1. Finalidade do documento

Este arquivo define o plano de testes do **Marco 0.1 — Primeira invasão jogável**.

Ele responde:

```text
O que precisa ser testado?
Como testar cada sistema?
Quais bugs bloqueiam avanço?
Quando uma wave pode ser considerada estável?
Quando o Marco 0.1 pode ser considerado jogável?
Quais testes devem ser repetidos após mudança de código?
```

Este documento deve ser usado junto com:

```text
02_PROTOTYPE_SCOPE.md
03_TECHNICAL_DESIGN.md
04_SYSTEMS_ARCHITECTURE.md
05_BACKLOG.md
06_AI_CODEX_RULES.md
```

---

## 2. Estratégia de teste

A estratégia do Marco 0.1 é **teste manual orientado a checklist**.

Motivo:

```text
O projeto ainda está em protótipo.
O foco é validar gameplay mínimo.
Automação completa de testes ainda não compensa.
Testes manuais detectam rapidamente falhas de fluxo, clareza e sensação de jogo.
```

### 2.1 Prioridade dos testes

| Prioridade | Tipo de teste | Objetivo |
|---|---|---|
| P0 | Teste bloqueante | Verificar se projeto abre e loop essencial funciona |
| P1 | Teste funcional | Verificar sistemas obrigatórios do Marco 0.1 |
| P2 | Teste de clareza | Verificar se jogador entende objetivo e resultado |
| P3 | Teste de polimento | Feedback visual, texto, pequenos ajustes |

---

## 3. Escopo dos testes do Marco 0.1

Entram nos testes:

```text
abertura da cena principal;
controle do jogador em primeira pessoa;
interação por Raycast ou equivalente;
coleta de madeira;
atualização do ResourceManager;
construção de barricada;
bloqueio de construção sem recurso;
vida do núcleo;
dano no núcleo;
NPC coletor;
NPC defensor;
inimigo básico;
WaveManager;
HUD;
vitória;
derrota;
loop completo em 10 a 15 minutos.
```

---

## 4. Fora do escopo de teste

Não testar no Marco 0.1:

```text
multiplayer;
save/load;
inventário completo;
sistema de facções;
diplomacia;
mundo procedural;
mapa grande;
arte final;
animação final;
áudio final;
balanceamento fino;
performance de jogo completo;
compatibilidade com console;
tradução;
acessibilidade completa.
```

Se algum desses itens aparecer durante teste, deve ser registrado como fora de escopo, não como bug bloqueante.

---

## 5. Ambientes de teste

### 5.1 Ambiente principal

| Item | Valor |
|---|---|
| Engine | Godot 4.x |
| Plataforma | PC |
| Sistema operacional | Windows inicialmente |
| Build | Execução pelo editor da Godot |
| Mapa | TestMap.tscn |
| Cena principal | Main.tscn |

### 5.2 Regra de ambiente

Sempre registrar:

```text
versão da Godot;
data do teste;
cena testada;
tarefa/wave relacionada;
resultado;
bugs encontrados.
```

---

## 6. Severidade de bugs

| Severidade | Definição | Ação |
|---|---|---|
| S0 | Projeto, cena ou execução principal não abre | Corrigir imediatamente |
| S1 | Impede vitória, derrota ou loop essencial | Corrigir antes de avançar |
| S2 | Sistema obrigatório funciona parcialmente | Corrigir antes de fechar Marco 0.1 |
| S3 | Feedback, UI, texto ou comportamento menor | Pode ir para backlog |
| S4 | Polimento estético | Adiar |

### 6.1 Bugs bloqueantes

São bloqueantes:

```text
Main.tscn não abre;
Player não se move;
interação não funciona;
madeira não é coletada;
barricada não pode ser construída;
inimigo não causa dano;
onda não termina;
vitória não aparece;
derrota não aparece.
```

---

## 7. Critérios de entrada para teste

Uma tarefa só deve entrar em teste quando:

```text
foi implementada;
a cena relacionada abre;
não há erro de sintaxe;
não há erro crítico no console;
a dependência anterior está funcionando;
o critério de aceite está claro;
o teste manual está definido.
```

---

## 8. Critérios de saída do teste

Uma tarefa pode sair de teste quando:

```text
o comportamento esperado foi observado;
o teste manual foi executado;
não houve erro S0 ou S1;
bugs S2 foram registrados;
a tarefa não quebrou funcionalidade anterior;
o status no backlog pode virar DONE ou voltar para DOING.
```

---

## 9. Matriz de rastreabilidade

| Sistema | Documento de origem | Critério no escopo | Casos de teste |
|---|---|---|---|
| Player | 03_TECHNICAL_DESIGN.md | Movimento FPS e interação | TC-001, TC-002 |
| InteractionRaycast | 04_SYSTEMS_ARCHITECTURE.md | Chamar `interact(actor)` | TC-003 |
| ResourceManager | 03/04 | Controlar madeira | TC-004, TC-005 |
| WoodNode | 03/04 | Coleta manual | TC-006 |
| SettlementCore | 03/04 | Vida e destruição do núcleo | TC-007, TC-008 |
| BuildSpot/Barricade | 03/04 | Construção com custo | TC-009, TC-010 |
| EnemyBasic | 03/04 | Atacar alvo | TC-011, TC-012 |
| WaveManager | 03/04 | Iniciar e terminar onda | TC-013, TC-014 |
| NpcCollector | 03/04 | Coletar madeira | TC-015 |
| NpcDefender | 03/04 | Defender contra inimigo | TC-016 |
| HUD | 03/04 | Mostrar estado | TC-017 |
| GameManager | 03/04 | Vitória e derrota | TC-018, TC-019, TC-020 |

---

## 10. Testes por wave

### 10.1 Wave 0 — Preparação

```text
[ ] Projeto abre.
[ ] Main.tscn existe.
[ ] TestMap.tscn existe.
[ ] Estrutura de pastas existe.
[ ] Cena principal roda pelo editor.
```

### 10.2 Wave 1 — Player e interação

```text
[ ] Player aparece no mapa.
[ ] Player se move.
[ ] Player olha com mouse.
[ ] Raycast aponta para frente.
[ ] Objeto interativo recebe interact(actor).
```

### 10.3 Wave 2 — Recursos

```text
[ ] ResourceManager está como Autoload.
[ ] wood inicia em 0.
[ ] add_wood aumenta madeira.
[ ] spend_wood reduz madeira.
[ ] spend_wood falha sem recurso suficiente.
```

### 10.4 Wave 3 — Núcleo e construção

```text
[ ] SettlementCore tem vida.
[ ] SettlementCore recebe dano.
[ ] BuildSpot consome madeira.
[ ] Barricade é instanciada.
[ ] Construção sem madeira é bloqueada.
```

### 10.5 Wave 4 — Inimigo básico

```text
[ ] EnemyBasic spawna.
[ ] EnemyBasic anda até alvo.
[ ] EnemyBasic ataca núcleo ou barricada.
[ ] EnemyBasic recebe dano.
[ ] EnemyBasic morre.
```

### 10.6 Wave 5 — Onda

```text
[ ] WaveManager inicia onda.
[ ] 3 a 5 inimigos aparecem.
[ ] enemies_alive aumenta.
[ ] enemies_alive reduz quando inimigo morre.
[ ] wave_finished dispara no fim.
```

### 10.7 Wave 6 — NPC coletor

```text
[ ] NpcCollector recebe ordem.
[ ] NpcCollector vai até recurso.
[ ] NpcCollector simula coleta.
[ ] NpcCollector deposita madeira.
[ ] HUD/contador reflete madeira nova.
```

### 10.8 Wave 7 — NPC defensor

```text
[ ] NpcDefender recebe ordem.
[ ] NpcDefender vai ao ponto defensivo.
[ ] NpcDefender detecta inimigo.
[ ] NpcDefender ataca inimigo.
[ ] Inimigo sofre dano.
```

### 10.9 Wave 8 — HUD e resultado

```text
[ ] HUD mostra madeira.
[ ] HUD mostra vida do núcleo.
[ ] HUD mostra aviso de onda.
[ ] HUD mostra vitória.
[ ] HUD mostra derrota.
```

### 10.10 Wave 9 — Integração

```text
[ ] Loop completo roda.
[ ] Vitória é possível.
[ ] Derrota é possível.
[ ] Sessão cabe em 10 a 15 minutos.
[ ] Bugs críticos estão registrados.
```

---

## 11. Casos de teste funcionais

| ID | Nome | Pré-condição | Passos | Resultado esperado | Severidade se falhar |
|---|---|---|---|---|---|
| TC-001 | Abrir cena principal | Projeto criado | Executar Main.tscn | Cena abre sem erro | S0 |
| TC-002 | Movimento do Player | Player no mapa | Usar WASD e mouse | Player anda e olha | S1 |
| TC-003 | Interação genérica | Raycast configurado | Olhar objeto interativo e pressionar ação | `interact(actor)` é chamado | S1 |
| TC-004 | Madeira inicia em zero | ResourceManager ativo | Rodar cena | `wood = 0` | S2 |
| TC-005 | Gasto sem madeira falha | Madeira em 0 | Tentar construir | Construção não ocorre | S1 |
| TC-006 | Coleta manual de madeira | WoodNode no mapa | Interagir com WoodNode | Madeira aumenta | S1 |
| TC-007 | Núcleo recebe dano | SettlementCore no mapa | Aplicar dano | Vida reduz | S1 |
| TC-008 | Núcleo destruído gera derrota | Vida do núcleo baixa | Aplicar dano letal | Derrota é disparada | S1 |
| TC-009 | Construir barricada com madeira | Madeira suficiente | Interagir com BuildSpot | Barricade aparece | S1 |
| TC-010 | Barricada recebe dano | Barricade criada | Inimigo ataca | Vida da barricada reduz | S2 |
| TC-011 | EnemyBasic se move até alvo | Inimigo com alvo | Iniciar cena | Inimigo anda até alvo | S1 |
| TC-012 | EnemyBasic ataca alvo | Inimigo perto do alvo | Aguardar ataque | Alvo recebe dano | S1 |
| TC-013 | WaveManager inicia onda | WaveManager ativo | Chamar start_wave | Inimigos aparecem | S1 |
| TC-014 | WaveManager encerra onda | Inimigos ativos | Matar todos | wave_finished dispara | S1 |
| TC-015 | NpcCollector coleta madeira | NPC e recurso existem | Atribuir coleta | Estoque aumenta | S1 |
| TC-016 | NpcDefender ataca inimigo | NPC e inimigo existem | Atribuir defesa | Inimigo sofre dano | S1 |
| TC-017 | HUD atualiza estado | HUD conectada | Alterar madeira/núcleo | HUD muda valores | S2 |
| TC-018 | Vitória aparece | Onda termina com núcleo vivo | Matar inimigos | Mensagem de vitória | S1 |
| TC-019 | Derrota por núcleo aparece | Núcleo chega a 0 | Causar dano letal | Mensagem de derrota | S1 |
| TC-020 | Loop completo | Sistemas integrados | Jogar sessão completa | Vitória ou derrota clara | S1 |

---

## 12. Testes de regressão mínimos

Rodar após qualquer mudança em código P0/P1:

```text
[ ] TC-001 — Abrir cena principal.
[ ] TC-002 — Movimento do Player.
[ ] TC-003 — Interação genérica.
[ ] TC-006 — Coleta manual de madeira.
[ ] TC-009 — Construção de barricada.
[ ] TC-013 — Início da onda.
[ ] TC-014 — Fim da onda.
[ ] TC-018 — Vitória.
[ ] TC-019 — Derrota.
[ ] TC-020 — Loop completo.
```

---

## 13. Testes de integração do loop completo

### 13.1 Cenário A — vitória preparada

```text
1. Abrir Main.tscn.
2. Coletar madeira suficiente.
3. Construir barricada.
4. Atribuir NpcCollector.
5. Atribuir NpcDefender.
6. Iniciar onda.
7. Defender núcleo.
8. Matar inimigos restantes.
```

Resultado esperado:

```text
O núcleo sobrevive.
A onda termina.
GameManager declara vitória.
HUD exibe vitória.
```

### 13.2 Cenário B — derrota por falta de preparação

```text
1. Abrir Main.tscn.
2. Não construir barricada.
3. Não atribuir defensor.
4. Iniciar onda.
5. Esperar inimigos atacarem núcleo.
```

Resultado esperado:

```text
O núcleo chega a 0 ou fica severamente ameaçado.
GameManager declara derrota se núcleo cair.
HUD exibe derrota.
```

### 13.3 Cenário C — utilidade dos NPCs

```text
1. Jogar uma sessão sem NPCs.
2. Jogar uma sessão usando NpcCollector e NpcDefender.
3. Comparar resultado.
```

Resultado esperado:

```text
Usar NPCs deve melhorar a chance de sobrevivência ou reduzir pressão do jogador.
```

---

## 14. Testes negativos

Testes negativos validam falhas esperadas.

```text
[ ] Tentar construir barricada com madeira 0.
[ ] Tentar interagir olhando para objeto sem interact(actor).
[ ] Destruir núcleo antes da onda terminar.
[ ] Matar todos inimigos sem núcleo destruído.
[ ] Tentar iniciar onda duas vezes.
[ ] Matar EnemyBasic e verificar se contagem não fica negativa.
[ ] Gastar madeira até 0 e verificar se não fica negativa.
```

Resultado esperado:

```text
O jogo deve falhar de forma controlada, sem travar e sem estado impossível.
```

---

## 15. Testes de usabilidade mínima

Objetivo: verificar se o protótipo é compreensível mesmo com assets temporários.

```text
[ ] O jogador entende onde está o núcleo.
[ ] O jogador entende onde coletar madeira.
[ ] O jogador entende que precisa construir defesa.
[ ] O jogador entende quando a onda começou.
[ ] O jogador entende quando ganhou.
[ ] O jogador entende quando perdeu.
[ ] O jogador percebe utilidade do NpcCollector.
[ ] O jogador percebe utilidade do NpcDefender.
```

Critério mínimo:

```text
Mesmo com visual simples, a sessão precisa comunicar objetivo, ameaça e resultado.
```

---

## 16. Testes de estabilidade

Executar pelo menos 3 sessões completas:

| Execução | Resultado esperado |
|---|---|
| Sessão 1 | Vitória possível sem travamento |
| Sessão 2 | Derrota possível sem travamento |
| Sessão 3 | Loop completo repetido sem erro crítico |

Registrar:

```text
duração da sessão;
resultado;
erros no console;
bugs observados;
comportamento estranho;
decisão de correção.
```

---

## 17. Registro de bugs

Usar este modelo:

```text
ID do bug:
Data:
Versão/build:
Cena:
Sistema afetado:
Severidade: S0/S1/S2/S3/S4
Descrição:
Passos para reproduzir:
Resultado esperado:
Resultado obtido:
Print/log, se houver:
Decisão: corrigir agora / backlog / cortar / ignorar.
```

### 17.1 Tabela rápida de bugs

| ID | Severidade | Sistema | Descrição | Status | Decisão |
|---|---|---|---|---|---|
| BUG-001 | S0/S1/S2/S3/S4 | A preencher | A preencher | TODO | A preencher |

---

## 18. Template de execução de teste

```text
Data:
Testador:
Versão da Godot:
Cena testada:
Wave relacionada:
Casos executados:
Resultado geral: PASS / FAIL / PARTIAL
Bugs encontrados:
Sistemas afetados:
Decisão:
Próxima ação:
```

### 18.1 Exemplo de resultado

```text
Data: 2026-XX-XX
Testador: Francisco
Versão da Godot: 4.x
Cena testada: Main.tscn
Wave relacionada: Wave 5
Casos executados: TC-013, TC-014
Resultado geral: PARTIAL
Bugs encontrados: EnemyBasic morre, mas enemies_alive não reduz.
Sistemas afetados: EnemyBasic, WaveManager
Decisão: corrigir antes de avançar para NPC defensor.
Próxima ação: revisar sinal de morte do EnemyBasic.
```

---

## 19. Checklist final antes de concluir o Marco 0.1

```text
[ ] TC-001 passou.
[ ] TC-002 passou.
[ ] TC-003 passou.
[ ] TC-004 passou.
[ ] TC-005 passou.
[ ] TC-006 passou.
[ ] TC-007 passou.
[ ] TC-008 passou.
[ ] TC-009 passou.
[ ] TC-010 passou.
[ ] TC-011 passou.
[ ] TC-012 passou.
[ ] TC-013 passou.
[ ] TC-014 passou.
[ ] TC-015 passou.
[ ] TC-016 passou.
[ ] TC-017 passou.
[ ] TC-018 passou.
[ ] TC-019 passou.
[ ] TC-020 passou.
[ ] 3 sessões completas foram executadas.
[ ] Nenhum bug S0 aberto.
[ ] Nenhum bug S1 aberto.
[ ] Bugs S2 foram registrados.
[ ] Itens fora de escopo foram movidos para backlog futuro.
[ ] Vitória e derrota são claras.
```

---

## 20. Resumo final do plano de testes

```text
O plano de testes do Marco 0.1 usa teste manual orientado a checklist.
O foco é validar primeira invasão jogável, não polimento final.
Os testes cobrem Player, interação, madeira, núcleo, barricada, inimigo, onda, NPCs, HUD, vitória e derrota.
O Marco 0.1 só pode ser concluído se TC-001 a TC-020 passarem ou se falhas restantes forem registradas como não bloqueantes.
Bugs S0 e S1 impedem avanço.
```
