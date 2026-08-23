# 🚀 BIA - Plataforma Educacional AWS

[![Version](https://img.shields.io/badge/version-4.3.0-blue.svg)](https://github.com/henrylle/bia)
[![Node](https://img.shields.io/badge/node-24.x-green.svg)](https://nodejs.org/)
[![React](https://img.shields.io/badge/react-17.0.2-61dafb.svg)](https://reactjs.org/)
[![License](https://img.shields.io/badge/license-ISC-orange.svg)](LICENSE)

> Projeto educacional para aprendizado prático de infraestrutura AWS com ECS, RDS, ALB e boas práticas de DevOps.

## 📋 Sobre o Projeto

BIA é uma aplicação full-stack desenvolvida para servir como base de aprendizado em eventos e treinamentos AWS. O projeto demonstra a implementação de uma arquitetura moderna utilizando serviços gerenciados da AWS, seguindo princípios de simplicidade para facilitar a compreensão de quem está iniciando na jornada cloud.

### 🎯 Objetivo

Fornecer uma estrutura educacional progressiva, permitindo que alunos evoluam desde cenários simples até situações mais complexas de infraestrutura cloud.

## 🏗️ Arquitetura

### Stack Tecnológica

**Frontend**
- React 17.0.2 com React Router DOM
- Vite como bundler e dev server
- React Icons para componentes visuais

**Backend**
- Node.js 24.x (LTS)
- Express 4.17.1
- Sequelize 6.6.5 (ORM)
- PostgreSQL 16.1

**Infraestrutura AWS**
- ECS (Elastic Container Service) com EC2
- RDS PostgreSQL (t3.micro)
- Application Load Balancer
- ECR (Elastic Container Registry)
- CodePipeline + CodeBuild para CI/CD
- Cloud Map para Service Discovery
- Redis (ioredis) para cache

**DevOps**
- Docker + Docker Compose
- AWS CLI v2
- Jest para testes

### 🎨 Cenários de Evolução

**Cenário 1:** Aplicação básica em ECS sem Load Balancer  
**Cenário 2:** Evolução com Application Load Balancer  
**Cenário 3:** Arquitetura completa com ALB + Cache (Redis) + Service Discovery

> 📖 Documentação completa da arquitetura em [docs/architecture](./docs/architecture)

## 🚀 Quick Start

### Pré-requisitos

- Docker e Docker Compose instalados
- Node.js 24.x ou superior
- Git

### Instalação Local

```bash
# Clone o repositório
git clone https://github.com/henrylle/bia.git
cd bia

# Inicie os containers
docker compose up -d

# Execute as migrations do banco de dados
docker compose exec server bash -c 'npx sequelize db:migrate'

# Acesse a aplicação
# Frontend: http://localhost:3000
# Backend: http://localhost:8080
```

### Variáveis de Ambiente

```env
# Database
DB_HOST=postgres
DB_PORT=5432
DB_NAME=bia_db
DB_USER=bia_user
DB_PASSWORD=bia_password

# Application
NODE_ENV=development
PORT=8080

# Frontend (Vite)
VITE_API_URL=http://localhost:8080
```

## 🧪 Testes

```bash
# Executar testes unitários
npm test

# Health check da API
curl http://localhost:8080/api/versao

# Testar rota com banco de dados
curl http://localhost:8080/api/tarefas
```

## 📦 Build e Deploy

### Build da Imagem Docker

```bash
# Build local
docker build -t bia-app .

# Tag para ECR
docker tag bia-app:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/bia:latest

# Push para ECR
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/bia:latest
```

### Deploy via Pipeline

O projeto possui pipeline automatizado configurado com AWS CodePipeline + CodeBuild:

1. Push para branch principal
2. Trigger automático do pipeline
3. Build da imagem Docker (buildspec.yml)
4. Push para ECR
5. Deploy automático para ECS

## 📚 Comandos Úteis

```bash
# Migrations
npx sequelize db:migrate              # Executar migrations
npx sequelize db:migrate:undo         # Reverter última migration
npx sequelize db:seed:all             # Executar seeds

# Docker
docker compose up -d                   # Subir containers
docker compose down                    # Parar containers
docker compose logs -f server         # Ver logs do servidor
docker compose exec server bash       # Acessar container

# Desenvolvimento
npm start                             # Iniciar servidor
npm run start_db                      # Inicializar banco
npm test                              # Executar testes
```

## 🎓 Evento Imersão AWS & IA

**Período:** 01/08 e 02/08/2026  
**Horário:** 9h30 às 17h30 (Online e ao Vivo)

[**>> Página de Inscrição do Evento**](https://org.imersaoaws.com.br/github/readme)

Durante o evento, você irá:
- ✅ Configurar infraestrutura AWS do zero
- ✅ Implementar CI/CD com CodePipeline
- ✅ Deploy automatizado em ECS
- ✅ Monitoramento e troubleshooting
- ✅ Boas práticas de segurança e escalabilidade

## 🤝 Contribuindo

Este é um projeto educacional aberto a contribuições. Sinta-se à vontade para:
- Reportar bugs via [Issues](https://github.com/henrylle/bia/issues)
- Sugerir melhorias
- Enviar Pull Requests

## 📝 Licença

Este projeto está sob a licença ISC. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 👤 Autor

**Henrylle Maia**  
GitHub: [@henryllemaia](https://github.com/henryllemaia)

---

⭐ Se este projeto foi útil para você, considere dar uma estrela no GitHub!

