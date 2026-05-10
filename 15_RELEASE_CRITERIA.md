# 15_RELEASE_CRITERIA.md

# Império de Sangue — Critérios de Release e Crescimento

| Campo | Valor |
|---|---|
| Documento | Critérios de Release e Crescimento |
| Projeto | Império de Sangue |
| Versão do documento | 1.0 |
| Marco base | M0.1 — Primeira invasão jogável |
| Engine alvo | Godot 4.x |
| Linguagem alvo | GDScript |
| Documento anterior | 14_ROADMAP.md |
| Próximo documento natural | 16_IMPLEMENTATION_START.md |
| Finalidade | Definir quando uma versão pode ser considerada entregue e como o projeto deve crescer sem perder controle |
| Status | Critérios iniciais de release e expansão |

> Este documento define quando uma versão está pronta.  
> Também define como o projeto deve crescer depois da primeira versão jogável.

---

## 1. Finalidade do documento

Este arquivo define os critérios objetivos para considerar uma versão de **Império de Sangue** como entregue.

Ele também registra o planejamento de crescimento do projeto depois do protótipo inicial.

Ele responde:

```text
Quando uma versão pode ser chamada de release?
Quais critérios mínimos cada marco precisa cumprir?
Quais bugs bloqueiam release?
Como o projeto deve crescer depois do M0.1?
Quais sistemas entram primeiro?
Quais sistemas devem esperar?
Quando cortar escopo?
Quando avançar de protótipo para vertical slice?
```

---

## 2. Regra principal de release

Uma release só pode ser declarada quando houver evidência testável.

```text
Sem teste, não há release.
Sem critério cumprido, não há release.
Sem changelog, não há release rastreável.
```

### 2.1 Regra anti-autoengano

Não considerar release apenas porque:

```text
o código compila;
a cena abre;
a ideia parece boa;
o sistema funciona uma vez;
a IA/Codex gerou código;
o protótipo parece próximo.
```

Release exige execução, validação e registro.

---

## 3. Tipos de release

| Tipo | Nome | Finalidade |
|---|---|---|
| R-DOC | Release documental | Documentos base prontos para iniciar execução |
| R-DEV | Release de desenvolvimento | Versão interna instável para testar sistema |
| R-PLAY | Release jogável interna | Versão jogável pelo desenvolvedor |
| R-TEST | Release para teste controlado | Versão para pessoas próximas testarem |
| R-SLICE | Vertical slice | Fatia curta apresentável |
| R-PUBLIC | Release pública futura | Build distribuível para público |

### 3.1 Regra

No momento atual, o foco correto é:

```text
R-DOC → R-DEV → R-PLAY
```

Não pular para `R-PUBLIC` antes de validar `R-PLAY`.

---

## 4. Estados de uma release

| Estado | Significado |
|---|---|
| PLANNED | Planejada, ainda não iniciada |
| IN_PROGRESS | Em implementação/teste |
| CANDIDATE | Candidata a release, aguardando validação final |
| APPROVED | Aprovada pelos critérios |
| RELEASED | Marcada como entregue |
| REJECTED | Reprovada nos critérios |
| HOTFIX_REQUIRED | Entregue, mas exige correção crítica |

---

## 5. Critérios gerais de aprovação

Toda release precisa cumprir:

```text
[ ] Objetivo do marco está claro.
[ ] Escopo do marco está respeitado.
[ ] Não há bug S0 aberto.
[ ] Não há bug S1 aberto.
[ ] Changelog foi atualizado.
[ ] Testes obrigatórios foram executados.
[ ] Riscos críticos foram revisados.
[ ] Decisões relevantes foram registradas.
[ ] Build/execução segue 08_BUILD_NOTES.md.
[ ] O resultado é reproduzível.
```

---

## 6. Critérios de release do M0.1

### 6.1 Nome

```text
M0.1 — Primeira invasão jogável
```

### 6.2 Objetivo

Validar o primeiro loop jogável.

O jogador deve conseguir:

```text
andar;
interagir;
coletar madeira;
construir barricada;
usar NPC coletor;
usar NPC defensor;
enfrentar inimigo básico;
passar por uma onda;
vencer ou perder.
```

### 6.3 Critérios obrigatórios

```text
[ ] Main.tscn abre sem erro S0.
[ ] Player se move.
[ ] Player interage por interact(actor).
[ ] ResourceManager controla madeira.
[ ] WoodNode aumenta madeira.
[ ] BuildSpot consome madeira.
[ ] Barricade é construída.
[ ] SettlementCore recebe dano.
[ ] EnemyBasic ataca alvo.
[ ] WaveManager inicia e encerra onda.
[ ] NpcCollector gera valor econômico perceptível.
[ ] NpcDefender ajuda na defesa.
[ ] HUD comunica madeira, núcleo, onda e resultado.
[ ] GameManager declara vitória.
[ ] GameManager declara derrota.
[ ] TC-001 a TC-020 foram executados.
[ ] Não há bug S0/S1 aberto.
```

### 6.4 Critério de rejeição

Rejeitar release M0.1 se:

```text
não há vitória;
não há derrota;
a onda não termina;
o inimigo não causa dano;
o jogador não consegue interagir;
madeira fica negativa;
construção ignora custo;
o protótipo depende de debug para funcionar fora do teste controlado.
```

---

## 7. Critérios de release do M0.2

### 7.1 Nome

```text
M0.2 — Expansão de sistemas essenciais
```

### 7.2 Objetivo

Aumentar escolhas sem quebrar o loop do M0.1.

### 7.3 Critérios obrigatórios

```text
[ ] Loop do M0.1 continua funcionando.
[ ] Pelo menos 2 escolhas de preparação existem.
[ ] Pelo menos 1 nova construção ou melhoria existe.
[ ] Pelo menos 1 variação de ameaça existe.
[ ] NPCs continuam úteis.
[ ] HUD continua compreensível.
[ ] Nenhum sistema futuro grande foi adicionado sem decisão.
[ ] Testes de regressão do M0.1 passaram.
```

### 7.4 Critério de rejeição

Rejeitar M0.2 se a expansão destruir clareza do M0.1.

---

## 8. Critérios de release do M0.3

### 8.1 Nome

```text
M0.3 — Profundidade de gestão e combate
```

### 8.2 Objetivo

Fazer decisões diferentes gerarem resultados diferentes.

### 8.3 Critérios obrigatórios

```text
[ ] Duas sessões com estratégias diferentes geram resultados perceptíveis.
[ ] Gestão de NPCs tem impacto real.
[ ] Combate tem pelo menos uma variação relevante.
[ ] O jogador ainda entende por que venceu ou perdeu.
[ ] O escopo ainda cabe em mapa controlado.
[ ] Bugs S0/S1 inexistentes.
```

---

## 9. Critérios de release do M0.4

### 9.1 Nome

```text
M0.4 — Vertical slice controlado
```

### 9.2 Objetivo

Criar uma fatia curta apresentável.

### 9.3 Critérios obrigatórios

```text
[ ] Menu inicial simples existe.
[ ] HUD é legível.
[ ] Tutorial textual mínimo existe.
[ ] Assets temporários principais foram melhorados ou padronizados.
[ ] Áudio mínimo de feedback existe ou foi conscientemente cortado.
[ ] Uma pessoa externa entende o objetivo sem explicação constante.
[ ] Build local é estável.
```

---

## 10. Critérios de release do M0.5

### 10.1 Nome

```text
M0.5 — Protótipo público interno
```

### 10.2 Objetivo

Permitir teste controlado com pessoas próximas.

### 10.3 Critérios obrigatórios

```text
[ ] Build exportada para Windows foi testada.
[ ] 3 a 5 pessoas podem testar.
[ ] Formulário ou roteiro de feedback existe.
[ ] Bugs críticos são registrados.
[ ] Assets externos possuem licença registrada.
[ ] O jogo não depende do editor da Godot para ser executado pelo testador.
```

---

## 11. Critérios de release do M1.0

### 11.1 Nome

