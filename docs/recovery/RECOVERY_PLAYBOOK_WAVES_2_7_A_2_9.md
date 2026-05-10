# Recovery Playbook - Waves 2.7 a 2.9

## Objetivo

Este playbook descreve como recuperar e revalidar o baseline jogavel de inventario, armazem e construcao caso algo quebre.

## Como reconstruir o projeto se algo quebrar

1. Abrir o projeto pela pasta que contem `project.godot`.
2. Confirmar que os arquivos criticos existem conforme `res://docs/baseline/FILE_MANIFEST_WAVES_2_7_A_2_9.json`.
3. Conferir hashes SHA256 quando houver suspeita de alteracao acidental.
4. Abrir `res://scenes/test/TestInventoryWarehouse.tscn`.
5. Confirmar que os nos de laboratorio existem.
6. Executar os testes headless, se Godot estiver disponivel.
7. Executar o checklist manual.

## Ordem de restauracao

1. `project.godot`
2. Scripts de inventario.
3. Scripts de armazem.
4. Scripts de construcao.
5. Scripts de recursos.
6. Scripts do Player e RayCast.
7. Scripts de debug/observabilidade.
8. Cena `TestInventoryWarehouse.tscn`.
9. Documentacao e ADRs.

## Fontes de verdade

- Contratos de runtime: scripts em `res://scripts/`.
- Cena-laboratorio: `res://scenes/test/TestInventoryWarehouse.tscn`.
- Baseline aceito: `res://docs/baseline/BASELINE_WAVES_2_7_A_2_9.md`.
- Manifest com hashes: `res://docs/baseline/FILE_MANIFEST_WAVES_2_7_A_2_9.json`.
- Decisoes arquiteturais:
  - `res://docs/adr/ADR-0001-wave-2-8-governanca-observabilidade.md`
  - `res://docs/adr/ADR-0002-wave-2-10-baseline-consolidado.md`

## Como validar apos restauracao

1. Abrir projeto sem erro vermelho.
2. Abrir `TestInventoryWarehouse.tscn`.
3. Executar cena.
4. Validar Player.
5. Validar coleta.
6. Validar deposito.
7. Validar construcao.
8. Validar bloqueio apos conclusao.
9. Validar logs JSON.

## Como reconhecer regressao

Ha regressao se qualquer uma destas situacoes ocorrer:

- Projeto nao abre.
- Cena-laboratorio nao abre.
- Player nao aparece.
- `E` nao interage.
- RayCast gera erro sem alvo.
- Coleta nao adiciona item ao PlayerInventory.
- Deposito cria ou perde quantidade indevidamente.
- Construcao consome do Player em politica `WAREHOUSE_ONLY`.
- Construcao avanca sem recurso no Warehouse.
- Construcao concluida consome novamente.
- Logs JSON desaparecem.
- `semantic_integrity` aparece como `fail`.

## Como revalidar inventario

Verificar:

- `InventoryContainer.add_item`
- `InventoryContainer.remove_item`
- `InventoryContainer.get_quantity`
- `InventoryContainer.has_items`
- `InventoryContainer.remove_items`
- `InventoryContainer.transfer_to`

Teste minimo:

1. Criar/usar PlayerInventory.
2. Adicionar `wood = 10`.
3. Remover `wood = 10`.
4. Confirmar saldo `0`.
5. Tentar remover mais do que existe.
6. Confirmar que saldo nao fica negativo.

## Como revalidar player.gd

Validar:

- WASD.
- Mouse.
- `Space` no chao.
- `Space` no ar.
- `Shift` no chao.
- `Shift` no ar.
- `E`.
- Ataque stub.
- `Esc`.
- `get_inventory()`.

Se `get_inventory()` falhar, ResourcePickup e WarehouseInteractable podem nao encontrar o inventario do jogador.

## Como revalidar logs estruturados

Procurar linhas JSON no Output com:

- `body = named_domain_event`
- `attributes.event_name`
- `attributes.operation_id`
- `attributes.idempotency_key`
- `attributes.state.before`
- `attributes.state.after`
- `attributes.delta`
- `attributes.semantic_integrity`

Se `schema_validation_failed` aparecer, tratar como falha de observabilidade.

## Como revalidar cena-laboratorio

Nos obrigatorios:

- `Player`
- `Player/PlayerInventory`
- `ResourcePickup_Wood`
- `ResourcePickup_Wood_2`
- `ResourcePickup_Stone`
- `Warehouse_Test`
- `WarehouseInteractable_Test`
- `BuildingSite_Test`
- `CanvasLayer/InventoryDebugHUD`

Configuracoes obrigatorias:

- `WarehouseInteractable_Test.warehouse_path = ../Warehouse_Test`
- `WarehouseInteractable_Test.accepted_item_id = wood`
- `WarehouseInteractable_Test.deposit_amount = 10`
- `BuildingSite_Test.required_costs = { &"wood": 10 }`
- `BuildingSite_Test.build_progress_per_payment = 50.0`
- `BuildingSite_Test.consume_policy = WAREHOUSE_ONLY`

## Comandos Godot headless

Se o executavel estiver no PATH:

```powershell
godot --headless --path O:\game --quit
```

Para rodar o teste por script, se o ambiente aceitar `--script` diretamente:

```powershell
godot --headless --path O:\game --script res://scripts/tests/inventory_system_test.gd
```

Se o teste nao encerrar sozinho, usar um runner temporario fora do repositorio que instancie `inventory_system_test.gd`, aguarde frames e chame `quit()`.

## Procedimento se Godot nao estiver no PATH

1. Localizar o executavel Godot instalado.
2. Usar caminho absoluto para o console/headless.
3. Exemplo observado neste ambiente:

```powershell
& 'C:\Users\timne\Downloads\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64_console.exe' --headless --path 'O:\game' --quit
```

## Procedimento se a cena nao abrir

1. Conferir se todos os `ext_resource` da cena existem.
2. Conferir se scripts referenciados compilam.
3. Conferir se `Player.tscn` existe.
4. Conferir se subresources de mesh/collision nao foram removidos.
5. Se o erro for de material nulo em renderer dummy headless, validar no editor antes de tratar como regressao de gameplay.

## Procedimento se JSON nao aparecer

1. Confirmar que a interacao realmente atingiu o alvo.
2. Confirmar que `interaction_raycast.gd` chamou `interact(actor)`.
3. Confirmar se `domain_event_logger.gd` existe.
4. Confirmar se o script do alvo tem preload do logger ou `class_name` acessivel.
5. Confirmar se houve retorno antecipado antes da emissao do evento.

## Procedimento se semantic_integrity falhar

1. Copiar o evento JSON completo.
2. Comparar `state.before`, `delta` e `state.after`.
3. Verificar se algum saldo ficou negativo.
4. Verificar se falha bloqueada alterou estado.
5. Verificar se build bem-sucedido consumiu exatamente o custo configurado.
6. Se o erro for em cena-laboratorio, nao avancar para Wave seguinte.
