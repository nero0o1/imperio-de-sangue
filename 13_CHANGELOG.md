# 13_CHANGELOG.md

# Império de Sangue — Changelog

| Campo | Valor |
|---|---|
| Documento | Changelog |
| Projeto | Império de Sangue |
| Versão do documento | 1.0 |
| Marco coberto | Marco 0.1 — Primeira invasão jogável |
| Engine alvo | Godot 4.x |
| Linguagem alvo | GDScript |
| Documento anterior | 12_OPEN_QUESTIONS.md |
| Próximo documento natural | 14_ROADMAP.md |
| Finalidade | Registrar alterações por versão, data, tipo, arquivos afetados e impacto |
| Status | Changelog inicial rigoroso |

> Este documento registra o histórico de mudanças do projeto.  
> O objetivo é saber o que mudou, quando mudou, por que mudou, quem/qual fonte motivou a mudança e qual impacto ela teve.

---

## 1. Finalidade do documento

Este arquivo registra mudanças relevantes no projeto **Império de Sangue**.

Ele responde:

```text
O que mudou?
Quando mudou?
Qual versão foi afetada?
Qual arquivo foi alterado?
Qual tipo de mudança ocorreu?
Qual foi o impacto?
A mudança veio de decisão, bug, teste, IA/Codex ou ajuste manual?
A mudança exige atualização em outros documentos?
A mudança precisa de teste de regressão?
```

Este documento serve para reduzir perda de rastreabilidade e permitir reversão controlada.

---

## 2. Regras de uso do changelog

### 2.1 Regra principal

Registrar mudanças que afetem:

```text
escopo;
arquitetura;
backlog;
testes;
riscos;
decisões;
perguntas em aberto;
assets/licença;
código;
cenas Godot;
configuração de build;
uso de IA/Codex.
```

### 2.2 Regra de rastreabilidade

Toda mudança relevante deve apontar pelo menos um destes vínculos:

```text
ID de decisão: DEC-xxx;
ID de risco: R-xxx;
ID de pergunta: Q-xxx;
ID de tarefa: Wn-xx;
ID de teste: TC-xxx;
ID de bug: BUG-xxx;
origem IA/Codex, se aplicável.
```

---

## 3. Padrão de versionamento

Usar versionamento simples e compatível com protótipo.

```text
0.0.x = documentação, preparação, ajustes sem build jogável
0.1.x = Marco 0.1 em desenvolvimento
0.1.0 = primeira invasão jogável mínima
0.2.x = expansão posterior ao Marco 0.1
```

### 3.1 Interpretação prática

| Versão | Significado |
|---|---|
| 0.0.1 | Estrutura inicial de documentação |
| 0.0.2 | Documentos de escopo/arquitetura/backlog refinados |
| 0.0.3 | Regras de IA, teste, build, assets e riscos criadas |
| 0.1.0-dev | Início de implementação jogável |
| 0.1.0 | Marco 0.1 jogável com vitória e derrota |

---

## 4. Tipos de mudança

| Tipo | Quando usar |
|---|---|
| ADDED | Algo novo foi criado |
| CHANGED | Algo existente foi alterado |
| FIXED | Bug ou erro foi corrigido |
| REMOVED | Algo foi removido |
| DEPRECATED | Algo ainda existe, mas será removido futuramente |
| SECURITY | Mudança ligada a segurança, licença ou risco legal |
| DOC | Mudança documental |
| TEST | Mudança de teste ou validação |
| BUILD | Mudança de build, execução ou configuração |
| ASSET | Mudança em asset, material, textura, áudio ou licença |
| AI | Mudança produzida ou motivada por IA/Codex |

---

## 5. Níveis de impacto

| Impacto | Descrição | Exige teste? |
|---|---|---|
| I0 | Sem impacto funcional | Não |
| I1 | Afeta texto/documentação local | Não, salvo inconsistência |
| I2 | Afeta um documento ou arquivo isolado | Revisão simples |
| I3 | Afeta um sistema ou cena | Sim |
| I4 | Afeta múltiplos sistemas/documentos | Sim, regressão parcial |
| I5 | Afeta arquitetura, escopo ou build jogável | Sim, regressão obrigatória |

