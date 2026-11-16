---
status: pending   # pending | configured
---

# Configuração do projeto

Preencha as respostas abaixo e rode `/project-init`. Ele lê este arquivo, pergunta sobre o que estiver faltando, vago ou contraditório, grava aqui as respostas finais e as usa para configurar o `CLAUDE.md`, o `tools/test-paths.txt`, o `docs/technical-conventions.md` e as specs de bootstrap (`specs/S0.*.md`).

- Respostas curtas bastam: o `/project-init` faz as perguntas de complemento.
- Escreva `default` para aceitar o padrão do template indicado na pergunta (vindo de `docs/guides/bootstrap.md` e `docs/guides/lint.md`), ou `?` quando ainda não souber: o `/project-init` vai propor uma opção.
- Cada pergunta indica qual parte da configuração ela alimenta (`→`).

---

## 1. Produto

**P1.1 Nome e slug.** Nome do produto e um slug curto em minúsculas (usado nos nomes de pacotes, bancos e containers).
→ `CLAUDE.md` Projeto; specs de bootstrap

Resposta:

**P1.2 Descrição.** O que é o produto, quem usa e as principais funcionalidades, em 3 a 5 linhas.
→ `CLAUDE.md` Projeto

Resposta:

**P1.3 Idioma da interface.** Idioma dos textos que o usuário final vê. Padrão: português (Brasil).
→ `CLAUDE.md` Convenções gerais

Resposta:

**P1.4 Planejamento.** Já existe um planejamento (épicos e histórias)? Se sim, onde está? Ele será adaptado para `docs/planning.md` (ver `docs/guides/planning.md`).
→ `docs/planning.md`

Resposta:

**P1.5 Trabalho bloqueado.** Algo que ainda não pode ter spec nem código (ex.: aguardando a escolha de um fornecedor)?
→ `CLAUDE.md` Trabalho bloqueado

Resposta:

## 2. Stack e estrutura

**P2.1 Apps.** Quais apps o produto tem (ex.: API, painel web de administração, app mobile, CLI, worker)? Para cada um: framework e plataforma.
→ `CLAUDE.md` Stack; S0.1

Resposta:

**P2.2 Linguagem e runtime.** Linguagem, runtime e política de versões. Padrão: as versões estáveis mais recentes no momento da execução, fixadas no repositório.
→ `CLAUDE.md` Stack; S0.1

Resposta:

**P2.3 Organização do repositório.** Monorepo ou app único? Gerenciador de pacotes / ferramenta de workspaces? Pacotes compartilhados (ex.: design tokens, schemas de validação, cliente tipado da API)?
→ `CLAUDE.md` Estrutura do repositório; S0.1

Resposta:

**P2.4 Banco e acesso a dados.** Banco, ORM ou camada de consulta, ferramenta de migrations. Padrão (quando há banco): o schema só muda por migration, nunca por sincronização automática.
→ `CLAUDE.md` Stack, Camadas; S0.1

Resposta:

**P2.5 Busca de dados e estado nos clientes.** Como os apps falam com o backend e guardam em cache os dados do servidor (ex.: TanStack Query). Padrão: um cliente tipado num pacote compartilhado, validado pelos schemas compartilhados.
→ `CLAUDE.md` Stack, Camadas

Resposta:

**P2.6 Infraestrutura de desenvolvimento.** O que roda em containers (só o banco, ou os apps também)? Portas? Banco de teste separado? Padrão: banco no Docker com versão fixa, volume nomeado, healthcheck e bancos separados de desenvolvimento e de teste; apps na máquina, com um profile opcional para rodá-los em containers.
→ S0.1; `CLAUDE.md` Ambiente de testes, Como rodar o projeto

Resposta:

**P2.7 Variáveis de ambiente.** Variáveis já conhecidas (além de banco, portas e URLs da API). Padrão: `.env.example` comentado e sem segredo real; um script que interrompe os comandos com mensagem clara quando falta o `.env`; um único módulo de configuração por app lê e valida o ambiente.
→ S0.1

Resposta:

## 3. Arquitetura

**P3.1 Camadas por app.** Para cada app: pastas, responsabilidade de cada uma e qual camada pode importar qual. Padrão de backend: routes → controllers → services → models, com regra de negócio só em services. Padrão de app cliente: components → domain → data (api, facades).
→ `CLAUDE.md` Camadas; regras de arquitetura da S0.2

Resposta:

**P3.2 Fachadas e integrações.** Serviços externos (pagamento, mensageria, e-mail, armazenamento…) e recursos do sistema operacional (links, câmera, armazenamento seguro…) que o produto vai usar. Padrão: uma pasta de fachada por app, um arquivo por capacidade, bibliotecas importadas só lá.
→ `CLAUDE.md` Fachadas e integrações; regras de fachada da S0.2

Resposta:

**P3.3 Estilo e tokens.** O produto tem interface? Padrão: um pacote de tokens (cor, espaçamento, tipografia, raio, sombra) como fonte única de estilo; nenhum valor literal de estilo fora dele, imposto pelo lint.
→ `CLAUDE.md` Estilo e tokens; S0.1; regras de tokens da S0.2

Resposta:

**P3.4 Concorrência e busca.** Haverá recursos de um por usuário, transições em que a primeira ação vale, eventos externos (webhooks) ou busca por texto sem diferenciar acentos e maiúsculas?
→ `CLAUDE.md` Concorrência e consistência, Buscas

Resposta:

**P3.5 Fluxo mínimo de ponta a ponta.** O que prova que todas as camadas estão ligadas? Padrão: um health check que passa por todas as camadas de todos os apps (tela do cliente → API → banco), com testes em cada camada.
→ S0.1

Resposta:

## 4. Testes e gates

**P4.1 Runner e bibliotecas de teste.** Padrão: um único runner em todos os workspaces (ex.: Jest), sem bibliotecas extras de assertion ou mock.
→ `CLAUDE.md` Testes; S0.1

Resposta:

**P4.2 Estratégia de testes.** Testes de integração com banco real? Regras de mock por camada? Testes end-to-end? Padrão: testes de integração do backend com um banco de teste real (migrations aplicadas uma vez, tabelas esvaziadas após cada teste); cada camada do cliente faz mock da camada de baixo; sem end-to-end na primeira fase.
→ `CLAUDE.md` Testes; S0.1

Resposta:

**P4.3 Caminhos de teste.** Globs que identificam os arquivos de teste (protegidos pelo gate). Padrão para TypeScript: `**/*.test.ts`, `**/*.test.tsx`, `**/__tests__/**`, `**/__mocks__/**`, `**/test-utils/**`.
→ `tools/test-paths.txt`

Resposta:

**P4.4 Gates.** Comandos de typecheck, testes e lint. Padrão: scripts na raiz `typecheck`, `test`, `lint` (e `lint:css` quando houver CSS), todos falhando com qualquer aviso.
→ `CLAUDE.md` Gates; S0.1, S0.2

Resposta:

**P4.5 CI.** Há CI/CD nesta fase? Padrão: não; lint e testes rodam localmente e são o gate.
→ `CLAUDE.md` Convenções gerais

Resposta:

**P4.6 Comandos proibidos.** Comandos destrutivos do projeto que os agentes nunca podem rodar (além de `git push` e `git reset --hard`). Padrão: reset do banco e remoção de volumes dos containers.
→ `CLAUDE.md` Comandos proibidos para agentes

Resposta:

## 5. Lint

Os padrões vêm de `docs/guides/lint.md`. Responda só o que for diferente.

**P5.1 Grupos de regras.** Arquitetura, fachadas, tokens, tamanho e complexidade, segurança de tipos, qualidade geral, higiene dos testes. Padrão: todos os que se aplicam à stack.
→ S0.2

Resposta:

**P5.2 Limites.** Padrão: 250 linhas por arquivo, 50 por função, complexidade ciclomática 10, profundidade de aninhamento 3, 4 parâmetros; arquivos de teste com 400 linhas e sem limite por função; migrations e seeds fora dos limites de tamanho.
→ S0.2

Resposta:

**P5.3 Acessibilidade.** Padrão: lint de acessibilidade em todo app com interface; no mobile, todo elemento tocável tem role, rótulo e dica.
→ S0.2

Resposta:

## 6. Convenções técnicas

Responda o que já estiver decidido. O que ficar com `?` continua "a definir" em `docs/technical-conventions.md` e é perguntado pela primeira spec que precisar.

**P6.1 Framework HTTP.**

Resposta:

**P6.2 Chave primária** (UUID ou auto-incremento).

Resposta:

**P6.3 Nomes no banco** (snake_case ou camelCase; tabelas no plural).

Resposta:

**P6.4 Timestamps e exclusão** (created_at/updated_at; exclusão lógica ou física).

Resposta:

**P6.5 Respostas de erro** (formato do corpo e códigos dos 4xx; corpo do 500 não tratado; status e formato dos campos no erro de validação).

Resposta:

**P6.6 Autenticação** (formato do token e como ele trafega).

Resposta:

**P6.7 Paginação** (cursor ou offset; nomes dos parâmetros; formato da resposta).

Resposta:

**P6.8 Datas, fuso horário, dinheiro, enums, nomes no JSON.**

Resposta:

**P6.9 Nome do arquivo de migration.** Padrão: `YYYYMMDDHHMMSS-verbo-objeto`, exportando `up` e `down`.

Resposta:

## 7. Outros pontos

**P7.1 Outras restrições ou preferências** (hospedagem, conformidade, desempenho, nível de acessibilidade, bibliotecas a evitar…).

Resposta:
