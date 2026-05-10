# Wave 3.1 - Implementation Report

## Arquivos modificados

- `scripts/inventory/inventory_container.gd`
- `scripts/resources/resource_pickup.gd`
- `scripts/storage/warehouse.gd`
- `scripts/storage/warehouse_interactable.gd`
- `scripts/building/building_site.gd`
- `scripts/debug/inventory_debug_hud.gd`
- `scripts/ui/hud/player_inventory_panel.gd`
- `scripts/ui/hud/warehouse_panel.gd`
- `scripts/ui/hud/building_status_panel.gd`
- `scripts/tests/inventory_system_test.gd`
- `scenes/test/TestInventoryWarehouse.tscn`

## Arquivos criados

- `docs/adr/ADR-0007-wave-3-1-armazem-multirrecurso.md`
- `docs/waves/WAVE_3_1_IMPLEMENTATION_REPORT.md`
- `docs/tests/WAVE_3_1_TEST_PLAN.md`

## Comportamento antes

- O armazem aceitava um `accepted_item_id` fixo, configurado como `wood`.
- O deposito era limitado por `deposit_amount` e nao transferia todos os recursos carregados.
- BuildingSite usava um custo simples, focado em `wood`.
- O HUD/debug mostrava dados em formato compacto e nao destacava o estoque multirrecurso.
- A cena de teste tinha madeira e pedra, mas os valores nao fechavam a receita multirrecurso da Wave 3.1.

## Comportamento depois

- O inventario expoe API multirrecurso (`add_resource`, `remove_resource`, `get_resource`, `has_resource`, `get_all_resources`, `is_empty`).
- ResourcePickup usa `resource_id` e `amount`.
- Warehouse mantem `stock: Dictionary` e oferece consumo atomico por receita.
- WarehouseInteractable transfere todos os recursos carregados pelo ator para o armazem.
- BuildingSite usa `required_resources` e `step_count`.
- Cada interacao com BuildingSite tenta pagar uma etapa pelo armazem.
- BuildingSite preserva a politica WAREHOUSE_ONLY.
- HUD/debug mostra inventario, estoque do armazem, progresso e conclusao.
- A cena de teste contem `WoodPickup` (`wood` x30, `10` por interacao), `StonePickup` (`stone` x10) e BuildingSite com receita `wood` x20 + `stone` x10 em 2 etapas.

## Validacoes realizadas

- Inspecao da arvore do projeto e dos scripts reais antes da edicao.
- Localizacao de pontos com `wood` fixo no armazem e na cena.
- Atualizacao da bateria GDScript existente para cobrir consumo atomico com falta parcial de `stone`.

## Validacoes nao realizadas

- Validacao visual/manual no editor Godot.
- Validacao via Godot CLI, caso o executavel nao esteja disponivel no ambiente local.

## Limitacoes

- A UI continua sendo HUD/debug e paineis simples, sem inventario visual completo.
- `BuildingResourceConsumer` preserva politicas antigas para compatibilidade de testes e sistemas legados, mas `BuildingSite` agora aplica WAREHOUSE_ONLY diretamente.
- Receitas nao divisiveis por `step_count` geram warning; esta Wave usa valores divisiveis.

## Pendencias

- Validar manualmente o loop completo no editor.
- Decidir em Wave futura se politicas antigas de `BuildingResourceConsumer` devem virar apenas ferramenta de teste ou ser removidas.
- Evoluir apresentacao visual e feedback de interacao sem quebrar o contrato logica/visual.

## Wave 3.1.1 - Limpeza tecnica e coleta progressiva

- Corrigido warning de shadowing de `amount` em `ResourcePickup`, renomeando o parametro local de evento para `collected_amount`.
- Corrigido warning de divisao inteira em `BuildingSite`, calculando o custo por etapa com `float(step_count)` depois de validar `step_count > 0`.
- `WoodPickup` agora possui estoque total `30`.
- `WoodPickup` entrega `10` por interacao e registra o restante em log.
- `StonePickup` foi preservado como coleta simples de `stone` x10.
- A construcao continua exigindo `wood` x20 + `stone` x10 em `step_count = 2`.
- Depois da construcao completa, a sobra esperada no Warehouse e `wood: 10`.

## Wave 3.1.2 — ResourcePickup esgotado sai do mapa

- WoodPickup continua progressivo: 30 total, 10 por interação.
- Ao chegar a 0, WoodPickup é removido da cena.
- StonePickup mantém comportamento de remoção ao esgotar.
- A antiga quarta interação de debug foi removida do teste.
- Motivo: recurso esgotado não deve continuar parecendo coletável em protótipo jogável.

