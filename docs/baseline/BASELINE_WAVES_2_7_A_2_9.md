# Baseline Waves 2.7 a 2.9

## Status

Accepted

## Data

2026-05-03

## Escopo coberto

Este baseline consolida o estado validado das Waves 2.7 a 2.9 do prototipo Godot 4.x "Imperio de Sangue".

O foco coberto e:

- Player FPS basico com movimento, camera, sprint, pulo, ataque stub e interacao.
- RayCast de interacao generica via `interact(actor)`.
- Inventario do jogador com itens `wood` e `stone`.
- Coleta de recursos no mapa.
- Deposito de `PlayerInventory` para `Warehouse`.
- Construção de laboratorio via `BuildingSite`.
- Politica de consumo da cena-laboratorio: `WAREHOUSE_ONLY`.
- Logs estruturados JSON com estado antes/depois/delta.
- Probes e testes de integridade semantica.

## Escopo fora

Este baseline nao cobre:

- HUD visual final.
- NPC trabalhador.
- NPC coletor.
- NPC defensor.
- Economia avancada.
- Crafting.
- Save/load.
- Multiplayer.
- Combate real.
- Dano em inimigos.
- Multiplos armazens em gameplay validado.
- Balanceamento final.
- Arte final.

## Resumo executivo

O projeto possui um fluxo jogavel minimo e validavel: o jogador coleta recursos, armazena no inventario, deposita madeira no armazem e usa o armazem para pagar etapas de construcao. A cena-laboratorio principal e `res://scenes/test/TestInventoryWarehouse.tscn`.

O baseline aceito exige que a construcao consuma somente do armazem na cena de teste. O custo por etapa e `wood = 10`, o progresso avanca de `0` para `50` e depois para `100`, e `is_completed = true` bloqueia novo consumo.

Os logs estruturados JSON devem permitir auditar `state.before`, `state.after`, `delta`, `semantic_integrity` e `invariant_result`. A documentacao desta Wave existe para permitir reconstruir, validar e continuar o projeto sem depender da memoria da conversa.

## Estado atual do projeto

- Projeto Godot alvo: 4.6.2.
- Cena principal configurada no projeto: `res://scenes/main/Main.tscn`.
- Cena-laboratorio principal: `res://scenes/test/TestInventoryWarehouse.tscn`.
- Cena-laboratorio tem Player instanciado com `PlayerInventory`.
- Recursos de teste:
  - `ResourcePickup_Wood`, `item_id = wood`, `quantity = 10`.
  - `ResourcePickup_Wood_2`, `item_id = wood`, `quantity = 10`.
  - `ResourcePickup_Stone`, `item_id = stone`, `quantity = 5`.
- Armazem:
  - `Warehouse_Test`, `warehouse_id = warehouse_test`, `settlement_id = settlement_test`.
  - `WarehouseInteractable_Test`, `accepted_item_id = wood`, `deposit_amount = 10`.
- Construcao:
  - `BuildingSite_Test`, `building_id = test_building`.
  - `required_costs = { &"wood": 10 }`.
  - `build_progress_per_payment = 50.0`.
  - `consume_policy = 1`, equivalente a `WAREHOUSE_ONLY`.
- Debug:
  - `InventoryDebugHUD` aponta para PlayerInventory, Warehouse_Test e BuildingSite_Test.

## Sistemas implementados

### Player

`res://scripts/player/player.gd`

- `CharacterBody3D`.
- WASD para movimento.
- Mouse para olhar.
- `sprint` apenas no chao.
- `jump` com `jump_velocity`.
- Ataque stub.
- `get_inventory()` para expor `PlayerInventory`.

### Interacao

`res://scripts/player/interaction_raycast.gd`

- Usa RayCast3D.
- Chama genericamente `interact(actor)`.
- Nao conhece classes especificas de recurso, armazem ou construcao.

### Inventario

Arquivos:

- `res://scripts/inventory/inventory_container.gd`
- `res://scripts/inventory/player_inventory.gd`
- `res://scripts/inventory/npc_inventory.gd`
- `res://scripts/inventory/item_definition.gd`
- `res://scripts/inventory/item_stack.gd`

Contrato atual:

- `add_item(item_id, quantity) -> int`
- `remove_item(item_id, quantity) -> int`
- `has_items(costs) -> bool`
- `remove_items(costs) -> bool`
- `get_quantity(item_id) -> int`
- `get_all_items() -> Dictionary`

### Recursos

`res://scripts/resources/resource_pickup.gd`

- Implementa `interact(actor)`.
- Adiciona recurso ao inventario do ator.
- Emite log estruturado.
- Pode remover/ocultar o objeto apos coleta.

### Armazem

Arquivos:

- `res://scripts/storage/warehouse.gd`
- `res://scripts/storage/warehouse_interactable.gd`
- `res://scripts/storage/storage_manager.gd`

Contrato atual:

- `Warehouse.deposit(item_id, quantity) -> int`
- `Warehouse.withdraw(item_id, quantity) -> int`
- `Warehouse.get_available(item_id) -> int`
- `Warehouse.can_pay(costs) -> bool`
- `Warehouse.pay(costs) -> bool`
- `Warehouse.ensure_inventory() -> InventoryContainer`

### Construcao

Arquivos:

- `res://scripts/building/build_cost.gd`
- `res://scripts/building/building_resource_consumer.gd`
- `res://scripts/building/building_site.gd`

Contrato atual:

- `BuildingSite.interact(actor) -> void`
- `BuildingSite.can_build_step(actor = null) -> bool`
- `BuildingSite.build_step(actor) -> bool`
- `BuildingResourceConsumer.consume(...) -> bool`