```text
M1.0 — Versão mínima comercial futura
```

### 11.2 Objetivo

Criar uma versão mínima distribuível, com qualidade e segurança de licença.

### 11.3 Critérios obrigatórios

```text
[ ] Save/load básico existe, se necessário para a experiência.
[ ] Menu e configurações mínimas existem.
[ ] Conteúdo jogável é suficiente para mais de uma sessão.
[ ] Assets possuem licença comercial clara.
[ ] Áudio possui licença clara ou é próprio.
[ ] Não há conteúdo de franquia, marca ou origem incerta.
[ ] Build foi testada fora do ambiente de desenvolvimento.
[ ] Bugs S0/S1/S2 críticos foram resolvidos.
[ ] Página ou canal de distribuição está preparado.
```

---

## 12. Planejamento de crescimento do projeto

O projeto deve crescer em camadas, não em salto.

### 12.1 Crescimento correto

```text
1. Fechar loop mínimo.
2. Melhorar clareza.
3. Adicionar uma escolha nova.
4. Testar se a escolha muda o resultado.
5. Só então adicionar outra camada.
```

### 12.2 Crescimento incorreto

```text
adicionar mundo aberto antes do loop;
adicionar diplomacia antes de defesa funcionar;
adicionar magia antes de combate básico funcionar;
adicionar save/load antes de sessão mínima existir;
comprar assets antes de validar mecânica;
refatorar arquitetura antes de ter problema real.
```

---

## 13. Modelo de crescimento por camadas

### Camada 1 — Loop central

```text
Player → recurso → construção → defesa → inimigo → onda → vitória/derrota
```

### Camada 2 — Escolhas de preparação

```text
mais construção;
mais uso de recurso;
melhor alocação de NPCs;
pequena variação de defesa.
```

### Camada 3 — Variedade de ameaça

```text
novo inimigo;
onda com composição diferente;
pressão por tempo;
alvo alternativo.
```

### Camada 4 — Gestão e progressão

```text
melhoria de assentamento;
produção;
tarefas mais claras de NPC;
progressão curta.
```

### Camada 5 — Identidade do jogo

```text
magia roubada;
diplomacia;
alianças;
expansão territorial;
fantasia de reino/império.
```

### Camada 6 — Produto

```text
save/load;
menu;
configurações;
assets finais;
áudio;
build pública;
licenças;
polimento.
```

---

## 14. Ordem correta de expansão

Ordem recomendada depois do M0.1:

```text
1. Mais clareza de HUD e feedback.
2. Mais uma construção simples.
3. Mais um inimigo simples.
4. Melhorar tarefa dos NPCs.
5. Criar reparo ou melhoria de defesa.
6. Criar primeira escolha de upgrade.
7. Criar magia simples, se ainda fizer sentido.
8. Criar primeira camada de diplomacia apenas depois da defesa/gestão funcionar.
```

### 14.1 Regra

```text
Sistema novo só entra se o sistema anterior estiver testado e compreensível.
```

---

## 15. Gates de crescimento

### Gate A — Antes de adicionar novo sistema

```text
[ ] O loop atual funciona?
[ ] O novo sistema tem tarefa no backlog?
[ ] O novo sistema cabe no marco atual?
[ ] O novo sistema tem teste manual?
[ ] O novo sistema não exige asset final?
[ ] O novo sistema não cria risco de licença?
[ ] O novo sistema reduz problema real ou melhora escolha do jogador?
```

### Gate B — Antes de adicionar complexidade a NPC

```text
[ ] O NPC atual já é útil?
[ ] O comportamento novo é visível para o jogador?
[ ] Pode ser feito com estados simples?
[ ] Não exige IA complexa?
[ ] Não quebra performance ou pathfinding?
```

### Gate C — Antes de adicionar magia/diplomacia

```text
[ ] Defesa e onda já funcionam?
[ ] Gestão de NPC já tem valor?
[ ] O sistema novo cria decisão real?
[ ] O sistema novo não exige UI grande?
[ ] O sistema novo pode ser testado em sessão curta?
```

