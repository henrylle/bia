# 🔄 Recriando o Time de Agentes (PO/Dev/DevOps/QA) no Claude Code

> **Objetivo:** repetir o mesmo processo do slide `desafio_labs_agents.pdf` (time de
> 4 agentes: `po`, `dev`, `devops`, `qa`, cada um com prompt, MCP e permissões
> próprias) — só que rodando em **Claude Code** em vez do **Kiro CLI**.
>
> O fluxo de trabalho (tasks numeradas, `doing/`, `done/`, worktrees isolados por
> branch) **não muda em nada** — ele é feito de arquivos Markdown e comandos git,
> não depende de qual ferramenta de IA está sendo usada. O que muda é só **como
> cada agente é definido e como ele roda**.

---

## 1. Mapa de conceitos: Kiro CLI → Claude Code

Antes de mexer em arquivo, é importante saber o que corresponde a quê. É a mesma
ideia com um formato de arquivo e um vocabulário diferentes:

| Conceito | No Kiro CLI | No Claude Code |
|---|---|---|
| Onde o agente é definido | `.kiro/agents/NOME.json` | `.claude/agents/NOME.md` (frontmatter YAML + prompt em Markdown) |
| "Persona" / system prompt | campo `"prompt"` no JSON | corpo do arquivo `.md`, depois do frontmatter |
| Quais ferramentas ele pode usar | `"tools"` + `"allowedTools"` + `"permissions.rules"` | campo `tools:` no frontmatter (lista simples de nomes) |
| Qual modelo de LLM usar | `"model": "claude-sonnet-4.5"` | campo `model:` no frontmatter (`sonnet`, `opus`, `haiku`; se omitir, herda o modelo da sessão principal) |
| Plugins externos (MCP) | `"mcpServers": {...}` dentro do próprio agente | `.mcp.json` na raiz do projeto (compartilhado — já existe e já tem o `aws-mcp` configurado) |
| Arquivos que o agente já lê de cara | `"resources": [...]` (carregado automaticamente) | não existe carregamento automático — o prompt do agente precisa **instruir** ele a ler os arquivos (ex.: "leia `.kiro/rules/*.md` antes de começar") |
| Como você "vira" aquele agente | `kiro-cli --agent po` (sessão inteira assume a persona) | você pede pro Claude Code **delegar** para o subagente (ele roda isolado e reporta de volta) — ver seção 5 |
| Onde ficam as regras compartilhadas | `.kiro/rules/*.md` | **continuam no mesmo lugar** — `.kiro/rules/*.md`. A pasta `.kiro/` não precisa ser renomeada; hoje ela só guarda convenções em Markdown, não tem nada específico do Kiro CLI nelas |
| Onde ficam as tasks e worktrees | `.kiro/tasks/`, `.kiro/worktrees/` | **continuam exatamente iguais** — é só git + Markdown |

**Ponto-chave:** você não está migrando o *processo*, só o *motor* que roda cada
papel. `.kiro/tasks/sequencial.md`, `.kiro/tasks/doing/`, `.kiro/tasks/done/`,
`.kiro/rules/*.md` e o fluxo de worktree continuam sendo a fonte da verdade.

---

## 2. Diferença importante de arquitetura (leia antes de configurar)

No Kiro CLI, cada agente é uma **sessão de CLI inteira** rodando com aquela
persona — você abre o terminal já "sendo" o `po`.

No Claude Code, subagentes (`.claude/agents/*.md`) são definidos para serem
**chamados por uma sessão principal**, que delega a tarefa, espera o subagente
terminar (ele roda isolado, sem poluir o contexto principal) e recebe o
resultado de volta. Ou seja: você continua com uma sessão só de Claude Code
aberta, e pede pra ela **"use o subagente po para criar a task tal"** — não
existe um `claude --agent po` que troque a sessão inteira de persona.

Na prática isso funciona bem para o seu fluxo (PO cria task → dev implementa →
qa valida → po fecha), porque é exatamente um padrão de **delegação
sequencial** — só muda o verbo: em vez de "abrir uma nova sessão como X", você
"pede pra sessão atual usar o subagente X".

---

## 3. Passo 1 — Completar o `.mcp.json` com os MCP que faltam

