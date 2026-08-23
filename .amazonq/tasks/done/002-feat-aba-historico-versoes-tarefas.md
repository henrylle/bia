# 002-feat-aba-historico-versoes-tarefas

## Descrição

Criar uma aba de "Histórico de Versões" na tela principal do sistema BIA, que exiba a lista de versões de cada tarefa adicionada pelo usuário via interface.

Atualmente, a tela principal (`/`) exibe as tarefas cadastradas sem nenhum registro histórico das versões criadas. A proposta é adicionar uma nova aba abaixo do formulário `AddTask`, ao lado da lista de tarefas atual, que centralize o histórico de todas as versões registradas.

Cada vez que o usuário adiciona uma tarefa via `POST /api/tarefas`, o sistema deve gravar automaticamente um registro na tabela `tarefa_versoes`, capturando o `titulo`, `dia_atividade`, `importante` e o `uuid` da tarefa de origem. Dessa forma, o histórico reflete exatamente o que o usuário submeteu pela interface.

A funcionalidade exige:
- Uma nova tabela `tarefa_versoes` no banco de dados (migration Sequelize)
- Registro automático de versão no backend ao criar uma tarefa
- Um endpoint para listar todas as versões registradas
- Um novo componente React `HistoricoVersoes.jsx` com a aba na tela principal

**Contexto técnico:**
- Frontend: React 17 com React Router DOM e Vite
- Backend: Express com Sequelize e PostgreSQL
- PK da tabela `Tarefas`: `uuid` (tipo UUID) — a FK em `tarefa_versoes` deve referenciar `uuid`
- Campos da tarefa: `titulo`, `dia_atividade`, `importante` (ver `api/models/tarefas.js`)
- Migration de referência: `database/migrations/20210924000838-criar-tarefas.js`
- Rotas de referência: `api/routes/tarefas.js`
- Controller de referência: `api/controllers/tarefas.js` (ponto de inserção: método `create`)
- Componente de integração: `client/src/components/Tasks.jsx` e `client/src/App.jsx`
- Padrão de nome de migration: timestamp + descrição (ex: `20260822120000-criar-tarefa-versoes.js`)

## Critérios de aceitação

- [x] Existe uma migration Sequelize que cria a tabela `tarefa_versoes` com os campos: `id` (PK inteiro auto-incremento), `tarefa_uuid` (FK referenciando `Tarefas.uuid`), `titulo`, `dia_atividade`, `importante`, `versao` (inteiro sequencial por tarefa), `createdAt`, `updatedAt`
- [x] O método `create` do controller de tarefas (`api/controllers/tarefas.js`) registra automaticamente uma entrada em `tarefa_versoes` após criar a tarefa com sucesso
- [x] Existe um endpoint `GET /api/tarefas/versoes` que retorna todas as versões registradas, ordenadas da mais recente para a mais antiga
- [x] Existe um novo componente `HistoricoVersoes.jsx` em `client/src/components/`
- [x] O componente `HistoricoVersoes.jsx` é exibido na tela principal (`/`), como uma aba ou seção separada da lista de tarefas
- [x] A aba exibe uma lista com: número da versão, título da tarefa, data/prazo (`dia_atividade`) e data/hora do registro (`createdAt`)
- [x] A lista é exibida em ordem cronológica decrescente (versão mais recente no topo)
- [x] Quando não há versões registradas, o componente exibe uma mensagem informativa (ex: "Nenhuma versão registrada ainda")
- [x] O componente busca os dados automaticamente ao ser montado e atualiza a lista após cada nova tarefa adicionada
- [x] A implementação segue o padrão visual (CSS) dos demais componentes do projeto
- [x] A migration pode ser executada com `npx sequelize db:migrate` sem erros