---

## 16. Regras para impedir crescimento descontrolado

```text
Toda ideia nova vai para backlog futuro, não para implementação imediata.
Toda mudança de escopo precisa de decisão registrada.
Toda sugestão da IA/Codex deve citar tarefa do backlog.
Todo sistema novo precisa de critério de teste.
Todo asset externo precisa de licença registrada.
Toda release precisa de changelog.
Toda expansão precisa preservar o loop anterior.
```

Se uma ideia não cabe no marco atual:

```text
registrar;
adicionar ao backlog futuro;
adiar;
voltar ao loop jogável.
```

---

## 17. Matriz de prontidão de release

| Critério | Peso | M0.1 | M0.2 | M0.3 | M0.4 | M0.5 | M1.0 |
|---|---:|---|---|---|---|---|---|
| Loop jogável | 10 | Obrigatório | Obrigatório | Obrigatório | Obrigatório | Obrigatório | Obrigatório |
| Vitória/derrota | 10 | Obrigatório | Obrigatório | Obrigatório | Obrigatório | Obrigatório | Obrigatório |
| Clareza de objetivo | 8 | Básica | Boa | Boa | Forte | Forte | Forte |
| Bugs S0/S1 | 10 | Zero | Zero | Zero | Zero | Zero | Zero |
| Teste manual | 9 | TC-001 a TC-020 | Regressão + novos | Regressão + novos | Externo leve | Externo controlado | Completo |
| Licença de assets | 8 | Baixa exigência se placeholder | Registro mínimo | Registro | Registro forte | Obrigatório | Obrigatório |
| Build fora do editor | 7 | Opcional | Opcional | Opcional | Desejável | Obrigatório | Obrigatório |
| Feedback externo | 6 | Opcional | Opcional | Desejável | Desejável | Obrigatório | Obrigatório |

---

## 18. Checklist antes de declarar release

```text
[ ] O tipo de release está definido.
[ ] O marco está definido.
[ ] Os critérios obrigatórios foram verificados.
[ ] O plano de testes foi executado.
[ ] Bugs S0/S1 estão zerados.
[ ] Bugs S2 foram avaliados.
[ ] Changelog foi atualizado.
[ ] Riscos foram revisados.
[ ] Decisões relevantes foram registradas.
[ ] Perguntas bloqueantes foram resolvidas ou adiadas formalmente.
[ ] Build/execução foi registrada.
[ ] A release pode ser reproduzida.
```

---

## 19. Checklist depois da release

```text
[ ] Registrar resultado da release.
[ ] Registrar bugs encontrados.
[ ] Atualizar changelog.
[ ] Atualizar risk register.
[ ] Atualizar open questions.
[ ] Atualizar backlog do próximo marco.
[ ] Registrar decisões novas.
[ ] Definir próxima ação objetiva.
```

---

## 20. Template de registro de release

```text
ID da release:
Data:
Marco:
Tipo: R-DOC / R-DEV / R-PLAY / R-TEST / R-SLICE / R-PUBLIC
Estado: PLANNED / IN_PROGRESS / CANDIDATE / APPROVED / RELEASED / REJECTED / HOTFIX_REQUIRED
Versão:
Resumo:

Critérios cumpridos:
-
-
-

Critérios não cumpridos:
-
-
-

Bugs abertos:
-
-

Testes executados:
-
-

Arquivos principais:
-
-

Decisões relacionadas:
-

Riscos relacionados:
-

Resultado final:
Aprovada / Rejeitada / Aprovada com ressalvas

Próxima ação:
```

---

## 21. Resumo final dos critérios de release

```text
Release é uma versão validada, não apenas código existente.
M0.1 só pode ser release quando a primeira invasão jogável funcionar com vitória e derrota.
O crescimento do projeto deve ocorrer por camadas: loop, clareza, escolhas, ameaça, gestão, identidade e produto.
Nenhum sistema novo deve entrar se o loop anterior estiver quebrado.
Toda expansão precisa preservar testabilidade, rastreabilidade e controle de escopo.
```
