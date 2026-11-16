---
name: card-approve
description: Aprova o card (draft → approved) e faz o commit dele e das mudanças no planejamento.
argument-hint: <ID da história, ex. S2.1>
disable-model-invocation: true
---

Aprove o card `docs/cards/$ARGUMENTS.md`.

1. Se o card não existir ou o `status` não for `draft`, pare e mostre a situação.
2. Confira se a seção "Decisões" não tem pergunta sem resposta. Se tiver, pare e liste.
3. Mude o `status` para `approved`. Não altere mais nada no card.
4. Rode `git status --short`. Só podem estar alterados o card e `docs/planning.md` (quando o `/card` atualizou regras). Se houver outra coisa, mostre e pergunte antes de seguir.
5. Faça o commit do card e, se alterado, do planejamento: `card($ARGUMENTS): aprova card`.
6. Diga que o próximo passo é `/spec $ARGUMENTS`.
