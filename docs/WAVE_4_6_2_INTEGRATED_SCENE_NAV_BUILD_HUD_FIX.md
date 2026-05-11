# Wave 4.6.2 - Cena integrada, navegacao, HUD e construcao

## Resumo executivo

A cena `scenes/test/NPCWave4OrderIntegrationTest.tscn` foi consolidada como a cena principal integrada de teste para inventario, coleta, armazem, construcao, HUD, comandos RTS e navegacao de NPCs.

Ela agora inclui `NavigationRegion3D`, `BuildPlacementController`, `BuildMenu`, armazem funcional, HUD com autowiring seguro, recursos `wood` e `stone`, tres NPCs civis e construcoes pendentes para validar `ASSIST_BUILD`.

## Branch e base

- Branch: `wave-4-6-npc-economia-construcao`
- Commit base observado: `92a81b1 Add typed NPC gathering and continuous build assistance`

## Arquivos alterados

- `scenes/test/NPCWave4OrderIntegrationTest.tscn`
- `scripts/npc/npc_base.gd`
- `scripts/npc/npc_order.gd`
- `scripts/npc/npc_order_executor.gd`
- `scripts/test/build_placement_controller.gd`
- `scripts/ui/hud/game_hud.gd`
- `scripts/ui/npc_command_menu.gd`
- `docs/WAVE_4_6_2_INTEGRATED_SCENE_NAV_BUILD_HUD_FIX.md`

## Cena integrada

`NPCWave4OrderIntegrationTest.tscn` agora reune:

- Player com inventario inicial.
- HUD ligada ao inventario, armazem, build controller e building site.
- Armazem funcional com estoque inicial.
- `BuildPlacementController`.
- `BuildMenu` acionavel pelo modo de construcao.
- Casa Civil e Armazem como opcoes de construcao.
- Tres NPCs civis.
- Recursos `wood` e `stone`.
- Menu de comando de NPC.
- Construcoes pendentes para `ASSIST_BUILD`.
- `NavigationRegion3D` com `NavigationMesh` cobrindo a area principal de teste.

## Navegacao de NPC

`npc_base.gd` agora registra:

- `NavigationRegion3D encontrado.`
- `NavigationAgent3D ativo.`
- `destino definido`
- `stuck detectado`
- `recalculando rota`
- `tentando offset lateral`
- falha final com motivo objetivo depois das tentativas de recuperacao.

O offset lateral agora considera NPCs proximos antes de usar apenas a direcao perpendicular ao destino.

## HUD

`game_hud.gd` ganhou autowiring seguro para:

- `PlayerInventory`
- `Warehouse`
- `BuildPlacementController`
- `BuildingSite`

A busca usa caminho exportado, grupos e varredura segura da cena. Se alguma referencia faltar, o log informa exatamente qual dependencia nao foi encontrada.

Na cena integrada, a HUD nao deve exibir `Warehouse: nao configurado` ou `Building: nao configurado` quando os sistemas existem.

## Construcao

`BuildPlacementController` agora entra no grupo `build_controller` e valida motivos de bloqueio antes de posicionar:

- colisao;
- fora da area navegavel;
- recurso insuficiente;
- build controller ausente;
- warehouse ausente;
- construcao ja concluida.

Casa Civil exige armazem disponivel. As checagens de recurso combinam estoque do armazem com inventario do jogador quando esses sistemas estao presentes.

## ASSIST_BUILD

`ASSIST_BUILD` agora pode iniciar sem alvo direto. O executor procura um `BuildingSite` incompleto elegivel.

Mensagens padronizadas:

- `ASSIST_BUILD cancelado: nenhuma construção pendente encontrada.`
- `ASSIST_BUILD bloqueado: recursos insuficientes.`

Depois de concluir uma construcao, o executor procura a proxima pendente. Se nao houver outra, encerra a ordem.

## GATHER_RESOURCE

`GATHER_RESOURCE` preserva filtro por tipo (`wood` ou `stone`). Se o alvo acabar antes do NPC chegar, o executor procura outro `ResourcePickup` do mesmo tipo.

Quando nao houver mais recurso daquele tipo, encerra limpo com:

`GATHER_RESOURCE concluído: nenhum recurso restante do tipo X.`

