# 🗺️ Análise de Arquitetura — Projeto BIA

> **Gerado em:** 27/08/2026
> **Objetivo:** servir de material de estudo para entender o que é cada peça do projeto, o porquê dela existir, e como tudo se conecta — escrito na perspectiva de quem vem de Ciência de Dados e está aprendendo Dev/DevOps/AWS.

---

## 1. O que é o projeto BIA, em uma frase

Uma aplicação web full-stack de **gerenciamento de tarefas** ("task tracker"): um frontend em React (Vite) conversa com uma API em Node.js/Express, que lê e grava dados num banco PostgreSQL via Sequelize (ORM). Tudo empacotado em Docker para rodar igual em qualquer máquina, com scripts prontos para deploy em ECS na AWS.

Pense nele como o equivalente a um projeto de dados que tem: uma camada de coleta/API, uma camada de armazenamento (banco), e uma camada de visualização (frontend) — só que aqui a "visualização" é uma interface web interativa, não um notebook.

---

## 2. Estrutura real do projeto (corrigindo o que o script genérico não viu)

O script `analise_project_bia.sh` foi escrito assumindo um projeto **Create React App clássico**, com frontend solto na raiz (`src/App.js`) e deploy manual via S3. O projeto BIA evoluiu para um layout diferente — por isso o script acusou "⚠️ não encontrado" em coisas que na verdade existem, só que em outro lugar:

| O script procurava | Onde realmente está | O que é |
|---|---|---|
| `src/App.js` na raiz | `client/src/App.jsx` | Frontend é **Vite + React**, não CRA, e vive dentro de `client/` |
| `.env.example` | não existe; config vem de `config/default.json` + variáveis de ambiente | Configuração usa o pacote `config`, não dotenv |
| `build-and-deploy.sh` (deploy manual p/ S3) | `deploy-ecs.sh` + `buildspec.yml` | Deploy é para **ECS** (containers), não S3 estático |

**Por quê isso importa para você estudar:** scripts de análise genéricos (ou tutoriais genéricos) partem de suposições sobre "como todo projeto React é organizado". Projetos reais divergem. O hábito de DevOps aqui é: **sempre verificar contra os arquivos de configuração reais** (`package.json`, `Dockerfile`, `compose.yml`) em vez de confiar em um padrão assumido.

### Árvore real (resumida)

```
bia/
├── Dockerfile                 → empacota API + build do frontend numa imagem
├── compose.yml                → orquestra API + banco Postgres localmente
├── server.js                  → ponto de entrada do backend
├── index.js
├── config/
│   ├── default.json           → porta da API (8080)
│   ├── express.js             → monta o app Express, serve o frontend buildado
│   └── database.js            → conexão com Postgres (local ou via Secrets Manager)
├── api/
│   ├── routes/                → define os endpoints (/api/tarefas, /api/versao, /ping)
│   ├── controllers/           → lógica de cada endpoint
│   └── models/                → modelos Sequelize
├── database/
│   └── migrations/            → histórico de mudanças no schema do banco
├── client/                    → FRONTEND (Vite + React), projeto próprio
│   ├── package.json           → dependências React (não é o package.json da API!)
│   ├── vite.config.js
│   └── src/
│       ├── App.jsx            → componente raiz da interface
│       ├── components/
│       ├── contexts/
│       └── lib/
├── deploy-ecs.sh              → script de deploy para AWS ECS
├── buildspec.yml              → pipeline de build (AWS CodeBuild)
├── scripts/                   → utilitários AWS (EC2, SSM, IAM roles, etc.)
└── rodar_app_local_unix.sh    → "receita" oficial para rodar localmente
```

**Ponto-chave:** existem **dois `package.json` diferentes** — um na raiz (backend) e um em `client/` (frontend). São dois projetos Node independentes, empacotados juntos. Isso é comum em monorepos simples: cada pasta tem seu próprio conjunto de dependências e scripts (`npm run build --prefix client` roda o build *dentro* de `client/` a partir da raiz).

---

## 3. As três camadas, explicadas

