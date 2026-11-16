# Guia: escrevendo o docs/planning.md

O planejamento é a entrada do `/card`. Ele não precisa ser perfeito: o `/card` transforma cada história em critérios fechados e testáveis, perguntando o que estiver em aberto. Mas quanto melhor o planejamento, mais curtas são essas conversas. Isto é um guia, não uma skill: escreva o planejamento numa conversa normal com o Claude (ou à mão), mantendo a estrutura abaixo.

## Estrutura (mantenha os nomes das seções: o `/card` os lê)

```
# Planejamento: épicos, funcionalidades e histórias
## Regras de negócio fechadas
## E1 · Nome do épico
### F1.1 Nome da funcionalidade
- S1.1 História
  - Dado ..., quando ..., então ...
## Dependências e ordem sugerida
## Pontos em aberto
## Premissas assumidas nos critérios
```

- IDs: épico `E{n}`, funcionalidade `F{épico}.{n}`, história `S{épico}.{n}`. Nunca reutilize nem renumere um ID depois que ele tiver card.
- O épico 0 é reservado às specs de bootstrap (`S0.*`), geradas pelo `/project-init`.

## Processo sugerido

1. **Escopo bruto.** Cole o que você tiver (briefing do cliente, anotações, prints) e peça ao Claude para listar as funcionalidades, sem julgá-las.
2. **Épicos e funcionalidades.** Agrupe as funcionalidades em épicos (uma área do produto) e funcionalidades (uma capacidade coerente dentro dela).
3. **Histórias.** Uma história por comportamento visível ao usuário, escrita do ponto de vista dele ("Cadastrar-me com meu celular, desde que…"). Divida as histórias que têm mais de um motivo para mudar.
4. **Critérios.** Abaixo de cada história, critérios Dado / Quando / Então (ver abaixo).
5. **Sugestões.** Peça ao Claude histórias que faltam, casos de borda e riscos. Aceite ou rejeite cada uma de forma explícita; remova as rejeitadas e renumere só antes de existir qualquer card.
6. **Regras e premissas.** Mova para "Regras de negócio fechadas" toda regra que vale para mais de uma história. Liste em "Premissas assumidas nos critérios" toda suposição feita sem decisão.
7. **Dependências.** Registre quais épicos dependem de quais e uma ordem sugerida. Bloqueios externos (um fornecedor ainda não escolhido) vão para "Trabalho bloqueado" no `CLAUDE.md`.

## Bons critérios

- Um comportamento por critério: um Dado, um Quando, um Então. Valores concretos ("60 segundos", "6 dígitos"), nunca "rápido" ou "alguns".
- Resultado observável: o que o usuário vê, o que é enviado, o que é guardado. Nunca implementação ("uma linha na tabela X").
- Cubra os estados, não só o caminho feliz: vazio, carregando, erro com opção de tentar de novo, sem permissão, usuário inativo, o próprio registro do usuário, ações repetidas e simultâneas.
- Fluxos sensíveis de segurança dizem o que **não** pode ser revelado nem chamado (ex.: "sem indicação de que o número não está cadastrado", "nenhuma chamada ao provedor de mensagens").
- Contradições entre critérios e regras fechadas são resolvidas no planejamento, não no card.

## Regras de negócio fechadas x decisões do card

- **Regra de negócio fechada:** vale para o produto inteiro (ex.: "um match só existe com curtida mútua"). Fica no planejamento; todo card e toda spec precisam respeitá-la.
- **Decisão do card:** vale só para uma história. Fica na tabela "Decisões" do card.
- Quando o `/card` decide algo que vale para outras histórias, ele propõe mover a decisão para "Regras de negócio fechadas" e tirar a premissa correspondente.

## Premissas assumidas nos critérios

Escreva-as como afirmações que podem ser validadas ("o código de acesso tem 6 dígitos", "campos obrigatórios do perfil: nome, categoria e cidade"). Elas são as primeiras perguntas que o `/card` faz nas histórias que dependem delas.
