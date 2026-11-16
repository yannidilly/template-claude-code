---
name: review
description: Etapa 4. Chama o agente reviewer (somente leitura), salva o relatório e marca review-done.
argument-hint: <ID da spec, ex. S2.8>
disable-model-invocation: true
---

Rode a etapa 4 (code review) de `$ARGUMENTS`.

1. Leia o frontmatter de `specs/$ARGUMENTS.md`. Se o `status` não for `code-green` nem `code-with-issues`, pare e avise.
2. Rode `git status --short`. Se a árvore não estiver limpa, pare e mostre o que está pendente.
3. Chame o agente `reviewer` com o prompt: `Spec $ARGUMENTS. A spec está em specs/$ARGUMENTS.md.` Quando o status for `code-with-issues`, acrescente as pendências relatadas pelo `/build` (desta conversa, ou "ver o relatório do build" se não estiverem disponíveis).
4. Salve o relatório do agente, sem editar, em `specs/reviews/$ARGUMENTS.md`. Ele é a referência dos números usados no `/fix`, inclusive em outra sessão.
5. Mude o `status` da spec para `review-done`. Faça o commit da spec e do relatório: `docs($ARGUMENTS): code review`.
6. Mostre ao usuário o relatório **completo**, sem resumir nem filtrar.
7. Diga que o próximo passo é `/fix $ARGUMENTS <números aceitos>` (ex.: `/fix $ARGUMENTS 1,3`) ou, se nenhum ponto for aceito, `/done $ARGUMENTS`. Os itens de "Para a etapa 2" e "Problemas da spec" não entram no `/fix` (o `implementer` não mexe em testes nem na spec): destaque-os para o usuário decidir.
