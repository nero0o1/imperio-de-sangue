# 14_ROADMAP.md

# Império de Sangue — Roadmap

| Campo | Valor |
|---|---|
| Documento | Roadmap |
| Projeto | Império de Sangue |
| Versão do documento | 1.0 |
| Marco base | Marco 0.1 — Primeira invasão jogável |
| Engine alvo | Godot 4.x |
| Linguagem alvo | GDScript |
| Documento anterior | 13_CHANGELOG.md |
| Próximo documento natural | 15_RELEASE_CRITERIA.md |
| Finalidade | Organizar evolução por marcos técnicos e por evolução jogável do protótipo |
| Status | Roadmap inicial de longo prazo |

> Este roadmap não é promessa de entrega.  
> Ele é uma sequência racional para evoluir o projeto sem pular do conceito para um jogo grande demais.

---

## 1. Finalidade do documento

Este arquivo organiza o caminho evolutivo de **Império de Sangue**.

Ele responde:

```text
Qual é o próximo marco depois do Marco 0.1?
O que cada marco precisa entregar?
Qual evolução técnica é esperada?
Qual evolução jogável é esperada?
Quais sistemas entram depois e quais devem esperar?
Quais critérios permitem avançar de um marco para outro?
Quando cortar escopo?
```

O roadmap deve evitar dois erros:

```text
1. Implementar sistemas grandes antes do loop mínimo funcionar.
2. Ficar eternamente documentando sem produzir versão jogável.
```

---

## 2. Princípio do roadmap

Regra central:

```text
Cada marco deve gerar uma versão mais jogável, não apenas mais código.
```

### 2.1 Prioridade de evolução

| Prioridade | Eixo | Motivo |
|---|---|---|
| 1 | Loop jogável | Sem loop, não há jogo testável |
| 2 | Clareza | Jogador precisa entender objetivo, ameaça e resultado |
| 3 | Sistemas essenciais | Construção, NPCs, inimigos, recursos, onda |
| 4 | Profundidade | Diplomacia, magia, economia e variedade entram depois |
| 5 | Arte final | Deve vir depois da prova mecânica |

---

## 3. Leitura por marcos técnicos e evolução jogável

Este roadmap usa duas leituras ao mesmo tempo.

### 3.1 Marcos técnicos

Focam em:

```text
arquitetura;
script;
cenas;
autoloads;
testes;
build;
assets;
performance;
ferramentas de produção.
```

### 3.2 Evolução jogável

Foca em:

```text
o que o jogador consegue fazer;
qual decisão o jogador toma;
qual ameaça existe;
como o jogador vence;
como o jogador perde;
o que muda entre uma sessão e outra.
```

### 3.3 Regra

```text
Um marco só avança se tiver ganho técnico e ganho jogável.
```

---

## 4. Visão geral dos marcos

| Marco | Nome | Objetivo técnico | Objetivo jogável | Status |
|---|---|---|---|---|
| M0.0 | Fundação documental | Criar documentos base | Clarear escopo antes de codar | Em andamento/concluído |
| M0.1 | Primeira invasão jogável | Criar loop mínimo | Coletar, construir, defender, vencer/perder | Próximo foco |
| M0.2 | Sistemas essenciais expandidos | Melhorar construção, recursos e NPCs | Mais escolhas na preparação | Futuro |
| M0.3 | Profundidade de gestão e combate | Adicionar variedade controlada | Sessões com decisões diferentes | Futuro |
| M0.4 | Vertical slice controlado | Unir mecânica, UI, visual e áudio temporário | Experiência curta apresentável | Futuro |
| M0.5 | Protótipo público interno | Estabilizar build e feedback | Teste com pessoas próximas | Futuro |
| M1.0 | Versão mínima comercial futura | Preparar base publicável | Jogo mínimo vendável/baixável | Longo prazo |

---

## 5. Marco 0.0 — Fundação documental

### 5.1 Objetivo

Criar base documental suficiente para começar implementação sem perder direção.

### 5.2 Entregas documentais

