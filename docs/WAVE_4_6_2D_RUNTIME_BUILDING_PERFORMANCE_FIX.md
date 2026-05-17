# Wave 4.6.2D - Runtime Building Integration, Floor Cleanup and Performance Stabilization

## Resumo executivo

Correção dos bloqueadores encontrados depois da Wave 4.6.2C na cena `NPCWave4OrderIntegrationTest.tscn`, com foco em estabilizar construções criadas em runtime, reduzir custo de busca/logs em execução normal, manter uma regra consistente de warehouse e auditar a suspeita de chão duplicado antes de qualquer merge ou promoção para protótipo jogável.

## Falhas observadas

- Dois pisos/chãos pareciam sobrepostos no cenário durante validação manual.
- NPCs ajudavam construções já existentes, mas construções colocadas em runtime não ficavam totalmente integradas ao fluxo de `ASSIST_BUILD`.
- Com cerca de 5 NPCs e 3 construções colocadas, o mundo começava a travar, com indício de excesso de logs, varreduras globais e atualização repetitiva de destino.
- Logs normais incluíam muitos eventos JSON, depósitos, mudanças de destino, stuck recovery e falhas genéricas de `ASSIST_BUILD`.
- A destruição por Delete foi mantida fora do escopo desta Wave.

## Causa raiz confirmada

- A cena contém apenas um piso físico/visual real no arquivo `.tscn`; a segunda superfície observada é compatível com overlay/debug/indicadores de navegação e marcadores, não com uma segunda malha grande de chão duplicada.
- Construções instanciadas pelo `BuildPlacementController` não eram configuradas de forma suficientemente explícita para a Wave D: grupo `building_site`, estado inicial incompleto, política de consumo e `warehouse_path` precisavam ser normalizados no momento da criação.
- O comando de NPC e o executor ainda dependiam de buscas amplas ou pouco direcionadas em partes do fluxo, o que tornava sites criados em runtime menos confiáveis e mais caros de localizar.
- Depósito e construção podiam divergir na escolha do warehouse quando mais de um warehouse existia no mundo.
- Logs detalhados e atualizações de alvo eram ativos demais para execução normal.

## Arquivos alterados

- `scripts/building/building_site.gd`
- `scripts/debug/domain_event_logger.gd`
- `scripts/npc/npc_base.gd`
- `scripts/npc/npc_order_executor.gd`
- `scripts/resources/resource_pickup.gd`
- `scripts/storage/warehouse.gd`
- `scripts/storage/warehouse_interactable.gd`
- `scripts/test/build_placement_controller.gd`
- `scripts/ui/npc_command_menu.gd`
- `docs/LOCAL_BEFORE_HOTFIX_4_6_2D.patch`
- `docs/WAVE_4_6_2D_RUNTIME_BUILDING_PERFORMANCE_FIX.md`

## Correções aplicadas

- `BuildingSite` agora entra no grupo `building_site` em `_ready()`, expõe logs detalhados por `debug_enabled` e informa motivo detalhado quando `ASSIST_BUILD` falha por recurso.
- `BuildPlacementController` configura sites criados em runtime com `is_completed = false`, progresso zerado, política `WAREHOUSE_THEN_PLAYER`, `warehouse_path` resolvido e grupos necessários.
- Construções criadas em runtime entram no grupo `destroyable_building` apenas como marcação segura para Wave futura; nenhuma lógica de Delete foi implementada.
- Warehouses e seus interactables entram nos grupos `warehouse` e `warehouse_interactable`.
- `NPCOrderExecutor` e `NPCCommandMenu` passaram a buscar pickups, warehouses e building sites pelos grupos `resource_pickup`, `warehouse_interactable` e `building_site`.
- NPCs preferem o warehouse default operacional (`warehouse_default`) para depósito e suporte de construção nesta Wave.
- Logs JSON de domínio ficam desligados por padrão, mantendo eventos de erro visíveis.
- Logs verbosos de pickup, warehouse interactable e NPC base foram colocados atrás de flags de debug.
- `NPCBase` evita reenviar `NavigationAgent3D.target_position` quando o destino mudou menos que o threshold configurado.
- A validação de placement foi throttled para reduzir consultas físicas quando o alvo de preview não precisa ser recalculado a cada frame.

## Chao

Nós grandes encontrados em `scenes/test/NPCWave4OrderIntegrationTest.tscn`:

- `Ground` (`StaticBody3D`) no grupo `movement_ground`.
- `Ground/MeshInstance3D` como piso visual principal.
- `Ground/CollisionShape3D` como colisão principal de piso.
- `NavigationRegion3D` no grupo `navigation_region`.

Também existem marcadores visuais pequenos (`MarkerNorth`, `MarkerSouth`, `MarkerEast`, `MarkerWest`) posicionados acima do chão para orientação. Eles não formam uma segunda malha grande de piso.

Resultado: não foi encontrada duplicidade real no arquivo da cena. Nenhuma geometria foi removida. A `NavigationRegion3D` foi preservada.

