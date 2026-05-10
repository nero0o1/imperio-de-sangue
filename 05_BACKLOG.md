# 05_BACKLOG.md

# Império de Sangue — Backlog do Protótipo

| Campo | Valor |
|---|---|
| Documento | Backlog do Protótipo |
| Projeto | Império de Sangue |
| Versão do documento | 1.0 |
| Marco coberto | Marco 0.1 — Primeira invasão jogável |
| Engine alvo | Godot 4.x |
| Linguagem alvo | GDScript |
| Documento anterior | 04_SYSTEMS_ARCHITECTURE.md |
| Próximo documento natural | 06_AI_CODEX_RULES.md |
| Finalidade | Transformar escopo e arquitetura em tarefas executáveis |
| Status | Backlog inicial para implementação |

> Este backlog existe para transformar planejamento em execução.  
> Cada tarefa deve gerar um resultado testável dentro da Godot.

---

## 1. Finalidade do documento

Este arquivo organiza as tarefas necessárias para construir o **Marco 0.1 — Primeira invasão jogável**.

O backlog deve responder:

```text
O que fazer primeiro?
Qual tarefa depende de qual?
Como saber se a tarefa terminou?
Qual prioridade de cada tarefa?
Qual wave cada tarefa pertence?
O que deve ficar fora do protótipo inicial?
```

Este documento não é:

```text
GDD completo;
manual de código;
roteiro narrativo;
lista de ideias futuras sem prioridade;
substituto do design técnico.
```

---

## 2. Regras de uso do backlog

### 2.1 Regra principal

Só entra no backlog do Marco 0.1 tarefa que ajude diretamente a validar:

```text
coleta de madeira;
construção de barricada;
uso de 2 NPCs funcionais;
inimigo básico;
onda curta;
vitória ou derrota clara.
```

### 2.2 Regra de execução

```text
Executar uma wave por vez.
Não começar sistemas futuros antes do loop mínimo funcionar.
Não polir visual antes de validar mecânica.
Não criar abstrações grandes antes de ter 1 implementação funcionando.
```

### 2.3 Regra para mudar tarefas

Qualquer alteração relevante deve ser registrada em:

```text
11_DECISION_LOG.md
13_CHANGELOG.md
```

---

## 3. Legenda operacional

### 3.1 Status

| Status | Significado |
|---|---|
| TODO | Ainda não iniciado |
| DOING | Em execução |
| BLOCKED | Bloqueado por dependência ou erro |
| TESTING | Implementado e aguardando teste |
| DONE | Concluído e testado |
| CUT | Removido do Marco 0.1 |

### 3.2 Prioridade

| Prioridade | Significado |
|---|---|
| P0 | Obrigatório para o protótipo abrir ou funcionar |
| P1 | Obrigatório para validar o loop jogável |
| P2 | Importante, mas pode esperar se houver bloqueio |
| P3 | Melhoria ou polimento simples |
| PX | Fora do Marco 0.1 |

### 3.3 Tipo

| Tipo | Significado |
|---|---|
| SETUP | Preparação de projeto |
| CODE | Script ou lógica |
| SCENE | Cena Godot |
| UI | Interface |
| TEST | Teste manual ou validação |
| DOC | Documentação ou registro |
| FIX | Correção |

---

## 4. Visão geral das waves

| Wave | Nome | Objetivo |
|---|---|---|
| 0 | Preparação do projeto | Criar base do projeto e estrutura mínima |
| 1 | Player e interação básica | Controlar jogador e interagir com objetos |
| 2 | Recursos e madeira | Coletar e armazenar madeira |
| 3 | Núcleo e construção | Criar núcleo, barricada e custo de construção |
| 4 | Inimigo básico | Criar ameaça mínima funcional |
| 5 | Sistema de onda | Spawnar inimigos e detectar fim da onda |
| 6 | NPC coletor | Automatizar coleta simples |
| 7 | NPC defensor | Defender contra inimigo básico |
| 8 | HUD, vitória e derrota | Fechar estados finais e feedback mínimo |
| 9 | Integração e estabilização | Testar o loop completo e cortar excesso |

