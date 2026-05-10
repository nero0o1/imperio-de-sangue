# 09_ASSET_GUIDE.md

# Império de Sangue — Guia de Assets

| Campo | Valor |
|---|---|
| Documento | Guia de Assets |
| Projeto | Império de Sangue |
| Versão do documento | 1.0 |
| Marco coberto | Marco 0.1 — Primeira invasão jogável |
| Engine alvo | Godot 4.x |
| Ferramenta 3D principal | Blender |
| Documento anterior | 08_BUILD_NOTES.md |
| Próximo documento natural | 10_RISK_REGISTER.md |
| Finalidade | Controlar uso, origem, licença, organização e substituição de assets do protótipo |
| Status | Guia inicial para placeholders, assets temporários e assets comerciais futuros |

> Este documento evita bagunça visual, perda de rastreabilidade e risco jurídico por uso de assets sem licença clara.  
> No Marco 0.1, assets existem para validar gameplay, não para criar arte final.

---

## 1. Finalidade do documento

Este arquivo define regras para uso de assets no projeto **Império de Sangue**.

Ele responde:

```text
Onde colocar assets temporários?
Onde colocar assets editáveis?
Quando um asset pode entrar no projeto?
Como registrar origem e licença?
Quais formatos usar com Godot 4.x?
Como usar Blender no pipeline?
Como evitar assets com risco comercial?
Quando substituir placeholder por asset final?
```

Este documento não é:

```text
manual completo de arte 3D;
parecer jurídico;
catálogo final de assets;
guia completo de animação;
guia de otimização avançada;
documento de monetização.
```

---

## 2. Princípio central de assets

No Marco 0.1, a regra é:

```text
Gameplay primeiro.
Arte final depois.
Licença sempre rastreável.
```

### 2.1 Regra principal

```text
Nenhum asset externo deve entrar no projeto sem origem e licença registradas.
```

### 2.2 Prioridade no protótipo

| Prioridade | Decisão |
|---|---|
| 1 | Usar formas simples da Godot/Blender |
| 2 | Usar placeholders próprios |
| 3 | Usar assets CC0 ou permissivos com registro |
| 4 | Deixar assets pagos/comerciais para fase posterior |
| 5 | Evitar asset com licença confusa |

---

## 3. Tipos de assets do projeto

| Tipo | Exemplo | Uso no Marco 0.1 |
|---|---|---|
| Placeholder 3D | cubo, cápsula, cilindro | Permitido e recomendado |
| Mesh 3D | barricada, árvore, inimigo | Permitido se simples e rastreável |
| Material | cor de madeira, pedra, metal | Permitido com material simples |
| Textura | madeira, terra, pedra | Usar apenas se licença clara |
| Ícone/UI | madeira, vida, alerta | Pode ser texto simples no início |
| Áudio | ataque, dano, onda | Opcional; não bloquear protótipo |
| Animação | andar, atacar, morrer | Fora do mínimo se atrasar implementação |
| Asset gerado por IA | objeto ou textura | Só com registro de ferramenta e termos |
| Fotogrametria | objeto real escaneado | Só se o objeto for próprio ou autorizado |

---

## 4. Estrutura de pastas para assets

Estrutura recomendada:

```text
res://
  assets_temp/
    meshes/
    materials/
    textures/
    icons/
    audio/

  assets_source/
    blender/
    references/
    photogrammetry/
    ai_generated/
    licenses/

  assets_final/
    meshes/
    materials/
    textures/
    icons/
    audio/
```

### 4.1 Função de cada pasta

| Pasta | Função |
|---|---|
| `assets_temp/` | Assets temporários usados para testar gameplay |
| `assets_source/` | Arquivos editáveis, referências, Blender, registros e licenças |
| `assets_final/` | Assets aprovados para versão mais madura |
| `assets_source/licenses/` | Cópias ou registros de licenças |
| `assets_source/references/` | Referências visuais que não entram diretamente no jogo |

### 4.2 Regra

