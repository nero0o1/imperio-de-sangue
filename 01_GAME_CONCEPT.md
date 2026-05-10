# 01_GAME_CONCEPT.md

# Império de Sangue — Conceito do Jogo

| Campo | Valor |
|---|---|
| Documento | Conceito do Jogo |
| Projeto | Império de Sangue |
| Versão do documento | 1.1 |
| Finalidade | Definir identidade, experiência, limites criativos e critérios de validação do jogo |
| Relação com o arquivo 00 | Expande a visão geral sem substituir o escopo técnico |
| Status | Documento base para protótipo jogável |

> Este documento define o que o jogo é, o que ele não é, qual experiência deve entregar e quais limites criativos protegem o protótipo contra expansão descontrolada.

---

## 1. Identidade básica

| Campo | Definição |
|---|---|
| Nome provisório | Império de Sangue |
| Plataforma inicial | PC |
| Engine pretendida | Godot 4.x |
| Linguagem principal | GDScript |
| Gênero dominante | RPG de ação em primeira pessoa com gestão tática de assentamento |
| Subgênero | Sandbox, defesa de base, fantasia sombria medieval |
| Perspectiva | Primeira pessoa |
| Modelo de desenvolvimento | Criador solo, hobby de longo prazo, apoio intensivo de IA |
| Duração alvo da sessão do protótipo | 10 a 15 minutos |
| Escopo inicial | Protótipo jogável, não produto comercial completo |
| Prioridade de validação | Primeira invasão jogável com decisão de alocação compreensível |

---

## 2. Logline

Um nobre exilado chega a uma região hostil e precisa transformar um acampamento frágil em um assentamento defensável, usando exploração, coleta, NPCs funcionais, construção estratégica e magia roubada para sobreviver à primeira invasão.

---

## 3. Frase de conceito

**Império de Sangue** é um RPG de ação em primeira pessoa com gestão tática de assentamento, no qual o jogador assume o papel de um nobre exilado que explora uma região hostil, recruta ou utiliza NPCs funcionais, constrói uma base defensável, rouba magia de forças inimigas e tenta sobreviver à primeira invasão.

---

## 4. Fantasia central do jogador

O jogador deve sentir que está reconstruindo poder a partir de quase nada.

A experiência desejada é:

```text
começar vulnerável;
explorar território hostil;
reunir recursos;
organizar pessoas;
erguer defesas;
roubar poder mágico;
sobreviver a uma ameaça maior;
transformar um acampamento frágil em núcleo de domínio.
```

O jogador não é apenas um guerreiro. Ele também é um líder local, responsável por decidir quem trabalha, quem defende, quem patrulha e quais riscos são aceitáveis.

---

## 5. Premissa narrativa inicial

O protagonista era parte de uma linhagem nobre derrotada, expulsa ou traída em uma disputa de poder.

Sem exército, sem corte e sem território seguro, ele chega a uma região instável, marcada por ruínas, criaturas hostis, facções menores e fontes perigosas de magia.

O objetivo inicial não é reconquistar um império inteiro. O objetivo do protótipo é menor e mais testável:

```text
fundar um assentamento mínimo;
organizar poucos sobreviventes ou aliados;
preparar uma defesa básica;
sobreviver à primeira invasão.
```

A narrativa deve servir ao gameplay. No protótipo, ela não deve exigir cutscenes, diálogos longos ou sistema complexo de escolhas morais.

---

## 6. O que o jogo é

| É | Explicação |
|---|---|
| RPG de ação em primeira pessoa | O jogador controla um personagem diretamente, explora, luta e interage com o mundo. |
| Jogo de assentamento | A base é o centro de progressão, defesa, produção e organização. |
| Gestão tática de NPCs | O jogador decide como alocar NPCs entre coleta, construção, patrulha, defesa e produção. |
| Defesa de base | A sessão culmina em uma invasão que testa a preparação do jogador. |
| Sandbox controlado | O jogador tem liberdade local, mas dentro de mapa pequeno e objetivo claro no protótipo. |
| Fantasia sombria medieval | O cenário usa estética medieval, magia e conflito de poder em mundo fictício. |
| Jogo de decisão sob pressão | A qualidade da preparação deve alterar o resultado da invasão. |

