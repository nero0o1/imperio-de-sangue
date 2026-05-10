# ADR-0005: Bloqueio de Input de Gameplay pela UI

## Contexto e Problema
Com a introdução da HUD de Inventário (Wave 2.11 e 2.11.1), um novo estado foi adicionado: a UI pode estar aberta sobrepondo o gameplay normal em primeira pessoa.
O problema observado (Wave 2.11.2) é que o jogador e a câmera continuavam respondendo a inputs de movimento (WASD), pulo, e recapturavam o mouse se o jogador clicasse fora da janela da interface da HUD.
Isso causava um estado inconsistente e movimentos indesejados no jogo enquanto a tela da HUD estava ativa.

## Decisão
Implementar um sistema de bloqueio de gameplay com baixo acoplamento, baseado em grupos (Group: `gameplay_input_blocker`).

1. **Player.gd atua como cliente reativo**:
   O nó `Player` verifica via `get_tree().get_nodes_in_group("gameplay_input_blocker")` tanto em `_physics_process` quanto em `_unhandled_input`.
   Se algum nó desse grupo tiver o método `is_inventory_ui_open()` retornando `true`, o Player aborta as leituras de teclado/mouse e apenas aplica inércia/gravidade (`_apply_movement_blocked`).

2. **GameHUD implementa a interface bloqueadora**:
   O nó `GameHUD` foi inserido no grupo `gameplay_input_blocker` e usa a já existente função `is_inventory_ui_open()`.
   A raiz e um novo nó `BackgroundBlocker` (ColorRect) receberam `mouse_filter = 0` (MOUSE_FILTER_STOP) para interceptar todos os cliques do mouse que seriam propagados para o jogo.

3. **Proteção Contínua do Mouse**:
   O script `game_hud.gd` força o mouse para o modo `VISIBLE` em `_process` quando a HUD está aberta, para reverter imediatamente qualquer captura acidental.

## Consequências
- **Positivas**:
  - Acoplamento extremamente frouxo: o Player não conhece o GameHUD.
  - Facilmente escalável para outras UIs (Menus, Diálogos, Lojas) apenas adicionando o grupo e o método de checagem.
  - O personagem para de se mover graciosamente usando a fricção/desaceleração programada se a UI for aberta enquanto ele corre ou pula.
- **Negativas**:
  - Chamada a `get_nodes_in_group()` no `_physics_process` tem custo maior que uma referência direta, mas perfeitamente aceitável para o escopo e garante isolamento das lógicas.
