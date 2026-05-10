# 00_PROJECT_OVERVIEW.md

# Império de Sangue — Visão Geral do Projeto

> Arquivo zero do projeto.  
> Serve como porta de entrada, controle de direção e referência rápida para desenvolvimento.

---

## 1. Identificação

| Campo | Definição |
|---|---|
| Nome provisório | Império de Sangue |
| Tipo de projeto | Protótipo jogável de hobby solo |
| Plataforma inicial | PC |
| Engine | Godot 4.x |
| Linguagem principal | GDScript |
| Perspectiva | Primeira pessoa |
| Gênero dominante | RPG de ação em primeira pessoa com gestão tática de assentamento |
| Subgênero | Sandbox, defesa de base, fantasia sombria medieval |
| Modelo de desenvolvimento | Criador solo com apoio intensivo de IA para código, documentação, testes, assets temporários e organização de tarefas |

---

## 2. Declaração curta do projeto

**Império de Sangue** é um RPG de ação em primeira pessoa com gestão tática de assentamento, no qual o jogador começa como um nobre exilado tentando transformar uma região hostil em um território defensável.

O jogador explora, coleta recursos, funda uma base, atribui funções a NPCs, constrói estruturas defensivas, obtém magia roubada de fontes hostis e tenta sobreviver à primeira invasão.

---

## 3. Objetivo do protótipo

O objetivo do protótipo é provar se a combinação abaixo gera uma experiência jogável interessante:

```text
Primeira pessoa
+ exploração hostil
+ coleta de recursos
+ fundação de assentamento
+ alocação de NPCs
+ construção funcional
+ preparação defensiva
+ invasão inimiga
= decisão tática compreensível em sessão curta
```

O protótipo não busca acabamento comercial imediato. Ele deve validar o núcleo jogável antes de expansão narrativa, econômica, diplomática ou visual.

---

## 4. Experiência central desejada

O jogador deve sentir que está reconstruindo poder a partir de quase nada.

A progressão emocional e mecânica da sessão deve seguir esta ordem:

```text
Sobreviver
→ organizar pessoas
→ construir uma base mínima
→ ler a ameaça
→ preparar defesa
→ enfrentar invasão
→ vencer ou perder por decisões próprias
```

---

## 5. Loop principal do jogo

```text
Explorar
→ Coletar
→ Fundar
→ Atribuir NPCs
→ Produzir / Construir
→ Obter informação
→ Defender
→ Avaliar resultado
```

### 5.1 Loop detalhado

| Etapa | Ação do jogador | Resultado esperado |
|---|---|---|
| Explorar | Patrulhar a área inicial | Encontrar recursos, inimigos e pontos de risco |
| Coletar | Coletar manualmente ou mandar NPCs coletarem | Gerar madeira, pedra e essência mágica |
| Fundar | Criar o núcleo inicial do assentamento | Liberar estruturas básicas |
| Atribuir | Definir funções dos NPCs | Ativar ciclos de trabalho |
| Produzir | Construir, reparar ou melhorar estruturas | Aumentar chance de sobreviver |
| Informar | Usar batedor ou torre de vigia | Revelar rota, tipo ou tempo de ataque |
| Defender | Posicionar NPCs e lutar junto | Sobreviver ou perder o assentamento |

---

## 6. Tensão principal do jogo

O jogador nunca deve ter pessoas suficientes para fazer tudo ao mesmo tempo.

A tensão principal vem da alocação:

```text
NPC coletando recurso
= mais material para construção
= menos defesa imediata

NPC construindo muralha
= base mais protegida
= menos recurso sendo coletado

NPC patrulhando
= ameaça revelada antes
= menos presença dentro da base

NPC defendendo
= maior chance de sobreviver à invasão
= menor crescimento econômico
```

A decisão relevante não é “fazer tudo”, mas escolher o que sacrificar.

---

## 7. Escopo macro do protótipo conceitual

Este é o alvo completo do protótipo jogável definido no conceito:

| Categoria | Alvo |
|---|---|
| Mapa | 1 território hostil pequeno |
| Jogador | 1 personagem em primeira pessoa |
| NPCs | 5 NPCs funcionais |
| Inimigos | 5 tipos de inimigo |
| Edifícios | Cabana Central, Armazém, Oficina/Ferraria, Torre de Vigia, Muralha/Torre defensiva e Salão de Conselho/Alianças |
| Magia | 1 magia roubada aplicável ao jogador ou à base |
| Invasão | 1 onda curta influenciada por preparação/patrulha |
| Sessão alvo | 10 a 15 minutos |

