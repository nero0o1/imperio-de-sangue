# ADR-0007 - Wave 3.1: Armazem multirrecurso

## Status

Proposto

## Contexto

O prototipo Godot 4.x em primeira pessoa ja validou a separacao entre a logica de construcao (`BuildingSite`) e a camada visual (`BuildingVisualState`). A Wave 3.0, porem, manteve o armazem e a construcao presos a um fluxo tecnico simples demais: depositar e consumir apenas `wood`.

Para um prototipo jogavel e demonstravel para publico, a fantasia minima precisa ficar palpavel: coletar recursos diferentes, depositar em um armazem comunitario e construir estruturas com receitas simples.

## Decisao

Implementar armazem multirrecurso com estoque em `Dictionary`:

```gdscript
{
	"wood": 20,
	"stone": 10,
}
```

O inventario do jogador tambem passa a expor uma API de recursos por `resource_id`, preservando compatibilidade com a API antiga de itens.

`ResourcePickup` passa a ser configuravel por `resource_id` e `amount`.

`WarehouseInteractable` deixa de ter um `resource_id` fixo e, ao interagir, transfere todos os recursos carregados pelo ator para o armazem.

`BuildingSite` passa a usar receita explicita:

```gdscript
required_resources = {
	"wood": 20,
	"stone": 10,
}
step_count = 2
```

Cada etapa custa `required_resources / step_count`, ou seja:

```gdscript
{
	"wood": 10,
	"stone": 5,
}
```

Politica WAREHOUSE_ONLY:

Building sites consume only from shared warehouse stock. Actor inventories are used only for carrying and depositing resources.

`BuildingVisualState` permanece desacoplado e depende apenas de `build_progress` e `is_completed`.

## Alternativas consideradas

- Manter `wood` como unico recurso: rejeitado porque nao comunica a fantasia minima do prototipo jogavel.
- Fazer `BuildingSite` consumir diretamente do inventario do jogador: rejeitado porque quebra o papel do armazem comunitario.
- Criar um sistema completo de itens, crafting e UI de inventario: rejeitado por estar fora do escopo desta Wave.
- Usar o `InventoryContainer` interno como unica fonte de verdade do armazem: rejeitado para deixar o contrato `stock: Dictionary` explicito no armazem, mantendo apenas compatibilidade com sistemas antigos.

## Consequencias

- O loop principal agora suporta `wood` e `stone`.
- Construcoes so avancam quando o armazem possui todos os recursos da etapa.
- `consume_resources` e atomico: falta parcial nao consome recursos disponiveis.
- O inventario do jogador fica restrito ao papel de carregar e depositar.
- HUD/debug consegue exibir inventario, estoque multirrecurso e estado de construcao.
- Codigos antigos que usam `deposit`, `withdraw`, `can_pay`, `pay` e `get_all_items` continuam funcionando como aliases de compatibilidade.

Nota Wave 3.1.3: eventos economicos do fluxo `ResourcePickup -> PlayerInventory -> Warehouse -> BuildingSite` devem preservar `before`, `after` e `delta`. O deposito valida conservacao basica entre player e armazem e recebe marcadores leves de integridade de evento. Esta trilha e diagnostica e nao substitui autoridade externa ou anti-cheat real.

## Criterios de aceite

- Player coleta `wood`.
- Player coleta `stone`.
- PlayerInventory suporta multiplos recursos.
- Warehouse deposita e mantem `wood` e `stone` por `resource_id`.
- Deposito transfere todos os recursos do ator.
- BuildingSite usa `required_resources`.
- BuildingSite exige `wood` e `stone`.
- BuildingSite consome exclusivamente do Warehouse.
- BuildingSite nao consome diretamente do PlayerInventory.
- `consume_resources` nao consome parcialmente em caso de falha.
- Construcoes concluidas nao consomem recursos adicionais.
- HUD/debug mostra estoque multirrecurso.
- BuildingVisualState continua sem dependencia de recursos, armazem ou inventario.
- Cena de teste valida o loop completo.