## Wave 3.1.3 - Telemetria economica e trilha de integridade

- Corrigido o delta vazio em `warehouse.deposit.success`.
- A causa era o calculo anterior de delta exigir valores numericos em `before` e `after`; quando um recurso saia do player ou surgia no Warehouse, o lado ausente era tratado como `null` e o delta era omitido.
- Eventos economicos agora devem preservar `state.before`, `state.after` e `delta`, incluindo deltas negativos para remocoes e positivos para adicoes.
- `DomainEventLogger` passou a expor `calculate_economic_delta(before, after)`, tratando chaves ausentes como zero e omitindo apenas deltas iguais a zero.
- Deposito valida conservacao economica basica: para cada recurso, `delta.player + delta.warehouse == 0`.
- Falha de conservacao nao bloqueia gameplay nesta Wave; o evento e marcado com `invariant_result = "fail"`, `failure_reason = "economic_conservation_failed"` e severidade `WARN`.
- Eventos emitidos pelo logger recebem `sequence_number`, `previous_integrity_hash` e `integrity_hash` como marcadores leves de integridade.
- Esta camada nao e anti-cheat completo. O objetivo e rastreabilidade, diagnostico e base futura.
- Protecao real contra manipulacao exigiria autoridade fora do cliente, como servidor autoritativo.
- No prototipo local, a meta e dificultar manipulacao casual e detectar inconsistencias.

## Wave 3.1.5 — Auditoria profunda de robustez e hardening

### Escopo

Auditoria de todos os scripts do protótipo (inventário, pickup, armazém, construção, visual, HUD, logger, testes). Correção de riscos localizados. Nenhuma feature de gameplay alterada.

### Achados classificados

#### RISCO_PROVÁVEL (corrigidos)

| # | Arquivo | Problema | Correção |
|---|---|---|---|
| R1 | `domain_event_logger.gd` | `canonicalize()` sem limite de profundidade — risco de stack overflow em payloads profundamente aninhados | Adicionada constante `_MAX_CANONICALIZE_DEPTH = 16`; `canonicalize()` recebe parâmetro interno `_depth`; ao exceder retorna `"[MAX_DEPTH]"` e emite `push_warning` |
| R2 | `building_visual_state.gd` | `_process()` acessa `building_site.build_progress` sem `is_instance_valid()` — se BuildingSite for liberado (queue_free), o acesso ao objeto invalidado pode crashar | Adicionado `is_instance_valid(building_site)` antes de acessar propriedades; referência é zerada se inválida |
| R3 | `warehouse.gd` | `_on_inventory_changed()` emitia `warehouse_changed` mesmo durante `_sync_inventory_from_stock()` (flag `_syncing_inventory = true`) — HUD observava estado instável N+1 vezes por operação | `_on_inventory_changed()` retorna cedo com `if _syncing_inventory: return`; emissão única e estável ao final de cada operação |

#### DÍVIDA_TÉCNICA (não corrigidas nesta Wave — registradas)

| # | Arquivo | Descrição |
|---|---|---|
| D1 | `warehouse.gd` | `has_resources({})` retorna `true` (custo vazio não é rejeitado). Seguro pois `build_step` verifica `step_cost.is_empty()` upstream. |
| D2 | `building_site.gd` | `get_step_cost()` trunca quantidade não divisível por `step_count` com `int(...)`. Warning emitido mas custo incorreto retornado para receitas indivisíveis. Atual receita usa valores divisíveis. |
| D3 | `warehouse_interactable.gd` | Depósito multi-recurso não é atomicamente reversível — remoção de wood e stone são operações separadas. `add_resource` nunca falha, então perda é impossível na prática. |
| D4 | `building_status_panel.gd` | `refresh()` chama `get_step_cost()` que pode emitir `push_warning` em receitas inválidas — ruído nos logs durante tick de HUD. |
| D5 | `canonicalize()` | Sem proteção contra referências circulares. GDScript não permite detectar ciclos facilmente; `_MAX_CANONICALIZE_DEPTH` mitiga o risco. Ciclo real em payload de evento seria erro de programação upstream. |

#### FALSO_POSITIVO (auditados, sem ação necessária)