---

## 8. Primeiro marco técnico recomendado

Antes de buscar o protótipo completo, o desenvolvimento deve começar por uma fatia vertical mínima.

## Marco 0.1 — Base jogável mínima

### Deve conter

```text
1 mapa pequeno
1 jogador FPS
1 sistema de interação por Raycast
1 recurso coletável
1 ResourceManager simples
1 núcleo de assentamento
1 barricada ou defesa simples
2 NPCs funcionais
1 inimigo básico
1 onda curta
1 condição de vitória
1 condição de derrota
```

### Não deve conter ainda

```text
Multiplayer
Save/load complexo
Mundo aberto grande
Narrativa profunda de NPCs
Árvore diplomática ampla
Economia completa
5 inimigos completos
5 NPCs totalmente polidos
Sistema de magia avançado
Cutscenes
Sistema político complexo
```

---

## 9. Condição de vitória do protótipo

O jogador vence se:

```text
1. fundar o assentamento;
2. organizar pelo menos parte dos NPCs;
3. preparar defesa mínima;
4. sobreviver à primeira invasão;
5. manter o núcleo do assentamento funcional até o fim da onda.
```

---

## 10. Condição de derrota do protótipo

O jogador perde se:

```text
1. morrer;
2. o núcleo do assentamento for destruído;
3. NPCs essenciais forem neutralizados antes do fim da invasão;
4. a base ficar incapaz de resistir à primeira onda.
```

---

## 11. Sistemas principais do projeto

| Sistema | Responsabilidade |
|---|---|
| Player System | Movimento, câmera, combate básico e interação |
| Interaction System | Detectar objetos interativos por Raycast |
| Resource System | Controlar recursos coletáveis e estoque |
| Settlement System | Controlar núcleo da base e estado do assentamento |
| Building System | Construção, reparo e estruturas funcionais |
| NPC System | Estados, funções e tarefas dos NPCs |
| Enemy System | Comportamento básico dos inimigos |
| Wave System | Controle da invasão |
| UI System | Mostrar estado mínimo ao jogador |
| Magic System | Aplicar uma magia roubada simples |

---

## 12. NPCs do protótipo completo

| NPC | Função principal | Uso no jogo |
|---|---|---|
| Coletor | Coleta de recurso | Acelera madeira, pedra e transporte |
| Construtor | Construção e reparo | Cria e mantém estruturas |
| Ferreiro/Artesão | Produção | Cria ferramentas, armas ou melhorias |
| Batedor | Patrulha e informação | Revela rota, tipo ou tempo da ameaça |
| Guardião/Guerreiro | Defesa e ataque | Protege a base e segura linha defensiva |

Para o Marco 0.1, começar apenas com:

```text
Coletor
Guardião/Guerreiro
```

Motivo: esses dois NPCs já testam o conflito principal entre economia e defesa.

---

## 13. Inimigos do protótipo completo

O conceito completo prevê 5 tipos de inimigos, mas o primeiro marco deve começar com apenas 1 inimigo básico.

### Inimigo inicial recomendado

```text
Nome técnico: EnemyBasic
Função: atacar o núcleo do assentamento
Comportamento: andar até o núcleo, atacar, morrer ao receber dano suficiente
Objetivo de design: validar se a base pode ser defendida
```

---

## 14. Recursos iniciais

| Recurso | Uso |
|---|---|
| Madeira | Construção básica, barricada, reparo |
| Pedra | Estruturas mais resistentes |
| Essência mágica | Magia roubada ou melhoria simples |

Para o Marco 0.1, começar apenas com:

```text
Madeira
```

Depois adicionar:

```text
Pedra
Essência mágica
```

---

## 15. Princípio de desenvolvimento

O projeto deve ser desenvolvido em camadas jogáveis.

Cada camada precisa gerar algo testável dentro da Godot antes de avançar.

```text
Não criar sistema grande sem teste.
Não criar arte final antes de validar gameplay.
Não criar narrativa profunda antes do loop funcionar.
Não criar economia complexa antes da coleta e defesa funcionarem.
Não criar 5 NPCs antes de 2 NPCs funcionarem.
Não criar 5 inimigos antes de 1 inimigo funcionar.
```

