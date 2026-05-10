# Wave 4 - NPC Foundation

## Objetivo da wave

Criar a fundacao tecnica dos primeiros NPCs sistemicos do prototipo, com uma base simples para civis, soldados e hostis futuros sem implementar combate, economia nova ou automacao de trabalho.

## Contexto resumido

O prototipo atual ja possui jogador em primeira pessoa, interacao por raycast, coleta manual, armazem compartilhado, construcao basica, `ResourceManager`, `WaveManager`, HUDs e cenas de teste. A Wave 4 adiciona NPCs como pecas sistemicas do loop futuro: civis poderao trabalhar, depositar recursos, construir, virar soldados e pressionar decisoes entre economia e defesa em waves posteriores.

## Escopo implementado

- Enums para role, faction, state e order type.
- Objeto `NPCOrder` com tipo, posicao alvo, node alvo, emissor, timestamp e validacao.
- `NPCBase` como `CharacterBody3D`.
- NPC civil generico com role/faction/state.
- Estado inicial `IDLE`.
- Selecao individual via `select()`, `deselect()` e `interact(actor)`.
- Feedback visual simples de selecao.
- Ordem `MOVE_TO_POSITION`.
- Ordem `FOLLOW_PLAYER`.
- Ordem `STOP`.
- Substituicao da ordem anterior por nova ordem.
- Logs com prefixo `[NPC]`.
- Cena isolada `NPCWave4Test.tscn` iniciando sem civis posicionados diretamente.
- Casa simples de criacao de civis (`NPCHouse`) com limite simples de 3 civis.
- Menu simples de criacao (`NPCCreationMenu`) com acao `Criar Civil` e fechamento/cancelamento.
- Spawn de civil proximo da casa, conectado ao sistema de selecao e ao menu contextual de comandos.
- Menu contextual simples para comandar o NPC selecionado/interagido.
- Teclas temporarias mantidas apenas como fallback/debug opcional na cena de teste, desativadas por padrao.
- Correcao da cena de teste para iniciar sem NPC selecionado automaticamente.
- Cena integrada `NPCWave4ConstructionStressTest.tscn` para validar Wave 4 em area ampla junto do fluxo existente de coleta, armazem e construcao pelo jogador.
- Limite seguro de destino no comando `Mover` da cena integrada, mantendo os civis dentro da area util de teste.
- Casa Civil configuravel para teste de estresse com ate 40 civis na cena integrada.
- Wave 4.2 na cena integrada: botao `Mover` entra em modo de escolha de ponto no chao, confirma com `E`, valida `movement_ground`, aplica clamp nos bounds seguros e emite `NPCOrder.move_to_position(...)`.
- Wave 4.3 na cena integrada: Casa Civil deixa de iniciar funcional separada e passa a ser habilitada pela conclusao do `BuildingSite` existente.
- Adaptador pequeno `BuildableCivilHouseController` conecta um `BuildingSite` especifico a uma `NPCHouse` especifica, sem duplicar construcao, menu ou sistema de spawn.
- Wave 4.4 na cena integrada: Casa Civil construivel passa a ser posicionada livremente pelo jogador com preview transparente, rotacao em passos de 90 graus e validacao real antes de instanciar o `BuildingSite`.
- Placement da Casa Civil valida raycast no `movement_ground`, bounds seguros, sobreposicao por `PhysicsDirectSpaceState3D.intersect_shape(...)` e margem minima simples contra player/casas existentes.
- Wave 4.4.1 na cena integrada: `H` abre o menu `Construir`, permitindo escolher `Armazem` ou `Casa Civil` antes de entrar no placement validado existente.
- Wave 4.4.1 preserva `E` como interacao normal e usa `build_confirm` (`Enter`) para confirmar construcao durante placement.
- Armazem construivel usa recursos do `PlayerInventory`; Casa Civil construivel tenta usar `Warehouse` e depois `PlayerInventory`.

## Escopo nao implementado

