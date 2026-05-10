# 11_DECISION_LOG.md

# Império de Sangue — Registro de Decisões

| Campo | Valor |
|---|---|
| Documento | Registro de Decisões |
| Projeto | Império de Sangue |
| Versão do documento | 1.0 |
| Marco coberto | Marco 0.1 — Primeira invasão jogável |
| Engine alvo | Godot 4.x |
| Linguagem alvo | GDScript |
| Documento anterior | 10_RISK_REGISTER.md |
| Próximo documento natural | 12_OPEN_QUESTIONS.md |
| Finalidade | Registrar decisões técnicas, escopo, arquitetura, assets, IA e testes com motivo e impacto |
| Status | Registro inicial de decisões |

> Este documento evita perda de rastreabilidade.  
> Decisão não registrada tende a virar confusão futura.

---

## 1. Finalidade do documento

Este arquivo registra decisões importantes do projeto **Império de Sangue**.

Ele responde:

```text
O que foi decidido?
Por que foi decidido?
Quais alternativas foram consideradas?
Quais impactos a decisão gera?
Quais riscos a decisão reduz ou aumenta?
Quando a decisão deve ser revisada?
Quais documentos ou arquivos foram afetados?
```

O objetivo é impedir que o projeto dependa apenas de memória informal.

---

## 2. O que deve virar decisão registrada

Registrar quando a decisão afetar:

```text
escopo do Marco 0.1;
arquitetura;
Autoloads;
nomes de scripts ou cenas;
contrato entre sistemas;
uso de IA/Codex;
uso de asset externo;
licença de asset;
ordem do backlog;
critério de teste;
risco crítico;
reversão de escolha anterior;
adiação de sistema importante.
```

### 2.1 Regra prática

Se a decisão puder gerar dúvida futura, registrar.

---

## 3. O que não precisa virar decisão registrada

Não precisa registrar:

```text
ajuste pequeno de texto;
correção ortográfica;
renomeação local sem impacto;
valor temporário de balanceamento claramente experimental;
placeholder visual óbvio;
comentário de código sem mudança funcional;
organização menor de tabela.
```

### 3.1 Exceção

Se uma mudança pequena quebrar algo ou alterar contrato, ela deve ser registrada.

---

## 4. Modelo padrão de decisão

Toda decisão relevante deve ter:

```text
ID;
data;
status;
categoria;
contexto;
decisão;
alternativas consideradas;
prós;
contras;
riscos;
impacto;
motivo da escolha;
documentos afetados;
critério de revisão.
```

---

## 5. Status de decisão

| Status | Significado |
|---|---|
| PROPOSTA | Ainda não aprovada |
| APROVADA | Decisão válida para o projeto |
| IMPLEMENTADA | Já aplicada no projeto |
| ADIADA | Decisão relevante, mas não entra agora |
| REVERTIDA | Decisão cancelada/substituída |
| OBSOLETA | Não se aplica mais ao escopo atual |

---

## 6. Escala de impacto

| Nota | Impacto |
|---:|---|
| 0 | Sem impacto real |
| 1–2 | Impacto local pequeno |
| 3–4 | Afeta um arquivo ou uma cena |
| 5–6 | Afeta um sistema inteiro |
| 7–8 | Afeta múltiplos sistemas ou backlog |
| 9–10 | Afeta arquitetura, escopo ou viabilidade do Marco 0.1 |

---

## 7. Critérios de avaliação

Toda decisão relevante deve ser avaliada por estes critérios:

| Critério | Pergunta |
|---|---|
| Escopo | Cabe no Marco 0.1? |
| Simplicidade | Reduz ou aumenta complexidade? |
| Testabilidade | Pode ser testada manualmente? |
| Arquitetura | Respeita 04_SYSTEMS_ARCHITECTURE.md? |
| Backlog | Está ligada a uma tarefa do 05_BACKLOG.md? |
| IA/Codex | Respeita 06_AI_CODEX_RULES.md? |
| Build | Não quebra 08_BUILD_NOTES.md? |
| Licença | Respeita 09_ASSET_GUIDE.md? |
| Risco | Reduz ou aumenta risco do 10_RISK_REGISTER.md? |

---

## 8. Registro inicial de decisões do Marco 0.1

