# Wave 4.6.2G - NPC Runtime Intelligence, Queue Reliability and Obstacle Navigation

## Resumo executivo

Esta Wave reforca a confiabilidade operacional dos NPCs criados em runtime, sem adicionar sistemas novos. O foco foi alinhar o comportamento dos civis criados por Casa Civil com os NPCs iniciais, projetar spawn e destinos de interacao na NavigationMesh, melhorar recuperacao de stuck e documentar a semantica atual da fila de ordens.

## Falhas observadas

- Civis criados por Casa Civil pareciam menos confiaveis que NPCs pre-existentes.
- NPCs runtime falhavam com mais frequencia ao coletar recursos.
- NPCs podiam travar quando construcoes eram posicionadas como obstaculos.
- GATHER_RESOURCE falhava com alvo valido e NavigationRegion3D presente, indicando problema de aproximacao/navegacao.
- A fila de ordens precisava de uma regra objetiva para QA manual.

## Diferenca entre NPC inicial e NPC runtime

Os NPCs iniciais da cena integrada e os NPCs criados por Casa Civil usam a mesma cena base `scenes/npc/NPCBase.tscn`. A cena base inclui `NavigationAgent3D`, collider compativel, inventario criado em `_ready`, entrada no grupo `npc`, executor de ordens e capabilities configuradas por role.

A diferenca relevante confirmada estava no spawn: o `NPCHouse` calculava uma posicao radial simples ao redor da casa. Esse ponto podia cair fora da NavigationMesh ou em area ruim quando havia colliders/construcoes proximas. As conexoes de menu/ordens para NPCs runtime ja eram feitas pelos controladores da cena integrada e pelo placement runtime.

## Correcoes aplicadas

- `NPCHouse` agora projeta o ponto radial de spawn para o ponto mais proximo da NavigationMesh com `NavigationServer3D.map_get_closest_point`.
- `NPCOrderExecutor` passou a usar pontos de aproximacao navegaveis para interacoes, em vez de mirar sempre no centro do alvo.
- `NPCBase` ganhou helpers publicos de projecao na navmesh, contagem de `NavigationRegion3D` e diagnostico de navegacao.
- A recuperacao de stuck agora tenta candidatos alternativos projetados na navmesh, em vez de repetir sempre o mesmo offset lateral.
- Logs de falha de movimento passaram a incluir causa provavel, destino atual, destino anterior, posicao do NPC, alvo, distancia, projecao do alvo e quantidade de NavigationRegion3D.

## Spawn navegavel

O spawn runtime continua usando a distribuicao radial como intencao inicial, mas o ponto final e projetado na NavigationMesh. Se `World3D`, navigation map ou ponto projetado estiverem invalidos, o sistema usa o fallback radial antigo e registra um `push_warning` controlado uma unica vez por casa.

## Aproximacao navegavel para recurso/construcao/warehouse

Foi adicionado um helper de aproximacao no executor de ordens. Ele calcula um ponto entre o NPC e o alvo, a uma fracao da distancia de interacao, projeta esse ponto na NavigationMesh e usa o resultado como destino de movimento. A validacao de interacao continua usando a distancia real ate o alvo.

Aplicado em:

- `GATHER_RESOURCE` indo ate resource pickup.
- `GATHER_RESOURCE` indo depositar no warehouse.
- `ASSIST_BUILD` indo ate BuildingSite.
- `FORCE_DROP` indo ate warehouse/interactable.
- `REPAIR` indo ate alvo reparavel.

## Stuck recovery

Quando o NPC detecta falta de progresso, a recuperacao agora considera candidatos ao redor do NPC e do alvo, alternando o lado usado e projetando as opcoes na NavigationMesh. Se todas as tentativas falharem, a ordem continua falhando corretamente; a mudanca e apenas para tentar uma rota alternativa antes da falha final e explicar melhor a causa.

Diagnosticos adicionados:

- destino atual;
- destino anterior;
- posicao do NPC;
- distancia ate destino;
- alvo e posicao do alvo, quando disponivel;
- distancia ate alvo;
- alvo projetado na NavigationMesh;
- quantidade de `NavigationRegion3D`;
- causa provavel: sem nav region, NavigationAgent indisponivel, destino invalido, destino fora da navmesh, alvo fora da navmesh/centro inacessivel, timeout/obstaculo.

## Auditoria de fila

A fila ja estava consistente com a regra definida para esta Wave:

| Acao | Comportamento confirmado no codigo |
|---|---|
| `queue_mode = false` | Substitui a ordem atual e limpa pendentes. |
| `queue_mode = true` | Enfileira no fim se ja houver ordem atual. |
| `CLEAR_QUEUE` | Limpa apenas ordens pendentes e preserva a ordem atual. |
| `STOP` | Cancela ordem atual, limpa pendentes e para o movimento. |
| `HOLD_POSITION` | Para movimento e bloqueia auto movement/chase. |

Nao houve reescrita da fila porque a semantica solicitada ja estava implementada; a Wave apenas documenta o comportamento e preserva os logs de transicao.

## Arquivos alterados

- `scripts/npc/npc_house.gd`
- `scripts/npc/npc_base.gd`
- `scripts/npc/npc_order_executor.gd`
- `docs/WAVE_4_6_2G_NPC_INTELLIGENCE_QUEUE_NAVIGATION.md`

## Testes automaticos

| Teste | Resultado |
|---|---|
| `git diff --check` | PASS |
| Godot headless projeto | PASS |
| Godot headless cena integrada | PASS |

## Testes manuais

| Teste | Resultado | Observacao |
|---|---|---|
| Abrir cena integrada | PENDING | Validacao manual no editor/player. |
| HUD OK | PENDING | Validacao manual no editor/player. |
| Criar Casa Civil | PENDING | Validacao manual no editor/player. |
| Criar 3 civis runtime | PENDING | Validacao manual no editor/player. |
| Runtime NPC coleta wood | PENDING | Validacao manual no editor/player. |
| Runtime NPC coleta stone | PENDING | Validacao manual no editor/player. |
| Deposito no Warehouse | PENDING | Validacao manual no editor/player. |
| Obstaculos com 3 construcoes | PENDING | Validacao manual no editor/player. |
| ASSIST_BUILD runtime | PENDING | Validacao manual no editor/player. |
| Fila STOP/CLEAR_QUEUE | PENDING | Validacao manual no editor/player. |
| Erro vermelho recorrente | PENDING | Validacao manual no editor/player. |

## Riscos restantes

- A projecao para o ponto mais proximo da NavigationMesh melhora spawn e aproximacao, mas nao substitui avoidance/steering robusto para obstaculos dinamicos complexos.
- Construcoes colocadas sobre rotas estreitas ainda podem gerar destinos alcancaveis apenas parcialmente se a NavigationMesh nao refletir esses obstaculos em runtime.
- O checklist manual de 5 NPCs, 3 construcoes e fila precisa ser executado no editor/player antes de liberar merge.
- Uma Wave futura pode separar tarefas compostas em um Task System pequeno, mas isso nao foi introduzido nesta Wave.

## Recomendacao de merge ou nao merge

Nao fazer merge apenas com testes headless. Recomendacao: atualizar o PR com esta correcao, executar o checklist manual da Wave 4.6.2G e liberar merge somente se NPC runtime coletar wood/stone, ASSIST_BUILD continuar funcionando, STOP/CLEAR_QUEUE ficarem previsiveis e nao houver erro vermelho recorrente.