- Combate.
- Dano.
- Inimigos.
- Ondas novas.
- Coleta real por NPC.
- Construcao real por NPC.
- Reparo real por NPC.
- Treinamento de soldado.
- Sistema de populacao.
- Save/load de NPC.
- Dialogo.
- Som.
- Magia.
- Animacao complexa.
- Arvore comportamental avancada.
- Selecao multipla.
- Fila de ordens.
- Formacao militar.
- Patrulha avancada.
- Economia nova.
- Construcao por NPC na cena integrada de estresse.
- Coleta automatica por NPC na cena integrada de estresse.
- Mover por clique no chao.
- Grid completo de construcao.
- Catalogo amplo de edificios construiveis alem de Armazem e Casa Civil.
- Demolicao.
- Save/load de construcoes posicionadas.

## Arquivos criados

- `scripts/npc/npc_enums.gd`
- `scripts/npc/npc_order.gd`
- `scripts/npc/npc_base.gd`
- `scripts/ui/npc_command_menu.gd`
- `scripts/ui/npc_creation_menu.gd`
- `scripts/npc/npc_house.gd`
- `scripts/test/npc_wave4_test.gd`
- `scenes/npc/NPCBase.tscn`
- `scenes/npc/NPCHouse.tscn`
- `scenes/ui/NPCCommandMenu.tscn`
- `scenes/ui/NPCCreationMenu.tscn`
- `scenes/test/NPCWave4Test.tscn`
- `docs/WAVE_4_NPC_FOUNDATION.md`
- `scripts/test/npc_wave4_construction_stress_test.gd`
- `scenes/test/NPCWave4ConstructionStressTest.tscn`
- `docs/WAVE_4_CONSTRUCTION_STRESS_TEST_REPORT.md`
- `scripts/test/buildable_civil_house_controller.gd`
- `docs/WAVE_4_3_BUILDABLE_CIVIL_HOUSE_REPORT.md`
- `scripts/building/building_placement_preview.gd`
- `scripts/test/build_placement_controller.gd`
- `scenes/buildings/BuildableCivilHouse.tscn`
- `docs/WAVE_4_4_BUILD_PLACEMENT_REPORT.md`
- `scripts/ui/build_menu.gd`
- `scenes/ui/BuildMenu.tscn`
- `scripts/test/buildable_warehouse_controller.gd`
- `scenes/buildings/BuildableWarehouse.tscn`
- `docs/WAVE_4_4_1_BUILD_MENU_AND_WAREHOUSE_REPORT.md`

## Arquivos alterados

Nenhum sistema existente fora da Wave 4 foi alterado. `Player`, `InteractionRayCast`, `Warehouse`, `BuildingSite`, `ResourceManager`, `WaveManager`, `Main.tscn` e `TestMap.tscn` foram apenas lidos para orientar a integracao.

Arquivos da Wave 4 atualizados na correcao:

- `scripts/npc/npc_base.gd`: sinal de selecao, reducao de logs redundantes de desselecao e checagem de chegada antes de consultar o proximo ponto de navegacao.
- `scripts/test/npc_wave4_test.gd`: remocao da selecao automatica inicial, integracao com o menu contextual e conexao da casa/menu de criacao ao spawn de civis.
- `scenes/test/NPCWave4Test.tscn`: remocao de `CivilA`, `CivilB` e `CivilC`, instancia da `Casa Civil`, menu de criacao em `CanvasLayer`, menu contextual em `CanvasLayer` e texto da cena atualizado.
- `docs/WAVE_4_NPC_FOUNDATION.md`: documentacao desta correcao.

Arquivos da Wave 4 revisados na auditoria corretiva:

- `scripts/npc/npc_base.gd`: remocao de preloads que sombreavam `class_name`, renomeacao de parametros de destino para evitar shadowing e manutencao das validacoes de ordem/alvo.
- `scripts/npc/npc_order.gd`: factories tipadas usando `NPCOrder.new(...)` diretamente, sem `load()` repetido em tempo de execucao.
- `scripts/npc/npc_house.gd`: rastreamento dos civis criados pela casa, limpeza de instancias invalidas, contador ativo mais previsivel e validacao do parent de spawn antes de concluir a criacao.
- `scripts/ui/npc_command_menu.gd`: validacao de `current_npc`, conexoes idempotentes de botoes e restauracao de mouse protegida contra outro bloqueador de input aberto.
- `scripts/ui/npc_creation_menu.gd`: validacao de `current_house`, conexoes idempotentes de botoes e restauracao de mouse protegida contra outro bloqueador de input aberto.
- `scripts/test/npc_wave4_test.gd`: validacao de NPC selecionado antes de ordens/menu, troca segura entre menus mantendo restauracao correta do mouse e defesa contra instancias liberadas.
- `scripts/npc/npc_house.gd`: distribuicao de spawn em aneis para reduzir sobreposicao quando a cena integrada usa limite de 40 civis.

