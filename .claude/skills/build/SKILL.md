---
name: build
description: Etapas 2 e 3. Executa uma spec aprovada (test-writer para os testes red, depois implementer), sem parar por dúvidas da spec, e relata as pendências no fim. Chamado pelo /approve; use direto só para retomar.
argument-hint: <ID da spec, ex. S2.8>
disable-model-invocation: true
---

Execute a spec aprovada `$ARGUMENTS`. A spec aprovada é o contrato final: os agentes não param por causa dela e a spec não é revisada durante a execução. Dúvidas e problemas viram pendências, relatadas no fim.

## 1. Ponto de partida

Leia o frontmatter de `specs/$ARGUMENTS.md` e retome de onde parou:

| `status` | `tests` | O que fazer |
| --- | --- | --- |
| `spec-approved` | `red` | passos 2 e 3 |
| `spec-approved` | `inline` | só o passo 3 (passada de bootstrap) |
| `tests-red` | `red` | só o passo 3 |
| `code-green` ou `code-with-issues` | qualquer | nada a executar; diga que o próximo passo é `/review $ARGUMENTS` |
| outro | | pare e mostre o status |

Rode `git status --short`. Se a árvore não estiver limpa, pare e mostre o que está pendente.

## 2. Testes (red)

1. Chame o agente `test-writer` com o prompt: `Spec $ARGUMENTS. A spec está em specs/$ARGUMENTS.md.` Não passe nenhum outro contexto.
2. Confira: o `status` é `tests-red`, `tests_commit` tem um SHA que existe (`git cat-file -e <sha>^{commit}`) e a árvore está limpa.
3. Se a conferência falhar (o agente não conseguiu commitar, ambiente quebrado), pare e mostre o que aconteceu. Isso é falha de execução, não dúvida da spec.
4. Guarde o relatório e as pendências do agente e siga para o passo 3 sem esperar o usuário.

## 3. Implementação

1. Chame o agente `implementer` com o prompt:

   ```
   Spec $ARGUMENTS, primeira passada (passada de bootstrap quando tests: inline). A spec está em specs/$ARGUMENTS.md.
   Pendências registradas pelo test-writer (interpretações adotadas nos testes):
   <lista, "nenhuma" ou "não se aplica (tests: inline)">
   ```

2. Confira: `tests_commit` tem um SHA que existe, `tools/gate-tests.sh <tests_commit>` dá `GATE OK`, o `status` é `code-green` ou `code-with-issues` e a árvore está limpa. Se o gate reprovar, isso é uma falha: mostre-a com destaque.

## 4. Relatório

Mostre ao usuário, nesta ordem:

1. **Resultado:** status final e resultado de cada gate (cada comando de "Gates" do `CLAUDE.md` e o gate dos testes).
2. **Testes:** a tabela dos itens `T` (critérios, arquivo, motivo do red) e os "já satisfeitos"; com `tests: inline`, os testes escritos e os critérios `[manual]`.
3. **Implementação:** os itens `I` feitos e os arquivos por camada; entradas novas do `docs/reuse.md`.
4. **Pendências:** todas as dos dois agentes, numeradas `P1`, `P2`, …, cada uma com a origem (item `T`, item `I`, teste ou gate), o problema, o que foi feito e a sugestão. Se não houver, diga "nenhuma".

Diga que o próximo passo é `/review $ARGUMENTS`.