---

## 5. Wave 0 — Preparação do projeto

Objetivo: criar a base mínima do projeto Godot e da organização de arquivos.

| ID | Tarefa | Tipo | Prioridade | Depende de | Critério de aceite | Status |
|---|---|---|---|---|---|---|
| W0-01 | Criar projeto Godot 4.x | SETUP | P0 | Nenhuma | Projeto abre sem erro | TODO |
| W0-02 | Criar estrutura de pastas inicial | SETUP | P0 | W0-01 | Pastas `scenes/`, `scripts/`, `assets_temp/`, `docs/` existem | TODO |
| W0-03 | Criar `Main.tscn` | SCENE | P0 | W0-02 | Cena principal existe e pode ser aberta | TODO |
| W0-04 | Criar `TestMap.tscn` simples | SCENE | P0 | W0-03 | Mapa pequeno com chão, limites e área de teste | TODO |
| W0-05 | Configurar `Main.tscn` como cena principal | SETUP | P0 | W0-03 | Executar projeto abre a cena principal | TODO |

### 5.1 Saída esperada da Wave 0

```text
Projeto abre.
Cena principal carrega.
Mapa de teste existe.
Estrutura de pastas está pronta.
```

---

## 6. Wave 1 — Player e interação básica

Objetivo: permitir controle em primeira pessoa e interação genérica com objetos.

| ID | Tarefa | Tipo | Prioridade | Depende de | Critério de aceite | Status |
|---|---|---|---|---|---|---|
| W1-01 | Criar `Player.tscn` com `CharacterBody3D` | SCENE | P0 | W0-04 | Player aparece no mapa | TODO |
| W1-02 | Implementar movimento FPS em `player.gd` | CODE | P0 | W1-01 | Jogador anda e olha ao redor | TODO |
| W1-03 | Adicionar `Camera3D` e `RayCast3D` | SCENE | P0 | W1-01 | Raycast aponta para frente da câmera | TODO |
| W1-04 | Criar `interaction_raycast.gd` | CODE | P1 | W1-03 | Raycast detecta objeto à frente | TODO |
| W1-05 | Implementar chamada genérica `interact(actor)` | CODE | P1 | W1-04 | Player interage sem conhecer classe concreta | TODO |

### 6.1 Saída esperada da Wave 1

```text
Jogador controla câmera e movimento.
Jogador consegue acionar interação genérica.
```

---

## 7. Wave 2 — Recursos e madeira

Objetivo: implementar madeira como recurso global mínimo.

| ID | Tarefa | Tipo | Prioridade | Depende de | Critério de aceite | Status |
|---|---|---|---|---|---|---|
| W2-01 | Criar `ResourceManager` como Autoload | CODE | P0 | W0-05 | Autoload acessível globalmente | TODO |
| W2-02 | Implementar `wood`, `add_wood`, `spend_wood` | CODE | P0 | W2-01 | Madeira nunca fica negativa | TODO |
| W2-03 | Criar `WoodNode.tscn` e `wood_node.gd` | SCENE | P1 | W1-05, W2-01 | Interagir com madeira aumenta estoque | TODO |
| W2-04 | Emitir sinal `wood_changed` | CODE | P1 | W2-02 | Mudança de madeira dispara sinal | TODO |

### 7.1 Saída esperada da Wave 2

```text
Jogador coleta madeira.
ResourceManager armazena madeira.
O sistema impede gasto sem recurso suficiente.
```

---

## 8. Wave 3 — Núcleo e construção

Objetivo: criar núcleo da base, barricada e ponto de construção com custo em madeira.

| ID | Tarefa | Tipo | Prioridade | Depende de | Critério de aceite | Status |
|---|---|---|---|---|---|---|
| W3-01 | Criar `SettlementCore.tscn` | SCENE | P0 | W0-04 | Núcleo aparece no mapa | TODO |
| W3-02 | Implementar vida do núcleo em `settlement_core.gd` | CODE | P0 | W3-01 | Núcleo recebe dano e chega a 0 | TODO |
| W3-03 | Criar `Barricade.tscn` e `barricade.gd` | SCENE | P1 | W3-01 | Barricada recebe dano e pode ser destruída | TODO |
| W3-04 | Criar `BuildSpot.tscn` e `build_spot.gd` | SCENE | P1 | W2-02, W3-03 | BuildSpot instancia barricada | TODO |
| W3-05 | Bloquear construção sem madeira suficiente | CODE | P1 | W3-04 | Construção falha se `spend_wood` retornar false | TODO |

### 8.1 Saída esperada da Wave 3

```text
Núcleo existe e pode ser destruído.
Barricada pode ser construída usando madeira.
Construção sem recurso é bloqueada.
```

---

## 9. Wave 4 — Inimigo básico

Objetivo: criar inimigo simples que ataca núcleo ou barricada.

| ID | Tarefa | Tipo | Prioridade | Depende de | Critério de aceite | Status |
|---|---|---|---|---|---|---|
| W4-01 | Criar `EnemyBasic.tscn` | SCENE | P0 | W3-01 | Inimigo aparece no mapa | TODO |
| W4-02 | Implementar vida e dano em `enemy_basic.gd` | CODE | P0 | W4-01 | Inimigo recebe dano e morre | TODO |
| W4-03 | Implementar movimento simples até alvo | CODE | P0 | W4-01, W3-01 | Inimigo anda até núcleo ou barricada | TODO |
| W4-04 | Implementar ataque simples | CODE | P0 | W4-03 | Inimigo reduz vida do alvo | TODO |

### 9.1 Saída esperada da Wave 4

```text
Inimigo básico consegue ameaçar núcleo ou barricada.
```

---

## 10. Wave 5 — Sistema de onda

Objetivo: controlar início, spawn, contagem e fim da onda inimiga.

| ID | Tarefa | Tipo | Prioridade | Depende de | Critério de aceite | Status |
|---|---|---|---|---|---|---|
| W5-01 | Criar `WaveManager` como Autoload | CODE | P0 | W4-01 | Autoload acessível globalmente | TODO |
| W5-02 | Implementar `start_wave()` | CODE | P0 | W5-01 | Onda pode ser iniciada por teste | TODO |
| W5-03 | Implementar spawn de 3 a 5 inimigos | CODE | P1 | W5-02, W4-01 | Inimigos aparecem em spawn point | TODO |
| W5-04 | Detectar fim da onda | CODE | P1 | W5-03, W4-02 | Onda termina quando inimigos morrem | TODO |

### 10.1 Saída esperada da Wave 5

```text
Uma onda curta começa, cria inimigos e termina.
```

---

## 11. Wave 6 — NPC coletor

Objetivo: criar NPC que coleta madeira e deposita no estoque global.

| ID | Tarefa | Tipo | Prioridade | Depende de | Critério de aceite | Status |
|---|---|---|---|---|---|---|
| W6-01 | Criar `NpcBase` com estados mínimos | CODE | P1 | W1-05 | NPC possui estado `IDLE` e transições simples | TODO |
| W6-02 | Criar `NpcCollector.tscn` | SCENE | P1 | W6-01 | Coletor aparece no mapa | TODO |
| W6-03 | Implementar atribuição de coleta por interação | CODE | P1 | W6-02, W1-05 | Player consegue mandar coletor trabalhar | TODO |
| W6-04 | Implementar ciclo coletar → retornar → depositar | CODE | P1 | W6-03, W2-01 | Estoque aumenta sem coleta manual contínua | TODO |

### 11.1 Saída esperada da Wave 6

```text
NPC coletor tem utilidade econômica perceptível.
```

---

## 12. Wave 7 — NPC defensor

Objetivo: criar NPC que ajuda contra inimigos durante a onda.