```text
00_PROJECT_OVERVIEW.md
01_GAME_CONCEPT.md
02_PROTOTYPE_SCOPE.md
03_TECHNICAL_DESIGN.md
04_SYSTEMS_ARCHITECTURE.md
05_BACKLOG.md
06_AI_CODEX_RULES.md
07_TEST_PLAN.md
08_BUILD_NOTES.md
09_ASSET_GUIDE.md
10_RISK_REGISTER.md
11_DECISION_LOG.md
12_OPEN_QUESTIONS.md
13_CHANGELOG.md
14_ROADMAP.md
```

### 5.3 Critério de conclusão

```text
Documentos base criados.
Backlog do Marco 0.1 claro.
Riscos principais mapeados.
Perguntas bloqueantes identificadas.
Próxima ação de implementação definida.
```

### 5.4 Risco principal

```text
Continuar criando documentação além do necessário e atrasar a Wave 0/Wave 1.
```

---

## 6. Marco 0.1 — Primeira invasão jogável

### 6.1 Objetivo técnico

Criar o primeiro loop jogável em Godot 4.x.

### 6.2 Objetivo jogável

O jogador deve conseguir:

```text
andar pelo mapa;
interagir com objetos;
coletar madeira;
construir barricada;
usar NpcCollector;
usar NpcDefender;
iniciar/enfrentar uma onda;
defender o núcleo;
vencer ou perder.
```

### 6.3 Sistemas incluídos

```text
Player básico;
InteractionRaycast;
ResourceManager;
WoodNode;
SettlementCore;
BuildSpot;
Barricade;
EnemyBasic;
WaveManager;
NpcCollector;
NpcDefender;
HUD;
GameManager.
```

### 6.4 Fora do M0.1

```text
multiplayer;
save/load;
inventário completo;
diplomacia;
magia complexa;
economia ampla;
mapa procedural;
arte final;
áudio final;
múltiplos biomas;
múltiplas facções.
```

### 6.5 Critério de conclusão

```text
TC-001 a TC-020 passaram ou falhas restantes foram classificadas como não bloqueantes.
Nenhum bug S0/S1 aberto.
Vitória e derrota são claras.
Sessão completa cabe em 10 a 15 minutos.
```

---

## 7. Marco 0.2 — Expansão de sistemas essenciais

### 7.1 Objetivo técnico

Expandir os sistemas que já provaram funcionar no M0.1 sem mudar a arquitetura central.

### 7.2 Objetivo jogável

O jogador deve ter mais escolhas durante preparação e defesa.

### 7.3 Possíveis entregas

```text
2 a 3 tipos de construção simples;
2 a 3 recursos ou sub-recursos;
melhoria do sistema de tarefas dos NPCs;
mais um tipo de inimigo;
onda com pequena variação;
reparo simples de barricada ou núcleo;
feedback melhor de HUD;
primeiro balanceamento básico.
```

### 7.4 Critério para entrar no M0.2

```text
M0.1 jogável e validado.
Backlog do M0.2 criado.
Riscos do M0.1 revisados.
Decisões pendentes críticas resolvidas.
```

### 7.5 Critério de conclusão

```text
O jogador tem pelo menos 2 caminhos viáveis de preparação.
NPCs têm utilidade clara.
A segunda versão não quebra o loop do M0.1.
```

---

## 8. Marco 0.3 — Profundidade de gestão e combate

### 8.1 Objetivo técnico

Introduzir profundidade controlada sem transformar o jogo em RTS amplo cedo demais.

### 8.2 Objetivo jogável

Sessões devem começar a variar por decisão do jogador.

### 8.3 Possíveis entregas

```text
mais tipos de NPC;
mais tipos de inimigos;
primeiras decisões de alocação de trabalhadores;
produção simples de recurso;
melhoria de defesa;
primeiro sistema de ameaça escalável;
primeiro protótipo de magia simples, se ainda fizer sentido;
primeiro sistema de upgrades simples.
```

### 8.4 Fora do M0.3

```text
mundo aberto completo;
diplomacia ampla;
campanha narrativa longa;
árvore de tecnologia extensa;
IA complexa de facções.
```

### 8.5 Critério de conclusão

```text
Duas sessões com decisões diferentes devem gerar resultados perceptivelmente diferentes.
O jogo ainda deve caber em mapa pequeno/controlado.
```

---

## 9. Marco 0.4 — Vertical slice controlado

### 9.1 Objetivo técnico

