# 10_RISK_REGISTER.md

# Império de Sangue — Registro de Riscos

| Campo | Valor |
|---|---|
| Documento | Registro de Riscos |
| Projeto | Império de Sangue |
| Versão do documento | 1.0 |
| Marco coberto | Marco 0.1 — Primeira invasão jogável |
| Engine alvo | Godot 4.x |
| Linguagem alvo | GDScript |
| Documento anterior | 09_ASSET_GUIDE.md |
| Próximo documento natural | 11_DECISION_LOG.md |
| Finalidade | Mapear riscos técnicos, escopo, licença, IA, motivação e qualidade do protótipo |
| Status | Registro inicial de riscos |

> Este documento existe para impedir que o projeto morra por escopo, bagunça técnica, assets inseguros, uso incorreto de IA ou perda de continuidade.  
> Risco não é pessimismo. É controle antecipado de falhas prováveis.

---

## 1. Finalidade do documento

Este arquivo registra e prioriza riscos do projeto **Império de Sangue**.

Ele responde:

```text
Quais riscos podem travar o Marco 0.1?
Qual risco é mais provável?
Qual risco causa maior impacto?
Qual risco precisa de mitigação imediata?
Qual gatilho indica que o risco virou problema real?
Qual plano de contingência usar?
```

Este documento deve ser revisado durante:

```text
mudança de escopo;
erro técnico recorrente;
uso intensivo de IA/Codex;
importação de asset externo;
pausa longa no projeto;
fechamento de uma wave;
início do Marco 0.2.
```

---

## 2. Método de avaliação de risco

Cada risco recebe três notas de 0 a 10:

```text
Probabilidade: chance de acontecer.
Impacto: dano se acontecer.
Detectabilidade: facilidade de perceber cedo. Quanto menor a detectabilidade, pior.
```

### 2.1 Fórmula operacional

```text
Score base = Probabilidade × Impacto
Score ajustado = Score base + (10 - Detectabilidade)
```

Exemplo:

```text
Probabilidade 8 × Impacto 9 = 72
Detectabilidade 4 → ajuste 6
Score ajustado = 78
```

### 2.2 Interpretação

```text
Quanto maior o score, mais cedo o risco deve ser tratado.
```

---

## 3. Escala de pontuação

### 3.1 Probabilidade

| Nota | Significado |
|---:|---|
| 0 | Não aplicável |
| 1–2 | Muito improvável |
| 3–4 | Possível, mas controlável |
| 5–6 | Moderado |
| 7–8 | Provável |
| 9–10 | Quase certo se nada for feito |

### 3.2 Impacto

| Nota | Significado |
|---:|---|
| 0 | Sem impacto |
| 1–2 | Incômodo menor |
| 3–4 | Atraso pequeno |
| 5–6 | Retrabalho relevante |
| 7–8 | Trava uma wave |
| 9–10 | Pode matar o Marco 0.1 |

### 3.3 Detectabilidade

| Nota | Significado |
|---:|---|
| 0 | Quase impossível detectar cedo |
| 1–2 | Difícil detectar antes de causar dano |
| 3–4 | Detectável com revisão cuidadosa |
| 5–6 | Detectável em teste normal |
| 7–8 | Fácil de perceber |
| 9–10 | Óbvio imediatamente |

---

## 4. Classificação de severidade

| Score ajustado | Classe | Ação |
|---:|---|---|
| 0–20 | Baixo | Monitorar |
| 21–40 | Moderado | Mitigar se aparecer em teste |
| 41–60 | Alto | Criar ação preventiva |
| 61–80 | Crítico | Tratar antes de avançar wave |
| 81–110 | Bloqueante | Parar expansão e corrigir |

---

## 5. Matriz geral de riscos

