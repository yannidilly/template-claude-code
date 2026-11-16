# Fluxo de desenvolvimento

O processo que todo trabalho percorre. Ele é o mesmo em qualquer projeto: o que é específico da stack fica em seções com nome fixo do `CLAUDE.md`, que este documento, os agentes e as skills citam.

## Princípios

- **Em caso de dúvida ou contradição, pare e pergunte. Não invente regra.** Vale para a sessão principal nas etapas S0, 0 e 1.
- **A spec aprovada é o contrato final de execução.** Nas etapas 2, 3 e 5 os agentes não param por dúvida ou problema da spec: seguem a interpretação mais fiel ao texto, terminam o trabalho e registram pendências, que a sessão principal relata no fim, numeradas (`P1`, `P2`, …). Só param por falha de execução (ambiente quebrado, árvore suja). A spec não é revisada durante a execução.
- **O que não está nos itens da spec não é testado nem implementado.** Todo critério `C` é coberto por algum item de teste `T`, e todo `T` por algum item de implementação `I`.
- **Os testes são protegidos.** Depois de congelados, só o `test-writer` mexe neles (ver "Proteção dos testes").
- **Subagentes não chamam outros subagentes.** A sessão principal orquestra e confere o resultado de cada etapa (status, gate e árvore limpa).
- **O campo `status` no frontmatter** de cards e specs permite retomar o trabalho em outra sessão. Ele é atualizado ao fim de cada etapa. O `/status` lista tudo.

## Idioma

Tudo em português, exceto identificadores, nomes de arquivo e de pasta, comandos, chaves e valores de frontmatter (`status: draft`, `tests_commit`) e os tipos de commit (`feat`, `test`…), que ficam em inglês.

## Artefatos

| Artefato | Caminho | Fonte de |
| --- | --- | --- |
| Questionário de configuração | `docs/project-setup.md` | respostas do projeto, aplicadas pelo `/project-init` |
| Planejamento | `docs/planning.md` | rascunho das histórias e das **regras de negócio fechadas**, que valem para todas (ver `docs/guides/planning.md`) |
| Card | `docs/cards/{ID}.md` | regras de negócio de uma história; depois de aprovado, substitui o rascunho do planejamento para ela |
| Spec | `specs/{ID}.md` | todas as decisões técnicas de uma história ou etapa de bootstrap: design, plano de testes (itens `T`) e plano de implementação (itens `I`) |
| Relatório de review | `specs/reviews/{ID}.md` | sugestões numeradas do review, usadas pelo `/fix` |
| Convenções técnicas | `docs/technical-conventions.md` | decisões de dados e de contrato que valem para todas as specs, decididas uma vez |
| Catálogo de reuso | `docs/reuse.md` | funções, componentes e hooks reutilizáveis |
| Caminhos de teste | `tools/test-paths.txt` | lista única dos globs de teste protegidos |

### IDs

- Épico `E{n}`, funcionalidade `F{épico}.{n}`, história `S{épico}.{n}` (ex.: `S2.8`).
- O épico 0 é reservado às specs de **bootstrap** (`S0.1` configuração geral, `S0.2` lint, …), geradas pelo `/project-init` e sem card.

## Etapas

| # | Etapa | Quem | Skill | Resultado |
| --- | --- | --- | --- | --- |
| S0 | Configuração do projeto e specs de bootstrap | sessão principal, com perguntas | `/project-init` | `CLAUDE.md` configurado, `specs/S0.*.md` em `draft` |
| 0 | Card | sessão principal, com perguntas | `/card S2.8`, `/card-approve S2.8` | `docs/cards/S2.8.md` em `draft`; com `/card-approve` vira `approved` (commitado) |
| 1 | Spec | sessão principal | `/spec S2.8`, `/approve S2.8` | `specs/S2.8.md` em `draft`; com `/approve` vira `spec-approved` (commitada) e as etapas 2 e 3 começam sozinhas |
| 2 | Testes (red) | agente `test-writer` | automático (`/build S2.8` retoma) | testes falhando pelo motivo certo, status `tests-red` |
| 3 | Código, refatoração e `docs/reuse.md` | agente `implementer` | automático (`/build S2.8` retoma) | status `code-green`, ou `code-with-issues`; pendências relatadas no chat |
| 4 | Code review | agente `reviewer`, somente leitura | `/review S2.8` | relatório em `specs/reviews/S2.8.md`, status `review-done` |
| 5 | Segunda passada | agente `implementer` | `/fix S2.8 1,3` | só os pontos do review que o usuário aceitar, status `fixes-applied` |
| 6 | Aprovação final | o usuário | `/done S2.8` | status `done` |

As specs de bootstrap (`S0.*`) pulam a etapa 0 e entram na etapa 1 (`/approve S0.1`). Elas rodam em ordem: uma spec só é aprovada quando todas as specs de bootstrap de número menor estão `done`, e as specs de história só depois de todas as de bootstrap estarem `done`.

### Status

- **Card:** `draft` → `approved`.
- **Spec:** `draft` → `spec-approved` → `tests-red` → `code-green` | `code-with-issues` → `review-done` → `fixes-applied` → `done`. (`fixes-applied` é pulado quando nenhum ponto do review é aceito.)