Hoje o `.mcp.json` da raiz já tem o `aws-mcp` (usado pelo `devops`). Faltam o
`shadcn` (usado pelo `dev`) e o `playwright` (usado pelo `qa`) — são os mesmos
pacotes que o Kiro já usa, então é só registrar:

```json
{
  "mcpServers": {
    "aws-mcp": {
      "command": "uvx",
      "args": [
        "mcp-proxy-for-aws@latest",
        "https://aws-mcp.us-east-1.api.aws/mcp",
        "--metadata",
        "AWS_REGION=us-east-1"
      ],
      "env": { "AWS_PROFILE": "formacaoaws" }
    },
    "shadcn": {
      "command": "npx",
      "args": ["-y", "shadcn@latest", "mcp"]
    },
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

Depois de editar, rode `/mcp` dentro do Claude Code (ou `claude mcp list`) pra
confirmar que os três servidores aparecem conectados. **Anote os nomes exatos
das ferramentas** que cada um expõe (aparecem como `mcp__shadcn__...` e
`mcp__playwright__...`) — você vai usá-los no passo 4, no campo `tools:` de
cada subagente.

> O `aws-mcp` já expõe (conferido nesta sessão): `mcp__aws-mcp__aws___call_aws`,
> `mcp__aws-mcp__aws___run_script`, `mcp__aws-mcp__aws___get_presigned_url`,
> `mcp__aws-mcp__aws___get_regional_availability`, `mcp__aws-mcp__aws___get_tasks`,
> `mcp__aws-mcp__aws___list_regions`, `mcp__aws-mcp__aws___read_documentation`,
> `mcp__aws-mcp__aws___retrieve_skill`, `mcp__aws-mcp__aws___search_documentation`.

---

## 4. Passo 2 — Criar os 4 subagentes em `.claude/agents/`

Crie a pasta `.claude/agents/` com um arquivo `.md` por agente. Formato do
frontmatter: `name`, `description` (usada pro Claude decidir quando chamar o
subagente sozinho), `tools` (lista separada por vírgula — **omitir o campo
libera todas as ferramentas**, então para os agentes restritos é obrigatório
listar explicitamente) e `model` (opcional).

### `.claude/agents/po.md`

```markdown
---
name: po
description: Product Owner do projeto BIA. Use para criar, priorizar, revisar e encerrar tasks em .kiro/tasks/, e para abrir Pull Requests. Não implementa código de aplicação.
tools: Read, Write, Bash, Glob, Grep
model: sonnet
---

Você é um Product Owner (PO) experiente, parte do time de desenvolvimento do
projeto BIA (Node/Express no backend, React no frontend). Você define e
prioriza tarefas de desenvolvimento, escreve histórias de usuário claras e dá
o aceite final antes do merge.

**Você NÃO escreve código de aplicação (`api/`, `client/`) — só arquivos
dentro de `.kiro/**`.**

Antes de agir, leia:
- `.kiro/agents/po/especificacao.md` (formato de task e fluxo de worktree obrigatório)
- `.kiro/rules/*.md` (regras de infraestrutura, Dockerfile e pipeline)
- `.kiro/tasks/sequencial.md` (próximo número de task)

Sua ferramenta de escrita (`Write`) deve ser usada **apenas** dentro de
`.kiro/**`. Seu uso do `Bash` deve se limitar a:
`git add`, `git commit`, `git push`, `git checkout`, `git status`, `git branch`,
`git log`, `git worktree`, `gh pr create`, `cd`, `pwd`, `ls`, `mv`.
Nunca rode `npm`, `docker`, `sequelize` ou qualquer comando que altere código
ou infraestrutura — isso é trabalho do `dev`/`devops`.

Siga sempre o formato `[NNN]-[tipo]-[resumo].md` e o workflow de worktree
descrito em `.kiro/agents/po/especificacao.md`.
```

### `.claude/agents/dev.md`

```markdown
---
name: dev
description: Desenvolvedor full-stack (Node/Express + React) do projeto BIA. Use para implementar tasks criadas pelo PO — tanto backend quanto frontend.
tools: Read, Write, Edit, Bash, Glob, Grep, mcp__shadcn__<preencher após rodar /mcp>
model: sonnet
---

Você é um desenvolvedor de software especializado em Backend (Node) e
Frontend (React), responsável por implementar as tasks especificadas pelo PO
em `.kiro/tasks/doing/`. Traduza histórias de usuário em código funcional,
seguindo as boas práticas do projeto.

