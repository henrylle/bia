## Codebase Overview

BIA ("Backend de Integração AWS") is a task-tracker teaching project: an Express/PostgreSQL API (`server.js` → `config/express.js` → `api/routes` → `api/controllers` → `api/models`) with a React 18 + Vite frontend (`client/`), deployed to AWS ECS via CodeBuild/CodePipeline. The repo also hosts the tooling used to develop it — a multi-agent Claude Code / Kiro CLI team (po/dev/devops/qa, defined in `.claude/agents/` and `.kiro/agents/`) working through git-worktree-isolated tasks in `.kiro/tasks/` — plus a large `docs/` folder of AWS-learning notes.

**Stack**: Node/Express + Sequelize/PostgreSQL, React 18 + Vite + Tailwind (shadcn/ui-style), Docker/Compose, AWS ECS/ECR/CodePipeline.
**Structure**: `api/` (backend) + `client/` (frontend) + `scripts/` (AWS infra automation) + `.kiro/`/`.claude/` (multi-agent dev workflow) + `docs/` (architecture & learning notes).

For detailed architecture, module guide, data flow diagrams, conventions, and known gotchas, see [docs/CODEBASE_MAP.md](docs/CODEBASE_MAP.md).
