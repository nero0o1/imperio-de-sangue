# 02_PROTOTYPE_SCOPE.md

# Império de Sangue — Escopo do Protótipo

| Campo | Valor |
|---|---|
| Documento | Escopo do Protótipo |
| Projeto | Império de Sangue |
| Versão do documento | 2.0 |
| Marco coberto | Marco 0.1 — Primeira invasão jogável |
| Finalidade | Fechar o que entra, o que fica fora e como validar o primeiro protótipo jogável |
| Relação com o arquivo 00 | Converte a visão geral em escopo executável |
| Relação com o arquivo 01 | Converte o conceito do jogo em limite prático de implementação |
| Próximo documento natural | 03_TECHNICAL_DESIGN.md |
| Status | Documento de controle de escopo para desenvolvimento inicial |

> Este documento serve para impedir crescimento descontrolado do projeto.  
> O foco é entregar uma primeira fatia vertical jogável, pequena, testável e compatível com desenvolvimento solo.

---

## 1. Finalidade do documento

Este arquivo define o escopo fechado do primeiro protótipo jogável de **Império de Sangue**.

Ele deve responder objetivamente:

```text
O que será implementado primeiro?
O que não será implementado agora?
Qual é a menor experiência jogável validável?
Como saber se o protótipo ficou jogável?
Qual sequência mínima o jogador precisa executar?
Quais sistemas são obrigatórios para validar a primeira invasão?
Quais sinais indicam que o escopo está crescendo errado?
```

Este documento não é:

```text
roteiro narrativo;
GDD completo;
arquitetura técnica detalhada;
manual de programação;
lista completa de todos os sistemas futuros;
documento de arte final.
```

A arquitetura técnica detalhada deve ficar em:

```text
03_TECHNICAL_DESIGN.md
```

---

## 2. Contrato de escopo

O Marco 0.1 tem uma função: provar o núcleo jogável mínimo.

O contrato é:

```text
Criar uma sessão curta onde o jogador coleta madeira, ergue defesa simples, atribui 2 NPCs funcionais e enfrenta 1 onda inimiga que pode gerar vitória ou derrota.
```

### 2.1 Regra principal

Se uma funcionalidade não ajuda diretamente a validar a primeira invasão jogável, ela não entra no Marco 0.1.

### 2.2 Regra de corte

Uma funcionalidade só entra no Marco 0.1 se passar por pelo menos 3 critérios:

```text
Ajuda o jogador a entender o objetivo da sessão.
Ajuda a validar coleta, construção, NPC, inimigo ou invasão.
Cria decisão entre economia e defesa.
Pode ser testada em poucos minutos.
Pode ser implementada com placeholder.
Não exige sistema complexo de UI, save, narrativa, economia ou IA avançada.
```

### 2.3 Regra de bloqueio automático

Uma funcionalidade fica bloqueada automaticamente se exigir:

```text
multiplayer;
mapa procedural;
save/load robusto;
inventário completo;
árvore de habilidades;
sistema diplomático amplo;
IA de grupo avançada;
arte final;
cutscenes;
cinemática;
conteúdo narrativo profundo;
mais de 2 NPCs funcionais;
mais de 1 tipo de inimigo funcional.
```

---

## 3. Pergunta de validação do Marco 0.1

O primeiro protótipo deve responder apenas esta pergunta:

```text
É compreensível e minimamente divertido preparar uma pequena base, alocar poucos NPCs e sobreviver a uma primeira invasão em primeira pessoa?
```

### 3.1 Hipótese de design

A hipótese é:

```text
A tensão entre coletar recurso, construir defesa e posicionar NPCs torna a invasão mais interessante do que um combate simples em primeira pessoa.
```

### 3.2 Como a hipótese será validada

A hipótese será considerada parcialmente validada se:

```text
O jogador entende que precisa se preparar.
O jogador percebe que NPCs alteram o resultado.
A barricada altera a chance de sobrevivência.
A derrota parece consequência de má preparação.
A vitória parece consequência de decisões anteriores.
```

---

## 4. Marco 0.1 — Primeira invasão jogável

O Marco 0.1 é a primeira fatia vertical jogável do projeto.

Ele deve permitir esta sequência mínima:

```text
1. Abrir um mapa pequeno.
2. Controlar o jogador em primeira pessoa.
3. Coletar madeira.
4. Registrar madeira no estoque.
5. Ativar ou fundar o núcleo do assentamento.
6. Construir uma barricada simples.
7. Atribuir 1 NPC para coleta.
8. Atribuir 1 NPC para defesa.
9. Iniciar uma onda inimiga curta.
10. Defender o núcleo.
11. Receber vitória ou derrota clara.
```

### 4.1 Objetivo do Marco 0.1

```text
Validar o loop mínimo: coletar → construir → atribuir NPC → defender → vencer/perder.
```

### 4.2 Resultado esperado

Ao terminar este marco, o projeto ainda não será um jogo completo. Ele será um protótipo funcional capaz de provar se o núcleo do conceito tem potencial.

### 4.3 Resultado que não é esperado

O Marco 0.1 não precisa parecer comercial, bonito ou completo. Ele precisa ser jogável, testável e honesto.

```text
Pode ter cubos.
Pode ter inimigos simples.
Pode ter UI textual.
Pode ter animação ausente.
Pode ter mapa pequeno.
Pode ter arte temporária.
```

---

## 5. Escopo fechado do Marco 0.1

| Categoria | Entra no Marco 0.1 | Observação |
|---|---|---|
| Mapa | 1 mapa pequeno | Terreno simples e assets temporários |
| Jogador | Movimento FPS básico | Sem parkour, stamina complexa ou animação final |
| Interação | Raycast simples | Usado para recurso, NPC, núcleo e construção |
| Recurso | Madeira | Único recurso obrigatório inicial |
| Estoque | Contador global de madeira | Sem inventário completo |
| Núcleo | 1 estrutura principal | Sua destruição causa derrota |
| Construção | 1 barricada simples | Posição fixa ou pré-definida é aceitável |
| NPCs | 2 NPCs funcionais | 1 coletor e 1 defensor |
| Inimigo | 1 tipo básico | Anda até o núcleo e ataca |
| Onda | 1 onda curta | Inimigos aparecem e atacam o núcleo |
| UI | Texto mínimo | Madeira, vida do núcleo, aviso de onda, vitória/derrota |
| Vitória | Sobreviver à onda | Estado claro no fim |
| Derrota | Jogador morre ou núcleo cai | Estado claro no fim |
| Teste | Checklist manual | Deve ser repetível |

---

## 6. Fora do Marco 0.1

Estes itens ficam bloqueados até o Marco 0.1 funcionar:

| Sistema | Motivo para ficar fora | Destino correto |
|---|---|---|
| Multiplayer | Complexidade técnica alta e desnecessária | Backlog futuro |
| Save/load robusto | Sessão alvo é curta; pode esperar | Marco posterior |
| Mundo aberto grande | Dificulta teste e polimento | Expansão futura |
| 5 inimigos completos | Antes é preciso validar 1 inimigo funcional | Backlog futuro |
| 5 NPCs completos | Antes é preciso validar 2 NPCs úteis | Backlog futuro |
| Árvore diplomática | Não valida a primeira invasão diretamente | Documento futuro |
| Economia completa | Risco de virar city builder antes da hora | Backlog futuro |
| Crafting complexo | Exige UI e regras demais | Backlog futuro |
| Inventário profundo | Contador global basta no início | Marco posterior |
| Narrativa profunda | NPCs são funcionais no protótipo | Documento narrativo futuro |
| Cutscenes | Não validam o loop jogável | Rejeitar no 0.1 |
| Sistema avançado de magia | 1 magia simples pode entrar depois, mas não é obrigatória no 0.1 | Marco 0.2+ |
| Arte final | Usar placeholders até o loop funcionar | Produção visual futura |
| Áudio final | Sons temporários ou ausência de áudio são aceitáveis | Polimento futuro |
| Balanceamento fino | Só faz sentido depois do loop funcionar | Pós-validação |

---

## 7. Escopo do jogador

### 7.1 Entra

```text
andar;
olhar em primeira pessoa;
correr simples, se for rápido implementar;
interagir por Raycast;
coletar madeira;
atacar inimigo com ação simples;
receber dano;
morrer;
acionar construção simples;
atribuir função básica a NPC.
```

### 7.2 Não entra