- `InventoryContainer.add_item/remove_item`: não produz estado negativo; chaves zeradas são removidas.
- `InventoryContainer.get_all_resources()`: retorna snapshot, não referência mutável.
- `ResourcePickup.interact()`: guarda atomicidade — amount só é decrementado após `accepted > 0`.
- `ResourcePickup`: não perde recurso se inventário não aceitar (`accepted <= 0` aborta antes de decrementar).
- `Warehouse.consume_resources()`: `has_resources()` verificado antes de qualquer mutação — atômico no contexto single-thread.
- `Warehouse.get_stock_snapshot()`: retorna cópia.
- `BuildingSite.build_step()`: `before` capturado antes de qualquer mutação; `blocked_completed` emite `before == after`, delta vazio.
- `BuildingVisualState`: sem dependência de wood, stone, inventory, stock ou warehouse.
- Todos os painéis HUD/debug: read-only, sem mutação de estado.
- `integrity_hash` excluído do próprio cálculo.
- `previous_integrity_hash` e `sequence_number` incluídos no cálculo.
- SHA-256 via `HashingContext.HASH_SHA256` (implementado na 3.1.4).

#### FORA_DE_ESCOPO

NPC, combate, save/load, anti-cheat, servidor, multiplayer.

### Arquivos modificados

- `scripts/debug/domain_event_logger.gd` — `_MAX_CANONICALIZE_DEPTH`, limite de profundidade em `canonicalize()`
- `scripts/building/building_visual_state.gd` — `is_instance_valid(building_site)` em `refresh_visual_state()`
- `scripts/storage/warehouse.gd` — guard de `warehouse_changed` durante sync em `_on_inventory_changed()`
- `scripts/tests/inventory_system_test.gd` — 8 novos testes de robustez

### Testes adicionados (Wave 3.1.5)

| Teste | Cobre |
|---|---|
| `_test_add_resource_ignores_non_positive` | amount ≤ 0 e resource_id vazio/espaços não alteram estado |
| `_test_remove_resource_no_negative` | remoção além do saldo retorna false sem mutação |
| `_test_get_all_resources_is_snapshot` | snapshot retornado é cópia, não referência interna |
| `_test_deposit_delta_correct` | delta player negativo + warehouse positivo + conservação econômica |
| `_test_canonicalize_max_depth` | limite de profundidade retorna marcador `[MAX_DEPTH]` |
| `_test_resource_pickup_no_inventory` | actor sem inventário não perde recurso do pickup |
| `_test_resource_pickup_depletes_and_queues_free` | pickup com `remove_when_depleted=true` agenda remoção ao esgotar |
| `_test_blocked_completed_has_empty_delta` | `blocked_completed` não muta armazém, progresso ou stone |

### Validações realizadas

- Auditoria textual de todos os scripts listados no escopo.
- Dry-run mental de cada correção antes da aplicação.
- Revisão das invariantes por arquivo (negativo, cópia, atomicidade, desacoplamento).

### Validações não realizadas

- Validação visual/manual no editor Godot.
- Execução via Godot CLI (não disponível neste ambiente).

### Confirmações

- Nenhum script de gameplay (ResourcePickup, Warehouse, WarehouseInteractable, BuildingSite, BuildingVisualState, HUD, player) teve lógica de gameplay alterada.
- Esta camada de hash/ledger **não é anti-cheat real**. É ferramenta diagnóstica de rastreabilidade.
- Política WAREHOUSE_ONLY preservada.
- Separação lógica/visual preservada.

## Wave 3.1.4 - Auditoria e correção do hash determinístico do ledger econômico

### Problema auditado

`_make_integrity_hash` era implementado como:

```gdscript
return str(hash(JSON.stringify(event)))
```

Dois defeitos identificados:

**Defeito 1 — `hash()` em vez de SHA-256.**
`hash()` é o hash built-in do GDScript: 32 bits, platform-dependent e com colisão trivial.
Não é adequado como marcador de integridade rastreável.

**Defeito 2 — `JSON.stringify` não é canônico.**
Godot 4 serializa chaves de `Dictionary` em ordem de inserção.
O mesmo estado lógico com chaves em ordens diferentes produz JSONs diferentes → hashes diferentes.
Exemplo concreto:

```
before_a = {"player":{"wood":30,"stone":10},"warehouse":{}}  # hash X
before_b = {"warehouse":{},"player":{"stone":10,"wood":30}}  # hash Y  (X ≠ Y, mesmo estado)
```

### Campos verificados no cálculo do hash

