# Relatório de Auditoria e Correção — Wave 4.6
**Branch:** `wave-4-6-npc-economia-construcao`  
**Hotfix branch:** `hotfix-4-6-1-fix` (criação manual necessária — ver seção Git)  
**Data:** 2026-05-10  
**Auditor:** Claude (Cowork)

---

## Resumo Executivo

A Wave 4.6 introduziu o sistema de economia de NPC (`GATHER_RESOURCE`, `FORCE_DROP`, `REPAIR`), modo de construção via tecla H, sistema de população por casa civil e wander idle. A auditoria identificou **2 bugs funcionais confirmados** e **2 itens já implementados corretamente** que não necessitavam intervenção. Dois itens (NavigationRegion3D e detecção de NPC travado) requerem configuração no editor Godot, não em código GDScript puro.

**Status pós-correção:** os 2 bugs foram corrigidos nos arquivos `npc_order.gd` e `npc_order_executor.gd`. As alterações estão no disco mas aguardam commit manual (ver seção Git).

---

## Arquivos Auditados

| Arquivo | Papel | Modificado |
|---|---|---|
| `scripts/npc/npc_order.gd` | Estrutura de dados de ordem; factories estáticas | ✅ Sim |
| `scripts/npc/npc_order_executor.gd` | Executor semântico de ordens por tipo | ✅ Sim |
| `scripts/npc/npc_base.gd` | Base do NPC; fila de ordens; `get_inventory()` | Não |
| `scripts/npc/npc_capability_set.gd` | Mapeamento de capacidades por função | Não |
| `scripts/npc/npc_tactical_state.gd` | Estado tático e posturas persistentes | Não |
| `scripts/inventory/npc_inventory.gd` | Inventário próprio do NPC | Não |
| `scripts/resources/resource_pickup.gd` | Pickup de recurso com domain events | Não |
| `scripts/core/population_manager.gd` | Gestão de capacidade populacional | Não |
| `scripts/ui/build_menu.gd` | Menu de construção (PT-BR) | Não |
| `scripts/test/build_placement_controller.gd` | Controlador de placement; tecla H | Não |
| `scripts/test/buildable_civil_house_controller.gd` | Liga construção concluída ao PopulationManager | Não |
| `scripts/test/npc_wave4_construction_stress_test.gd` | Cena de stress test | Não |

---

## Bugs Identificados e Correções Aplicadas

### Bug 1 — GATHER_RESOURCE não filtrava por tipo de recurso

**Arquivo:** `scripts/npc/npc_order_executor.gd` — `_is_valid_resource_pickup()`  
**Gravidade:** Alta (funcional — NPC coletava qualquer recurso independente da ordem)

**Problema:**  
```gdscript
# Antes — sem filtro de tipo:
func _is_valid_resource_pickup(node: Node) -> bool:
    return _has_property(node, "resource_id") and _has_property(node, "amount") \
        and node.has_method("interact") and int(node.get("amount")) > 0
```

**Solução aplicada — 4 mudanças coordenadas:**

1. **`npc_order.gd`** — campo `resource_id_filter` adicionado:
```gdscript
var resource_id_filter: StringName = &""  # GATHER_RESOURCE: se preenchido, só coleta este tipo
```

2. **`npc_order.gd`** — factory `gather_resource` adicionada:
```gdscript
static func gather_resource(resource_id: StringName = &"", target: Node3D = null,
        actor: Node = null, queued: bool = false) -> NPCOrder:
    var order := NPCOrder.new(NPCEnums.OrderType.GATHER_RESOURCE, Vector3.ZERO, target, actor, queued)
    order.resource_id_filter = resource_id
    return order
```

3. **`npc_order_executor.gd`** — var `_collector_resource_filter` + reset em `_reset_runtime_state`:
```gdscript
var _collector_resource_filter: StringName = &""
# em _reset_runtime_state():
_collector_resource_filter = &""
```

4. **`npc_order_executor.gd`** — leitura em `_start_gather_resource` + filtragem em `_is_valid_resource_pickup`:
```gdscript
# Em _start_gather_resource:
_collector_resource_filter = order.resource_id_filter

# Em _is_valid_resource_pickup (novo):
if _collector_resource_filter != &"":
    return StringName(str(node.get("resource_id"))) == _collector_resource_filter
return true
```

**Compatibilidade:** chamadas existentes sem `resource_id_filter` recebem `&""` (sem filtro) — comportamento idêntico ao anterior.

