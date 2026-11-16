---
name: fix
description: Etapa 5. Chama o agente implementer (segunda passada) só com os pontos aceitos do review.
argument-hint: <ID da spec> <números aceitos, ex. S2.8 1,3,5>
disable-model-invocation: true
---

Rode a etapa 5 (segunda passada). Os argumentos são `$ARGUMENTS`: a primeira palavra é o ID da spec, o resto é a lista dos números aceitos do review.

1. Se faltar o ID ou a lista de números, pare e peça.
2. Leia o frontmatter de `specs/<ID>.md`. Se o `status` não for `review-done`, pare e avise.
3. Rode `git status --short`. Se a árvore não estiver limpa, pare e mostre o que está pendente.
4. Leia `specs/reviews/<ID>.md` e pegue, da tabela "Sugestões para o implementer", as linhas com os números informados. Se algum número não existir, pare e avise.
5. Chame o agente `implementer` com o prompt:

   ```
   Spec <ID>, segunda passada. A spec está em specs/<ID>.md.
   Pontos aceitos do review (aplique somente estes):
   <linhas completas da tabela: #, severidade, arquivo:linha, problema, sugestão>
   ```

6. Confira por conta própria:
   - `tools/gate-tests.sh <tests_commit>` dá `GATE OK`;
   - o `status` da spec é `fixes-applied`;
   - `git status --short` está limpo.
7. Repasse o relatório do agente, destacando as pendências, e o resultado das conferências. Diga que o próximo passo é `/done <ID>`.
