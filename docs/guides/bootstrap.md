# Guia: specs de bootstrap

O `/project-init` usa este guia, junto com as respostas de `docs/project-setup.md`, para gerar as specs de bootstrap. Ele guarda as decisões que já foram tomadas uma vez, para que sejam propostas como padrão em vez de discutidas de novo. O usuário pode mudar qualquer uma delas no questionário.

## Quais specs de bootstrap

| Spec | Conteúdo | `tests` | Depende de |
| --- | --- | --- | --- |
| `S0.1` configuração geral | repositório, workspaces, ambiente, infraestrutura, pacotes compartilhados, fluxo mínimo de ponta a ponta, configuração dos testes, scripts da raiz, "Como rodar o projeto" no `CLAUDE.md` | `inline` (o ferramental de testes está sendo criado) | — |
| `S0.2` lint | lint e lint de estilo impondo arquitetura, fachadas, tokens, tamanho, segurança de tipos e qualidade, com um teste por regra (ver `docs/guides/lint.md`) | `red` (o runner de testes já existe depois da S0.1) | S0.1 |
| `S0.3`+ | só quando o questionário pede algo que não cabe na S0.1 nem na S0.2 (ex.: CI, um segundo banco, configuração de i18n) | `red` quando possível | as anteriores |

Mantenha cada spec executável numa única passada do `implementer`. Quando a S0.1 ficar grande demais (ex.: três apps mais a infraestrutura), divida por app (`S0.1` repositório e backend, `S0.2` web, `S0.3` mobile, depois o lint) e explique a divisão nas specs.

## Formato

As specs de bootstrap seguem o formato de spec de `docs/workflow.md` ("Formato da spec de bootstrap"): objetivo, entradas, árvore de pastas, tabela de dependências iniciais, critérios agrupados em `R1`, `R2`… e numerados `C1`, `C2`…, design técnico quando necessário, plano de testes (`T`), plano de implementação (`I`), verificação manual, fora de escopo e pontos a validar. Critérios que só uma pessoa consegue conferir são marcados `[manual]` e listados em "Verificação manual".

## Decisões padrão da S0.1

### Repositório e workspaces

- A árvore completa de pastas é listada na spec; pastas vazias recebem um `.gitkeep`.
- O manifesto da raiz é privado, fixa a versão do gerenciador de pacotes e a do runtime (ex.: `packageManager` e `engines`), com um arquivo de versão do runtime (ex.: `.nvmrc`) na mesma versão major.
- Versões: as estáveis mais recentes e compatíveis entre si, escolhidas no momento da execução e fixadas. Dependências presas a um framework são instaladas pelo instalador do próprio framework (ex.: `npx expo install`), para respeitar o SDK.
- Uma configuração base estrita do compilador, que todo workspace estende.
- O `.gitignore` cobre dependências, builds, caches dos frameworks, coverage, `.env*` (exceto `.env.example`), arquivos gerados (ex.: CSS gerado dos tokens) e dados locais dos containers. O `.editorconfig` já vem no template.
- Um único lockfile depois de uma instalação limpa.

### Ambiente

- O `.env.example` lista e comenta todas as variáveis, sem nenhum segredo real.
- Um script na raiz interrompe todo comando que precisa do `.env` com uma mensagem clara (`cp .env.example .env`).
- Cada app tem um único módulo de configuração, o único lugar que lê o ambiente; ele valida as variáveis e falha logo, com mensagem clara.
- Cada app tem um logger único; nenhum outro arquivo escreve no console.

### Backend

- O módulo do app monta o app HTTP sem subir o servidor; um módulo separado sobe o servidor (assim os testes de integração rodam sem abrir porta).
- O schema só muda por migration, nunca por sincronização automática. Migrations e seeds rodam na mesma linguagem do app. Os seeds rodam sem erro quando vazios.
- Se as pastas de migrations e seeds tratam todo arquivo de código como migration, os testes delas ficam em outro lugar (ex.: `src/__tests__/`).
- As pastas vazias das camadas existem desde o início (routes, controllers, services, models, migrations, seeds, middlewares, validators, integrations, config).
- Um middleware de erro não tratado devolve o formato definido nas convenções para erro não tratado e registra o erro.

### Fluxo mínimo de ponta a ponta

Um health check que atravessa todas as camadas de todos os apps e prova que estão ligadas:

- Backend: `GET /health` → route → controller → service, e o service verifica o banco. `200 { "status": "ok", "database": "up" }` e `503 { "status": "error", "database": "down" }`. A resposta cumpre o schema compartilhado.
- Pacotes compartilhados (quando há mais de um cliente): schemas de validação (schema e tipo da resposta do health), cliente tipado da API (`createApiClient({ baseUrl })` com `health()` validando a resposta), design tokens com valores provisórios e, para o web, um script de build que gera as CSS variables.
- Cada app cliente: uma tela provisória mostrando carregando, erro com "Tentar novamente" e "API online", passando por todas as camadas do cliente (componente → hook de domínio → data/api → fachada de configuração). Os estilos usam só tokens.
- Os arquivos desse fluxo são provisórios e são substituídos quando a primeira história real tocar neles.

### Infraestrutura

- Banco no Docker com versão fixa (nunca `latest`), volume nomeado, healthcheck e um script de inicialização que cria os bancos de desenvolvimento e de teste.
- Script na raiz que sobe só o banco e espera ficar saudável; um profile opcional sobe também os apps em containers, com recarga ao editar (bind mount) e o host do banco igual ao nome do serviço dentro da rede.
- Portas, usuário, senha e nomes dos bancos vêm do `.env`, nunca fixos no compose.
- Os Dockerfiles fazem o build a partir da raiz do repositório, usam o cache do gerenciador de pacotes e não colocam segredo na imagem.
- Um comando de reset do banco que pede confirmação (com uma opção para pular).
- Apps mobile nunca rodam em containers.

### Testes

- Todo workspace com código tem seus testes rodando no runner único.
- Backend: testes de integração com o banco de teste, migrations aplicadas uma vez num setup global, tabelas esvaziadas após cada teste. O teste do health usa a biblioteca de teste HTTP sobre o módulo do app e simula a falha do banco sem derrubar o container.
- Apps clientes: cada camada é testada com mock da camada de baixo; módulos do framework nunca recebem mock, só as fachadas.
- Pacotes compartilhados: o build dos tokens gera uma variável por token; o cliente da API aceita uma resposta válida e rejeita uma inválida.

### Scripts da raiz

`dev:*` por app, `infra:up`, `infra:up:apps`, `infra:down`, `infra:logs`, `db:migrate`, `db:migrate:undo`, `db:seed`, `db:reset`, `typecheck`, `test`, `test:*` por app, e o build dos arquivos gerados (ex.: `tokens:build`), que os scripts de dev e de build do web rodam antes. O `lint` é criado pela S0.2.

### Documentação

- O `docs/reuse.md` ganha entradas para os pacotes compartilhados e os helpers criados (tokens, cliente da API, fachada de configuração, helpers do banco de teste).
- No fim, a S0.1 substitui a seção "Como rodar o projeto" do `CLAUDE.md`: pré-requisitos, passo a passo da primeira vez, modos de execução e tabela de comandos.

### Verificação manual

Uma sequência numa máquina limpa: copiar o `.env`, instalar, gerar os arquivos gerados, subir o banco, rodar migrations e seeds, subir cada app e conferir o fluxo de ponta a ponta, parar e subir em containers, rodar typecheck e testes.

### Fora de escopo (padrão)

Lint (S0.2), configuração do Claude Code (já vem no template), imagens de produção, hospedagem, CI/CD, builds para as lojas e qualquer história de negócio.

## Lições aprendidas (Node + pnpm + Expo + React + PostgreSQL)

Aplique quando a stack for essa:

- Expo com pnpm precisa de `node-linker=hoisted` no `.npmrc` para o Metro resolver as dependências do monorepo (confira a documentação do SDK vigente).
- O pnpm 10 bloqueia scripts de instalação por padrão: liste os pacotes que precisam deles em `onlyBuiltDependencies` (ex.: `esbuild`, `@parcel/watcher`).
- As versões recentes do Node não trazem mais o corepack: `npm i -g corepack && corepack enable`.
- O `sequelize-cli` roda migrations e seeds em TypeScript com o `tsx` (configurado no `.sequelizerc`).
- O servidor de dev do web repassa `/api/*` para a URL da API, lida num único arquivo (ex.: `vite.config.ts`); a API em si não tem prefixo.
- No celular físico, a URL da API precisa ser o IP da máquina na rede; no emulador Android, `10.0.2.2`.
- A configuração do app mobile lê o `.env` da raiz por conta própria e valida a URL da API, porque os tipos do framework declaram as variáveis públicas sem tipo.
