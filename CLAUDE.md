# CLAUDE.md

Guia do projeto para o Claude Code. Mantenha este arquivo curto e atualizado.

<!--
TEMPLATE: as seções marcadas com {{...}} são preenchidas pelo /project-init a partir de docs/project-setup.md.
Não preencha à mão. O /project-init remove estes comentários e todos os marcadores; as seções opcionais
que não se aplicam ao projeto são apagadas.
-->

## Projeto

{{DESCRICAO_DO_PROJETO: o que é o produto, quem usa e as principais funcionalidades, em 3 a 5 linhas}}

- **Fluxo:** `docs/workflow.md` é o processo de desenvolvimento (etapas, status, formatos de card e spec, proteção dos testes). Toda skill e todo agente o seguem.
- **Planejamento:** `docs/planning.md` (épicos, funcionalidades, histórias `S{épico}.{n}`, critérios Dado/Quando/Então). É o rascunho das histórias e a fonte das regras de negócio fechadas, que valem para todas elas. Como escrever: `docs/guides/planning.md`.
- **Cards:** `docs/cards/{ID}.md`, um por história. O card aprovado é a fonte do negócio da história e substitui o rascunho do planejamento.
- **Specs:** `specs/{ID}.md`, uma por história ou etapa de bootstrap (`S0.*`). A spec é técnica e centraliza todas as decisões: design, plano de testes (itens `T`) e plano de implementação (itens `I`). Os agentes só executam os itens.
- **Convenções técnicas:** `docs/technical-conventions.md`, decisões de dados e de contrato que valem para todas as specs.
- **Reuso:** `docs/reuse.md`. Consulte antes de criar algo novo.
- Em caso de dúvida ou contradição, pare e pergunte. Não invente regra.

## Trabalho bloqueado

{{TRABALHO_BLOQUEADO: épicos ou histórias que ainda não podem ter spec nem código, com o motivo; ou "Nenhum."}}

## Stack

{{TABELA_DA_STACK: | Camada | Tecnologia | (monorepo/gerenciador de pacotes, cada app, banco, linguagem, busca de dados, runner de testes)}}

## Estrutura do repositório

```
{{ARVORE_DO_REPOSITORIO: pastas de primeiro nível e workspaces, uma linha cada}}
docs/           workflow.md, planning.md, technical-conventions.md, reuse.md, project-setup.md, guides/, cards/
specs/          uma spec por história ou etapa de bootstrap; relatórios de review em specs/reviews/
tools/          gate-tests.sh, test-paths.txt, hooks/
.claude/        agentes (test-writer, implementer, reviewer) e skills do fluxo
```

Não crie camadas nem pastas de primeiro nível novas sem perguntar.

## Convenções gerais

- Tipagem estrita em tudo. Sem tipos de escape ({{REGRA_SEM_ANY: ex.: "sem `any`" em TypeScript}}).
- Tudo em português (textos de interface, cards, specs, docs, descrições de teste, comentários, mensagens de commit), exceto identificadores, nomes de arquivo e de pasta, comandos e valores lidos por máquina (chaves e valores de frontmatter, tipos de commit), que ficam em inglês.
- Listas fixas de referência, que os usuários não alteram, ficam direto no banco, via seeds, sem fluxo de edição, a menos que uma história peça.
- {{REGRA_DE_CI: ex.: "Não há CI/CD nesta fase. Lint e testes rodam localmente e são o gate de cada etapa."}}
- Pacotes compartilhados nunca importam de apps. A dependência vai sempre dos apps para os pacotes, e um app nunca importa de outro.
- Não use comentário de desativação de lint para contornar uma regra. Se a regra atrapalha, pare e pergunte.
- Nenhuma dependência nova sem a spec prever.
- Logs por um logger único em cada app. Sem saída direta no console.
- Commits por etapa, como em `docs/workflow.md` ("Commits por etapa").

## Camadas

{{CAMADAS: para cada app, uma tabela | Pasta | Responsabilidade | e uma tabela | Camada | Pode importar |, seguidas das regras (onde fica a regra de negócio, onde ficam as chamadas externas, onde a configuração/ambiente é lida, mudança de schema só por migration etc.)}}

## Fachadas e integrações

Toda comunicação com o sistema operacional ou com serviços externos fica em uma pasta própria. O resto da aplicação não sabe como a integração é feita.

{{FACHADAS: por app, a pasta da fachada, um arquivo por capacidade, as fachadas existentes e previstas, e as bibliotecas que só podem ser importadas lá dentro}}

