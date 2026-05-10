# 04_SYSTEMS_ARCHITECTURE.md

# Império de Sangue — Arquitetura de Sistemas

| Campo | Valor |
|---|---|
| Documento | Arquitetura de Sistemas |
| Projeto | Império de Sangue |
| Versão do documento | 1.1-corrigido |
| Engine alvo | Godot 4.x |
| Linguagem alvo | GDScript |
| Marco coberto | Marco 0.1 — Primeira invasão jogável |
| Documento anterior | 03_TECHNICAL_DESIGN.md |
| Próximo documento natural | 05_BACKLOG.md |
| Finalidade | Definir dependências, contratos, ownership, sinais e fluxos entre sistemas |

> Este documento define como os sistemas se relacionam.  
> Ele não é backlog e não é código completo. Ele é a referência para evitar acoplamento e escopo descontrolado.

---

## 1. Finalidade do documento

Este arquivo define a arquitetura sistêmica do Marco 0.1.

Ele responde:

```text
Quem é dono de cada estado?
Quem pode chamar quem?
Quais sinais existem?
Qual sistema decide vitória e derrota?
Qual sistema controla madeira?
Qual sistema controla a onda?
Como NPCs, inimigos, jogador e base se comunicam?
Como evitar que tudo dependa de tudo?
```

Objetivo direto:

```text
Permitir implementação rápida em Godot 4.x sem criar um emaranhado de dependências.
```

---

## 2. Diferença entre design técnico e arquitetura de sistemas

| Documento | Função |
|---|---|
| `03_TECHNICAL_DESIGN.md` | Define cenas, scripts, Autoloads, pseudocódigo e plano técnico inicial |
| `04_SYSTEMS_ARCHITECTURE.md` | Define relações entre sistemas, contratos, ownership, sinais e limites de dependência |

Em termos práticos:

```text
03 = quais peças existem e como começar.
04 = como as peças conversam sem virar bagunça.
```

---

## 3. Visão arquitetural do Marco 0.1

O Marco 0.1 usa arquitetura simples, orientada a cenas, sinais e responsabilidades pequenas.

```text
Autoloads globais:
- GameManager
- ResourceManager
- WaveManager

Entidades principais:
- Player
- InteractionRaycast
- SettlementCore
- Barricade
- BuildSpot
- WoodNode
- NpcBase
- NpcCollector
- NpcDefender
- EnemyBasic
- HUD
```

### 3.1 Diagrama de alto nível

```text
                         ┌────────────────┐
                         │  GameManager   │
                         │ vitória/derrota│
                         └───────┬────────┘
                                 │ sinais
       ┌─────────────────────────┼─────────────────────────┐
       │                         │                         │
┌──────▼────────┐        ┌───────▼────────┐        ┌───────▼───────┐
│ResourceManager│        │  WaveManager   │        │      HUD      │
│ madeira       │        │ onda/inimigos  │        │ exibição      │
└──────┬────────┘        └───────┬────────┘        └───────▲───────┘
       │                         │                         │
┌──────▼──────┐          ┌───────▼───────┐          ┌──────┴──────┐
│WoodNode     │          │ EnemyBasic    │          │ Player      │
│coleta       │          │ ameaça        │          │ ação direta │
└──────┬──────┘          └───────┬───────┘          └──────┬──────┘
       │                         ▼                         │
┌──────▼────────┐        ┌───────────────┐          ┌──────▼──────┐
│NpcCollector   │        │SettlementCore │◄─────────┤BuildSpot    │
│economia       │        │núcleo/derrota │          │construção   │
└──────┬────────┘        └───────▲───────┘          └──────┬──────┘
       │                         │                         │
┌──────▼────────┐        ┌───────▼───────┐          ┌──────▼──────┐
│   NpcBase     │        │ NpcDefender   │          │ Barricade   │
│estado comum   │        │ defesa        │          │ bloqueio    │
└───────────────┘        └───────────────┘          └─────────────┘
```

---

## 4. Camadas do protótipo

| Camada | Contém | Responsabilidade |
|---|---|---|
| Global | GameManager, ResourceManager, WaveManager | Estado global e coordenação |
| Entidades | Player, NPCs, inimigos, núcleo, barricada | Objetos que existem no mundo |
| Interação | InteractionRaycast, WoodNode, BuildSpot, NPCs interativos | Entrada do jogador sobre o mundo |
| Apresentação | HUD, labels, mensagens | Mostrar estado sem decidir regra |