---

## 6. Status de mudança

| Status | Significado |
|---|---|
| PROPOSED | Mudança proposta, ainda não aplicada |
| APPLIED | Mudança aplicada |
| TESTING | Mudança aplicada e em teste |
| VERIFIED | Mudança aplicada e validada |
| REVERTED | Mudança revertida |
| CANCELLED | Mudança cancelada antes de aplicar |

---

## 7. Formato obrigatório de entrada

Toda entrada relevante deve conter:

```text
ID da mudança;
data;
versão;
tipo;
status;
impacto;
resumo;
arquivos afetados;
origem;
vínculos;
teste necessário;
resultado da validação;
observações.
```

---

## 8. Changelog inicial dos documentos

| ID | Data | Versão | Tipo | Status | Impacto | Resumo | Arquivos afetados | Origem |
|---|---|---|---|---|---|---|---|---|
| CHG-001 | A preencher | 0.0.1 | ADDED/DOC | APPLIED | I2 | Criado arquivo 00 de visão geral do projeto | 00_PROJECT_OVERVIEW.md | Planejamento |
| CHG-002 | A preencher | 0.0.1 | ADDED/DOC | APPLIED | I2 | Criado arquivo 01 de conceito do jogo | 01_GAME_CONCEPT.md | Planejamento |
| CHG-003 | A preencher | 0.0.2 | ADDED/DOC | APPLIED | I3 | Criado arquivo 02 de escopo do protótipo | 02_PROTOTYPE_SCOPE.md | Escopo |
| CHG-004 | A preencher | 0.0.2 | ADDED/DOC | APPLIED | I3 | Criado arquivo 03 de design técnico | 03_TECHNICAL_DESIGN.md | Arquitetura técnica |
| CHG-005 | A preencher | 0.0.2 | ADDED/DOC | APPLIED | I4 | Criado arquivo 04 de arquitetura de sistemas | 04_SYSTEMS_ARCHITECTURE.md | Arquitetura |
| CHG-006 | A preencher | 0.0.2 | ADDED/DOC | APPLIED | I4 | Criado arquivo 05 de backlog por waves | 05_BACKLOG.md | Planejamento executivo |
| CHG-007 | A preencher | 0.0.3 | ADDED/DOC/AI | APPLIED | I4 | Criado arquivo 06 de regras para IA/Codex | 06_AI_CODEX_RULES.md | Governança de IA |
| CHG-008 | A preencher | 0.0.3 | ADDED/DOC/TEST | APPLIED | I4 | Criado arquivo 07 de plano de testes | 07_TEST_PLAN.md | QA manual |
| CHG-009 | A preencher | 0.0.3 | ADDED/DOC/BUILD | APPLIED | I3 | Criado arquivo 08 de notas de build e execução | 08_BUILD_NOTES.md | Execução local |
| CHG-010 | A preencher | 0.0.3 | ADDED/DOC/ASSET | APPLIED | I3 | Criado arquivo 09 de guia de assets | 09_ASSET_GUIDE.md | Assets/licença |
| CHG-011 | A preencher | 0.0.3 | ADDED/DOC | APPLIED | I4 | Criado arquivo 10 de registro de riscos | 10_RISK_REGISTER.md | Riscos |
| CHG-012 | A preencher | 0.0.3 | ADDED/DOC | APPLIED | I4 | Criado arquivo 11 de registro de decisões | 11_DECISION_LOG.md | Rastreabilidade |
| CHG-013 | A preencher | 0.0.3 | ADDED/DOC | APPLIED | I3 | Criado arquivo 12 de perguntas em aberto | 12_OPEN_QUESTIONS.md | Perguntas abertas |

---

## 9. Registro por versão

### 0.0.3 — Documentação operacional e governança