Arquivos da integracao de estresse e construcao:

- `scripts/test/npc_wave4_construction_stress_test.gd`: especializacao da cena de teste da Wave 4 com limites de movimento, clamp do destino de `Mover`, configuracao de estresse e auto-spawn opcional desativado por padrao.
- `scenes/test/NPCWave4ConstructionStressTest.tscn`: mapa 80x80 com Player, pickups de madeira/pedra, HUDs, menus de NPC e fluxo de construcao posicionado em runtime.
- `docs/WAVE_4_CONSTRUCTION_STRESS_TEST_REPORT.md`: relatorio tecnico da integracao e validacao.
- `docs/WAVE_4_PRETEST_AUDIT_REPORT.md`: auditoria pre-teste da cena integrada antes de liberar estresse com 20/40 NPCs.

Arquivos da Wave 4.2:

- `scripts/test/npc_wave4_construction_stress_test.gd`: fluxo de escolha de destino no chao para o comando `Mover`, cancelamento com `Esc`, raycast fisico, validacao de chao e clamp de bounds.
- `scripts/player/player.gd`: gancho pequeno para permitir que a cena atual consuma a acao `interact` antes do raycast normal do jogador, apenas quando a cena expuser `try_consume_player_interact(...)`.
- `scenes/test/NPCWave4ConstructionStressTest.tscn`: `Ground` marcado com o grupo `movement_ground`.
- `docs/WAVE_4_2_MOVE_TO_GROUND_REPORT.md`: relatorio tecnico da Wave 4.2.

Arquivos da Wave 4.3:

- `scripts/test/buildable_civil_house_controller.gd`: adaptador que observa um `BuildingSite`, mantem a `NPCHouse` bloqueada antes da conclusao e habilita criacao de civis quando a construcao termina.
- `scripts/building/building_site.gd`: sinal minimo `construction_completed(building_site)` emitido uma vez quando `is_completed` passa a verdadeiro.
- `scripts/npc/npc_house.gd`: export `creation_enabled` para bloquear `interact`, `can_create_npc` e status de criacao antes da casa estar pronta.
- `scenes/test/NPCWave4ConstructionStressTest.tscn`: `NPCHouse` vinculada ao local da construcao, invisivel/desabilitada no inicio, controlada pelo adaptador e configurada para ate 40 civis apos conclusao.
- `docs/WAVE_4_3_BUILDABLE_CIVIL_HOUSE_REPORT.md`: relatorio tecnico da Wave 4.3.

Arquivos da Wave 4.4:

- `scripts/building/building_placement_preview.gd`: preview/fantasma transparente da pegada da Casa Civil, alternando material verde/vermelho por validade.
- `scripts/test/build_placement_controller.gd`: controller reutilizavel de posicionamento, entrada em modo build, rotacao, confirmacao, cancelamento, raycast de chao e validacao por `intersect_shape`.
- `scenes/buildings/BuildableCivilHouse.tscn`: prefab com `BuildingSite`, `NPCHouse`, `BuildingVisualState` e `BuildableCivilHouseController`.
- `scripts/test/npc_wave4_construction_stress_test.gd`: na Wave 4.4, consumia `E` durante placement via `try_consume_player_interact(...)`; na Wave 4.4.1 esse consumo foi removido para devolver `E` a interacao normal.
- `scenes/test/NPCWave4ConstructionStressTest.tscn`: substituicao do `BuildingSite` fixo por `BuildPlacementController`, configurado para instanciar `BuildableCivilHouse.tscn`.
- `project.godot`: acoes de construcao mantidas no `InputMap`; na Wave 4.4.1, `build_mode` usa `H`, `rotate_building` usa `R` e `build_confirm` usa `Enter`.
- `docs/WAVE_4_4_BUILD_PLACEMENT_REPORT.md`: relatorio tecnico da Wave 4.4.