```text
sistema completo de atributos;
classes de personagem;
equipamentos múltiplos;
inventário com slots;
árvore de habilidades;
animações finais;
combos;
magias múltiplas;
montaria;
diálogo ramificado;
sistema de reputação;
fadiga, fome ou sede.
```

### 7.3 Critério mínimo

O jogador deve ser suficiente para testar o protótipo, não para representar o personagem final.

### 7.4 Controles mínimos sugeridos

| Ação | Entrada sugerida |
|---|---|
| Mover | WASD |
| Olhar | Mouse |
| Correr | Shift |
| Interagir | E |
| Atacar | Botão esquerdo do mouse |
| Abrir ação simples de NPC | E olhando para NPC |
| Iniciar onda em modo teste | Tecla temporária ou botão de debug |

---

## 8. Escopo do mapa

### 8.1 Entra

| Elemento | Descrição |
|---|---|
| Área inicial | Local onde o jogador começa |
| Área de recurso | Pequena zona com madeira coletável |
| Área do núcleo | Local de fundação ou ativação da base |
| Rota de inimigos | Caminho simples até o núcleo |
| Zona de invasão | Ponto de spawn dos inimigos |
| Limites do mapa | Barreiras simples para impedir fuga do teste |

### 8.2 Não entra

```text
biomas múltiplos;
mapa procedural;
masmorras;
cidades grandes;
interiores complexos;
longas distâncias;
mapa aberto;
verticalidade complexa;
navegação por mapa/minimapa.
```

### 8.3 Tamanho recomendado

O mapa deve ser pequeno o suficiente para o jogador entender tudo em até 2 minutos.

### 8.4 Layout mínimo sugerido

```text
[Spawn do jogador]
      |
[Área do núcleo] ---- [Área de madeira]
      |
[Rota inimiga]
      |
[Spawn da onda]
```

---

## 9. Escopo de recursos e estoque

### 9.1 Recurso obrigatório

```text
Madeira
```

### 9.2 Funções da madeira

```text
ser coletada pelo jogador;
ser coletada pelo NPC coletor;
aumentar contador global;
ser consumida para construir barricada;
opcionalmente ser consumida para reparar núcleo ou barricada.
```

### 9.3 Modelo de estoque

No Marco 0.1, o estoque pode ser global.

Exemplo:

```text
wood = 0
```

Não é necessário inventário por item, peso, slot ou baú físico.

### 9.4 Regras mínimas de recurso

```text
Madeira não pode ficar negativa.
Construção deve falhar se madeira for insuficiente.
Coleta deve gerar feedback visual ou textual.
NPC coletor deve aumentar o mesmo estoque global usado pelo jogador.
```

---

## 10. Escopo do assentamento

### 10.1 Entra

| Elemento | Função |
|---|---|
| Núcleo | Estrutura principal da base |
| Vida do núcleo | Define proximidade da derrota |
| Estoque global | Armazena madeira |
| Barricada | Atrasa, bloqueia ou absorve dano de inimigo |

### 10.2 Não entra

```text
múltiplos prédios produtivos;
melhorias por nível;
felicidade da população;
moradia;
impostos;
produção em cadeia;
logística complexa;
território expansível;
limites políticos do assentamento.
```

### 10.3 Regra de derrota ligada ao assentamento

Se o núcleo chegar a 0 de vida, a sessão termina em derrota.

### 10.4 Regra de clareza

A vida do núcleo deve estar visível ou facilmente verificável durante o teste.

---

## 11. Escopo de construção

### 11.1 Construção obrigatória

```text
Barricada simples
```

### 11.2 Comportamento mínimo da barricada

A barricada deve cumprir pelo menos uma função:

```text
bloquear inimigo;
atrasar inimigo;
receber dano antes do núcleo;
criar rota defensiva simples.
```

### 11.3 Formas aceitáveis de implementação

| Forma | Aceitável? | Observação |
|---|---:|---|
| Posição fixa de construção | Sim | Melhor para o primeiro teste |
| Ghost preview simples | Sim | Apenas se não atrasar muito |
| Sistema livre de construção | Não | Complexidade alta para o 0.1 |
| Grid completo | Não | Deixar para depois |
| Rotação manual de peça | Não | Não é necessária agora |

