---
name: card
description: Etapa 0. Levanta as dúvidas de negócio da história, faz as perguntas e, com tudo respondido, gera docs/cards/<ID>.md em draft.
argument-hint: <ID da história, ex. S2.1>
disable-model-invocation: true
---

Monte o card da história `$ARGUMENTS`, seguindo a "Etapa 0: card" e o "Formato do card" de `docs/workflow.md`. O trabalho aqui é só de negócio: nada de código, testes ou decisões técnicas.

## 1. Conferir o ponto de partida

1. Se `$ARGUMENTS` estiver vazio ou começar com `S0.`, pare: specs de bootstrap não têm card (elas vêm do `/project-init`).
2. Confira "Trabalho bloqueado" no `CLAUDE.md`. Se a história estiver bloqueada, pare e avise.
3. Se `docs/cards/$ARGUMENTS.md` já existir:
   - `draft`: retome a partir dele e da seção "Decisões".
   - `approved`: se `specs/$ARGUMENTS.md` não existir, pergunte se o usuário quer reabrir o card (volta para `draft`). Se a spec já existir, pare e avise.

## 2. Levantar os pontos em aberto

Leia em `docs/planning.md` a história, as regras de negócio fechadas, as dependências e as "Premissas assumidas nos critérios". Leia também os cards já aprovados em `docs/cards/` que tratam do mesmo assunto, para não perguntar de novo o que já foi decidido e não contradizer uma decisão anterior.

Monte a lista de pontos que impedem escrever critérios fechados e testáveis:

- premissas de que a história depende e que ainda não foram validadas;
- parâmetros sem valor (prazos, limites, quantidades, textos, URLs);
- critérios ambíguos, contraditórios entre si ou com uma regra fechada, ou impossíveis de verificar;
- casos de borda que a história não cobre e que precisam de resposta: estados vazio e de erro, usuário inativo ou sem permissão, ações sobre o próprio registro, ações repetidas ou simultâneas, papéis e permissões;
- dependências de outras histórias que mudam o comportamento desta.

Não invente resposta para nenhum desses pontos e não trate uma premissa como decidida.

## 3. Perguntar

- Mostre a lista de pontos antes de começar, numerada, para o usuário ver o tamanho da conversa.
- Use a ferramenta de perguntas, com no máximo 4 perguntas por rodada, cada uma objetiva e com 2 a 4 opções. Quando tiver uma recomendação, coloque-a primeiro e explique o porquê na descrição.
- Pergunte só o que é de negócio. Decisão técnica (endpoint, tabela, biblioteca) fica para a spec.
- Repita as rodadas até não sobrar nenhum ponto. Uma resposta pode abrir pontos novos: inclua-os.
- Se o usuário adiar um ponto, o card não é gerado. Liste o que ficou pendente e pare.

## 4. Atualizar o planejamento

Se uma resposta cria ou muda uma regra que vale para outras histórias (ou valida uma premissa), proponha a alteração em `docs/planning.md`: a regra entra em "Regras de negócio fechadas" e a premissa correspondente sai de "Premissas assumidas nos critérios". Mostre o trecho e aplique só depois da confirmação do usuário. Regras que valem só para esta história ficam só no card.

## 5. Gerar o card

Com todos os pontos respondidos, escreva `docs/cards/$ARGUMENTS.md` com `status: draft`:

- os critérios de aceite na versão final, em Dado/Quando/Então, um por item, completos e testáveis. Eles podem diferir do rascunho do planejamento: o card é que vale para esta história;
- a seção "Decisões" com cada pergunta feita e a resposta, na ordem.

Não faça commit. Mostre o card e diga que o próximo passo é `/card-approve $ARGUMENTS`.
