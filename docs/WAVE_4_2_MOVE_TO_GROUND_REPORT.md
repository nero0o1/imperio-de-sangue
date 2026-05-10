# Relatorio Tecnico - Wave 4.2 Mover por Ponto no Chao

## 1. Resumo executivo

Foi implementado o comando `Mover` por ponto no chao na cena integrada `res://scenes/test/NPCWave4ConstructionStressTest.tscn`.

O fluxo agora e: selecionar NPC, abrir menu contextual, clicar em `Mover`, mirar no chao e pressionar `E`. A cena faz raycast fisico a partir da camera do jogador, aceita apenas o Ground da arena, aplica clamp nos bounds seguros `-36..36` em X/Z e emite `NPCOrder.move_to_position(destination, player)`.

A cena base `NPCWave4Test.tscn` foi preservada com o comportamento provisorio antigo do botao `Mover`.

## 2. Arquivos alterados

| Arquivo | Alteracao | Motivo |
| --- | --- | --- |
| `res://scripts/test/npc_wave4_construction_stress_test.gd` | Adicionado modo de escolha de destino, raycast de chao, validacao, clamp, confirmacao com `E` e cancelamento com `Esc`. | Implementar Wave 4.2 na cena integrada sem criar sistema novo. |
| `res://scripts/player/player.gd` | Adicionado gancho `try_consume_player_interact` na cena atual antes do raycast normal de interacao. | Permitir que a cena integrada consuma `E` durante escolha de destino, sem quebrar interacoes nas outras cenas. |
| `res://scenes/test/NPCWave4ConstructionStressTest.tscn` | Ground adicionado ao grupo `movement_ground`. | Identificar destino valido para movimento sem mexer em physics layers. |
| `res://docs/WAVE_4_NPC_FOUNDATION.md` | Documentado fluxo da Wave 4.2 e escopo preservado. | Manter a documentacao da Wave 4 coerente. |
| `res://docs/WAVE_4_2_MOVE_TO_GROUND_REPORT.md` | Criado este relatorio. | Registrar implementacao, validacao e pendencias. |

## 3. Fluxo antes vs depois

| Estado | Antes | Depois |
| --- | --- | --- |
| `NPCWave4Test.tscn` | `Mover` mandava o NPC andar alguns metros a frente. | Preservado. |
| `NPCWave4ConstructionStressTest.tscn` | `Mover` mandava o NPC andar alguns metros a frente, com clamp. | `Mover` entra em modo de escolha de ponto no chao, confirma com `E` e aplica clamp. |
| Destino invalido | Nao havia escolha manual de destino. | Nao emite ordem; mantem o modo ativo para nova tentativa. |
| Cancelamento | Nao aplicavel. | `Esc` cancela sem emitir ordem. |

## 4. Implementacao tecnica

- Estado novo na cena integrada: `_awaiting_move_destination` e `_move_destination_npc`.
- O sinal `move_requested` do menu e tratado pela cena integrada via override de `_on_menu_move_requested(...)`.
- Ao entrar no modo de destino, o menu contextual fecha e o mouse volta para camera capturada.
- O `Player` consulta a cena atual antes de executar o raycast normal de `interact`; isso evita que `E` selecione NPC/casa/armazem enquanto o jogador esta confirmando destino.
- O raycast usa a camera do jogador e `PhysicsRayQueryParameters3D`.
- O raycast exclui o Player e o NPC comandado.
- Destino valido exige collider no grupo `movement_ground` ou nome contendo `Ground`.
- `_clamp_move_destination(...)` continua limitando X/Z dentro de `movement_bounds_min/max`.

## 5. Escopo preservado

Nao foi implementado:

- pathfinding/navmesh;
- IA/wander;
- inimigos;
- combate;
- construcao por NPC;
- coleta por NPC;
- mover por clique no chao;
- selecao multipla;
- fila de ordens;
- economia nova.

`Warehouse`, `BuildingSite`, `ResourceManager` e regras de construcao nao foram reescritos.

## 6. Validacao CLI/headless

| Comando | Resultado | Evidencia |
| --- | --- | --- |
| `Godot --headless --path O:\game --check-only --script res://scripts/test/npc_wave4_construction_stress_test.gd` | Passou | Exit code 0. |
| `Godot --headless --path O:\game --check-only --script res://scripts/test/npc_wave4_test.gd` | Passou | Exit code 0. |
| `Godot --headless --path O:\game --check-only --script res://scripts/player/player.gd` | Passou | Exit code 0. |
| `Godot --headless --path O:\game res://scenes/test/NPCWave4ConstructionStressTest.tscn --quit-after 5` | Passou | Exit code 0; logs de Casa Civil limite 40, debug desligado, bounds `(-36,-36)..(36,36)` e auto-spawn 0. |
| `Godot --headless --path O:\game res://scenes/test/NPCWave4Test.tscn --quit-after 5` | Passou | Exit code 0; logs de Casa Civil limite 3 e debug desligado. |

## 7. Testes manuais necessarios

| Teste | Passos | Esperado |
| --- | --- | --- |
| A - Cena integrada sem NPCs | Abrir e executar `NPCWave4ConstructionStressTest.tscn`. | Player, camera, construcao e menus funcionam sem erro vermelho. |
| B - Criar 1 civil | Interagir com Casa Civil e criar 1 civil. | Civil nasce e pode ser selecionado. |
| C - Mover por ponto no chao | Selecionar civil, clicar `Mover`, mirar no Ground e pressionar `E`. | NPC recebe `MOVE_TO_POSITION` e anda ate o ponto. |
| D - Destino invalido | Clicar `Mover`, mirar em NPC/casa/armazem/BuildingSite e pressionar `E`. | Ordem nao e emitida; modo continua ativo. |
| E - Cancelamento | Clicar `Mover` e pressionar `Esc`. | Modo cancela; NPC nao recebe ordem. |
| F - Bounds | Mirar perto da borda e confirmar. | Destino fica dentro de `-36..36` em X/Z. |
| G - Construcao depois do mover | Mover NPC, depois coletar/depositar/construir. | Fluxo de construcao do jogador continua funcionando. |

## 8. Riscos restantes

| Risco | Observacao |
| --- | --- |
| Raycast em objeto na frente do chao | Intencional: objetos nao sao aceitos como chao; jogador deve mirar no Ground. |
| Movimento direto sem desvio | Continua usando fallback direto, sem navmesh. |
| Cena base ainda usa mover provisorio | Preservado de proposito para nao alterar a cena validada. |
| Confirmacao visual pendente | Headless valida scripts/cenas, mas nao confirma camera/mouse/mira no editor. |

## 9. Pendencias fora de escopo

- Indicador visual de destino.
- Pathfinding com `NavigationRegion3D`.
- Clique no chao para mover.
- Selecao multipla.
- Fila de ordens.
- IA/wander.
- Construcao/coleta por NPC.
- Teste de estresse com 20/40 NPCs.

## 10. Decisao final

APROVADO COM RESSALVAS.

Justificativa: scripts e cenas passam em headless, e a implementacao ficou limitada ao fluxo de destino por `E` na cena integrada. A aprovacao completa depende do teste manual no editor confirmando mouse/camera, destino valido/invalido, cancelamento e construcao apos mover.