| ID | Categoria | Decisão | Status | Impacto | Revisar quando |
|---|---|---|---|---:|---|
| DEC-001 | Engine | Usar Godot 4.x como engine inicial | APROVADA | 9 | Se a engine impedir o protótipo |
| DEC-002 | Linguagem | Usar GDScript no Marco 0.1 | APROVADA | 8 | Se performance ou integração exigir outra linguagem |
| DEC-003 | Escopo | Focar no Marco 0.1 — primeira invasão jogável | APROVADA | 10 | Após TC-001 a TC-020 passarem |
| DEC-004 | Arquitetura | Usar três Autoloads principais: GameManager, ResourceManager e WaveManager | APROVADA | 8 | Se manager virar gargalo ou acoplamento excessivo |
| DEC-005 | Interação | Usar `interact(actor)` para objetos interativos | APROVADA | 8 | Se o padrão não cobrir interação mínima |
| DEC-006 | Assets | Usar placeholders em `assets_temp` até o loop funcionar | APROVADA | 7 | Após primeira sessão jogável completa |
| DEC-007 | IA/Codex | Usar IA apenas vinculada a tarefa do backlog | APROVADA | 9 | Se a IA começar a expandir escopo |
| DEC-008 | Teste | Usar teste manual por checklist no Marco 0.1 | APROVADA | 7 | Se testes manuais ficarem insuficientes |
| DEC-009 | NPC | Começar com apenas NpcCollector e NpcDefender | APROVADA | 8 | Após utilidade dos 2 NPCs ser validada |
| DEC-010 | Inimigo | Começar com apenas EnemyBasic | APROVADA | 8 | Após onda básica funcionar |

---

## 9. Decisões técnicas

### DEC-001 — Usar Godot 4.x como engine inicial

| Campo | Valor |
|---|---|
| Status | APROVADA |
| Categoria | Técnica / Engine |
| Decisão | Usar Godot 4.x como engine inicial do projeto |
| Contexto | O projeto precisa reduzir dependência de engine comercial com risco de mudança de cobrança/licenciamento |
| Alternativa A | Godot 4.x |
| Alternativa B | Unity |
| Alternativa C | Unreal Engine |
| Prós | Código aberto, sem lock-in comercial forte, adequada para protótipo solo |
| Contras | Menor ecossistema AAA que Unity/Unreal |
| Riscos | Limitações futuras em sistemas muito complexos |
| Impacto | 9 |
| Motivo da escolha | Alinha com independência, custo baixo e protótipo controlado |
| Documentos afetados | 00, 01, 02, 03, 04, 05, 06, 08 |
| Revisar quando | Se a engine impedir algum requisito essencial do protótipo |

### DEC-002 — Usar GDScript no Marco 0.1

| Campo | Valor |
|---|---|
| Status | APROVADA |
| Categoria | Técnica / Linguagem |
| Decisão | Usar GDScript como linguagem principal do protótipo |
| Contexto | O Marco 0.1 precisa de velocidade de implementação e integração direta com Godot |
| Alternativa A | GDScript |
| Alternativa B | C# |
| Alternativa C | C++/GDExtension |
| Prós | Simples, integrado, rápido para prototipagem |
| Contras | Menor robustez para sistemas muito grandes se comparado a linguagens mais rígidas |
| Riscos | Código pode ficar solto se não houver disciplina arquitetural |
| Impacto | 8 |
| Motivo da escolha | Melhor custo-benefício para protótipo solo |
| Documentos afetados | 03, 04, 05, 06, 08 |
| Revisar quando | Se performance, tooling ou manutenção exigirem C# ou outra opção |

---

## 10. Decisões de escopo

### DEC-003 — Focar no Marco 0.1 — primeira invasão jogável

| Campo | Valor |
|---|---|
| Status | APROVADA |
| Categoria | Escopo |
| Decisão | O primeiro objetivo jogável é uma sessão curta com coleta, barricada, 2 NPCs, inimigo básico, onda, vitória e derrota |
| Contexto | O conceito completo é grande demais para iniciar pelo jogo final |
| Alternativa A | Começar pelo Marco 0.1 |
| Alternativa B | Começar por mundo aberto |
| Alternativa C | Começar por narrativa, diplomacia ou arte final |
| Prós | Reduz risco, cria prova jogável, permite teste real |
| Contras | Adia sistemas mais interessantes do jogo final |
| Riscos | O protótipo parecer simples demais no início |
| Impacto | 10 |
| Motivo da escolha | Valida o núcleo antes de expandir |
| Documentos afetados | 01, 02, 05, 07, 10 |
| Revisar quando | TC-001 a TC-020 passarem ou falharem de forma conclusiva |

---

## 11. Decisões de arquitetura

### DEC-004 — Usar três Autoloads principais