---

## 7. O que o jogo não é

| Não é | Limite |
|---|---|
| Simulador histórico | Não reconstrói eventos reais nem exige precisão acadêmica histórica. |
| RTS clássico | Não usa visão isométrica nem controle massivo de exércitos no protótipo. |
| RPG narrativo profundo no protótipo | NPCs iniciais são funcionais, não personagens com arcos extensos. |
| City builder complexo | A economia inicial é simples e orientada à defesa. |
| Mundo aberto grande | O primeiro mapa deve ser pequeno, testável e controlado. |
| Jogo de guerra em larga escala | O protótipo testa defesa local, não campanhas militares amplas. |
| Simulador de sociedade | Moral, política, economia e cultura ficam simplificadas no início. |
| Jogo dependente de arte final | O protótipo deve funcionar com placeholders e assets temporários. |

---

## 8. Contexto de mundo

O mundo é uma fantasia sombria medieval de baixa fidelidade histórica.

Isso significa:

```text
usa estética medieval;
usa castelos, vilas, ruínas, armas brancas, muralhas e conflito territorial;
usa magia como força perigosa e disputada;
não tenta simular um período histórico real;
não precisa obedecer eventos, povos, cronologias ou geopolítica do mundo real.
```

### 8.1 Tom do mundo

| Elemento | Direção |
|---|---|
| Atmosfera | Sombria, hostil, instável |
| Política | Disputa local de poder, alianças frágeis, sobrevivência territorial |
| Magia | Rara, roubada, perigosa, útil como vantagem tática |
| Território | Região de fronteira, ruínas, ameaça externa e recursos limitados |
| Violência | Presente como conflito de guerra e defesa, sem foco em gore |
| Humor | Baixo ou quase inexistente no protótipo |
| Esperança | Pequena, ligada à reconstrução gradual do assentamento |

### 8.2 Regras criativas do mundo

```text
O mundo deve parecer antigo, perigoso e disputado.
A magia deve ter custo, risco ou origem hostil.
O assentamento deve parecer frágil no começo.
O território deve comunicar ameaça antes da invasão.
A estética medieval serve ao clima, não à precisão histórica.
```

---

## 9. Pilares de experiência

| Pilar | Função no jogo | Como aparece no protótipo |
|---|---|---|
| Exploração hostil | Obriga o jogador a sair da segurança da base | Recursos e ameaças fora do núcleo inicial |
| Gestão tática de NPCs | Cria decisões de alocação | NPCs com funções diferentes e tempo limitado |
| Construção funcional | Transforma recurso em defesa e produção | Barricada, núcleo, armazém ou torre simples |
| Preparação para invasão | Dá consequência às decisões anteriores | Onda inimiga curta no fim da sessão |
| Magia roubada | Cria vantagem rara e temática | Uma magia simples aplicada ao jogador ou base |
| Escassez de tempo/pessoas | Impede que o jogador faça tudo | Poucos NPCs e ameaça chegando |

### 9.1 Pilar dominante do protótipo

O pilar dominante do primeiro protótipo deve ser:

```text
Preparação para invasão por meio de alocação limitada de NPCs.
```

Se esse pilar não funcionar, adicionar mais inimigos, mais magia ou mais edifícios não resolve o problema central.

---

## 10. Loop principal de gameplay

```text
Explorar
→ Coletar
→ Fundar
→ Atribuir NPCs
→ Construir / Produzir
→ Obter informação
→ Preparar defesa
→ Defender
→ Receber vitória ou derrota
```

### 10.1 Loop em termos de decisão

