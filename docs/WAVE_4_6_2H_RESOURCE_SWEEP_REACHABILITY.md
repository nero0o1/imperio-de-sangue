# Wave 4.6.2H - Resource Sweep, Reachability and Target Reservation

## Resumo executivo

Esta hotfix torna GATHER_RESOURCE mais robusto para varrer recursos do mesmo tipo. O NPC agora escolhe candidatos por grupo, ignora temporariamente pickups que falharam por navegação, reserva o pickup escolhido e diferencia fim normal de recursos restantes inacessiveis/reservados.

## Falha observada

- NPCs melhoraram em spawn e aproximacao na Wave 4.6.2G, mas ainda podiam encerrar a ordem ao primeiro pickup inacessivel.
- Dois NPCs podiam escolher o mesmo pickup porque nao havia reserva simples de alvo.
- A mensagem final de GATHER_RESOURCE nao separava claramente "nao sobrou recurso" de "existem recursos, mas nenhum esta disponivel agora".

## Causa raiz

GATHER_RESOURCE selecionava o pickup valido mais proximo sem memoria temporaria de falhas e sem propriedade de reserva no ResourcePickup. Quando a navegacao reportava stuck/timeout indo coletar, o executor tratava como falha da ordem inteira, mesmo que houvesse outro pickup do mesmo tipo no mapa.

## Arquivos alterados

- scripts/npc/npc_order_executor.gd
- scripts/resources/resource_pickup.gd
- docs/WAVE_4_6_2H_RESOURCE_SWEEP_REACHABILITY.md

## Varredura de recursos

- Adicionada `_get_resource_pickup_candidates(resource_filter)`.
- A busca usa `get_tree().get_nodes_in_group("resource_pickup")`.
- Os candidatos sao filtrados por `_is_valid_resource_pickup_for_filter`.
- Pickups em blacklist temporaria ou reservados por outro NPC sao ignorados.
- A lista e ordenada por distancia ate o NPC.
- `_find_nearest_resource_pickup` passou a consumir essa lista e reservar o alvo escolhido.

## Blacklist temporaria

- Adicionado `RESOURCE_TARGET_BLACKLIST_SECONDS := 10.0`.
- Cada NPC mantem `_collector_failed_targets`.
- Ao receber stuck recovery failure ou timeout indo ate o pickup, o alvo atual entra na blacklist, a reserva e liberada e a ordem volta para `COLLECTOR_FINDING_RESOURCE`.
- A blacklist e limpa por expiracao, ao terminar ordem e ao cancelar/trocar runtime state.

## Reserva de pickup

- `ResourcePickup` agora possui `reserved_by`.
- Adicionados:
  - `can_be_reserved_by(actor)`
  - `reserve_for(actor)`
  - `release_reservation(actor)`
  - `is_reserved_by_other(actor)`
- A reserva e feita quando o NPC escolhe alvo.
- A reserva e liberada quando o alvo e coletado, fica invalido, falha por navegacao, troca de alvo, cancelamento ou esgotamento do pickup.

## Estados finais

- Sem pickups validos restantes do tipo: `COMPLETED`, com mensagem informando que nao ha recurso restante.
- Pickups validos existem, mas estao em blacklist/reservados: `PARTIAL`, com contadores de validos, blacklist e reservados.
- Falhas de inventario/armazem continuam `FAILED`.

## Testes automaticos

| Teste | Resultado |
|---|---|
| `git diff --check` | PASS |
| Godot headless projeto | PASS |
| Godot headless cena integrada | PASS |

## Testes manuais

| Teste | Resultado | Observacao |
|---|---|---|
| Confirmar 5+ wood e 5+ stone no mapa | PENDING | Requer editor/manual |
| NPC inicial coleta mais de um wood e continua apos deposito | PENDING | Requer editor/manual |
| NPC inicial coleta stone | PENDING | Requer editor/manual |
| Civis runtime coletam wood/stone | PENDING | Requer editor/manual |
| Construcoes bloqueiam alguns recursos e NPC pula alvo inacessivel | PENDING | Verificar log de blacklist |
| Dois NPCs coletando evitam sempre o mesmo pickup | PENDING | Verificar reserva em runtime |

## Riscos restantes

- A blacklist e local por NPC e temporaria; um pickup realmente inacessivel pode ser tentado novamente apos 10 segundos.
- A reserva e simples e nao persiste fora do ciclo de vida do node, suficiente para a Wave atual mas nao substitui um sistema global de tarefas.
- O teste manual ainda precisa confirmar a confiabilidade com 5+ pickups, civis runtime e obstaculos colocados propositalmente.

## Recomendacao de merge ou nao merge

Nao promover para merge final apenas pelos testes headless. A implementacao deve ser validada manualmente na cena integrada com dois NPCs coletando em paralelo e obstaculos bloqueando parte dos recursos.