---

### Bug 2 — ASSIST_BUILD terminava após completar o primeiro canteiro

**Arquivo:** `scripts/npc/npc_order_executor.gd` — `_process_assist_build()`  
**Gravidade:** Média (funcional — NPC parava ocioso após primeiro canteiro concluído)

**Problema:**  
```gdscript
# Antes — terminava COMPLETED ao detectar is_completed == true:
if bool(order.target_node.get("is_completed")):
    return _finish(order, NPCEnums.OrderStatus.COMPLETED, "ASSIST_BUILD completed: ...")
```

**Solução aplicada — 3 mudanças coordenadas:**

1. **`_process_assist_build`** — lógica de redirecionamento ao detectar site concluído:
```gdscript
var site_done := not is_instance_valid(order.target_node) \
    or bool(order.target_node.get("is_completed"))
if site_done:
    var next_site := _find_nearest_incomplete_building_site()
    if next_site == null:
        return _finish(order, NPCEnums.OrderStatus.COMPLETED, "ASSIST_BUILD completed: todos os canteiros concluidos.")
    # Redireciona para o próximo canteiro sem criar nova ordem.
    order.target_node = next_site
    _build_step_elapsed = 0.0
    _npc.tactical_state.reset_movement_modifiers()
    _npc._begin_semantic_move(order.target_node.global_position, NPCTacticalState.ASSISTING_BUILD)
    return NPCEnums.OrderStatus.RUNNING
```

2. **`_find_nearest_incomplete_building_site()`** — helper adicionado:
```gdscript
func _find_nearest_incomplete_building_site() -> Node3D:
    var root := _get_search_root()
    return _find_nearest_node(root, Callable(self, "_is_incomplete_building_site")) as Node3D
```

3. **`_is_incomplete_building_site()`** — predicate adicionado:
```gdscript
func _is_incomplete_building_site(node: Node) -> bool:
    if not is_instance_valid(node) or not (node is Node3D):
        return false
    return node.has_method("build_step") and not bool(node.get("is_completed"))
```

**Invariante preservado:** `_process_assist_build` nunca chama `_finish(COMPLETED)` enquanto houver canteiro acessível. A mutação de `order.target_node` é segura: `NPCOrder` é `RefCounted` com campos públicos, e a fila de ordens guarda referência ao mesmo objeto.

---

## Itens Verificados como Já Implementados Corretamente

### Modo de construção (tecla H)
**Verificado em:** `scripts/test/build_placement_controller.gd` + `project.godot`  
`build_mode` (H = keycode 72) está registrado em `project.godot`. `BuildPlacementController._unhandled_input()` trata o evento, chama `_open_build_menu()`, e o menu `BuildMenu.tscn` está em PT-BR (`"Armazém"`, `"Casa Civil"`, `"Fechar"`). Cancelamento via Esc funciona em `build_menu.gd._unhandled_input()`. ✅

### Sistema de população (+10 por casa)
**Verificado em:** `buildable_civil_house_controller.gd` → `npc_house.gd` → `population_manager.gd`  
Fluxo completo: `building_site.construction_completed` → `_on_construction_completed()` → `npc_house.register_population_capacity()` → `PopulationManager.register_house(self, 10)` → `capacity_max += 10`. ✅

---

## Itens Pendentes (Requerem Editor Godot)

| Item | Status | O que falta |
|---|---|---|
| NavigationRegion3D nas cenas de teste | ⚠️ Pendente | Adicionar nó `NavigationRegion3D` + `MeshInstance3D` (bake) nas cenas `NPCWave4Test.tscn` e `NPCWave4ConstructionStressTest.tscn`. Sem isso, `NavigationAgent3D` não encontra caminho. |
| Detecção de NPC travado | ⚠️ Parcial | `COLLECTOR_TIMEOUT = 20s` já existe para estados de coleta. Para ordens de movimento geral (MOVE_TO_POSITION), não há detecção de travamento. Requer lógica de velocidade média ou posição delta em `npc_base.gd`. |
| HUD de recursos e população | ⚠️ Não auditado | Não foi possível confirmar se há HUD exibindo estoque do armazém e capacidade populacional. Requer inspeção das cenas de UI. |

---

## Tabela de Riscos