| ID | Categoria | Risco | Prob. | Impacto | Detect. | Score ajustado | Classe | Status |
|---|---|---|---:|---:|---:|---:|---|---|
| R-001 | Técnico | Player/controle FPS demorar mais que previsto | 5 | 7 | 7 | 38 | Moderado | Aberto |
| R-002 | Técnico | Raycast/interação ficar acoplado demais ao Player | 7 | 8 | 5 | 61 | Crítico | Aberto |
| R-003 | Técnico | NPCs exigirem IA mais complexa que o necessário | 8 | 9 | 4 | 78 | Crítico | Aberto |
| R-004 | Técnico | Inimigo/pathfinding travar desenvolvimento | 7 | 8 | 5 | 61 | Crítico | Aberto |
| R-005 | Técnico | WaveManager não controlar corretamente inimigos vivos | 6 | 8 | 6 | 52 | Alto | Aberto |
| R-006 | Escopo | Tentar criar jogo completo antes do Marco 0.1 | 9 | 10 | 3 | 97 | Bloqueante | Aberto |
| R-007 | Escopo | Adicionar diplomacia, magia ou economia cedo demais | 8 | 9 | 5 | 77 | Crítico | Aberto |
| R-008 | Escopo | Arte final consumir tempo antes do loop funcionar | 8 | 8 | 6 | 68 | Crítico | Aberto |
| R-009 | Licença | Usar asset sem licença comercial clara | 6 | 9 | 4 | 60 | Alto | Aberto |
| R-010 | Licença | Asset gerado por IA ter termos incertos | 5 | 8 | 3 | 47 | Alto | Aberto |
| R-011 | IA/Codex | Codex expandir arquitetura fora do escopo | 8 | 9 | 5 | 77 | Crítico | Aberto |
| R-012 | IA/Codex | Código gerado parecer correto, mas quebrar contrato arquitetural | 7 | 8 | 4 | 62 | Crítico | Aberto |
| R-013 | Motivação | Projeto parecer grande demais e gerar abandono | 7 | 9 | 4 | 69 | Crítico | Aberto |
| R-014 | Motivação | Excesso de documentação atrasar execução | 8 | 7 | 6 | 60 | Alto | Aberto |
| R-015 | Qualidade | Protótipo funcionar, mas não ser compreensível | 6 | 8 | 5 | 53 | Alto | Aberto |
| R-016 | Qualidade | Vitória/derrota parecerem aleatórias | 6 | 9 | 5 | 59 | Alto | Aberto |
| R-017 | Organização | Renomear arquivos e quebrar cenas/scripts | 5 | 7 | 6 | 39 | Moderado | Aberto |
| R-018 | Organização | Não registrar decisões e perder rastreabilidade | 7 | 7 | 3 | 56 | Alto | Aberto |
| R-019 | Build | Autoload/Input Map mal configurado impedir execução | 6 | 8 | 8 | 50 | Alto | Aberto |
| R-020 | Teste | Não repetir regressão após mudanças | 7 | 8 | 4 | 62 | Crítico | Aberto |

---

## 6. Riscos técnicos

### R-001 — Player/controle FPS demorar mais que previsto

| Campo | Valor |
|---|---|
| Probabilidade | 5 |
| Impacto | 7 |
| Detectabilidade | 7 |
| Score ajustado | 38 |
| Classe | Moderado |
| Gatilho | Movimento/câmera ainda instável após Wave 1 |
| Mitigação | Usar implementação FPS mínima, sem parkour, stamina complexa ou animações |
| Contingência | Reduzir para movimento básico sem sprint |

### R-002 — Raycast/interação ficar acoplado demais ao Player

| Campo | Valor |
|---|---|
| Probabilidade | 7 |
| Impacto | 8 |
| Detectabilidade | 5 |
| Score ajustado | 61 |
| Classe | Crítico |
| Gatilho | `player.gd` começa a ter `if` específico para madeira, NPC, núcleo e BuildSpot |
| Mitigação | Usar contrato `interact(actor)` em objetos interativos |
| Contingência | Refatorar interação antes de criar NPCs |

### R-003 — NPCs exigirem IA mais complexa que o necessário

| Campo | Valor |
|---|---|
| Probabilidade | 8 |
| Impacto | 9 |
| Detectabilidade | 4 |
| Score ajustado | 78 |
| Classe | Crítico |
| Gatilho | NPCs começarem a exigir comportamento autônomo, memória, personalidade ou pathfinding complexo |
| Mitigação | Limitar NPCs a estados simples: Idle, Moving, Working, Returning, Defending, Disabled |
| Contingência | Trocar NPCs por comportamento semi-estático temporário |