## ASSIST_BUILD runtime

Antes, a construção colocada pelo jogador dependia de configuração implícita do prefab e de buscas menos direcionadas. Isso deixava o `BuildingSite` runtime vulnerável a ausência de grupo, `warehouse_path` inconsistente e seleção incorreta do alvo incompleto.

Agora o `BuildPlacementController` normaliza a construção no momento da instância, e os comandos de NPC localizam sites incompletos pelo grupo `building_site`, incluindo os criados em runtime. Quando a construção não pode avançar por recurso, o log informa o recurso faltante, a política de consumo, o warehouse resolvido e o inventário do ator quando aplicável.

## Recursos/Warehouse

Regra atual da Wave 4.6.2D: usar o warehouse central/default (`warehouse_default`) como fonte preferencial do protótipo até existir um `WarehouseRegistry` ou economia global formal.

- Depósito de NPC prefere o interactable ligado ao warehouse default operacional.
- `BuildingSite` runtime recebe `warehouse_path` resolvido pelo `BuildPlacementController`.
- `ASSIST_BUILD` usa a política `WAREHOUSE_THEN_PLAYER`, com diagnóstico claro quando falta recurso.
- HUD continua apontando para os sistemas configurados da cena.

Risco restante: múltiplos warehouses ainda não têm pooling global nem roteamento econômico completo. Se o jogador criar warehouses adicionais, a regra de central/default deve ser substituída por uma Wave própria de registry/roteamento.

## Performance

Gargalos encontrados e tratados:

- Eventos JSON de domínio eram impressos em modo normal; agora só logs verbosos habilitados ou eventos de erro são impressos.
- Pickups, warehouses, building sites e menu de comando tinham pontos de busca que podiam varrer a árvore; os fluxos principais agora usam grupos.
- Atualização de destino de NPC podia reenviar alvo para o `NavigationAgent3D` sem mudança relevante; foi adicionado threshold.
- Logs de ordem do NPC ficavam ativos por padrão; agora `debug_enabled` vem desligado e falhas críticas continuam visíveis.
- Preview de construção fazia validação continuamente; foi adicionado throttle configurável.

Observação manual de FPS/travamento: não executada nesta sessão headless. O teste headless da cena por 5 segundos não apresentou travamento, parser error, erro vermelho recorrente nem spam JSON.

## Testes automaticos

| Teste | Resultado |
|---|---|
| `git diff --check` | PASS |
| Godot headless projeto | PASS |
| Godot headless cena integrada | PASS |

## Testes manuais

| Teste | Resultado | Observacao |
|---|---|---|
| Abrir `NPCWave4OrderIntegrationTest.tscn` | PASS parcial | Cena abriu em headless; validacao visual no editor ainda recomendada. |
| Confirmar um chao real | PASS parcial | Auditoria do `.tscn` confirmou um piso real; inspeção visual manual ainda recomendada. |
| Colocar 3 construcoes via BuildPlacementController | NAO EXECUTADO | Requer editor/interacao manual. |
| Criar/usar 5 NPCs | NAO EXECUTADO | Requer editor/interacao manual. |
| ASSIST_BUILD em construcao runtime | PASS parcial | Fluxo de runtime foi corrigido por codigo; validacao manual ainda recomendada. |
| Falha de recurso informa recurso/warehouse | PASS | `BuildingSite.get_build_block_reason()` agora detalha recurso faltante, politica, warehouse e inventario. |
| NPCs andando/coletando | PASS parcial | Cena headless inicializou sem erro; fluxo completo manual ainda recomendado. |
| Observar travamentos/FPS | NAO EXECUTADO | Ambiente headless nao mede FPS visual do editor. |
| Logs JSON sem spam em modo normal | PASS | Teste headless da cena nao mostrou eventos JSON em loop. |

## Riscos restantes

- A política de warehouse default é intencionalmente simples e deve ser trocada por registry/roteamento quando a economia suportar múltiplos warehouses de forma sistêmica.
- A validação manual com 5 NPCs e 3 construções ainda precisa medir FPS aproximado no editor.
- O grupo `destroyable_building` foi preparado para segurança futura, mas nenhuma destruição por Delete foi implementada.
- A correção reduz buscas e logs, mas ainda não substitui todos os sistemas por cache invalidável/eventos.

## Git

- Branch: `hotfix-4-6-2c-manual-validation`
- Commit: este commit de hotfix
- Push: realizado para `origin/hotfix-4-6-2c-manual-validation`
- PR: #1 atualizado pelo push da branch
- Patch local pré-hotfix: `docs/LOCAL_BEFORE_HOTFIX_4_6_2D.patch`

## Proxima recomendacao

Só depois desta estabilização, criar uma Wave separada para destruição de construções com tecla Delete, sem refund inicial, usando raycast da câmera e grupo `destroyable_building`, com proteção para não destruir chão, player, NPC, recurso ou Warehouse principal.