## Como testar

1. Abrir `scenes/test/NPCWave4OrderIntegrationTest.tscn`.
2. Confirmar que a HUD mostra inventario, armazem e construcao configurados.
3. Selecionar um NPC civil.
4. Testar mover, seguir e parar/dispensar.
5. Usar `Coletar madeira` e confirmar que apenas `wood` e coletado.
6. Usar `Coletar pedra` e confirmar que apenas `stone` e coletado.
7. Confirmar deposito no armazem e retorno para coleta do mesmo tipo.
8. Pressionar `H`.
9. Selecionar Casa Civil ou Armazem.
10. Testar posicionamento valido e invalido.
11. Mandar NPC assistir construcao.
12. Confirmar que ele conclui uma construcao e procura a proxima pendente.
13. Observar logs de navegacao e recuperacao de stuck quando houver bloqueio.

## Sequencia recomendada de teste manual

1. Validar HUD sem mensagens de sistema nao configurado.
2. Validar coleta de madeira.
3. Validar coleta de pedra.
4. Validar deposito.
5. Validar tecla `H` e preview de construcao.
6. Validar bloqueio de construcao invalida.
7. Validar `ASSIST_BUILD` com recurso suficiente.
8. Validar fim limpo quando nao houver construcao pendente.
9. Validar recuperacao de stuck em obstaculo ou aglomeracao de NPCs.

## Testes executados

Comando executado:

```powershell
git diff --check
```

Resultado:

- Passou.
- Apenas avisos de conversao LF/CRLF do Git no Windows.

Comando executado:

```powershell
C:\Users\timne\Downloads\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64_console.exe --headless --path . --quit
```

Resultado:

- Passou.

Comando executado:

```powershell
C:\Users\timne\Downloads\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64_console.exe --headless --path . --quit-after 5 res://scenes/test/NPCWave4OrderIntegrationTest.tscn
```

Resultado:

- Passou.
- Logs confirmaram `NavigationRegion3D encontrado.`
- Logs confirmaram `NavigationAgent3D ativo.`
- Logs confirmaram tres NPCs civis criados.
- Logs confirmaram player e armazem populados com recursos iniciais.

Comando executado:

```powershell
C:\Users\timne\Downloads\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64_console.exe --headless --path . --quit-after 5 res://scenes/test/NPCWave4ConstructionStressTest.tscn
```

Resultado:

- Passou.
- A cena antiga de laboratorio ainda avisa que nao possui armazem configurado na HUD. Esse aviso nao apareceu na cena integrada principal.

## Testes manuais pendentes

Ainda falta validacao manual interativa no editor/jogo para:

- abrir menu com `H`;
- clicar em Casa Civil e Armazem;
- posicionar preview/ghost em local valido;
- confirmar bloqueio visual em local invalido;
- observar coleta/deposito completa em tempo real;
- provocar stuck com obstaculos e confirmar recuperacao visual.

## Erros corrigidos

- Cena de ordens nao tinha construcao integrada.
- Cena principal integrada nao tinha `NavigationRegion3D`.
- HUD dependia de referencias explicitas frageis.
- `ASSIST_BUILD` dependia de alvo inicial selecionado.
- `GATHER_RESOURCE` podia ficar preso em alvo removido/esgotado.
- Logs de navegacao nao deixavam claro quando o `NavigationAgent3D` estava ativo.
- Motivos de bloqueio de construcao eram pouco especificos.

## Riscos restantes

- A `NavigationMesh` integrada e uma malha plana ampla de teste; ainda nao e um bake final considerando todos os obstaculos.
- A recuperacao de stuck e heuristica simples; pode exigir ajuste fino com colisores reais mais densos.
- A cena `NPCWave4ConstructionStressTest.tscn` continua sendo laboratorio separado e ainda pode mostrar aviso de armazem ausente.
- A validacao headless garante carregamento e scripts sem erro, mas nao substitui teste manual de clique, preview e fluxo completo.

## Proxima recomendacao

Fazer uma rodada manual focada na cena `NPCWave4OrderIntegrationTest.tscn` e, se aprovada, renomear ou duplicar essa cena para uma cena oficial de prototipo jogavel, como `PrototypePlayable.tscn`.