### Etapa S0: configuração do projeto

- O usuário preenche `docs/project-setup.md` e roda `/project-init`.
- O `/project-init` lista as lacunas (respostas ausentes, vagas ou contraditórias), pergunta em rodadas até não sobrar nenhuma, grava as respostas no questionário, preenche as seções do projeto no `CLAUDE.md`, `tools/test-paths.txt` e `docs/technical-conventions.md`, e gera as specs de bootstrap em `draft`, seguindo `docs/guides/bootstrap.md` e `docs/guides/lint.md`.
- Nada é executado automaticamente: cada spec de bootstrap é revisada e aprovada pelo usuário com `/approve` e depois percorre as etapas 2 a 6 como uma história.
- O `/project-init` pode rodar de novo enquanto todas as specs de bootstrap estiverem em `draft`, para revisar respostas e gerá-las de novo.

### Etapa 0: card

- Lê a história, as regras de negócio fechadas, as dependências e as premissas em `docs/planning.md`, e os cards já aprovados sobre o mesmo assunto.
- Lista os pontos em aberto (premissas não validadas, parâmetros sem valor, ambiguidades, contradições, casos de borda) e faz as perguntas de negócio, em rodadas, até não sobrar nenhum. Decisão técnica fica para a spec.
- Só gera o card com todas as dúvidas respondidas. Ponto adiado significa card não gerado.
- Regra decidida que vale para outras histórias (ou premissa validada) vai para "Regras de negócio fechadas" do planejamento, com confirmação, e a premissa sai de "Premissas assumidas nos critérios".
- O usuário aprova com `/card-approve`. Sem card `approved`, não há spec.

### Etapa 1: spec

- Lê o card aprovado, `docs/technical-conventions.md`, `docs/reuse.md` e o código que a história toca, e gera `specs/{ID}.md` com os critérios copiados do card (`C1`, `C2`, …), o design técnico, o plano de testes e o plano de implementação.
- O design é concreto e segue o "Checklist de design técnico" do `CLAUDE.md` (ex.: migrations com colunas, tipos e constraints; endpoints com request e response em exemplo JSON e tabela de erros; assinaturas de services e hooks; telas com estados e textos).
- **Plano de testes:** itens `T{bloco}.{n}`, cada um com tipo, `Req` (critérios), arquivo, cenário e resultado esperado completo. Inclui os testes de contrato (erros, validação, constraints, borda, estados de tela, concorrência).
- **Plano de implementação:** itens `I{bloco}.{n}`, na "Ordem do plano de implementação" do `CLAUDE.md`, cada um com o arquivo e o que fazer, com nomes, tipos e payloads exatos, e `Req` (itens `T`).
- Convenção "a definir" que a spec precise é perguntada, registrada em `docs/technical-conventions.md` e não é perguntada de novo. Decisão técnica só da história também é perguntada.
- Se faltar decisão de negócio, o card é reaberto. Não escreve código nem testes.

### Etapa 2: testes (red)

- Lê **somente** a spec aprovada, `docs/technical-conventions.md` e as convenções de teste. Não lê código de implementação nem o contexto das etapas anteriores.
- Escreve um teste `T1.1 — ...` por item `T`, exatamente como definido. Não cria testes fora do plano. Item ambíguo ou impossível, critério sem item e caso relevante não coberto viram pendências, sem parar.
- Roda os testes e confirma que cada um falha por ausência de implementação ou por assertion. Módulo de implementação ausente conta como red válido quando o caminho do import é o definido na spec. Falha por sintaxe, configuração, dependência ausente ou caminho de import diferente da spec não vale.
- Faz o commit `test({ID}): red` e grava o SHA em `tests_commit` na spec.

**Testes inline (só bootstrap).** Quando uma spec de bootstrap tem `tests: inline` (normalmente a `S0.1`, porque é ela que cria o ferramental de testes), a etapa 2 é pulada: o `implementer` escreve os itens `T` junto com o código, faz o commit `test({ID}): testes` quando eles estão finais e grava esse SHA em `tests_commit`. Daí em diante os testes ficam protegidos como os demais.

### Etapa 3: código, refatoração e reuse.md

- **Antes de escrever:** lê `docs/reuse.md` e reutiliza o que já existe.
- **Código:** executa os itens `I` do plano de implementação, na ordem e exatamente como descritos, mesmo no que os testes não cobrem, e nada além deles. Testes verdes são condição necessária, não suficiente. Não altera arquivos de teste. Se um item estiver errado, incompleto, ambíguo ou conflitar com um teste, segue a interpretação mais fiel ao texto, termina os demais e registra a pendência.
- **Refatoração:** com os testes verdes, extrai o que for reutilizável (componentes, funções, hooks) e remove duplicação.
- **Documentação:** registra em `docs/reuse.md` o que for novo e reutilizável.
- Termina com o gate de proteção dos testes aprovado. Com os gates verdes e sem pendências, o status é `code-green`; senão, `code-with-issues`.

### Etapa 4: code review