| ID | Tarefa | Tipo | Prioridade | Depende de | Critério de aceite | Status |
|---|---|---|---|---|---|---|
| W7-01 | Criar `NpcDefender.tscn` | SCENE | P1 | W6-01, W4-01 | Defensor aparece no mapa | TODO |
| W7-02 | Implementar atribuição de defesa por interação | CODE | P1 | W7-01, W1-05 | Player consegue mandar defensor defender | TODO |
| W7-03 | Implementar detecção de inimigo próximo | CODE | P1 | W7-02, W4-01 | Defensor encontra inimigo em alcance | TODO |
| W7-04 | Implementar ataque simples do defensor | CODE | P1 | W7-03, W4-02 | Defensor reduz vida do inimigo | TODO |

### 12.1 Saída esperada da Wave 7

```text
NPC defensor reduz pressão da invasão.
```

---

## 13. Wave 8 — HUD, vitória e derrota

Objetivo: exibir estado mínimo e fechar resultado da sessão.

| ID | Tarefa | Tipo | Prioridade | Depende de | Critério de aceite | Status |
|---|---|---|---|---|---|---|
| W8-01 | Criar `HUD.tscn` e `hud.gd` | UI | P1 | W0-05 | HUD aparece na tela | TODO |
| W8-02 | Mostrar madeira e vida do núcleo | UI | P1 | W2-04, W3-02, W8-01 | HUD atualiza valores por sinal ou chamada controlada | TODO |
| W8-03 | Criar `GameManager` como Autoload | CODE | P0 | W0-05 | Estado global acessível | TODO |
| W8-04 | Implementar vitória e derrota | CODE | P0 | W3-02, W5-04, W8-03 | HUD mostra vitória ou derrota clara | TODO |

### 13.1 Saída esperada da Wave 8

```text
Jogador entende madeira, vida do núcleo e resultado final.
```

---

## 14. Wave 9 — Integração e estabilização

Objetivo: rodar o loop completo e corrigir falhas críticas.

| ID | Tarefa | Tipo | Prioridade | Depende de | Critério de aceite | Status |
|---|---|---|---|---|---|---|
| W9-01 | Montar fluxo completo em `Main.tscn` | TEST | P0 | W1-05, W2-04, W3-05, W5-04, W8-04 | Sessão completa pode ser jogada | TODO |
| W9-02 | Testar cenário de vitória | TEST | P0 | W9-01 | Jogador consegue vencer ao preparar base | TODO |
| W9-03 | Testar cenário de derrota | TEST | P0 | W9-01 | Jogador consegue perder por núcleo destruído ou morte | TODO |
| W9-04 | Registrar bugs e cortar excessos | DOC | P1 | W9-02, W9-03 | Bugs críticos registrados e itens fora de escopo removidos | TODO |

### 14.1 Saída esperada da Wave 9

```text
Marco 0.1 jogável, com vitória e derrota possíveis.
```

---

## 15. Bugs e correções

Usar esta seção durante testes.

| ID | Severidade | Descrição | Sistema afetado | Status | Decisão |
|---|---|---|---|---|---|
| BUG-001 | S0/S1/S2/S3 | A preencher | A preencher | TODO | Corrigir / adiar / cortar |

### 15.1 Severidade

| Severidade | Definição | Ação |
|---|---|---|
| S0 | Projeto ou cena não abre | Corrigir imediatamente |
| S1 | Impede vitória ou derrota | Corrigir antes de avançar |
| S2 | Sistema obrigatório funciona parcialmente | Corrigir antes do Marco 0.2 |
| S3 | Feedback, UI ou visual menor | Pode ir para backlog futuro |
| S4 | Polimento | Adiar |

---

## 16. Itens fora do Marco 0.1

Estes itens não devem ser implementados agora.

