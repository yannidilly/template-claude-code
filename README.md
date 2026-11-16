# Template de fluxo de desenvolvimento com Claude Code

Um ponto de partida para construir projetos com o Claude Code de forma previsível: cada funcionalidade vira uma **história**, que passa por **card → spec → testes red → implementação → code review → ajustes → aprovação**. Cada etapa tem um responsável, um resultado esperado e um ponto de controle (status, testes protegidos e gates).

O template traz **só o fluxo**. Stack, arquitetura, lint e a estrutura inicial do código são definidos para cada projeto, a partir de um questionário, pelo comando `/project-init`.

> **Funciona com qualquer projeto.** Nada no fluxo depende de linguagem, framework ou banco. Os agentes e os comandos leem as informações técnicas (comandos de teste, camadas, caminhos de teste, checklists) de seções com nome fixo do `CLAUDE.md`, preenchidas pelo `/project-init`. Para trocar de stack, basta responder o questionário de outro jeito: API em Node, backend em Python, app mobile, CLI ou monorepo com vários apps.

---

## Sumário

1. [Visão geral do fluxo](#1-visão-geral-do-fluxo)
2. [Passo a passo](#2-passo-a-passo)
3. [O que cada etapa produz](#3-o-que-cada-etapa-produz)
4. [Como os testes são protegidos](#4-como-os-testes-são-protegidos)
5. [Comandos](#5-comandos)
6. [Adaptando a qualquer projeto](#6-adaptando-a-qualquer-projeto)
7. [Estrutura do template](#7-estrutura-do-template)
8. [Perguntas frequentes](#8-perguntas-frequentes)

---

## 1. Visão geral do fluxo

```
 PROJETO (uma vez)                         CADA HISTÓRIA
 ─────────────────                         ─────────────
 docs/project-setup.md                     docs/planning.md
        │  você preenche                          │  você escreve (guia em docs/guides/planning.md)
        ▼                                         ▼
 /project-init  ── perguntas ──┐           /card S1.1  ── perguntas de negócio ──┐
        │                      │                  │                              │
        ▼                      │                  ▼                              │
 CLAUDE.md configurado ◄───────┘           docs/cards/S1.1.md (draft) ◄──────────┘
 specs/S0.1.md, S0.2.md (draft)                   │  /card-approve
        │                                         ▼
        │  cada spec de bootstrap          /spec S1.1  ── perguntas técnicas
        │  segue o fluxo da direita ──►           │
        ▼                                         ▼
 base do código criada                     specs/S1.1.md (draft)
                                                  │  /approve  (você revisa e aprova)
                                                  ▼
                                           agente test-writer → testes red (commit)
                                                  ▼
                                           agente implementer → código verde
                                                  │  /review
                                                  ▼
                                           agente reviewer → relatório numerado
                                                  │  /fix S1.1 1,3   (só os pontos que você aceitar)
                                                  ▼
                                           agente implementer → ajustes
                                                  │  /done
                                                  ▼
                                           história aprovada
```

**Princípios:**

- **Dúvida não vira suposição.** Nas etapas de card, spec e configuração, o Claude pergunta até não sobrar ponto em aberto. Nada de regra inventada.
- **A spec aprovada é o contrato.** Os agentes só executam os itens da spec. O que não está nela não é testado nem implementado. Nas etapas automáticas, uma dúvida não interrompe o trabalho: vira uma **pendência** (`P1`, `P2`, …) relatada no fim.
- **Testes antes do código, e protegidos.** Quem escreve os testes não lê o código. Quem escreve o código não pode alterar os testes.
- **Você aprova cada passo importante:** o card, a spec, os pontos do review a aplicar e a entrega final.
- **Tudo é retomável.** O status fica no frontmatter de cada card e spec. O `/status` mostra onde cada item parou e qual é o próximo passo.

---

## 2. Passo a passo

### Passo 1 — Criar o projeto a partir do template

Copie ou clone este repositório na pasta do novo projeto. Abra a pasta no Claude Code e aceite o diálogo de confiança do workspace: os hooks dos agentes só rodam com a pasta confiável.

### Passo 2 — Responder o questionário

Abra `docs/project-setup.md` e responda as perguntas:

- **Produto:** nome, descrição, idioma do conteúdo, se já existe planejamento.
- **Stack e estrutura:** apps, linguagem, monorepo, banco, infraestrutura, variáveis de ambiente.
- **Arquitetura:** camadas de cada app, fachadas e integrações, tokens de estilo, concorrência, busca.
- **Testes e gates:** runner, estratégia, caminhos de teste, comandos de typecheck, teste e lint.
- **Lint:** grupos de regras e limites.
- **Convenções técnicas:** chaves, nomes, erros, autenticação, paginação, datas, dinheiro.

Respostas curtas bastam. Escreva `default` para aceitar o padrão indicado na pergunta, ou `?` se ainda não souber: o `/project-init` sugere uma opção.

### Passo 3 — Rodar `/project-init`

O comando:

1. lista o que falta, está vago ou se contradiz, e pergunta em rodadas (no máximo 4 perguntas por vez, com uma recomendação);
2. grava as respostas finais no próprio questionário;
3. mostra o plano (o que entra em cada arquivo) e **só escreve depois da sua confirmação**;
4. preenche o `CLAUDE.md`, `tools/test-paths.txt` e `docs/technical-conventions.md`;
5. gera as **specs de bootstrap** como rascunho: `specs/S0.1.md` (configuração geral) e `specs/S0.2.md` (lint), seguindo os padrões de `docs/guides/bootstrap.md` e `docs/guides/lint.md`;
6. faz o commit `chore(init): ...`, com a sua confirmação.

Nada é instalado nem executado nesse passo. Se quiser mudar algo, edite o rascunho ou rode `/project-init <o que revisar>` enquanto as specs de bootstrap forem rascunho.

### Passo 4 — Executar o bootstrap

Revise e execute cada spec de bootstrap, em ordem:

```
/approve S0.1    → aprova e executa (cria a estrutura, as dependências, a infra e o primeiro fluxo de ponta a ponta)
/review S0.1     → code review
/fix S0.1 1,2    → opcional: aplica os pontos do review que você aceitar
/done S0.1       → você confirma a verificação manual e aprova
```

Depois, o mesmo para `S0.2` (lint). No fim, o projeto tem a base do código rodando, testes em cada camada, lint impondo a arquitetura e a seção "Como rodar o projeto" do `CLAUDE.md` escrita.

### Passo 5 — Escrever o planejamento

Preencha `docs/planning.md` com épicos (`E1`), funcionalidades (`F1.1`) e histórias (`S1.1`), com critérios Dado/Quando/Então, regras de negócio fechadas e premissas. O guia `docs/guides/planning.md` explica como montar o planejamento numa conversa com o Claude.

### Passo 6 — Desenvolver cada história

```
/card S1.1          → perguntas de negócio até fechar tudo; gera o card
/card-approve S1.1  → você aprova o card (commit)
/spec S1.1          → design técnico, plano de testes e plano de implementação
/approve S1.1       → você aprova a spec; os agentes escrevem os testes red e o código
/review S1.1        → code review somente leitura, com sugestões numeradas
/fix S1.1 1,3       → aplica só os pontos que você escolheu
/done S1.1          → aprovação final
```

Use `/status` a qualquer momento para ver o andamento e o próximo passo.

---

## 3. O que cada etapa produz

| Etapa | Arquivo gerado | Commit | Status |
| --- | --- | --- | --- |
| Configuração | `CLAUDE.md`, `tools/test-paths.txt`, `specs/S0.*.md` | `chore(init): configura projeto e specs de bootstrap` | questionário `configured` |
| Card | `docs/cards/S1.1.md` | `card(S1.1): aprova card` | `draft` → `approved` |
| Spec | `specs/S1.1.md` | `spec(S1.1): aprova spec` | `draft` → `spec-approved` |
| Testes red | arquivos de teste | `test(S1.1): red` e `spec(S1.1): registra tests_commit` | `tests-red` |
| Código | código, `docs/reuse.md` | `feat(S1.1): ...`, `refactor(S1.1): ...`, `docs(S1.1): ...` | `code-green` ou `code-with-issues` |
| Review | `specs/reviews/S1.1.md` | `docs(S1.1): code review` | `review-done` |
| Ajustes | código | `refactor(S1.1): aplica pontos do review` | `fixes-applied` |
| Aprovação | — | `spec(S1.1): concluída` | `done` |

O histórico do git fica contando a história de cada entrega, etapa por etapa:

```
spec(S1.1): concluída
refactor(S1.1): aplica pontos do review
docs(S1.1): code review
docs(S1.1): registra itens reutilizáveis
feat(S1.1): cria endpoint de itens e tela da lista
spec(S1.1): registra tests_commit
test(S1.1): red
spec(S1.1): aprova spec
card(S1.1): aprova card
```

### Exemplo de card (`docs/cards/S1.1.md`)

```markdown
---
id: S1.1
epic: E1
status: approved
---
# S1.1 — Cadastrar um item

## Objetivo
Permitir que o usuário registre itens na própria lista.
## Regras de negócio aplicáveis
## Critérios de aceite (Dado / Quando / Então)
- Dado um usuário autenticado, quando envio um item com nome, então o item aparece no topo da lista.
- Dado um nome vazio, quando envio, então vejo "Informe o nome" e nada é salvo.
## Fora de escopo
## Dependências
## Decisões
| # | Pergunta | Resposta |
| 1 | Pode haver dois itens com o mesmo nome? | Sim |
```

### Exemplo de item da spec (`specs/S1.1.md`)

Cada critério `C` é coberto por um teste `T`, e cada `T` por um item de implementação `I`:

```markdown
- **T1.1** Teste de integração: POST /items com corpo válido retorna 201 e o item criado
  - Req: C1
  - Arquivo: apps/api/src/__tests__/createItem.test.ts
  - Cenário: usuário U1 autenticado; nenhum item no banco
  - Resultado esperado: HTTP 201, body { "id", "name": "Mesa", "createdAt" }; uma linha em items

- **I1.1** Criar a migration create-items: tabela items com id (UUID PK), name (NOT NULL), owner_id (FK users)
  - Req: T1.1
```

### Exemplo de relatório da execução

No fim do `/approve`, você recebe o resultado dos gates, a tabela de testes, os itens implementados e as pendências:

```
Resultado: code-with-issues — typecheck ✓  testes ✓  lint ✓  gate dos testes: GATE OK
Pendências:
P1 (I2.3) A spec não define o texto do estado vazio. Usei "Nenhum item ainda". Sugestão: confirmar o texto.
```

### Exemplo de relatório de review (`specs/reviews/S1.1.md`)

```
| # | Severidade  | Arquivo:linha            | Problema                        | Sugestão                       |
| 1 | bloqueante  | services/items.ts:42     | grava em 2 tabelas sem transação | envolver em transação          |
| 2 | menor       | components/ItemList.tsx:8 | nome pouco claro                | renomear para visibleItems     |
```

Você escolhe o que aplicar: `/fix S1.1 1`.

---

## 4. Como os testes são protegidos

Garantir que o código não "ajeita" os testes para passar não depende só de instrução:

1. **Separação de papéis.** O `test-writer` escreve os testes lendo só a spec, sem olhar o código. O `implementer` escreve o código sem poder alterar os testes.
2. **Hook.** O `implementer` tem um hook (`tools/hooks/protect-tests.sh`) que bloqueia a edição de testes já commitados.
3. **Gate por diff.** O `tools/gate-tests.sh <tests_commit>` reprova qualquer teste alterado, apagado ou novo desde o commit dos testes, inclusive mudanças feitas pelo shell. Ele roda no fim da implementação, do `/fix` e do `/done`.
4. **Fonte única.** Os caminhos de teste ficam só em `tools/test-paths.txt`, lido pelo gate, pelo hook e pelo lint.

Se o `implementer` achar que um teste está errado, ele não mexe no teste: registra uma pendência com a justificativa, e você decide.

---

## 5. Comandos

| Comando | Etapa | O que faz |
| --- | --- | --- |
| `/project-init` | S0 | Configura o projeto a partir do questionário e gera as specs de bootstrap |
| `/card <ID>` | 0 | Levanta as dúvidas de negócio, pergunta e gera o card |
| `/card-approve <ID>` | 0 | Aprova o card e faz o commit |
| `/spec <ID>` | 1 | Gera a spec técnica a partir do card aprovado |
| `/approve <ID>` | 1 | Aprova a spec e dispara testes e código |
| `/build <ID>` | 2 e 3 | Retoma a execução, se ela foi interrompida |
| `/review <ID>` | 4 | Code review somente leitura |
| `/fix <ID> <números>` | 5 | Aplica os pontos do review que você aceitar |
| `/done <ID>` | 6 | Aprovação final |
| `/status [ID]` | — | Mostra o andamento e o próximo passo |

| Agente | Etapa | Pode |
| --- | --- | --- |
| `test-writer` | 2 | Escrever testes. Não lê o código de implementação |
| `implementer` | 3 e 5 | Escrever código. Não altera testes (hook e gate) |
| `reviewer` | 4 | Só ler e rodar verificações. Não edita nada |

---

## 6. Adaptando a qualquer projeto

O fluxo é o mesmo para qualquer stack, porque tudo o que é específico do projeto fica em pontos de configuração explícitos:

| O que muda por projeto | Onde fica | Quem preenche |
| --- | --- | --- |
| Stack, camadas, fachadas, tokens | Seções do `CLAUDE.md` | `/project-init` |
| Comandos de typecheck, teste e lint | `CLAUDE.md`, seção "Gates" | `/project-init` |
| Como subir o ambiente de testes | `CLAUDE.md`, seção "Ambiente de testes" | `/project-init` |
| Ordem do plano de implementação | `CLAUDE.md`, seção "Ordem do plano de implementação" | `/project-init` |
| O que a spec precisa detalhar | `CLAUDE.md`, seção "Checklist de design técnico" | `/project-init` |
| Checagens extras do review | `CLAUDE.md`, seção "Checklist de review do projeto" | `/project-init` |
| Caminhos de teste | `tools/test-paths.txt` | `/project-init` |
| Convenções de dados e contrato | `docs/technical-conventions.md` | `/project-init` e depois cada `/spec` |
| Estrutura inicial do código e lint | `specs/S0.*.md` | `/project-init`, executadas pelo fluxo |

Exemplos:

- **API Node + painel React + app Expo:** camadas `routes → controllers → services → models` e `components → domain → data`, Jest, ESLint com regras de fronteira, tokens de estilo.
- **Backend Python:** `pytest`, `ruff` e `mypy` nos gates, caminhos `tests/**` e `**/test_*.py`, camadas `api → services → repositories`.
- **Projeto sem interface:** as seções de tokens e telas são removidas pelo `/project-init`.

Os guias `docs/guides/bootstrap.md` e `docs/guides/lint.md` guardam decisões já tomadas, como padrões, junto com as lições aprendidas de projetos anteriores. Eles são o ponto de partida das specs de bootstrap e não precisam ser discutidos de novo a cada projeto. Para mudar um padrão, responda diferente no questionário. Para mudar o padrão de todos os projetos futuros, edite o guia no template.

---

## 7. Estrutura do template

```
CLAUDE.md                      guia do projeto; seções {{...}} preenchidas pelo /project-init
README.md                      esta documentação
docs/
  workflow.md                  o fluxo completo: etapas, status, formatos de card e spec, proteção dos testes
  project-setup.md             questionário lido pelo /project-init
  planning.md                  esqueleto do planejamento (épicos, histórias, regras fechadas)
  technical-conventions.md     convenções técnicas: definidas e a definir
  reuse.md                     catálogo de funções, componentes e hooks reutilizáveis
  guides/
    planning.md                como escrever o planejamento
    bootstrap.md               padrões da spec de configuração geral (S0.1)
    lint.md                    padrões da spec de lint (S0.2)
  cards/                       um card por história
specs/                         uma spec por história ou etapa de bootstrap
  reviews/                     relatórios de code review
tools/
  test-paths.txt               caminhos de teste (fonte única)
  test-paths.sh                leitor compartilhado dos caminhos
  gate-tests.sh                gate de proteção dos testes
  hooks/protect-tests.sh       hook do implementer
.claude/
  agents/                      test-writer, implementer, reviewer
  skills/                      project-init, card, card-approve, spec, approve, build, review, fix, done, status
```

---

## 8. Perguntas frequentes

**Qual é o idioma do projeto?**
Tudo em português: documentação, cards, specs, descrições de skills e agentes, testes, mensagens e commits. Ficam em inglês só os identificadores, os nomes de arquivo e de pasta, os comandos e os valores lidos por máquina (chaves e valores de status no frontmatter, como `status: draft`, e os tipos de commit, como `feat`). O idioma dos textos da interface do produto é escolhido no questionário (padrão: português).

**O que acontece se a spec estiver errada durante a execução?**
Os agentes não param: seguem a interpretação mais fiel ao texto e registram uma pendência. Você vê todas as pendências no relatório e decide se corrige no `/fix`, numa nova história ou reabrindo a spec.

**Posso pular etapas?**
Os comandos conferem o status antes de agir. Por exemplo, não há spec sem card aprovado, nem história antes do fim do bootstrap. Isso mantém o rastro de decisões completo.

**Tem CI?**
Não por padrão: lint e testes rodam localmente e são o gate de cada etapa. Se o projeto precisar de CI, responda no questionário (Q4.5), e o `/project-init` cria uma spec de bootstrap para isso.

**Como retomo o trabalho em outra sessão?**
Rode `/status`. Se uma execução foi interrompida, `/build <ID>` retoma de onde parou.