| Fase | Decisão do jogador | Consequência esperada |
|---|---|---|
| Exploração | Ir mais longe ou ficar perto da base | Mais recurso ou mais segurança |
| Coleta | Coletar manualmente ou usar NPC | Mais controle direto ou mais automação |
| Fundação | Onde posicionar o núcleo | Define defesa e rotas de ataque |
| Alocação | Quem faz qual tarefa | Define eficiência da base |
| Construção | Defesa, produção ou suporte | Define prioridade estratégica |
| Informação | Patrulhar ou ignorar risco | Revela ou oculta ameaça |
| Defesa | Distribuir NPCs e lutar | Testa preparação acumulada |

### 10.2 Loop mínimo do Marco 0.1

```text
andar pelo mapa;
coletar madeira;
registrar madeira no estoque;
fundar ou ativar núcleo;
construir barricada;
atribuir coletor;
atribuir defensor;
iniciar onda;
defender núcleo;
exibir vitória ou derrota.
```

---

## 11. Verbos principais do jogador

| Verbo | Prioridade | Observação |
|---|---:|---|
| Andar/olhar | Alta | Base de controle em primeira pessoa |
| Interagir | Alta | Usado para recurso, NPC e construção |
| Coletar | Alta | Sustenta construção inicial |
| Construir | Alta | Converte recurso em defesa |
| Atribuir | Alta | Núcleo da gestão tática |
| Defender | Alta | Testa combate e preparação |
| Patrulhar | Média | Pode ser simplificado no primeiro marco |
| Usar magia | Média | Deve entrar só após defesa mínima funcionar |
| Negociar | Baixa | Sistema futuro |
| Expandir território | Baixa | Sistema futuro |

---

## 12. Tensão principal

A tensão principal do jogo é a escassez de pessoas, tempo e recursos.

O jogador nunca deve conseguir fazer tudo ao mesmo tempo.

Exemplos:

```text
Mandar NPC coletar madeira aumenta construção, mas reduz defesa imediata.
Mandar NPC patrulhar revela ameaça, mas reduz mão de obra na base.
Mandar NPC defender protege o núcleo, mas atrasa produção.
Construir defesa agora pode impedir expansão depois.
Explorar pode gerar magia, mas deixa a base menos supervisionada.
```

A pergunta central da sessão é:

```text
O que eu sacrifico agora para aumentar minha chance de sobreviver depois?
```

---

## 13. Loop de NPCs

O NPC é uma peça funcional do sistema de assentamento.

Loop geral:

```text
NPC livre
→ recebe função
→ vai até edifício, área ou ponto de tarefa
→ executa ciclo
→ gera resultado
→ repete ou aguarda nova ordem
```

### 13.1 Ciclos básicos

| Tipo de ciclo | Sequência mínima |
|---|---|
| Coleta | Ir ao recurso → coletar → voltar ao armazém → depositar → repetir |
| Construção | Ir ao canteiro → consumir recurso → construir/reparar → aguardar nova ordem |
| Produção | Ir à oficina → consumir recurso → esperar tempo → gerar item/melhoria |
| Patrulha | Ir ao ponto → observar → revelar ameaça → retornar ou continuar rota |
| Defesa | Ir à posição → detectar inimigo → atacar/recuar → proteger estrutura ou NPC |

### 13.2 Estados mínimos de NPC

```text
Idle;
MovingToTask;
Working;
Returning;
Defending;
Disabled.
```

Esses estados são suficientes para protótipo. Emoções, personalidade e memória narrativa ficam fora do início.

---

## 14. Personagem jogável

O personagem jogável deve ser simples no protótipo.

### 14.1 Capacidades mínimas

```text
andar;
correr;
olhar em primeira pessoa;
interagir com objetos;
coletar recurso;
atacar inimigo;
receber dano;
morrer;
ativar ou construir estrutura simples;
atribuir função básica a NPC.
```

### 14.2 Capacidades fora do início

```text
árvore extensa de habilidades;
equipamentos complexos;
inventário profundo;
diálogos ramificados;
montarias;
magias múltiplas;
combos avançados.
```

