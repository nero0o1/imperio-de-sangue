# Relatorio Tecnico - Wave 4.4.1 Menu de Construcao e Armazem

## 1. Resumo executivo

A Wave 4.4.1 transforma o placement validado da Casa Civil em um fluxo de construcao por catalogo simples. `H` abre o menu `Construir`, o jogador escolhe `Armazem` ou `Casa Civil`, e a construcao selecionada entra no mesmo modo de posicionamento validado ja existente.

O fluxo preserva a regra principal: verde permite, vermelho bloqueia. `E` deixou de confirmar construcao e voltou a ser apenas interacao normal; `build_confirm` foi criado em `Enter`.

## 2. Arquivos alterados/criados

Criados:

- `res://scripts/ui/build_menu.gd`
- `res://scenes/ui/BuildMenu.tscn`
- `res://scripts/test/buildable_warehouse_controller.gd`
- `res://scenes/buildings/BuildableWarehouse.tscn`
- `res://docs/WAVE_4_4_1_BUILD_MENU_AND_WAREHOUSE_REPORT.md`

Alterados:

- `res://scripts/test/build_placement_controller.gd`
- `res://scripts/test/npc_wave4_construction_stress_test.gd`
- `res://scripts/building/building_site.gd`
- `res://scripts/building/building_resource_consumer.gd`
- `res://scenes/buildings/BuildableCivilHouse.tscn`
- `res://scenes/test/NPCWave4ConstructionStressTest.tscn`
- `res://docs/WAVE_4_NPC_FOUNDATION.md`
- `res://project.godot`

## 3. Fluxo antes vs depois

Antes:

- `B` entrava diretamente no placement da Casa Civil.
- `E` confirmava construcao durante placement.
- A cena integrada dependia de armazem fixo para o loop principal de recursos.

Depois:

- `H` abre `BuildMenu`.
- O menu bloqueia gameplay input enquanto esta visivel.
- Escolher `Armazem` ou `Casa Civil` fecha o menu e inicia o placement validado.
- `R` gira o preview.
- `Enter` confirma a construcao se o local estiver valido.
- `Esc` cancela menu ou placement.
- `E` permanece reservado para interacao normal.
- A cena integrada inicia sem armazem/casa funcionais fixos.

## 4. Controles

| Acao | Input | Uso |
| --- | --- | --- |
| `build_mode` | `H` | Abrir menu de construcao |
| `rotate_building` | `R` | Girar preview em placement |
| `build_confirm` | `Enter` | Confirmar construcao valida |
| `ui_cancel` | `Esc` | Fechar menu ou cancelar placement |
| `interact` | `E` | Interacao normal do jogador |

## 5. Catalogo de construcoes

O catalogo ficou minimo e direto no `BuildPlacementController`:

| Building id | Cena | Footprint | Resultado |
| --- | --- | --- | --- |
| `warehouse` | `BuildableWarehouse.tscn` | `warehouse_footprint_size` | BuildingSite de Armazem |
| `civil_house` | `BuildableCivilHouse.tscn` | `civil_house_footprint_size` | BuildingSite de Casa Civil |

## 6. Regras de custo por construcao

| Construcao | Politica | Como consome |
| --- | --- | --- |
| Armazem | `INVENTORY_ONLY` / `PLAYER_ONLY` | Usa apenas `PlayerInventory` |
| Casa Civil | `WAREHOUSE_THEN_INVENTORY` / `WAREHOUSE_THEN_PLAYER` | Tenta `Warehouse`; se a etapa inteira nao couber, tenta `PlayerInventory` |

Nao foi implementado consumo dividido entre armazem e inventario no `BuildingSite`. A fallback atual exige que uma fonte consiga pagar a etapa completa, o que e menor e mais previsivel nesta etapa.

## 7. Regras de validade do placement

| Regra | Como valida | O que bloqueia | Evidencia |
| --- | --- | --- | --- |
| Chao valido | Raycast da camera com `PhysicsRayQueryParameters3D` | Sem hit, posicao invalida, collider fora de `movement_ground`/`Ground` | `build_placement_controller.gd` retorna `sem_chao_valido` |
| Bounds | Comparacao direta X/Z contra `-36..36` | Posicao fora da arena segura | Retorna `fora_dos_bounds`; nao usa clamp |
| Footprint | `PhysicsDirectSpaceState3D.intersect_shape(...)` com `BoxShape3D` | Player, NPC, Warehouse, WarehouseInteractable, BuildingSite, NPCHouse, ResourcePickup e qualquer corpo/area nao-ground | Retorna `sobrepondo <node>` |
| Margem minima | Distancia horizontal simples | Muito perto do player ou casas existentes | Retorna `muito_perto_do_player` ou `muito_perto_de <node>` |
| Confirmacao | `try_confirm_placement()` revalida antes de instanciar | Preview vermelho nao cria nada | Log `[BUILD] Nao foi possivel posicionar...` |

