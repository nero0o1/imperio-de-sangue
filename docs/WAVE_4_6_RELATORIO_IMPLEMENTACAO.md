# Wave 4.6 - Relatorio de Implementacao

## Resumo

Esta Wave consolidou a base de economia e ordens civis para o prototipo RPG + RTS. A coleta, deposito e construcao agora respeitam o inventario do ator que executa a acao; NPCs civis ganharam ciclo continuo de coleta, deposito forcado seguro, patrulha persistente, reparo MVP e movimento idle controlado. A populacao passou a ter um gerente global com exibicao no HUD/debug.

## Arquivos criados

- `scripts/core/population_manager.gd`
- `scripts/core/population_manager.gd.uid`
- `docs/WAVE_4_6_RELATORIO_IMPLEMENTACAO.md`

## Arquivos alterados

- `scenes/test/NPCWave4OrderIntegrationTest.tscn`
- `scenes/test/NPCWave4ConstructionStressTest.tscn`
- `scenes/ui/hud/GameHUD.tscn`
- `scripts/building/building_site.gd`
- `scripts/npc/npc_base.gd`
- `scripts/npc/npc_house.gd`
- `scripts/npc/npc_order.gd`
- `scripts/npc/npc_order_executor.gd`
- `scripts/resources/resource_pickup.gd`
- `scripts/storage/warehouse_interactable.gd`
- `scripts/test/build_placement_controller.gd`
- `scripts/test/buildable_civil_house_controller.gd`
- `scripts/test/npc_wave4_order_integration_test.gd`
- `scripts/ui/hud/game_hud.gd`
- `scripts/ui/npc_command_menu.gd`

## Sistemas corrigidos

- Inventario do ator: `ResourcePickup`, `WarehouseInteractable` e `BuildingSite` resolvem o inventario por `get_inventory()` do ator ou por `InventoryContainer` filho do proprio ator, sem fallback para `PlayerInventory`.
- Coletor automatico: `NPCOrderExecutor` executa ciclo `PROCURANDO_RECURSO -> INDO_COLETAR -> COLETANDO -> INDO_DEPOSITAR -> DEPOSITANDO`, repetindo ate parar, faltar recurso/armazem ou estourar timeout.
- Deposito forcado: `FORCE_DROP` deposita apenas em armazem valido, usa o inventario do ator e registra falhas claras para inventario vazio ou ausencia de armazem.
- Construcoes: armazem novo usa custo do inventario do player antes de ficar operacional; casa pode usar armazem quando ele ja existe e esta ativo. `BuildingSite` ganhou vida e API de reparo.
- Populacao global: `PopulationManager` controla populacao atual, capacidade maxima, casas registradas e bloqueio de spawn por limite.
- Patrulha: `PATROL` alterna continuamente entre dois pontos; quando so ha um ponto, o executor cria um segundo com offset seguro.
- Reparo MVP: NPC civil repara estruturas danificadas em passos pequenos ate a vida maxima.
- Idle de NPC aliado: NPC ocioso pode andar levemente dentro de raio configuravel sem interferir em ordens ativas.
- Menu de ordens: botoes principais agora usam portugues natural e deixam ordens incompletas fora da UI principal.
- Build mode H: cena de stress usa o modo de construcao por tecla H, com menu Casa/Armazem, preview valido/invalido, confirmacao por clique/Enter e cancelamento por Esc/botao direito.

## Testes executados

- `git diff --check`
- Busca por referencias `res://*.gd` quebradas em `.gd`, `.tscn` e `.tres`
- Busca por fallbacks indevidos de `PlayerInventory` em pickup/armazem/construcao
- `Godot_v4.6.2-stable_win64.exe --headless --path . --quit`
- `Godot_v4.6.2-stable_win64.exe --headless --path . --quit-after 2 res://scenes/test/NPCWave4OrderIntegrationTest.tscn`
- `Godot_v4.6.2-stable_win64.exe --headless --path . --quit-after 2 res://scenes/test/NPCWave4ConstructionStressTest.tscn`

## Problemas encontrados

- A cena de integracao mantinha o armazem com recursos iniciais para debug, mascarando o teste de custo. O setup foi separado em inventario inicial do player e estoque debug do armazem zerado por padrao.
- A ordem de coleta era pontual; foi substituida por maquina de estados persistente no executor de ordens.
- Casas controlavam spawn localmente; agora podem registrar capacidade no `PopulationManager` quando a construcao e concluida.
- O menu de comandos misturava nomes internos e estados parciais/debug na UI principal; os comandos visiveis foram reduzidos aos fluxos testaveis da Wave.

## Problemas nao resolvidos

- O reparo ainda nao depende de um sistema completo de dano/combate. Para teste manual, use dano controlado via `damage_for_test(amount)` ou ajuste `current_health` no inspetor.
- A validacao visual final do preview de construcao deve ser feita no editor/janela do Godot, porque a checagem headless confirma carregamento e parse, mas nao substitui teste visual interativo.

## Proximos passos

- Criar testes automatizados pequenos para `PopulationManager`, roteamento de inventario e loop de coleta.
- Integrar dano real de combate com a API `is_damaged()`/`repair(amount)` ja preparada.
- Evoluir o HUD para mostrar inventario do NPC selecionado e estado detalhado da ordem atual.
- Revisar UX do menu de construcao para suportar mais tipos sem crescer em complexidade.

## Roteiro de teste manual no Godot

A. Player coleta madeira.
Resultado esperado: madeira entra no inventario do player e o HUD/debug atualiza.

B. NPC recebe ordem de coletar.
Resultado esperado: NPC vai ao recurso, recurso entra no inventario do NPC, NPC deposita no armazem e repete o ciclo.

C. Player tenta construir sem recurso.
Resultado esperado: construcao nao inicia e uma mensagem clara aparece no HUD/debug/console.

D. Player constroi armazem.
Resultado esperado: custo vem do inventario do player, nao do armazem ainda inexistente.

E. Player constroi casa apos armazem pronto.
Resultado esperado: se o armazem tiver recurso, casa pode consumir do armazem; casa concluida aumenta a capacidade populacional.

F. Populacao atinge limite.
Resultado esperado: novas unidades nao aparecem acima do limite global mostrado como `Populacao: atual / capacidade`.

G. Patrulha.
Resultado esperado: NPC alterna entre dois pontos ate receber ordem de parar.

H. Reparo.
Resultado esperado: construcao danificada recupera vida aos poucos; NPC para quando a vida chega ao maximo.

I. Modo construcao com tecla H.
Resultado esperado: H abre modo construcao; preview fica verde em local valido, vermelho em local invalido; clique ou Enter constroi somente se o local e o custo forem validos.