```text
Asset sem licença registrada não deve sair de assets_temp para assets_final.
```

---

## 5. Regras para placeholders

Placeholders são permitidos e recomendados no Marco 0.1.

### 5.1 Placeholders aceitáveis

```text
cubo para barricada;
cápsula para jogador;
cápsula vermelha/cinza para inimigo;
cilindro para árvore;
caixa para núcleo;
plano simples para chão;
texto simples na HUD;
material colorido básico.
```

### 5.2 Regras

```text
Placeholder deve ser fácil de substituir.
Placeholder deve ter nome claro.
Placeholder não deve exigir pipeline complexo.
Placeholder não deve consumir tempo de arte final.
Placeholder deve ficar em assets_temp.
```

### 5.3 Nome recomendado

```text
TEMP_barricade_block.glb
TEMP_enemy_capsule.tres
TEMP_wood_material.tres
TEMP_core_box.glb
```

---

## 6. Regras para assets 3D

### 6.1 Formatos recomendados

| Formato | Uso recomendado |
|---|---|
| GLB | Preferencial para Godot; empacota mesh, material e textura com praticidade |
| GLTF | Bom para pipeline aberto com arquivos separados |
| OBJ | Útil para mesh estática simples, mas limitado para materiais/animação |
| FBX | Usar apenas se necessário; pode gerar inconsistência de importação |
| BLEND | Guardar como fonte editável em assets_source/blender |

### 6.2 Regras técnicas

```text
Preferir GLB para importação na Godot.
Manter arquivo BLEND original em assets_source/blender.
Evitar mesh pesada no Marco 0.1.
Evitar rig/animação complexa no início.
Aplicar escala e rotação no Blender antes de exportar.
Usar nomes claros para objetos.
```

### 6.3 Escala inicial

Regra prática:

```text
1 unidade Godot ≈ 1 metro.
```

Não precisa ser perfeito no protótipo, mas precisa ser consistente.

---

## 7. Regras para texturas e materiais

### 7.1 Materiais no Marco 0.1

No início, usar materiais simples:

```text
marrom para madeira;
cinza para pedra;
vermelho escuro para inimigo;
azul/cinza para jogador em debug;
verde ou amarelo para ponto interativo.
```

### 7.2 Texturas externas

Texturas externas só entram se houver:

```text
origem registrada;
licença registrada;
permissão para uso comercial, se houver intenção futura de monetizar;
arquivo de licença salvo ou link registrado;
autor registrado, quando aplicável.
```

### 7.3 Proibido no Marco 0.1

```text
baixar textura aleatória do Google Imagens;
usar textura sem origem;
usar textura com marca d'água;
usar textura de jogo conhecido;
usar textura de filme/série/anime;
usar textura sem licença clara.
```

---

## 8. Regras para áudio

Áudio é opcional no Marco 0.1.

### 8.1 Permitido

```text
som temporário próprio;
som CC0 com registro;
beep simples para feedback;
áudio gerado pelo próprio desenvolvedor;
áudio criado em ferramenta com termos claros.
```

### 8.2 Proibido

```text
música comercial;
áudio retirado de jogo;
áudio retirado de filme, série ou anime;
som de biblioteca sem licença clara;
áudio com restrição contra uso comercial se houver intenção futura de monetizar.
```

### 8.3 Regra

```text
Áudio não deve bloquear o Marco 0.1.
Se atrasar, remover áudio e manter feedback visual/textual.
```

---

## 9. Regras para UI e ícones

No Marco 0.1, UI pode ser textual.

### 9.1 UI mínima

```text
Madeira: 0
Núcleo: 100/100
Onda: aguardando/iniciada/finalizada
Vitória
Derrota
Pressione E para interagir
```

### 9.2 Ícones

Ícones só entram se:

```text
forem próprios;
forem CC0;
tiverem licença permissiva registrada;
não forem copiados de jogos conhecidos.
```

---

## 10. Regras legais e licenças