```
┌──────────────────────────────────────────────────────────────────┐
│  CAMADA 1 — FRONTEND (client/)                                   │
│  Tecnologia: React + Vite                                        │
│  O que faz: interface visual (listar/criar/editar tarefas)       │
│  Onde roda: no navegador do usuário                              │
│  Como chega lá: Express serve os arquivos estáticos buildados    │
│                  (client/build) direto da API — não precisa de   │
│                  servidor web separado nem de S3 para rodar local│
├──────────────────────────────────────────────────────────────────┤
│  CAMADA 2 — BACKEND (api/, server.js, config/)                   │
│  Tecnologia: Node.js + Express                                   │
│  O que faz: expõe endpoints REST (ex: GET/POST /api/tarefas),    │
│              valida dados, fala com o banco via Sequelize        │
│  Onde roda: container Docker (local) ou ECS (produção)           │
│  Porta: 8080 dentro do container                                 │
├──────────────────────────────────────────────────────────────────┤
│  CAMADA 3 — BANCO DE DADOS (database/migrations/)                │
│  Tecnologia: PostgreSQL                                          │
│  O que faz: guarda as tarefas de forma persistente                │
│  Onde roda: container Docker local ("database" no compose.yml)   │
│              ou RDS/Secrets Manager em produção na AWS            │
└──────────────────────────────────────────────────────────────────┘
```

### Como uma requisição percorre essas camadas (exemplo real do código)

1. No navegador, o React (`client/src`) faz uma chamada `fetch`/`axios` para `/api/tarefas`.
2. O Express (`api/routes/tarefas.js`) recebe em `app.route("/api/tarefas").get(...)`.
3. A rota chama o **controller** (`api/controllers/tarefas.js`), que contém a lógica.
4. O controller usa o **model** Sequelize (`api/models/tarefas.js`) para consultar o Postgres.
5. `config/database.js` decide **como conectar**: se `DB_HOST` for `database`/`127.0.0.1`/`localhost` → conexão local direta; caso contrário (produção) → busca credenciais no **AWS Secrets Manager** e usa SSL. Essa é uma técnica comum: o mesmo código se adapta ao ambiente (local vs. nuvem) olhando variáveis de ambiente, sem precisar de branches de código separados.
6. Resposta volta em JSON, o React atualiza a tela.

---

## 4. Docker: o que cada arquivo faz e por quê

### `Dockerfile` — "receita" de como empacotar tudo numa imagem
```dockerfile
FROM public.ecr.aws/docker/library/node:22-slim   # imagem base: Node 22 enxuto
COPY package*.json ./  &&  RUN npm install         # instala deps do BACKEND primeiro
COPY client/package*.json ./client/  &&  RUN ...   # instala deps do FRONTEND
COPY . .                                           # copia todo o código
RUN cd client && npm run build                     # builda o React em arquivos estáticos
EXPOSE 8080
CMD [ "npm", "start" ]                              # ao rodar o container: node server
```
**Por que fazer nessa ordem (deps antes do código completo)?** Aproveita o *cache de camadas* do Docker: se o código muda mas as dependências não, o Docker não reinstala tudo do zero — só reconstrói a partir da linha que mudou. Isso acelera builds repetidos, algo bem análogo a cachear resultados intermediários num pipeline de dados.

### `compose.yml` — orquestra API + banco juntos, localmente
```yaml
services:
  server:      # a API, buildada a partir do Dockerfile acima, porta 3001 (host) → 8080 (container)
  database:    # Postgres oficial, porta 5433 (host) → 5432 (container)
```
Com `docker compose up`, você sobe **os dois containers já conectados na mesma rede virtual** — o backend enxerga o banco pelo hostname `database`, sem precisar descobrir IP.

---

## 5. Deploy na AWS: ECS, não S3

O README genérico do script mencionava S3 + EC2, mas o projeto real usa **ECS (Elastic Container Service)** — o serviço da AWS para rodar containers Docker em produção sem gerenciar servidores manualmente.

- **`buildspec.yml`** → instruções para o **AWS CodeBuild** (serviço de CI) construir a imagem Docker automaticamente a partir do código.
- **`deploy-ecs.sh`** → script manual que builda a imagem, envia pro **ECR** (registro de imagens Docker da AWS, tipo um "Docker Hub privado"), e atualiza o serviço no ECS — com versionamento por commit hash, permitindo rollback fácil.
- **`config/database.js`** já está preparado para produção: se a variável `DB_SECRET_NAME` estiver definida, busca usuário/senha do banco no **AWS Secrets Manager** em vez de usar credenciais fixas no código — prática de segurança padrão (nunca commitar senha em texto puro).

**Analogia para Ciência de Dados:** ECS + ECR está para "rodar seu container em produção" assim como um scheduler (Airflow, cron gerenciado) está para "rodar seu script de ETL". Você empacota o ambiente (Docker), aponta pra AWS, e ela cuida de manter o processo rodando, reiniciar se cair, escalar se precisar.

