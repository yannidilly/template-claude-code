# Convenções técnicas

Decisões técnicas que valem para todas as specs. Cada uma é decidida uma vez: o `/spec` consulta este arquivo antes de perguntar, e quando uma spec precisa de uma convenção ainda "a definir", ele pergunta, registra a resposta aqui e só então segue.

Regras de arquitetura (camadas, fachadas, tokens, concorrência) ficam no `CLAUDE.md`. Aqui ficam só os padrões de dados e de contrato.

## Definidas

| Tema | Convenção | Origem |
| --- | --- | --- |

<!-- O /project-init preenche esta tabela a partir da seção 6 de docs/project-setup.md; as specs acrescentam linhas depois (Origem = ID da spec). -->

## A definir

Perguntar quando a primeira spec precisar e mover para "Definidas". O `/project-init` remove as linhas já respondidas e as que não se aplicam à stack.

| Tema | Pergunta |
| --- | --- |
| Framework HTTP | Qual framework serve a API? |
| Erro não tratado | Status e corpo de um erro não tratado, e onde ele é registrado? |
| Arquivo de migration | Padrão do nome do arquivo e funções exportadas? |
| Prefixo das rotas | A API tem prefixo de caminho (ex.: `/api`, `/v1`)? |
| Chave primária | UUID ou inteiro auto-incremento? |
| Nomes no banco | Tabelas e colunas em `snake_case` ou `camelCase`? Tabelas no plural? |
| Timestamps | `created_at`/`updated_at` em todas as tabelas? Exclusão lógica (`deleted_at`) ou física? |
| Erros 4xx | Formato do corpo (ex.: `{ "error": { "code": "...", "message": "...", "fields": {...} } }`) e lista de códigos? |
| Erro de validação | Código HTTP (400 ou 422) e como os campos inválidos aparecem? |
| Autenticação | Formato do token de sessão e como ele trafega (ex.: `Authorization: Bearer`)? |
| Paginação | Cursor ou offset; nomes dos parâmetros e formato da resposta? |
| Datas | ISO 8601 em UTC na API? Fuso de exibição? Data sem hora (`YYYY-MM-DD`) para datas de negócio? |
| Dinheiro | Centavos em inteiro ou decimal? Como trafega na API? |
| Enums | Enum nativo do banco, texto com validação ou tabela de referência? |
| Nomes no JSON | `camelCase` nos corpos de request e response? |
| Telefones, documentos e outros formatos | Formato de armazenamento (ex.: telefone em E.164)? |
