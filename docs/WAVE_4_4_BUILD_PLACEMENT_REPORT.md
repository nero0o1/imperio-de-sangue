# Relatorio Tecnico - Wave 4.4 Posicionamento Validado de Construcao

## 1. Resumo executivo

A Wave 4.4 implementa o modo de posicionamento livre da Casa Civil construivel na cena integrada `NPCWave4ConstructionStressTest.tscn`.

O jogador entra no modo com `B`, mira no chao, ve um preview transparente da pegada da casa, gira com `R`, confirma com `E` e cancela com `Esc`. A confirmacao so instancia a casa quando o local esta valido. Locais sem chao valido, fora dos bounds, sobrepostos a objetos existentes ou dentro de margens minimas simples permanecem vermelhos e bloqueados.

## 2. Arquivos alterados/criados

Criados:

- `res://scripts/building/building_placement_preview.gd`
- `res://scripts/test/build_placement_controller.gd`
- `res://scenes/buildings/BuildableCivilHouse.tscn`
- `res://docs/WAVE_4_4_BUILD_PLACEMENT_REPORT.md`

Alterados:

- `res://scenes/test/NPCWave4ConstructionStressTest.tscn`
- `res://scripts/test/npc_wave4_construction_stress_test.gd`
- `res://docs/WAVE_4_NPC_FOUNDATION.md`
- `res://project.godot`

## 3. Fluxo antes vs depois

Antes:

- A cena integrada tinha um `BuildingSite` fixo para a Casa Civil.
- A Casa Civil era habilitada pelo `BuildableCivilHouseController` quando o canteiro fixo terminava.
- O jogador nao escolhia onde construir a casa.

Depois:

- A cena integrada inicia sem Casa Civil fixa.
- `BuildPlacementController` cria um preview temporario e valida o local mirado.
- `E` durante placement instancia `BuildableCivilHouse.tscn` somente se o preview estiver valido.
- O prefab instanciado preserva o fluxo Wave 4.3: `BuildingSite` ativo, `NPCHouse` bloqueada e `BuildableCivilHouseController` liberando criacao apos conclusao.

## 4. Implementacao tecnica

- `BuildingPlacementPreview` e um `Node3D` com `MeshInstance3D` simples, material verde transparente para valido e vermelho transparente para invalido.
- `BuildPlacementController` usa o raycast da camera do jogador para encontrar o ponto do chao.
- A validacao de bounds bloqueia fora de `Vector2(-36, -36)` ate `Vector2(36, 36)`, sem clamp silencioso.
- A validacao de footprint usa `PhysicsDirectSpaceState3D.intersect_shape(...)` com `BoxShape3D` de `Vector3(4, 2, 4)`.
- A confirmacao reaproveita o gancho existente `try_consume_player_interact(...)`, chamado pelo `Player` antes do raycast normal de interacao.
- `BuildableCivilHouse.tscn` concentra `BuildingSite`, `NPCHouse`, `BuildingVisualState` e `BuildableCivilHouseController` para evitar duplicacao futura.

## 5. Regras de validade do placement

| Regra | Como valida | O que bloqueia | Evidencia |
|---|---|---|---|
| Chao valido | `intersect_ray` da camera ate `placement_distance`; aceita collider em `movement_ground` ou nome contendo `Ground` | Sem hit, posicao nao finita, collider que nao e chao | Motivo `sem_chao_valido`; preview vermelho; `E` nao instancia |
| Bounds | Compara X/Z com `movement_bounds_min` e `movement_bounds_max` | Qualquer ponto fora de `-36..36` em X/Z | Motivo `fora_dos_bounds`; sem clamp silencioso |
| Footprint | `intersect_shape` imediato com `BoxShape3D` `4x2x4` no transform do preview | Player, NPCs, `NPCHouse`, `BuildingSite`, Warehouse, pickups e qualquer corpo/area nao-ground | Motivo `sobrepondo <nome>`; apenas preview e ground sao ignorados |
| Margem minima | Distancia horizontal simples contra player e casas no grupo `npc_house` | Construir muito perto do jogador ou de casas existentes | Motivos `muito_perto_do_player` e `muito_perto_de <nome>` |
| Estado de confirmacao | `try_confirm_placement()` chama `_update_current_target()` antes de instanciar | Qualquer motivo invalido atual | Log `[BUILD] Nao foi possivel posicionar Casa Civil: <motivo>.` |

## 6. Escopo preservado

Nao foi implementado:

- Grid completo.
- Varios edificios.
- Construcao por NPC.
- Demolicao.
- Economia nova.
- Save/load.
- Pathfinding.
- Inimigos.
- Combate.

