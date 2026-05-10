# WAVE_2_IMPLEMENTATION_REPORT.md

## 1. Resumo executivo

A Wave 2 implementou o primeiro sistema real de recurso do projeto Godot 4.x "Imperio de Sangue": madeira global controlada pelo `ResourceManager`, coleta via `WoodNode` e integracao com o sistema generico de interacao validado na Wave 1.

O `Player` continua sem conhecer madeira, `WoodNode` ou classes especificas. O `interaction_raycast.gd` permaneceu intocado e segue chamando apenas `interact(actor)`.

Valor inicial de `wood`: `0`.

## 2. Escopo executado

- `ResourceManager` completado como dono unico do estado `wood`.
- Criado sinal `wood_changed(new_value: int)`.
- Criados os metodos `get_wood()`, `add_wood(amount)`, `spend_wood(amount)`, `can_afford_wood(amount)` e alias `can_spend_wood(amount)`.
- `add_wood(amount)` aceita apenas valores maiores que zero, soma madeira, emite `wood_changed` e registra log.
- `spend_wood(amount)` aceita apenas valores maiores que zero, retorna `false` se o saldo for insuficiente, retorna `true` quando consome madeira, emite `wood_changed` apenas em consumo valido e impede saldo negativo.
- Criado `WoodNode.tscn` com raiz `StaticBody3D`, `MeshInstance3D` e `CollisionShape3D`, usando apenas recursos built-in.
- Criado `wood_node.gd` com `interact(actor)`, `wood_per_interaction`, `max_uses`, `remaining_uses` e `destroy_when_depleted`.
- Instanciados dois `WoodNode`s no `TestMap.tscn`.
- Mantido `TestInteractable` no mapa.
- Corrigido apenas o texto de debug do stub `attack()` para nao indicar combate na Wave 2.

## 3. Arquivos criados

- `res://scenes/resources/WoodNode.tscn`
- `res://scripts/resources/wood_node.gd`
- `res://WAVE_2_IMPLEMENTATION_REPORT.md`

## 4. Arquivos alterados

- `res://scripts/core/resource_manager.gd`
- `res://scenes/test/TestMap.tscn`
- `res://scripts/player/player.gd`

Alteracao em `player.gd`: somente texto/comentario do debug de `attack()` para remover a referencia enganosa a combate na Wave 2. Input, movimento, camera, interacao, clique de recaptura e comportamento de ataque stub foram preservados.

Arquivos mantidos intocados nesta Wave:

- `res://project.godot`
- `res://scripts/player/interaction_raycast.gd`
- `res://scenes/player/Player.tscn`
- `res://scenes/main/Main.tscn`
- `res://scripts/core/game_manager.gd`
- `res://scripts/core/wave_manager.gd`
- `res://scenes/test/TestInteractable.tscn`

## 5. Estrutura final de pastas

Estrutura relevante ao escopo atual:

```text
res://
  assets_temp/
  docs/
  scenes/
    buildings/
    enemies/
    main/
      Main.tscn
    npcs/
    player/
      Player.tscn
    resources/
      WoodNode.tscn
    test/
      TestInteractable.tscn
      TestMap.tscn
    ui/
  scripts/
    buildings/
    core/
      game_manager.gd
      resource_manager.gd
      wave_manager.gd
    enemies/
    npcs/
    player/
      interaction_raycast.gd
      player.gd
    resources/
      wood_node.gd
    test/
    ui/
  project.godot
  WAVE_1_IMPLEMENTATION_REPORT.md
  WAVE_2_IMPLEMENTATION_REPORT.md
```

## 6. Como abrir o projeto

1. Abrir o Godot 4.x.
2. Escolher "Importar" ou "Abrir projeto".
3. Selecionar a pasta `O:\game`.
4. Confirmar que `project.godot` foi carregado.
5. Confirmar em `Project > Project Settings > Globals > Autoload` que existem `GameManager`, `ResourceManager` e `WaveManager`.

`ResourceManager` ja estava configurado como Autoload em `project.godot`, portanto esse arquivo nao precisou ser alterado.

## 7. Como executar

1. Abrir `res://scenes/main/Main.tscn`.
2. Confirmar que ela e a cena principal configurada em `project.godot`.
3. Pressionar Play/F5.
4. A cena deve carregar `TestMap.tscn` e `Player.tscn`.

## 8. Como testar

Teste de movimento e regressao da Wave 1:

- Usar WASD para mover.
- Usar mouse para controlar a camera.
- Usar Shift para correr.
- Pressionar ESC para liberar o mouse.
- Clicar na janela para recapturar o mouse e confirmar que esse clique nao chama `attack()`.
- Clicar com o botao esquerdo com mouse capturado e confirmar no Output o log do stub `attack()`.

Teste do `TestInteractable`:

- Olhar para o `TestInteractable` no mapa.
- Pressionar E.
- Confirmar que o log de interacao anterior continua aparecendo.
- Olhar para uma area vazia e pressionar E.
- Confirmar que nao ha erro vermelho no Output.

Teste do `WoodNode`:

- Localizar `WoodNodeA` ou `WoodNodeB` em `TestMap.tscn`.
- Olhar diretamente para o bloco de madeira.
- Pressionar E.
- Confirmar no Output logs semelhantes a `[Resource] add_wood(...) aplicado` e `[WoodNode] Coletado por Player`.
- Repetir ate os usos acabarem.
- Confirmar que o node removivel emite log de recurso esgotado e sai da cena quando `destroy_when_depleted` estiver `true`.

Teste do `ResourceManager`:

- `get_wood()` deve retornar o total atual de madeira.
- `add_wood(amount)` com `amount > 0` aumenta `wood` e emite `wood_changed(new_value)`.
- `add_wood(amount)` com `amount <= 0` e ignorado com warning e nao altera `wood`.
- `spend_wood(amount)` com saldo suficiente reduz `wood`, emite `wood_changed(new_value)` e retorna `true`.
- `spend_wood(amount)` com saldo insuficiente nao altera `wood` e retorna `false`.
- `spend_wood(amount)` com `amount <= 0` e ignorado com warning e retorna `false`.
- `wood` nao deve ficar negativo.

## 9. Tarefas concluídas do backlog

- `W2-01`: `ResourceManager` esta acessivel globalmente como Autoload existente em `project.godot`.
- `W2-02`: `wood`, `add_wood` e `spend_wood` implementados com protecao contra saldo negativo.
- `W2-03`: `WoodNode.tscn` e `wood_node.gd` criados; interacao aumenta estoque global de madeira.
- `W2-04`: `wood_changed(new_value: int)` implementado e emitido quando `wood` muda.

## 10. Tarefas pendentes

- HUD para exibir madeira: fora do escopo da Wave 2.
- BuildSpot, barricada e consumo de madeira para construcao: Wave 3 ou posterior.
- NPC coletor/defensor: fora do escopo da Wave 2.
- Inimigos, ondas reais e vitoria/derrota: fora do escopo da Wave 2.
- Teste manual no editor Godot apos esta implementacao.
- Atualizacao de changelog de produto, caso o usuario queira registrar a Wave 2 em documento separado.

## 11. Erros encontrados

- O executavel `godot` nao foi encontrado no PATH desta sessao, entao nao foi possivel executar validacao headless por terminal.
- A pasta `O:\game` nao esta em um repositorio Git nesta sessao, entao nao foi possivel gerar diff por `git status`.
- Durante a edicao do texto de debug do `player.gd`, houve uma incompatibilidade de patch por codificacao/acentos no conteudo anterior. A solucao foi recriar o arquivo com o mesmo comportamento e texto ASCII, alterando apenas comentarios e mensagem do stub de ataque.

Nao houve limitacao para editar `.tscn`: `WoodNode.tscn` foi criado e `TestMap.tscn` foi alterado por arquivo com estrutura simples de Godot.

## 12. Informações incompletas

- A versao exata do Godot 4.x usada pelo usuario nao foi informada, embora `project.godot` indique feature `4.6`.
- Ainda nao ha HUD na Wave 2, portanto `wood_changed` so pode ser verificado por conexao futura, debug/manual test ou chamada em runtime.
- O documento `02_PROTOTYPE_SCOPE.md` descreve em uma parte "Wave 2 - Assentamento", incluindo barricada e consumo de madeira. O `05_BACKLOG.md` e o pedido atual definem Wave 2 como "Recursos e madeira". Segui o pedido atual e o backlog para evitar implementar Wave 3 antecipadamente.
- O `WAVE_1_IMPLEMENTATION_REPORT.md` indicava ausencia de `07_TEST_PLAN.md`, mas o arquivo existe no projeto atual. Isso nao bloqueou a Wave 2.

