# Arquivo 17 — Wave 2.6 — Implementação do Sistema de Inventário, Estoque e Armazéns

## 1. Objetivo técnico

Este arquivo implementa a base operacional do sistema de inventário definido no Arquivo 16.

A Wave 2.6 entrega os scripts iniciais em GDScript para:

- Definição de itens.
- Pilhas de itens.
- Inventário genérico reutilizável.
- Inventário do jogador.
- Inventário simplificado de NPC.
- Armazém compartilhado.
- Gerenciador de armazéns.
- Custo de construção.
- Consumo de recursos por construção.
- Script de teste manual para validar a lógica sem depender de interface visual.

A prioridade desta Wave é lógica estável, previsível e fácil de testar.

---

## 2. Decisão de arquitetura

O inventário visual deve ser criado depois. Nesta fase, o núcleo de dados precisa funcionar sozinho.

Ordem correta:

```text
Dados > Regras > Testes > Integração > Interface
```

O sistema foi separado em três blocos:

```text
inventory/  -> armazenamento genérico de itens
storage/    -> armazéns compartilhados
building/   -> consumo de recursos por construções
```

---

## 3. Arquivos criados

```text
res://scripts/inventory/item_definition.gd
res://scripts/inventory/item_stack.gd
res://scripts/inventory/inventory_container.gd
res://scripts/inventory/player_inventory.gd
res://scripts/inventory/npc_inventory.gd
res://scripts/storage/warehouse.gd
res://scripts/storage/storage_manager.gd
res://scripts/building/build_cost.gd
res://scripts/building/building_resource_consumer.gd
res://scripts/tests/inventory_system_test.gd
```

---

## 4. Critério de aceite

A Wave 2.6 está concluída quando o teste manual confirma:

- Adicionar recursos ao inventário funciona.
- Remover recursos funciona.
- Transferir recursos entre inventários funciona.
- Armazém recebe depósito.
- Armazém permite retirada.
- Sistema reconhece custo suficiente.
- Sistema bloqueia custo insuficiente.
- Construção consome recursos do armazém.
- Nenhuma quantidade fica negativa.

---

## 5. Como testar no Godot

1. Execute este gerador Python na raiz do projeto Godot.
2. Abra o projeto no Godot.
3. Crie um Node vazio em uma cena de teste.
4. Anexe o script:

```text
res://scripts/tests/inventory_system_test.gd
```

5. Execute a cena.
6. Verifique o console.

Resultado esperado:

```text
[PASS] Todos os testes do sistema de inventário foram concluídos.
```

---

## 6. Observação técnica

Este sistema ainda não tem UI. Isso é intencional.

A interface estilo SkyUI deve consumir esses scripts depois, não misturar lógica visual com regra de inventário.