### 11.4 Regra de custo

A barricada deve consumir madeira. Se ela for gratuita, a relação coleta → construção não será validada.

---

## 12. Escopo de interação

### 12.1 Interação obrigatória

| Interação | Resultado esperado |
|---|---|
| Olhar para madeira e pressionar ação | Coletar madeira |
| Olhar para núcleo | Ver estado ou ativar base |
| Olhar para ponto de barricada | Construir barricada se houver madeira |
| Olhar para NPC coletor | Atribuir coleta |
| Olhar para NPC defensor | Atribuir defesa |

### 12.2 Implementação mínima aceitável

```text
Raycast saindo da câmera do jogador;
interface IInteractable simples ou método equivalente;
texto contextual mínimo;
ação única por tecla.
```

---

## 13. Escopo de NPCs

### 13.1 NPCs obrigatórios

| NPC | Função | Critério mínimo |
|---|---|---|
| Coletor | Coleta madeira e deposita no estoque | Deve aumentar madeira sem controle direto constante |
| Defensor | Ataca inimigos próximos do núcleo ou barricada | Deve ajudar na defesa da onda |

### 13.2 Estados mínimos

```text
Idle;
MovingToTask;
Working;
Returning;
Defending;
Disabled.
```

### 13.3 Não entra

```text
personalidade;
diálogo;
memória narrativa;
relações;
níveis de lealdade;
equipamentos complexos;
necessidades como fome, sede ou descanso;
pathfinding avançado em mapa grande;
árvore comportamental sofisticada;
agentes autônomos com objetivos próprios.
```

### 13.4 Critério mínimo de utilidade

O jogador deve perceber diferença entre usar e não usar NPCs.

Se vencer sem NPCs for tão fácil quanto vencer com NPCs, o sistema falhou para este marco.

### 13.5 Ciclo mínimo do coletor

```text
Idle
→ receber ordem de coleta
→ ir até recurso
→ coletar
→ voltar ao estoque/núcleo
→ depositar madeira
→ repetir ou aguardar
```

### 13.6 Ciclo mínimo do defensor

```text
Idle
→ receber ordem de defesa
→ ir até ponto defensivo
→ detectar inimigo próximo
→ atacar ou bloquear
→ retornar ao ponto defensivo
```

---

## 14. Escopo de inimigos e onda

### 14.1 Inimigo obrigatório

| Campo | Definição |
|---|---|
| Nome técnico | EnemyBasic |
| Função | Atacar o núcleo |
| Alvo primário | Núcleo do assentamento |
| Alvo secundário | Barricada ou NPC defensor, se estiver no caminho |
| Movimento | Ir até o alvo por rota simples |
| Ataque | Reduzir vida do alvo |
| Morte | Desaparecer ou cair ao chegar a 0 de vida |

### 14.2 Onda obrigatória

| Campo | Definição |
|---|---|
| Quantidade inicial | Pequena, ajustável |
| Duração | Curta |
| Início | Manual por teste ou automático após tempo definido |
| Fim | Todos inimigos derrotados ou núcleo destruído |
| Resultado | Vitória ou derrota |

### 14.3 Não entra

```text
IA de grupo complexa;
flanqueamento avançado;
inimigos com habilidades especiais;
chefes;
ondas múltiplas;
diretor dinâmico de dificuldade;
spawn procedural complexo;
comportamento furtivo;
cerco prolongado.
```

### 14.4 Regra de alvo

No Marco 0.1, inimigos devem priorizar simplicidade:

```text
Se barricada estiver no caminho, atacar barricada.
Se não houver barricada ou ela cair, atacar núcleo.
Se defensor estiver próximo, pode sofrer dano ou trocar ataque simples.
```

---

## 15. UI mínima

### 15.1 Entra

```text
contador de madeira;
vida do jogador;
vida do núcleo;
aviso de onda;
mensagem de vitória;
mensagem de derrota;
interação simples: “Pressione E”.
```

### 15.2 Não entra

```text
menus complexos;
inventário visual;
minimapa;
árvore de construção;
tela de diplomacia;
interface final polida;
HUD com muitos ícones;
tela de personagem;
tela de facção.
```

### 15.3 Regra de legibilidade

A UI não precisa ser bonita, mas precisa responder a três perguntas:

```text
Tenho madeira suficiente?
O núcleo está perto de cair?
Ganhei ou perdi?
```

---

## 16. Balanceamento inicial

Os números abaixo são placeholders para teste, não valores finais.

| Variável | Valor inicial sugerido |
|---|---:|
| Madeira inicial | 0 |
| Madeira por coleta manual | 1 |
| Madeira por ciclo do coletor | 1 a 2 |
| Custo da barricada | 5 madeira |
| Vida do jogador | 100 |
| Vida do núcleo | 100 |
| Vida da barricada | 50 |
| Vida do inimigo básico | 30 |
| Dano do jogador | 10 |
| Dano do defensor | 5 a 10 |
| Dano do inimigo | 5 a 10 por ataque |
| Quantidade de inimigos na onda | 3 a 5 |
| Tempo até onda automática | 8 a 12 minutos |

Ajustar apenas depois que todos os sistemas mínimos funcionarem.

---

## 17. Critérios de aceite

O Marco 0.1 só será aceito se todos os critérios obrigatórios forem cumpridos.

| ID | Critério | Obrigatório? |
|---|---|---:|
| AC-01 | Cena principal abre sem erro crítico | Sim |
| AC-02 | Jogador consegue se mover e olhar em primeira pessoa | Sim |
| AC-03 | Jogador consegue interagir por Raycast ou sistema equivalente | Sim |
| AC-04 | Jogador consegue coletar madeira | Sim |
| AC-05 | Madeira aparece no estoque/contador | Sim |
| AC-06 | Estoque impede construção sem madeira suficiente | Sim |
| AC-07 | Núcleo do assentamento existe e tem vida | Sim |
| AC-08 | Jogador consegue construir ou ativar uma barricada | Sim |
| AC-09 | Barricada interfere na invasão de alguma forma | Sim |
| AC-10 | NPC coletor consegue gerar madeira no estoque | Sim |
| AC-11 | NPC defensor consegue atacar ou bloquear inimigo | Sim |
| AC-12 | Inimigo básico consegue atacar núcleo ou defesa | Sim |
| AC-13 | Onda curta pode iniciar e terminar | Sim |
| AC-14 | Vitória é exibida quando a onda termina e o núcleo sobrevive | Sim |
| AC-15 | Derrota é exibida quando o jogador morre ou o núcleo cai | Sim |
| AC-16 | Existe pelo menos 1 cenário de vitória possível | Sim |
| AC-17 | Existe pelo menos 1 cenário de derrota possível | Sim |
| AC-18 | Sessão completa cabe em 10 a 15 minutos | Preferencial |

---

## 18. Checklist de teste manual

Executar este teste após cada avanço relevante.

```text
[ ] Abrir cena principal sem erro.
[ ] Mover jogador.
[ ] Olhar ao redor com câmera.
[ ] Interagir com recurso de madeira.
[ ] Ver contador de madeira aumentar.
[ ] Tentar construir barricada sem madeira suficiente.
[ ] Confirmar que construção é bloqueada sem recurso.
[ ] Coletar madeira suficiente.
[ ] Ativar/fundar núcleo.
[ ] Construir barricada usando madeira.
[ ] Ver madeira diminuir após construção.
[ ] Atribuir NPC coletor.
[ ] Ver NPC coletor buscar recurso e aumentar estoque.
[ ] Atribuir NPC defensor.
[ ] Iniciar onda inimiga.
[ ] Ver inimigo andar em direção ao núcleo.
[ ] Ver inimigo causar dano.
[ ] Ver barricada interferir no ataque.
[ ] Ver NPC defensor reagir.
[ ] Defender manualmente, se necessário.
[ ] Ver vitória se núcleo sobreviver.
[ ] Ver derrota se núcleo cair ou jogador morrer.
```

---

## 19. Cenários de teste

### 19.1 Teste A — vitória básica

```text
Coletar madeira.
Construir barricada.
Atribuir coletor.
Atribuir defensor.
Iniciar onda.
Defender núcleo.
Esperado: vitória.
```

### 19.2 Teste B — derrota por falta de preparação

```text
Não construir barricada.
Não atribuir defensor.
Iniciar onda.
Esperado: derrota ou dano severo ao núcleo.
```

