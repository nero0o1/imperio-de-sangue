# 08_BUILD_NOTES.md

# Império de Sangue — Notas de Build e Execução

| Campo | Valor |
|---|---|
| Documento | Notas de Build e Execução |
| Projeto | Império de Sangue |
| Versão do documento | 1.0 |
| Marco coberto | Marco 0.1 — Primeira invasão jogável |
| Engine alvo | Godot 4.x |
| Linguagem alvo | GDScript |
| Documento anterior | 07_TEST_PLAN.md |
| Próximo documento natural | 09_ASSET_GUIDE.md |
| Finalidade | Registrar como abrir, configurar, executar e diagnosticar o projeto durante o protótipo |
| Status | Documento operacional inicial |

> Este documento registra como rodar o projeto localmente.  
> Ele deve reduzir perda de tempo com configuração, cena principal, Autoloads, Input Map e erros básicos de execução.

---

## 1. Finalidade do documento

Este arquivo documenta o procedimento mínimo para abrir e executar o protótipo **Império de Sangue** na Godot.

Ele responde:

```text
Qual versão da Godot usar?
Qual cena deve abrir primeiro?
Quais Autoloads precisam estar configurados?
Quais entradas precisam existir no Input Map?
Como rodar o Marco 0.1 pelo editor?
Quais erros comuns podem impedir execução?
Quando uma build pode ser considerada jogável?
```

Este documento não é:

```text
manual de gameplay;
plano de testes completo;
backlog;
arquitetura de sistemas;
guia de assets;
manual de exportação comercial.
```

---

## 2. Ambiente alvo

| Item | Valor esperado |
|---|---|
| Engine | Godot 4.x |
| Linguagem | GDScript |
| Plataforma inicial | PC |
| Sistema principal de desenvolvimento | Windows |
| Execução inicial | Pelo editor da Godot |
| Exportação comercial | Fora do Marco 0.1 |
| Build alvo do protótipo | Execução local jogável |

### 2.1 Regra de versão

Registrar a versão exata da Godot usada:

```text
Godot version: 4.x.x
Renderer: Forward+ / Mobile / Compatibility
Sistema operacional:
Data da última execução funcional:
```

---

## 3. Como abrir o projeto

Procedimento esperado:

```text
1. Abrir Godot 4.x.
2. Clicar em Importar.
3. Selecionar a pasta raiz do projeto.
4. Abrir o arquivo project.godot.
5. Confirmar que a árvore res:// aparece corretamente.
6. Abrir Main.tscn.
7. Executar o projeto pelo editor.
```

### 3.1 Pasta raiz esperada

A pasta raiz deve conter:

```text
project.godot
scenes/
scripts/
assets_temp/
docs/
```

---

## 4. Como executar pelo editor

### 4.1 Execução normal

```text
1. Abrir Main.tscn.
2. Confirmar se Main.tscn está definida como cena principal.
3. Pressionar F5 ou botão Play.
4. Verificar se o jogador aparece no TestMap.tscn.
5. Confirmar que HUD aparece.
6. Confirmar que não há erro crítico no console.
```

### 4.2 Execução de cena isolada

Para testar uma cena específica:

```text
1. Abrir a cena desejada.
2. Pressionar F6 ou Executar Cena Atual.
3. Verificar se a cena depende de Autoloads.
4. Se a cena quebrar por falta de referência, testar via Main.tscn.
```

### 4.3 Regra prática

```text
Main.tscn é a execução oficial do Marco 0.1.
Cenas isoladas são úteis para debug, mas não substituem o teste do loop completo.
```

---

## 5. Cenas principais

| Cena | Caminho esperado | Função |
|---|---|---|
| Main | `res://scenes/main/Main.tscn` | Cena principal do protótipo |
| TestMap | `res://scenes/test/TestMap.tscn` | Mapa pequeno de teste |
| Player | `res://scenes/player/Player.tscn` | Jogador em primeira pessoa |
| HUD | `res://scenes/ui/HUD.tscn` | Interface mínima |
| SettlementCore | `res://scenes/settlement/SettlementCore.tscn` | Núcleo da base |
| BuildSpot | `res://scenes/settlement/BuildSpot.tscn` | Ponto de construção |
| Barricade | `res://scenes/settlement/Barricade.tscn` | Defesa simples |
| WoodNode | `res://scenes/resources/WoodNode.tscn` | Madeira coletável |
| EnemyBasic | `res://scenes/enemies/EnemyBasic.tscn` | Inimigo básico |
| NpcCollector | `res://scenes/npc/NpcCollector.tscn` | NPC coletor |
| NpcDefender | `res://scenes/npc/NpcDefender.tscn` | NPC defensor |

