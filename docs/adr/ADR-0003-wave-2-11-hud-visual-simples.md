# ADR-0003 - Wave 2.11 HUD Visual Simples

## Status

Accepted

## Date

2026-05-04

## Context

O projeto validou fluxo de inventario, armazem, construcao, observabilidade JSON e player movement nas Waves 2.7 a 2.9. A Wave 2.10 consolidou um baseline reconstruivel. O proximo risco pratico e a dependencia excessiva do Output/console para entender estado durante testes manuais.

A cena-laboratorio principal continua sendo `res://scenes/test/TestInventoryWarehouse.tscn`, com fluxo `coleta -> PlayerInventory -> Warehouse -> BuildingSite`, politica efetiva `WAREHOUSE_ONLY`, custo `wood = 10` por etapa e progresso esperado `0 -> 50 -> 100`.

Existe uma pasta local `res://modelo de inventario/` com arquivos de referencia coletados de projetos externos. Essa pasta deve orientar arquitetura e direcao visual, mas nao deve ser importada como dependencia, addon ou fonte de codigo copiado nesta Wave.

## Alternatives Considered

1. Manter apenas Output/JSON.
2. Criar UI final estilo SkyUI.
3. Criar HUD visual simples modular.
4. Criar NPC antes de HUD.

## Decision

Criar uma HUD visual simples, modular e somente leitura, composta por paineis separados para PlayerInventory, Warehouse e BuildingSite.

A HUD segue direcao PC-first inspirada por listas/tabelas de inventario, nao por grade de slots estilo Minecraft. Ela apresenta busca textual como elemento estrutural inicial e organiza itens em linhas textuais com nome, categoria, quantidade, peso, valor e raridade, deixando os valores ainda nao implementados como placeholders.

## Consequences

- Melhora teste manual.
- Reduz dependencia do console.
- Mantem dominio desacoplado.
- Nao substitui UI final.
- Cria base para futuras telas de inventario/armazem.
- Preserva logs JSON como fonte de auditoria tecnica.
- Adia drag and drop, grid inventory, equipamentos, crafting e NPCs.

## Supersedes

None
