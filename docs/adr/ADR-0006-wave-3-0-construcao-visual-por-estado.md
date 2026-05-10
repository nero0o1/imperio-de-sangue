# ADR-0006 - Wave 3.0: Construcao visual por estado

## Status

Aceita

## Contexto

A cena-laboratorio `res://scenes/test/TestInventoryWarehouse.tscn` ja validava coleta, deposito em armazem e construcao via `BuildingSite`. O jogador, porem, tinha pouco feedback espacial para distinguir se o canteiro estava em fundacao, em construcao parcial ou concluido.

A regra de dominio continua centralizada em `BuildingSite`: `build_progress`, `is_completed`, custos e politica `WAREHOUSE_ONLY` nao devem ser alterados por esta Wave.

## Decisao

Criar a subcena `res://scenes/buildings/BuildingVisualState.tscn`, controlada por `res://scripts/building/building_visual_state.gd`.

O controlador exporta `building_site_path: NodePath`, le apenas `build_progress` e `is_completed`, e alterna tres grupos visuais exclusivos:

| Estado | Visual |
| --- | --- |
| `0%` e nao concluido | `FoundationVisual` |
| `> 0%` e `< 100%` e nao concluido | `UnderConstructionVisual` |
| `is_completed` ou `>= 100%` | `CompletedVisual` |

Os placeholders usam apenas `MeshInstance3D`, sem colisao fisica. Assim, futuras artes finais podem substituir os meshes/filhos de `FoundationVisual`, `UnderConstructionVisual` e `CompletedVisual` sem reestruturar a cena ou alterar a logica de construcao.

Tambem foram adicionadas duas subcenas de ambiente reutilizaveis:

- `res://scenes/environment/CenarioGrande.tscn`
- `res://scenes/environment/CenarioParedes.tscn`

Elas sao instanciadas na cena-laboratorio para ampliar o contexto visual em volta do jogador e da construcao.

## Alternativas Consideradas

- Apenas mudar a cor do cubo do `BuildingSite`: menor custo, mas fraco para leitura a distancia e pouco substituivel por arte final.
- Animar o proprio `BuildingSite`: aumentaria acoplamento com a logica interativa.
- Criar um sistema dinamico de multiplas construcoes: util no futuro, mas fora do escopo desta Wave.

## Consequencias

- Feedback visual mais claro para jogador e futuros NPCs.
- O `BuildingSite_Test` permanece como ponto interativo e autoridade de estado.
- A cena visual e substituivel por modelos finais sem alterar scripts de dominio.
- O ambiente de teste fica mais representativo sem adicionar IA, economia ou novas regras.