- A fachada fala a linguagem do domínio: `openChat(number)`, `pickProfilePhoto()`, `sendCode(phone, code)`. Nunca uma chamada crua de biblioteca ou de HTTP na assinatura.
- **Testes** fazem mock da fachada, nunca da biblioteca por trás nem do HTTP externo.

## Estilo e tokens

<!-- Opcional: o /project-init apaga esta seção quando o projeto não tem interface. -->

{{TOKENS: onde fica a fonte única de estilo, como cada app a consome (importa o objeto, CSS variables geradas…) e a regra: nenhum valor literal de cor, espaçamento, tipografia, raio ou sombra fora do pacote de tokens; se falta um token, crie-o lá antes de usar. O lint impõe isso.}}

## Concorrência e consistência

<!-- Opcional: o /project-init apaga esta seção quando o projeto não tem banco de dados. -->

Resolva no banco, não só na lógica da aplicação:

- **Um por usuário (ex.: um voto por usuário em cada enquete):** constraint única (usuário, enquete) e tratamento do erro de duplicidade.
- **A primeira ação vale (ex.: a primeira marcação de um item como usado):** atualização condicional atômica (`UPDATE ... WHERE used_at IS NULL`) e checagem das linhas afetadas. Nunca ler e depois gravar.
- **Eventos externos idempotentes (ex.: webhooks de pagamento):** chave única do id do evento, processado em transação.
- Toda operação que grava em mais de uma tabela usa transação.

## Buscas

<!-- Opcional: o /project-init apaga esta seção quando nenhuma história precisa de busca por texto. -->

A busca sem diferenciar maiúsculas e acentos usa recursos do banco habilitados por migration ({{RECURSOS_DE_BUSCA: ex.: `unaccent` e `pg_trgm` no PostgreSQL}}), criados pela primeira história que precisar deles.

## Testes

{{CONVENCOES_DE_TESTE: runner por workspace (um único runner, sem bibliotecas extras), bibliotecas, banco real ou não, isolamento entre testes, regras de mock por camada, testes end-to-end ou não, onde ficam os arquivos de teste}}

## Caminhos de teste

Os globs de teste protegidos ficam em `tools/test-paths.txt`, a fonte única lida pelo gate, pelo hook e pelo lint. Altere-os só lá.

## Ambiente de testes

{{AMBIENTE_DE_TESTES: o que precisa estar no ar antes dos testes (ex.: "o banco: rode `pnpm infra:up` se estiver fora do ar") e como conferir}}

## Gates

Rode nesta ordem ao fim de toda etapa que escreve código. Todos precisam passar sem erro e sem aviso.

{{GATES: lista numerada de comandos (typecheck, testes, lint, outros linters), indicando qual spec de bootstrap cria cada um}}

Depois, `tools/gate-tests.sh <tests_commit>`, que precisa dar `GATE OK`.

## Comandos proibidos para agentes

`git push`, `git reset --hard`, `git checkout` de outro commit sobre arquivos de teste, e:

{{COMANDOS_PROIBIDOS: comandos destrutivos do projeto (reset do banco, remoção de volumes etc.)}}

## Ordem do plano de implementação

{{ORDEM_DE_IMPLEMENTACAO: a ordem das camadas nos itens I, ex.: migration → model → schema → service → controller → route → api-client → data/api → domain → components}}

## Checklist de design técnico

O que a seção "Design técnico" de uma spec precisa detalhar:

{{CHECKLIST_DE_DESIGN: ex.: modelo de dados (migrations com colunas, tipos, nulo, default, PK, FKs com ON DELETE, unique, índices; seeds; models); API (método e caminho, autenticação, schema de validação, request e respostas em JSON, tabela de erros); services (assinaturas e garantias: transação, constraint, atualização atômica); app e painel (telas, componentes, hooks, acesso a dados, fachadas, estados, textos, rótulos de acessibilidade); integrações}}

## Checklist de review do projeto

Além das conferências genéricas do agente `reviewer`:

{{CHECKLIST_DE_REVIEW: conferências de camadas e fronteiras, de fachadas, de tokens, biblioteca de validação de entrada, estados de tela e acessibilidade, biblioteca de busca de dados, pontos de segurança da stack}}

## Lint

{{RESUMO_DO_LINT: ferramentas, onde fica a configuração (um módulo por grupo de regras em tools/lint/), como rodar e os principais limites; detalhes em specs/S0.2.md e docs/guides/lint.md}}

## Como rodar o projeto

{{COMO_RODAR: pré-requisitos, passo a passo da primeira vez, modos de execução, tabela de comandos. Escrito pela spec de bootstrap de configuração geral (S0.1) ao fim da execução.}}
