---
name: project-init
description: Etapa S0. Lê docs/project-setup.md, pergunta sobre cada lacuna até não sobrar nenhuma, configura o CLAUDE.md, o tools/test-paths.txt e o docs/technical-conventions.md, e gera as specs de bootstrap (specs/S0.*.md) em draft para aprovação manual. Pode rodar de novo para revisar enquanto as specs de bootstrap forem draft.
argument-hint: "[opcional: o que revisar, numa segunda execução]"
disable-model-invocation: true
---

Configure o projeto a partir de `docs/project-setup.md`, seguindo a "Etapa S0: configuração do projeto" de `docs/workflow.md`. Esta skill só configura e escreve rascunhos: não instala nada, não escreve código da aplicação e não executa nenhuma spec. Cada spec de bootstrap é aprovada pelo usuário com `/approve`.

## 1. Conferir o ponto de partida

1. Rode `git rev-parse --is-inside-work-tree`. Se não for um repositório git, pare e peça ao usuário para rodar `git init` (o fluxo depende do git).
2. Rode `git status --short`. Se houver alterações além de `docs/project-setup.md`, mostre-as e pergunte antes de seguir.
3. Leia o `status` do frontmatter de `docs/project-setup.md`:
   - `pending`: execução completa (passos 2 a 7).
   - `configured`: execução de revisão. Leia `specs/S0.*.md`. Se alguma não estiver mais em `draft`, pare: o bootstrap já está em execução, e as mudanças passam por uma nova spec de bootstrap ou por uma história. Senão, considere `$ARGUMENTS` (e as novas edições no questionário) como o que revisar e percorra os passos 2 a 7 só no que for afetado.

## 2. Ler

- `docs/project-setup.md` (as respostas), `docs/workflow.md`, `CLAUDE.md` (os marcadores `{{...}}` e o que cada um espera) e `docs/technical-conventions.md`.
- `docs/guides/bootstrap.md` e `docs/guides/lint.md`: as decisões padrão. A resposta `default` significa "use o guia"; resposta vazia ou `?` significa "proponha o padrão do guia como recomendação".
- O planejamento indicado na P1.4, se houver.

## 3. Levantar as lacunas

Monte a lista numerada dos pontos que impedem preencher todos os marcadores e escrever specs de bootstrap com itens fechados e verificáveis:

- perguntas sem resposta e sem padrão nos guias;
- respostas vagas (ex.: "um banco" sem dizer qual; "camadas como de costume");
- respostas que se contradizem ou contradizem um padrão dos guias que o usuário não mudou de forma explícita;
- respostas que não se encaixam nos guias (outra stack, outra linguagem): a intenção do guia continua valendo, mas a escolha concreta (ferramenta, plugin, comando) precisa ser perguntada;
- marcadores do `CLAUDE.md` sem resposta correspondente;
- seções opcionais (Estilo e tokens, Concorrência e consistência, Buscas) cuja aplicação não está clara;
- a divisão do bootstrap (uma S0.1 ou uma por app; se é preciso uma `S0.3` ou mais).

Nunca invente resposta e nunca trate um padrão como aceito quando o usuário escreveu outra coisa.

## 4. Perguntar

- Mostre antes a lista numerada, para o usuário ver o tamanho da conversa.
- Use a ferramenta de perguntas, com no máximo 4 perguntas por rodada e 2 a 4 opções cada, com o padrão do guia (ou a sua recomendação) primeiro, explicando o porquê.
- Repita as rodadas até não sobrar nada. Uma resposta pode abrir pontos novos: inclua-os.
- Depois de cada rodada, grave as respostas fechadas em `docs/project-setup.md` (nas linhas `Resposta:`), para uma próxima execução partir delas.
- Se o usuário adiar um ponto que bloqueia um marcador ou uma spec de bootstrap, nada é gerado: liste o que ficou pendente e pare (as respostas já gravadas ficam).

## 5. Mostrar o plano e confirmar

Antes de escrever qualquer outra coisa, mostre:

- o conteúdo de cada seção do `CLAUDE.md` que será preenchida (em forma resumida) e as seções opcionais que serão removidas;
- os globs do `tools/test-paths.txt`;
- as convenções que entram em "Definidas" no `docs/technical-conventions.md`, e as linhas de "A definir" que serão removidas por não se aplicarem;
- a lista das specs de bootstrap (ID, título, `tests: inline|red` e o escopo em uma linha cada).

Peça ao usuário para confirmar ou ajustar. Não siga sem confirmação.

## 6. Escrever

1. **`CLAUDE.md`:** substitua cada `{{...}}` pelo conteúdo final, escrito como regra do projeto (e não como pergunta); apague as seções opcionais que não se aplicam; apague os comentários do template. Deixe "Como rodar o projeto" com uma linha avisando que a S0.1 a escreve. Nenhum marcador pode sobrar (`grep -n '{{' CLAUDE.md` precisa voltar vazio).
2. **`tools/test-paths.txt`:** um glob por linha, abaixo dos comentários do cabeçalho.
3. **`docs/technical-conventions.md`:** preencha "Definidas" (origem: `project-setup`), remova de "A definir" as linhas respondidas ou que não se aplicam, e remova o comentário do template.
4. **`docs/planning.md`:** se o usuário indicou um planejamento existente, adapte-o à estrutura de `docs/guides/planning.md`, mantendo o conteúdo e os IDs (converta os IDs das histórias para `S{épico}.{n}` se preciso), e mostre as diferenças. Senão, deixe o esqueleto.
5. **Specs de bootstrap `specs/S0.{n}.md`:** no "Formato da spec de bootstrap" de `docs/workflow.md`, com `kind: bootstrap`, `status: draft`, `tests_commit:` vazio e `tests: inline` na spec que cria o ferramental de testes (`red` nas demais). Siga os guias no conteúdo:
   - S0.1 (configuração geral) a partir de `docs/guides/bootstrap.md`; S0.2 (lint) a partir de `docs/guides/lint.md`, com as tabelas de camadas do `CLAUDE.md` final convertidas em critérios de fronteira e os globs de teste lidos de `tools/test-paths.txt`.
   - Concretas como uma spec de história: árvore de pastas, tabela de dependências, critérios `C` agrupados em blocos `R`, plano de testes `T` com arquivo e resultado esperado completo, plano de implementação `I` com arquivos, nomes e comandos exatos, todo `C` coberto por um `T` (ou marcado `[manual]`) e todo `T` por um `I`.
   - O último item `I` da spec de configuração geral substitui "Como rodar o projeto" no `CLAUDE.md`; o último item `I` da spec de lint atualiza "Lint" no `CLAUDE.md`, se algo mudou.
   - "Pontos a validar" lista toda premissa não confirmada de forma explícita pelo usuário (ex.: versões escolhidas no momento da execução).
6. Mude o `status` de `docs/project-setup.md` para `configured`.

## 7. Conferir e fechar

- `grep -rn '{{' CLAUDE.md docs/technical-conventions.md` volta vazio; `tools/test-paths.txt` tem pelo menos um glob.
- Em cada spec de bootstrap: todo `C` está em algum `T` ou marcado `[manual]`; todo `T` está em algum `I`; nenhum item deixa decisão em aberto.
- Mostre um resumo: seções preenchidas, convenções registradas e, para cada spec de bootstrap, os blocos, o número de itens `T` e `I` e os pontos a validar.
- Peça ao usuário para confirmar o commit. Com a confirmação, faça o commit de tudo: `chore(init): configura projeto e specs de bootstrap` (ou `chore(init): revisa configuração` numa execução de revisão). Não faça push.
- Diga o próximo passo: ler `specs/S0.1.md`, ajustar se preciso (ou rodar `/project-init <o que revisar>`) e então `/approve S0.1`. As specs de bootstrap rodam em ordem, cada uma por `/approve`, `/review`, `/fix` e `/done`.
