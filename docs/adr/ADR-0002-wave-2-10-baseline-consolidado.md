# ADR-0002 - Wave 2.10: Baseline Consolidado e Plano de Continuidade

## Status

Accepted

## Date

2026-05-03

## Context

As Waves 2.7 a 2.9 implementaram e validaram o fluxo jogavel de inventario, armazem e construcao, alem de observabilidade JSON e controle fisico basico do Player.

O projeto agora possui uma cena-laboratorio principal em `res://scenes/test/TestInventoryWarehouse.tscn`, onde o fluxo alvo e coleta -> PlayerInventory -> Warehouse -> BuildingSite. A politica efetiva do `BuildingSite_Test` permanece `WAREHOUSE_ONLY`, o custo de validacao e `wood = 10` por etapa, o progresso esperado e `0 -> 50 -> 100`, e `is_completed = true` bloqueia qualquer novo consumo.

Antes de avancar para HUD visual, multiplos Build Sites ou NPC trabalhador, o projeto precisa de documentacao reconstruivel para reduzir dependencia da memoria da conversa e facilitar validacao futura.

## Alternatives Considered

1. Avancar direto para HUD.
2. Avancar direto para NPC.
3. Criar apenas um resumo informal.
4. Criar baseline consolidado + recovery playbook + roadmap.

## Decision

Criar baseline consolidado, checklist manual, matriz de testes, roadmap e playbook de recuperacao antes de adicionar novos sistemas.

Esta decisao tambem registra hashes dos arquivos criticos em um manifest JSON, preserva ADRs existentes por append-only e define a cena-laboratorio como referencia principal para continuidade.

## Consequences

- Aumenta rastreabilidade.
- Reduz risco de regressao.
- Facilita reconstrucao do projeto.
- Facilita onboarding tecnico futuro.
- Atrasa levemente gameplay novo.
- Cria base para a proxima Wave 2.11.
- Mantem runtime intocado nesta Wave.

## Supersedes

None