### Observabilidade

Arquivos:

- `res://scripts/debug/domain_event_logger.gd`
- `res://scripts/tests/semantic_integrity_probe.gd`

Campos esperados:

- `timestamp`
- `severity_text`
- `body`
- `attributes.event_name`
- `attributes.operation_id`
- `attributes.idempotency_key`
- `attributes.state.before`
- `attributes.state.after`
- `attributes.delta`
- `attributes.semantic_integrity`
- `attributes.invariant_result`

## Mapa de arquivos criticos

Ver manifest completo em:

`res://docs/baseline/FILE_MANIFEST_WAVES_2_7_A_2_9.json`

## Cena-laboratorio

Cena principal de validacao:

`res://scenes/test/TestInventoryWarehouse.tscn`

Nos esperados:

- `Player`
- `Player/PlayerInventory`
- `ResourcePickup_Wood`
- `ResourcePickup_Wood_2`
- `ResourcePickup_Stone`
- `Warehouse_Test`
- `WarehouseInteractable_Test`
- `BuildingSite_Test`
- `CanvasLayer/InventoryDebugHUD`

## Controles disponiveis

- `W`: mover para frente.
- `S`: mover para tras.
- `A`: mover para esquerda.
- `D`: mover para direita.
- Mouse: olhar.
- `E`: interagir.
- `Space`: pular.
- `Shift`: sprint apenas no chao.
- Botao esquerdo do mouse: ataque stub.
- `Esc`: liberar mouse.
- Clique na janela: recapturar mouse sem atacar no mesmo clique.

## Fluxo validado

1. Abrir `res://scenes/test/TestInventoryWarehouse.tscn`.
2. Interagir com `ResourcePickup_Wood`.
3. `PlayerInventory` recebe `wood = 10`.
4. Interagir com `WarehouseInteractable_Test`.
5. `PlayerInventory` perde `wood = 10`.
6. `Warehouse_Test` recebe `wood = 10`.
7. Interagir com `BuildingSite_Test`.
8. `Warehouse_Test` consome `wood = 10`.
9. `BuildingSite_Test` avanca para `50%`.
10. Repetir coleta, deposito e construcao.
11. `BuildingSite_Test` avanca para `100%`.
12. `is_completed = true`.
13. Interacoes posteriores na construcao nao consomem recurso.

## Invariantes semanticos

- Nenhum item pode ficar negativo.
- Nenhum item deve ser criado do nada em transferencias.
- Deposito `PlayerInventory -> Warehouse` deve conservar quantidade total.
- Consumo `Warehouse -> BuildingSite` deve reduzir o armazem exatamente pelo custo aceito.
- Em `WAREHOUSE_ONLY`, `BuildingSite` nao deve consumir diretamente do `PlayerInventory`.
- Falha por saldo insuficiente nao altera inventario, armazem ou progresso.
- Construcao concluida nao consome novamente.
- `build_step(actor)` retorna `true` apenas quando uma etapa foi paga e aplicada.
- `state.before + delta` deve reconciliar exatamente com `state.after`.

## Eventos JSON esperados

Eventos esperados no Output:

- `resource_pickup.collect.success`
- `warehouse.deposit.success`
- `warehouse.deposit.blocked_no_item`
- `building_site.consume.success`
- `building_site.consume.blocked_no_stock`
- `building_site.consume.blocked_completed`
- `building_site.consume.blocked_invalid_reference`

Todo evento estruturado deve conter:

- `state.before`
- `state.after`
- `delta`
- `semantic_integrity`
- `invariant_result`, quando aplicavel.

## Bugs corrigidos

- Parse error em `building_resource_consumer.gd` causado por passagem de `Warehouse` onde era esperado `InventoryContainer`.
- Acesso direto fraco a `_ensure_inventory()` substituido por `ensure_inventory()` em correcoes posteriores.
- `can_build_step(actor)` passou a considerar criterios coerentes com `build_step(actor)`.
- Falhas de construcao sem recursos agora devem gerar log explicito.
- Pulo do Player usa `jump_velocity` e so executa no chao.
- Controle aereo ajustado para evitar aceleracao/sprint indevido no ar.
- Pulo duplo bloqueado.

## Limitacoes atuais

- HUD atual e debug simples, nao UI final.
- NPCs ainda nao executam coleta, deposito ou construcao.
- `StorageManager` existe, mas o laboratorio valida um armazem especifico.
- Sem save/load.
- Sem economia avancada.
- Sem multiplos Build Sites validados em gameplay.
- Sem arte final.
- Validacao manual ainda e necessaria no editor para confirmar percepcao visual e input real.

## Criterios para considerar o baseline integro

- Projeto abre sem parse error vermelho.
- `TestInventoryWarehouse.tscn` abre.
- Player aparece.
- WASD, mouse, Space, Shift, E, Esc e clique esquerdo mantem comportamento esperado.
- Coleta de wood adiciona ao `PlayerInventory`.
- Deposito remove do `PlayerInventory` e adiciona ao `Warehouse`.
- Construcao consome somente do `Warehouse`.
- Progresso avanca `0 -> 50 -> 100`.
- Construcao concluida nao consome novamente.
- Logs JSON aparecem com before/after/delta.
- Teste `inventory_system_test.gd` passa.
- Arquivos criticos preservam contratos listados neste baseline.

## Proximas Waves recomendadas

1. Wave 2.11 - HUD Visual Simples.
2. Wave 2.12 - Construcao Visual por Estado.
3. Wave 2.13 - Multiplos Build Sites.
4. Wave 2.14 - Primeiro NPC Trabalhador.