| ID | Tipo | Resumo | Impacto | Status |
|---|---|---|---|---|
| CHG-007 | DOC/AI | Regras para IA/Codex | I4 | APPLIED |
| CHG-008 | DOC/TEST | Plano de testes | I4 | APPLIED |
| CHG-009 | DOC/BUILD | Notas de build | I3 | APPLIED |
| CHG-010 | DOC/ASSET | Guia de assets | I3 | APPLIED |
| CHG-011 | DOC | Registro de riscos | I4 | APPLIED |
| CHG-012 | DOC | Registro de decisões | I4 | APPLIED |
| CHG-013 | DOC | Perguntas em aberto | I3 | APPLIED |

### 0.0.2 — Escopo, técnica e arquitetura

| ID | Tipo | Resumo | Impacto | Status |
|---|---|---|---|---|
| CHG-003 | DOC | Escopo do protótipo | I3 | APPLIED |
| CHG-004 | DOC | Design técnico | I3 | APPLIED |
| CHG-005 | DOC | Arquitetura de sistemas | I4 | APPLIED |
| CHG-006 | DOC | Backlog por waves | I4 | APPLIED |

### 0.0.1 — Fundação documental

| ID | Tipo | Resumo | Impacto | Status |
|---|---|---|---|---|
| CHG-001 | DOC | Visão geral do projeto | I2 | APPLIED |
| CHG-002 | DOC | Conceito do jogo | I2 | APPLIED |

---

## 10. Registro por data

Usar esta seção para registrar mudanças futuras em ordem cronológica.

### AAAA-MM-DD

| ID | Versão | Tipo | Status | Impacto | Resumo | Arquivos afetados | Teste |
|---|---|---|---|---|---|---|---|
| CHG-XXX | 0.x.x | ADDED/CHANGED/FIXED | PROPOSED/APPLIED/VERIFIED | I0–I5 | A preencher | A preencher | Sim/Não |

---

## 11. Mudanças em documentação

Registrar quando houver:

```text
novo documento;
remoção de documento;
alteração de escopo;
alteração de arquitetura;
alteração de backlog;
alteração de teste;
alteração de risco;
alteração de decisão;
alteração de pergunta aberta.
```

### 11.1 Regra

```text
Toda mudança documental que afeta execução deve apontar o documento afetado e o motivo.
```

---

## 12. Mudanças em código

Registrar quando houver:

```text
novo script;
alteração de script existente;
correção de bug;
renomeação de função pública;
alteração de sinal;
alteração de contrato entre sistemas;
alteração de Autoload;
refatoração relevante.
```

### 12.1 Campos extras para código

```text
Script afetado:
Sistema afetado:
Tarefa do backlog:
Teste executado:
Regressão necessária:
```

---

## 13. Mudanças em cenas Godot

Registrar quando houver:

```text
nova cena;
renomeação de cena;
mudança na árvore de nós;
script anexado ou removido;
collider alterado;
Input Map impactado;
referência quebrada ou corrigida.
```

### 13.1 Campos extras para cena

```text
Cena afetada:
Nós alterados:
Scripts anexados:
Teste no editor:
```

---

## 14. Mudanças em assets

Registrar quando houver:

```text
novo asset externo;
substituição de placeholder;
remoção de asset;
alteração de licença;
asset movido para assets_final;
asset gerado por IA;
asset vindo de fotogrametria;
asset editado no Blender.
```

### 14.1 Campos extras para asset

```text
Asset afetado:
Origem:
Licença:
Uso comercial permitido:
Pasta:
Registro em ASSET_REGISTER:
```

---

## 15. Mudanças em arquitetura

Registrar quando houver:

```text
novo Autoload;
remoção de Autoload;
alteração de ownership;
alteração de sinal global;
alteração de fluxo de vitória/derrota;
alteração de ResourceManager;
alteração de WaveManager;
alteração do contrato interact(actor).
```

### 15.1 Regra

Mudança arquitetural exige:

```text
entrada no 11_DECISION_LOG.md;
revisão do 04_SYSTEMS_ARCHITECTURE.md;
teste de regressão no 07_TEST_PLAN.md.
```

---

## 16. Mudanças em escopo

Registrar quando houver:

```text
sistema novo;
sistema removido;
item movido para fora do Marco 0.1;
item trazido de marco futuro;
alteração de prioridade no backlog;
alteração de critério de aceite.
```

### 16.1 Regra

Mudança de escopo sem decisão registrada é inválida.

---

## 17. Mudanças vindas de IA/Codex

Registrar quando IA/Codex:

```text
gerar código aceito;
gerar código rejeitado por escopo;
sugerir refatoração;
sugerir mudança arquitetural;
corrigir bug;
criar documentação;
alterar prompt padrão;
introduzir risco ou erro.
```

### 17.1 Campos extras para IA/Codex

```text
Ferramenta:
Prompt usado:
Resumo da resposta:
Aceito? Sim/Não/Parcial
Motivo:
Arquivos afetados:
Teste executado:
```

---

## 18. Mudanças de teste e bugs

Registrar quando houver:

```text
novo caso de teste;
alteração em caso de teste;
bug S0/S1;
bug recorrente;
correção validada;
regressão encontrada;
critério de aceite alterado.
```

### 18.1 Campos extras para bug/teste

```text
Bug relacionado:
Teste relacionado:
Resultado antes:
Resultado depois:
Regressão executada:
```

---

## 19. Critérios para registrar mudança

Registrar se a mudança:

```text
afeta execução;
afeta escopo;
afeta arquitetura;
afeta teste;
afeta risco;
afeta decisão;
afeta asset/licença;
afeta build;
afeta backlog;
pode gerar dúvida futura;
precisa de regressão;
foi feita por IA/Codex e aceita.
```

---

## 20. Critérios para não registrar mudança

Não precisa registrar:

```text
correção ortográfica sem impacto;
reformatação visual sem mudança de conteúdo;
comentário local sem mudança de regra;
ajuste temporário descartado no mesmo momento;
teste informal sem consequência;
placeholder criado e removido imediatamente.
```

Se houver dúvida, registrar de forma curta.

---

## 21. Template curto de changelog

```text
ID:
Data:
Versão:
Tipo:
Status:
Impacto:
Resumo:
Arquivos afetados:
Origem:
Teste necessário:
```

---

## 22. Template completo de changelog

```text
ID:
Data:
Versão:
Tipo: ADDED / CHANGED / FIXED / REMOVED / DEPRECATED / SECURITY / DOC / TEST / BUILD / ASSET / AI
Status: PROPOSED / APPLIED / TESTING / VERIFIED / REVERTED / CANCELLED
Impacto: I0 / I1 / I2 / I3 / I4 / I5
Resumo:

Motivo:

Arquivos afetados:
-
-

Origem:
- Humano / IA-Codex / Bug / Teste / Risco / Decisão / Pergunta aberta

Vínculos:
- Decisão: DEC-xxx
- Risco: R-xxx
- Pergunta: Q-xxx
- Backlog: Wn-xx
- Teste: TC-xxx
- Bug: BUG-xxx

Validação necessária:
-
-

Resultado da validação:

Observações:
```

---

## 23. Checklist antes de fechar versão

```text
[ ] Toda mudança relevante foi registrada.
[ ] Mudanças de arquitetura têm decisão no 11_DECISION_LOG.md.
[ ] Mudanças de risco foram refletidas no 10_RISK_REGISTER.md.
[ ] Mudanças de teste foram refletidas no 07_TEST_PLAN.md.
[ ] Mudanças de backlog foram refletidas no 05_BACKLOG.md.
[ ] Mudanças de asset respeitam 09_ASSET_GUIDE.md.
[ ] Mudanças de IA/Codex respeitam 06_AI_CODEX_RULES.md.
[ ] Build/execução ainda segue 08_BUILD_NOTES.md.
[ ] Regressão foi executada quando impacto I3 ou maior.
[ ] Não existe mudança estrutural sem motivo registrado.
```

---

## 24. Resumo final do changelog

```text
O changelog registra mudanças por versão, data, tipo, arquivos afetados e impacto.
Mudanças relevantes precisam de vínculo com decisão, risco, pergunta, backlog, teste ou bug.
Mudanças de impacto I3 ou maior exigem teste.
Mudanças de escopo ou arquitetura exigem decisão registrada.
O objetivo é manter rastreabilidade e permitir reversão controlada.
```