---

## 6. Autoloads obrigatórios

Configurar em:

```text
Project > Project Settings > Autoload
```

| Nome do Autoload | Caminho do script | Obrigatório? |
|---|---|---:|
| GameManager | `res://scripts/core/game_manager.gd` | Sim |
| ResourceManager | `res://scripts/core/resource_manager.gd` | Sim |
| WaveManager | `res://scripts/core/wave_manager.gd` | Sim |

### 6.1 Checklist de Autoload

```text
[ ] GameManager está ativo.
[ ] ResourceManager está ativo.
[ ] WaveManager está ativo.
[ ] Os nomes estão escritos exatamente como nos documentos.
[ ] Nenhum Autoload extra foi criado sem decisão registrada.
```

---

## 7. Input Map obrigatório

Configurar em:

```text
Project > Project Settings > Input Map
```

| Ação | Tecla/botão sugerido | Função |
|---|---|---|
| move_forward | W | Andar para frente |
| move_backward | S | Andar para trás |
| move_left | A | Andar para esquerda |
| move_right | D | Andar para direita |
| sprint | Shift | Correr simples |
| interact | E | Interagir com objeto olhando para ele |
| attack | Mouse Left | Ataque simples |
| debug_start_wave | T ou F9 | Iniciar onda em modo teste |

### 7.1 Regra de Input Map

```text
Não codificar teclas diretamente no script se a ação existir no Input Map.
Usar Input.is_action_pressed ou Input.is_action_just_pressed.
```

---

## 8. Estrutura mínima esperada

A estrutura mínima do projeto deve ser:

```text
res://
  scenes/
    main/
    player/
    npc/
    enemies/
    settlement/
    resources/
    ui/
    test/
  scripts/
    core/
    player/
    npc/
    enemies/
    settlement/
    resources/
    ui/
  assets_temp/
    materials/
    meshes/
    icons/
  docs/
```

### 8.1 Regra de organização

```text
Cena fica em scenes/.
Script fica em scripts/.
Asset temporário fica em assets_temp/.
Documento fica em docs/.
```

---

## 9. Configurações iniciais do projeto

### 9.1 Cena principal

A cena principal deve ser:

```text
res://scenes/main/Main.tscn
```

### 9.2 Renderer

No Marco 0.1, renderer não deve ser prioridade.

Regra:

```text
Usar configuração padrão da Godot, salvo se houver problema de compatibilidade.
Não gastar tempo com qualidade gráfica antes do loop funcionar.
```

### 9.3 Física e colisão

Verificar:

```text
Player tem CollisionShape3D.
Chão tem colisão.
EnemyBasic tem colisão.
SettlementCore tem colisão se for atacável por contato/alcance.
Barricade tem colisão se deve bloquear inimigo.
RayCast3D possui collision mask compatível com objetos interativos.
```

---

## 10. Procedimento de build/exportação

No Marco 0.1, a exportação final não é prioridade.

### 10.1 Procedimento mínimo aceitável

```text
Rodar pelo editor da Godot.
Testar Main.tscn.
Confirmar vitória e derrota.
Registrar versão funcional.
```

### 10.2 Exportação futura

Quando for necessário exportar para Windows:

```text
1. Instalar export templates compatíveis com a versão da Godot.
2. Criar preset Windows Desktop.
3. Exportar build de teste.
4. Executar fora do editor.
5. Registrar erro, se houver.
```

### 10.3 Regra

```text
Não bloquear o Marco 0.1 por exportação comercial.
Primeiro validar execução pelo editor.
```

---

## 11. Checklist antes de rodar