| Campo | Valor |
|---|---|
| Status | APROVADA |
| Categoria | Arquitetura |
| Decisão | Usar GameManager, ResourceManager e WaveManager como Autoloads do Marco 0.1 |
| Contexto | O protótipo precisa de estado global mínimo sem criar estrutura excessiva |
| Alternativa A | Três Autoloads claros |
| Alternativa B | Um Manager único |
| Alternativa C | Nenhum Autoload, tudo por referência de cena |
| Prós | Simples, rastreável, reduz configuração manual |
| Contras | Risco de abuso de estado global |
| Riscos | Managers crescerem demais |
| Impacto | 8 |
| Motivo da escolha | Divide responsabilidades globais sem arquitetura pesada |
| Documentos afetados | 03, 04, 05, 06, 08 |
| Revisar quando | Algum manager começar a concentrar regra que não pertence a ele |

### DEC-005 — Usar `interact(actor)` para objetos interativos

| Campo | Valor |
|---|---|
| Status | APROVADA |
| Categoria | Arquitetura / Interação |
| Decisão | Player deve chamar `interact(actor)` em objetos interativos |
| Contexto | Evitar Player cheio de lógica específica para madeira, NPC, núcleo e BuildSpot |
| Alternativa A | Interface simples `interact(actor)` |
| Alternativa B | Player identificar cada classe manualmente |
| Alternativa C | Sistema complexo de eventos/interações |
| Prós | Simples, extensível, reduz acoplamento |
| Contras | Exige disciplina para todos os objetos interativos seguirem o contrato |
| Riscos | Objetos implementarem interação de forma inconsistente |
| Impacto | 8 |
| Motivo da escolha | Melhor equilíbrio entre simplicidade e desacoplamento |
| Documentos afetados | 03, 04, 05, 06, 07 |
| Revisar quando | O padrão não cobrir interações mínimas do Marco 0.1 |

---

## 12. Decisões de assets e licença

### DEC-006 — Usar placeholders em `assets_temp`

| Campo | Valor |
|---|---|
| Status | APROVADA |
| Categoria | Assets |
| Decisão | Usar placeholders em `assets_temp` até o loop jogável funcionar |
| Contexto | Arte final antes da mecânica aumenta risco de atraso e retrabalho |
| Alternativa A | Placeholders temporários |
| Alternativa B | Comprar assets cedo |
| Alternativa C | Produzir arte final antes do protótipo |
| Prós | Acelera validação, reduz risco de licença, evita perda de tempo |
| Contras | Visual inicial será simples |
| Riscos | Protótipo parecer menos motivador visualmente |
| Impacto | 7 |
| Motivo da escolha | Gameplay precisa ser validado antes da estética |
| Documentos afetados | 09, 10 |
| Revisar quando | Primeira sessão completa estiver jogável |

---

## 13. Decisões de IA/Codex

### DEC-007 — Usar IA apenas vinculada a tarefa do backlog

| Campo | Valor |
|---|---|
| Status | APROVADA |
| Categoria | IA/Codex |
| Decisão | Todo pedido para IA/Codex deve citar uma tarefa do 05_BACKLOG.md |
| Contexto | IA tende a criar sistemas extras e expandir escopo se o pedido for aberto demais |
| Alternativa A | IA vinculada ao backlog |
| Alternativa B | Pedir sistemas grandes de uma vez |
| Alternativa C | Não usar IA para código |
| Prós | Mantém foco, reduz escopo, facilita revisão |
| Contras | Exige disciplina ao formular prompts |
| Riscos | Usuário pular essa regra por pressa |
| Impacto | 9 |
| Motivo da escolha | Reduz risco crítico de expansão descontrolada |
| Documentos afetados | 05, 06, 10 |
| Revisar quando | IA gerar código fora do escopo ou quebrar arquitetura |

---

## 14. Decisões de teste e qualidade

### DEC-008 — Usar teste manual por checklist no Marco 0.1

| Campo | Valor |
|---|---|
| Status | APROVADA |
| Categoria | Teste / Qualidade |
| Decisão | Usar teste manual por checklist como estratégia inicial |
| Contexto | O protótipo ainda é pequeno e precisa validar fluxo jogável, não automação extensa |
| Alternativa A | Teste manual por checklist |
| Alternativa B | Testes automatizados extensos desde o início |
| Alternativa C | Testar informalmente sem registro |
| Prós | Rápido, prático, adequado para gameplay inicial |
| Contras | Menos rigoroso que automação formal |
| Riscos | Regressão se checklist não for repetido |
| Impacto | 7 |
| Motivo da escolha | Melhor custo-benefício para Marco 0.1 |
| Documentos afetados | 07, 10 |
| Revisar quando | Regressões ficarem frequentes ou sistemas crescerem |

---

## 15. Decisões adiadas

### DEC-009 — Começar com apenas NpcCollector e NpcDefender