---

## 6. Como rodar o projeto localmente (passo a passo confirmado no código)

Esta é a sequência oficial, já existente em `rodar_app_local_unix.sh`:

```bash
cd bia

# 1. Sobe só o banco Postgres em container
docker compose up -d database

# 2. Instala dependências do backend (raiz)
npm install --loglevel=error

# 3. Builda o frontend Vite (gera client/build)
npm run build --prefix client --loglevel=error

# 4. Aplica as migrations no banco (cria as tabelas)
npx sequelize db:migrate

# 5. Sobe a API — que também passa a servir o frontend buildado
npm start
```

➡️ Aplicação completa acessível em **http://localhost:8080**.

### Alternativa 100% containerizada
```bash
docker compose up -d
```
Sobe API + banco juntos (API acessível em `http://localhost:3001`, mapeada para a porta 8080 do container).

### Modo desenvolvimento (hot-reload no frontend)
```bash
docker compose up -d database
npm install && npx sequelize db:migrate
npm start &                       # API na 8080
cd client && npm install && npm run dev   # Vite dev server, porta própria (5173)
```

---

## 7. Checklist real do projeto (corrigido)

| Componente | Status | Observação |
|---|---|---|
| Dockerfile | ✅ | Builda backend + frontend numa imagem só |
| compose.yml | ✅ | Orquestra API + Postgres local |
| server.js / api/ | ✅ | Backend Express completo, com rotas, controllers e models |
| client/ (React+Vite) | ✅ | Frontend completo — só não está onde o script genérico esperava |
| database/migrations | ✅ | Versionamento de schema via Sequelize |
| Deploy AWS | ✅ | Via ECS/ECR (`deploy-ecs.sh`, `buildspec.yml`), não S3 |
| Secrets Manager | ✅ | `config/database.js` já integrado, ativa via `DB_SECRET_NAME` |
| `.env.example` | ❌ | Não existe — config é via `config/default.json` + env vars |

---

## 8. Glossário rápido (AWS/DevOps → linguagem de dados)

| Termo | O que é | Analogia |
|---|---|---|
| **Docker** | Empacota código + dependências + SO mínimo numa unidade portátil | Como um `requirements.txt` + ambiente virtual, mas incluindo o "sistema operacional" também |
| **Docker Compose** | Orquestra múltiplos containers que precisam conversar entre si | Como um `docker-compose` de um pipeline com vários serviços (ex: API + banco + cache) |
| **ECR** | Registro privado de imagens Docker na AWS | Um "repositório git", mas para imagens de container em vez de código |
| **ECS** | Serviço que roda e gerencia containers em produção | Um scheduler gerenciado (tipo Airflow-as-a-service, mas para containers genéricos) |
| **Secrets Manager** | Armazena senhas/credenciais de forma segura, fora do código | Como usar variáveis de ambiente/vault em vez de hardcodar senha no notebook |
| **Sequelize** | ORM (Object-Relational Mapper) para Node.js falar com SQL | Análogo ao SQLAlchemy em Python |
| **Migrations** | Scripts versionados que alteram o schema do banco de forma controlada | Como versionar transformações de schema em vez de alterar tabelas manualmente |
| **CodeBuild (buildspec.yml)** | Serviço de CI da AWS que builda a imagem automaticamente a partir do código | Um "runner de CI" (tipo GitHub Actions), hospedado na AWS |

---

## 9. Por onde continuar estudando

1. Leia `api/routes/tarefas.js` → `api/controllers/tarefas.js` → `api/models/tarefas.js`, nessa ordem — é o caminho completo de uma requisição, do endpoint até o banco.
2. Leia `config/database.js` para entender a técnica de "mesma configuração, comportamento diferente por ambiente" (padrão muito comum em apps que rodam local + nuvem).
3. Explore `client/src/App.jsx` e a pasta `client/src/components/` para ver como o frontend consome a API.
4. Quando tiver mais familiaridade com Docker, leia `deploy-ecs.sh` de ponta a ponta — ele documenta na prática o ciclo build → push ECR → deploy ECS → rollback.

---

*Documento gerado automaticamente a partir da análise do código-fonte do projeto, cruzando o output do script `analise_project_bia.sh` com os arquivos reais (`package.json`, `Dockerfile`, `compose.yml`, `config/*.js`, `api/*`) para corrigir suposições incorretas do script genérico.*