Este documento não é parecer jurídico. Ele define uma política prática de redução de risco.

### 10.1 Licenças preferidas

| Licença/origem | Uso recomendado |
|---|---|
| Criado pelo próprio desenvolvedor | Melhor opção |
| CC0 / domínio público verificável | Baixo risco, desde que registrado |
| Licença permissiva com uso comercial | Aceitável com registro |
| Asset pago com licença comercial clara | Aceitável no futuro, guardar comprovante |
| Asset sem licença clara | Não usar |
| Conteúdo de franquias conhecidas | Não usar |

### 10.2 Regra comercial

Se existe possibilidade de cobrar pelo jogo no futuro:

```text
usar apenas assets com permissão comercial clara;
guardar prova de licença;
guardar link de origem;
guardar data de acesso;
guardar nome do autor quando aplicável;
não usar asset apenas porque “parece gratuito”.
```

---

## 11. Matriz de risco de licença

| Risco | Descrição | Ação |
|---|---|---|
| Baixo | Asset próprio ou CC0 com registro | Pode usar |
| Médio | Licença permissiva, mas exige atribuição | Usar se atribuição for registrada |
| Alto | Licença confusa, sem uso comercial claro | Não usar em build pública |
| Crítico | Conteúdo copiado de franquia/marca/personagem | Não usar |
| Desconhecido | Sem origem ou sem licença | Não usar |

### 11.1 Regra

```text
Na dúvida, tratar como risco alto e não usar em build pública/comercial.
```

---

## 12. Registro obrigatório de origem

Todo asset externo precisa de registro.

Campos mínimos:

```text
Nome do asset:
Tipo:
Arquivo:
Origem:
Autor:
Licença:
Permite uso comercial? Sim/Não/Incerto
Exige atribuição? Sim/Não/Incerto
Data de download/acesso:
Link ou comprovante:
Alterações feitas:
Pasta atual:
Decisão: temporário / aprovado / rejeitado
```

### 12.1 Arquivo recomendado

Registrar assets em documento futuro ou tabela:

```text
assets_source/ASSET_REGISTER.md
```

---

## 13. Pipeline Blender → Godot

### 13.1 Etapas

```text
1. Criar ou editar asset no Blender.
2. Aplicar escala e rotação.
3. Nomear objetos de forma clara.
4. Remover objetos ocultos ou desnecessários.
5. Salvar .blend em assets_source/blender.
6. Exportar como GLB para assets_temp ou assets_final.
7. Importar na Godot.
8. Conferir escala, material e colisão.
9. Testar dentro de TestMap.tscn.
```

### 13.2 Regra de exportação

```text
BLEND é fonte editável.
GLB é arquivo de uso na Godot.
```

---

## 14. Pipeline IA/Fotogrametria → Blender → Godot

### 14.1 IA gerando asset

Quando asset for gerado por IA, registrar:

```text
ferramenta usada;
prompt usado;
data;
termos de uso da ferramenta;
se permite uso comercial;
se exige atribuição;
se o resultado foi editado no Blender.
```

### 14.2 Fotogrametria

Fotogrametria só deve usar:

```text
objeto próprio;
objeto com autorização;
ambiente sem marcas protegidas;
sem rosto/pessoa identificável;
sem propriedade privada sensível;
sem obra artística protegida sem permissão.
```

### 14.3 Pipeline recomendado

```text
captura ou geração
→ limpeza no Blender
→ redução/simplificação se necessário
→ exportação GLB
→ teste na Godot
→ registro de origem/licença
```

---

## 15. Padrões de nomeação

### 15.1 Prefixos

| Prefixo | Uso |
|---|---|
| TEMP_ | Asset temporário/placeholders |
| SRC_ | Arquivo fonte/editável |
| FINAL_ | Asset aprovado para uso mais maduro |
| UI_ | Ícone ou elemento de interface |
| MAT_ | Material |
| TEX_ | Textura |
| SFX_ | Efeito sonoro |
| BGM_ | Música |