Antes de implementar, leia:
- `.kiro/rules/*.md`
- A task em `.kiro/tasks/doing/NNN-tipo-resumo.md`

Regras obrigatórias:
- Vá marcando o checklist da task conforme cada etapa é concluída.
- **Ao terminar a implementação, você DEVE rodar o rebuild completo antes de
  avisar que terminou:**
  1. `docker compose down`
  2. `docker compose build server`
  3. `docker compose up -d`
  4. `curl -s http://localhost:3001/api/versao` (confirmar que respondeu)
- Ao final, sinalize qual é o próximo agente a entrar (normalmente `qa`).
```

### `.claude/agents/devops.md`

```markdown
---
name: devops
description: Especialista em infraestrutura AWS do projeto BIA (ECS em EC2, pipeline). Use para consultar recursos reais na conta AWS, revisar Dockerfile/pipeline, ou investigar problemas de deploy. Somente leitura — nunca cria/altera infraestrutura.
tools: Read, Glob, Grep, mcp__aws-mcp__aws___call_aws, mcp__aws-mcp__aws___run_script, mcp__aws-mcp__aws___get_tasks, mcp__aws-mcp__aws___get_regional_availability, mcp__aws-mcp__aws___get_presigned_url, mcp__aws-mcp__aws___list_regions, mcp__aws-mcp__aws___read_documentation, mcp__aws-mcp__aws___retrieve_skill, mcp__aws-mcp__aws___search_documentation
model: sonnet
---

Você é o especialista em infraestrutura AWS do time do projeto BIA. Seu papel
é **consultivo e somente leitura** — você não altera código de aplicação nem
infraestrutura diretamente (repare que `Write`, `Edit` e `Bash` não estão na
sua lista de ferramentas — isso é proposital).

Escopo:
- Consultar recursos reais na conta `formacaoaws` (região `us-east-1`) via
  `aws-mcp` para responder dúvidas, investigar problemas e validar arquitetura.
- Revisar Dockerfiles, pipeline (CodePipeline/CodeBuild/ECR/ECS) e desenho de
  infraestrutura seguindo `.kiro/rules/infraestrutura.md`,
  `.kiro/rules/dockerfile.md` e `.kiro/rules/pipeline.md`.
- Fazer troubleshooting quando acionado por outro agente ou pelo usuário.

Reporte suas conclusões para quem te acionou — você não atualiza arquivos de
task nem faz commit.
```

### `.claude/agents/qa.md`

```markdown
---
name: qa
description: QA do projeto BIA. Use para validar, ponta a ponta via navegador, se a implementação do dev atende aos critérios de aceite de uma task antes do aceite final do PO.
tools: Read, Glob, Grep, mcp__playwright__<preencher após rodar /mcp>
model: sonnet
---

Você valida, ponta a ponta, o que o `dev` implementou antes do `po` dar o
aceite final. Você **não escreve código** — só valida (repare que `Write`,
`Edit` e `Bash` não estão na sua lista de ferramentas).

