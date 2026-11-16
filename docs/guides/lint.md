# Guia: spec de bootstrap do lint (S0.2)

O `/project-init` usa este guia para gerar a spec do lint. As decisões abaixo já foram tomadas uma vez e são o padrão; o questionário (seção 5) só registra o que for diferente. O objetivo do lint é **impor automaticamente** o que o `CLAUDE.md` define: camadas, fachadas, tokens, tamanho, segurança de tipos e qualidade.

## Organização

- Uma configuração de lint na raiz que só compõe módulos por grupo de regras de `tools/lint/`: `architecture`, `facades`, `tokens`, `size`, `typescript` (segurança de tipos), `quality`, `tests`. Os padrões de caminho compartilhados ficam num módulo (ex.: `tools/lint/paths.mjs`).
- **Os padrões dos arquivos de teste são lidos de `tools/test-paths.txt`** (nunca copiados). Os arquivos de configuração de ferramenta (ex.: `**/*.config.*`) são um segundo padrão compartilhado.
- `tools/lint` é um workspace, com manifesto, configuração do compilador, configuração de testes e os testes das regras.
- Um linter de estilo separado para o CSS, quando há app web.
- Scripts na raiz: `lint` (todos os workspaces, arquivos da raiz e `tools/`) e `lint:css`; cada workspace tem também o seu `lint`. Os dois falham com qualquer aviso (`--max-warnings 0` ou equivalente).
- Ficam de fora: dependências, builds, caches dos frameworks, coverage e arquivos gerados (ex.: o CSS dos tokens).
- Scripts e arquivos de configuração sem informação de tipo são lintados sem as regras que dependem de tipo.
- Nenhum comentário de desativação de lint; o código existente da S0.1 é ajustado para passar.

## Grupos de regras e critérios padrão

Cada item vira um ou mais critérios na spec (Dado um arquivo com X, quando rodo o lint, então há o erro Y / passa).

### R1 · Arquitetura

- Fronteiras de camada por app, a partir das tabelas de "Camadas" do `CLAUDE.md` (cada camada só importa o que a sua linha permite). Arquivos de teste ficam fora das regras de camada, mas continuam seguindo as regras de mock.
- Regras que precisam valer também para módulos que ainda não existem são reforçadas por **padrões de caminho do import** (os plugins de fronteira costumam avaliar só imports que resolvem para um arquivo existente).
- A raiz do repositório é fixada na configuração, para o lint funcionar igual a partir da raiz ou de dentro de um workspace.
- Sem ciclos de importação.
- Acesso ao ambiente só dentro da pasta de configuração de cada app (arquivos de configuração de ferramenta são exceção).
- Pacotes compartilhados nunca importam apps; um app nunca importa outro.
- Services do backend nunca importam os tipos de requisição e resposta do framework HTTP.

### R2 · Fachadas

- Módulos da plataforma ou do framework (ex.: `expo`, `expo-*`, e `Linking`, `Alert`, `Platform`, `PermissionsAndroid` vindos de `react-native`) só dentro da pasta de fachadas do cliente; componentes básicos de interface passam.
- Clientes HTTP (`axios`, `node-fetch`, `got`, `undici`, `http`, `https`, com ou sem o prefixo `node:`, e o `fetch` global) só dentro da pasta de integrações do backend (o bootstrap do servidor é a única exceção possível).
- Um service que importa uma integração passa.

### R3 · Estilo e tokens (projetos com interface)

Vale para os arquivos de interface fora do pacote de tokens; arquivos de teste ficam de fora.

- Cores literais (hexadecimal, inclusive em template literals; `rgb()`, `rgba()`, `hsl()`, `hsla()`) são erro.
- Números literais diferentes de zero em propriedades de espaçamento (`margin*`, `padding*`, `gap`, `rowGap`, `columnGap`), tipografia (`fontSize`, `lineHeight`, `letterSpacing`), raio e borda (`borderRadius*`, `borderWidth*`, inclusive os lados) e sombra (`elevation`, `shadow*`) são erro; `0` e valores de token passam.
- Mobile: sem cores literais, sem estilos inline, sem texto solto fora de componentes de texto.
- CSS: hexadecimal, cores nomeadas e as variantes `rgb()`/`hsl()` são erro; `px`, `rem` e `em` em propriedades de espaçamento, tipografia, raio, borda e sombra são erro (as três unidades, para a regra não ser contornada); `0` e `var(--...)` passam.
- O pacote de tokens pode conter literais.

