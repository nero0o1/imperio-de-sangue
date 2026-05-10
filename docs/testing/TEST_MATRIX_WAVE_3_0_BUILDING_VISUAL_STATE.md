# Test Matrix - Wave 3.0 Building Visual State

## Escopo

Validar que `BuildingVisualState` representa exclusivamente os estados de `BuildingSite_Test` sem alterar coleta, deposito, construcao, HUD ou politica de consumo.

## Checklist Manual

| Caso | Passos | Resultado esperado |
| --- | --- | --- |
| Estado inicial | Abrir `res://scenes/test/TestInventoryWarehouse.tscn`. Observar `BuildingSite_Test`. | Apenas `FoundationVisual` visivel. Label mostra `0%`. |
| Coletar sem depositar | Coletar `ResourcePickup_Wood`; nao depositar no armazem. | Visual permanece em fundacao. HUD continua mostrando estoque do jogador/armazem corretamente. |
| Depositar madeira | Depositar wood no `WarehouseInteractable_Test`. | Visual permanece em fundacao ate interagir com o `BuildingSite_Test`. |
| Primeira etapa | Interagir com `BuildingSite_Test` uma vez apos deposito suficiente. | Apenas `UnderConstructionVisual` visivel. Label mostra `50%`. |
| Segunda etapa | Repor/depositar recursos se necessario e interagir novamente. | Apenas `CompletedVisual` visivel. Label mostra `100%`. |
| Pos-conclusao | Interagir novamente com a construcao concluida. | Nenhum consumo adicional; visual continua concluido. |
| HUD toggle | Pressionar `I` para abrir/fechar HUD durante cada estado. | HUD alterna normalmente; visual 3D nao interfere no mouse/HUD. |
| Politica de consumo | Conferir logs/estado durante construcao. | `WAREHOUSE_ONLY` preservado; inventario do jogador nao e consumido na etapa de construcao. |
| Console | Rodar a cena e acompanhar saida. | Sem parse errors, referencias invalidas ou erros de script. |

## Arquivos Principais

- `res://scripts/building/building_visual_state.gd`
- `res://scenes/buildings/BuildingVisualState.tscn`
- `res://scenes/environment/CenarioGrande.tscn`
- `res://scenes/environment/CenarioParedes.tscn`
- `res://scenes/test/TestInventoryWarehouse.tscn`

## Fora de Escopo

- IA de NPC.
- Animacoes avancadas.
- Multiplas construcoes dinamicas.
- Mudancas em pickup, player, inventario, HUD ou custos de construcao.