---

## 16. Regra de uso de IA no desenvolvimento

A IA pode ser usada para:

```text
Gerar código inicial
Revisar arquitetura
Criar documentação
Sugerir testes
Criar assets temporários
Criar nomes e variações
Organizar backlog
Ajudar debug
```

A IA não deve decidir sozinha:

```text
Aumentar escopo
Criar sistemas fora do marco atual
Alterar arquitetura sem registro
Adicionar dependências externas sem justificativa
Trocar engine ou linguagem sem decisão documentada
Usar assets sem checar licença
```

Toda alteração relevante deve ser registrada depois em:

```text
11_DECISION_LOG.md
13_CHANGELOG.md
```

---

## 17. Status atual

| Item | Estado |
|---|---|
| Conceito do jogo | Definido |
| Pasta de documentação | Em criação |
| Arquivo zero | Em criação |
| Escopo técnico detalhado | Pendente |
| Arquitetura de sistemas | Pendente |
| Backlog executável | Pendente |
| Projeto Godot | Pendente ou inicial |
| Protótipo jogável | Ainda não iniciado |

---

## 18. Próximo marco

Criar os documentos mínimos para iniciar desenvolvimento sem perda de escopo:

```text
00_PROJECT_OVERVIEW.md
01_GAME_CONCEPT.md
02_PROTOTYPE_SCOPE.md
03_TECHNICAL_DESIGN.md
04_SYSTEMS_ARCHITECTURE.md
05_BACKLOG.md
06_AI_CODEX_RULES.md
```

Depois disso, iniciar o Marco 0.1 na Godot.

---

## 19. Critério para iniciar desenvolvimento na Godot

O desenvolvimento prático pode começar quando estes pontos estiverem definidos:

```text
1. Escopo do Marco 0.1 fechado.
2. Sistemas principais nomeados.
3. Primeiras tarefas do backlog escritas.
4. Regras para Codex/IA definidas.
5. Critérios de teste manual definidos.
```

---

## 20. Critério de sucesso do Marco 0.1

O Marco 0.1 será considerado funcional quando for possível jogar esta sequência:

```text
1. Abrir o mapa.
2. Controlar o jogador em primeira pessoa.
3. Coletar madeira.
4. Depositar ou registrar madeira no estoque.
5. Fundar ou ativar o núcleo da base.
6. Construir uma barricada simples.
7. Atribuir 1 NPC para coleta.
8. Atribuir 1 NPC para defesa.
9. Iniciar uma onda inimiga.
10. Defender o núcleo.
11. Receber vitória ou derrota clara.
```

---

## 21. Frase de controle contra escopo infinito

Se uma ideia nova não ajuda a validar a primeira invasão jogável, ela vai para backlog futuro.

O foco atual é:

```text
Primeira invasão jogável.
Decisão de alocação compreensível.
Base mínima defensável.
Vitória ou derrota clara.
```

---

## 22. Como usar este arquivo

Este arquivo deve ser usado como ponto de entrada do projeto.

Ele serve para:

```text
lembrar o objetivo central do jogo;
impedir aumento de escopo sem decisão registrada;
orientar a criação dos próximos documentos;
alinhar desenvolvimento, IA e organização do protótipo.
```

Este arquivo não substitui:

```text
documento de conceito completo;
escopo técnico;
backlog;
arquitetura de sistemas;
regras de uso de IA/Codex;
decision log;
changelog.
```

---

## 23. Regra de atualização

Este arquivo só deve ser alterado quando mudar uma decisão central do projeto.

Exemplos:

```text
troca de engine;
troca de gênero dominante;
mudança de plataforma inicial;
mudança do escopo do Marco 0.1;
mudança do loop principal;
mudança da condição de vitória/derrota.
```

Mudanças menores devem ir para backlog, changelog ou decision log.

---

## 24. Checklist rápido de leitura

Antes de iniciar uma tarefa nova, verificar:

```text
A tarefa ajuda a validar a primeira invasão jogável?
A tarefa cabe no Marco 0.1?
A tarefa tem relação com jogador, recurso, base, NPC, inimigo ou onda?
A tarefa evita dependência desnecessária de asset final?
A tarefa pode ser testada dentro da Godot?
```

Se a resposta for “não” para a maioria dos itens, mover para backlog futuro.
