# Arquivo 16 — Wave 2.5 — Sistema de Estoque, Inventário e Armazéns Compartilhados

## 1. Objetivo técnico

A Wave 2.5 define o sistema base de inventário, estoque, armazéns compartilhados e disponibilidade de recursos para jogador, NPCs e construções.

O objetivo não é criar um inventário visual complexo neste momento. O objetivo é estabelecer uma arquitetura funcional, expansível e testável para que os sistemas de construção, coleta, produção, transporte e defesa possam consumir recursos de forma previsível.

Esta Wave existe para evitar que cada entidade do jogo trate itens de forma isolada. O inventário pessoal do jogador, os carregamentos simples dos NPCs e os armazéns da cidade devem operar sobre uma mesma lógica de recursos.

---

## 2. Escopo da Wave 2.5

Esta Wave cobre:

- Modelo lógico de item.
- Modelo lógico de pilha de item.
- Inventário pessoal do jogador.
- Inventário simplificado de NPC.
- Armazém compartilhado por assentamento ou construção.
- Consulta de disponibilidade de recursos.
- Consumo de recursos para construção.
- Depósito e retirada de recursos.
- Separação entre item carregado e item disponível no armazém.
- Base para integração futura com UI de inventário estilo SkyUI.

Esta Wave não cobre:

- Interface visual definitiva.
- Sistema de peso avançado.
- Economia completa.
- Comércio entre cidades.
- Crafting complexo.
- Equipamentos detalhados.
- Loot procedural avançado.
- Balanceamento final de capacidade.

---

## 3. Decisão de design

O inventário do jogo deve seguir uma lógica inspirada em inventários profissionais de RPG para PC, com organização por categorias, filtros e leitura rápida.

A referência funcional é um inventário no estilo SkyUI, usado em Skyrim, porque ele é adequado para muitos itens, permite organização eficiente e funciona bem com mouse e teclado.

A implementação inicial, porém, deve ser simples. Primeiro se constrói o núcleo de dados. A interface visual deve ser acoplada depois.

A regra correta para esta fase é:

> Primeiro o sistema precisa saber guardar, consultar, transferir e consumir itens. Depois ele precisa parecer bonito.

---

## 4. Princípios do sistema

### 4.1 Inventário pessoal do jogador

O jogador pode carregar itens diretamente.

Esse inventário deve aceitar no futuro:

- Armas.
- Ferramentas.
- Recursos.
- Consumíveis.
- Materiais raros.
- Itens de missão.

Na fase atual, o foco é recurso simples.

Exemplo:

- Madeira.
- Pedra.
- Ferro.
- Comida.
- Tecido.
- Couro.

---

### 4.2 Inventário de NPCs

NPCs não precisam de inventário complexo no protótipo.

Cada NPC deve ter apenas:

- Item ou ferramenta em uso.
- Pequena carga temporária.
- Capacidade de retirar/depositar recursos em armazéns.

NPCs construtores, coletores e trabalhadores devem usar preferencialmente os recursos do armazém compartilhado.

Isso reduz complexidade e evita que o jogo precise simular dezenas de inventários completos sem necessidade.

---

### 4.3 Armazém compartilhado

O armazém é a entidade central de recursos do assentamento.

Ele representa os itens disponíveis para:

- Construções automáticas.
- NPCs trabalhadores.
- Produção futura.
- Defesa futura.
- Expansão do assentamento.

A construção pelos NPCs deve ser mais lenta que a construção direta do jogador, mas deve ser automática e constante.

Essa decisão cria um equilíbrio funcional:

- O jogador constrói rápido quando está presente.
- Os NPCs mantêm progresso quando o jogador está longe.
- O armazém funciona como ponto comum de suprimento.

---

## 5. Fluxo lógico principal

### 5.1 Coleta pelo jogador

1. Jogador coleta recurso.
2. Recurso entra no inventário pessoal.
3. Jogador pode usar diretamente ou depositar no armazém.
4. Construções próximas podem consumir do armazém se a regra permitir.

---