Tambem nao foram reescritos `BuildingSite`, `NPCHouse`, `Warehouse`, menus ou mapa base.

## 7. Validacao CLI/headless

Godot usado:

- `O:\Games\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64_console.exe`
- Versao reportada: `Godot Engine v4.6.2.stable.official.71f334935`

| Comando | Resultado | Evidencia |
|---|---|---|
| `Godot --headless --path O:\game --check-only --script res://scripts/test/build_placement_controller.gd` | Passou | `EXIT=0` |
| `Godot --headless --path O:\game --check-only --script res://scripts/building/building_placement_preview.gd` | Passou | `EXIT=0` |
| `Godot --headless --path O:\game --check-only --script res://scripts/test/buildable_civil_house_controller.gd` | Passou | `EXIT=0` |
| `Godot --headless --path O:\game --check-only --script res://scripts/test/npc_wave4_construction_stress_test.gd` | Passou | `EXIT=0` |
| `Godot --headless --path O:\game --check-only --script res://scripts/building/building_site.gd` | Passou | `EXIT=0` |
| `Godot --headless --path O:\game --check-only --script res://scripts/npc/npc_house.gd` | Passou | `EXIT=0` |
| `Godot --headless --path O:\game --check-only --script res://scripts/player/player.gd` | Passou | `EXIT=0` |
| `Godot --headless --path O:\game res://scenes/test/NPCWave4ConstructionStressTest.tscn --quit-after 5` | Passou | Cena carregou e logou ready da cena integrada |
| `Godot --headless --path O:\game res://scenes/test/NPCWave4Test.tscn --quit-after 5` | Passou | Cena base carregou e logou ready da Wave 4 |

## 8. Testes manuais necessarios

- Teste A - Entrar e cancelar placement: pressionar `B`, confirmar preview, pressionar `Esc`, validar que nada e criado.
- Teste B - Local valido: mirar em chao livre, preview verde, pressionar `E`, validar nascimento do `BuildingSite`.
- Teste C - Fora dos bounds: mirar na borda/fora da arena, preview vermelho, `E` nao cria nada.
- Teste D - Sobre Warehouse: mirar/posicionar sobre o armazem, preview vermelho, `E` nao cria nada.
- Teste E - Sobre BuildingSite existente: criar uma casa, tentar criar outra sobre a primeira, preview vermelho.
- Teste F - Sobre NPC: criar civil, tentar posicionar casa sobre o civil, preview vermelho.
- Teste G - Rotacao: pressionar `R` varias vezes e confirmar passos de 90 graus.
- Teste H - Construcao depois do placement: posicionar, coletar/depositar recursos, construir, interagir com casa pronta e criar civil.
- Teste I - Regressao da cena base: abrir `NPCWave4Test.tscn`, criar civil pela casa base e testar comandos basicos.

## 9. Riscos restantes

Raycast:

- Mirar diretamente em objetos solidos pode invalidar por `sem_chao_valido` antes da camada de footprint. O bloqueio esta correto, mas o motivo pode ser menos especifico que `sobrepondo`.

Footprint:

- A pegada e uma caixa aproximada `4x2x4`, nao uma forma exata do modelo final.

Colisao:

- A regra bloqueia qualquer corpo/area nao-ground. E conservadora e segura para a Wave 4.4, mas pode exigir mascaras/camadas quando houver mais tipos de objeto decorativo.

UI/input:

- Placement usa `B`, `R`, `E` e `Esc` sem UI dedicada. O fluxo e propositalmente minimo.

Multiplas construcoes:

- Multiplas Casas Civis sao permitidas se cada local passar na validacao. Nao ha limite global nesta wave.

Performance:

- `intersect_shape` roda durante placement para um unico preview. O custo e aceitavel no escopo atual.

## 10. Pendencias fora de escopo

- UI de lista de edificios.
- Snapping/grid.
- Mascara dedicada de colisao para placement.
- Preview com asset final.
- Custo/limite para iniciar placement.
- Persistencia de construcoes.
- Construtor NPC automatico.
- Regras globais de populacao.
- Integracao com pathfinding/navmesh.

## 11. Decisao final

APROVADO COM RESSALVAS.

Motivo: todos os checks CLI/headless obrigatorios passaram e a cena integrada carrega sem erro. A aprovacao final visual ainda depende dos testes manuais A-I, principalmente confirmacao de cor do preview, rotacao percebida em jogo e bloqueios sobre Warehouse, BuildingSite e NPC.
