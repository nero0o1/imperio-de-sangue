# Relatorio Tecnico — Cena Integrada de Estresse e Construcao

## 1. Resumo executivo

Foi criada a cena `res://scenes/test/NPCWave4ConstructionStressTest.tscn` para validar a Wave 4 em uma area ampla, com Casa Civil para ate 40 civis, comandos de NPC preservados e o fluxo existente de construcao pelo jogador no mesmo mapa. A cena base `res://scenes/test/NPCWave4Test.tscn` nao foi alterada.

A integracao reutiliza `NPCHouse`, `NPCBase`, menus de NPC, `Player`, `PlayerInventory`, pickups de recurso, `Warehouse`, `WarehouseInteractable`, `BuildingSite` e HUDs existentes. Nao foi implementada construcao por NPC.

## 2. Arquivos criados/alterados

| Arquivo | Criado/alterado | Motivo | Risco reduzido |
| --- | --- | --- | --- |
| `res://scenes/test/NPCWave4ConstructionStressTest.tscn` | Criado | Cena integrada com area ampla, Casa Civil, armazem, pickups e BuildingSite | Permite testar NPCs e construcao sem mexer na cena validada |
| `res://scripts/test/npc_wave4_construction_stress_test.gd` | Criado | Especializar o controlador existente com bounds, clamp de destino e configuracao de estresse | Evita NPC sair da plataforma em ordens longas |
| `res://scripts/npc/npc_house.gd` | Alterado | Distribuir spawn em aneis quando houver muitos civis | Reduz sobreposicao no teste com 40 NPCs |
| `res://docs/WAVE_4_NPC_FOUNDATION.md` | Alterado | Registrar a nova cena integrada e o escopo preservado | Evita confundir teste de construcao do jogador com construcao por NPC |
| `res://docs/WAVE_4_CONSTRUCTION_STRESS_TEST_REPORT.md` | Criado | Registrar decisao tecnica, validacoes e pendencias | Facilita aceite e regressao futura |

## 3. Area de movimentacao

| Item | Valor |
| --- | --- |
| Ground visual | `80 x 80` |
| Ground collision | `80 x 80` |
| Limites de movimento | X/Z de `-36` a `36` |
| Margem de seguranca | 4 unidades ate a borda do chao |
| Casa Civil | `(-20, 0, 0)` |
| Armazem/interagivel | `(10, 0, -8)` |
| Construcao/BuildingSite | `(20, 0, 8)` |
| Player | `(0, 0, 20)` |

O comando `Mover` da cena integrada calcula o destino bruto a frente do jogador e aplica `_clamp_move_destination(destination)` antes de emitir `NPCOrder.move_to_position(...)`.

## 4. Integracao com construcao

Foi reaproveitado o sistema ja existente de construcao manual:

| Componente | Reuso |
| --- | --- |
| `res://scripts/building/building_site.gd` | `BuildingSite_Test`, com custo `wood: 20` e `stone: 10` |
| `res://scripts/storage/warehouse.gd` | `Warehouse_Test`, armazem compartilhado |
| `res://scripts/storage/warehouse_interactable.gd` | Deposito manual do inventario do jogador |
| `res://scripts/resources/resource_pickup.gd` | `WoodPickup` e `StonePickup` para obter recursos |
| `res://scripts/inventory/player_inventory.gd` | Inventario do jogador adicionado ao Player da cena |
| `res://scenes/buildings/BuildingVisualState.tscn` | Visual da construcao vinculado ao `BuildingSite_Test` |

Fluxo esperado: jogador interage com `WoodPickup` e `StonePickup`, deposita no `WarehouseInteractable_Test`, interage com `BuildingSite_Test` e progride a construcao. O `ResourceManager` global foi apenas inspecionado; o fluxo reutilizado usa inventario + armazem, como na cena `TestInventoryWarehouse.tscn`.

## 5. Escopo preservado

Nao foi implementado:

| Fora de escopo | Status |
| --- | --- |
| Construcao por NPC | Nao implementado |
| Coleta por NPC | Nao implementado |
| IA/wander | Nao implementado |
| Combate | Nao implementado |
| Inimigos | Nao implementado |
| Economia nova | Nao implementado |
| Mover por clique no chao | Nao implementado |
| Selecao multipla | Nao implementado |
| Fila de ordens | Nao implementado |

## 6. Validacao tecnica

