# Relatorio Tecnico - Wave 4.3 Casa Civil Construivel Integrada

## 1. Resumo executivo

A cena integrada `res://scenes/test/NPCWave4ConstructionStressTest.tscn` agora usa o fluxo principal do prototipo: o jogador coleta recursos, deposita no armazem, constroi a Casa Civil usando o `BuildingSite` existente e so entao a Casa Civil habilita a criacao de civis.

A implementacao usa um adaptador pequeno, `BuildableCivilHouseController`, para conectar um `BuildingSite` especifico a uma `NPCHouse` especifica. O sistema de construcao, o armazem, o inventario, o menu de criacao e o spawn de NPCs foram reutilizados.

## 2. Arquivos alterados

| Arquivo | Alteracao | Motivo | Risco reduzido |
| --- | --- | --- | --- |
| `res://scripts/test/buildable_civil_house_controller.gd` | Criado adaptador entre `BuildingSite` e `NPCHouse`. | Habilitar Casa Civil apenas apos construcao sem criar sistema paralelo. | Reduz acoplamento e prepara multiplas casas por NodePath. |
| `res://scripts/building/building_site.gd` | Adicionado sinal `construction_completed(building_site)` emitido uma vez. | Permitir que sistemas observem conclusao sem reescrever construcao. | Evita polling fragil e duplicacao de logica. |
| `res://scripts/npc/npc_house.gd` | Adicionado `creation_enabled` e bloqueio de `interact`/`can_create_npc` quando desabilitada. | Impedir criacao antes da Casa Civil estar pronta. | Evita bypass pelo menu existente. |
| `res://scenes/test/NPCWave4ConstructionStressTest.tscn` | `NPCHouse` movida/vinculada ao local do `BuildingSite`, invisivel/desabilitada no inicio e controlada pelo adaptador. | Tornar a casa construida a origem real dos civis. | Remove fluxo artificial de casa separada. |
| `res://docs/WAVE_4_NPC_FOUNDATION.md` | Atualizado com Wave 4.3, fluxo e limitacoes. | Manter historico tecnico da Wave 4 coerente. | Reduz ambiguidade para proximas waves. |
| `res://docs/WAVE_4_3_BUILDABLE_CIVIL_HOUSE_REPORT.md` | Criado este relatorio. | Registrar implementacao, validacao e pendencias. | Facilita auditoria antes de estresse. |

## 3. Fluxo antes vs depois

| Etapa | Antes | Depois |
| --- | --- | --- |
| Inicio da cena | `NPCHouse` funcional criava civis imediatamente; `BuildingSite` era um teste separado. | `NPCHouse` inicia bloqueada; o jogador ve o `BuildingSite` da Casa Civil. |
| Construcao | Jogador construia uma estrutura sem relacao direta com criacao de civis. | Jogador constroi a Casa Civil pelo `BuildingSite` existente. |
| Criacao de civil | Civil era criado por uma casa separada, sem depender do loop de recurso. | Civil so e criado apos a conclusao da casa construida. |
| Comando de NPC | Seguir, parar, dispensar e mover por ponto funcionavam para civis criados pela casa separada. | Os mesmos comandos funcionam para civis criados pela casa concluida. |
| Multiplas casas futuras | A cena sugeria uma unica casa funcional fixa. | Cada par `BuildingSite` + `NPCHouse` pode ter seu proprio adaptador via NodePath. |

## 4. Implementacao tecnica

`BuildableCivilHouseController` recebe `building_site_path` e `npc_house_path` por export. No `_ready()`, ele alinha a `NPCHouse` ao `BuildingSite`, aplica o estado inicial conforme `is_completed` e conecta o sinal `construction_completed`.

Antes da conclusao, a `NPCHouse` fica com `creation_enabled = false`, invisivel e sem colisao. Isso impede que o raycast/interact abra o menu de criacao antes da hora. Apos a conclusao, o adaptador habilita a `NPCHouse`, reativa a colisao dela e desativa a colisao do `BuildingSite` concluido, permitindo que o jogador interaja com a casa construida no mesmo local.

`BuildingSite` recebeu apenas o sinal minimo de conclusao. O consumo de recursos continua vindo do `Warehouse`; custo, progresso, etapas, HUD e economia nao foram alterados.

`NPCHouse` continua responsavel por limite local, spawn, `npc_scene`, `spawn_radius`, contador e sinal `npc_created`. O menu reutilizado e o `NPCCreationMenu`; o menu de comandos continua sendo o `NPCCommandMenu` ja usado pela Wave 4.

## 5. Escopo preservado

Nao foi implementado:

- soldado;
- treinamento de soldado;
- construcao por NPC;
- coleta por NPC;
- IA/wander;
- combate;
- inimigos;
- economia nova;
- populacao global;
- selecao multipla;
- fila de ordens.

Tambem nao houve reescrita de `Warehouse`, `WarehouseInteractable`, `ResourceManager`, `PlayerInventory`, `NPCCommandMenu` ou `NPCCreationMenu`.

## 6. Validacao CLI/headless

