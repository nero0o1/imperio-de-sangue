# 03_TECHNICAL_DESIGN.md

# Império de Sangue — Design Técnico

| Campo | Valor |
|---|---|
| Documento | Design Técnico |
| Projeto | Império de Sangue |
| Versão do documento | 1.0 |
| Engine alvo | Godot 4.x |
| Linguagem alvo | GDScript |
| Marco coberto | Marco 0.1 — Primeira invasão jogável |
| Finalidade | Traduzir o escopo do protótipo em arquitetura técnica inicial |
| Documento anterior | 02_PROTOTYPE_SCOPE.md |
| Próximo documento natural | 04_SYSTEMS_ARCHITECTURE.md |
| Status | Base técnica para iniciar implementação |

> Este documento define como o Marco 0.1 será implementado tecnicamente na Godot.  
> Ele não é código final. Ele é o mapa técnico para cenas, scripts, autoloads, sinais e fluxo de execução.

---

## 1. Finalidade do documento

Este arquivo transforma o escopo do protótipo em um plano técnico de implementação.

Ele responde:

```text
Quais cenas precisam existir?
Quais scripts precisam existir?
Quais sistemas serão Autoloads?
Como os sistemas conversam?
Qual é o fluxo técnico da sessão?
Quais sinais serão emitidos?
Como evitar acoplamento excessivo?
Qual ordem técnica reduz retrabalho?
```

Este documento não substitui:

```text
04_SYSTEMS_ARCHITECTURE.md;
05_BACKLOG.md;
06_AI_CODEX_RULES.md;
11_DECISION_LOG.md.
```

---

## 2. Premissas técnicas

| Premissa | Decisão |
|---|---|
| Engine | Godot 4.x |
| Linguagem | GDScript |
| Plataforma inicial | PC |
| Perspectiva | Primeira pessoa |
| Arquitetura | Simples, modular e suficiente para protótipo solo |
| Persistência | Fora do Marco 0.1 |
| Multiplayer | Fora do Marco 0.1 |
| Inventário completo | Fora do Marco 0.1 |
| Assets finais | Fora do Marco 0.1 |
| Testes | Teste manual + scripts simples com validação por cena |

### 2.1 Regra técnica central

```text
Implementar primeiro o menor sistema jogável possível.
Refatorar depois que o loop funcionar.
Não criar arquitetura genérica demais antes de validar o protótipo.
```

---

## 3. Arquitetura geral

A arquitetura do Marco 0.1 deve ser dividida em sistemas pequenos:

```text
GameManager
→ controla estado geral da sessão

ResourceManager
→ controla madeira e recursos globais

WaveManager
→ controla início, andamento e fim da invasão

Player
→ controla movimento, câmera, interação e ataque simples

Interaction System
→ detecta objeto interativo pelo olhar do jogador

Settlement System
→ controla núcleo, vida da base e derrota

Building System
→ controla construção de barricada

NPC System
→ controla coletor e defensor

Enemy System
→ controla inimigo básico

UI System
→ mostra madeira, vida, onda, vitória e derrota
```

### 3.1 Diagrama simplificado

```text
                 ┌──────────────┐
                 │  GameManager │
                 └──────┬───────┘
                        │
        ┌───────────────┼────────────────┐
        │               │                │
┌───────▼───────┐ ┌─────▼──────┐ ┌───────▼───────┐
│ResourceManager│ │WaveManager │ │     HUD       │
└───────┬───────┘ └─────┬──────┘ └───────▲───────┘
        │               │                │
        │        ┌──────▼──────┐         │
        │        │ EnemyBasic  │         │
        │        └──────┬──────┘         │
        │               │                │
┌───────▼───────┐ ┌─────▼──────┐ ┌───────┴───────┐
│  NpcCollector │ │Settlement  │ │    Player     │
└───────────────┘ │Core        │ └───────────────┘
                  └────────────┘
```

### 3.2 Diretriz de acoplamento

```text
Cenas concretas podem chamar Autoloads.
Autoloads não devem depender de cenas específicas sempre que possível.
Comunicação de eventos deve usar sinais quando reduzir acoplamento.
Código simples é preferível a abstração prematura.
```

---

## 4. Estrutura de pastas Godot

Estrutura sugerida para o Marco 0.1:

```text
res://
  scenes/
    main/
      Main.tscn
    player/
      Player.tscn
    npc/
      NpcCollector.tscn
      NpcDefender.tscn
    enemies/
      EnemyBasic.tscn
    settlement/
      SettlementCore.tscn
      Barricade.tscn
      BuildSpot.tscn
    resources/
      WoodNode.tscn
    ui/
      HUD.tscn
    test/
      TestMap.tscn

  scripts/
    core/
      game_manager.gd
      resource_manager.gd
      wave_manager.gd
      game_state.gd
    player/
      player.gd
      interaction_raycast.gd
    npc/
      npc_base.gd
      npc_collector.gd
      npc_defender.gd
    enemies/
      enemy_basic.gd
    settlement/
      settlement_core.gd
      barricade.gd
      build_spot.gd
    resources/
      wood_node.gd
    ui/
      hud.gd

  assets_temp/
    materials/
    meshes/
    icons/

  docs/
    00_PROJECT_OVERVIEW.md
    01_GAME_CONCEPT.md
    02_PROTOTYPE_SCOPE.md
    03_TECHNICAL_DESIGN.md
```

### 4.1 Regra para assets temporários

Tudo que for placeholder deve ficar em:

```text
res://assets_temp/
```

Assim fica claro o que pode ser substituído depois.

---

## 5. Autoloads

Autoloads recomendados para o Marco 0.1:

| Autoload | Script | Responsabilidade |
|---|---|---|
| GameManager | `res://scripts/core/game_manager.gd` | Estado geral da sessão, vitória, derrota e fluxo principal |
| ResourceManager | `res://scripts/core/resource_manager.gd` | Madeira e recursos globais |
| WaveManager | `res://scripts/core/wave_manager.gd` | Controle da onda inimiga |

### 5.1 Por que usar Autoloads aqui

Autoloads ajudam no protótipo porque:

```text
simplificam acesso global;
evitam passar referência manual em toda cena;
facilitam HUD acessar estado;
centralizam vitória/derrota;
reduzem configuração inicial.
```

### 5.2 Risco dos Autoloads

Autoloads em excesso viram estado global bagunçado.

Regra:

```text
Só usar Autoload para estado realmente global.
Não transformar todo script em Autoload.
```

---

## 6. Cenas principais

| Cena | Caminho | Função |
|---|---|---|
| Main | `res://scenes/main/Main.tscn` | Cena principal que junta mapa, jogador, HUD e sistemas visuais |
| TestMap | `res://scenes/test/TestMap.tscn` | Mapa pequeno de validação |
| Player | `res://scenes/player/Player.tscn` | Jogador em primeira pessoa |
| HUD | `res://scenes/ui/HUD.tscn` | Interface mínima |
| SettlementCore | `res://scenes/settlement/SettlementCore.tscn` | Núcleo da base |
| Barricade | `res://scenes/settlement/Barricade.tscn` | Defesa simples |
| BuildSpot | `res://scenes/settlement/BuildSpot.tscn` | Ponto de construção da barricada |
| WoodNode | `res://scenes/resources/WoodNode.tscn` | Madeira coletável |
| NpcCollector | `res://scenes/npc/NpcCollector.tscn` | NPC coletor |
| NpcDefender | `res://scenes/npc/NpcDefender.tscn` | NPC defensor |
| EnemyBasic | `res://scenes/enemies/EnemyBasic.tscn` | Inimigo básico |

---

## 7. Sistemas obrigatórios do Marco 0.1

| Sistema | Script principal | Depende de | Entrega mínima |
|---|---|---|---|
| Player System | `player.gd` | Input, CharacterBody3D | Movimento e ataque simples |
| Interaction System | `interaction_raycast.gd` | Camera3D/RayCast3D | Interagir com objetos olhando para eles |
| Resource System | `resource_manager.gd` | Autoload | Madeira global |
| Settlement System | `settlement_core.gd` | GameManager | Vida do núcleo e derrota |
| Building System | `build_spot.gd` | ResourceManager | Construir barricada consumindo madeira |
| NPC System | `npc_base.gd` | ResourceManager/Enemy | Coletor e defensor funcionais |
| Enemy System | `enemy_basic.gd` | SettlementCore | Inimigo ataca núcleo/defesa |
| Wave System | `wave_manager.gd` | EnemyBasic/GameManager | Iniciar e encerrar onda |
| UI System | `hud.gd` | Sinais/Autoloads | Mostrar estado mínimo |

---

## 8. Fluxo técnico da sessão