### 19.3 Teste C — utilidade do NPC coletor

```text
Atribuir coletor.
Esperar ciclo de coleta.
Esperado: estoque aumenta sem coleta manual contínua.
```

### 19.4 Teste D — utilidade do NPC defensor

```text
Atribuir defensor.
Iniciar onda.
Esperado: defensor ataca, bloqueia ou reduz pressão inimiga.
```

### 19.5 Teste E — clareza de resultado

```text
Forçar vitória e derrota em execuções separadas.
Esperado: mensagens finais claras e diferentes.
```

### 19.6 Teste F — construção com recurso insuficiente

```text
Zerar madeira.
Tentar construir barricada.
Esperado: construção não ocorre e feedback mínimo aparece.
```

---

## 20. Estados de jogo mínimos

| Estado | Função |
|---|---|
| Setup | Cena carregada, elementos iniciais prontos |
| Exploration | Jogador pode coletar e preparar base |
| Preparation | Jogador constrói e atribui NPCs |
| WaveActive | Inimigos estão ativos |
| Victory | Onda terminou e núcleo sobreviveu |
| Defeat | Jogador morreu ou núcleo foi destruído |

Esses estados podem ser implementados em `GameManager` ou sistema equivalente.

---

## 21. Ordem recomendada de implementação

### Wave 0 — Preparação do projeto

```text
Criar projeto Godot.
Criar cena principal.
Criar pasta de scripts.
Criar cena Player.
Criar cena TestMap.
Criar HUD temporário.
```

### Wave 1 — Jogador e interação

```text
Movimento FPS.
Câmera.
Raycast de interação.
Objeto de madeira coletável.
Contador global de madeira.
```

### Wave 2 — Assentamento

```text
Núcleo com vida.
UI mínima de vida do núcleo.
Construção de barricada simples.
Consumo de madeira.
Bloqueio de construção sem recurso.
```

### Wave 3 — NPC coletor

```text
NPC com estado Idle.
Atribuição para coleta.
Movimento até recurso.
Coleta.
Retorno ao estoque.
Incremento de madeira.
```

### Wave 4 — Inimigo básico

```text
Spawn de inimigo.
Movimento até núcleo.
Ataque ao núcleo.
Vida e morte do inimigo.
```

### Wave 5 — NPC defensor

```text
Atribuição para defesa.
Detecção de inimigo próximo.
Ataque simples.
Proteção do núcleo ou barricada.
```

### Wave 6 — Sistema de onda

```text
Iniciar onda.
Spawn de 3 a 5 inimigos.
Detectar fim da onda.
Declarar vitória ou derrota.
```

### Wave 7 — Teste e corte de escopo

```text
Rodar checklist manual.
Remover funcionalidades que não ajudam o loop.
Ajustar números básicos.
Registrar pendências no backlog.
```

### Wave 8 — Consolidação

```text
Renomear scripts confusos.
Adicionar comentários apenas onde houver lógica não óbvia.
Registrar decisões no decision log.
Preparar próximo documento técnico.
```

---

## 22. Convenção mínima de nomes

Sugestão de nomes para manter consistência entre documentação e Godot.

| Conceito | Nome técnico sugerido |
|---|---|
| Jogador | Player |
| Controlador de jogo | GameManager |
| Recursos | ResourceManager |
| Madeira | Wood |
| Núcleo | SettlementCore |
| Barricada | Barricade |
| NPC base | NpcBase |
| NPC coletor | NpcCollector |
| NPC defensor | NpcDefender |
| Inimigo básico | EnemyBasic |
| Sistema de onda | WaveManager |
| UI principal | HUD |
| Interação | InteractionRaycast |
| Ponto de construção | BuildSpot |
| Ponto de spawn | SpawnPoint |

Esses nomes podem ser refinados no arquivo técnico, mas não devem mudar sem motivo.

---

## 23. Estrutura mínima de pastas sugerida

Esta estrutura é apenas referência inicial. A estrutura técnica final deve ser detalhada no `03_TECHNICAL_DESIGN.md`.

```text
res://
  scenes/
    main/
    player/
    npc/
    enemies/
    settlement/
    resources/
    ui/
  scripts/
    core/
    player/
    npc/
    enemies/
    settlement/
    resources/
    ui/
  assets_temp/
  docs/
```

