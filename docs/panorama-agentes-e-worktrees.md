# 🧭 Panorama: Time de Agentes de IA e Worktrees — Projeto BIA

> Este documento é uma introdução para quem está vendo o projeto pela primeira vez.
> Ele explica **o que é um worktree**, **como uma task percorre o projeto** e
> **o que cada agente de IA (kiro-cli) faz**. Para os detalhes técnicos completos,
> veja os pointers na seção [Para saber mais](#para-saber-mais).

---

## 1. O que é um Git Worktree (e por que usamos)

Normalmente, um repositório Git só permite estar em **um branch por vez** — trocar de
branch (`git checkout`) troca os arquivos na sua pasta de trabalho.

Um **worktree** resolve isso: é uma segunda pasta, ligada ao mesmo repositório (mesmo
histórico, mesmos commits), mas com **seu próprio branch e seus próprios arquivos**
soltos ao lado. Ou seja, dá pra ter várias tasks sendo implementadas **em paralelo**,
cada uma isolada em sua própria pasta, sem uma atrapalhar a outra nem exigir stash/commit
temporário pra trocar de contexto.

No projeto BIA:

- Cada **task** ganha seu próprio worktree em `.kiro/worktrees/NNN-tipo-resumo/`
  (pasta ignorada pelo Git — cada worktree é local, temporário).
- O branch da task sempre parte de `ia-main` e segue o padrão
  `feature/NNN-tipo-resumo` (ou `fix/`, `test/`, conforme o tipo).
- Quando a task termina e o PR é mergeado, o worktree é removido.

```
bia/                              ← repositório principal (branch ia-main)
├── .kiro/
│   └── worktrees/                ← pasta ignorada pelo git, criada sob demanda
│       ├── 006-feat-calendario/  ← worktree da task 006 (branch feature/006-...)
│       └── 007-feat-grafico/     ← worktree da task 007 (branch feature/007-...)
├── client/
├── server/
└── ...
```

Hoje (neste snapshot do repositório) **não há worktrees ativos** — o backlog está
"limpo", sem task em andamento.

---

## 2. Como uma task percorre o projeto, do início ao fim

```
   PO cria a task              Agente assume a task           PR + merge
   ─────────────────           ──────────────────────         ─────────────
.kiro/tasks/                .kiro/tasks/doing/  →  worktree      ia-main
NNN-tipo-resumo.md    ─────►  NNN-tipo-resumo.md     isolado ─────► (PR aprovado)
(numeração sequencial                                 branch      .kiro/tasks/done/
 controlada por                                    feature/NNN-   NNN-tipo-resumo.md
 sequencial.md)                                        ...
```

1. **PO** escreve a task em `.kiro/tasks/NNN-tipo-resumo.md` (numeração sequencial
   controlada por `.kiro/tasks/sequencial.md`), já indicando **qual agente** deve
   executá-la (`dev`, `devops` ou `qa`).
2. O agente responsável confere se está em `ia-main`, atualiza (`git pull`), move a
   task para `.kiro/tasks/doing/` e cria o worktree isolado com o branch
   `feature/NNN-...` a partir de `ia-main`.
3. Dentro do worktree, o agente **implementa** a task, marcando os critérios de
   aceite conforme avança.
4. Ao concluir, o agente sinaliza qual é o **próximo agente** a entrar (ex.: `dev`
   termina e chama o `qa` pra validar; ou chama o `po` pra revisar e abrir o PR).
5. O **PO** dá o aceite final e abre o Pull Request de volta para `ia-main`.
6. Depois do merge, a task vai para `.kiro/tasks/done/` e o worktree é removido.

---

## 3. Quem é quem: os agentes

| Agente | Papel | Implementa código? | Ferramentas / MCP | Acesso |
|---|---|---|---|---|
| **po** | Product Owner | ❌ Não — só escreve os arquivos de task | — | Escreve apenas em `.kiro/**`; roda só comandos git/gh específicos (`add`, `commit`, `push`, `checkout`, `worktree`, `gh pr create`) |
| **dev** | Desenvolvedor Full-stack (Node + React) | ✅ **Sim — é quem implementa de fato** | `shadcn` (componentes de UI) | Leitura, escrita e shell liberados — precisa instalar dependências, buildar, testar |
| **devops** | Especialista em infraestrutura AWS | ❌ Não altera código; atua como consultor de infra | `aws-mcp` (proxy oficial AWS, conta `formacaoaws`, região `us-east-1`) | Somente leitura — consulta recursos reais na AWS, não escreve nem roda shell |
| **qa** | Qualidade / testes ponta a ponta | ❌ Não implementa — valida o que o `dev` fez | `playwright` (automação de navegador) | Somente leitura |
| **bia** *(legado)* | Agente genérico original, anterior à divisão em papéis | — | — | Praticamente histórico; o time hoje trabalha com os quatro agentes acima |

### Em outras palavras

- **`po`** é o "dono do produto": decide **o quê** fazer, escreve a especificação da
  task no formato `[NNN]-[tipo]-[resumo].md` e é quem dá o aceite final e abre o PR.
  Ele **não escreve código de aplicação** — só arquivos dentro de `.kiro/`.
- **`dev`** é **quem efetivamente implementa** as instruções da task — tanto backend
  (Node) quanto frontend (React). É o agente com mais liberdade de escrita/shell, e
  segue uma regra extra fixa (`.kiro/agents/dev/instrucoes.md`): ao terminar qualquer
  implementação, ele é obrigado a rodar o ciclo completo de rebuild dos containers
  (`docker compose down` → `build` → `up`) e confirmar que `/api/versao` responde,
  antes de avisar que a task está pronta.
- **`devops`** entra quando o assunto é infraestrutura AWS (ECS, EC2, pipeline) —
  consulta a conta real via MCP, mas de forma somente leitura, funcionando mais como
  analista/consultor do que como executor.
- **`qa`** garante qualidade, testando a aplicação no navegador via Playwright antes
  do aceite.
- **`bia`** é o agente genérico que existia antes da divisão do time — hoje é um
  resquício histórico da configuração original do projeto.

---

## 4. Regras que todos os agentes seguem

Além da definição de cada agente, há um conjunto de regras compartilhadas em
`.kiro/rules/`, lidas por praticamente todos os agentes:

- **`infraestrutura.md`** — arquitetura AWS do projeto (ECS em EC2, evolução com/sem
  ALB), convenção de nomes de recursos e Security Groups. Reforça a filosofia do
  projeto: **simplicidade acima de complexidade**, por ser um ambiente de formação.
- **`dockerfile.md`** — regras para qualquer Dockerfile do projeto: sempre
  single-stage, sem otimizações avançadas, sem usuário non-root, sempre validando o
  health check em `/api/versao`.
- **`pipeline.md`** — como funciona o pipeline de CI/CD (CodePipeline + CodeBuild →
  ECR → ECS), do source no GitHub até o deploy.

---

## Para saber mais

- **Fluxo de worktree em detalhe** (passo a passo técnico para os agentes):
  `.kiro/docs/worktree-steering.md`
- **Guia de worktree para humanos** (conceitos e exemplos):
  `.kiro/docs/worktree-workflow.md`
- **Template usado para criar novas tasks com worktree**:
  `.kiro/docs/task-template-with-worktree.md`
- **Diagrama visual da arquitetura de isolamento dos worktrees**:
  `.kiro/docs/worktree-architecture-diagram.md`
- **Especificação completa de como o PO cria as tasks**:
  `.kiro/agents/po/especificacao.md`
- **Backlog atual** (tasks pendentes e concluídas): `.kiro/tasks/`
