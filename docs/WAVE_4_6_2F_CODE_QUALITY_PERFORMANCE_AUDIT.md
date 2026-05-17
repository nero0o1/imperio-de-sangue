# Wave 4.6.2F - Auditoria de Qualidade, Performance e Segurança de Refactor

## Resumo executivo

A Wave 4.6.2F manteve o comportamento funcional da Wave 4.6.2E e reduziu peso no fluxo de preview/placement. A correção aplicada remove a instanciação repetida de cenas probe durante validações de construção, substituindo por cache por `building_id`. O debug detalhado do placement fica desligado por padrão.

## Problemas encontrados

- `BuildPlacementController` instanciava a cena atual em `_get_building_state_invalid_reason()` e `_get_required_resources_for_current_building()`.
- Essas funções podem ser chamadas durante a atualização do preview, então o custo crescia junto com uso de placement.
- `placement_debug_enabled` estava ligado por padrão, contrariando a regra de logs detalhados desligados em execução normal.
- A busca obrigatória ainda encontra prints e warnings em scripts de UI/teste/core, mas a maioria está fora do caminho quente desta correção ou já depende de flags de debug.

## Código removido/enxugado

- Removidas as duas instanciações probe repetidas no caminho de validação do placement.
- `_get_building_state_invalid_reason()` passou a consultar o estado inicial cacheado.
- `_get_required_resources_for_current_building()` passou a retornar o custo cacheado do building atual.

## Funções pesadas identificadas

- `scripts/test/build_placement_controller.gd`
  - `_get_building_state_invalid_reason()`: antes instanciava cena para ler `BuildingSite.is_completed`.
  - `_get_required_resources_for_current_building()`: antes instanciava cena para ler `BuildingSite.required_resources`.
  - `_find_first_child_of_type()`: busca recursiva mantida apenas para configuração inicial/cache e configuração pós-instanciação real, não para validação repetida.
- `scripts/npc/npc_order_executor.gd`
  - Coleta, warehouse e build site já usam grupos (`resource_pickup`, `warehouse_interactable`, `building_site`) nos fluxos principais.

## Otimizações aplicadas

- Criado cache `_building_scene_config_cache` por `building_id`.
- O cache armazena:
  - `required_resources`;
  - `initial_completed_state`.
- `begin_placement()` copia a configuração cacheada para o estado corrente do preview.
- `_clear_preview()` limpa o estado corrente para evitar reaproveitamento acidental.
- `placement_debug_enabled` alterado para `false` por padrão.

## Otimizações adiadas e motivo

- Não foi criado `WarehouseRegistry`: a Wave pede correção mínima e não mudança de regra de economia.
- Não foram removidos prints de menus/comandos de NPC: isso pode alterar rastreabilidade manual existente; deve virar passe dedicado de debug flags por módulo.
- Não foi reescrito `NPCOrderExecutor`: os fluxos críticos já usam grupos e a Wave não pede mudança de gameplay.
- Não foi removida busca recursiva usada para configurar uma construção recém-instanciada: não é caminho por frame e é necessária para cenas com hierarquia interna.

## Arquivos alterados

- `scripts/test/build_placement_controller.gd`
- `docs/WAVE_4_6_2F_CODE_QUALITY_PERFORMANCE_AUDIT.md`

## Testes automáticos

| Teste | Resultado |
|---|---|
| `git diff --check` | PASS |
| Godot headless projeto | PASS |
| Godot headless cena integrada | PASS |

## Teste manual recomendado

| Checklist | Resultado |
|---|---|
| Abrir `NPCWave4OrderIntegrationTest.tscn` | PENDENTE |
| Rodar por 2 minutos | PENDENTE |
| Criar 3 construções runtime | PENDENTE |
| Criar/usar 5 NPCs | PENDENTE |
| Testar coleta wood/stone | PENDENTE |
| Testar `ASSIST_BUILD` | PENDENTE |
| Confirmar depurador sem warnings novos | PENDENTE |
| Confirmar FPS aproximado aceitável | PENDENTE |
| Confirmar logs sem spam | PENDENTE |

Observação: a validação visual/manual de 2 minutos deve ser executada no editor antes do merge. Os testes headless confirmam parser e abertura da cena, mas não medem FPS real nem fluxo visual completo.

## Riscos restantes

- Ainda existem prints em menus e cenas de teste; não aparecem como spam JSON normal, mas podem poluir o console em validação extensa.
- A configuração cacheada assume que o custo inicial da cena não muda dinamicamente enquanto o jogo está rodando.
- A política de warehouse segue a decisão da Wave anterior e ainda não substitui um registry dedicado.

## Recomendação de merge ou não merge

Não fazer merge ainda sem executar o checklist manual de 2 minutos no editor. Se o teste manual confirmar ausência de regressão, FPS aceitável e sem warnings novos, o PR #1 fica em condição razoável para revisão final.