```text
Main.tscn carrega
→ GameManager entra em Setup
→ ResourceManager inicia madeira = 0
→ Player é posicionado
→ SettlementCore é ativado
→ HUD conecta sinais
→ Jogador coleta madeira
→ ResourceManager emite resource_changed
→ Jogador constrói barricada no BuildSpot
→ ResourceManager consome madeira
→ NPC coletor recebe tarefa
→ NPC defensor recebe tarefa
→ WaveManager inicia onda
→ EnemyBasic spawna e busca núcleo
→ combate/defesa acontece
→ WaveManager detecta fim da onda
→ GameManager declara Victory ou Defeat
→ HUD exibe resultado
```

---

## 9. Player System

### 9.1 Cena sugerida

```text
Player.tscn
  CharacterBody3D
    Camera3D
      RayCast3D
    CollisionShape3D
```

### 9.2 Script

```text
res://scripts/player/player.gd
```

### 9.3 Responsabilidades

```text
movimento FPS;
controle de câmera;
interação com RayCast;
ataque simples;
vida do jogador;
morte do jogador;
chamada para GameManager em caso de derrota.
```

### 9.4 Fora do escopo

```text
animação final;
inventário completo;
arma complexa;
equipamentos;
stamina profunda;
sistema de classes;
árvore de habilidade.
```

### 9.5 Interface técnica mínima

```gdscript
func take_damage(amount: int) -> void
func die() -> void
func attack() -> void
func try_interact() -> void
```

---

## 10. Interaction System

### 10.1 Responsabilidade

O sistema de interação deve permitir que o jogador olhe para um objeto e execute uma ação simples.

### 10.2 Objetos interativos no Marco 0.1

```text
WoodNode;
BuildSpot;
NpcCollector;
NpcDefender;
SettlementCore.
```

### 10.3 Padrão mínimo de interface

Em GDScript, usar método simples:

```gdscript
func interact(actor: Node) -> void:
    pass
```

Ou, se preferir mais organização depois, criar uma convenção documentada em vez de interface formal.

### 10.4 Regra técnica

```text
O RayCast detecta.
O objeto decide o que acontece.
O Player não deve conter lógica específica de madeira, NPC, núcleo e barricada.
```

---

## 11. Resource System

### 11.1 Autoload

```text
ResourceManager
res://scripts/core/resource_manager.gd
```

### 11.2 Estado mínimo

```gdscript
var wood: int = 0
```

### 11.3 Sinais

```gdscript
signal wood_changed(new_value: int)
signal resource_error(message: String)
```

### 11.4 Funções mínimas

```gdscript
func add_wood(amount: int) -> void
func can_spend_wood(amount: int) -> bool
func spend_wood(amount: int) -> bool
func reset() -> void
```

### 11.5 Regras

```text
wood nunca pode ficar negativo;
spend_wood retorna false se não houver madeira suficiente;
toda alteração em wood emite wood_changed;
ResourceManager não conhece Player, NPC ou HUD diretamente.
```

---

## 12. Settlement System

### 12.1 Cena

```text
SettlementCore.tscn
  StaticBody3D ou Node3D
    MeshInstance3D
    CollisionShape3D
```

### 12.2 Script

```text
res://scripts/settlement/settlement_core.gd
```

### 12.3 Estado mínimo

```gdscript
var max_health: int = 100
var health: int = 100
```

### 12.4 Sinais

```gdscript
signal core_health_changed(current: int, maximum: int)
signal core_destroyed
```

### 12.5 Funções mínimas

```gdscript
func take_damage(amount: int) -> void
func repair(amount: int) -> void
func is_destroyed() -> bool
```

### 12.6 Regra de derrota

Quando `health <= 0`, o núcleo emite `core_destroyed` e o `GameManager` declara derrota.

---

## 13. Building System

### 13.1 Cenas

```text
BuildSpot.tscn
Barricade.tscn
```

### 13.2 BuildSpot

Responsável por construir barricada em posição simples.

Estado mínimo:

```gdscript
var barricade_scene: PackedScene
var wood_cost: int = 5
var built: bool = false
```

Funções mínimas:

```gdscript
func interact(actor: Node) -> void
func can_build() -> bool
func build() -> void
```

### 13.3 Barricade

Responsável por receber dano e interferir na rota/ataque inimigo.

Estado mínimo:

```gdscript
var max_health: int = 50
var health: int = 50
```

Funções mínimas:

```gdscript
func take_damage(amount: int) -> void
func destroy() -> void
```

### 13.4 Regra

A barricada deve consumir madeira. Se for gratuita, não valida o loop de coleta.

---

## 14. NPC System

### 14.1 Base técnica

Criar `NpcBase` para compartilhar comportamento mínimo.