Regra de camada:

```text
Apresentação não controla regra.
Entidade não decide estado global sozinha.
Autoload coordena, mas não deve conhecer detalhe visual.
Interação deve chamar ações pequenas e previsíveis.
```

---

## 5. Mapa de dependências

### 5.1 Dependências permitidas

| Origem | Pode depender de | Motivo |
|---|---|---|
| Player | InteractionRaycast, métodos locais de ataque/dano | Entrada e ação direta |
| InteractionRaycast | Objetos com `interact(actor)` | Interação genérica |
| WoodNode | ResourceManager | Adicionar madeira |
| BuildSpot | ResourceManager, Barricade scene | Consumir madeira e criar barricada |
| SettlementCore | GameManager por sinal | Derrota ao destruir núcleo |
| Barricade | Nenhum global obrigatório | Receber dano e destruir-se |
| NpcBase | Estado comum de NPC | Padronizar comportamento base |
| NpcCollector | NpcBase, ResourceManager | Coletar e depositar madeira |
| NpcDefender | NpcBase, EnemyBasic em alcance | Atacar ameaça |
| EnemyBasic | Target Node3D, entidades com `take_damage(amount)` | Atacar alvo |
| WaveManager | EnemyBasic scene, spawn points, sinais de morte | Spawn e fim da onda |
| HUD | Sinais dos Managers e núcleo | Exibir estado |
| GameManager | Sinais de WaveManager, Player e SettlementCore | Vitória/derrota |

### 5.2 Dependências proibidas no Marco 0.1

| Origem | Não deve depender de | Motivo |
|---|---|---|
| HUD | Regras de vitória/derrota | HUD só exibe |
| EnemyBasic | HUD | Inimigo não controla UI |
| WoodNode | HUD | Recurso não controla apresentação |
| Player | Lógica interna de cada objeto | Player só interage genericamente |
| ResourceManager | Player/NPC/HUD | ResourceManager só controla recurso |
| WaveManager | Madeira, HUD ou regras de construção | WaveManager só controla onda |
| NPCs | Diplomacia/facções/magia | Fora do escopo do Marco 0.1 |

---

## 6. Regras de comunicação entre sistemas

| Situação | Comunicação recomendada |
|---|---|
| Evento global | Signal |
| Consulta simples de recurso | Chamada direta ao ResourceManager |
| Interação do jogador com objeto | `interact(actor)` |
| Dano entre entidades | Chamada direta `take_damage(amount)` |
| Atualização de HUD | Signal |
| Vitória/derrota | GameManager |

Regras obrigatórias:

```text
Player não altera madeira diretamente.
HUD não decide vitória ou derrota.
EnemyBasic não decide fim da onda.
WaveManager não decide derrota por núcleo destruído.
SettlementCore não sabe detalhes da HUD.
NPCs não controlam estado global.
GameManager não deve virar depósito de todas as regras.
```

---

## 7. Contratos dos Autoloads

### 7.1 GameManager

Responsabilidade:

```text
Controlar estado global da sessão.
Declarar vitória.
Declarar derrota.
Bloquear fluxo após fim da sessão.
Emitir sinais globais de estado.
```

Estado permitido:

```gdscript
current_state: int
is_game_finished: bool
```

Sinais:

```gdscript
signal game_state_changed(new_state: int)
signal game_won
signal game_lost(reason: String)
```

Não deve conhecer:

```text
quantidade de madeira;
detalhes do pathfinding;
como NPC coleta;
como HUD desenha labels;
como a barricada renderiza.
```

### 7.2 ResourceManager

Responsabilidade:

```text
Controlar madeira.
Adicionar madeira.
Consumir madeira.
Emitir mudança de madeira.
Impedir recurso negativo.
```

Estado permitido:

```gdscript
wood: int
```

Sinais:

```gdscript
signal wood_changed(new_value: int)
signal resource_error(message: String)
```

Métodos esperados:

```gdscript
func add_wood(amount: int) -> void
func spend_wood(amount: int) -> bool
func get_wood() -> int
```

### 7.3 WaveManager

Responsabilidade:

```text
Controlar início da onda.
Spawnar EnemyBasic.
Contar inimigos vivos.
Emitir fim da onda.
```

Estado permitido:

```gdscript
wave_active: bool
enemies_alive: int
enemies_to_spawn: int
spawn_points: Array[Node3D]
enemy_scene: PackedScene
```

Sinais:

```gdscript
signal wave_started
signal enemy_spawned(enemy: Node)
signal enemy_killed
signal wave_finished
```

---

## 8. Contratos das entidades de jogo

### 8.1 Player

Dono de:

```text
movimento;
câmera;
vida do jogador;
ação de ataque simples;
acionamento da interação.
```

Contrato mínimo:

```gdscript
func take_damage(amount: int) -> void
func die() -> void
func attack() -> void
func try_interact() -> void
```

### 8.2 SettlementCore

Dono de:

```text
vida do núcleo;
emissão de core_destroyed;
recebimento de dano no núcleo.
```

Contrato mínimo:

```gdscript
signal core_health_changed(current: int, maximum: int)
signal core_destroyed

func take_damage(amount: int) -> void
func repair(amount: int) -> void
func is_destroyed() -> bool
```

### 8.3 Barricade

Dono de:

```text
vida da barricada;
recebimento de dano;
destruição local.
```

Contrato mínimo:

```gdscript
func take_damage(amount: int) -> void
func destroy() -> void
```

### 8.4 NpcBase

Dono de:

```text
estado comum de NPC;
transições simples;
referências básicas de destino;
contrato mínimo para ordens.
```

Estados mínimos:

```text
IDLE;
MOVING;
WORKING;
RETURNING;
DEFENDING;
DISABLED.
```

Contrato mínimo:

```gdscript
func set_state(new_state: int) -> void
func assign_task(target: Node) -> void
func clear_task() -> void
```

### 8.5 NpcCollector

Dono de:

```text
ciclo de coleta;
retorno ao ponto de depósito;
adição de madeira via ResourceManager.
```

Contrato mínimo:

```gdscript
func start_collecting() -> void
func deposit_resources() -> void
```

### 8.6 NpcDefender

Dono de:

```text
posição defensiva;
detecção de inimigos próximos;
ataque simples contra EnemyBasic.
```

Contrato mínimo:

```gdscript
func start_defending() -> void
func find_enemy_in_range() -> Node
func attack_enemy(enemy: Node) -> void
```

### 8.7 EnemyBasic

Dono de:

```text
vida própria;
alvo atual;
movimento simples até alvo;
ataque simples;
emissão de morte.
```

Contrato mínimo:

```gdscript
signal died(enemy: Node)

func set_target(new_target: Node3D) -> void
func take_damage(amount: int) -> void
func attack() -> void
func die() -> void
```

---

## 9. Contratos das cenas interativas

Regra geral:

```gdscript
func interact(actor: Node) -> void
```

| Cena | Interação esperada |
|---|---|
| WoodNode | Adiciona madeira no ResourceManager |
| BuildSpot | Consome madeira e instancia Barricade |
| NpcCollector | Recebe/ativa tarefa de coleta |
| NpcDefender | Recebe/ativa tarefa de defesa |
| SettlementCore | Exibe estado mínimo ou serve como ponto central |

---

## 10. Fluxos sistêmicos obrigatórios

O Marco 0.1 tem seis fluxos obrigatórios:

```text
coleta de madeira;
construção de barricada;
NPC coletor;
NPC defensor;
onda inimiga;
vitória/derrota.
```

Cada fluxo deve funcionar isoladamente antes da integração total.

---

## 11. Fluxo: coleta de madeira

Sequência:

```text
Player olha para WoodNode.
InteractionRaycast detecta WoodNode.
Player pressiona interagir.
InteractionRaycast chama WoodNode.interact(Player).
WoodNode chama ResourceManager.add_wood(amount).
ResourceManager altera wood.
ResourceManager emite wood_changed.
HUD atualiza contador.
```

Diagrama:

```text
Player → InteractionRaycast → WoodNode → ResourceManager → HUD
```

---

## 12. Fluxo: construção de barricada

Sequência:

```text
Player olha para BuildSpot.
InteractionRaycast detecta BuildSpot.
Player pressiona interagir.
BuildSpot verifica built == false.
BuildSpot chama ResourceManager.spend_wood(wood_cost).
Se retornar false, construção falha com feedback mínimo.
Se retornar true, BuildSpot instancia Barricade.
BuildSpot marca built = true.
HUD atualiza madeira por sinal do ResourceManager.
```

Regra crítica:

```text
BuildSpot não deve construir se ResourceManager.spend_wood() retornar false.
```

---

## 13. Fluxo: NPC coletor

Sequência:

```text
Player interage com NpcCollector.
NpcCollector herda regras comuns de NpcBase.
NpcCollector muda estado para MOVING.
NpcCollector vai até WoodNode ou ponto abstrato de coleta.
NpcCollector simula trabalho.
NpcCollector muda para RETURNING.
NpcCollector retorna ao núcleo/estoque.
NpcCollector chama ResourceManager.add_wood(amount).
ResourceManager emite wood_changed.
HUD atualiza contador.
```

Regra crítica:

```text
NpcCollector pode chamar ResourceManager, mas ResourceManager não deve conhecer NpcCollector.
```

---

## 14. Fluxo: NPC defensor

Sequência:

```text
Player interage com NpcDefender.
NpcDefender herda regras comuns de NpcBase.
NpcDefender muda estado para DEFENDING.
NpcDefender vai para ponto defensivo.
NpcDefender procura EnemyBasic em alcance.
Se encontrar, chama EnemyBasic.take_damage(amount).
EnemyBasic morre se health <= 0.
EnemyBasic emite died.
WaveManager reduz enemies_alive.
```

Regra crítica:

```text
NpcDefender não decide vitória. Ele apenas ajuda a matar ou atrasar inimigos.
```

---

## 15. Fluxo: onda inimiga

Sequência:

```text
GameManager ou comando de teste chama WaveManager.start_wave().
WaveManager muda wave_active = true.
WaveManager emite wave_started.
WaveManager instancia EnemyBasic nos spawn points.
WaveManager define alvo dos inimigos.
EnemyBasic anda até alvo.
EnemyBasic ataca Barricade ou SettlementCore.
EnemyBasic morre quando health <= 0.
WaveManager recebe morte.
WaveManager reduz enemies_alive.
Quando enemies_alive == 0, WaveManager emite wave_finished.
GameManager recebe wave_finished e declara vitória se o jogo ainda estiver em WAVE_ACTIVE.
```

Regra crítica:

```text
WaveManager controla a onda, mas GameManager controla o resultado global.
```

---

## 16. Fluxo: vitória e derrota

Vitória:

```text
WaveManager detecta fim da onda.
WaveManager emite wave_finished.
GameManager verifica estado atual.
Se estado == WAVE_ACTIVE e núcleo ainda existe, GameManager chama win_game().
GameManager emite game_won.
HUD exibe vitória.
```

Derrota por núcleo destruído:

```text
EnemyBasic ataca SettlementCore.
SettlementCore reduz health.
Se health <= 0, SettlementCore emite core_destroyed.
GameManager recebe core_destroyed.
GameManager chama lose_game("O núcleo foi destruído.").
HUD exibe derrota.
```

Regra crítica:

```text
Apenas GameManager declara vitória ou derrota global.
```

---

## 17. Matriz de sinais

| Sinal | Emissor | Receptor | Efeito |
|---|---|---|---|
| `wood_changed(new_value)` | ResourceManager | HUD | Atualiza madeira |
| `resource_error(message)` | ResourceManager | HUD opcional | Mostra feedback |
| `core_health_changed(current, maximum)` | SettlementCore | HUD | Atualiza vida do núcleo |
| `core_destroyed` | SettlementCore | GameManager | Derrota |
| `player_died` | Player | GameManager | Derrota |
| `wave_started` | WaveManager | HUD/GameManager | Atualiza estado |
| `enemy_spawned(enemy)` | WaveManager | Debug/HUD opcional | Inimigo criado |
| `died(enemy)` | EnemyBasic | WaveManager | Reduz contagem |
| `enemy_killed` | WaveManager | HUD opcional | Debug/contador |
| `wave_finished` | WaveManager | GameManager | Vitória possível |
| `game_state_changed(state)` | GameManager | HUD | Atualiza estado |
| `game_won` | GameManager | HUD | Mensagem de vitória |
| `game_lost(reason)` | GameManager | HUD | Mensagem de derrota |

---

## 18. Matriz de ownership