Somente leitura. Não edita nada. Devolve uma lista priorizada: arquivo, problema, sugestão e severidade. Confere a aderência à spec (itens `T` e `I` e design técnico), às convenções técnicas, às camadas, às fachadas, aos tokens, ao `reuse.md`, à concorrência e ao "Checklist de review do projeto" do `CLAUDE.md`.

### Etapa 5: segunda passada

O `implementer` roda de novo, só com os pontos do review que o usuário aceitar, com os testes protegidos e os mesmos gates.

## Proteção dos testes

"Não alterar testes" não depende só de instrução:

1. **Gate por diff.** Ao fim das etapas 3 e 5, `tools/gate-tests.sh <tests_commit>` deve dar `GATE OK`. Ele reprova qualquer arquivo de teste alterado, apagado ou novo em relação ao commit dos testes, inclusive por shell (`sed -i`, redirecionamento). Os globs protegidos são lidos de `tools/test-paths.txt`.
2. **Hook.** O agente `implementer` tem um hook `PreToolUse` (`tools/hooks/protect-tests.sh`) que bloqueia `Edit`/`Write` em arquivos de teste já commitados. Arquivos novos e mudanças por shell são pegos pelo gate. Hooks de agentes do projeto só rodam depois que o diálogo de confiança do workspace é aceito (não rodam em sessões `-p`), mais um motivo para o gate continuar obrigatório.
3. **Se o `implementer` achar que um teste está errado,** ele não o edita: continua a implementação e registra a pendência com a justificativa.

`tools/test-paths.txt` é a fonte única dos globs de teste: o gate, o hook e a configuração de lint o leem, e o `CLAUDE.md` aponta para ele.

## Gates

Ao fim de cada etapa que escreve código (3 e 5), o `implementer` roda os comandos da seção "Gates" do `CLAUDE.md` nos workspaces afetados e corrige o código até ficarem verdes. O que não ficar verde sem sair da spec ou sem mexer em teste vira pendência. O gate de proteção dos testes nunca vira pendência: precisa dar `GATE OK`. Durante o bootstrap, um gate cujo comando ainda não existe é pulado e relatado.

## Commits por etapa

`card({ID}): ...`, `spec({ID}): ...`, `test({ID}): red`, `feat({ID}): ...`, `refactor({ID}): ...`, `fix({ID}): ...`, `docs({ID}): ...`, e `chore(init): ...` para o `/project-init`. A descrição do commit é em português. Nunca faça push.

## Formato do card (`docs/cards/S2.8.md`)

```
---
id: S2.8
epic: E2
status: draft   # draft | approved
---
# S2.8 — título da história

## Objetivo
## Regras de negócio aplicáveis
## Critérios de aceite (Dado / Quando / Então)
## Fora de escopo
## Dependências
## Decisões
| # | Pergunta | Resposta |
```

## Formato da spec (`specs/S2.8.md`)

```
---
id: S2.8
epic: E2
kind: story        # story | bootstrap
tests: red         # red | inline (inline só em specs de bootstrap)
status: draft      # draft | spec-approved | tests-red | code-green | code-with-issues | review-done | fixes-applied | done
tests_commit:      # SHA do commit que congelou os testes
---
# S2.8 — título da história

## Regras de negócio aplicáveis                  (do card)
## Critérios de aceite (Dado / Quando / Então)   (do card, texto exato, numerados C1, C2…; técnicos marcados [técnico])
## Fora de escopo
## Design técnico                                (seções do "Checklist de design técnico" do CLAUDE.md)
## Plano de testes                               (itens T{bloco}.{n})
- **T1.1** Teste de integração: POST /items com corpo válido retorna 201 e o item criado
  - Req: C1, C2
  - Arquivo: <caminho definido pelas convenções de teste do projeto>
  - Cenário: dados no banco e mocks
  - Resultado esperado: HTTP 201, body com id, name e createdAt; uma linha em items
## Plano de implementação                        (itens I{bloco}.{n}, na "Ordem do plano de implementação" do CLAUDE.md)
- **I1.1** Criar a migration create-items: tabela items com as colunas id (PK), name (NOT NULL), ...
  - Req: T1.1
```

### Formato da spec de bootstrap (`specs/S0.1.md`)

Mesmo formato, com `kind: bootstrap`, sem card e sem "Regras de negócio aplicáveis". No lugar delas:

```
## Objetivo
## Entradas necessárias antes de executar   (ferramentas instaladas, arquivos que precisam existir)
## Critérios de aceite                      (agrupados em R1, R2…; cada critério numerado C1, C2… dentro dos grupos)
## Verificação manual                       (comandos para rodar numa máquina limpa; o resultado é registrado na aprovação)
## Fora de escopo
## Pontos a validar                         (premissas que o usuário precisa confirmar antes do /approve)
```

Critérios que só uma pessoa consegue verificar (uma tela abre, os containers recarregam) são marcados `[manual]` e vão para "Verificação manual", sem item `T`.

## docs/reuse.md

Catálogo curto e direto das funções, componentes e hooks reutilizáveis. Cada entrada tem nome e caminho do arquivo, quando usar, quando não usar e um exemplo curto. Consulte antes de criar algo novo e atualize ao criar algo reutilizável.