## 8. Escopo preservado

Nao foi implementado:

- grid completo;
- edificios alem de Armazem e Casa Civil;
- limite de inventario;
- limite de armazem;
- economia nova;
- construcao por NPC;
- coleta por NPC;
- soldado;
- inimigos;
- combate;
- save/load;
- demolicao;
- reparo;
- selecao multipla;
- fila de ordens;
- navmesh/pathfinding.

## 9. Validacao CLI/headless

| Comando | Resultado | Evidencia |
| --- | --- | --- |
| `Godot --headless --path O:\game --check-only --script res://scripts/test/build_placement_controller.gd` | PASS | Exit code 0 |
| `Godot --headless --path O:\game --check-only --script res://scripts/building/building_placement_preview.gd` | PASS | Exit code 0 |
| `Godot --headless --path O:\game --check-only --script res://scripts/test/buildable_civil_house_controller.gd` | PASS | Exit code 0 |
| `Godot --headless --path O:\game --check-only --script res://scripts/test/npc_wave4_construction_stress_test.gd` | PASS | Exit code 0 |
| `Godot --headless --path O:\game --check-only --script res://scripts/building/building_site.gd` | PASS | Exit code 0 |
| `Godot --headless --path O:\game --check-only --script res://scripts/npc/npc_house.gd` | PASS | Exit code 0 |
| `Godot --headless --path O:\game --check-only --script res://scripts/player/player.gd` | PASS | Exit code 0 |
| `Godot --headless --path O:\game --check-only --script res://scripts/ui/build_menu.gd` | PASS | Exit code 0 |
| `Godot --headless --path O:\game --check-only --script res://scripts/test/buildable_warehouse_controller.gd` | PASS | Exit code 0 |
| `Godot --headless --path O:\game --check-only --script res://scripts/building/building_resource_consumer.gd` | PASS | Exit code 0 |
| `Godot --headless --path O:\game res://scenes/test/NPCWave4ConstructionStressTest.tscn --quit-after 5` | PASS | Exit code 0, cena integrada carregou |
| `Godot --headless --path O:\game res://scenes/test/NPCWave4Test.tscn --quit-after 5` | PASS | Exit code 0, cena base carregou |

## 10. Testes manuais necessarios

- Teste A: `H` abre menu de construcao, mostra Armazem/Casa Civil e bloqueia `E` de interagir enquanto menu esta aberto.
- Teste B: Armazem em local valido cria BuildingSite no ponto escolhido.
- Teste C: Armazem em pickup, player, borda ou objeto existente fica vermelho e nao constroi.
- Teste D: Armazem consome inventario, conclui e passa a aceitar deposito/interacao.
- Teste E: Casa Civil usa recursos do Armazem quando disponiveis.
- Teste F: Casa Civil tambem pode progredir usando inventario.
- Teste G: Casa concluida cria civil e preserva seguir, parar e mover por ponto no chao.
- Teste H: Cena base `NPCWave4Test.tscn` continua criando e comandando civil.

## 11. Riscos restantes

Raycast:

- Mirar diretamente em objetos solidos pode impedir o hit no chao e deixar o local invalido. Isso e conservador e bloqueia a construcao.

Footprint:

- A caixa e aproximada e nao representa asset final. Predios futuros podem precisar de footprint por recurso/dado.

Colisao:

- A consulta bloqueia qualquer corpo/area nao-ground. Isso reduz falsos positivos de construcao, mas pode exigir camadas especificas depois.

UI/input:

- `Enter` e seguro para prototipo. Mouse esquerdo nao foi usado para evitar conflito com ataque.

Multiplas construcoes:

- Casa Civil procura o primeiro `Warehouse` existente quando nao ha `warehouse_path` explicito. Multiplos armazens podem precisar de criterio por proximidade.

Performance:

- `intersect_shape` por frame e aceitavel para um unico preview; nao deve ser replicado em massa sem revisao.

## 12. Pendencias fora de escopo

- Capacidade do armazem.
- UI de estoque por armazem construido.
- Custo/limite de criacao de civil.
- Construtor/coletor automatico.
- Escolha de armazem por proximidade.
- Dados de catalogo em `Resource`.
- Grid, snapping e pathfinding.

## 13. Decisao final

APROVADO COM RESSALVAS.

Motivo: validacao CLI/headless passou e a cena base carregou sem regressao. Os testes manuais visuais A-H ainda precisam ser executados no editor/jogo para confirmar o comportamento perceptivo do preview, menu, bloqueio de input e loop completo de recursos.