| Estado/dado | Dono único | Leitores permitidos | Escritores permitidos |
|---|---|---|---|
| `wood` | ResourceManager | HUD, BuildSpot, NPCs | ResourceManager via métodos públicos |
| `current_state` | GameManager | HUD, sistemas de fluxo | GameManager |
| `wave_active` | WaveManager | GameManager, HUD | WaveManager |
| `enemies_alive` | WaveManager | GameManager/debug | WaveManager |
| `core_health` | SettlementCore | HUD, GameManager | SettlementCore via `take_damage/repair` |
| `player_health` | Player | HUD opcional, GameManager | Player via `take_damage` |
| `barricade_health` | Barricade | EnemyBasic/debug | Barricade via `take_damage` |
| `npc_state` | NpcBase/NPC específico | Player/debug | Próprio NPC |
| `enemy_health` | EnemyBasic | NPC/Player/debug | EnemyBasic via `take_damage` |

Regra:

```text
Quem é dono do estado altera o estado.
Outros sistemas pedem alteração por método público ou recebem evento por sinal.
```

---

## 19. Regras anti-acoplamento

### 19.1 Player genérico

Player deve interagir com qualquer objeto que tenha `interact(actor)`.

Player não deve ter código como:

```text
if objeto == madeira;
if objeto == npc;
if objeto == buildspot.
```

### 19.2 HUD passiva

HUD apenas:

```text
recebe sinal;
atualiza texto;
mostra mensagem;
oculta mensagem.
```

### 19.3 Managers pequenos

```text
GameManager controla estado global.
ResourceManager controla recurso.
WaveManager controla onda.
```

### 19.4 Entidade decide seu dano

```text
EnemyBasic.take_damage();
SettlementCore.take_damage();
Barricade.take_damage();
Player.take_damage().
```

---

## 20. Sequência de inicialização

Ordem recomendada quando `Main.tscn` carregar:

```text
1. Autoloads já existem por configuração do projeto.
2. Main instancia/carrega TestMap.
3. Main instancia Player.
4. Main instancia HUD.
5. Main garante SettlementCore na cena.
6. Main registra referências necessárias no WaveManager, se necessário.
7. HUD conecta sinais de ResourceManager, GameManager e SettlementCore.
8. SettlementCore conecta core_destroyed ao GameManager.
9. WaveManager conecta wave_finished ao GameManager.
10. GameManager chama start_game().
```

Regra prática:

```text
Clareza > automação excessiva.
```

---

## 21. Sequência de encerramento

Quando vitória ou derrota ocorrer:

```text
GameManager altera estado para VICTORY ou DEFEAT.
GameManager emite game_won ou game_lost.
HUD mostra resultado.
Player pode ter input bloqueado ou ignorado.
WaveManager não deve spawnar novos inimigos.
NPCs podem parar ou ficar em IDLE.
```

Regra:

```text
Depois de vitória ou derrota, nenhum sistema deve continuar alterando resultado global.
```

---

## 22. Contratos mínimos por arquivo

| Arquivo | Contrato mínimo |
|---|---|
| `game_manager.gd` | Estado global, vitória e derrota |
| `resource_manager.gd` | Madeira global e sinais de recurso |
| `wave_manager.gd` | Iniciar onda, spawn, contagem e fim |
| `player.gd` | Movimento, ataque, dano e interação |
| `interaction_raycast.gd` | Detectar e chamar `interact(actor)` |
| `wood_node.gd` | Adicionar madeira ao ResourceManager |
| `build_spot.gd` | Consumir madeira e criar Barricade |
| `barricade.gd` | Receber dano e destruir-se |
| `settlement_core.gd` | Vida do núcleo e sinal de destruição |
| `npc_base.gd` | Estado básico de NPC |
| `npc_collector.gd` | Ciclo de coleta e depósito |
| `npc_defender.gd` | Defesa e ataque a inimigos |
| `enemy_basic.gd` | Movimento, ataque, dano e morte |
| `hud.gd` | Exibição de madeira, vida, onda e resultado |

---

## 23. Erros arquiteturais prováveis

| Erro | Sintoma | Correção |
|---|---|---|
| Player sabe demais | `player.gd` cheio de if para cada objeto | Usar `interact(actor)` |
| HUD decide regra | Vitória/derrota dentro de `hud.gd` | Mover para GameManager |
| ResourceManager conhece HUD | Manager chama label diretamente | Usar sinal `wood_changed` |
| WaveManager decide tudo | Onda controla derrota, UI e inimigo | Limitar WaveManager à onda |
| NPC autônomo demais | NPC age fora da ordem do jogador | Reduzir estados e ações |
| Inimigo complexo demais | Pathfinding vira problema central | Usar rota/alvo simples |
| BuildSpot gratuito | Coleta perde função | Exigir `spend_wood` |