Criar uma fatia apresentável do jogo, ainda pequena, com mecânica, UI, assets temporários melhores e áudio mínimo.

### 9.2 Objetivo jogável

O jogador deve conseguir jogar uma sessão curta e entender a proposta sem explicação externa extensa.

### 9.3 Possíveis entregas

```text
menu inicial simples;
tela de vitória/derrota mais clara;
HUD mais legível;
assets temporários substituídos por assets próprios simples;
áudio mínimo de feedback;
tutorial textual curto;
melhoria de mapa;
balanceamento de primeira sessão.
```

### 9.4 Critério de conclusão

```text
Uma pessoa externa consegue jogar a sessão sem orientação constante.
Principais decisões do jogador são compreensíveis.
O jogo não depende de logs/debug para ser entendido.
```

---

## 10. Marco 0.5 — Protótipo público interno

### 10.1 Objetivo técnico

Preparar uma build para teste com pessoas próximas ou grupo controlado.

### 10.2 Objetivo jogável

Coletar feedback real de pessoas que não acompanharam a criação.

### 10.3 Possíveis entregas

```text
build exportada para Windows;
registro de feedback;
correção de bugs S0/S1/S2;
melhor onboarding;
melhoria mínima de performance;
primeiro pacote de assets permitidos;
controle de versão mais disciplinado;
changelog por release.
```

### 10.4 Critério de conclusão

```text
3 a 5 pessoas conseguem testar.
Feedback é registrado.
Bugs críticos são classificados.
Próxima direção do jogo fica mais clara.
```

---

## 11. Marco 1.0 — Versão futura mínima comercial

### 11.1 Objetivo técnico

Criar uma versão mínima publicável/baixável com qualidade suficiente para distribuição controlada.

### 11.2 Objetivo jogável

O jogador deve encontrar uma experiência curta, repetível e com progressão mínima.

### 11.3 Possíveis entregas

```text
save/load básico;
menu e configurações;
mais conteúdo jogável;
mais inimigos;
mais construções;
mais NPCs;
primeira camada de progressão;
assets com licença segura;
trilha/efeitos próprios ou licenciados;
build estável;
página de distribuição;
termos/licenças organizados.
```

### 11.4 Critério mínimo

```text
O jogo precisa ser jogável sem acompanhamento do desenvolvedor.
Não deve conter asset com licença incerta.
Não deve depender de debug para completar sessão.
```

---

## 12. Linha do tempo recomendada

Não usar datas rígidas no início. Usar sequência por evidência.

| Ordem | Marco | Condição para iniciar | Condição para concluir |
|---:|---|---|---|
| 1 | M0.0 | Conceito definido | Documentos base criados |
| 2 | M0.1 | Backlog claro | Loop jogável com vitória/derrota |
| 3 | M0.2 | M0.1 validado | Mais escolhas de preparação |
| 4 | M0.3 | Sistemas essenciais estáveis | Sessões variam por decisão |
| 5 | M0.4 | Gameplay compreensível | Vertical slice curto apresentável |
| 6 | M0.5 | Slice estável | Teste externo controlado |
| 7 | M1.0 | Feedback validado | Versão mínima publicável |

### 12.1 Regra temporal

```text
Não avançar por ansiedade.
Avançar por critério testado.
```

---

## 13. Dependências entre marcos

```text
M0.0 → M0.1
M0.1 → M0.2
M0.2 → M0.3
M0.3 → M0.4
M0.4 → M0.5
M0.5 → M1.0
```

### 13.1 Dependências críticas

| Dependência | Motivo |
|---|---|
| M0.1 antes de M0.2 | Sem loop mínimo, expansão é chute |
| M0.2 antes de M0.3 | Sem sistemas essenciais, profundidade vira bagunça |
| M0.3 antes de M0.4 | Vertical slice precisa de decisões reais |
| M0.4 antes de M0.5 | Teste externo exige experiência compreensível |
| M0.5 antes de M1.0 | Versão comercial precisa de feedback real |

---

## 14. Critérios de avanço entre marcos

Antes de avançar, confirmar:

```text
[ ] O marco atual tem critério de conclusão cumprido.
[ ] Não há bug S0/S1 aberto.
[ ] O changelog foi atualizado.
[ ] O risk register foi revisado.
[ ] O decision log recebeu decisões relevantes.
[ ] O backlog do próximo marco está claro.
[ ] O escopo do próximo marco não tenta resolver o jogo inteiro.
```

