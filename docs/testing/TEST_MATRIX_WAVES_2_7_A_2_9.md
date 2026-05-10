# Test Matrix - Waves 2.7 a 2.9

## Testes unitarios

| Area | Teste | Resultado esperado | Evidencia esperada | Severidade se falhar |
|---|---|---|---|---|
| InventoryContainer | `add_item(wood, 10)` | Saldo wood = 10 | Assert/teste passa | Alta |
| InventoryContainer | `remove_item(wood, 4)` | Remove 4, saldo restante 6 | Assert/teste passa | Alta |
| InventoryContainer | remover mais que existe | Remove apenas disponivel, saldo 0 | Assert/teste passa | Alta |
| InventoryContainer | `transfer_to` | Origem reduz, destino aumenta | Assert/teste passa | Alta |
| Warehouse | `deposit(wood, 10)` | Warehouse wood = 10 | Assert/teste passa | Alta |
| Warehouse | `withdraw(wood, 4)` | Warehouse wood = 6 | Assert/teste passa | Alta |
| Warehouse | `pay({wood: 10})` | Consome custo exato | Assert/teste passa | Critica |
| BuildingResourceConsumer | `WAREHOUSE_ONLY` | Consome somente Warehouse | Assert/teste passa | Critica |
| BuildingResourceConsumer | `PLAYER_ONLY` | Consome somente Player | Assert/teste passa | Alta |
| BuildingResourceConsumer | `PLAYER_THEN_WAREHOUSE` | Consome Player primeiro | Assert/teste passa | Alta |
| BuildingResourceConsumer | `WAREHOUSE_THEN_PLAYER` | Consome Warehouse primeiro | Assert/teste passa | Alta |
| BuildingResourceConsumer | quantidade negativa | Retorna false e nao consome | Warning + assert/teste passa | Critica |
| DomainEventLogger | schema minimo | Evento valido sem erros | JSON + assert/teste passa | Alta |
| DomainEventLogger | reconciliacao | `before + delta = after` | Assert/teste passa | Critica |

## Testes integrados

| Fluxo | Passos | Resultado esperado | Evidencia esperada | Severidade se falhar |
|---|---|---|---|---|
| ResourcePickup -> PlayerInventory | Interagir com wood | PlayerInventory wood = 10 | `resource_pickup.collect.success` | Critica |
| PlayerInventory -> Warehouse | Depositar wood | Player wood = 0, Warehouse wood = 10 | `warehouse.deposit.success` | Critica |
| Warehouse -> BuildingSite | Construir com Warehouse wood = 10 | Warehouse wood = 0, progresso +50 | `building_site.consume.success` | Critica |
| Stone bloqueado | Coletar stone e tentar construir | Progresso nao muda | `blocked_no_stock` | Alta |
| Conclusao | Construir duas etapas | Progresso 100, concluida true | Log de sucesso com completed true | Critica |
| Pos-conclusao | Interagir apos 100% | Nao consome | `blocked_completed` | Critica |

## Testes manuais

| Teste | Resultado esperado | Evidencia esperada no Output | Severidade se falhar |
|---|---|---|---|
| Abrir projeto | Sem parse error vermelho | Banner do projeto/editor sem erro critico | Critica |
| Abrir cena-laboratorio | Cena carrega | Nos visiveis no Scene Tree | Critica |
| WASD | Player se move | Observacao visual | Alta |
| Mouse | Camera gira | Observacao visual | Alta |
| E sem alvo | Sem erro | Pode haver log de sem alvo, mas sem exception | Media |
| Space | Player pula | Observacao visual e log `jump() chamado...` se ativo | Alta |
| Shift no chao | Sprint funciona | Observacao visual | Media |
| Shift no ar | Nao acelera como sprint | Observacao visual | Media |
| Clique esquerdo | Ataque stub | Log de stub | Baixa |
| Esc | Libera mouse | Cursor visivel | Media |

## Testes comportamentais

| Cenario | Resultado esperado | Evidencia esperada | Severidade se falhar |
|---|---|---|---|
| Tentar construir sem Warehouse wood | Falha sem mutacao | `building_site.consume.blocked_no_stock` | Critica |
| Coletar wood e construir sem depositar | Falha em `WAREHOUSE_ONLY` | Player ainda tem wood, Warehouse 0 | Critica |
| Depositar e construir | Sucesso | Warehouse reduz 10, progresso 50 | Critica |
| Repetir ciclo | Sucesso | Progresso 100, completed true | Critica |
| Interagir apos concluida | Bloqueado | Warehouse nao muda | Critica |
| Spammar E | Nao deve gerar dupla mutacao indevida | Estados consistentes | Alta |

## Testes de borda

| Borda | Resultado esperado | Evidencia esperada | Severidade se falhar |
|---|---|---|---|
| `quantity <= 0` em pickup | Bloqueia coleta | Warning/evento bloqueado | Alta |
| `item_id` vazio | Bloqueia coleta/deposito | Warning/evento bloqueado | Alta |
| Warehouse path invalido | Bloqueia sem mutacao | `blocked_invalid_reference` | Critica |
| Player sem inventario | Bloqueia pickup/deposito | Warning/evento bloqueado | Alta |
| Custo negativo | Consumo retorna false | Warning sem mutacao | Critica |
| Falta parcial de wood | Falha sem consumo parcial | Estado inalterado | Critica |

## Testes de regressao

| Regressao protegida | Como testar | Resultado esperado | Severidade |
|---|---|---|---|
| Player conhece classes especificas | Revisar `player.gd` | Player usa interacao generica | Alta |
| RayCast especializado | Revisar `interaction_raycast.gd` | Chama apenas `interact(actor)` | Alta |
| BuildSite consome Player em WAREHOUSE_ONLY | Coletar wood sem depositar e construir | Falha, Player mantem wood | Critica |
| Completed consome novamente | Interagir apos 100% | Nao consome | Critica |
| Logs silenciosos | Executar fluxo completo | Eventos JSON no Output | Alta |
| Movimento alterado por sistemas de estoque | Testar WASD/pulo/sprint | Movimento preservado | Alta |

## Campos JSON esperados

Campos obrigatorios:

- `timestamp`
- `severity_text`
- `body`
- `attributes.event_name`
- `attributes.operation_id`
- `attributes.idempotency_key`
- `attributes.entity.type`
- `attributes.entity.id`
- `attributes.policy`
- `attributes.result`
- `attributes.state.before`
- `attributes.state.after`
- `attributes.delta`
- `attributes.semantic_integrity`
- `attributes.failure_reason`

Campos esperados nos eventos de fluxo:

- `actor`
- `operation`
- `resource_id`
- `amount`
- `source`
- `target`
- `success`
- `reason_if_failed`
- `invariant_result`

## Resultado esperado final

O baseline passa quando:

- Testes unitarios e integrados passam.
- Cena-laboratorio executa.
- Fluxo manual conclui construcao em 100%.
- Nao ha saldo negativo.
- Falhas bloqueadas nao alteram estado.
- Eventos JSON sao emitidos e reconciliaveis.