| Comando | Resultado | Evidencia |
| --- | --- | --- |
| `Godot --headless --path O:\game --check-only --script res://scripts/test/buildable_civil_house_controller.gd` | Passou | Exit code 0. |
| `Godot --headless --path O:\game --check-only --script res://scripts/test/npc_wave4_construction_stress_test.gd` | Passou | Exit code 0. |
| `Godot --headless --path O:\game --check-only --script res://scripts/building/building_site.gd` | Passou | Exit code 0. |
| `Godot --headless --path O:\game --check-only --script res://scripts/npc/npc_house.gd` | Passou | Exit code 0. |
| `Godot --headless --path O:\game --check-only --script res://scripts/player/player.gd` | Passou | Exit code 0. |
| `Godot --headless --path O:\game res://scenes/test/NPCWave4ConstructionStressTest.tscn --quit-after 5` | Passou | Exit code 0; logs de cena integrada, bounds `(-36,-36)..(36,36)`, auto-spawn 0 e debug desligado. |
| `Godot --headless --path O:\game res://scenes/test/NPCWave4Test.tscn --quit-after 5` | Passou | Exit code 0; cena base carregou com Casa Civil limite 3 e debug desligado. |
| Probe temporaria headless da Wave 4.3 | Passou | `build_step` consumiu recursos do Warehouse, completou 100% e logou `[NPC] Casa Civil construida. Criacao de civis habilitada.`. A sonda foi apagada ao final. |

## 7. Testes manuais necessarios

| Teste | Passos | Resultado esperado |
| --- | --- | --- |
| A - Cena integrada inicia sem Casa Civil funcional | Abrir e rodar `NPCWave4ConstructionStressTest.tscn`; tentar criar civil antes de construir. | Nao cria civil, menu nao abre, sem erro vermelho, log informa casa ainda nao pronta se houver interacao direta. |
| B - Construir Casa Civil | Coletar wood/stone, depositar no Warehouse e interagir com o `BuildingSite` ate concluir. | Progresso avanca, construcao conclui e loga `[NPC] Casa Civil construida. Criacao de civis habilitada.` |
| C - Criar civil pela casa construida | Interagir com a casa concluida e clicar `Criar Civil`. | Civil nasce perto da casa construida, contador atualiza e NPC pode ser selecionado. |
| D - Comandar NPC criado | Selecionar Civil 1, usar seguir, parar, mover por ponto no chao e dispensar. | Todos os comandos funcionam; destino invalido no mover por ponto nao emite ordem. |
| E - Construcao e NPC coexistindo | Criar civil, mandar seguir e interagir com Warehouse/BuildingSite/outros objetos. | NPC nao quebra raycast nem fluxo de construcao; interferencia fisica deve ser registrada como risco de layout. |
| F - Multiplas casas futuras | Revisar instancia/exports do adaptador. | Adaptador usa NodePaths, contagem permanece local por `NPCHouse` e nao ha dependencia global de uma unica casa. |

## 8. Riscos restantes

| Categoria | Risco | Observacao |
| --- | --- | --- |
| UI/input | Mouse/camera precisam ser validados no editor apos construcao e abertura de menu. | Headless nao cobre experiencia visual. |
| Raycast | Apos conclusao, a colisao da casa fica no mesmo local da construcao. | Foi mitigado desativando a colisao do `BuildingSite` concluido. |
| Multiplas casas | Fluxo permite multiplos adaptadores, mas ainda nao ha teste manual com duas casas. | Fora do escopo desta wave. |
| Colisao | Civis seguindo o jogador podem bloquear fisicamente interacoes. | Registrar em teste manual antes de corrigir com sistema maior. |
| Performance | Limite 40 continua disponivel, mas estresse nao foi executado nesta etapa. | Estresse deve esperar os gates funcionais. |
| Arquitetura | O adaptador ainda e de cena de teste. | Cenas principais futuras devem adotar padrao equivalente. |

## 9. Pendencias fora de escopo

- Teste visual/manual completo no editor.
- Estresse com 20/40 civis.
- Custo de criacao de civil.
- Limite global de populacao.
- Multiplas Casas Civis construiveis em gameplay real.
- Coleta/construcao por NPC.
- Soldado, combate, inimigos e novas ondas.
- Pathfinding/navmesh.

## 10. Decisao final

APROVADO COM RESSALVAS.

Justificativa: scripts, cenas e probe headless passaram, a cena base carregou sem quebra e a Casa Civil nao inicia habilitada na cena integrada. A aprovacao total depende dos testes manuais A-F no editor, principalmente mouse/camera, raycast e fluxo real de construcao pelo jogador.

## Validacao de arquitetura

| Pergunta | Resposta |
| --- | --- |
| A cena integrada continua sendo o ambiente principal? | Sim. A Wave 4.3 altera `NPCWave4ConstructionStressTest.tscn`. |
| A Casa Civil separada foi removida, desativada ou vinculada a construcao? | Foi vinculada a construcao, inicia invisivel/desabilitada e e controlada pelo adaptador. |
| A casa construida e quem cria civis? | Sim. A `NPCHouse` fica no local do `BuildingSite` e so habilita apos conclusao. |
| Ainda e possivel construir? | Sim. `BuildingSite` e `Warehouse` foram reutilizados sem alterar economia. |
| Ainda e possivel mover NPC por ponto no chao? | Sim. O fluxo da Wave 4.2 foi preservado. |
| O sistema permite criar mais casas no futuro sem reescrever tudo? | Sim. O adaptador usa NodePaths e a contagem permanece local na `NPCHouse`. |
| Algum sistema foi duplicado sem necessidade? | Nao. |
| Algum sistema foi reescrito sem necessidade? | Nao. |
| A cena base foi preservada? | Sim. `NPCWave4Test.tscn` carregou em headless e `NPCHouse.creation_enabled` e verdadeiro por padrao. |
| O escopo proibido foi respeitado? | Sim. |
