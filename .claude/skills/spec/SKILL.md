---
name: spec
description: Etapa 1. Gera specs/<ID>.md em draft a partir do card aprovado, com design técnico, plano de testes (itens T) e plano de implementação (itens I).
argument-hint: <ID da história, ex. S2.8>
disable-model-invocation: true
---

Gere a spec da história `$ARGUMENTS`, seguindo a "Etapa 1: spec" e o "Formato da spec" de `docs/workflow.md`.

A spec centraliza **todas** as decisões técnicas. O `test-writer` e o `implementer` só executam os itens que ela lista, sem decidir nada. O que não estiver na spec não será testado nem implementado.

## 1. Conferir o ponto de partida

1. Se `$ARGUMENTS` começar com `S0.`, pare: as specs de bootstrap são geradas pelo `/project-init`.
2. Confira se todas as specs de bootstrap (`specs/S0.*.md`) estão com `status: done`. Se não estiverem, pare, liste-as e diga que o bootstrap precisa terminar antes.
3. Confira "Trabalho bloqueado" no `CLAUDE.md`. Se a história estiver bloqueada, pare e avise.
4. Leia `docs/cards/$ARGUMENTS.md`. Se ele não existir ou o `status` não for `approved`, pare e diga que o próximo passo é `/card $ARGUMENTS`.
5. Se `specs/$ARGUMENTS.md` já existir, pare e mostre o `status` atual. Não sobrescreva.

## 2. Ler

- O card: é a fonte do negócio. Use `docs/planning.md` só para as regras fechadas que o card cita. Se faltar uma decisão de negócio, pare e avise: o card precisa ser reaberto com `/card $ARGUMENTS`.
- `docs/technical-conventions.md`, `docs/reuse.md` e o código que a história vai tocar, para não conflitar com o que já existe.
- Specs já aprovadas que criaram as tabelas, os endpoints ou as telas que esta história usa.

## 3. Decidir o que for técnico

- Se a spec precisar de uma convenção que está "a definir" em `docs/technical-conventions.md`, pergunte, registre a resposta em "Definidas" (origem: `$ARGUMENTS`) e só então siga.
- Para decisões técnicas só desta história que não saem do código nem das convenções (ex.: índice composto, ordem de paginação, comportamento de um erro), pergunte com a ferramenta de perguntas, no máximo 4 por rodada, com uma recomendação primeiro.
- Não invente regra de negócio para fechar o design.

## 4. Escrever `specs/$ARGUMENTS.md`

Use `kind: story`, `tests: red`, `status: draft` e `tests_commit:` vazio, no formato de `docs/workflow.md`.

**Regras de negócio, critérios e fora de escopo:** os do card. Numere os critérios `C1`, `C2`, … com o texto exato do card. Comportamento técnico que precisa ser verificado (ex.: `400` para corpo inválido) entra como critério marcado `[técnico]`.

**Design técnico:** a referência que os itens citam, cobrindo todo ponto do "Checklist de design técnico" do `CLAUDE.md` que se aplica à história.

**Plano de testes:** itens `T{bloco}.{n}`, agrupados em blocos (ex.: bloco 1 = `POST /items`, bloco 2 = tela da lista de itens). Cada item:

```
- **T1.1** Teste de integração: POST /items com corpo válido retorna 201 e o item criado
  - Req: C1, C2
  - Arquivo: <caminho seguindo "Testes" no CLAUDE.md>
  - Cenário: usuário U1 autenticado; nenhum item no banco
  - Resultado esperado: HTTP 201, body { "id": <uuid>, "name": "Mesa", "createdAt": <data ISO> }; uma linha em items com dono U1
```

- Tipos: unidade, integração (backend com o banco real, quando "Testes" assim definir) ou componente (tela).
- O resultado esperado é completo e verificável: código HTTP, campos do body, estado das tabelas, o que a tela mostra, chamadas aos mocks.
- Cubra cada critério `C` com pelo menos um item. Inclua também os itens de contrato que o design exige: cada linha da tabela de erros, validação de entrada, constraints e rollback, casos de borda, estados de tela, concorrência.

**Plano de implementação:** itens `I{bloco}.{n}`, na "Ordem do plano de implementação" do `CLAUDE.md`. Cada item:

```
- **I1.1** Criar a migration `20260101000000-create-items`: tabela `items` com `id` (UUID PK), `name` (texto NOT NULL), `owner_id` (FK users ON DELETE CASCADE), `created_at`, `updated_at`
  - Req: T1.1, T1.2
```

- Cada item diz o arquivo e o que fazer, com nomes, tipos, assinaturas, payloads e textos exatos, sem deixar decisão para o `implementer`.
- Cada item `T` precisa ser satisfeito por algum item `I`.

## 5. Conferir e fechar

- Todo `C` aparece em algum `T`. Todo `T` aparece em algum `I`. Nenhum item deixa decisão em aberto.
- Não escreva código nem testes. Não faça commit.
- Mostre um resumo (blocos, número de itens `T` e `I`, tabelas, endpoints e telas), as convenções registradas e as dúvidas. A aprovação é com `/approve $ARGUMENTS`.
