# ADR-0001 - Wave 2.8: Governanca, assertividade semantica e observabilidade

## Status

Accepted

## Date

2026-05-03

## Context

A cena-laboratorio `res://scenes/test/TestInventoryWarehouse.tscn` valida o fluxo coleta -> PlayerInventory -> Warehouse -> BuildingSite. O baseline obrigatorio mantem `BuildingSite_Test` com politica efetiva `WAREHOUSE_ONLY`, custo `{ &"wood": 10 }` por etapa e progresso esperado `0 -> 50 -> 100`.

As Waves anteriores ja implementaram coleta, deposito, consumo e progresso. A Wave 2.8 endurece esse fluxo com governanca, logs estruturados e uma probe semantica para evidenciar `before`, `after` e `delta` das transacoes relevantes, sem reabrir escopo para UI final, NPCs, crafting, economia, save/load, combate real ou multiplos armazens.

## Alternatives Considered

- Manter apenas logs textuais simples: menor custo, mas pouca rastreabilidade e baixa capacidade de detectar mutacoes silenciosas.
- Alterar a politica da cena para permitir consumo combinado: rejeitado porque o laboratorio exige `WAREHOUSE_ONLY`.
- Introduzir uma UI de debug mais rica: rejeitado por estar fora do escopo da Wave 2.8.
- Adicionar observabilidade estruturada com probe semantica: escolhido por aumentar verificabilidade sem mudar a semantica de gameplay.

## Decision

Adicionar um logger estruturado de eventos de dominio e uma probe semantica de teste para medir estados antes/depois/delta em operacoes de coleta, deposito e construcao. Instrumentar os scripts de runtime apenas para emitir eventos observaveis, preservando regras atuais de custo, progresso e politica `WAREHOUSE_ONLY` na cena-laboratorio.

## Consequences

- Interacoes validas e bloqueadas passam a emitir eventos serializados com `state.before`, `state.after`, `delta` e `semantic_integrity`.
- Falhas como saldo insuficiente, referencia invalida e construcao concluida ficam explicitas no Output.
- A probe cria uma base para testes de integridade semantica, incluindo conservacao de quantidade e bloqueio de consumo apos conclusao.
- O projeto continua sem UI final, NPCs, crafting, economia ou sistemas fora do escopo.

## Supersedes

None
