# 18_WAVE_2_7_VALIDACAO_JOGAVEL_INVENTARIO_ARMAZEM_CONSTRUCAO.md

## 1. Objetivo

Implementar a Wave 2.7: validacao jogavel do fluxo coleta -> inventario do jogador -> deposito em armazem -> consumo por construcao -> progresso de construcao.

Esta wave integra os sistemas conceituais das Waves 2.5 e 2.6 em uma cena de teste simples, sem criar UI definitiva, crafting, economia, NPCs, save/load ou sistemas de waves.

## 2. Erro corrigido

Arquivo corrigido:

- `res://scripts/building/building_resource_consumer.gd`

Erro original:

- Parse error porque `_consume_split()` esperava argumentos `InventoryContainer`, mas o codigo passava `Warehouse` diretamente.

Causa:

- `Warehouse` possui um `inventory: InventoryContainer`, mas nao herda de `InventoryContainer`.
- O consumidor de recursos precisava usar `warehouse.inventory`, nao o proprio `warehouse`.

Correcao aplicada:

- `consume()` agora passa `warehouse.inventory` para `_consume_split()`.
- `_get_warehouse_inventory()` garante inicializacao segura chamando `warehouse._ensure_inventory()` quando necessario.
- `_consume_split()` recebe somente `InventoryContainer` ou `null`.
- Foram adicionadas validacoes defensivas para custos vazios, item vazio, quantidade menor ou igual a zero, inventario nulo e armazem nulo.

Como validar:

- Abrir o projeto na Godot 4.x.
- Executar uma cena que carregue `res://scripts/building/building_resource_consumer.gd`.
- Confirmar que nao ha mais parse error nesse arquivo.

## 3. Arquivos criados

- `res://scripts/resources/resource_pickup.gd`
- `res://scripts/storage/warehouse_interactable.gd`
- `res://scripts/building/building_site.gd`
- `res://scripts/debug/inventory_debug_hud.gd`
- `res://scenes/test/TestInventoryWarehouse.tscn`
- `res://18_WAVE_2_7_VALIDACAO_JOGAVEL_INVENTARIO_ARMAZEM_CONSTRUCAO.md`

## 4. Arquivos modificados

- `res://scripts/building/building_resource_consumer.gd`
- `res://scripts/tests/inventory_system_test.gd`
- `res://scripts/player/player.gd`

## 5. Como testar

### Teste automatizado/manual do sistema de inventario

1. Abrir Godot 4.x.
2. Criar ou abrir uma cena temporaria que instancie `res://scripts/tests/inventory_system_test.gd`, se ainda nao existir uma cena de teste dedicada.
3. Executar a cena.
4. Confirmar no Output:

```text
[PASS] Todos os testes do sistema de inventario foram concluidos.
```

Observacao: a mensagem no script usa acentos conforme solicitado no briefing. Em alguns terminais do Windows a exibicao pode aparecer com encoding incorreto, mas na Godot deve ser lida como UTF-8.

### Teste jogavel da Wave 2.7

1. Abrir `res://scenes/test/TestInventoryWarehouse.tscn`.
2. Executar a cena.
3. Usar WASD para se mover, mouse para olhar e `E` para interagir.
4. Interagir com `ResourcePickup_Wood`.
5. Confirmar que o HUD mostra `PlayerInventory: wood=10`.
6. Interagir com `WarehouseInteractable_Test`.
7. Confirmar que o HUD mostra `PlayerInventory: {}` e `Warehouse: wood=10`.
8. Interagir com `BuildingSite_Test`.
9. Confirmar que o armazem consome `wood=10` e a construcao avanca para `50.0%`.
10. Repetir coleta, deposito e construcao.
11. Confirmar que a construcao chega a `100.0%` e `is_completed = true`.
12. Interagir novamente com a construcao concluida.
13. Confirmar que nenhum recurso adicional e consumido.

## 6. Criterios de aceite

- Sem parse error em `res://scripts/building/building_resource_consumer.gd`.
- `WAREHOUSE_ONLY` consome apenas do armazem.
- `PLAYER_ONLY` consome apenas do jogador.
- `PLAYER_THEN_WAREHOUSE` consome primeiro do jogador e completa pelo armazem.
- `WAREHOUSE_THEN_PLAYER` consome primeiro do armazem e completa pelo jogador.
- Recurso combinado insuficiente retorna `false` e nao altera inventarios.
- Quantidade negativa retorna `false` e nao altera inventarios.
- `ResourcePickup` adiciona recurso ao inventario do jogador.
- `WarehouseInteractable` remove recurso do jogador e deposita no armazem.
- `BuildingSite` consome recursos com `BuildingResourceConsumer`.
- Construcao concluida nao consome recurso novamente.
- HUD de debug mostra inventario do jogador, armazem e progresso da construcao.

## 7. Limitacoes

- Nao consegui executar no Godot neste ambiente; validacao pendente no editor.
- O comando `godot` nao esta disponivel no PATH deste ambiente.
- O comando `git status` indicou que `O:\game` nao e um repositorio Git, entao nao houve validacao por diff Git.
- A UI criada e apenas HUD de debug com `Label`, nao uma interface final.
- O fluxo suporta apenas uma cena de teste simples, sem logistica entre multiplos armazens.
- Nao foram implementados crafting, economia, NPCs, save/load, waves ou combate real.

## 8. Proxima Wave recomendada

Recomendo validar esta Wave 2.7 no editor antes de avancar. Se o fluxo coleta -> deposito -> construcao funcionar sem erros, a proxima wave pode introduzir uma primeira interface simples de construcao ou a primeira entidade NPC trabalhadora, dependendo da prioridade do projeto.