### R-004 — Inimigo/pathfinding travar desenvolvimento

| Campo | Valor |
|---|---|
| Probabilidade | 7 |
| Impacto | 8 |
| Detectabilidade | 5 |
| Score ajustado | 61 |
| Classe | Crítico |
| Gatilho | EnemyBasic não consegue chegar ao núcleo de forma confiável |
| Mitigação | Usar rota simples, alvo direto ou navegação mínima |
| Contingência | Usar movimento direto por direção até o alvo no Marco 0.1 |

### R-005 — WaveManager não controlar corretamente inimigos vivos

| Campo | Valor |
|---|---|
| Probabilidade | 6 |
| Impacto | 8 |
| Detectabilidade | 6 |
| Score ajustado | 52 |
| Classe | Alto |
| Gatilho | Onda nunca termina ou termina antes da hora |
| Mitigação | EnemyBasic deve emitir morte; WaveManager deve ser dono de `enemies_alive` |
| Contingência | Criar botão/debug para forçar fim de onda enquanto corrige contagem |

---

## 7. Riscos de escopo

### R-006 — Tentar criar jogo completo antes do Marco 0.1

| Campo | Valor |
|---|---|
| Probabilidade | 9 |
| Impacto | 10 |
| Detectabilidade | 3 |
| Score ajustado | 97 |
| Classe | Bloqueante |
| Gatilho | Surgirem tarefas de mundo aberto, facções, economia, múltiplas magias ou narrativa profunda antes do loop mínimo |
| Mitigação | Seguir 05_BACKLOG.md por waves |
| Contingência | Congelar novas ideias e mover para backlog futuro |

### R-007 — Adicionar diplomacia, magia ou economia cedo demais

| Campo | Valor |
|---|---|
| Probabilidade | 8 |
| Impacto | 9 |
| Detectabilidade | 5 |
| Score ajustado | 77 |
| Classe | Crítico |
| Gatilho | Qualquer tarefa fora de coleta, construção, NPCs, inimigo, onda e resultado entrar como prioridade |
| Mitigação | Validar toda tarefa contra 02_PROTOTYPE_SCOPE.md |
| Contingência | Cortar sistema e registrar em backlog futuro |

### R-008 — Arte final consumir tempo antes do loop funcionar

| Campo | Valor |
|---|---|
| Probabilidade | 8 |
| Impacto | 8 |
| Detectabilidade | 6 |
| Score ajustado | 68 |
| Classe | Crítico |
| Gatilho | Gastar horas em personagem, textura, animação ou cenário antes do protótipo jogável |
| Mitigação | Usar placeholders em `assets_temp` |
| Contingência | Voltar para cubos/cápsulas e cortar arte final |

---

## 8. Riscos de assets e licença

### R-009 — Usar asset sem licença comercial clara

| Campo | Valor |
|---|---|
| Probabilidade | 6 |
| Impacto | 9 |
| Detectabilidade | 4 |
| Score ajustado | 60 |
| Classe | Alto |
| Gatilho | Asset externo entra sem origem/licença em `assets_source` |
| Mitigação | Aplicar 09_ASSET_GUIDE.md e registrar origem |
| Contingência | Remover asset e substituir por placeholder |

### R-010 — Asset gerado por IA ter termos incertos

| Campo | Valor |
|---|---|
| Probabilidade | 5 |
| Impacto | 8 |
| Detectabilidade | 3 |
| Score ajustado | 47 |
| Classe | Alto |
| Gatilho | Usar asset de ferramenta IA sem salvar termos, prompt e origem |
| Mitigação | Registrar ferramenta, termos de uso, prompt e data |
| Contingência | Usar asset apenas como referência temporária ou remover |

---

## 9. Riscos de uso de IA/Codex

### R-011 — Codex expandir arquitetura fora do escopo