| Arquivo | Problema | Solução | Risco |
|---|---|---|---|
| `npc_order_executor.gd` | `_is_valid_resource_pickup` sem filtro | `_collector_resource_filter` + comparação por `StringName` | Baixo — `resource_id` no pickup pode ser `String` ou `StringName`; `StringName(str(...))` cobre ambos |
| `npc_order_executor.gd` | ASSIST_BUILD terminava cedo | Redireciona `order.target_node` para próximo site | Baixo — mutação in-place segura; `_is_incomplete_building_site` não retorna site recém-concluído |
| `npc_order.gd` | Ausência de factory para GATHER_RESOURCE tipado | `NPCOrder.gather_resource(resource_id)` adicionada | Nenhum — backward compatible; sem filtro = `&""` = comportamento anterior |
| Todas as cenas | Ausência de `NavigationRegion3D` | Requer editor | Alto — sem bake, NPCs não conseguem navegar em terreno complexo |

---

## Testes Manuais Executáveis

Após commit e execução da cena `NPCWave4ConstructionStressTest.tscn` no Godot:

1. **GATHER_RESOURCE filtrado:**  
   Emitir `NPCOrder.gather_resource(&"wood")` para um NPC civil. Verificar no console que o NPC só interage com `ResourcePickup` cujo `resource_id == "wood"`. Pickups de `stone` devem ser ignorados.

2. **GATHER_RESOURCE sem filtro (retrocompatibilidade):**  
   Emitir `NPCOrder.gather_resource()` (sem argumento). NPC deve coletar qualquer pickup válido disponível — idêntico ao comportamento anterior.

3. **ASSIST_BUILD multi-site:**  
   Colocar 2 canteiros de construção incompletos. Emitir `NPCOrder.assist_build(canteiro_1)` para um NPC. Após o canteiro 1 ser concluído, o NPC deve se mover automaticamente para o canteiro 2 sem nova ordem. Após ambos concluídos, ordem deve terminar COMPLETED.

4. **ASSIST_BUILD sem próximo site:**  
   Com apenas 1 canteiro, concluir a construção. O NPC deve terminar a ordem com COMPLETED sem erros no console.

5. **Modo de construção (H):**  
   Pressionar H → menu de construção abre. Pressionar Esc → menu fecha. Selecionar "Casa Civil" → modo de placement ativo. Confirmar placement → estrutura aparece no mundo.

6. **População:**  
   Completar 1 casa civil. Verificar via `PopulationManager.capacity_max` que o valor aumentou em 10.

---

## Comandos Git (executar no terminal Windows)

```bash
# Na raiz do projeto O:\game

# 1. Criar branch hotfix a partir da branch atual
git checkout -b hotfix-4-6-1-fix

# 2. Verificar arquivos modificados (deve mostrar os dois scripts)
git status

# 3. Forçar re-hash e adicionar os arquivos ao stage
#    (necessário por limitação de mtime no mount do sandbox)
git add scripts/npc/npc_order.gd scripts/npc/npc_order_executor.gd

# 4. Confirmar que os dois arquivos estão staged
git diff --cached --stat

# 5. Commit com prefixo fix:
git commit -m "fix: filtro resource_id em GATHER_RESOURCE e continuacao multi-site em ASSIST_BUILD

- NPCOrder: adiciona campo resource_id_filter (StringName, padrao &'')
- NPCOrder: adiciona factory gather_resource(resource_id, target, actor, queued)
- NPCOrderExecutor: _collector_resource_filter aplicado em _is_valid_resource_pickup
- NPCOrderExecutor: _process_assist_build redireciona para proximo canteiro incompleto
- NPCOrderExecutor: adiciona _find_nearest_incomplete_building_site e _is_incomplete_building_site
- Retrocompativel: resource_id_filter == &'' aceita qualquer pickup (comportamento anterior)"

# 6. Verificar diff final
git diff HEAD~1 --stat
```

---

## Limitações Desta Auditoria

- **Compilação Godot headless:** não executada — sandbox Linux não possui Godot instalado. Erros de sintaxe GDScript não podem ser descartados via compilação; revisão textual foi realizada.
- **Git index.lock:** o processo Godot/Windows mantém o index.lock. Commit deve ser feito no terminal Windows, não no sandbox Linux.
- **NavigationRegion3D:** requer editor visual para adicionar nó e fazer bake da malha de navegação — fora do escopo de correção em código puro.
- **HUD:** não foi possível confirmar a existência ou estado de uma HUD de recursos/população sem acesso à cena principal.