| Item | Motivo | Destino |
|---|---|---|
| Save/load | Sessão curta não precisa persistência | Marco futuro |
| Inventário completo | Contador global basta | Marco futuro |
| Crafting complexo | Aumenta UI e regras | Backlog futuro |
| Mapa procedural | Complexidade desnecessária | Futuro distante |
| Diplomacia | Não valida primeira invasão | Documento futuro |
| Magia avançada | Pode explodir escopo | Após defesa funcionar |
| Arte final | Não valida mecânica | Produção visual futura |
| Multiplayer | Complexidade alta | Fora do protótipo inicial |
| Múltiplas ondas | Primeiro validar 1 onda | Backlog futuro |
| 5 NPCs completos | Primeiro validar 2 NPCs | Backlog futuro |
| 5 inimigos completos | Primeiro validar 1 inimigo | Backlog futuro |

---

## 17. Definition of Ready

Uma tarefa está pronta para começar quando:

```text
tem ID;
tem descrição objetiva;
tem prioridade;
tem dependência explícita;
tem critério de aceite;
cabe no Marco 0.1;
não depende de sistema fora do escopo;
pode ser testada na Godot.
```

---

## 18. Definition of Done

Uma tarefa só vira `DONE` quando:

```text
foi implementada;
a cena abre sem erro;
o comportamento esperado funciona;
o critério de aceite foi testado;
não quebrou tarefa anterior;
se gerou decisão técnica, foi registrada;
se gerou bug, foi registrado.
```

---

## 19. Ordem mínima de execução

Ordem recomendada sem paralelismo:

```text
W0-01 → W0-02 → W0-03 → W0-04 → W0-05
W1-01 → W1-02 → W1-03 → W1-04 → W1-05
W2-01 → W2-02 → W2-03 → W2-04
W3-01 → W3-02 → W3-03 → W3-04 → W3-05
W4-01 → W4-02 → W4-03 → W4-04
W5-01 → W5-02 → W5-03 → W5-04
W6-01 → W6-02 → W6-03 → W6-04
W7-01 → W7-02 → W7-03 → W7-04
W8-01 → W8-02 → W8-03 → W8-04
W9-01 → W9-02 → W9-03 → W9-04
```

### 19.1 Primeira entrega jogável mínima

A primeira entrega realmente jogável começa a aparecer ao concluir:

```text
W1 + W2 + W3 + W4 + W5 + W8
```

NPCs entram depois para validar a camada de gestão.

---

## 20. Modelo de prompt para IA/Codex

Usar este modelo para pedir código sem expandir escopo:

```text
Projeto: Império de Sangue.
Engine: Godot 4.x.
Linguagem: GDScript.
Marco atual: 0.1 — Primeira invasão jogável.
Tarefa do backlog: [ID e nome da tarefa].
Dependências já existentes: [listar].
Arquitetura obrigatória:
- GameManager decide vitória/derrota.
- ResourceManager controla madeira.
- WaveManager controla onda.
- HUD só exibe estado.
- Player interage usando interact(actor).
Não criar sistemas fora do Marco 0.1.
Não adicionar multiplayer, save/load, inventário completo, diplomacia ou mundo procedural.
Entregar código simples, testável e compatível com Godot 4.x.
```

---

## 21. Checklist final do backlog

Antes de iniciar implementação pesada, confirmar:

```text
[ ] Todas as tarefas P0 estão claras.
[ ] Todas as tarefas P1 têm critério de aceite.
[ ] Nenhuma tarefa depende de sistema fora do Marco 0.1.
[ ] O backlog começa com projeto, mapa, player e interação.
[ ] O backlog não começa por arte final.
[ ] O backlog não começa por diplomacia.
[ ] O backlog não começa por magia avançada.
[ ] Há teste de vitória.
[ ] Há teste de derrota.
[ ] Há seção de bugs.
[ ] Há regra para cortar escopo.
```

---

## 22. Resumo final do backlog

```text
O backlog do Marco 0.1 é organizado por waves.
A prioridade é criar uma primeira invasão jogável.
O fluxo mínimo é: jogador → interação → madeira → núcleo → barricada → inimigo → onda → NPCs → HUD → vitória/derrota.
Cada tarefa tem ID, prioridade, dependência e critério de aceite.
Itens que não validam a primeira invasão ficam fora.
```