| Campo | Incluído antes da correção | Incluído após correção | Observação |
|---|---|---|---|
| `event_name` | ✅ (via `event.attributes`) | ✅ | — |
| `operation_id` | ✅ | ✅ | — |
| `entity.type`, `entity.id` | ✅ | ✅ | — |
| `timestamp` | ✅ (via raiz do `event`) | ✅ | Incluído corretamente |
| `sequence_number` | ✅ | ✅ | Adicionado antes de `_make_integrity_hash` |
| `previous_integrity_hash` | ✅ | ✅ | Adicionado antes de `_make_integrity_hash` |
| `integrity_hash` (próprio) | ✅ Ausente na chamada | ✅ Ausente na chamada | Atribuído *depois* da chamada — correto |
| `state.before`, `state.after`, `delta` | ✅ | ✅ | — |

`integrity_hash` nunca entra no cálculo do próprio `integrity_hash` — o atributo é inserido em `attributes` apenas após `_make_integrity_hash(event)` retornar. Este comportamento estava correto antes e foi preservado.

### Correções aplicadas em `domain_event_logger.gd`

**Adicionada função pública `canonicalize(value) -> String`:**
- `Dictionary`: chaves ordenadas alfabeticamente antes de serializar, recursivamente.
- `Array`: ordem preservada, elementos canonicalizados recursivamente.
- `int`, `float`, `bool`, `null`, `String`, `StringName`: representação estável.

**`_make_integrity_hash` reescrito:**
- Chama `canonicalize(event)` em vez de `JSON.stringify(event)`.
- Usa `HashingContext.HASH_SHA256` em vez de `hash()`.
- Resultado: string hex de 64 caracteres, determinístico, independente de plataforma.

### Arquivos modificados

- `scripts/debug/domain_event_logger.gd` — adicionada `canonicalize()`, corrigida `_make_integrity_hash()`
- `scripts/tests/inventory_system_test.gd` — adicionado `_test_integrity_hash_deterministic()`
- `docs/waves/WAVE_3_1_IMPLEMENTATION_REPORT.md` — esta seção

### Gameplay preservado

Nenhum arquivo de gameplay foi alterado. `_make_integrity_hash` é chamado apenas dentro de `emit_event`, que é uma função diagnóstica. O retorno de `emit_event` não afeta lógica de estado do jogo.

### Checklist de aceitação

| Critério | Status | Observação |
|---|---|---|
| Hash determinístico auditado | PASS | `hash()` substituído por SHA-256 canônico |
| Chaves de Dictionary ordenadas | PASS | `canonicalize()` ordena alfabeticamente |
| `previous_integrity_hash` incluído | PASS | Já em `attributes` quando hash é calculado |
| `integrity_hash` excluído do próprio cálculo | PASS | Atribuído após retorno de `_make_integrity_hash` |
| SHA-256 usado | PASS | `HashingContext.HASH_SHA256`, hex de 64 chars |
| Gameplay preservado | PASS | Nenhum script de gameplay alterado |

## Wave 3.1.6 — Auditoria de performance estrutural

### Escopo

Auditoria e correção de custos estruturais que poderiam prejudicar performance, estabilidade e manutenibilidade conforme o projeto crescer. Nenhuma feature de gameplay adicionada ou removida.

### Classificação de custos

#### CUSTO_CRITICO (corrigidos)

| # | Arquivo | Problema | Correção |
|---|---|---|---|
| C1 | `building_visual_state.gd` | `_process()` chamava `_set_exclusive_visual()` e atualizava labels a ~60 FPS mesmo sem mudança de estado. Custo fixo por frame mesmo quando a construção está parada. | Adicionados `_last_progress: float = -1.0` e `_last_completed: bool = false`. `refresh_visual_state()` retorna cedo quando `progress == _last_progress and completed == _last_completed`. |
| C2 | `warehouse_interactable.gd` + `warehouse.gd` | Depósito multi-recurso chamava `add_resource()` N vezes → N chamadas a `_sync_inventory_from_stock()` e N emissões de `warehouse_changed`. | Adicionado `batch_add_resources(resources: Dictionary)` no Warehouse. `WarehouseInteractable` agora coleta `to_deposit: Dictionary` e chama `batch_add_resources()` uma única vez após remover todos os recursos do inventário do jogador. |

#### CUSTO_RELEVANTE (corrigidos)

