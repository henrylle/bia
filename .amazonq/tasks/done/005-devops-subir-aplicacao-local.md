# 005-devops-subir-aplicacao-local

## Descrição

Subir a aplicação BIA localmente usando Docker Compose, garantindo que todos os serviços estejam rodando corretamente (backend, frontend e banco de dados PostgreSQL), executar as migrations e validar os health checks.

## Critérios de aceitação

- [x] Executar `docker compose up -d` e confirmar que todos os containers sobem sem erro
- [x] Executar as migrations com `docker compose exec server bash -c 'npx sequelize db:migrate'`
- [x] Validar que o backend responde em `http://localhost:3001/api/versao` (porta 3001 conforme compose.yml)
- [x] Validar que o endpoint `http://localhost:3001/api/tarefas` retorna dados (conectividade com o banco)
- [x] Confirmar que o frontend está acessível em `http://localhost:3001`
- [x] Reportar o status de todos os containers (`docker compose ps`)

## Contexto técnico

- Arquivo de orquestração: `compose.yml` na raiz do projeto
- Health check principal: `GET /api/versao` (não depende de banco)
- Health check com banco: `GET /api/tarefas`
- Frontend: React + Vite em `client/`
- Backend: Node.js + Express em `server.js`
- Banco: PostgreSQL 16