---

## 24. Regras para uso de IA/Codex neste marco

A IA pode ajudar a gerar código, mas deve obedecer ao escopo.

### 24.1 Permitido

```text
gerar scripts pequenos;
explicar erros;
criar versões simples de sistemas;
sugerir testes;
organizar backlog;
refatorar código já funcional;
criar placeholders;
escrever documentação de sistema;
criar checklist de validação.
```

### 24.2 Bloqueado

```text
adicionar multiplayer;
adicionar save/load complexo;
criar inventário completo;
criar sistema de facções;
criar mundo procedural;
adicionar dependência externa sem justificativa;
reescrever arquitetura inteira sem decisão registrada;
expandir escopo além do Marco 0.1;
criar sistemas genéricos demais antes do loop funcionar.
```

### 24.3 Regra de prompt para IA

Toda solicitação de código deve mencionar:

```text
Godot 4.x;
GDScript;
Marco 0.1;
sem multiplayer;
sem save/load complexo;
sem inventário completo;
com foco em primeira invasão jogável.
```

---

## 25. Riscos do Marco 0.1

| Risco | Impacto | Mitigação |
|---|---|---|
| Tentar criar todos os NPCs | Atraso e confusão | Começar com coletor e defensor |
| Construção livre complexa | Trava técnica | Usar posição fixa de barricada |
| Inimigo com IA demais | Bugs de pathfinding | Rota simples até o núcleo |
| UI crescer demais | Perda de tempo | Texto mínimo na tela |
| Arte final cedo demais | Desvio de foco | Usar placeholders |
| Balanceamento antes da hora | Retrabalho | Balancear só depois do loop funcionar |
| Magia entrar cedo demais | Escopo explode | Adiar até defesa mínima funcionar |
| Código genérico demais | Atraso sem ganho real | Implementar simples e refatorar depois |
| Documentação virar burocracia | Desenvolvimento não começa | Cada doc deve virar ação prática |

---

## 26. Pontuação de prioridade dos sistemas

| Sistema | Importância para o Marco 0.1 | Urgência | Prioridade final |
|---|---:|---:|---:|
| Player FPS | 10 | 10 | 10 |
| Interação | 10 | 10 | 10 |
| Recurso madeira | 9 | 9 | 9 |
| Núcleo | 10 | 9 | 9.5 |
| Barricada | 9 | 8 | 8.5 |
| NPC coletor | 8 | 8 | 8 |
| NPC defensor | 8 | 8 | 8 |
| Inimigo básico | 10 | 9 | 9.5 |
| Onda | 10 | 9 | 9.5 |
| UI mínima | 8 | 7 | 7.5 |
| Magia | 5 | 3 | 4 |
| Diplomacia | 2 | 1 | 1.5 |

Recomendação: implementar primeiro tudo com prioridade final igual ou maior que 8.

---

## 27. Métricas de teste do protótipo

| Métrica | Alvo inicial |
|---|---:|
| Tempo até entender objetivo | até 2 minutos |
| Tempo até primeira coleta | até 1 minuto |
| Tempo até primeira construção | até 5 minutos |
| Tempo até primeira invasão | 8 a 12 minutos |
| Duração total da sessão | 10 a 15 minutos |
| Número mínimo de decisões relevantes | 3 |
| Número mínimo de estados finais | 2: vitória e derrota |
| Número de NPCs funcionais | 2 |
| Número de tipos de inimigo | 1 |

---

## 28. Definition of Done

O Marco 0.1 estará concluído quando:

```text
O jogo abrir em uma cena jogável.
O jogador conseguir coletar madeira.
O jogador conseguir construir uma barricada.
O núcleo tiver vida e puder ser destruído.
O NPC coletor tiver utilidade perceptível.
O NPC defensor tiver utilidade perceptível.
O inimigo básico conseguir atacar.
A onda iniciar e terminar.
Vitória e derrota forem exibidas claramente.
O checklist manual passar sem erro crítico.
```

### 28.1 Erro crítico

Erro crítico é qualquer problema que impeça:

```text
abrir a cena;
controlar o jogador;
coletar madeira;
iniciar a onda;
concluir vitória ou derrota.
```

---

## 29. Critérios para avançar ao Marco 0.2