Fluxo:
1. Leia os critérios de aceite em `.kiro/tasks/doing/NNN-tipo-resumo.md`.
2. Valide o health check da aplicação em `/api/versao`.
3. Use o Playwright para testar os fluxos de UI descritos na task.
4. Se tudo passar, sinalize para o `po` que a task está **aprovada em QA**.
5. Se algo falhar, sinalize para o `dev` com passos claros pra reproduzir.
```

> ⚠️ Substitua `mcp__shadcn__<preencher...>` e `mcp__playwright__<preencher...>`
> pelos nomes reais das ferramentas assim que rodar `/mcp` (passo 3). Enquanto
> não preencher, deixe só `Read, Write, Edit, Bash, Glob, Grep` (dev) ou
> `Read, Glob, Grep` (qa) que o subagente já funciona — só não vai ter acesso
> ao MCP específico ainda.

---

## 5. Passo 3 — Como usar o time no dia a dia

Com os arquivos acima em `.claude/agents/`, o Claude Code passa a "ver" os 4
subagentes automaticamente (rode `/agents` pra confirmar que aparecem
listados). Duas formas de acioná-los:

**a) Automático** — se seu pedido bater com a `description` de um agente, o
Claude Code pode delegar sozinho. Ex.: pedir "crie uma task para adicionar um
filtro de tarefas por prioridade" tende a acionar o `po` sozinho.

**b) Explícito (mais previsível para reproduzir o processo do slide)** —
peça diretamente:
```
Use o subagente po para criar uma nova task: "adicionar filtro de tarefas por prioridade".
```
```
Use o subagente dev para implementar a task 009 que está em .kiro/tasks/doing/.
```
```
Use o subagente qa para validar a task 009 no worktree .kiro/worktrees/009-feat-.../
```

O restante do processo — mover a task para `doing/`, criar o worktree com
`git worktree add .kiro/worktrees/NNN-... -b feature/NNN-... ia-main`, abrir o
PR com `gh pr create --base ia-main` — é **idêntico** ao que já está descrito
em `.kiro/agents/po/especificacao.md` e `docs/panorama-agentes-e-worktrees.md`.
Não precisa reescrever nada disso; os subagentes novos foram instruídos a ler
esses mesmos arquivos.

---

## 6. Diferenças honestas em relação ao Kiro CLI

| Aspecto | Kiro CLI | Claude Code | Impacto |
|---|---|---|---|
| Restrição fina de comandos shell (ex.: `po` só pode `git commit`, nunca `npm`) | `permissions.rules` com `match` por comando, `effect: allow/deny` | `tools:` só libera/bloqueia a categoria `Bash` inteira, não comando a comando | Para `po` e `dev`, a restrição de **quais** comandos rodar vira uma instrução no prompt (soft), não uma trava técnica (hard). Para `devops` e `qa` isso não importa, porque `Bash` nem está na lista de ferramentas deles — trava técnica real. |
| Restrição de **onde** escrever (`po` só em `.kiro/**`) | `toolsSettings.write.allowedPaths` | Não existe campo equivalente no frontmatter do subagente | Vira instrução no prompt (soft). Se quiser trava técnica real, dá pra criar um hook `PreToolUse` no `.claude/settings.json` que barra `Write`/`Edit` fora de `.kiro/**` — mas isso é complexidade extra que o projeto (regra "simplicidade acima de complexidade") provavelmente não precisa para um ambiente de treino. |
| "Resources" carregados automaticamente | Sim, via `resources: [...]` | Não — o subagente só lê o que o prompt manda ele ler | Já resolvido nos arquivos acima: cada prompt instrui explicitamente quais `.md` ler primeiro. |
| Modo de invocar a persona | Sessão de CLI inteira dedicada | Delegação a partir de uma sessão principal | Muda o hábito de uso, não o resultado — ver seção 2 e 5. |
| Garantia de "somente leitura" na AWS (`devops`) | Depende do `aws-mcp` + permissões do perfil `formacaoaws` | Idêntico — mesmo `aws-mcp`, mesmo `.mcp.json` | **Importante:** a garantia real de "não consigo alterar infra" vem do **IAM do perfil `formacaoaws`** (se ele só tem `Describe*`/`List*`/`Get*`), não da lista de ferramentas do agente — isso vale igualmente para Kiro e Claude Code. Vale confirmar isso na conta AWS, não só confiar na config local. |

---

## 7. Checklist rápido de setup

- [ ] Adicionar `shadcn` e `playwright` ao `.mcp.json` (passo 1)
- [ ] Rodar `/mcp` e anotar os nomes reais das tools do `shadcn`/`playwright`
- [ ] Criar `.claude/agents/po.md`, `dev.md`, `devops.md`, `qa.md` (passo 2)
- [ ] Preencher os nomes de tools MCP nos campos `tools:` de `dev.md` e `qa.md`
- [ ] Rodar `/agents` e confirmar que os 4 aparecem listados
- [ ] Testar o fluxo ponta a ponta com uma task pequena (ex.: pedir pro `po`
      criar uma task de teste, depois pedir pro `dev` implementar)

## 📚 Referências
- [Panorama de Agentes e Worktrees](./panorama-agentes-e-worktrees.md) — o processo original (Kiro CLI), que este documento adapta
- `.kiro/agents/po/especificacao.md` — formato de task e workflow de worktree (continua valendo)
- `.kiro/rules/*.md` — regras compartilhadas (infraestrutura, Dockerfile, pipeline)
- `desafio_labs_agents.pdf` — slide original do módulo do curso que inspirou este time de agentes