### 15.2 Exemplos

```text
TEMP_barricade_block.glb
TEMP_enemy_capsule.glb
SRC_barricade_wood.blend
FINAL_barricade_wood.glb
MAT_wood_basic.tres
TEX_ground_dirt_cc0.png
SFX_hit_wood_cc0.wav
```

---

## 16. Critérios para substituir placeholder

Substituir placeholder só quando:

```text
a mecânica associada estiver funcionando;
o asset novo tiver origem registrada;
a licença estiver clara;
o asset não quebrar escala;
o asset não prejudicar performance;
o asset não atrasar o Marco 0.1;
o asset melhorar leitura do gameplay.
```

### 16.1 Regra

```text
Não substituir placeholder por estética se o sistema ainda não funciona.
```

---

## 17. O que fica fora do Marco 0.1

Não priorizar agora:

```text
personagens finais;
animações finais;
cinemáticas;
trilhas sonoras finais;
texturas PBR complexas;
LOD;
rig avançado;
assets comprados;
pack visual completo;
identidade visual comercial;
interface final;
polimento gráfico avançado.
```

---

## 18. Checklist antes de importar asset

```text
[ ] O asset é necessário para o Marco 0.1?
[ ] Pode ser substituído por placeholder?
[ ] A origem está registrada?
[ ] A licença está registrada?
[ ] Permite uso comercial, se necessário?
[ ] Exige atribuição?
[ ] O arquivo fonte foi guardado?
[ ] O nome segue padrão?
[ ] A pasta correta foi usada?
[ ] O asset foi testado na Godot?
```

---

## 19. Checklist antes de usar comercialmente

Antes de usar em build pública/comercial:

```text
[ ] Origem confirmada.
[ ] Licença salva ou registrada.
[ ] Uso comercial permitido.
[ ] Atribuição registrada, se exigida.
[ ] Não contém marca registrada visível.
[ ] Não contém personagem de franquia.
[ ] Não contém textura copiada de outro jogo.
[ ] Não contém áudio comercial.
[ ] Não contém pessoa identificável sem autorização.
[ ] Não depende de ferramenta com termos incompatíveis.
```

Se qualquer item falhar, o asset não deve entrar em build comercial.

---

## 20. Problemas comuns com assets

| Problema | Causa provável | Correção inicial |
|---|---|---|
| Asset gigante na Godot | Escala errada no Blender | Aplicar escala e exportar novamente |
| Material não aparece | Exportação incompleta | Revisar GLB/material |
| Textura ausente | Caminho quebrado | Usar GLB ou corrigir referência |
| Colisão inexistente | Mesh sem CollisionShape | Criar colisão simples na Godot |
| Asset pesado | Polígonos demais | Simplificar no Blender |
| Licença incerta | Origem mal registrada | Não usar fora de teste local |
| Nome confuso | Sem padrão | Renomear com prefixo adequado |
| Importação inconsistente | Formato problemático | Preferir GLB |

---

## 21. Template de registro de asset

```text
ID do asset:
Nome:
Tipo: mesh / textura / material / áudio / UI / referência
Arquivo:
Pasta:
Origem:
Autor:
Licença:
Uso comercial permitido? Sim/Não/Incerto
Atribuição obrigatória? Sim/Não/Incerto
Data de acesso/download:
Link/comprovante:
Ferramenta usada, se IA/fotogrametria:
Prompt usado, se IA:
Alterações feitas:
Status: TEMP / APROVADO / REJEITADO
Motivo da decisão:
```

---

## 22. Resumo final do guia de assets

```text
No Marco 0.1, assets devem servir ao gameplay.
Usar placeholders é correto e esperado.
Assets temporários ficam em assets_temp.
Fontes editáveis ficam em assets_source.
Assets aprovados ficam em assets_final.
Todo asset externo precisa de origem e licença registradas.
Preferir assets próprios, CC0 ou licenças permissivas com uso comercial claro.
Na dúvida, não usar em build pública ou comercial.
```
