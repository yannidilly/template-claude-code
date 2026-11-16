---
name: done
description: Etapa 6. Aprovação final de uma spec (status done).
argument-hint: <ID da spec, ex. S2.8>
disable-model-invocation: true
---

Faça a aprovação final de `$ARGUMENTS`.

1. Leia o frontmatter de `specs/$ARGUMENTS.md`. O `status` precisa ser `fixes-applied`, ou `review-done` quando nenhum ponto do review foi aceito. Em qualquer outro caso, pare e avise.
2. Rode `tools/gate-tests.sh <tests_commit>`. Se não der `GATE OK`, pare e mostre o resultado.
3. Rode `git status --short`. Se houver alterações além da spec, pare e mostre.
4. Se a spec tiver a seção "Verificação manual" ou critérios `[manual]` (bootstrap), liste-os e peça ao usuário que confirme que cada um foi conferido. Registre a confirmação (data e resultado) no fim dessa seção. Se algum falhou, pare: é preciso um novo `/fix` ou uma nova spec de bootstrap.
5. Mude o `status` para `done` e faça o commit só da spec: `spec($ARGUMENTS): concluída`.
6. Se esta era a última spec de bootstrap, diga que o bootstrap terminou e que o próximo passo é escrever o `docs/planning.md` (ver `docs/guides/planning.md`) e rodar `/card` para a primeira história.
