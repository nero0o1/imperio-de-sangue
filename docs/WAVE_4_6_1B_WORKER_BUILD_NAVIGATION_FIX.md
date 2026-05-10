# Wave 4.6.1B - Coleta tipada, construcao continua e navegacao anti-travamento

## 1. Resumo executivo

A Wave 4.6.1B corrige tres falhas praticas da economia RTS dos civis:

- NPCs agora podem receber ordem de coleta por tipo de recurso (`wood` ou `stone`).
- O coletor mantem o mesmo tipo ao coletar, depositar e voltar ao campo.
- `ASSIST_BUILD` agora procura outro `BuildingSite` incompleto quando o alvo atual termina.
- Movimento sem progresso por tempo relevante aciona tentativa de recuperacao com repath e offset lateral antes de falhar.

## 2. Branch e commit base

- Branch: `wave-4-6-npc-economia-construcao`
- Commit base: `007c222e28dbdc5aebf621a4eeb92c058382698d`

## 3. Arquivos alterados

- `scripts/npc/npc_order.gd`
- `scripts/npc/npc_order_executor.gd`
- `scripts/npc/npc_base.gd`
- `scripts/ui/npc_command_menu.gd`
- `docs/WAVE_4_6_1B_WORKER_BUILD_NAVIGATION_FIX.md`

## 4. Diferenca tecnica antes/depois

Antes:

- `GATHER_RESOURCE` podia escolher qualquer `ResourcePickup` valido proximo.
- O menu principal nao separava coleta de madeira e pedra.
- `ASSIST_BUILD` dependia de um unico `target_node`.
- O movimento podia falhar por travamento sem tentativa clara de recuperacao.

Depois:

- `NPCOrder` carrega `resource_id_filter`.
- O executor filtra pickups por `resource_id`.
- O menu emite ordens separadas para madeira e pedra.
- `ASSIST_BUILD` procura o proximo canteiro incompleto.
- `NPCBase` detecta stuck, reaplica rota e tenta offset lateral simples.

## 5. Como `resource_id_filter` funciona

`NPCOrder` possui:

```gdscript
var resource_id_filter: StringName = &""
```

O factory `NPCOrder.gather_resource(...)` cria ordens `GATHER_RESOURCE` com filtro explicito.

- `&"wood"`: aceita apenas pickups com `resource_id == "wood"`.
- `&"stone"`: aceita apenas pickups com `resource_id == "stone"`.
- `&""`: modo debug, aceita qualquer pickup valido.

## 6. Como "Coletar madeira" funciona

O menu cria:

```gdscript
NPCOrder.gather_resource(&"wood", null, selected_npc, queue_enabled)
```

O executor procura somente `ResourcePickup` valido com `resource_id == "wood"`.

## 7. Como "Coletar pedra" funciona

O menu cria:

```gdscript
NPCOrder.gather_resource(&"stone", null, selected_npc, queue_enabled)
```

O executor procura somente `ResourcePickup` valido com `resource_id == "stone"`.

## 8. Como construcao continua funciona

`ASSIST_BUILD` agora usa `_find_nearest_incomplete_building_site()`.

Fluxo:

1. Se o alvo atual for invalido ou estiver concluido, procura outro canteiro incompleto.
2. Se encontrar, atualiza `order.target_node` e move o NPC ate ele.
3. Se nao encontrar, conclui a ordem com mensagem clara.
4. Se faltar recurso para continuar, falha com mensagem explicita.

## 9. Separacao coleta/deposito/construcao

Contratos aplicados:

- `GATHER_RESOURCE` usa `ResourcePickup`, inventario do NPC e armazem operacional.
- `FORCE_DROP` usa somente armazem operacional.
- `ASSIST_BUILD` usa somente canteiro incompleto com `build_step`.
- `BuildingSite` nao e aceito como armazem operacional.
- Armazem pronto nao e tratado como obra.

Funcoes de contrato:

- `_is_valid_resource_pickup_for_filter(...)`
- `_is_operational_warehouse(...)`
- `_is_building_site(...)`
- `_is_valid_incomplete_building_site(...)`

## 10. Como stuck detection funciona

`NPCBase` mede progresso durante movimento semantico.

Se o NPC tem alvo ativo, ainda esta longe e quase nao se deslocou apos 2 segundos:

1. Loga `[NPCNavigation] stuck detectado`.
2. Reaplica o alvo no `NavigationAgent3D`, quando disponivel.
3. Loga `[NPCNavigation] recalculando rota`.
4. Tenta um ponto lateral curto.
5. Loga `[NPCNavigation] tentando offset lateral`.
6. Se exceder tentativas, marca falha de navegacao para o executor encerrar a ordem.

## 11. Testes executados

Executado em PowerShell no repositorio `O:\game`.

```powershell
git diff --check
```

Resultado: passou. Apenas avisos de LF/CRLF foram emitidos.

```powershell
O:\Games\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64_console.exe --headless --path . --quit
```

Resultado: passou com codigo 0.

```powershell
O:\Games\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64_console.exe --headless --path . --quit-after 5 res://scenes/test/NPCWave4OrderIntegrationTest.tscn
```

Resultado: passou com codigo 0.

Observacao: a cena informa ausencia de `NavigationRegion3D` e usa movimento direto, comportamento ja existente.

```powershell
O:\Games\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64_console.exe --headless --path . --quit-after 5 res://scenes/test/NPCWave4ConstructionStressTest.tscn
```

Resultado: passou com codigo 0.

## 12. Testes manuais pendentes

Nao foi declarado "validado manualmente".

Pendentes em editor Godot:

- Teste A: selecionar NPC e usar "Coletar madeira"; confirmar coleta apenas de `wood`, deposito e repeticao.
- Teste B: selecionar NPC e usar "Coletar pedra"; confirmar coleta apenas de `stone`, deposito e repeticao.
- Teste C: criar duas construcoes incompletas e confirmar construcao em sequencia.
- Teste D: confirmar que coleta nao chama `build_step`, deposito nao mira `BuildingSite`, e construcao nao deposita recurso.
- Teste E: criar travamento fisico e confirmar logs de stuck, repath e offset.

## 13. Limitacoes restantes

- A cena `NPCWave4OrderIntegrationTest.tscn` ainda registra falta de `NavigationRegion3D`; movimento direto continua sendo usado nela.
- A validacao de stuck foi coberta por codigo e carga headless, mas ainda precisa de teste manual com obstaculo real.
- A cena jogavel oficial unificada ainda nao foi criada nesta Wave.

## 14. Proxima recomendacao

Proxima Wave recomendada:

- Consolidar uma cena `PrototypePlayable.tscn` com construcao, ordens, coleta, deposito, populacao e navegacao.
- Adicionar `NavigationRegion3D` funcional nas cenas de teste relevantes.
- Criar teste automatizado de fluxo economico por tipo de recurso, quando houver harness de gameplay apropriado.