Arquivos da Wave 4.4.1:

- `scripts/ui/build_menu.gd`: menu simples de construcao no grupo `gameplay_input_blocker`, com botoes `Armazem`, `Casa Civil` e `Fechar`.
- `scenes/ui/BuildMenu.tscn`: UI do menu `Construir`.
- `scripts/test/build_placement_controller.gd`: catalogo minimo para Armazem/Casa Civil, confirmacao por `build_confirm` e manutencao das validacoes de placement.
- `scripts/test/buildable_warehouse_controller.gd`: adaptador que habilita `WarehouseInteractable` apenas depois da conclusao do `BuildingSite`.
- `scenes/buildings/BuildableWarehouse.tscn`: prefab construivel com `BuildingSite`, `Warehouse`, `WarehouseInteractable`, `BuildingVisualState` e controller.
- `scripts/building/building_site.gd`: suporte minimo a politica de consumo por construcao.
- `scripts/building/building_resource_consumer.gd`: aliases de politica `INVENTORY_ONLY`, `WAREHOUSE_THEN_INVENTORY` e `INVENTORY_THEN_WAREHOUSE`.
- `scenes/buildings/BuildableCivilHouse.tscn`: Casa Civil configurada para tentar `Warehouse` e depois `PlayerInventory`.
- `scenes/test/NPCWave4ConstructionStressTest.tscn`: cena integrada inicia sem armazem/casa fixos funcionais e usa `BuildMenu` + catalogo de placement.
- `project.godot`: `build_mode` movido para `H` e nova acao `build_confirm` em `Enter`.

## Como testar

1. Abrir o projeto no Godot 4.x.
2. Abrir `res://scenes/test/NPCWave4Test.tscn`.
3. Executar a cena atual.
4. Verificar que nenhum civil aparece inicialmente.
5. Mirar na `Casa Civil` e pressionar `E` para abrir o menu de criacao.
6. Clicar em `Criar Civil`.
7. Verificar que um civil nasce perto da casa, entra em `IDLE`, e fica conectado ao menu contextual de ordens.
8. Mirar em um civil e pressionar `E` para selecionar via raycast/interacao, caso o menu nao esteja aberto.
9. Usar o menu contextual estilo conversa de comando para comandar o NPC.
10. Ativar `debug_keyboard_commands_enabled` apenas se precisar validar comandos tecnicos por teclado.

## Criacao de civis pela casa

A cena de teste nao posiciona mais `CivilA`, `CivilB` e `CivilC` diretamente no mapa. A origem dos civis agora e a `Casa Civil`, uma estrutura simples interagivel por raycast. Ao interagir com a casa, o menu de criacao abre e permite criar civis ate o limite simples configurado em `max_spawned_npcs`.

O civil criado e instanciado a partir de `NPCBase.tscn`, nasce perto da casa, entra no grupo `npc` pelo `_ready()` de `NPCBase`, conecta o sinal `selection_changed` ao controlador da cena de teste e pode ser comandado pelo menu contextual. Esta implementacao nao consome recursos, nao cria populacao real e nao adiciona economia; ela apenas valida o fluxo tecnico de criacao e conexao do NPC criado.

Na cena integrada `NPCWave4ConstructionStressTest.tscn`, a Wave 4.4.1 muda o fluxo: a `Casa Civil` nao inicia fixa no mapa. O jogador pressiona `H`, escolhe `Casa Civil` no menu `Construir`, mira no chao, usa um preview transparente para escolher uma posicao valida, pode girar com `R` e confirma com `Enter` (`build_confirm`). Apenas se o preview estiver verde o prefab `BuildableCivilHouse.tscn` e instanciado. A casa instanciada contem `BuildingSite` ativo, `NPCHouse` desabilitada e `BuildableCivilHouseController`, mantendo o comportamento da Wave 4.3 depois que a construcao e concluida.

