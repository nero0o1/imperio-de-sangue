# Wave 4.6.1A - Correcao de parser e populacao

## Resumo

Este hotfix corrige o erro vermelho de parser em `npc_house.gd` causado pela dependencia direta do tipo global `PopulationManager`. A casa civil agora resolve o gerenciador por contrato de metodos, sem depender do nome de classe no escopo do script. A mesma protecao foi aplicada nos pontos auxiliares que consultavam populacao para evitar regressao semelhante no HUD e no controlador de construcao.

## Causa do erro

`scripts/npc/npc_house.gd` declarava variavel e retorno com o tipo nominal `PopulationManager`. Quando o editor nao resolvia esse `class_name` no escopo atual, o parser marcava o script com:

`Could not find type "PopulationManager" in the current scope.`

O hotfix remove a dependencia nominal em `NPCHouse` e passa a aceitar qualquer `Node` que cumpra o contrato minimo de populacao.

## Arquivos alterados

- `scripts/npc/npc_house.gd`
- `scripts/core/population_manager.gd`
- `scripts/ui/hud/game_hud.gd`
- `scripts/test/build_placement_controller.gd`
- `scripts/test/npc_wave4_construction_stress_test.gd`
- `scenes/test/NPCWave4ConstructionStressTest.tscn`
- `scenes/test/NPCWave4OrderIntegrationTest.tscn`
- `scenes/buildings/BuildableCivilHouse.tscn`
- `docs/WAVE_4_6_1A_PARSER_POPULATION_FIX.md`

## Tipo nominal ou contrato

Foi usada validacao por contrato. Para uma casa civil, o gerenciador de populacao e considerado valido quando o node possui:

- `register_house`
- `can_spawn`
- `try_reserve_population`
- `release_population`

O HUD usa contrato menor, exigindo `get_status_text`, porque apenas exibe o estado de populacao.

## Populacao +10 por casa

- `scripts/core/population_manager.gd`: `capacity_per_house = 10`.
- `scripts/npc/npc_house.gd`: `population_capacity_bonus = 10`.
- Cenas de teste atualizadas de `capacity_per_house = 5` para `10`.
- `BuildableCivilHouse` e o teste de stress usam limite local `10` apenas como protecao secundaria. A fonte de verdade continua sendo o `PopulationManager` global.

Resultado esperado:

- 1 casa civil concluida adiciona +10 de capacidade global.
- 2 casas civis concluidas adicionam +20 de capacidade global.
- A casa nao deve estabelecer +40 de capacidade por unidade.

## Cenas validadas

| Cena | PopulationManager | BuildPlacementController | BuildMenu | H/build_mode | Uso recomendado |
| --- | --- | --- | --- | --- | --- |
| `scenes/test/NPCWave4ConstructionStressTest.tscn` | Sim | Sim | Sim | Sim, via acao `build_mode` na tecla H | Laboratorio jogavel de construcao, armazem, casa e populacao |
| `scenes/test/NPCWave4OrderIntegrationTest.tscn` | Sim | Nao | Nao | Nao nesta cena | Laboratorio de ordens/NPC, nao e cena de teste do modo construcao |
| `scenes/main/Main.tscn` | Nao | Nao | Nao | Nao nesta cena | Cena base simples do prototipo, fora do escopo atual de validacao de H |

O modo H fica funcional na cena `NPCWave4ConstructionStressTest`, que contem o `BuildPlacementController` e o `BuildMenu`. `NPCWave4OrderIntegrationTest` nao recebeu menu/controlador neste hotfix para manter a cena focada em ordens e evitar ampliar o escopo.

## Logs de BuildMode

`BuildPlacementController` agora registra:

- `[BuildMode] H pressionado`
- `[BuildMode] menu de construção aberto`
- `[BuildMode] construção selecionada: Casa Civil`
- `[BuildMode] construção selecionada: Armazém`
- `[BuildMode] preview válido`
- `[BuildMode] preview inválido: <motivo>`
- `[BuildMode] construção criada`
- `[BuildMode] construção bloqueada: <motivo>`

Se `[BuildMode] H pressionado` nao aparecer ao pressionar H na cena de construcao, o input nao chegou ao controller.

## Testes executados

- `git diff --check`: passou. Foram exibidos apenas avisos de conversao LF/CRLF do Git.
- Busca textual por `is/as/:/-> PopulationManager` nos scripts e por configuracoes antigas `capacity_per_house = 5`, `population_capacity_bonus = 5` e `max_spawned_npcs = 40`: passou sem ocorrencias relevantes.
- `Godot_v4.6.2-stable_win64.exe --headless --path . --quit`: passou.
- `Godot_v4.6.2-stable_win64.exe --headless --path . --quit-after 2 res://scenes/test/NPCWave4ConstructionStressTest.tscn`: passou.
- `Godot_v4.6.2-stable_win64.exe --headless --path . --quit-after 2 res://scenes/test/NPCWave4OrderIntegrationTest.tscn`: passou.
- Abertura grafica curta de `NPCWave4ConstructionStressTest`: passou.
- Abertura grafica curta de `NPCWave4OrderIntegrationTest`: passou.
- Teste interativo com `Godot_v4.6.2-stable_win64_console.exe` em `NPCWave4ConstructionStressTest`: H chegou ao controller e registrou `[BuildMode] H pressionado`; o menu abriu, a Casa Civil foi selecionada, a construcao foi criada e a casa concluida registrou capacidade global adicional de +10.

## Pendencias restantes

- Se a equipe decidir que `NPCWave4OrderIntegrationTest` tambem deve validar construcao, adicionar `BuildPlacementController` e `BuildMenu` nessa cena em uma alteracao propria.