---

## 15. NPCs funcionais do protótipo completo

| NPC | Função principal | Função secundária | Vantagem | Limitação |
|---|---|---|---|---|
| Coletor | Coletar recursos | Transporte | Acelera economia básica | Fraco em combate |
| Construtor | Construir e reparar | Reforçar defesa | Reduz tempo de obra | Depende de recurso disponível |
| Ferreiro/Artesão | Produzir itens/melhorias | Reparar equipamento | Melhora defesa ou dano | Pouco útil fora da oficina |
| Batedor | Patrulhar e revelar ameaça | Alertar rota de invasão | Dá informação antecipada | Baixo impacto direto em combate |
| Guardião/Guerreiro | Defender e atacar | Proteger NPCs | Segura linha defensiva | Não gera recurso |

### 15.1 NPCs do primeiro marco

Para o primeiro marco técnico, usar apenas:

```text
Coletor
Guardião/Guerreiro
```

Motivo: esses dois já testam o conflito essencial entre economia e defesa.

---

## 16. Inimigos

O protótipo completo prevê 5 tipos de inimigos, mas o primeiro marco deve começar com apenas 1 inimigo básico.

### 16.1 Inimigo inicial

| Campo | Definição |
|---|---|
| Nome técnico | EnemyBasic |
| Função | Atacar o núcleo do assentamento |
| Comportamento | Caminha até o núcleo, ataca e pode ser morto |
| Objetivo de design | Validar se defesa, NPC e combate funcionam juntos |

### 16.2 Tipos futuros possíveis

| Tipo | Função tática |
|---|---|
| Invasor básico | Pressiona a linha defensiva |
| Saqueador rápido | Tenta contornar defesa e atacar recurso/NPC |
| Bruto | Tem mais vida e força, ameaça estruturas |
| Cultista | Usa magia ou enfraquece defesa |
| Comandante menor | Melhora organização dos inimigos na onda |

Esses tipos devem ficar fora do primeiro marco, salvo se o inimigo básico já estiver funcional.

---

## 17. Edifícios e estruturas

| Estrutura | Função no jogo | Prioridade |
|---|---|---|
| Cabana Central / Núcleo | Coração do assentamento e condição de derrota | Alta |
| Armazém | Recebe e contabiliza recursos | Alta |
| Oficina/Ferraria | Produz melhorias simples | Média |
| Torre de Vigia | Revela ameaça ou aumenta alcance de detecção | Média |
| Muralha/Barricada | Bloqueia ou atrasa inimigos | Alta |
| Salão de Conselho/Alianças | Futuro sistema político/diplomático | Baixa no protótipo inicial |

### 17.1 Estruturas do Marco 0.1

```text
Núcleo do assentamento;
estoque global simples;
barricada simples.
```

---

## 18. Condição de vitória

O jogador vence a sessão se:

```text
fundar o assentamento;
organizar pelo menos parte dos NPCs;
preparar defesa mínima;
sobreviver à primeira invasão;
manter o núcleo do assentamento funcional até o fim da onda.
```

A vitória deve ser clara e exibida ao jogador.

Exemplo:

```text
Vitória: o assentamento resistiu à primeira invasão.
```

---

## 19. Condição de derrota

O jogador perde se:

```text
morrer;
o núcleo do assentamento for destruído;
NPCs essenciais forem neutralizados antes do fim da invasão;
a base ficar incapaz de resistir à primeira onda.
```

A derrota deve ser clara e exibida ao jogador.

Exemplo:

```text
Derrota: o núcleo do assentamento foi destruído.
```

---

## 20. Recursos

| Recurso | Função |
|---|---|
| Madeira | Construção básica, barricadas e reparo |
| Pedra | Estruturas mais resistentes |
| Essência mágica | Magia roubada ou melhorias especiais |

### 20.1 Recurso inicial obrigatório

```text
Madeira
```

Madeira é suficiente para validar:

```text
coleta;
estoque;
construção;
reparo;
decisão entre coletar e defender.
```

---

## 21. Magia roubada

A magia deve ser tratada como vantagem rara, não como sistema principal no primeiro momento.

### 21.1 Conceito

A magia não é aprendida de forma tradicional. Ela é roubada, extraída ou tomada de inimigos, ruínas, fontes hostis ou entidades derrotadas.

### 21.2 Funções possíveis

| Uso | Exemplo |
|---|---|
| Buff no jogador | Aumentar dano temporariamente |
| Buff na base | Fortalecer barricada por tempo limitado |
| Controle | Lentificar inimigos por poucos segundos |
| Recurso especial | Converter essência em melhoria |

### 21.3 Magia inicial recomendada

```text
Nome técnico: BloodWard
Função: reforçar temporariamente o núcleo ou uma barricada
Motivo: conversa diretamente com defesa de base e não exige sistema complexo de combate mágico.
```

---

## 22. Escopo do protótipo completo

| Categoria | Conteúdo incluído |
|---|---|
| Mapa | 1 território hostil pequeno |
| Jogador | Movimento, câmera, interação, coleta e combate básico |
| NPCs | 5 NPCs funcionais |
| Inimigos | 5 tipos de inimigos |
| Edifícios | Núcleo, armazém, oficina, torre, barricada/muralha e salão/conselho simples |
| Magia | 1 magia roubada simples |
| Invasão | 1 onda curta |
| UI | Recursos, vida, estado da base e aviso de onda |

---

## 23. Fora do protótipo inicial

| Sistema | Motivo |
|---|---|
| Narrativa profunda de NPCs | Exige escrita, diálogo, estado emocional e memória narrativa. |
| Diplomacia ampla | Aumenta escopo sem validar o loop básico. |
| Economia completa | Pode transformar o projeto em city builder antes da hora. |
| Mundo aberto grande | Dificulta teste e acabamento. |
| Guerra em larga escala | Exige IA, pathfinding e balanceamento demais. |
| Crafting complexo | Aumenta UI, inventário e regras. |
| Multiplayer | Complexidade técnica desproporcional para hobby solo. |
| Save/load robusto | Importante depois, mas não necessário para primeira sessão curta. |
| Sistema de facções completo | Deve esperar o loop base funcionar. |
| Cutscenes | Não validam o núcleo jogável. |

---

## 24. Diferencial do jogo

O diferencial do projeto não é ter apenas combate, construção ou NPCs.

O diferencial está na combinação:

```text
RPG em primeira pessoa
+ assentamento funcional
+ NPCs como peças táticas
+ defesa de base
+ magia roubada
+ escassez de pessoas
+ consequência direta na invasão
```

A experiência deve fazer o jogador perceber que a base sobreviveu ou caiu por causa das decisões de alocação e preparação.

---

## 25. Riscos de design

| Risco | Efeito | Controle |
|---|---|---|
| Escopo crescer demais | Projeto trava antes de ficar jogável | Priorizar Marco 0.1 |
| NPCs complexos demais | IA difícil de implementar | Começar com estados simples |
| Construção virar city builder | Loop principal perde foco | Construção só com função defensiva no início |
| Combate roubar o foco | Gestão vira irrelevante | Invasão deve depender da preparação |
| Magia ficar ampla demais | Sistema explode em complexidade | Começar com 1 magia simples |
| Mundo grande demais | Teste e polimento ficam inviáveis | 1 mapa pequeno |
| Arte final vir cedo demais | Tempo gasto sem validar jogo | Usar placeholders no início |
| Documentação virar burocracia | Desenvolvimento não começa | Cada documento deve gerar decisão prática |

---

## 26. Promessa jogável do protótipo

Ao final do protótipo, o jogador deve conseguir contar uma micro-história emergente como:

```text
Explorei a floresta, juntei madeira, mandei um NPC coletar, coloquei outro na defesa, construí uma barricada fraca, descobri tarde demais a rota dos inimigos e quase perdi o núcleo durante a invasão.
```