| Campo | Valor |
|---|---|
| Status | APROVADA |
| Categoria | Escopo / NPC |
| Decisão | No Marco 0.1, implementar apenas NpcCollector e NpcDefender |
| Alternativas adiadas | construtor, batedor, ferreiro/artesão, NPC narrativo |
| Motivo | Dois NPCs já validam economia e defesa |
| Impacto | 8 |
| Revisar quando | Os dois NPCs forem úteis e testáveis |

### DEC-010 — Começar com apenas EnemyBasic

| Campo | Valor |
|---|---|
| Status | APROVADA |
| Categoria | Escopo / Inimigos |
| Decisão | No Marco 0.1, implementar apenas EnemyBasic |
| Alternativas adiadas | saqueador rápido, bruto, cultista, comandante menor |
| Motivo | Um inimigo já valida alvo, dano, onda, defesa e vitória/derrota |
| Impacto | 8 |
| Revisar quando | A primeira onda funcionar sem bug S0/S1 |

---

## 16. Decisões revertidas

Nenhuma decisão revertida no momento.

Modelo para quando houver reversão:

```text
ID original:
Data da reversão:
Motivo:
Problema causado pela decisão original:
Nova decisão substituta:
Arquivos afetados:
Risco residual:
```

---

## 17. Template curto para nova decisão

```text
ID:
Data:
Status:
Categoria:
Decisão:
Motivo:
Impacto: 0–10
Documentos afetados:
Revisar quando:
```

---

## 18. Template completo para nova decisão

```text
ID:
Data:
Status: PROPOSTA / APROVADA / IMPLEMENTADA / ADIADA / REVERTIDA / OBSOLETA
Categoria:
Contexto:
Problema que a decisão resolve:
Decisão:

Alternativas consideradas:
A)
B)
C)

Prós da decisão:
-
-
-

Contras da decisão:
-
-
-

Riscos criados:
-
-
-

Riscos reduzidos:
-
-
-

Impacto: 0–10
Arquivos/documentos afetados:
Tarefas do backlog afetadas:
Critério de aceite:
Critério de revisão:
Responsável:
Origem da decisão: Humano / IA / Teste / Bug / Risco
```

---

## 19. Checklist antes de aprovar decisão

```text
[ ] A decisão cabe no Marco 0.1?
[ ] A decisão reduz risco ou resolve problema real?
[ ] A decisão não adiciona sistema fora do escopo?
[ ] A decisão respeita 04_SYSTEMS_ARCHITECTURE.md?
[ ] A decisão respeita 06_AI_CODEX_RULES.md?
[ ] A decisão não quebra 08_BUILD_NOTES.md?
[ ] A decisão não cria risco de licença contra 09_ASSET_GUIDE.md?
[ ] A decisão tem critério de revisão?
[ ] A decisão tem impacto estimado?
[ ] A decisão tem alternativa considerada?
```

---

## 20. Checklist antes de reverter decisão

```text
[ ] A decisão original está identificada?
[ ] O motivo da reversão é objetivo?
[ ] A reversão resolve mais problemas do que cria?
[ ] Os arquivos afetados estão listados?
[ ] O backlog precisa ser atualizado?
[ ] Os testes precisam ser repetidos?
[ ] O risco residual foi registrado?
```

---

## 21. Relação com outros documentos

| Documento | Relação com decisões |
|---|---|
| 02_PROTOTYPE_SCOPE.md | Define se decisão cabe ou não no Marco 0.1 |
| 03_TECHNICAL_DESIGN.md | Define base técnica que decisões não devem contradizer |
| 04_SYSTEMS_ARCHITECTURE.md | Define contratos e ownership que decisões devem respeitar |
| 05_BACKLOG.md | Converte decisões em tarefas executáveis |
| 06_AI_CODEX_RULES.md | Controla decisões vindas de IA/Codex |
| 07_TEST_PLAN.md | Valida decisões por teste |
| 08_BUILD_NOTES.md | Garante que decisão não quebre execução |
| 09_ASSET_GUIDE.md | Controla decisões de asset/licença |
| 10_RISK_REGISTER.md | Mostra riscos que a decisão reduz ou aumenta |

---

## 22. Resumo final do decision log

```text
O decision log registra decisões que afetam escopo, arquitetura, código, IA, assets, testes e riscos.
Toda decisão importante deve ter motivo, alternativas, prós, contras, impacto e critério de revisão.
O objetivo é manter rastreabilidade e impedir que o projeto dependa de memória informal.
Decisões não registradas tendem a gerar retrabalho, conflito de escopo e perda de direção.
```