```text
res://scripts/npc/npc_base.gd
```

### 14.2 Estados mínimos

```gdscript
enum NpcState {
    IDLE,
    MOVING_TO_TASK,
    WORKING,
    RETURNING,
    DEFENDING,
    DISABLED
}
```

### 14.3 NpcCollector

Responsabilidade:

```text
receber ordem de coleta;
ir até ponto de madeira;
simular coleta;
voltar ao núcleo/estoque;
adicionar madeira ao ResourceManager.
```

Funções mínimas:

```gdscript
func assign_collect_task(target: Node3D) -> void
func collect() -> void
func deposit() -> void
```

### 14.4 NpcDefender

Responsabilidade:

```text
receber ordem de defesa;
ir até ponto defensivo;
detectar inimigo próximo;
atacar inimigo;
ajudar a proteger núcleo/barricada.
```

Funções mínimas:

```gdscript
func assign_defense_task(defense_point: Node3D) -> void
func find_target() -> Node3D
func attack_target(target: Node3D) -> void
```

### 14.5 Regra anti-complexidade

Não usar comportamento emergente complexo no Marco 0.1. O NPC deve parecer útil, não inteligente.

---

## 15. Enemy System

### 15.1 Cena

```text
EnemyBasic.tscn
  CharacterBody3D
    MeshInstance3D
    CollisionShape3D
```

### 15.2 Script

```text
res://scripts/enemies/enemy_basic.gd
```

### 15.3 Estado mínimo

```gdscript
var health: int = 30
var damage: int = 5
var attack_range: float = 1.5
var move_speed: float = 2.0
var target: Node3D
```

### 15.4 Funções mínimas

```gdscript
func set_target(new_target: Node3D) -> void
func take_damage(amount: int) -> void
func die() -> void
func attack() -> void
```

### 15.5 Comportamento mínimo

```text
Se não estiver no alcance do alvo, mover em direção ao alvo.
Se estiver no alcance, atacar em intervalo simples.
Se vida chegar a 0, morrer e avisar WaveManager.
```

### 15.6 Alvo

Prioridade simples:

```text
Barricada, se existir e estiver no caminho.
Núcleo, se não houver barricada ativa.
Defensor, se a implementação simples permitir.
```

---

## 16. Wave System

### 16.1 Autoload

```text
WaveManager
res://scripts/core/wave_manager.gd
```

### 16.2 Responsabilidades

```text
iniciar onda;
spawnar EnemyBasic;
contar inimigos vivos;
detectar fim da onda;
avisar GameManager sobre vitória possível.
```

### 16.3 Estado mínimo

```gdscript
var wave_active: bool = false
var enemies_alive: int = 0
var enemies_to_spawn: int = 3
```

### 16.4 Sinais

```gdscript
signal wave_started
signal enemy_spawned(enemy: Node)
signal enemy_killed
signal wave_finished
```

### 16.5 Funções mínimas

```gdscript
func start_wave() -> void
func spawn_enemy() -> void
func notify_enemy_killed() -> void
func finish_wave() -> void
```

### 16.6 Regra

WaveManager não deve cuidar de UI diretamente. Ele emite sinais; HUD ou GameManager reagem.

---

## 17. UI System

### 17.1 Cena

```text
HUD.tscn
  CanvasLayer
    Control
      LabelWood
      LabelCoreHealth
      LabelWave
      LabelResult
      LabelInteraction
```

### 17.2 Script

```text
res://scripts/ui/hud.gd
```

### 17.3 Responsabilidades

```text
mostrar madeira;
mostrar vida do núcleo;
mostrar aviso de onda;
mostrar vitória;
mostrar derrota;
mostrar texto de interação.
```

### 17.4 Regra

HUD não decide regra de jogo. HUD apenas exibe estado recebido.

---

## 18. Estados globais de jogo

### 18.1 Enum sugerido

```gdscript
enum GameState {
    SETUP,
    EXPLORATION,
    PREPARATION,
    WAVE_ACTIVE,
    VICTORY,
    DEFEAT
}
```

### 18.2 Transições

```text
SETUP → EXPLORATION
EXPLORATION → PREPARATION
PREPARATION → WAVE_ACTIVE
WAVE_ACTIVE → VICTORY
WAVE_ACTIVE → DEFEAT
EXPLORATION/PREPARATION → DEFEAT, se jogador morrer ou núcleo cair
```

### 18.3 GameManager

Responsável por:

```text
armazenar estado atual;
receber evento de núcleo destruído;
receber evento de jogador morto;
receber evento de onda finalizada;
declarar vitória ou derrota;
impedir ações depois do fim da sessão.
```

---

## 19. Sinais e comunicação entre sistemas

| Emissor | Sinal | Receptor típico | Função |
|---|---|---|---|
| ResourceManager | `wood_changed` | HUD | Atualizar contador de madeira |
| SettlementCore | `core_health_changed` | HUD | Atualizar vida do núcleo |
| SettlementCore | `core_destroyed` | GameManager | Declarar derrota |
| WaveManager | `wave_started` | HUD/GameManager | Avisar início da onda |
| WaveManager | `wave_finished` | GameManager | Avaliar vitória |
| EnemyBasic | `died` | WaveManager | Reduzir inimigos vivos |
| Player | `player_died` | GameManager | Declarar derrota |
| GameManager | `game_won` | HUD | Exibir vitória |
| GameManager | `game_lost` | HUD | Exibir derrota |

### 19.1 Regra de comunicação

```text
Use chamada direta quando for simples e local.
Use sinal quando o evento interessar a mais de um sistema.
Não faça HUD controlar regra de jogo.
Não faça EnemyBasic decidir vitória.
Não faça Player alterar madeira diretamente sem ResourceManager.
```

---

## 20. Ordem técnica de implementação

### 20.1 Etapa 1 — Cena principal

```text
Criar Main.tscn.
Criar TestMap.tscn.
Instanciar Player.
Instanciar HUD.
Instanciar SettlementCore.
```

### 20.2 Etapa 2 — Player

```text
Movimento FPS.
Câmera.
RayCast3D.
Interação genérica.
Ataque simples.
```

### 20.3 Etapa 3 — Recursos

```text
ResourceManager como Autoload.
WoodNode interativo.
Coleta manual.
HUD mostrando madeira.
```

### 20.4 Etapa 4 — Núcleo e construção

```text
SettlementCore com vida.
BuildSpot.
Barricade.
Consumo de madeira.
Bloqueio sem recurso.
```

### 20.5 Etapa 5 — Inimigo

```text
EnemyBasic.
Movimento até alvo.
Ataque ao núcleo.
Morte do inimigo.
```

### 20.6 Etapa 6 — Onda

```text
WaveManager.
Spawn de inimigos.
Contagem de inimigos vivos.
Fim da onda.
```

### 20.7 Etapa 7 — NPCs

```text
NpcBase.
NpcCollector.
NpcDefender.
Atribuição simples por interação.
```

### 20.8 Etapa 8 — Estados finais

```text
GameManager detecta vitória.
GameManager detecta derrota.
HUD exibe resultado.
Bloquear ações após fim.
```

---

## 21. Pseudocódigo do GameManager

```gdscript
extends Node

signal game_won
signal game_lost(reason: String)
signal game_state_changed(new_state: int)

enum GameState { SETUP, EXPLORATION, PREPARATION, WAVE_ACTIVE, VICTORY, DEFEAT }

var current_state: GameState = GameState.SETUP

func set_state(new_state: GameState) -> void:
    current_state = new_state
    game_state_changed.emit(new_state)

func start_game() -> void:
    set_state(GameState.EXPLORATION)

func start_wave() -> void:
    set_state(GameState.WAVE_ACTIVE)
    WaveManager.start_wave()

func on_core_destroyed() -> void:
    lose_game("O núcleo foi destruído.")

func on_player_died() -> void:
    lose_game("O jogador morreu.")

func on_wave_finished() -> void:
    if current_state == GameState.WAVE_ACTIVE:
        win_game()

func win_game() -> void:
    set_state(GameState.VICTORY)
    game_won.emit()

func lose_game(reason: String) -> void:
    set_state(GameState.DEFEAT)
    game_lost.emit(reason)
```

---

## 22. Pseudocódigo do ResourceManager

```gdscript
extends Node

signal wood_changed(new_value: int)
signal resource_error(message: String)

var wood: int = 0

func reset() -> void:
    wood = 0
    wood_changed.emit(wood)

func add_wood(amount: int) -> void:
    if amount <= 0:
        return
    wood += amount
    wood_changed.emit(wood)

func can_spend_wood(amount: int) -> bool:
    return wood >= amount

func spend_wood(amount: int) -> bool:
    if amount <= 0:
        return true
    if wood < amount:
        resource_error.emit("Madeira insuficiente.")
        return false
    wood -= amount
    wood_changed.emit(wood)
    return true
```

---

## 23. Erros técnicos esperados e resposta