| Teste | Comando/ferramenta | Resultado | Evidencia |
| --- | --- | --- | --- |
| Existencia da cena integrada | `Test-Path .\scenes\test\NPCWave4ConstructionStressTest.tscn` | Passou | Retornou `True` |
| Existencia do script integrado | `Test-Path .\scripts\test\npc_wave4_construction_stress_test.gd` | Passou | Retornou `True` |
| Cena base preservada no disco | `Test-Path .\scenes\test\NPCWave4Test.tscn` | Passou | Retornou `True` |
| Cenas auxiliares existem | `Test-Path` para `NPCHouse`, `NPCCreationMenu`, `NPCCommandMenu`, `Main` | Passou | Todos retornaram `True` |
| Ground/collision 80x80 | `Select-String` na nova cena | Passou | `size = Vector3(80, 0.2, 80)` em mesh e shape |
| Stress de 40 civis | `Select-String` na nova cena | Passou | `max_spawned_npcs = 40` |
| Auto-spawn desligado | `Select-String` na nova cena | Passou | `auto_spawn_npcs_on_ready = 0` |
| Debug keyboard desligado | `Select-String` na nova cena | Passou | `debug_keyboard_commands_enabled = false` |
| Clamp de destino | `Select-String` no script integrado | Passou | `_clamp_move_destination`, `clampf` e `move_to_position` encontrados |
| Godot check da cena base | `Godot --headless --path O:\game --check-only --script res://scripts/test/npc_wave4_test.gd` | Bloqueado | `godot` nao esta no PATH deste ambiente |
| Godot check da cena integrada | `Godot --headless --path O:\game --check-only --script res://scripts/test/npc_wave4_construction_stress_test.gd` | Bloqueado | `godot` nao esta no PATH deste ambiente |
| Load headless da cena base | `Godot --headless --path O:\game res://scenes/test/NPCWave4Test.tscn --quit-after 5` | Bloqueado | `godot` nao esta no PATH deste ambiente |
| Load headless da cena integrada | `Godot --headless --path O:\game res://scenes/test/NPCWave4ConstructionStressTest.tscn --quit-after 5` | Bloqueado | `godot` nao esta no PATH deste ambiente |

## 7. Validacao funcional

| Cenario | Passos | Resultado | Observacao |
| --- | --- | --- | --- |
| Cena base preservada | Abrir `NPCWave4Test.tscn`, criar 1 civil, seguir/mover/parar/dispensar | Pendente manual | Cena base nao foi editada |
| Cena integrada carrega | Abrir `NPCWave4ConstructionStressTest.tscn` | Pendente manual | Validacao headless bloqueada por Godot CLI ausente |
| Criar 40 NPCs | Criar civis pela Casa Civil ate o limite | Pendente manual | Casa configurada com `max_spawned_npcs = 40` |
| Mover NPCs para bordas | Selecionar civis e usar `Mover` olhando para direcoes extremas | Pendente manual | Destino e limitado por X/Z `-36..36` |
| Seguir/parar | Mandar alguns civis seguirem o jogador e parar | Pendente manual | Usa ordens existentes da Wave 4 |
| Construcao pelo jogador | Coletar madeira/pedra, depositar, interagir com BuildingSite | Pendente manual | Sistema existente foi reutilizado |
| Interacao com Warehouse/BuildingSite | Criar varios NPCs e interagir com os objetos de construcao | Pendente manual | Se houver bloqueio fisico, registrar como ajuste de colisao/layout |
| Ausencia de erro vermelho | Executar cenas no editor | Pendente manual | Necessita Godot Editor/CLI |

## 8. Performance

| Ponto analisado | Custo esperado | Risco | Observacao para 40+ entidades |
| --- | --- | --- | --- |
| NPCBase com fallback direto | Medio | CPU/fisica aumenta linearmente | Sem pathfinding complexo nesta cena |
| Menus de NPC | Baixo | Baixo | Apenas um menu contextual ativo |
| Spawn de 40 civis | Medio | Sobreposicao/fisica | Spawn em aneis reduz empilhamento inicial |
| Raycast de interacao | Baixo | Interferencia por corpos proximos | Validar manualmente com NPCs seguindo o jogador |
| BuildingSite/Warehouse | Baixo | Baixo | So reage a interacao do jogador |

## 9. Riscos restantes

| Categoria | Risco |
| --- | --- |
| Tecnico | Godot CLI nao foi executado neste ambiente, entao parse/carregamento real ainda precisa ser confirmado |
| Gameplay | 40 civis sem selecao multipla ainda exigem teste manual individual ou auto-spawn tecnico |
| Fisica/colisao | NPCs seguindo o jogador podem entrar na frente do raycast para Warehouse/BuildingSite |
| Performance | 40 entidades devem ser aceitaveis para estresse inicial, mas 40+ precisa medicao real de FPS |
| UI/input | Menus de criacao/comando e HUDs coexistem na cena; validar restauracao do mouse no editor |

## 10. Pendencias fora de escopo

- Criar `NavigationRegion3D`/navmesh real para movimento robusto.
- Implementar escolha de ponto no chao para `Mover`.
- Avaliar colisao/layers para impedir NPCs de bloquear totalmente interacoes do jogador.
- Medir FPS real com 40 e depois 40+ entidades.
- Implementar coleta/construcao por NPC apenas em wave futura propria.

## 11. Decisao final

APROVADO COM RESSALVAS.

Tecnicamente, a cena integrada foi criada pelo menor caminho seguro, reutilizando os sistemas existentes e preservando `NPCWave4Test.tscn`. A ressalva e objetiva: a validacao Godot headless e os testes manuais no editor ainda precisam ser executados em um ambiente onde o binario `Godot` esteja disponivel no PATH ou informado por caminho absoluto.
