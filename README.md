<div align="center">

# 🤖 BIA - Bootcamp de Infraestrutura AWS

**B**ootcamp de **I**nfraestrutura **A**WS

*Projeto didático para o módulo de Agentes de IA e Multi-Agentes da Formação AWS*

[![Version](https://img.shields.io/badge/version-4.2.0-blue.svg?style=for-the-badge)](https://github.com/henrylle/bia)
[![Node](https://img.shields.io/badge/node-%3E%3D18.0.0-brightgreen.svg?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org)
[![Docker](https://img.shields.io/badge/docker-enabled-2496ED.svg?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![AWS](https://img.shields.io/badge/AWS-ECS%20%7C%20RDS%20%7C%20ECR-orange.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![License](https://img.shields.io/badge/license-ISC-green.svg?style=for-the-badge)](LICENSE)

[Começar](#-começando) •
[Documentação](#-documentação-adicional) •
[API](#-api-endpoints) •
[Deploy](#-deploy-na-aws) •
[Contribuir](#-contribuindo)

</div>

---

## 📚 Sobre o Projeto

**BIA** é uma aplicação full-stack desenvolvida como base prática para o módulo de **Agentes de IA e Multi-Agentes** da **Formação AWS**. O projeto demonstra a integração de tecnologias modernas de frontend e backend com infraestrutura AWS, seguindo boas práticas de DevOps e arquitetura cloud-native.

<div align="center">

### ✨ Destaques

</div>

<table>
<tr>
<td width="50%">

**🎯 Objetivos Pedagógicos**
- Aplicação full-stack containerizada
- Deploy em AWS ECS
- CI/CD com CodePipeline
- Infraestrutura como código
- Workflow multi-agente IA

</td>
<td width="50%">

**🚀 Tecnologias Core**
- React 18 + Vite
- Node.js + Express
- PostgreSQL + Sequelize
- Docker + Docker Compose
- AWS Cloud Services

</td>
</tr>
</table>

---

## 🏗️ Arquitetura

### Stack Tecnológico

#### Backend
- **Runtime:** Node.js (v18+)
- **Framework:** Express.js 4.17
- **Database:** PostgreSQL 17.1 com Sequelize ORM
- **AWS SDK:** Integração com Secrets Manager e STS

#### Frontend
- **Framework:** React 18.3
- **Build Tool:** Vite 5.4
- **Styling:** Tailwind CSS 4.3
- **Bibliotecas:** React Router, Recharts, Lucide Icons

#### Infraestrutura
- **Containerização:** Docker + Docker Compose
- **Cloud Provider:** AWS (ECS, RDS, ECR, CodePipeline)
- **CI/CD:** AWS CodeBuild + GitHub Actions

---

## 🚀 Começando

### Pré-requisitos

- **Node.js** >= 18.0.0
- **Docker** e **Docker Compose**
- **Git**
- **AWS CLI** (para deploy em produção)
- **curl** (para health checks)

### 📦 Instalação

#### 1. Clone o repositório

```bash
git clone https://github.com/henrylle/bia.git
cd bia
```

#### 2. Instale as dependências

```bash
# Backend
npm install

# Frontend
cd client
npm install
cd ..
```

#### 3. Configure as variáveis de ambiente

O arquivo `compose.yml` já está configurado para desenvolvimento local com valores padrão.

---

## 🐳 Executando com Docker

### Iniciar a aplicação completa

```bash
docker compose up -d
```

Isso irá iniciar:
- **Backend:** http://localhost:3001
- **Database:** PostgreSQL na porta 5433
- **Frontend:** Servido pelo backend na porta 3001

### Rebuild da aplicação

```bash
docker compose down
docker compose build server
docker compose up -d
```

### Verificar logs

```bash
docker compose logs -f server
```

### Parar a aplicação

```bash
docker compose down
```

---

## 🔍 Health Check

Verifique se a aplicação está funcionando:

```bash
curl -s http://localhost:3001/api/versao
```

Resposta esperada:
```json
{
  "versao": "4.2.0"
}
```

---

## 📁 Estrutura do Projeto

```
bia/
├── .github/              # GitHub Actions workflows
├── .kiro/                # Sistema multi-agente
│   ├── agents/           # Configuração dos agentes (PO, Dev, DevOps, QA)
│   ├── docs/             # Documentação do worktree workflow
│   ├── rules/            # Regras de infraestrutura, Dockerfile e pipeline
│   ├── tasks/            # Gerenciamento de tarefas
│   └── worktrees/        # Worktrees isolados por feature
├── api/                  # Backend API
│   ├── controllers/      # Lógica de controle
│   ├── routes/           # Definição de rotas
│   ├── models/           # Modelos do Sequelize
│   └── data/             # Dados mockados
├── client/               # Frontend React
│   ├── src/
│   │   ├── components/   # Componentes React
│   │   ├── styles/       # Estilos CSS
│   │   └── lib/          # Utilitários
│   └── public/           # Assets estáticos
├── config/               # Configurações da aplicação
├── database/             # Migrations do Sequelize
├── docs/                 # Documentação adicional
├── scripts/              # Scripts auxiliares
├── tests/                # Testes unitários
├── buildspec.yml         # AWS CodeBuild configuration
├── compose.yml           # Docker Compose configuration
├── Dockerfile            # Container image definition
└── server.js             # Entry point da aplicação
```

---

## 🛠️ Sistema Multi-Agente

O projeto BIA utiliza um sistema de gerenciamento de tarefas através de **agentes de IA**:

### Agentes Disponíveis

| Agente | Responsabilidade |
|--------|------------------|
| **PO** | Criação de tasks, revisão e abertura de PRs |
| **Dev** | Implementação de features (frontend e backend) |
| **DevOps** | Infraestrutura, pipeline e deploy |
| **QA** | Garantia de qualidade e testes |

### Workflow de Worktree

O projeto adota o padrão **feature/branch com worktrees isolados**:

1. Cada task possui seu próprio branch e worktree
2. Todos os branches derivam de `ia-main`
3. Worktrees ficam em `.kiro/worktrees/`
4. Tasks são gerenciadas em `.kiro/tasks/` (todo → doing → done)

Para mais detalhes, consulte:
- [Worktree Workflow](.kiro/docs/worktree-workflow.md)
- [Worktree Steering](.kiro/docs/worktree-steering.md)

---

## 🏗️ Deploy na AWS

### Infraestrutura

O projeto utiliza:
- **ECS Cluster** com instâncias EC2 (t3.micro)
- **RDS PostgreSQL** (t3.micro)
- **ECR** para registry de imagens
- **CodePipeline** + **CodeBuild** para CI/CD

### Nomenclatura de Recursos

Todos os recursos seguem o prefixo `bia`:

```
cluster-bia           # ECS Cluster (sem ALB)
cluster-bia-alb       # ECS Cluster (com ALB)
task-def-bia          # Task Definition
service-bia           # ECS Service
bia-db                # Security Group do RDS
bia-web               # Security Group do EC2 (sem ALB)
bia-ec2               # Security Group do EC2 (com ALB)
bia-alb               # Security Group do ALB
```

### Script de Deploy

```bash
./deploy-ecs.sh
```

Para regras detalhadas de infraestrutura, consulte:
- [Regras de Infraestrutura](.kiro/rules/infraestrutura.md)
- [Regras de Pipeline](.kiro/rules/pipeline.md)

---

## 🧪 Testes

### Executar testes unitários

```bash
npm test
```

### Estrutura de Testes

```
tests/
└── unit/
    └── controllers/
```

---

## 📝 API Endpoints

### Versão
```
GET /api/versao
```

### Tarefas
```
GET    /api/tarefas       # Listar todas as tarefas
GET    /api/tarefas/:id   # Buscar tarefa por ID
POST   /api/tarefas       # Criar nova tarefa
PUT    /api/tarefas/:id   # Atualizar tarefa
DELETE /api/tarefas/:id   # Deletar tarefa
```

### Health Check
```
GET /api/ping
```

---

## 🤝 Contribuindo

Este é um projeto didático. Para contribuir:

1. Crie uma task seguindo o template em `.kiro/docs/task-template-with-worktree.md`
2. Siga o workflow de worktree documentado
3. Implemente seguindo as regras em `.kiro/rules/`
4. Abra PR contra `ia-main`

---

## 📖 Documentação Adicional

- [Arquitetura AWS ECS](docs/architecture/aws-ecs-diagram.html)
- [Regras de Dockerfile](.kiro/rules/dockerfile.md)
- [Task Template](.kiro/docs/task-template-with-worktree.md)

---

## 📧 Suporte

Para dúvidas sobre o curso:
- Acesse a **área de membros** da Formação AWS
- Utilize o **app do aluno** para acompanhamento

---

## 📄 Licença

Este projeto está sob a licença ISC. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 🎓 Sobre a Formação AWS

**Curso:** Formação AWS  
**Módulo:** Agentes de IA e Multi Agentic  
**Versão do Projeto:** 4.2.0

---

<div align="center">
  <sub>Desenvolvido com ❤️ para fins educacionais</sub>
</div>

