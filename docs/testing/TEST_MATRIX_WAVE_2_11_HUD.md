# Test Matrix Wave 2.11 - HUD Visual Simples

## Objetivo

Validar que a HUD visual simples mostra PlayerInventory, Warehouse e BuildingSite sem alterar gameplay, dominio ou logs JSON.

## Escopo

- Cena principal de teste: `res://scenes/test/TestInventoryWarehouse.tscn`.
- HUD visual: `res://scenes/ui/hud/GameHUD.tscn`.
- Fluxo validado: coleta -> PlayerInventory -> Warehouse -> BuildingSite.
- Politica da cena-laboratorio: `WAREHOUSE_ONLY`.

## Casos de teste

| ID | Teste | Resultado esperado | Severidade se falhar |
|---|---|---|---|
| HUD-01 | Abrir `TestInventoryWarehouse.tscn` | Cena abre sem erro de parse | Critica |
| HUD-02 | Executar a cena | HUD aparece no topo da tela | Alta |
| HUD-03 | NodePath de PlayerInventory valido | Painel Inventario mostra `vazio` no estado inicial | Alta |
| HUD-04 | NodePath de Warehouse valido | Painel Armazem mostra `vazio` no estado inicial | Alta |
| HUD-05 | NodePath de BuildingSite valido | Painel Construcao mostra `test_building`, progresso `0.0%`, `Concluida: false` | Alta |
| HUD-06 | Coletar `ResourcePickup_Wood` | Inventario mostra `wood` com quantidade `10` | Alta |
| HUD-07 | Coletar `ResourcePickup_Stone` | Inventario mostra `stone` com quantidade `5` | Media |
| HUD-08 | Depositar wood no armazem | Inventario remove `wood`; Armazem mostra `wood` com quantidade `10` | Alta |
| HUD-09 | Construir uma etapa | Armazem reduz `wood`; Construcao mostra progresso `50.0%` e status `em construcao` | Alta |
| HUD-10 | Construir segunda etapa | Construcao mostra progresso `100.0%`, `Concluida: true` e status `concluida` | Alta |
| HUD-11 | Interagir depois de concluida | HUD permanece em `100.0%`; estoque nao e consumido novamente | Critica |
| HUD-12 | Quebrar NodePath em copia de teste | Painel correspondente mostra `nao configurado` sem erro fatal | Media |
| HUD-13 | Observar Output durante o fluxo | Logs JSON continuam aparecendo | Alta |
| HUD-14 | Testar movimento/interacao | Gameplay continua igual ao baseline | Critica |

## Campos esperados na HUD

### Inventario

- Titulo `Inventario`.
- Mensagem `nao configurado` se o NodePath estiver ausente.
- Mensagem `vazio` se nao houver itens.
- Linhas textuais com nome, categoria, quantidade, peso, valor e raridade.

### Armazem

- Titulo `Armazem`.
- Mensagem `nao configurado` se o NodePath estiver ausente.
- Mensagem `vazio` se nao houver itens.
- Linha de `wood` apos deposito.

### Construcao

- `building_id`.
- Barra textual de progresso.
- Porcentagem.
- `is_completed`.
- `required_costs`.
- Status textual: `aguardando recurso`, `em construcao` ou `concluida`.

## Regras de regressao

- A HUD nao pode chamar `add_item()`.
- A HUD nao pode chamar `remove_item()`.
- A HUD nao pode chamar `remove_items()`.
- A HUD nao pode chamar `deposit()`.
- A HUD nao pode chamar `withdraw()`.
- A HUD nao pode chamar `pay()`.
- A HUD nao pode chamar `build_step()`.
- A HUD deve usar apenas consultas e leitura de propriedades.

## Resultado esperado final

Ao final do fluxo completo, a HUD deve mostrar:

- PlayerInventory sem `wood` usado na construcao.
- Warehouse sem saldo negativo.
- BuildingSite com progresso `100.0%`.
- BuildingSite com `Concluida: true`.
- Logs JSON ainda visiveis no Output.

## Wave 2.11.1 — Casos adicionais: Toggle da HUD por tecla I

| ID | Teste | Resultado esperado | Severidade se falhar |
|---|---|---|---|
| HUD-15 | Pressionar I com HUD fechada | HUD abre, mostra estado atual, cursor do mouse visivel | Alta |
| HUD-16 | Pressionar I com HUD aberta | HUD fecha, mouse volta ao modo de gameplay (CAPTURED) | Alta |
| HUD-17 | Abrir HUD apos coletar wood | HUD abre mostrando wood atualizado no inventario | Alta |
| HUD-18 | Abrir HUD apos depositar wood | HUD mostra warehouse com wood atualizado | Alta |
| HUD-19 | Buscar "wood" com HUD aberta | Filtro visual funciona; item real nao e removido | Alta |
| HUD-20 | Fechar HUD e continuar gameplay | WASD, mouse look e tecla E continuam funcionando normalmente | Critica |

## Wave 2.11.2 — Casos adicionais: Bloqueio de Gameplay com HUD Aberta

| ID | Teste | Resultado esperado | Severidade se falhar |
|---|---|---|---|
| HUD-21 | Abrir a HUD e tentar andar (WASD) | O jogador permanece parado, nao acelera | Alta |
| HUD-22 | Abrir a HUD e tentar mover a camera | A camera permanece estatica | Alta |
| HUD-23 | Abrir a HUD enquanto pula | O jogador cai com gravidade normal e atrito aereo restrito sem responder a input | Alta |
| HUD-24 | Clicar no BackgroundBlocker com HUD aberta | O click e absorvido, mouse continua visivel, gameplay nao e retomado | Alta |
| HUD-25 | Tentar atacar (LMB) com a HUD aberta | O ataque e ignorado e o log nao e emitido | Alta |
| HUD-26 | Fechar a HUD apos clique no background | O gameplay volta normalmente apos tecla I ou botao de Fechar | Alta |
| HUD-27 | Tentar interagir (E) com a HUD aberta | O botao de interacao e ignorado | Media |
| HUD-28 | Mudar o cursor do mouse e pressionar teclas da UI | LineEdit consome texto, WASD e ignorado, mouse reforcado visivel | Critica |

