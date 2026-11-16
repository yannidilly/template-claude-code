---
name: approve
description: Aprova uma spec (draft → spec-approved), faz o commit dela e inicia a execução (etapas 2 e 3).
argument-hint: <ID da spec, ex. S2.8 ou S0.1>
disable-model-invocation: true
---

Aprove a spec `specs/$ARGUMENTS.md`.

1. Se a spec não existir ou o `status` não for `draft`, pare e mostre o status atual.
2. Confira a ordem do bootstrap (ver `docs/workflow.md`):
   - spec de bootstrap (`S0.n`): todas as specs de bootstrap de número menor precisam estar `done`;
   - spec de história: todas as specs de bootstrap precisam estar `done`.
   Se não estiverem, pare e liste o que falta.
3. Em uma spec de bootstrap, mostre os "Pontos a validar" e peça ao usuário que os confirme (ou que edite a spec antes). Se a spec tiver critérios `[manual]`, lembre que eles serão conferidos no `/done`.
4. Mude o `status` para `spec-approved`. Não altere mais nada na spec.
5. Rode `git status --short`. Só podem estar alterados a spec e `docs/technical-conventions.md` (quando o `/spec` registrou convenções). Se houver outra coisa, mostre e pergunte antes de seguir: os agentes exigem a árvore de trabalho limpa.
6. Faça o commit da spec e, se alterado, das convenções: `spec($ARGUMENTS): aprova spec`.
7. Em seguida, execute a spec: leia e siga `.claude/skills/build/SKILL.md` com o ID `$ARGUMENTS`.
