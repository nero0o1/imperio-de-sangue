# ADR-0004 — Wave 2.11.1: Toggle de Inventário pela Tecla I

- **Status:** Accepted
- **Data:** 2026-05-04
- **Wave:** 2.11.1
- **Decisor:** Equipe de desenvolvimento — Império de Sangue

---

## Contexto

A Wave 2.11 introduziu a HUD visual modular (`GameHUD`) somente leitura para exibir `PlayerInventory`, `Warehouse` e `BuildingSite`. A HUD era exibida estaticamente ao iniciar a cena, sem mecanismo de abertura/fechamento durante o gameplay.

Para uma experiência de jogo FPS adequada, a HUD de inventário deve ser:
- Fechada por padrão (não bloqueia a visão nem o mouse durante gameplay).
- Acessível sob demanda via tecla, sem depender de interação com objetos da cena.

## Decisão

Implementar o toggle da HUD de inventário pela action `inventory_toggle`, mapeada à tecla `I` no InputMap do projeto.

### Componentes alterados

| Arquivo | Alteração |
|---|---|
| `project.godot` | Adicionada action `inventory_toggle` → tecla física `I` (physical_keycode 73) |
| `scripts/ui/hud/game_hud.gd` | Adicionados: `start_open` export, `open_inventory_ui()`, `close_inventory_ui()`, `toggle_inventory_ui()`, `is_inventory_ui_open()`, `_unhandled_input()` |
| `scenes/ui/hud/GameHUD.tscn` | Header atualizado com dica `[I] abrir/fechar`; botão Fechar adicionado |
| `scenes/test/TestInventoryWarehouse.tscn` | `start_open = false` explícito na instância `GameHUD` |
| `docs/testing/TEST_MATRIX_WAVE_2_11_HUD.md` | Casos HUD-15 a HUD-20 adicionados |

### Não alterados

- `scripts/inventory/*` — intactos
- `scripts/storage/warehouse.gd` — intacto
- `scripts/storage/warehouse_interactable.gd` — intacto
- `scripts/building/*` — intactos
- `scripts/resources/resource_pickup.gd` — intacto
- `scripts/player/player.gd` — intacto
- `scripts/debug/domain_event_logger.gd` — intacto
- `semantic_integrity`, logs JSON, ADR-0003 — intactos

## Justificativa técnica

### Por que InputMap e não tecla física?

Godot recomenda sempre abstrair teclas via `InputMap/actions` para:
1. Permitir remapeamento futuro sem tocar no código.
2. Evitar dependência rígida de hardware (layout de teclado).
3. Manter consistência com as demais actions do projeto (`move_forward`, `interact`, `jump` etc.).

### Por que `_unhandled_input` e não `_input`?

`_unhandled_input` respeita a cadeia de eventos: se o `SearchBox` (LineEdit) estiver focado e o usuário digitar `I`, o evento é consumido pelo controle de UI antes de chegar ao `_unhandled_input` do `GameHUD`. Isso evita fechar a HUD ao digitar no campo de busca.

### Por que controlar o mouse no GameHUD e não no Player?

O `player.gd` captura o mouse em `_ready()` e o libera com `ESC`. O `GameHUD` não altera essa lógica interna — apenas comuta entre `MOUSE_MODE_VISIBLE` (ao abrir) e `MOUSE_MODE_CAPTURED` (ao fechar). A lógica de recaptura via clique do Player permanece intacta.

### Por que `start_open = false`?

Em gameplay FPS, a HUD de inventário aberta por padrão bloqueia a visão e o cursor do mouse, impedindo o movimento da câmera. O padrão `false` garante que a HUD só apareça quando o jogador solicitar.

## Consequências

### Positivas

- HUD acessível diretamente durante gameplay sem depender de objetos da cena.
- Toggle via tecla e via botão visual utilizam o mesmo método (`close_inventory_ui()`).
- `refresh_all()` é chamado ao abrir, garantindo dados sempre atualizados.
- Foco no `SearchBox` ao abrir permite busca imediata.
- WASD e câmera não ficam presos após fechar (foco liberado + MOUSE_MODE_CAPTURED restaurado).
- Não altera domínio, consumo, inventário real, armazém real, construção ou logs JSON.

### Riscos mitigados

- Conflito com ESC: `_unhandled_input` no `GameHUD` não interfere com o `_unhandled_input` do Player para `ui_cancel`, pois as actions são distintas.
- Conflito com SearchBox: `_unhandled_input` não recebe o evento se o LineEdit já o consumiu.
- Double-close: `close_inventory_ui()` verifica `has_focus()` antes de `release_focus()`.

## Referências

- ADR-0003: Wave 2.11 — HUD Visual Simples
- `TEST_MATRIX_WAVE_2_11_HUD.md` — casos HUD-15 a HUD-20
- Godot 4 docs: [InputMap](https://docs.godotengine.org/en/stable/classes/class_inputmap.html)
- Godot 4 docs: [Control._unhandled_input](https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-private-method-unhandled-input)