```text
[ ] project.godot existe.
[ ] Main.tscn existe.
[ ] Main.tscn está como cena principal.
[ ] TestMap.tscn existe.
[ ] Player está instanciado.
[ ] HUD está instanciada.
[ ] GameManager está como Autoload.
[ ] ResourceManager está como Autoload.
[ ] WaveManager está como Autoload.
[ ] Input Map tem interact.
[ ] Input Map tem attack.
[ ] Input Map tem movimentos.
[ ] Console não mostra erro de script ao abrir o projeto.
```

---

## 12. Checklist depois de rodar

```text
[ ] Cena abriu.
[ ] Player apareceu.
[ ] Player se moveu.
[ ] Mouse controlou câmera.
[ ] Interação funcionou.
[ ] HUD apareceu.
[ ] Madeira pôde ser coletada.
[ ] Barricada pôde ser construída.
[ ] Onda pôde iniciar.
[ ] Inimigo apareceu.
[ ] Vitória ou derrota apareceu.
[ ] Erros do console foram registrados.
```

---

## 13. Problemas conhecidos

| ID | Problema | Severidade | Status | Observação |
|---|---|---|---|---|
| KNOWN-001 | A preencher | S0/S1/S2/S3/S4 | TODO | A preencher |

### 13.1 Regra

Todo problema repetido deve sair da memória informal e entrar nesta seção ou no `07_TEST_PLAN.md`.

---

## 14. Solução de problemas

| Sintoma | Causa provável | Correção inicial |
|---|---|---|
| Projeto não abre | Versão errada da Godot | Conferir versão Godot 4.x |
| Main.tscn não executa | Cena principal não configurada | Definir Main.tscn como main scene |
| Autoload não encontrado | Nome/caminho errado | Conferir Project Settings > Autoload |
| Player não se move | Input Map faltando | Conferir ações de movimento |
| Interação não funciona | RayCast3D/collision mask | Conferir máscara e colisão do objeto |
| HUD não atualiza | Sinal não conectado | Conferir conexão com ResourceManager/GameManager |
| Inimigo não ataca | Alvo nulo | Conferir target do EnemyBasic |
| Onda não termina | enemies_alive não reduz | Conferir sinal de morte do inimigo |
| Derrota não aparece | core_destroyed não conectado | Conferir conexão SettlementCore → GameManager |
| Vitória não aparece | wave_finished não conectado | Conferir conexão WaveManager → GameManager |

---

## 15. Registro de versões locais

Usar esta tabela para registrar execuções funcionais.

| Data | Godot | Commit/versão local | Cena | Resultado | Observação |
|---|---|---|---|---|---|
| A preencher | 4.x | A preencher | Main.tscn | PASS/PARTIAL/FAIL | A preencher |

### 15.1 Regra de registro

Registrar pelo menos quando:

```text
uma wave for concluída;
um bug S0/S1 for corrigido;
o loop completo rodar;
vitória e derrota forem confirmadas;
uma exportação for testada.
```

---

## 16. Regras para não quebrar execução

```text
Não renomear Autoload sem atualizar todos os scripts.
Não mover Main.tscn sem atualizar cena principal.
Não mover scripts sem atualizar cenas anexadas.
Não alterar Input Map sem revisar Player.
Não apagar assets_temp usados por cenas atuais.
Não mudar nome de sinal sem revisar conexões.
Não criar dependência externa sem decisão registrada.
Não exportar antes de validar execução pelo editor.
```

---

## 17. Critérios para build jogável do Marco 0.1

Uma execução pode ser considerada jogável quando:

```text
Main.tscn abre pelo editor.
Player se move.
HUD aparece.
Madeira pode ser coletada.
Barricada pode ser construída.
NPC coletor tem utilidade.
NPC defensor tem utilidade.
EnemyBasic ataca.
WaveManager inicia e termina onda.
GameManager declara vitória.
GameManager declara derrota.
Não há bug S0 ou S1 aberto.
```

---

## 18. Resumo final das notas de build

```text
O Marco 0.1 deve ser executado inicialmente pelo editor da Godot.
A cena principal é Main.tscn.
O mapa de teste é TestMap.tscn.
Os Autoloads obrigatórios são GameManager, ResourceManager e WaveManager.
O Input Map precisa conter movimento, interact, attack e debug_start_wave.
Exportação comercial fica fora do escopo inicial.
Uma build jogável é aquela que permite testar coleta, construção, NPCs, inimigo, onda, vitória e derrota sem bug S0/S1.
```