| # | Arquivo | Problema | Correção |
|---|---|---|---|
| R1 | `domain_event_logger.gd` | `_merged_keys()` usava `Array.has()` O(N) no loop interno → O(N²) no total. | Reescrito com `seen: Dictionary` como conjunto — O(N). |
| R2 | `warehouse_interactable.gd` | `_resource_keys()` usava `Array.has()` O(N) → O(N²). | Reescrito com `seen: Dictionary` como conjunto — O(N). |
| R3 | `building_site.gd` | `get_step_cost()` recomputava a receita completa a cada chamada (chamado a cada 0,25s pela HUD). | Adicionado `_cached_step_cost: Dictionary`. `_compute_step_cost()` executa apenas em `_ready()`. `get_step_cost()` retorna cópia defensiva do cache. |
| R4 | `building_site.gd` | `_resource_keys()` usava `Array.has()` O(N) → O(N²). | Reescrito com `seen: Dictionary` como conjunto — O(N). |
| R5 | `game_hud.gd` | `_get_player_inventory()`, `_get_warehouse()`, `_get_building_site()` chamavam `get_node_or_null()` a cada refresh (0,25s). | Adicionados `_cached_player_inventory`, `_cached_warehouse`, `_cached_building_site`. Populados em `_cache_nodes()` com guard `is_instance_valid()`. |
| R6 | `inventory_debug_hud.gd` | Mesma situação: `get_node_or_null()` em todos os getters de domínio a cada tick. | Adicionados vars de cache e `_cache_domain_nodes()` chamado em `_ready()`. |

#### CUSTO_ACEITÁVEL (não corrigidos — registrados)

| # | Arquivo | Descrição | Motivo para não corrigir |
|---|---|---|---|
| A1 | `domain_event_logger.gd` | `emit_event()` constrói um Dictionary grande, faz SHA-256 e chama `JSON.stringify` + `print`. | Chamado apenas em eventos de jogo (coleta, depósito, construção) — não em hot path. Custo justificado para diagnóstico. |
| A2 | `warehouse.gd` | `_sync_inventory_from_stock()` reconstrói o InventoryContainer completo a cada operação de escrita no estoque. | Número de recursos é pequeno (< 10 em protótipo). Shadow inventory é necessário para compatibilidade com sistemas que consomem `InventoryContainer`. |

#### FORA_DE_ESCOPO

Profiler em runtime, pooling de objetos, multithreading, LOD, shader/draw call otimization, anti-cheat real, servidor autoritativo.

### Arquivos modificados

- `scripts/building/building_visual_state.gd` — dirty flag `_last_progress` / `_last_completed`
- `scripts/storage/warehouse.gd` — `batch_add_resources()`
- `scripts/storage/warehouse_interactable.gd` — usa `batch_add_resources`, `_resource_keys()` O(N)
- `scripts/debug/domain_event_logger.gd` — `_merged_keys()` O(N)
- `scripts/building/building_site.gd` — cache de `get_step_cost()`, `_compute_step_cost()`, `_resource_keys()` O(N)
- `scripts/ui/hud/game_hud.gd` — cache de nós de domínio em `_cache_nodes()`
- `scripts/debug/inventory_debug_hud.gd` — cache de nós em `_cache_domain_nodes()`
- `scripts/tests/inventory_system_test.gd` — 2 novos testes

### Testes adicionados (Wave 3.1.6)

| Teste | Cobre |
|---|---|
| `_test_warehouse_batch_add_resources` | Acumulação correta, batch sobre estoque existente, entradas inválidas ignoradas, batch vazio seguro |
| `_test_building_site_step_cost_cache` | Custo por etapa correto, idempotência entre chamadas, mutação do retorno não contamina cache interno |

### Validações realizadas

- Auditoria textual de todos os arquivos no escopo.
- Dry-run mental de cada correção antes da aplicação.
- Verificação de que `get_step_cost()` retorna cópia defensiva (`.duplicate()`) para evitar contaminação do cache por chamadores externos.
- Verificação de que `batch_add_resources()` em Warehouse e `_sync_inventory_from_stock()` / `warehouse_changed` são chamados exatamente uma vez por operação de depósito.
- Verificação de que o guard dirty flag em `BuildingVisualState` não bloqueia a primeira atualização (`_last_progress = -1.0` garante que o primeiro frame sempre passa).

### Validações não realizadas

- Validação visual/manual no editor Godot.
- Execução via Godot CLI (não disponível neste ambiente).
- Medição de frametime antes/depois.

### Confirmações

- Nenhuma feature de gameplay adicionada ou removida.
- Política WAREHOUSE_ONLY preservada.
- Separação lógica/visual preservada.
- `batch_add_resources()` é adição pura — não quebra compatibilidade com `add_resource()` existente.
- Cache de `get_step_cost()` é seguro: `required_resources` e `step_count` são `@export` definidos em design time e não mudam em runtime.
- Guard de `is_instance_valid()` nos caches de HUD tolera `queue_free()` de nós de domínio sem crash.