Essa micro-história é mais importante que quantidade de conteúdo.

---

## 27. Critérios de sucesso do conceito

O conceito estará validado se o protótipo demonstrar:

```text
O jogador entende rapidamente o objetivo.
O jogador percebe a escassez de NPCs.
O jogador toma decisões diferentes entre coleta e defesa.
A invasão testa decisões anteriores.
A derrota parece consequência compreensível.
A vitória parece resultado de preparação.
A sessão cabe em 10 a 15 minutos.
```

---

## 28. Critérios de falha do conceito

O conceito deve ser revisado se ocorrerem estes sinais:

```text
O jogador vence sem usar NPCs.
O jogador vence sem construir defesa.
O jogador não entende por que perdeu.
A invasão parece aleatória.
A coleta parece inútil.
A base parece decoração.
Os NPCs parecem cosméticos.
O combate sozinho resolve tudo.
A sessão passa de 15 minutos antes de ficar interessante.
```

---

## 29. Métricas simples de teste

| Métrica | Alvo inicial |
|---|---:|
| Tempo até entender objetivo | até 2 minutos |
| Tempo até primeira coleta | até 1 minuto |
| Tempo até primeira construção | até 5 minutos |
| Tempo até primeira invasão | entre 8 e 12 minutos |
| Duração total da sessão | 10 a 15 minutos |
| Quantidade mínima de decisões relevantes | 3 |
| Quantidade mínima de estados claros | vitória ou derrota |

Essas métricas são referências práticas, não números finais de balanceamento.

---

## 30. Dependências de design para o próximo documento

O próximo documento recomendado é:

```text
02_PROTOTYPE_SCOPE.md
```

Ele deve transformar este conceito em escopo fechado, com:

```text
lista exata do que entra no Marco 0.1;
lista exata do que fica fora;
critérios de aceite;
ordem de implementação;
checklist de teste manual;
limites para uso de IA/Codex.
```

---

## 31. Regra de proteção do conceito

Toda nova ideia deve responder positivamente a pelo menos uma destas perguntas:

```text
Ajuda a validar a primeira invasão?
Melhora a decisão de alocação de NPCs?
Torna a base mais compreensível?
Melhora a relação entre preparação e consequência?
Reduz trabalho manual do desenvolvedor solo?
```

Se não responder, deve ir para backlog futuro.

---

## 32. Checklist de revisão rápida

Antes de alterar este conceito, verificar:

```text
A mudança mantém o jogo como RPG de ação em primeira pessoa?
A mudança mantém a base como centro de progressão?
A mudança mantém NPCs como ferramenta tática?
A mudança melhora a invasão jogável?
A mudança cabe em protótipo solo?
A mudança evita dependência de arte final?
```

Se a mudança falhar em três ou mais itens, ela não pertence ao conceito principal neste momento.

---

## 33. Glossário curto

| Termo | Definição neste projeto |
|---|---|
| Assentamento | Base inicial do jogador, centro de defesa e produção. |
| Núcleo | Estrutura principal da base; sua destruição causa derrota. |
| NPC funcional | Personagem sem arco narrativo profundo, criado para executar tarefa útil. |
| Invasão | Onda inimiga curta que testa a preparação do jogador. |
| Magia roubada | Poder obtido de fonte hostil, usado como vantagem tática. |
| Marco 0.1 | Primeira fatia vertical jogável do projeto. |
| Placeholder | Asset temporário usado para testar mecânica antes de arte final. |

---

## 34. Resumo final do conceito

```text
Império de Sangue é um RPG de ação em primeira pessoa com gestão tática de assentamento.
O jogador começa fraco, organiza poucos NPCs, coleta recursos, constrói defesas e tenta sobreviver a uma invasão.
O centro da experiência é escolher como alocar pessoas e recursos sob pressão.
O protótipo deve validar uma sessão curta, clara e jogável antes de qualquer expansão.
```
