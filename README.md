# BIA — Formação AWS

Projeto base do módulo **Agentes de IA e Multi-Agentes** da Formação AWS.

## Sobre o projeto

A BIA é uma aplicação de gerenciamento de tarefas usada como base prática ao longo dos módulos da Formação AWS. O objetivo é evoluir a infraestrutura e os recursos AWS progressivamente, acompanhando o conteúdo do curso.

## Stack

| Camada | Tecnologia |
|--------|-----------|
| Frontend | React + Vite |
| Backend | Node.js + Express |
| Banco de dados | MySQL (via Sequelize) |
| Cache | Redis (ElastiCache) |
| Orquestração local | Docker Compose |
| Automação | n8n |

## Pré-requisitos

- Docker e Docker Compose instalados
- Node.js 18+
- Conta AWS configurada (para os módulos de infraestrutura)

## Rodando localmente

**Unix/macOS:**
```bash
./rodar_app_local_unix.sh
```

**Windows:**
```bash
rodar_app_local_windows.bat
```

Ou manualmente:
```bash
docker compose up -d
```

A aplicação sobe em `http://localhost:3000`.

## Migrations

```bash
docker compose exec server bash -c 'npx sequelize db:migrate'
```

## Estrutura do projeto

```
bia/
├── api/
│   ├── controllers/    # Lógica de negócio
│   ├── models/         # Models Sequelize
│   └── routes/         # Definição das rotas
├── client/             # Frontend React + Vite
├── config/             # Configurações Express e banco
├── database/
│   └── migrations/     # Migrations Sequelize
├── docs/               # Documentação e diagramas de arquitetura
├── lib/                # Módulos utilitários (cache, boot)
├── n8n/                # Configurações do n8n
├── scripts/            # Scripts de infraestrutura AWS
│   └── ecs/            # Scripts específicos para ECS
└── tests/              # Testes unitários
```

## Scripts úteis

| Script | Descrição |
|--------|-----------|
| `scripts/ligar_bia_local.sh` | Sobe a aplicação local |
| `scripts/parar_bia_local.sh` | Para a aplicação local |
| `scripts/insert-tarefas-massa.sh` | Insere tarefas em massa para testes |
| `scripts/delete-all-tarefas.sh` | Remove todas as tarefas |
| `generate-sts-token.sh` | Gera token STS para acesso AWS |

## Módulo atual

> **Formação AWS — Agentes de IA e Multi-Agentes**  
> Acompanhe o curso pela área de membros e app do aluno.
