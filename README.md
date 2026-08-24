# BIA — Plataforma Educacional AWS

[![Version](https://img.shields.io/badge/version-4.3.0-blue.svg)](https://github.com/henrylle/bia)
[![Node](https://img.shields.io/badge/node-24.x-green.svg)](https://nodejs.org/)
[![React](https://img.shields.io/badge/react-18.x-61dafb.svg)](https://reactjs.org/)
[![License](https://img.shields.io/badge/license-ISC-orange.svg)](LICENSE)

Projeto educacional para aprendizado prático de infraestrutura AWS com ECS, RDS, ALB e boas práticas de DevOps.

---

## Sobre o Projeto

BIA é uma aplicação full-stack criada por [Henrylle Maia](https://github.com/henryllemaia) para servir de base nos eventos e treinamentos da **Formação AWS**. O projeto foi concebido em 2021 e vem evoluindo com as melhores práticas da AWS, seguindo um princípio central: **simplicidade progressiva** — começar fácil e evoluir gradualmente.

---

## Cenários de Evolução

| Cenário | Descrição |
|---------|-----------|
| **1** | Aplicação em ECS sem Load Balancer |
| **2** | Evolução com Application Load Balancer |
| **3** | Arquitetura completa — ALB + Cache (Redis) + Service Discovery |

> Documentação completa de cada cenário em [docs/architecture](./docs/architecture)

---

## Stack

**Frontend**
- React 18 com React Router DOM 6
- Vite 5 como bundler e dev server
- React Icons 5

**Backend**
- Node.js 24.x (LTS)
- Express 4.17
- Sequelize 6.6 (ORM) + PostgreSQL 16
- ioredis para cache (Redis)

**Infraestrutura AWS**
- ECS com EC2 (cluster gerenciado)
- RDS PostgreSQL (t3.micro)
- Application Load Balancer
- ECR para registry de imagens
- CodePipeline + CodeBuild (CI/CD)
- Cloud Map para Service Discovery

**DevOps**
- Docker + Docker Compose
- AWS CLI v2
- Jest para testes unitários

---

## Quick Start

**Pré-requisitos:** Docker, Docker Compose e Git instalados.

```bash
# Clone o repositório
git clone https://github.com/henrylle/bia.git
cd bia

# Suba os containers
docker compose up -d

# Execute as migrations
docker compose exec server bash -c 'npx sequelize db:migrate'
```

Acesse:
- Frontend → http://localhost:3000
- Backend → http://localhost:8080

### Variáveis de Ambiente

```env
# Banco de dados
DB_HOST=postgres
DB_PORT=5432
DB_NAME=bia_db
DB_USER=bia_user
DB_PASSWORD=bia_password

# Aplicação
NODE_ENV=development
PORT=8080

# Frontend (Vite)
VITE_API_URL=http://localhost:8080
```

---

## Testes e Health Check

```bash
# Testes unitários
npm test

# Health check (sem banco)
curl http://localhost:8080/api/versao

# Rota com banco de dados
curl http://localhost:8080/api/tarefas
```

---

## Build e Deploy

### Imagem Docker

```bash
docker build -t bia-app .

docker tag bia-app:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/bia:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/bia:latest
```

### Pipeline (CodePipeline + CodeBuild)

1. Push para a branch principal
2. Pipeline disparado automaticamente
3. Build da imagem Docker via `buildspec.yml`
4. Push da imagem para o ECR
5. Deploy rolling update no ECS

---

## Comandos Úteis

```bash
# Banco de dados
npx sequelize db:migrate          # Aplicar migrations
npx sequelize db:migrate:undo     # Reverter última migration
npx sequelize db:seed:all         # Executar seeds

# Docker
docker compose up -d              # Subir containers
docker compose down               # Parar containers
docker compose logs -f server     # Acompanhar logs do servidor
docker compose exec server bash   # Acessar o container

# Desenvolvimento
npm start                         # Iniciar servidor
npm run start_db                  # Inicializar banco
npm test                          # Executar testes
```

---

## Evento — Imersão AWS & IA

**01 e 02 de agosto de 2026 · 9h30 às 17h30 · Online e ao Vivo**

[**Garanta sua vaga →**](https://org.imersaoaws.com.br/github/readme)

Durante o evento você vai:
- Configurar infraestrutura AWS do zero
- Implementar CI/CD com CodePipeline
- Fazer deploy automatizado em ECS
- Aplicar boas práticas de segurança e escalabilidade

---

## Contribuindo

Projeto educacional aberto a contribuições:
- Bugs → [Issues](https://github.com/henrylle/bia/issues)
- Melhorias → Pull Requests são bem-vindos

## Licença

ISC — veja [LICENSE](LICENSE) para detalhes.

## Autor

**Henrylle Maia** · [@henryllemaia](https://github.com/henryllemaia)

---

⭐ Se este projeto foi útil, deixe uma estrela no GitHub!