| Campo | Valor |
|---|---|
| Probabilidade | 8 |
| Impacto | 9 |
| Detectabilidade | 5 |
| Score ajustado | 77 |
| Classe | Crítico |
| Gatilho | Código gerado criar managers extras, inventário, save/load, facções ou sistemas futuros |
| Mitigação | Usar 06_AI_CODEX_RULES.md em todo prompt |
| Contingência | Rejeitar resposta e pedir versão reduzida ao Marco 0.1 |

### R-012 — Código gerado parecer correto, mas quebrar contrato arquitetural

| Campo | Valor |
|---|---|
| Probabilidade | 7 |
| Impacto | 8 |
| Detectabilidade | 4 |
| Score ajustado | 62 |
| Classe | Crítico |
| Gatilho | HUD decidir regra, Player controlar madeira, EnemyBasic decidir fim da onda |
| Mitigação | Revisar contra 04_SYSTEMS_ARCHITECTURE.md |
| Contingência | Refatorar antes de avançar wave |

---

## 10. Riscos de motivação e continuidade

### R-013 — Projeto parecer grande demais e gerar abandono

| Campo | Valor |
|---|---|
| Probabilidade | 7 |
| Impacto | 9 |
| Detectabilidade | 4 |
| Score ajustado | 69 |
| Classe | Crítico |
| Gatilho | Sensação de que “não avancei nada” por várias sessões |
| Mitigação | Trabalhar por tarefas pequenas do 05_BACKLOG.md |
| Contingência | Reduzir meta semanal para uma tarefa P0/P1 pequena |

### R-014 — Excesso de documentação atrasar execução

| Campo | Valor |
|---|---|
| Probabilidade | 8 |
| Impacto | 7 |
| Detectabilidade | 6 |
| Score ajustado | 60 |
| Classe | Alto |
| Gatilho | Criar documentos novos sem implementar waves |
| Mitigação | Após documentos base, alternar: 1 bloco de implementação para cada ajuste documental |
| Contingência | Congelar documentação e executar Wave 0/1 |

---

## 11. Riscos de qualidade do protótipo

### R-015 — Protótipo funcionar, mas não ser compreensível

| Campo | Valor |
|---|---|
| Probabilidade | 6 |
| Impacto | 8 |
| Detectabilidade | 5 |
| Score ajustado | 53 |
| Classe | Alto |
| Gatilho | Jogador não entende madeira, núcleo, barricada, onda ou resultado |
| Mitigação | HUD textual mínima e teste de usabilidade do 07_TEST_PLAN.md |
| Contingência | Adicionar feedback textual antes de arte final |

### R-016 — Vitória/derrota parecerem aleatórias

| Campo | Valor |
|---|---|
| Probabilidade | 6 |
| Impacto | 9 |
| Detectabilidade | 5 |
| Score ajustado | 59 |
| Classe | Alto |
| Gatilho | Jogador perde sem entender causa ou vence sem preparação |
| Mitigação | Garantir que barricada, NPCs e preparação alterem resultado |
| Contingência | Ajustar dano, vida e quantidade de inimigos |

---

## 12. Riscos de organização do projeto

### R-017 — Renomear arquivos e quebrar cenas/scripts

| Campo | Valor |
|---|---|
| Probabilidade | 5 |
| Impacto | 7 |
| Detectabilidade | 6 |
| Score ajustado | 39 |
| Classe | Moderado |
| Gatilho | Cena não encontra script ou recurso após reorganização |
| Mitigação | Evitar renomear sem necessidade; registrar mudanças no changelog |
| Contingência | Reverter renomeação ou corrigir referências no editor |

### R-018 — Não registrar decisões e perder rastreabilidade

| Campo | Valor |
|---|---|
| Probabilidade | 7 |
| Impacto | 7 |
| Detectabilidade | 3 |
| Score ajustado | 56 |
| Classe | Alto |
| Gatilho | Mudanças importantes feitas “de cabeça” sem registro |
| Mitigação | Usar 11_DECISION_LOG.md para decisões técnicas e escopo |
| Contingência | Reconstituir decisão e registrar retroativamente |

### R-019 — Autoload/Input Map mal configurado impedir execução

