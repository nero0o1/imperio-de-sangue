# Checklist de Validacao Manual - Waves 2.7 a 2.9

## Checklist para abrir o projeto

- [ ] Abrir Godot 4.6.x.
- [ ] Importar/abrir a pasta do projeto.
- [ ] Confirmar que `project.godot` carrega.
- [ ] Confirmar ausencia de erro vermelho de parse no Output.
- [ ] Confirmar que a cena principal do projeto ainda e `res://scenes/main/Main.tscn`.

## Checklist para executar TestInventoryWarehouse.tscn

- [ ] Abrir `res://scenes/test/TestInventoryWarehouse.tscn`.
- [ ] Confirmar que a cena carrega sem dependencias ausentes.
- [ ] Confirmar que existem `ResourcePickup_Wood`, `ResourcePickup_Wood_2` e `ResourcePickup_Stone`.
- [ ] Confirmar que existe `Warehouse_Test`.
- [ ] Confirmar que existe `WarehouseInteractable_Test`.
- [ ] Confirmar que existe `BuildingSite_Test`.
- [ ] Confirmar que existe `InventoryDebugHUD`.
- [ ] Executar a cena.
- [ ] Confirmar que o Player aparece.

## Checklist de player

- [ ] `W` move para frente.
- [ ] `A` move para esquerda.
- [ ] `S` move para tras.
- [ ] `D` move para direita.
- [ ] Mouse controla camera.
- [ ] `E` chama interacao no alvo.
- [ ] `E` sem alvo nao gera erro vermelho.
- [ ] `Space` faz o Player pular.
- [ ] `Space` no ar nao causa pulo duplo.
- [ ] `Shift` aumenta velocidade apenas no chao.
- [ ] `Shift` no ar nao aumenta velocidade horizontal.
- [ ] Botao esquerdo chama ataque stub.
- [ ] `Esc` libera o mouse.
- [ ] Clique na janela recaptura o mouse sem atacar no mesmo clique.

## Checklist de inventario

- [ ] Interagir com `ResourcePickup_Wood`.
- [ ] Confirmar no HUD/debug: `PlayerInventory` recebeu `wood = 10`.
- [ ] Confirmar no Output evento `resource_pickup.collect.success`.
- [ ] Interagir com `ResourcePickup_Stone`.
- [ ] Confirmar no HUD/debug: `PlayerInventory` recebeu `stone = 5`.
- [ ] Confirmar que stone nao paga construcao que exige wood.
- [ ] Confirmar que nenhum item fica negativo.

## Checklist de armazem

- [ ] Com `wood = 10` no PlayerInventory, interagir com `WarehouseInteractable_Test`.
- [ ] Confirmar que `PlayerInventory wood` fica `0`.
- [ ] Confirmar que `Warehouse wood` fica `10`.
- [ ] Confirmar evento `warehouse.deposit.success`.
- [ ] Tentar depositar sem wood.
- [ ] Confirmar evento `warehouse.deposit.blocked_no_item`.
- [ ] Confirmar que nenhum saldo muda na tentativa sem wood.

## Checklist de construcao

- [ ] Com Warehouse vazio, interagir com `BuildingSite_Test`.
- [ ] Confirmar evento `building_site.consume.blocked_no_stock`.
- [ ] Confirmar que progresso continua `0`.
- [ ] Depositar `wood = 10` no Warehouse.
- [ ] Interagir com `BuildingSite_Test`.
- [ ] Confirmar que Warehouse passa de `10` para `0`.
- [ ] Confirmar progresso `50%`.
- [ ] Repetir coleta e deposito.
- [ ] Interagir novamente com `BuildingSite_Test`.
- [ ] Confirmar progresso `100%`.
- [ ] Confirmar `is_completed = true`.
- [ ] Interagir apos concluida.
- [ ] Confirmar evento `building_site.consume.blocked_completed`.
- [ ] Confirmar que Warehouse nao perde recurso apos conclusao.

## Checklist de logs JSON

- [ ] Verificar se cada evento impresso e JSON valido.
- [ ] Confirmar campo `timestamp`.
- [ ] Confirmar campo `severity_text`.
- [ ] Confirmar `body = named_domain_event`.
- [ ] Confirmar `attributes.event_name`.
- [ ] Confirmar `attributes.operation_id`.
- [ ] Confirmar `attributes.idempotency_key`.
- [ ] Confirmar `attributes.state.before`.
- [ ] Confirmar `attributes.state.after`.
- [ ] Confirmar `attributes.delta`.
- [ ] Confirmar `attributes.semantic_integrity`.
- [ ] Confirmar `attributes.invariant_result` nos eventos instrumentados de fluxo.

## Checklist de movimento aereo

- [ ] Pular parado e confirmar que o salto ocorre uma vez.
- [ ] Pressionar Space repetidamente no ar e confirmar que nao ha pulo duplo.
- [ ] Pular segurando Shift e confirmar que sprint nao acelera no ar.
- [ ] Mudar direcao no ar e confirmar que o controle aereo e limitado.
- [ ] Aterrissar e confirmar que movimento normal e sprint voltam a funcionar.

## Checklist de regressao

- [ ] `interaction_raycast.gd` continua chamando apenas `interact(actor)`.
- [ ] Player nao conhece `WoodNode`, `ResourcePickup`, `Warehouse` ou `BuildingSite` diretamente.
- [ ] `BuildingSite_Test` continua `WAREHOUSE_ONLY`.
- [ ] Custo continua `wood = 10`.
- [ ] Progresso por pagamento continua `50.0`.
- [ ] Cena nao exige assets externos.
- [ ] Nenhum sistema de NPC foi introduzido.
- [ ] Nenhum sistema de crafting foi introduzido.
- [ ] Nenhum sistema de economia avancada foi introduzido.

## Se acontecer X, entao e erro

| Situacao | Entao e erro se |
|---|---|
| Apertar `E` sem alvo | Aparecer erro vermelho ou exception |
| Coletar wood | `PlayerInventory` nao receber `wood = 10` |
| Depositar wood | Warehouse nao receber exatamente a quantidade retirada do Player |
| Depositar sem wood | Algum saldo mudar |
| Construir sem wood no Warehouse | Progresso aumentar |
| Construir com wood no Player, mas sem wood no Warehouse | Construir em politica `WAREHOUSE_ONLY` |
| Construir com wood no Warehouse | Warehouse nao perder exatamente `10 wood` |
| Construcao concluida | Interacao posterior consumir recurso |
| Evento JSON | Faltar `state.before`, `state.after` ou `delta` |
| Pular no ar | Player executar pulo duplo |
| Sprint no ar | Player acelerar como se estivesse no chao |

## Resultado esperado final

Ao fim da validacao manual:

- `BuildingSite_Test` deve estar em `100%`.
- `is_completed` deve estar `true`.
- Interacoes posteriores com `BuildingSite_Test` nao devem consumir recursos.
- Nenhum saldo deve estar negativo.
- Logs JSON devem evidenciar sucesso, bloqueio por falta de recurso e bloqueio por construcao concluida.
