---
name: status
description: Lista a configuração, as specs de bootstrap, os cards e as specs das histórias, com o status e o próximo passo de cada um. Somente leitura.
argument-hint: "[ID opcional para mostrar só um]"
disable-model-invocation: true
---

Mostre em que pé está o trabalho. Somente leitura: não altere nada e não faça commit.

1. Leia o `status` do frontmatter de `docs/project-setup.md`, de cada `docs/cards/*.md` e de cada `specs/*.md` (ignore `specs/reviews/`). Se `$ARGUMENTS` vier preenchido, mostre só esse ID.
2. Rode `git status --short` e anote se a árvore está limpa.
3. Mostre:
   - **Configuração:** o status do questionário (`pending` → próximo passo `/project-init`).
   - **Bootstrap:** uma linha por spec `S0.*`: ID, título, status e próximo passo.
   - **Histórias:** uma linha por ID encontrado em cards ou specs: ID, título, status do card, status da spec e próximo passo.
4. Próximo passo por situação:

| Situação | Próximo passo |
| --- | --- |
| sem card | `/card <ID>` |
| card `draft` | terminar o `/card <ID>`, depois `/card-approve <ID>` |
| card `approved`, sem spec | `/spec <ID>` |
| spec `draft` | revisar e depois `/approve <ID>` |
| `spec-approved` ou `tests-red` | `/build <ID>` (retomar) |
| `code-green` ou `code-with-issues` | `/review <ID>` |
| `review-done` | `/fix <ID> <números>` ou `/done <ID>` |
| `fixes-applied` | `/done <ID>` |
| `done` | — |

5. Termine com uma única linha: o próximo passo mais urgente (primeiro uma execução inacabada, depois o bootstrap em ordem, depois as histórias) e um aviso se a árvore não estiver limpa.
