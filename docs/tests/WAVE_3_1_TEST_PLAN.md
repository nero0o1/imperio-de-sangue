# Wave 3.1 - Test Plan

## 1. Coletar wood

1. Abrir `scenes/test/TestInventoryWarehouse.tscn`.
2. Iniciar a cena.
3. Interagir com `WoodPickup`.
4. Confirmar no HUD/debug que o inventario do jogador contem `wood: 10`.
5. Interagir mais duas vezes com `WoodPickup`.
6. Confirmar no HUD/debug que o inventario do jogador contem `wood: 30`.
7. Confirmar logs semelhantes a `[ResourcePickup] Coletado wood x10. Restante: 20.`, `Restante: 10.` e `Restante: 0.`

## 2. Coletar stone

1. Interagir com `StonePickup`.
2. Confirmar no HUD/debug que o inventario do jogador contem `stone: 10`.
3. Confirmar log semelhante a `[ResourcePickup] Coletado stone x10.`

## 3. Depositar ambos

1. Interagir com `WarehouseInteractable_Test`.
2. Confirmar que o inventario do jogador fica vazio.
3. Confirmar que o Warehouse mostra `wood: 30` e `stone: 10`.
4. Confirmar logs de deposito para os dois recursos.

## 4. Construir com estoque suficiente

1. Interagir com `BuildingSite_Test`.
2. Confirmar que o armazem passa para `wood: 20` e `stone: 5`.
3. Confirmar progresso em `50%`.
4. Interagir novamente com `BuildingSite_Test`.
5. Confirmar que o armazem fica com `wood: 10` e sem `stone`.
6. Confirmar progresso em `100%` e `Completed: true`.

## 5. Tentar construir com falta parcial de stone

1. Reiniciar a cena ou preparar estado com `wood: 10` no armazem e `stone: 0`.
2. Interagir com `BuildingSite_Test`.
3. Confirmar que a construcao nao avanca.
4. Confirmar que `wood` continua com a mesma quantidade.
5. Confirmar log de recursos insuficientes com custo `wood` + `stone`.

## 6. Tentar construir com recurso no inventario mas sem deposito

1. Reiniciar a cena.
2. Coletar `wood` e `stone`.
3. Nao interagir com o armazem.
4. Interagir com `BuildingSite_Test`.
5. Confirmar que a construcao nao avanca.
6. Confirmar que o inventario do jogador nao foi consumido.

## 7. Tentar interagir com construcao concluida

1. Concluir a construcao.
2. Adicionar ou depositar mais recursos no armazem, se necessario.
3. Interagir novamente com `BuildingSite_Test`.
4. Confirmar que nenhum recurso adicional e consumido.
5. Confirmar log de construcao ja concluida.

## 8. Verificar HUD/debug

1. Observar o HUD durante o loop completo.
2. Confirmar que ele exibe:

```text
Após depósito:
Player Inventory:
vazio

Warehouse:
wood: 30
stone: 10

Building:
Progress: 0%
Completed: false

Após primeira etapa:
Player Inventory:
vazio

Warehouse:
wood: 20
stone: 5

Building:
Progress: 50%
Completed: false

Após segunda etapa:
Player Inventory:
vazio

Warehouse:
wood: 10
stone: 0 ou ausência de stone

Building:
Progress: 100%
Completed: true
```

3. Confirmar que HUD/debug apenas le estado e nao altera inventario, armazem ou construcao.

## 9. Coleta progressiva do WoodPickup

1. Reiniciar a cena.
2. Interagir uma vez com `WoodPickup`.
3. Confirmar `Player Inventory: wood: 10`.
4. Interagir segunda vez com `WoodPickup`.
5. Confirmar `Player Inventory: wood: 20`.
6. Interagir terceira vez com `WoodPickup`.
7. Confirmar `Player Inventory: wood: 30`.

## 10. WoodPickup removido ao esgotar

1. Reiniciar a cena.
2. Interagir 3 vezes com WoodPickup.
3. Confirmar Player Inventory: wood: 30.
4. Confirmar que WoodPickup não permanece visível no mapa.
5. Confirmar que WoodPickup não permanece interagível.
6. Confirmar log semelhante:
   `[ResourcePickup] Coletado wood x10. Restante: 0.`
   `[ResourcePickup] wood esgotado. Removendo pickup.`

## 11. Sobra de wood no armazem

1. Coletar `WoodPickup` tres vezes e `StonePickup` uma vez.
2. Depositar no armazem.
3. Construir duas etapas.
4. Confirmar `Warehouse: wood: 10`.
5. Confirmar `Warehouse: stone: 0` ou ausencia de `stone`.
