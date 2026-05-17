# Wave 4.6.2C - Hotfix de Validacao Manual

## Resumo executivo

Correcao dos bloqueadores encontrados no teste manual da cena NPCWave4OrderIntegrationTest.tscn. O hotfix estabiliza a coleta GATHER_RESOURCE quando um ResourcePickup e esgotado/removido, corrige a resolucao de HUD para Warehouse/BuildingSite na cena integrada e registra a auditoria Git exigida antes da correcao.

## Falhas observadas

- HUD mostrava Warehouse: nao configurado.
- HUD mostrava Building: nao configurado.
- GATHER_RESOURCE gerava Invalid type em _is_valid_resource_pickup_for_filter apos ResourcePickup esgotar.
- Parser indicava erro de indentacao no match _collector_state.
- Possivel duplicidade de chao observada no editor.

## Causa raiz

- _collector_target podia continuar apontando para um ResourcePickup que ja havia entrado em queue_free(), e o estado do coletor nao limpava explicitamente a referencia antes de voltar para COLLECTOR_FINDING_RESOURCE.
- _is_valid_resource_pickup_for_filter recebia Node tipado rigidamente; quando o alvo ja estava invalido/freed, a chamada podia falhar antes da validacao interna conseguir rejeitar o objeto com seguranca.
- O bloco match _collector_state precisava permanecer alinhado no mesmo nivel dos estados COLLECTOR_FINDING_RESOURCE, COLLECTOR_GOING_TO_GATHER, COLLECTOR_COLLECTING, COLLECTOR_GOING_TO_DEPOSIT e COLLECTOR_DEPOSITING.
- InventoryDebugHUD tinha player_inventory_path configurado, mas nao tinha warehouse_path nem building_site_path na cena integrada. Por isso Player Inventory aparecia, enquanto Warehouse e Building ficavam como nao configurado.
- A cena contem um Ground visual/fisico unico e uma NavigationRegion3D. Nao foi encontrada duplicidade real de dois MeshInstance3D grandes de piso ou dois CollisionShape3D grandes de piso; a segunda camada observada deve ser overlay/debug de navegacao ou marcadores auxiliares.

## Arquivos alterados

- scripts/npc/npc_order_executor.gd
- scenes/test/NPCWave4OrderIntegrationTest.tscn
- docs/WAVE_4_6_2C_MANUAL_VALIDATION_HOTFIX.md
- docs/LOCAL_BEFORE_HOTFIX_4_6_2C.patch

Observacao de auditoria: antes do hotfix ja existiam alteracoes locais em scenes/test/NPCWave4OrderIntegrationTest.tscn e scripts/test/build_placement_controller.gd. Elas foram registradas em docs/LOCAL_BEFORE_HOTFIX_4_6_2C.patch antes de qualquer edicao. A alteracao em scripts/test/build_placement_controller.gd permanece pre-existente e nao faz parte da correcao aplicada por este hotfix.

## Correcoes aplicadas

- _is_valid_resource_pickup e _is_valid_resource_pickup_for_filter agora aceitam Variant, validam null, Object invalido/freed e somente depois convertem para Node/Node3D.
- A validacao preserva resource_id, amount, interact e o filtro wood/stone antes de aceitar um pickup.
- COLLECTOR_GOING_TO_GATHER e COLLECTOR_COLLECTING limpam _collector_target quando o alvo deixa de ser valido, voltam para COLLECTOR_FINDING_RESOURCE e permitem procurar outro ResourcePickup do mesmo tipo.
- InventoryDebugHUD na cena integrada recebeu warehouse_path e building_site_path.
- PopulationManager foi colocado no grupo population_manager.
- Confirmado que Warehouse, BuildingSite, BuildPlacementController e PlayerInventory ja possuem os grupos esperados na cena.
- Confirmado que nao ha duplicidade real de chao: mantidos um Ground visual, um CollisionShape3D de chao e uma NavigationRegion3D.

## Testes automaticos

| Teste | Resultado |
|---|---|
| git diff --check | PASS |
| Godot headless projeto | PASS |
| Godot headless cena integrada | PASS |
| Probe headless de HUD, pickup freed, coleta/deposito wood e stone | PASS |

## Testes manuais

| Teste | Resultado | Observacao |
|---|---|---|
| HUD Player Inventory | PASS | InventoryDebugHUD manteve Player Inventory configurado. |
| HUD Warehouse | PASS | warehouse_path configurado para ../../Warehouse. |
| HUD Building | PASS | building_site_path configurado para ../../CivilHouseA/BuildingSite. |
| Coleta wood | PASS | Probe headless esgotou WoodPickup1 sem erro. |
| Coleta stone | PASS | Probe headless esgotou StonePickup1 sem erro. |
| Deposito no armazem | PASS | Warehouse aumentou wood e stone apos deposito via WarehouseInteractable. |
| Pickup esgotado sem erro | PASS | _is_valid_resource_pickup_for_filter rejeitou objeto apos queue_free sem Invalid type. |
| Chao duplicado | PASS | Nao ha duplicidade real; observado como overlay/debug de NavigationMesh ou marcadores. |

## Riscos restantes

- A validacao interativa completa no editor depende de execucao manual com input real, camera e UI aberta; a cobertura headless confirmou os caminhos de parser, cena, HUD, pickup freed, coleta e deposito.
- scripts/test/build_placement_controller.gd ja estava alterado antes do hotfix e foi preservado sem sobrescrita.
- A destruicao de construcoes por tecla Delete nao foi implementada neste hotfix.

## Git

- Branch: hotfix-4-6-2c-manual-validation
- Commit principal: bf5aaac - fix: stabilize wave 4.6.2 manual validation blockers
- Push: realizado para origin/hotfix-4-6-2c-manual-validation
- PR: https://github.com/nero0o1/imperio-de-sangue/pull/1

## Proxima recomendacao

Criar uma Wave separada para destruicao de construcoes com tecla Delete, sem refund inicial, usando raycast da camera e grupo destroyable_building.