Só avançar para o Marco 0.2 se o Marco 0.1 estiver jogável.

Critérios mínimos:

```text
3 sessões de teste completas sem travamento crítico;
vitória possível;
derrota possível;
NPCs úteis;
construção útil;
invasão compreensível;
lista de bugs críticos registrada;
lista de melhorias futuras separada do escopo atual.
```

---

## 30. Backlog futuro permitido após o Marco 0.1

Após validar o Marco 0.1, considerar:

```text
adicionar pedra;
adicionar essência mágica;
adicionar magia BloodWard;
adicionar torre de vigia;
adicionar batedor;
adicionar construtor;
adicionar segundo tipo de inimigo;
melhorar UI;
melhorar feedback visual;
melhorar animações;
adicionar salvamento simples;
adicionar primeira decisão diplomática simples.
```

Nada disso deve bloquear a entrega do Marco 0.1.

---

## 31. Matriz MoSCoW do Marco 0.1

| Classificação | Itens |
|---|---|
| Must have | Player FPS, interação, madeira, núcleo, barricada, 2 NPCs, inimigo básico, onda, vitória/derrota |
| Should have | UI mínima clara, bloqueio de construção sem recurso, cenário de vitória e derrota |
| Could have | correr simples, reparo básico, aviso de tempo até invasão |
| Won't have now | magia, diplomacia, save/load, inventário completo, mapa grande, múltiplas ondas |

---

## 32. Matriz de rastreabilidade

| Objetivo de design | Sistema que valida | Critério de aceite relacionado |
|---|---|---|
| Preparar base antes da invasão | Construção + núcleo | AC-07, AC-08, AC-09 |
| Alocar NPCs com utilidade | NPC coletor e defensor | AC-10, AC-11 |
| Criar ameaça real | EnemyBasic + WaveManager | AC-12, AC-13 |
| Gerar consequência clara | GameManager + HUD | AC-14, AC-15 |
| Validar coleta | ResourceManager | AC-04, AC-05, AC-06 |
| Validar sessão curta | Fluxo completo | AC-18 |

---

## 33. Classificação de bugs

| Severidade | Definição | Ação |
|---|---|---|
| S0 | Impede abrir o projeto/cena | Corrigir antes de qualquer avanço |
| S1 | Impede concluir vitória ou derrota | Corrigir no mesmo ciclo |
| S2 | Sistema obrigatório funciona parcialmente | Registrar e corrigir antes do Marco 0.2 |
| S3 | Problema visual, texto ou feedback menor | Pode ir para backlog |
| S4 | Polimento ou melhoria estética | Adiar |

---

## 34. Registro mínimo pós-teste

Após cada teste manual, registrar:

```text
Data do teste;
versão/build;
o que foi testado;
resultado: vitória, derrota ou travamento;
bugs encontrados;
itens fora de escopo identificados;
decisão: corrigir agora, mover para backlog ou descartar.
```

Esse registro pode ficar depois em:

```text
13_CHANGELOG.md
14_TEST_LOG.md
```

---

## 35. Regra de mudança de escopo

Qualquer item novo precisa ser classificado antes de entrar.

| Classificação | Ação |
|---|---|
| Essencial para Marco 0.1 | Pode entrar se não quebrar a fatia vertical |
| Útil, mas não essencial | Vai para backlog futuro |
| Estético | Adiar |
| Complexo | Adiar |
| Fora do conceito | Rejeitar ou registrar como ideia separada |

Toda mudança relevante deve ser registrada em:

```text
11_DECISION_LOG.md
13_CHANGELOG.md
```

### 35.1 Pergunta obrigatória antes de aceitar mudança

```text
Essa mudança ajuda a validar a primeira invasão jogável ou apenas deixa o projeto mais ambicioso?
```

Se a resposta for “apenas deixa mais ambicioso”, a mudança fica fora.

---

## 36. Resumo final do escopo

```text
O Marco 0.1 deve entregar uma primeira invasão jogável.
O jogador coleta madeira, constrói uma defesa simples, usa 2 NPCs funcionais e enfrenta 1 onda curta.
O objetivo é provar o loop base, não criar o jogo completo.
Qualquer funcionalidade que não ajude esse teste deve ficar fora.
```