| Campo | Valor |
|---|---|
| Probabilidade | 6 |
| Impacto | 8 |
| Detectabilidade | 8 |
| Score ajustado | 50 |
| Classe | Alto |
| Gatilho | Erro de Autoload não encontrado ou input não responde |
| Mitigação | Aplicar 08_BUILD_NOTES.md antes de rodar testes |
| Contingência | Revisar Project Settings e Input Map |

### R-020 — Não repetir regressão após mudanças

| Campo | Valor |
|---|---|
| Probabilidade | 7 |
| Impacto | 8 |
| Detectabilidade | 4 |
| Score ajustado | 62 |
| Classe | Crítico |
| Gatilho | Corrigir um sistema e quebrar outro sem perceber |
| Mitigação | Rodar regressão mínima do 07_TEST_PLAN.md após alterações P0/P1 |
| Contingência | Voltar para última versão funcional registrada |

---

## 13. Planos de mitigação prioritários

Prioridade imediata:

| Prioridade | Risco | Ação |
|---:|---|---|
| 1 | R-006 | Não iniciar sistemas fora do Marco 0.1 |
| 2 | R-003 | Manter NPCs com estados simples |
| 3 | R-011 | Usar prompt restritivo do 06_AI_CODEX_RULES.md |
| 4 | R-007 | Bloquear diplomacia, magia avançada e economia ampla |
| 5 | R-020 | Rodar regressão mínima após mudanças P0/P1 |
| 6 | R-008 | Usar placeholders até o loop funcionar |
| 7 | R-013 | Trabalhar por tarefas pequenas do backlog |

---

## 14. Gatilhos de intervenção

Parar expansão e corrigir quando ocorrer:

```text
nova ideia fora do Marco 0.1 virar tarefa ativa;
mais de 2 sessões sem avanço jogável;
NPC exigir comportamento complexo;
IA gerar sistema não solicitado;
HUD começar a controlar regra;
Player começar a controlar tudo;
asset externo entrar sem licença;
vitória/derrota não funcionar;
projeto não abrir;
regressão quebrar algo que já funcionava.
```

---

## 15. Checklist semanal de riscos

Usar uma vez por semana ou a cada bloco de desenvolvimento.

```text
[ ] Alguma tarefa fora do Marco 0.1 entrou no trabalho atual?
[ ] Algum sistema ficou mais complexo que o necessário?
[ ] Algum asset entrou sem licença registrada?
[ ] Algum código de IA foi colado sem revisão?
[ ] O projeto ainda abre na Godot?
[ ] Main.tscn ainda roda?
[ ] A última mudança passou nos testes de regressão mínimos?
[ ] Existe bug S0 ou S1 aberto?
[ ] O backlog ainda reflete o que está sendo feito?
[ ] Houve avanço jogável nesta semana?
```

---

## 16. Template para novo risco

```text
ID:
Categoria:
Descrição:
Probabilidade: 0–10
Impacto: 0–10
Detectabilidade: 0–10
Score ajustado:
Classe: Baixo / Moderado / Alto / Crítico / Bloqueante
Gatilho:
Mitigação:
Contingência:
Responsável:
Status: Aberto / Mitigado / Fechado / Aceito
Data de criação:
Última revisão:
```

---

## 17. Critérios para fechar risco

Um risco pode ser fechado quando:

```text
não se aplica mais ao Marco 0.1;
a causa foi removida;
há teste comprovando que não ocorre;
foi aceito conscientemente como risco residual;
foi movido para Marco futuro;
a mitigação virou regra permanente do projeto.
```

Não fechar risco apenas porque foi esquecido.

---

## 18. Resumo final do registro de riscos

```text
Os maiores riscos do projeto são escopo, IA/Codex expandindo demais, NPCs complexos, arte antes da mecânica e abandono por excesso de ambição.
O Marco 0.1 deve continuar pequeno: coleta, construção, 2 NPCs, inimigo básico, onda, vitória e derrota.
Riscos com score crítico ou bloqueante devem ser tratados antes de avançar novas waves.
Toda mitigação deve favorecer execução simples, teste manual e rastreabilidade.
```