### 5.2 Coleta por NPC

1. NPC recebe tarefa de coleta.
2. NPC coleta recurso no mundo.
3. NPC carrega quantidade limitada.
4. NPC retorna ao armazém.
5. NPC deposita o recurso.
6. O recurso passa a ficar disponível para o assentamento.

---

### 5.3 Construção pelo jogador

1. Jogador seleciona construção.
2. Sistema consulta recursos disponíveis.
3. Sistema pode consumir recursos do inventário pessoal, do armazém ou de ambos.
4. Construção avança rapidamente.

---

### 5.4 Construção por NPC

1. Construção entra na fila automática.
2. NPC construtor consulta armazém.
3. Se houver recursos, NPC reserva ou consome parte dos materiais.
4. NPC executa progresso lento e constante.
5. Se faltarem recursos, a construção fica aguardando suprimento.

---

## 6. Estrutura técnica recomendada em Godot

### 6.1 Scripts sugeridos

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
```

---

## 7. ItemDefinition

Representa o tipo do item.

Campos mínimos:

```text
id: StringName
name: String
category: StringName
max_stack: int
is_resource: bool
```

Exemplo:

```text
id = "wood"
name = "Madeira"
category = "resource"
max_stack = 99
is_resource = true
```

---

## 8. ItemStack

Representa uma quantidade de um item.

Campos mínimos:

```text
item_id: StringName
quantity: int
```

Regras:

- quantity nunca deve ser negativa.
- item_id deve existir no catálogo de itens.
- pilhas iguais podem ser somadas.
- pilhas diferentes não podem ser somadas.

---

## 9. InventoryContainer

Classe base para qualquer inventário.

Responsabilidades:

- Adicionar item.
- Remover item.
- Consultar quantidade.
- Verificar se possui recursos suficientes.
- Transferir item para outro container.

Métodos mínimos:

```text
add_item(item_id, quantity) -> int
remove_item(item_id, quantity) -> int
get_quantity(item_id) -> int
has_items(costs) -> bool
transfer_to(target, item_id, quantity) -> int
```

Retorno recomendado:

- `add_item` retorna a quantidade que não coube.
- `remove_item` retorna a quantidade removida.
- `transfer_to` retorna a quantidade transferida.

---

## 10. PlayerInventory

Extensão de InventoryContainer.

Responsabilidades futuras:

- Integrar com UI.
- Integrar com hotbar.
- Integrar com equipamento.
- Integrar com peso ou capacidade.

No protótipo, ele pode herdar quase tudo da classe base.

---

## 11. NpcInventory

Extensão simplificada de InventoryContainer.

Regras recomendadas:

- Capacidade menor.
- Poucas pilhas.
- Sem UI própria inicialmente.
- Usado apenas para transporte temporário.

O NPC não deve operar como baú ambulante complexo.

---

## 12. Warehouse

Representa armazém compartilhado.

Responsabilidades:

- Guardar recursos do assentamento.
- Permitir depósito por jogador e NPCs.
- Permitir consumo por construções.
- Informar disponibilidade para sistemas automáticos.

Campos mínimos:

```text
warehouse_id: StringName
settlement_id: StringName
inventory: InventoryContainer
```

Métodos mínimos:

```text
deposit(item_id, quantity) -> int
withdraw(item_id, quantity) -> int
get_available(item_id) -> int
can_pay(costs) -> bool
pay(costs) -> bool
```

---

## 13. StorageManager

Gerencia armazéns.

Responsabilidades:

- Registrar armazéns.
- Encontrar armazém por assentamento.
- Somar recursos disponíveis entre múltiplos armazéns.
- Escolher de qual armazém consumir.

Na fase inicial, pode existir apenas um armazém global de teste.

Depois, o jogo pode evoluir para:

- Armazém por cidade.
- Armazém por distrito.
- Armazém por construção.
- Rede logística entre armazéns.

---

## 14. BuildCost

Representa custo de construção.

Exemplo:

```text
Casa simples:
- Madeira: 20
- Pedra: 10
```

Campos mínimos:

```text
building_id: StringName
costs: Dictionary[StringName, int]
```

---

## 15. BuildingResourceConsumer

Sistema responsável por consumir recursos para construção.

Responsabilidades:

- Verificar custo.
- Consultar inventário do jogador.
- Consultar armazém.
- Aplicar política de consumo.
- Liberar progresso de construção.

Políticas possíveis:

```text
PLAYER_ONLY
WAREHOUSE_ONLY
PLAYER_THEN_WAREHOUSE
WAREHOUSE_THEN_PLAYER
```

Para protótipo, a política recomendada é:

```text
WAREHOUSE_THEN_PLAYER
```

Motivo:

- Incentiva o uso do armazém como infraestrutura central.
- Mantém o jogador livre para carregar itens importantes.
- Facilita construção automática por NPC.

---

## 16. Regras de consistência

O sistema deve obedecer às seguintes regras:

1. Nenhum item pode ter quantidade negativa.
2. Nenhuma construção pode consumir item inexistente.
3. Nenhum NPC deve criar recurso do nada.
4. Todo recurso usado em construção deve sair de algum container válido.
5. Armazém não deve depender da UI.
6. Inventário não deve depender de construção.
7. Construção consulta inventário/armazém por serviço, não por acesso direto desorganizado.
8. O sistema deve funcionar mesmo sem interface visual.

---

## 17. Testes mínimos

### 17.1 Teste de depósito

Entrada:

```text
warehouse.deposit("wood", 10)
```

Resultado esperado:

```text
warehouse.get_available("wood") == 10
```

---

### 17.2 Teste de retirada

Entrada:

```text
warehouse.withdraw("wood", 4)
```

Resultado esperado:

```text
warehouse.get_available("wood") == 6
```

---

### 17.3 Teste de custo suficiente

Entrada:

```text
cost = {"wood": 5, "stone": 2}
warehouse contém wood=10, stone=3
```

Resultado esperado:

```text
warehouse.can_pay(cost) == true
```

---

### 17.4 Teste de custo insuficiente

Entrada:

```text
cost = {"wood": 20}
warehouse contém wood=10
```

Resultado esperado:

```text
warehouse.can_pay(cost) == false
```

---

### 17.5 Teste de construção automática

Entrada:

```text
Construção custa wood=10
Armazém contém wood=15
NPC construtor inicia tarefa
```

Resultado esperado:

```text
Construção consome wood=10
Armazém fica com wood=5
Construção entra em progresso
```

---

## 18. Ordem de implementação recomendada

1. Criar ItemDefinition.
2. Criar ItemStack.
3. Criar InventoryContainer.
4. Criar Warehouse.
5. Criar StorageManager.
6. Criar BuildCost.
7. Criar BuildingResourceConsumer.
8. Criar teste manual com armazém global.
9. Integrar jogador depositando recurso.
10. Integrar NPC depositando recurso.
11. Integrar construção consumindo recurso.
12. Só depois criar UI de inventário.

---

## 19. Critério de aceite da Wave 2.5

A Wave 2.5 pode ser considerada concluída quando:

- O jogo possui ao menos um armazém funcional.
- O jogador consegue adicionar recursos ao sistema.
- O armazém consegue guardar e informar quantidades.
- Uma construção consegue consultar e consumir recursos.
- NPCs podem ser integrados sem inventário complexo.
- A lógica funciona sem interface visual definitiva.
- O sistema não depende de valores hardcoded espalhados em múltiplos scripts.

---

## 20. Risco técnico principal

O principal risco é tentar criar uma interface bonita antes de estabilizar a lógica de dados.

Isso deve ser evitado.

A prioridade correta é:

```text
Dados > Regras > Testes > Integração > Interface
```

---

## 21. Decisão final da Wave

A arquitetura deve adotar um sistema centralizado de armazéns compartilhados, com inventário pessoal para o jogador e inventário mínimo para NPCs.

Essa decisão reduz complexidade, facilita construção automática e cria base sólida para expansão futura do jogo.