---

## 15. Critérios de corte de escopo

Cortar ou adiar quando:

```text
a tarefa não ajuda o marco atual;
a tarefa exige sistema futuro;
a tarefa bloqueia entrega jogável;
a tarefa depende de asset final;
a tarefa cria risco de licença;
a tarefa vem de sugestão da IA fora do backlog;
a tarefa não pode ser testada manualmente;
a tarefa aumenta complexidade sem melhorar o loop.
```

Destino dos cortes:

```text
backlog futuro;
perguntas em aberto;
decision log;
risk register.
```

---

## 16. Backlog futuro por categoria

### 16.1 Sistemas futuros

```text
save/load;
inventário;
crafting;
magia;
diplomacia;
facções;
progressão;
árvore de tecnologia;
economia avançada;
mapa maior;
IA de facções.
```

### 16.2 Conteúdo futuro

```text
mais NPCs;
mais inimigos;
mais construções;
mais recursos;
mais mapas;
mais eventos;
mais objetivos de sessão.
```

### 16.3 Produção futura

```text
assets finais;
áudio final;
menu final;
configurações;
exportação;
telemetria simples de teste;
controle de versão formal;
licenças organizadas.
```

---

## 17. Riscos por fase

| Marco | Risco principal | Mitigação |
|---|---|---|
| M0.0 | Documentar demais | Encerrar documentação base e iniciar Wave 0 |
| M0.1 | Loop não fechar | Reduzir sistemas ao mínimo jogável |
| M0.2 | Expandir antes de estabilizar | Manter 1 expansão por vez |
| M0.3 | Complexidade de NPC/inimigo | Limitar estados e variações |
| M0.4 | Polimento engolir gameplay | Polir só o que melhora compreensão |
| M0.5 | Feedback sem método | Usar formulário/checklist de teste |
| M1.0 | Risco comercial/licença | Usar apenas assets aprovados |

---

## 18. Indicadores de progresso

### 18.1 Indicadores técnicos

```text
número de tarefas P0 concluídas;
número de bugs S0/S1 abertos;
quantidade de sistemas obrigatórios funcionando;
quantidade de testes TC aprovados;
frequência de regressões.
```

### 18.2 Indicadores jogáveis

```text
jogador entende objetivo;
jogador consegue preparar defesa;
jogador consegue vencer;
jogador consegue perder;
NPCs mudam resultado da sessão;
construção muda resultado da sessão;
a sessão termina em 10 a 15 minutos no M0.1.
```

---

## 19. Decisões pendentes por marco

### M0.1

```text
Q-001 — Núcleo ativo ou fundado?
Q-002 — Onda manual ou automática?
Q-003 — Jogador ataca ou apenas comanda?
Q-004 — Barricada bloqueia ou absorve dano?
Q-005 — Papel do NPC defensor.
Q-006 — Coleta real ou abstrata.
Q-008 — NavigationAgent3D ou movimento direto.
Q-024 — Quando parar documentação e iniciar implementação.
```

### M0.2+

```text
magia simples;
reparo;
mais recursos;
mais construções;
mais inimigos;
mais NPCs;
progressão inicial.
```

---

## 20. Checklist de revisão do roadmap

Revisar o roadmap quando:

```text
[ ] M0.1 for concluído.
[ ] Algum risco bloqueante aparecer.
[ ] Uma decisão de escopo for revertida.
[ ] Feedback externo contradizer a direção atual.
[ ] A IA/Codex sugerir mudança estrutural relevante.
[ ] O projeto ficar mais de 2 semanas sem avanço jogável.
```

---

## 21. Resumo final do roadmap

```text
O roadmap organiza o projeto por marcos técnicos e evolução jogável.
M0.0 cria a fundação documental.
M0.1 deve entregar a primeira invasão jogável.
M0.2 expande sistemas essenciais.
M0.3 adiciona profundidade controlada.
M0.4 cria uma vertical slice apresentável.
M0.5 prepara teste externo controlado.
M1.0 representa uma versão mínima comercial futura.
O avanço entre marcos depende de critérios testados, não de vontade de adicionar sistemas.
```
