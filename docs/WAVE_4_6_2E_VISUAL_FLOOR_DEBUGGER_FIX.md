# Wave 4.6.2E - Visual Floor Cleanup and Debugger Warning Fix

## Falhas observadas

- O problema visual do chao ainda aparecia durante o teste manual da cena `NPCWave4OrderIntegrationTest.tscn`.
- O depurador indicava variaveis declaradas e nao usadas em `NPCCommandMenu`.
- Logs de coleta/navegacao mostravam falhas genericas como `Movement failed after stuck recovery attempts` e `GATHER_RESOURCE failed: NPC bloqueado por timeout simples`.
- O preview de construcao podia falhar com `sem_chao_valido` sem informar o raycast usado.
- Delete para destruir construcoes permanece fora do escopo.

## Causa raiz

- As variaveis `_nearest_building_site`, `_nearest_dist_tmp`, `_nearest_pickup`, `_nearest_pickup_dist`, `_nearest_warehouse_interactable` e `_nearest_wi_dist` eram sobras da busca recursiva removida na Wave 4.6.2D.
- A cena nao tinha um segundo chao fisico grande, mas tinha auxiliares visuais/debug no mesmo plano de trabalho: `NavigationRegion3D` com navmesh no y=0 e quatro markers (`MarkerNorth`, `MarkerSouth`, `MarkerWest`, `MarkerEast`) logo acima do piso em y=0.03. Em execucao/debug visual isso podia ser interpretado como camada extra de chao.
- As falhas de navegacao e placement nao carregavam contexto suficiente para distinguir alvo invalido, raycast sem hit, collider fora do grupo `movement_ground` ou ausencia de `NavigationRegion3D`.

## Arquivos alterados

- `scenes/test/NPCWave4OrderIntegrationTest.tscn`
- `scripts/npc/npc_order_executor.gd`
- `scripts/test/build_placement_controller.gd`
- `scripts/ui/npc_command_menu.gd`
- `docs/WAVE_4_6_2E_VISUAL_FLOOR_DEBUGGER_FIX.md`

## Como o problema do chao foi identificado

A auditoria do `.tscn` confirmou:

- `Ground` (`StaticBody3D`) no grupo `movement_ground`.
- `Ground/MeshInstance3D` como piso visual principal.
- `Ground/CollisionShape3D` como colisao principal.
- `NavigationRegion3D` no grupo `navigation_region`, com navmesh coplanar ao topo do chao.
- Quatro markers visiveis acima do piso.

Nao foi encontrada segunda malha grande de piso nem segunda colisao grande. A limpeza aplicada ocultou `NavigationRegion3D` e markers auxiliares, preservando a navegacao e o chao real.

## Overlay/debug ou geometria real

Era overlay/auxiliar visual, nao uma duplicidade real de piso. Para religar a visualizacao de depuracao no editor, reativar temporariamente `visible = true` em `NavigationRegion3D` ou nos markers da cena. Para jogo/teste normal, eles ficam ocultos.

## Warnings removidos

Removidas as variaveis de classe nao usadas:

- `_nearest_building_site`
- `_nearest_dist_tmp`
- `_nearest_pickup`
- `_nearest_pickup_dist`
- `_nearest_warehouse_interactable`
- `_nearest_wi_dist`

As funcoes de busca atuais continuam existindo e usam variaveis locais.

## Diagnostico de `sem_chao_valido`

`BuildPlacementController` agora guarda e imprime, sem spam por frame, o diagnostico do raycast quando a validacao falha:

- origem do raycast;
- destino;
- collision mask;
- se consulta areas/corpos;
- se nao bateu em nada;
- collider atingido;
- posicao do hit;
- grupos do collider;
- se o collider esta no grupo `movement_ground`.

## Diagnostico de `Movement failed`

`NPCOrderExecutor` agora detalha falhas de navegacao/coleta com:

- tipo da ordem;
- estado da coleta;
- filtro de recurso;
- posicao do NPC;
- validade do alvo;
- nome/path/posicao do alvo quando disponivel;
- distancia ate o alvo;
- quantidade de `NavigationRegion3D` no grupo `navigation_region`.

A falha continua sendo falha; a mudanca e apenas diagnostica.

## Testes executados

| Teste | Resultado |
|---|---|
| `git diff --check` | PASS |
| Godot headless projeto | PASS |
| Godot headless cena integrada | PASS |

## Teste manual

| Teste | Resultado | Observacao |
|---|---|---|
| Abrir `NPCWave4OrderIntegrationTest.tscn` | PASS parcial | Cena abre em headless; inspecao visual no editor ainda recomendada. |
| Confirmar chao visual | PASS parcial | Causa objetiva identificada e auxiliares ocultados; confirmar visualmente no editor/jogo. |
| Depurador sem warnings unused | PASS parcial | Variaveis declaradas foram removidas; confirmar no painel do editor. |
| Criar construcao | NAO EXECUTADO | Requer interacao manual. |
| Mandar NPC coletar | NAO EXECUTADO | Requer interacao manual. |
| Falha de movimento com diagnostico claro | PASS por codigo | Diagnostico implementado; validar quando a falha ocorrer manualmente. |

## Riscos restantes

- Se o editor estiver com overlays globais de navegacao/colisao ativados, eles ainda podem aparecer por configuracao do editor, fora da cena.
- A confirmacao visual final depende de abrir a cena no editor ou jogo com a mesma configuracao usada no teste manual.
- Os diagnosticos foram adicionados sem transformar falhas em sucesso; gargalos reais de navegacao ainda precisam ser corrigidos se os novos logs apontarem causa estrutural.

## Status do PR

- Branch: `hotfix-4-6-2c-manual-validation`
- PR: #1 (`hotfix-4-6-2c-manual-validation` -> `wave-4-6-npc-economia-construcao`)
- Status: atualizado pelo push deste hotfix apos commit.

## Proxima recomendacao

Nao fazer merge ainda ate a validacao manual confirmar o chao visual limpo, depurador sem warnings e diagnosticos uteis para eventuais falhas de navegacao/coleta. Delete para destruir construcoes deve continuar em Wave separada.
