# Relatorio Tecnico - Auditoria Pre-Teste da Cena Integrada

## 1. Resumo executivo

Foi executada uma auditoria de pre-teste funcional da cena `res://scenes/test/NPCWave4ConstructionStressTest.tscn`, com foco em validar se a cena esta pronta para testes progressivos antes de qualquer estresse com 20/40 NPCs.

A cena base `res://scenes/test/NPCWave4Test.tscn` foi preservada. A cena integrada carrega em headless, possui arena 80x80, bounds com margem, Casa Civil configurada para ate 40 civis, auto-spawn desligado por padrao, debug keyboard desligado e fluxo de construcao reutilizando inventario do jogador, pickups, armazem e `BuildingSite` existentes.

Foi aplicada apenas uma correcao pequena e segura: a rotacao inicial do `Player` na cena integrada foi normalizada para ele nascer olhando para a arena/pickups, reduzindo atrito no teste manual sem alterar sistemas.

## 2. Arquivos inspecionados

| Arquivo | Status |
| --- | --- |
| `res://scenes/test/NPCWave4ConstructionStressTest.tscn` | Inspecionado e corrigido pontualmente |
| `res://scripts/test/npc_wave4_construction_stress_test.gd` | Inspecionado |
| `res://scenes/test/NPCWave4Test.tscn` | Inspecionado |
| `res://scripts/test/npc_wave4_test.gd` | Inspecionado |
| `res://scripts/npc/npc_base.gd` | Inspecionado |
| `res://scripts/npc/npc_house.gd` | Inspecionado |
| `res://scripts/ui/npc_command_menu.gd` | Inspecionado |
| `res://scripts/ui/npc_creation_menu.gd` | Inspecionado |
| `res://scripts/building/building_site.gd` | Inspecionado |
| `res://scripts/storage/warehouse.gd` | Inspecionado |
| `res://scripts/storage/warehouse_interactable.gd` | Inspecionado |
| `res://scripts/resources/resource_pickup.gd` | Inspecionado |
| `res://scripts/inventory/player_inventory.gd` | Inspecionado |
| `res://docs/WAVE_4_NPC_FOUNDATION.md` | Inspecionado |
| `res://docs/WAVE_4_CONSTRUCTION_STRESS_TEST_REPORT.md` | Inspecionado |

## 3. Achados e correcoes

| ID | Categoria | Severidade | Achado | Acao |
| --- | --- | --- | --- | --- |
| A-001 | Cena integrada | Baixa | `Player` nascia em `(0, 0, 20)`, mas com rotacao de 180 graus, apontando para fora da arena/pickups. | Normalizada a transformacao inicial do `Player` na cena integrada para identidade, mantendo a posicao. |
| A-002 | CLI | Informativa | `Godot` nao estava no PATH. | Localizado executavel console em `C:\Users\timne\Downloads\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64_console.exe` e usado nos testes. |
| A-003 | Escopo | Informativa | Nao ha construcao por NPC, coleta por NPC, IA/wander, inimigos ou combate novos na cena integrada. | Nenhuma correcao necessaria. |

## 4. Checklist de pre-teste

| Item | Resultado | Evidencia |
| --- | --- | --- |
| 1. Cena base `NPCWave4Test.tscn` preservada | Passou | Cena separada inspecionada e carregada em headless com exit code 0. |
| 2. Cena integrada com Ground visual e collision 80x80 | Passou | Mesh e `BoxShape3D` usam `size = Vector3(80, 0.2, 80)`. |
| 3. `movement_bounds_min/max` dentro do chao, com margem | Passou | Bounds `(-36, -36)..(36, 36)` dentro do chao 80x80, margem de 4 unidades. |
| 4. Casa Civil com `max_spawned_npcs = 40` | Passou | Override da instancia `NPCHouse` na cena integrada. |
| 5. `auto_spawn_npcs_on_ready = 0` por padrao | Passou | Valor exportado e valor da cena sao 0. |
| 6. `debug_keyboard_commands_enabled = false` por padrao | Passou | Valor da cena integrada e da cena base sao `false`. |
| 7. Existe `PlayerInventory` no Player | Passou | Node `Player/PlayerInventory` com `player_inventory.gd`. |
| 8. Existem pickups suficientes para construcao | Passou | `WoodPickup` com 30 wood e `StonePickup` com 10 stone; custo total do BuildingSite: 20 wood e 10 stone. |
| 9. `WarehouseInteractable` e `BuildingSite` interagiveis | Passou | Ambos sao `StaticBody3D`, possuem `CollisionShape3D`, script e paths de armazem/building configurados. |
| 10. Menus nao iniciam visiveis | Passou | `npc_command_menu.gd` e `npc_creation_menu.gd` fazem `visible = false` em `_ready()`. |
| 11. Comando `Mover` aplica clamp de destino | Passou | `_order_move_forward()` usa `_clamp_move_destination()` antes de `NPCOrder.move_to_position(...)`. |
| 12. Sistema de construcao reutilizado, nao reescrito | Passou | Reuso de `building_site.gd`, `warehouse.gd`, `warehouse_interactable.gd`, `resource_pickup.gd` e `PlayerInventory`. |
| 13. Nao ha construcao por NPC | Passou | NPCs emitem ordens de seguir/mover/parar; sem chamada de `BuildingSite`/`build_step` por NPC. |
| 14. Nao ha IA/wander/inimigo/combate novo | Passou | Busca estatica nao encontrou implementacao nova desses sistemas; apenas enums/faction existentes. |