Esse fluxo nao adiciona custo de civil nem sistema de populacao. A construcao da Casa Civil tenta consumir recursos de um `Warehouse` construido e, se ele nao tiver o custo completo da etapa, tenta consumir do `PlayerInventory`. A criacao de civis continua local da casa apos ela estar pronta.

## Cena integrada de estresse e construcao

`NPCWave4ConstructionStressTest.tscn` preserva a cena base `NPCWave4Test.tscn` e cria uma arena separada para testar NPCs em area ampla junto do sistema existente de construcao pelo jogador.

- Chao visual e colisao: `80 x 80`.
- Area util de movimento: X/Z de `-36` a `36`, deixando 4 unidades de margem ate a borda do chao.
- `Mover` na cena integrada aplica clamp no destino antes de emitir `NPCOrder.move_to_position(...)`.
- Layout atual: jogador em `(0, 0, 20)`, pickups de madeira/pedra e nenhum armazem/casa funcional fixo no inicio.
- A construcao usa `scripts/building/building_site.gd`, `scripts/storage/warehouse.gd`, `scripts/storage/warehouse_interactable.gd`, `scripts/resources/resource_pickup.gd` e `PlayerInventory`, seguindo o contrato ja validado em `TestInventoryWarehouse.tscn`.

Esta cena nao implementa construcao por NPC. O objetivo e confirmar que o jogador consegue coletar recursos, construir um Armazem com inventario, depositar recursos nele, construir a Casa Civil com armazem ou inventario, criar civis pela casa concluida e comandar esses civis no mesmo mapa integrado.

## Placement validado da Casa Civil

Na cena integrada, `H` abre o menu `Construir`. Escolher `Armazem` ou `Casa Civil` inicia o mesmo modo de posicionamento validado. O preview segue o ponto do chao mirado pela camera do jogador e fica verde apenas quando todas as validacoes passam:

- Raycast precisa acertar uma posicao finita em collider do grupo `movement_ground` ou com nome contendo `Ground`.
- A posicao precisa ficar dentro dos bounds seguros `-36..36` em X/Z.
- A pegada aproximada da construcao precisa passar em consulta fisica imediata com `PhysicsDirectSpaceState3D.intersect_shape(...)`, ignorando apenas o preview e o chao.
- O ponto nao pode ficar dentro da margem minima simples do jogador nem de casas existentes.

Se o preview estiver vermelho, `Enter` nao instancia nada e o modo permanece ativo. Se estiver verde, `Enter` instancia a cena selecionada, aplica posicao/rotacao, configura a politica de pagamento do `BuildingSite` e sai do modo placement. `Esc` cancela o modo e remove o preview. `E` permanece reservado para interacao normal do jogador.

## Menu de construcao

`BuildMenu.tscn` e uma UI simples no grupo `gameplay_input_blocker`. Enquanto esta visivel, o mouse fica liberado para clicar nos botoes e o `Player` bloqueia input de gameplay pelo mesmo contrato usado pelos menus existentes. O menu expoe `is_inventory_ui_open()`, retorna `visible` e oferece:

- `Armazem`: fecha o menu e inicia placement do prefab `BuildableWarehouse.tscn`.
- `Casa Civil`: fecha o menu e inicia placement do prefab `BuildableCivilHouse.tscn`.
- `Fechar`: cancela a escolha e restaura mouse/camera.

O Armazem nasce como `BuildingSite` usando politica `INVENTORY_ONLY`. Quando concluido, `BuildableWarehouseController` habilita `WarehouseInteractable`, permitindo deposito/interacao. A Casa Civil nasce como `BuildingSite` usando politica `WAREHOUSE_THEN_INVENTORY`; quando concluida, `BuildableCivilHouseController` habilita `NPCHouse`.

## Menu contextual

O menu contextual e a interface principal da cena de teste para comandar NPCs nesta correcao da Wave 4. O fluxo esperado e: o jogador olha para um NPC, usa a acao `interact`, o NPC e selecionado e o menu abre. Ele aparece apenas quando um NPC e selecionado/interagido, mostra nome, estado atual, a frase "O que deseja ordenar?" e oferece comandos ja existentes em linguagem de jogador:

- `Mover`: envia `MOVE_TO_POSITION` para uma posicao a frente do NPC, usando comportamento provisorio.
- `Seguir voce`: envia `FOLLOW_PLAYER`.
- `Parar`: envia `STOP`.
- `Dispensar`: desseleciona o NPC e fecha o menu.

O menu nao adiciona dialogo narrativo nem cria mecanicas novas. Ele apenas chama as ordens ja existentes.

## Mover provisorio

Na cena base `NPCWave4Test.tscn`, o botao `Mover` preserva o comportamento minimo da Wave 4: o NPC selecionado recebe uma ordem para andar alguns metros a frente, usando a direcao do jogador quando disponivel. Este comportamento foi mantido para preservar a cena ja validada.

Na cena integrada `NPCWave4ConstructionStressTest.tscn`, a Wave 4.2 substitui o comportamento provisorio do botao `Mover` por escolha de ponto no chao:

1. Selecionar/interagir com um NPC.
2. Clicar em `Mover` no menu contextual.
3. O menu fecha e o mouse volta para controle de camera.
4. Mirar no chao da arena.
5. Pressionar `E` para confirmar.
6. A cena valida o collider como `movement_ground`/`Ground`, aplica clamp em X/Z dentro de `-36..36` e emite `NPCOrder.move_to_position(destination, player)`.
7. `Esc` cancela o modo sem emitir ordem.

Destinos sobre NPC, Casa Civil, armazem ou `BuildingSite` nao sao aceitos como chao valido. O modo permanece ativo para uma nova tentativa.

## Controles fallback/debug

- `E`: selecionar NPC mirado pelo raycast do player, usando `interact(actor)`.
- `H` na cena integrada: abrir menu de construcao.
- `R` durante placement na cena integrada: girar o preview em 90 graus.
- `Enter` (`build_confirm`) durante placement na cena integrada: confirmar a construcao somente se o local estiver valido.
- `Esc` durante placement na cena integrada: cancelar posicionamento e remover o preview.
- `E` durante a escolha de destino na cena integrada: confirmar o ponto de movimento no chao.
- `E` mirando na `Casa Civil`: abrir o menu de criacao de civis.
- `Esc` durante a escolha de destino na cena integrada: cancelar o modo de escolha.
- `1`, `2`, `3`: selecionar civis ja criados por indice, somente se `debug_keyboard_commands_enabled = true`.
- `M`: mandar o NPC selecionado mover para frente, somente se `debug_keyboard_commands_enabled = true`.
- `F`: mandar o NPC selecionado seguir o jogador, somente se `debug_keyboard_commands_enabled = true`.
- `X`: parar/cancelar ordem atual, somente se `debug_keyboard_commands_enabled = true`.
- `C`: desselecionar o NPC atual, somente se `debug_keyboard_commands_enabled = true`.

Esses controles existem apenas em `scripts/test/npc_wave4_test.gd`, nao alteram os controles globais do projeto, ficam desativados por padrao e devem ser tratados como apoio tecnico. A interface principal de comando da cena de teste e o menu contextual.

## Logs esperados

Todos os logs da fundacao de NPC usam prefixo `[NPC]`. Eventos esperados:

- NPC criado.
- Estado inicial `IDLE`.
- Selecao.
- Desselecao.
- Ordem recebida.
- Mudanca de estado.
- Chegada ao destino.
- Ordem cancelada.
- Ordem invalida, se emitida manualmente.
- Fallback de movimento direto quando nao houver navegacao funcional assumida.
- Falha de navegacao se o alvo de follow deixar de existir.
- Menu contextual aberto/fechado.
- Casa de criacao pronta.
- Casa Civil ainda nao construida, quando interagida antes da conclusao.
- Local de construcao valido/invalido durante placement da Casa Civil.
- Falha de posicionamento da Casa Civil com motivo de invalidade.
- Casa Civil posicionada para construcao.
- Posicionamento de Casa Civil cancelado.
- Menu de construcao aberto/fechado.
- Armazem posicionado para construcao.
- Armazem construido e interacao de deposito habilitada.
- Casa Civil construida e criacao de civis habilitada.
- Casa interagida.
- Menu de criacao aberto/fechado.
- Civil criado pela casa e conectado ao menu de ordens.