### R4 · Tamanho e complexidade

Padrões (sem contar linhas em branco e comentários): 250 linhas por arquivo, 50 linhas por função, complexidade ciclomática 10, profundidade de aninhamento 3, 4 parâmetros. Arquivos de teste: sem limite por função, 400 linhas por arquivo. Migrations e seeds: sem limites de tamanho.

### R5 · Segurança de tipos

- Sem `any` explícito (ou equivalente).
- Sem Promises soltas (com `await`, tratadas ou com `void` explícito).
- Imports usados só como tipo usam a sintaxe de import de tipo.
- Sem non-null assertion.
- Funções exportadas com tipo de retorno explícito (componentes React: `ReactElement`); arquivos de teste ficam de fora.
- A configuração base do compilador é estrita.

### R6 · Qualidade

- Sem saída no console, exceto no arquivo do logger de cada app.
- Regras de hooks e dependências exaustivas como erro (React).
- Acessibilidade: regras recomendadas de a11y no web; no mobile, tocáveis sem role, rótulo e dica de acessibilidade são erro.
- Sem testes focados (`.only`, `fdescribe`, `fit`) e sem testes desativados (`.skip`, `xdescribe`, `xit`).

### R7 · Execução

- Qualquer violação faz o comando terminar com código diferente de zero; avisos também reprovam.
- Código limpo termina com zero, inclusive o código existente da S0.1, ajustado sem comentários de desativação.
- Um arquivo novo dentro do `include` do compilador de um workspace é coberto pelas regras do seu workspace sem mudar a configuração.

## Verificando as regras

As regras de lint têm testes e seguem o mesmo fluxo (um teste por critério):

- Cada critério passa um código inline pela API do linter com um **caminho de arquivo virtual** que simula o local (ex.: `apps/api/src/controllers/user.controller.ts`) e confere o id da regra esperada, ou a ausência de erro nos casos que devem passar.
- Sem arquivos de fixture no disco. Imports de fronteira podem apontar para módulos que já existem no repositório.
- Os critérios do lint de estilo fazem o mesmo com a API do linter de estilo e a configuração do app web.
- O comando de testes da raiz inclui os testes do lint.

## Fora de escopo (padrão)

Integração com CI e hooks de commit, formatação automática, regras de nome de arquivo, detecção de exports sem uso, ferramentas externas de fronteira, regras de `width`/`height` literais e camadas de apps cuja estrutura interna ainda não foi definida.

## Lições aprendidas (TypeScript: ESLint 9 + typescript-eslint)

Aplique quando a stack for essa:

- ESLint 9 com flat config e type-aware (`projectService`), porque `no-floating-promises` precisa de informação de tipo. Na época, o ESLint 10 não era suportado por `eslint-plugin-import`, `react-native`, `react-native-a11y` e `jsx-a11y`; confira de novo antes de escolher.
- Plugins: `eslint-plugin-boundaries` (+ `eslint-import-resolver-typescript` para os imports dos workspaces), `eslint-plugin-import` (`import/no-cycle`), `react-hooks`, `react-native`, `react-native-a11y`, `jsx-a11y`, `jest`; Stylelint para o CSS. Plugins sem suporte ao flat config são adaptados com `@eslint/compat`.
- Reforço por caminho: `@typescript-eslint/no-restricted-imports` com padrões `regex`.
- Fixe `boundaries/root-path` e caminhos absolutos no resolver, para o lint funcionar a partir de um workspace.
- Arquivos virtuais nos testes: o `projectService` só aceita arquivos que existem, então os virtuais se chamam `lintcase*` e, só na instância do ESLint dos testes, recebem um projeto padrão (`allowDefaultProject` com um `tsconfig.virtual.json`). Casos que precisam de arquivo real (ciclos de importação) usam um caminho existente com conteúdo inline, sem mexer no disco.
- O `import/no-cycle` precisa de `disableScc: true` com arquivos virtuais (custa só desempenho).
- O Jest roda os testes do lint em modo ESM (`--experimental-vm-modules`), porque o Stylelint só é publicado como ESM.
- Conjunto básico do `react-native-a11y`: um tocável com `accessibilityLabel` também precisa de `accessibilityHint`.
- Lacuna conhecida: `import { env } from 'node:process'` não é pego pela regra de `process.env`; permita só em arquivos de configuração de ferramenta.
