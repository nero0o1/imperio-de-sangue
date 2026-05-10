# Wave 4.5.1 — Relatório Final de Entrega

**Data:** 2026-05-09  
**Escopo:** Correção da Wave 4.5 (Sistema Semântico de Ordens) para torná-la testável no editor e no gameplay.

---

## Arquivos Alterados

| Arquivo | Tipo | Motivo |
|---|---|---|
| `scripts/npc/npc_order.gd` | Corrigido | Warning de shadowing: `order_type` → `p_order_type`, `position` → `p_position` em `make()` |
| `scripts/npc/npc_base.gd` | Ampliado | Adicionado `NpcInventory` dinâmico + `get_inventory()` para suporte a GATHER/FORCE_DROP |
| `scripts/npc/npc_order_executor.gd` | Ampliado | MVP real de GATHER_RESOURCE e FORCE_DROP (mover até alvo → `interact()`) |
| `scripts/ui/npc_command_menu.gd` | Reescrito | Menu completo com 25+ ordens, painel de debug, modo fila, logs `[UIOrder]` |
| `scenes/ui/NPCCommandMenu.tscn` | Reconstruído | Minimal (sem filhos fixos); toda UI criada em `_build_ui()` pelo script |
| `scripts/ui/hud/warehouse_panel.gd` | Corrigido | Mensagem de fallback melhorada ("aguardando construcao" em vez de "nao configurado") |
| `scripts/ui/hud/building_status_panel.gd` | Corrigido | Mensagem de fallback melhorada ("nenhum alvo selecionado") |
| `scripts/test/npc_wave4_test.gd` | Ampliado | Adicionado handler `_on_menu_patrol_requested` + conexão do sinal `patrol_requested` |
| `scripts/test/npc_wave4_order_integration_test.gd` | Novo | Controlador da cena de integração com pré-população de armazém e patrulha real |
| `scenes/test/NPCWave4OrderIntegrationTest.tscn` | Nova | Cena de teste completa: 3 NPCs, armazém pré-populado, 10 madeira + 5 pedra, 2 canteiros |

---

## Ordens Expostas no Menu

### MOVIMENTO (implementadas)

| Ordem | Status | Observação |
|---|---|---|
| MOVE_TO_POSITION | **REAL** | NPC se move para frente do jogador |
| PATROL | **REAL** | NPC vai ao ponto calculado (patrol_radius a frente) |
| FOLLOW_TARGET | **REAL** | NPC segue o jogador |
| STOP | **REAL** | Para a ordem atual imediatamente |
| HOLD_POSITION | **REAL** | Bloqueia auto-movimento; NPC fica parado |
| CLEAR_QUEUE | **REAL** | Limpa fila de ordens pendentes |

### CONSTRUÇÃO / ECONOMIA

| Ordem | Status | Observação |
|---|---|---|
| ASSIST_BUILD | **REAL** | NPC anda até BuildingSite mais próximo e executa build_step() |
| GATHER_RESOURCE | **REAL (MVP)** | NPC anda até pickup mais próximo e chama interact() |
| FORCE_DROP | **REAL (MVP)** | NPC anda até WarehouseInteractable mais próximo e chama interact() |
| REPAIR | PARTIAL | Sinalizado no log; executor retorna PARTIAL sem lógica de cura |

### POSTURAS / COMBATE

| Ordem | Status | Observação |
|---|---|---|
| ATTACK_MOVE | PARTIAL | NPC avança 8u na direção do olhar; sem combate real |
| FOCUS_FIRE | UNSUPPORTED | Sem sistema de combate nesta fase |
| FIRE_AT_WILL | UNSUPPORTED | Sem sistema de combate nesta fase |
| HOLD_FIRE | UNSUPPORTED | Sem sistema de combate nesta fase |
| VOLLEY_FIRE | UNSUPPORTED | Sem sistema de combate nesta fase |
| REPAIR_UNDER_FIRE | UNSUPPORTED | Sem sistema de combate nesta fase |

### FORMAÇÃO

| Ordem | Status | Observação |
|---|---|---|
| FORM_SHIELD_WALL | UNSUPPORTED | Sem formações nesta fase |
| BRACE_PIKES | UNSUPPORTED | Sem formações nesta fase |

### ESTRUTURA / CERCO

| Ordem | Status | Observação |
|---|---|---|
| MAN_SIEGE_RAM | UNSUPPORTED | Sem veículos de cerco nesta fase |
| SCALE_WALLS | UNSUPPORTED | Sem mecânica de escalada nesta fase |
| SAP_FOUNDATION | UNSUPPORTED | Sem sabotagem nesta fase |
| POUR_MURDER_HOLES | UNSUPPORTED | Sem mecânica de defesa de estrutura nesta fase |
| SALLY_OUT | UNSUPPORTED | Sem guarnições nesta fase |
| GARRISON | UNSUPPORTED | Sem ponto de guarnição detectado na cena |

---

## Painel de Debug (NPCCommandMenu)

Quando um NPC está selecionado, o painel exibe em tempo real:

- **Ordem atual**: tipo + label da ordem em execução
- **Fila**: número de ordens pendentes + modo fila (ON/OFF)
- **Tático**: estado tático + postura atual
- **Último status**: código de status da última ordem finalizada
- **Motivo**: `failure_reason` da última ordem (vazia se bem-sucedida)
- **Inventário NPC**: recursos que o NPC carrega atualmente

O CheckButton "Enfileirar próxima" alterna `queue_mode`. Quando ativado, a próxima ordem clicada é adicionada à fila em vez de substituir a atual.

---

## Cena de Integração — Como Testar

**Abrir:** `scenes/test/NPCWave4OrderIntegrationTest.tscn`

### Configuração inicial (automática)
- Armazém pré-populado: **200 wood + 100 stone** (via script no `_ready()`)
- 3 NPCs civis pré-posicionados em (-5,5), (0,5), (5,5)
- WarehouseInteractable (caixa azul) em (-14, 0)
- 10 pickups de madeira (marrom) e 5 de pedra (cinza)
- 2 canteiros: CivilHouseA (madeira+pedra) e WarehouseBuilding (só madeira)

### Testes manuais executáveis

1. **MOVE**: Olhe para NPC → E (selecionar) → "Mover" → NPC anda na direção do jogador
2. **PATROL**: Selecione NPC → "Patrulhar" → NPC vai para ponto a 8u na frente do jogador
3. **FOLLOW**: Selecione NPC → "Seguir Jogador" → NPC te segue; mova-se para confirmar
4. **STOP / HOLD**: Selecione NPC em movimento → "Parar" → NPC para imediatamente
5. **CLEAR_QUEUE**: Ative modo fila → enfileire 3 ordens → "Limpar Fila" → fila zerada
6. **ASSIST_BUILD**: Selecione NPC → "Auxiliar Construção" → NPC anda até CivilHouseA e constrói (consume do armazém)
7. **GATHER_RESOURCE**: Selecione NPC → "Coletar Recurso" → NPC anda até madeira mais próxima e pega
8. **FORCE_DROP**: Após coleta → "Depositar Tudo" → NPC anda até WarehouseInteractable e deposita
9. **NPC do HUD**: Olhe para NPCHouse → E → crie um civil → civil aparece conectado ao menu
10. **Inventário NPC**: No painel de debug, veja o inventário do NPC mudar após coleta e depósito

### Verificações no console

Mensagens esperadas ao iniciar:
```
[OrderTest] Cena Wave 4.5.1 pronta. Armazem: 200 wood, 100 stone. Teclas debug: desativadas.
[OrderTest] Armazem populado: wood=200, stone=100.
```

Ao clicar um botão de ordem:
```
[UIOrder] NomeNPC — GATHER_RESOURCE
[Order] GATHER_RESOURCE: ...
```

---

## Warnings Corrigidos

| Warning | Arquivo | Correção |
|---|---|---|
| `order_type` shadowing class variable | `npc_order.gd` `make()` | Renomeado para `p_order_type` |
| `position` shadowing built-in Vector3 property | `npc_order.gd` `make()` | Renomeado para `p_position` |
| `position` em `issue_move_order()` | `npc_base.gd` | Renomeado para `destination` |

---

## Riscos e Limitações

| Risco | Severidade | Mitigação |
|---|---|---|
| NavigationMesh ausente na cena nova | Médio | NPCs usam fallback de movimento direto (`_log_movement_fallback_once`); funcionam sem nav mesh |
| `npc_name` export pode não existir em NPCBase | Baixo | Ordens e seleção funcionam sem ele; apenas o label de debug fica genérico |
| GATHER pick-up com NPC sem role CIVIL | Médio | NPCCapabilitySet.supports() pode rejeitar; verificar se NPCBase.tscn tem role default = CIVIL |
| Patrulha MVP: apenas 1 waypoint (destino frente) | Baixo | Comportamento correto, mas não cíclico; expandir em Wave 5 com array de waypoints |
| warehouse_path em BuildingSite sub-nó | Médio | Path `../../Warehouse` relativo ao BuildingSite; verificar no editor se o link aparece verde |
| Sub-nós de instância sem `_loading_mode` | Baixo | Godot 4.6 aceita a sintaxe usada; se houver erro de parse, adicionar propriedades antes de warehouse_path |

---

## Não Validado em Godot

Este relatório descreve alterações feitas em código. **A Godot não foi executada** para confirmar compilação ou comportamento em runtime. Testes manuais na engine são necessários para:

- Confirmar ausência de erros de script no console
- Confirmar que o NPCCommandMenu abre e exibe todas as seções
- Confirmar que GATHER e FORCE_DROP movem o NPC e chamam interact()
- Confirmar que o armazém exibe 200 wood + 100 stone no HUD após iniciar

---

## Próximos Passos (Wave 5)

- Patrulha multi-waypoint com ciclo configurável
- GATHER com seleção de resource_id específico (não só o mais próximo)
- FORCE_DROP para inventário do jogador (não só armazém)
- NPCs autônomos: ciclo gather → drop sem ordem manual
- Combate básico para desbloquear as ordens UNSUPPORTED de combate