## 5. Validacao CLI/headless

| Comando | Resultado | Evidencia |
| --- | --- | --- |
| `Godot --headless --path O:\game --check-only --script res://scripts/test/npc_wave4_construction_stress_test.gd` | Passou | Exit code 0, Godot 4.6.2. |
| `Godot --headless --path O:\game --check-only --script res://scripts/test/npc_wave4_test.gd` | Passou | Exit code 0, Godot 4.6.2. |
| `Godot --headless --path O:\game res://scenes/test/NPCWave4ConstructionStressTest.tscn --quit-after 5` | Passou | Exit code 0; logs: Casa Civil limite 40, debug desativado, bounds `(-36,-36)..(36,36)`, auto_spawn 0. |
| `Godot --headless --path O:\game res://scenes/test/NPCWave4Test.tscn --quit-after 5` | Passou | Exit code 0; logs: Casa Civil limite 3, debug desativado. |

## 6. Plano de teste manual em etapas

| Etapa | Passos | Resultado esperado |
| --- | --- | --- |
| A - Cena integrada carrega sem NPCs | Abrir `NPCWave4ConstructionStressTest.tscn` no editor e executar sem criar civis. | Sem erro vermelho; mouse/camera/player funcionam; objetos principais visiveis. |
| B - Construcao sem NPCs | Coletar wood/stone, depositar no armazem e interagir com `BuildingSite_Test`. | Construcao progride/conclui usando recursos do armazem. |
| C - Criar 1 civil sem comando | Interagir com Casa Civil e criar 1 civil. | Civil aparece; menu fecha corretamente; sem selecao automatica indevida. |
| D - Comandos com 1 civil | Selecionar civil e testar Seguir, Mover e Parar. | Ordens funcionam; destino de Mover permanece dentro da area segura. |
| E - Construcao com 1 civil seguindo | Mandar 1 civil seguir o jogador e repetir fluxo de armazem/construcao. | NPC nao quebra raycast/menu/construcao; se bloquear fisicamente, registrar layout/collision. |
| F - Comandos com 3 civis | Criar 3 civis e alternar comandos entre eles. | Menus e selecao continuam estaveis; NPCs nao caem fora do chao. |
| G - Pre-carga com 10 civis | Criar ate 10 civis, mover para direcoes variadas e testar armazem/construcao. | Sem erro vermelho recorrente; mouse/camera nao travam; construcao ainda acessivel. |

## 7. Criterios para liberar teste de 20/40 NPCs

Liberar o teste de 20/40 NPCs apenas se todos os pontos abaixo passarem no editor:

| Criterio | Status atual |
| --- | --- |
| Cena integrada carrega sem erro vermelho | Liberavel por headless; pendente confirmacao visual |
| Construcao funciona sem NPCs | Pendente manual |
| 1 NPC funciona com seguir/mover/parar | Pendente manual |
| Construcao funciona com 1 NPC seguindo | Pendente manual |
| 3 NPCs funcionam com comandos alternados | Pendente manual |
| 10 NPCs nao quebram menu, raycast ou construcao | Pendente manual |
| NPCs nao caem para fora do chao | Pendente manual |
| Mouse/camera nao ficam presos | Pendente manual |
| Console nao gera erro vermelho recorrente | Pendente manual |

## 8. Pendencias fora de escopo

- Validar visualmente no editor a construcao sem NPCs e com NPC seguindo.
- Validar possivel interferencia fisica de NPCs no raycast para `WarehouseInteractable_Test` e `BuildingSite_Test`.
- Executar a progressao 1/3/10 civis antes de qualquer teste de 20/40.
- Medir performance real somente depois que o fluxo funcional basico passar.
- Implementar IA/wander, inimigos, combate, pathfinding/navmesh, selecao multipla, mover por clique, coleta por NPC e construcao por NPC apenas em tarefas futuras proprias.

## 9. Decisao final

APROVADO COM RESSALVAS.

Justificativa tecnica: a auditoria estatica e os testes headless passaram, e a unica correcao aplicada foi pequena e limitada a orientacao inicial do jogador na cena integrada. A cena esta pronta para o pre-teste manual progressivo A-G, mas ainda nao deve liberar estresse real com 20/40 NPCs ate que construcao, raycast, menus, mouse/camera e comandos passem no editor com 0/1/3/10 civis.
