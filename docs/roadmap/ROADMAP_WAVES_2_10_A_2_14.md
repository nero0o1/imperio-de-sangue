# Roadmap Waves 2.10 a 2.14

## Wave 2.10 - Baseline Consolidado

### Objetivo

Criar documentacao reconstruivel para validar e continuar o projeto sem depender da conversa.

### Escopo

- Baseline tecnico.
- Checklist manual.
- Roadmap.
- Recovery playbook.
- Matriz de testes.
- Manifest JSON com hashes.
- ADR append-only.

### Fora do escopo

- Gameplay novo.
- Alteracoes em scripts.
- Alteracoes em cenas.
- UI nova.
- NPCs.

### Arquivos provaveis

- `res://docs/baseline/BASELINE_WAVES_2_7_A_2_9.md`
- `res://docs/checklists/CHECKLIST_VALIDACAO_MANUAL_WAVES_2_7_A_2_9.md`
- `res://docs/roadmap/ROADMAP_WAVES_2_10_A_2_14.md`
- `res://docs/recovery/RECOVERY_PLAYBOOK_WAVES_2_7_A_2_9.md`
- `res://docs/testing/TEST_MATRIX_WAVES_2_7_A_2_9.md`
- `res://docs/baseline/FILE_MANIFEST_WAVES_2_7_A_2_9.json`
- `res://docs/adr/ADR-0002-wave-2-10-baseline-consolidado.md`

### Riscos

- Documentacao ficar divergente do estado real.
- Omitir hash ou caminho critico.

### Criterios de aceite

- Todos os documentos obrigatorios existem.
- JSON e valido.
- Hashes dos arquivos criticos registrados.
- Nenhum runtime alterado.

### Dependencias

- Estado validado das Waves 2.7 a 2.9.

### Rollback

- Remover apenas documentos criados nesta Wave, se necessario.
- Nao ha rollback de gameplay porque nenhum gameplay deve ser alterado.

### Decisao de avanco

Avancar somente se checklist manual puder ser executado pelo usuario.

## Wave 2.11 - HUD Visual Simples

### Objetivo

Substituir dependencia de leitura manual do Output por um HUD visual simples e nao definitivo.

### Escopo

- Mostrar madeira no PlayerInventory.
- Mostrar madeira no Warehouse.
- Mostrar progresso do BuildingSite.
- Mostrar estado concluido/nao concluido.
- Usar UI simples, sem estilo final.

### Fora do escopo

- SkyUI.
- Menus complexos.
- Inventario visual completo.
- Drag and drop.
- Crafting.

### Arquivos provaveis

- `res://scripts/debug/inventory_debug_hud.gd`
- `res://scenes/test/TestInventoryWarehouse.tscn`
- Possivel nova cena simples de HUD, se aprovado.

### Riscos

- Misturar UI definitiva com debug.
- Criar dependencia circular entre HUD e dominio.
- Quebrar cena-laboratorio por NodePaths incorretos.

### Criterios de aceite

- HUD mostra PlayerInventory, Warehouse e BuildingSite.
- HUD nao altera estado.
- Logs JSON continuam funcionando.
- Cena-laboratorio continua validavel.

### Dependencias

- Baseline Wave 2.10 aceito.
- Fluxo inventario/armazem/construcao estavel.

### Rollback

- Remover alteracoes de HUD e retornar ao Output/Debug HUD atual.

### Decisao de avanco

Avancar se o usuario quiser melhorar leitura de teste antes de expandir sistemas.

## Wave 2.12 - Construcao Visual por Estado

### Objetivo

Dar feedback visual simples para estados da construcao.

### Escopo

- Estado vazio/em progresso/concluido.
- Alteracao simples de cor, mesh ou escala.
- Feedback visual sem sistema de assets final.

### Fora do escopo

- Animacoes complexas.
- Sistema completo de edificacoes.
- Barricadas funcionais com dano.
- Arvore tecnologica.

### Arquivos provaveis

- `res://scripts/building/building_site.gd`
- `res://scenes/test/TestInventoryWarehouse.tscn`
- Possivel cena dedicada de BuildingSite visual.

### Riscos

- Alterar gameplay ao implementar feedback visual.
- Acoplar visual diretamente a regras de estoque.

### Criterios de aceite

- Progresso 0, 50 e 100 possui feedback perceptivel.
- Consumo continua identico.
- `WAREHOUSE_ONLY` continua preservado no laboratorio.

### Dependencias

- HUD ou debug suficiente para comparar estado visual e estado real.

### Rollback

- Reverter apenas mudancas visuais.

### Decisao de avanco

Avancar se o fluxo ja estiver facil de validar visualmente.

## Wave 2.13 - Multiplos Build Sites

### Objetivo

Validar que o sistema suporta mais de um canteiro de obras sem regressao.

### Escopo

- Dois ou mais Build Sites na cena-laboratorio ou nova cena de teste.
- Custos simples.
- Consumo ainda pelo armazem.
- Logs identificando corretamente cada `building_id`.

### Fora do escopo

- Multiplos armazens.
- Logistica automatica.
- NPC trabalhador.
- Priorizacao automatica.

### Arquivos provaveis

- `res://scenes/test/TestInventoryWarehouse.tscn` ou nova cena de teste.
- `res://scripts/building/building_site.gd`, somente se houver bug real.
- `res://scripts/tests/inventory_system_test.gd`.

### Riscos

- IDs duplicados.
- Logs ambiguos.
- NodePaths incorretos.

### Criterios de aceite

- Cada Build Site consome separadamente.
- Recursos insuficientes bloqueiam corretamente.
- Nenhum Build Site concluido consome novamente.

### Dependencias

- Observabilidade JSON estavel.
- Baseline reconstruivel.

### Rollback

- Remover Build Sites adicionais da cena de teste.

### Decisao de avanco

Avancar se a construcao unica estiver totalmente validada.

## Wave 2.14 - Primeiro NPC Trabalhador

### Objetivo

Criar o primeiro NPC trabalhador minimo para interagir com o fluxo existente.

### Escopo

- NPC simples.
- Comportamento limitado e testavel.
- Uso de inventario simplificado de NPC.
- Acao manual ou muito controlada, sem IA complexa.

### Fora do escopo

- Sistema completo de IA.
- Pathfinding avancado.
- Combate.
- Multiplas profissoes.
- Simulacao economica.

### Arquivos provaveis

- `res://scripts/npc/npc_base.gd`
- `res://scripts/npc/worker_npc.gd`
- `res://scripts/inventory/npc_inventory.gd`
- Nova cena de teste para NPC trabalhador.

### Riscos

- Introduzir autonomia antes de ter observabilidade suficiente.
- Quebrar fluxo manual validado.
- Criar acoplamento forte entre NPC, Warehouse e BuildingSite.

### Criterios de aceite

- NPC nao substitui o teste manual.
- NPC nao altera regras de consumo.
- Fluxo manual continua valido.
- Logs continuam rastreaveis.

### Dependencias

- Wave 2.13 recomendada antes, para validar multiplos alvos.
- Regras de interacao e estoque bem documentadas.

### Rollback

- Desativar/remover cena de teste do NPC e manter laboratorio manual.

### Decisao de avanco

Avancar apenas apos HUD/debug e multiplos Build Sites estarem estaveis.