| Erro | Causa provável | Resposta |
|---|---|---|
| Player atravessa chão | Colisão/camada errada | Revisar CollisionShape3D e layer |
| Raycast não detecta objeto | Máscara/camada errada | Conferir collision mask |
| Madeira não atualiza na HUD | Sinal não conectado | Conectar `wood_changed` |
| Barricada constrói sem madeira | Falha em `spend_wood` | Bloquear construção se retornar false |
| Inimigo não anda | Target nulo ou navegação ausente | Definir alvo manualmente |
| Vitória não dispara | Inimigos vivos não decrementam | Conferir sinal de morte |
| Derrota não dispara | Núcleo não emite sinal | Conferir `core_destroyed` |

---

## 24. Regras para geração de código por IA

Todo prompt para IA gerar código deve conter:

```text
Projeto: Império de Sangue.
Engine: Godot 4.x.
Linguagem: GDScript.
Marco: 0.1 — Primeira invasão jogável.
Não usar multiplayer.
Não criar save/load.
Não criar inventário completo.
Não adicionar sistemas fora do escopo.
Gerar código simples, testável e compatível com cenas pequenas.
```

### 24.1 Proibido para IA neste marco

```text
criar arquitetura ECS complexa;
criar framework próprio;
adicionar addons externos;
gerar sistema procedural;
criar múltiplas camadas de herança sem necessidade;
criar manager para tudo;
reescrever escopo.
```

---

## 25. Definition of Done técnico

O design técnico do Marco 0.1 estará cumprido quando:

```text
Main.tscn abre sem erro.
Player se move em primeira pessoa.
Raycast interage com WoodNode, BuildSpot e NPCs.
ResourceManager controla madeira.
SettlementCore tem vida e emite sinal de destruição.
BuildSpot cria Barricade consumindo madeira.
NpcCollector gera madeira no estoque.
NpcDefender ataca ou bloqueia inimigo.
EnemyBasic ataca núcleo ou barricada.
WaveManager inicia e encerra onda.
GameManager declara vitória e derrota.
HUD mostra madeira, vida do núcleo e resultado.
```

---

## 26. Checklist técnico antes de avançar

```text
[ ] Autoloads configurados no Project Settings.
[ ] Main.tscn definida como cena principal.
[ ] Player instanciado no mapa.
[ ] HUD instanciada e visível.
[ ] WoodNode interativo funcionando.
[ ] ResourceManager emitindo wood_changed.
[ ] SettlementCore emitindo core_destroyed.
[ ] BuildSpot consumindo madeira.
[ ] Barricade recebendo dano.
[ ] EnemyBasic recebendo e causando dano.
[ ] WaveManager contando inimigos vivos.
[ ] GameManager recebendo fim da onda.
[ ] Vitória e derrota testadas.
```

---

## 27. Limites de refatoração

Refatorar só quando houver problema real.

Refatoração permitida:

```text
renomear scripts confusos;
remover duplicação evidente;
separar arquivo muito grande;
centralizar sinal repetido;
melhorar legibilidade sem mudar comportamento.
```

Refatoração bloqueada no Marco 0.1:

```text
criar arquitetura genérica para todos os sistemas futuros;
migrar tudo para padrão complexo;
criar plugin interno;
reescrever sistemas funcionais só por estética;
criar abstrações para coisas que ainda só existem uma vez.
```

---

## 28. Relação com próximos documentos

| Documento | Função depois deste |
|---|---|
| 04_SYSTEMS_ARCHITECTURE.md | Detalhar dependências, diagramas e contratos entre sistemas |
| 05_BACKLOG.md | Transformar etapas técnicas em tarefas executáveis |
| 06_AI_CODEX_RULES.md | Definir regras para Codex/IA gerar código sem sair do escopo |
| 07_TEST_PLAN.md | Formalizar testes manuais e critérios de regressão |
| 11_DECISION_LOG.md | Registrar decisões técnicas relevantes |

---

## 29. Resumo final do design técnico

```text
O Marco 0.1 será implementado em Godot 4.x com GDScript.
A arquitetura usa poucos Autoloads: GameManager, ResourceManager e WaveManager.
As cenas principais são Player, TestMap, HUD, SettlementCore, BuildSpot, Barricade, WoodNode, NpcCollector, NpcDefender e EnemyBasic.
O foco técnico é validar coleta, construção, NPCs, inimigo, onda, vitória e derrota.
Qualquer arquitetura mais complexa deve esperar o loop mínimo funcionar.
```