## 13. Decisões técnicas tomadas

- `ResourceManager` permanece como Autoload unico e dono do estado `wood`.
- `wood` inicia em `0`.
- `wood_changed(new_value)` e emitido somente quando uma operacao valida altera ou reseta o valor de madeira.
- Valores invalidos em `add_wood` e `spend_wood` sao ignorados com `push_warning`.
- `spend_wood` usa `can_afford_wood` e retorna `false` sem alterar saldo quando nao ha madeira suficiente.
- `WoodNode` chama o Autoload `ResourceManager` dentro de `interact(actor)`, preservando o contrato `Player -> InteractionRaycast -> interact(actor)`.
- `WoodNode` usa `call("add_wood", ...)` depois de validar o metodo, evitando dependencia de tipo estatico em Godot 4.
- `WoodNodeA` usa valores padrao: `5` madeiras por interacao e `3` usos.
- `WoodNodeB` usa valores configurados no mapa: `3` madeiras por interacao e `2` usos.
- `destroy_when_depleted` fica `true` por padrao para remover o node quando os usos acabam.
- Nenhum segundo `ResourceManager` foi instanciado em cena.

## 14. Decisões que exigem aprovação do usuário

- Aprovar se a proxima Wave deve seguir para Wave 3 com BuildSpot/barricada ou se devemos primeiro ajustar documentacao para alinhar a nomenclatura de Waves.
- Aprovar se `can_spend_wood(amount)` deve permanecer como alias de compatibilidade ou ser removido para manter apenas `can_afford_wood(amount)`.
- Aprovar se a exibicao de madeira via HUD deve entrar na Wave 3 ou ficar para a Wave de UI prevista no backlog.

## 15. O que o usuário precisa fazer

- Abrir o projeto na Godot 4.x.
- Executar `Main.tscn`.
- Testar movimento, interacao generica, `TestInteractable` e `WoodNode`.
- Conferir o Output para logs de coleta e alteracao de madeira.
- Confirmar se nao ha erro vermelho apos interagir, atacar, soltar/recapturar mouse e esgotar madeira.

## 16. O que o usuário precisa corrigir

- Nada precisa ser corrigido manualmente para a Wave 2 funcionar, caso o editor abra as cenas normalmente.
- Opcional: adicionar o executavel Godot ao PATH se quiser permitir testes headless por terminal em Waves futuras.
- Opcional: revisar a divergencia documental entre `02_PROTOTYPE_SCOPE.md` e `05_BACKLOG.md` sobre o significado de Wave 2.

## 17. O que o usuário precisa ler e entender

- `04_SYSTEMS_ARCHITECTURE.md`: fluxo `Player -> InteractionRaycast -> WoodNode -> ResourceManager`.
- `05_BACKLOG.md`: Wave 2 e Wave 3 estao separadas; madeira agora, construcao depois.
- `06_AI_CODEX_RULES.md`: Player nao deve alterar madeira diretamente e managers nao devem virar objetos de cena.
- `08_BUILD_NOTES.md`: Autoloads e execucao pela cena principal.

## 18. O que o usuário precisa construir manualmente

Nada foi deixado para construcao manual nesta Wave.

Se a Godot regravar UIDs ou metadados ao abrir o projeto, basta salvar as cenas pelo editor. Isso e comportamento normal e nao muda o escopo implementado.

## 19. O que o usuário precisa testar

- `E` em `TestInteractable` continua funcionando.
- `E` em area vazia nao gera erro.
- `E` em `WoodNodeA` aumenta madeira em `5` por interacao.
- `E` em `WoodNodeB` aumenta madeira em `3` por interacao.
- `WoodNodeA` some apos `3` usos se `destroy_when_depleted` estiver `true`.
- `WoodNodeB` some apos `2` usos se `destroy_when_depleted` estiver `true`.
- Output mostra logs de `ResourceManager` e `WoodNode`.
- Botao esquerdo continua chamando apenas o stub `attack()`.
- Clique de recaptura do mouse continua sem atacar no mesmo clique.
- Nao aparecem erros vermelhos no Output.

## 20. Próxima etapa recomendada

Recomendacao objetiva: testar manualmente a Wave 2 no editor antes de avancar.

Se a Wave 2 passar sem erro vermelho, a proxima etapa recomendada e Wave 3: assentamento minimo com consumo de madeira, BuildSpot e barricada simples, sem HUD completo e sem NPCs.