## Movimento e navegacao

`NPCBase.tscn` inclui `NavigationAgent3D`. O script define `target_position` e usa `get_next_path_position()` quando o agente esta disponivel.

Como a cena de teste nao cria uma `NavigationRegion3D`, a implementacao tambem possui fallback direto: o NPC se move horizontalmente em direcao ao alvo com `move_and_slide()`. Esse fallback e temporario e intencional para nao bloquear a entrega da wave por ausencia de navmesh.

## Limitacoes conhecidas

- O fallback direto nao desvia de obstaculos.
- Nao ha selecao multipla.
- Nao ha fila de ordens.
- O estado `SELECTED` e usado apenas quando o NPC esta selecionado e sem ordem ativa; durante movimento ou follow, `selected` continua verdadeiro, mas `current_state` reflete a ordem ativa.
- A cena de teste nao valida navegacao em navmesh real.
- O menu contextual e uma UI simples de teste, nao um controlador RTS global.
- A cena de teste usa fallback direto porque nao possui `NavigationRegion3D`.
- A cena base ainda usa deslocamento provisorio para frente no botao `Mover`; a escolha de ponto no chao foi implementada apenas na cena integrada da Wave 4.2.
- A criacao de civis usa limite simples local na casa e nao e um sistema de populacao completo.
- A casa cria civis sem custo de recurso nesta wave.
- O civil criado e selecionado automaticamente apos o clique em `Criar Civil` para permitir comandar imediatamente no prototipo.
- Na cena integrada, a criacao de civis so fica disponivel apos a conclusao do `BuildingSite` da Casa Civil. Na cena base, `NPCHouse` preserva `creation_enabled = true` por padrao para manter regressao.
- O preview da Wave 4.4 usa uma caixa simples, nao o asset final da casa.
- A validacao de footprint usa caixas aproximadas por tipo de construcao, sem grid, snapping ou analise de navegacao.
- Mirar diretamente em um objeto solido pode falhar na camada de raycast por nao acertar o chao; isso e aceito nesta wave porque o local fica vermelho e bloqueia a construcao.
- Na Wave 4.4.1, a Casa Civil procura o primeiro `Warehouse` disponivel na cena quando o `warehouse_path` nao e explicito; cenarios futuros com multiplos armazens podem precisar de selecao por proximidade ou UI dedicada.

## Riscos tecnicos

- Se uma cena futura usar `NavigationAgent3D` sem `NavigationRegion3D`, o agente pode nao produzir caminho util. O fallback direto mantem a wave testavel, mas pathfinding robusto deve ser validado na Wave 4.2.
- `interact(actor)` seleciona o NPC e a cena de teste abre o menu por sinal de selecao, mas ainda nao existe um controlador RTS central. A integracao robusta de selecao e ordens deve ser feita em wave propria.
- O menu usa `Input.MOUSE_MODE_VISIBLE` enquanto aberto e restaura o modo de mouse anterior ao fechar. Esse comportamento segue o padrao das UIs atuais, mas deve ser revisado quando houver UI global de comandos.
- A casa e o menu de criacao estao integrados nas cenas de teste da Wave 4. Na cena integrada, cada Casa Civil posicionada instancia `BuildableCivilHouse.tscn`, e a ativacao por construcao continua dependendo de `BuildableCivilHouseController`.
- A consulta de footprint bloqueia qualquer corpo/area nao-ground. Isso e conservador e adequado para a Wave 4.4, mas predios futuros podem precisar de camadas/mascaras de colisao mais especificas.
- O Armazem construido nao tem limite de capacidade nesta etapa.

## Proximos passos

- Validar manualmente a Wave 4.4.1 por gates: abrir menu com `H`, construir Armazem valido, bloquear Armazem invalido, construir Armazem com inventario, construir Casa Civil com Armazem, construir Casa Civil com inventario, criar civil, comandar civil e validar regressao da cena base.
- Civil coletor/depositador.
- Civil construtor/reparador.
- Populacao/criacao de civis com regras reais, custo e limite global.
- Civil treinado como soldado.
- Inimigo simples e onda basica.
- Estresse com 10/20/40 entidades apos os gates funcionais passarem.