---

## 24. Testes arquiteturais manuais

```text
[ ] Player interage com WoodNode sem conhecer classe concreta.
[ ] WoodNode altera madeira apenas via ResourceManager.
[ ] HUD atualiza madeira por sinal.
[ ] BuildSpot não constrói sem madeira.
[ ] BuildSpot instancia Barricade após consumir madeira.
[ ] SettlementCore emite core_destroyed quando vida chega a 0.
[ ] GameManager declara derrota ao receber core_destroyed.
[ ] WaveManager encerra onda quando enemies_alive chega a 0.
[ ] GameManager declara vitória ao receber wave_finished.
[ ] HUD só mostra vitória/derrota; não decide resultado.
[ ] EnemyBasic não chama HUD.
[ ] NpcBase contém estado comum de NPC.
[ ] NPCs não alteram estado global diretamente.
```

---

## 25. Checklist arquitetural

Antes de avançar para implementação pesada, confirmar:

```text
[ ] Cada estado tem dono claro.
[ ] Cada sistema tem responsabilidade única.
[ ] Autoloads são apenas 3 no Marco 0.1.
[ ] HUD é passiva.
[ ] GameManager controla vitória/derrota.
[ ] ResourceManager controla madeira.
[ ] WaveManager controla onda.
[ ] Player interage genericamente.
[ ] BuildSpot consome madeira via ResourceManager.
[ ] SettlementCore não conhece HUD diretamente.
[ ] EnemyBasic não decide fim de onda.
[ ] NpcBase existe como base comum dos NPCs.
[ ] NpcCollector não altera UI.
[ ] NpcDefender não declara vitória.
```

---

## 26. Regras para expansão futura

Só expandir arquitetura depois do Marco 0.1 funcionar.

| Expansão | Quando considerar |
|---|---|
| InventoryManager | Quando houver mais de 3 recursos ou itens carregáveis |
| BuildManager | Quando houver construção livre ou múltiplas estruturas |
| QuestManager | Quando houver objetivos narrativos |
| FactionManager | Quando diplomacia entrar no protótipo |
| SaveManager | Quando sessão precisar persistir |
| AudioManager | Quando áudio virar parte real do feedback |

Regra:

```text
Não criar Manager futuro antes de existir necessidade real.
```

---

## 27. Regra para Codex/IA gerar código

Todo pedido de código deve informar o contrato arquitetural.

Modelo mínimo:

```text
Crie o script [nome] para Godot 4.x em GDScript.
Ele pertence ao Marco 0.1 de Império de Sangue.
Respeite a arquitetura:
- GameManager decide vitória/derrota.
- ResourceManager controla madeira.
- WaveManager controla onda.
- HUD só exibe estado.
- Player interage via interact(actor).
- NPCs compartilham comportamento comum via NpcBase.
Não adicione sistemas fora do escopo.
```

---

## 28. Definition of Done arquitetural

A arquitetura do Marco 0.1 estará adequada quando:

```text
Fluxo de coleta funciona sem Player alterar madeira diretamente.
Fluxo de construção funciona sem BuildSpot criar madeira artificialmente.
Fluxo de NPC coletor usa ResourceManager corretamente.
Fluxo de NPC defensor afeta EnemyBasic sem decidir vitória.
Fluxo de onda termina via WaveManager.
Fluxo de vitória/derrota passa pelo GameManager.
HUD recebe sinais e não controla regras.
NpcBase centraliza estado comum de NPC.
Cada sistema pode ser explicado em uma frase.
```

---

## 29. Resumo final da arquitetura

```text
A arquitetura do Marco 0.1 usa três Autoloads: GameManager, ResourceManager e WaveManager.
GameManager é dono de vitória, derrota e estado global.
ResourceManager é dono da madeira.
WaveManager é dono da onda.
Player interage genericamente com objetos do mundo usando interact(actor).
HUD apenas exibe informações.
NpcBase centraliza comportamento comum dos NPCs.
NpcCollector e NpcDefender especializam funções simples.
Entidades como SettlementCore, Barricade e EnemyBasic controlam seu próprio estado local.
A comunicação usa sinais para eventos globais e chamadas diretas para ações locais simples.
```
