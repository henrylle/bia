# Plugins do Claude Code, mapa do repo e correção de MCP — 31/08/2026

> Registro do que foi instalado/gerado/corrigido numa sessão de setup do
> Claude Code, pra não precisar re-descobrir o "porquê" depois. Não é uma
> task do fluxo `.kiro/tasks/` (não é feature de app) — é housekeeping de
> ferramental.

## 0. Contexto

Cinco plugins de usuário (`~/.claude`, valem pra qualquer projeto, não só o
bia) foram instalados: `remember`, `cartographer`, `headroom`,
`claude-code-setup` e, mais tarde nesta sessão, `commit-commands`.
`gitkraken-hooks` já estava instalado desde 11/06/2026 (não é "recente").

| Plugin | O que faz | Por que ajuda no bia |
|---|---|---|
| `remember` | Salva estado/decisões entre sessões em `.remember/` e injeta de volta no início da próxima | Continuidade entre sessões do time de agentes (po/dev/devops/qa) sem re-explicar contexto |
| `cartographer` | Mapeia o repo com subagentes em paralelo e gera `docs/CODEBASE_MAP.md` | Onboarding rápido — ver seção 1 |
| `headroom` | Camada de compressão de contexto (MCP) — reduz tokens de saídas grandes/repetitivas (JSON, logs) | Chamadas via `aws-mcp` e saídas de build/log tendem a ser verbosas |
| `claude-code-setup` | Skill que analisa o repo e recomenda hooks/subagentes/skills/MCPs específicos | Gerou as recomendações da seção 2 |
| `commit-commands` | Comandos `/commit`, `/commit-push-pr`, `/clean_gone` | Encaixa no agente `po`, que já tem `Bash` restrito a git/gh |

## 1. Mapa do codebase (`docs/CODEBASE_MAP.md` + `CLAUDE.md`)

Gerado pelo `cartographer`: 4 subagentes Sonnet leram o repo em paralelo
(app code, infra/scripts, `docs/`, config de agentes) e o resultado foi
sintetizado em [`docs/CODEBASE_MAP.md`](./CODEBASE_MAP.md) — arquitetura,
guia de módulos, fluxos de dados (Mermaid), convenções e uma lista de
gotchas/código morto encontrados (ex.: `index.js`/`lib/boot.js` legado,
`api/routes/ping.js` nunca montado, dois theming systems em paralelo no
CSS do client, campo `concluida` que só existe no client). `CLAUDE.md` foi
criado na raiz com o resumo + link pro mapa (não existia antes).

**Vale re-rodar** quando o repo mudar bastante — o cartographer detecta se
o mapa já existe e atualiza só o que precisa.

## 2. Recomendações de automação e o que foi implementado

O `claude-code-setup` sugeriu automações em 5 categorias. **Combinado
explícito**: nada que mexe em `api/`/`client/` (isso fica pras aulas de
AWS — o propósito do projeto). Do que sobrou (tooling de workflow/infra),
3 foram implementados:

- **[`.claude/agents/security-reviewer.md`](../.claude/agents/security-reviewer.md)**
  — subagente somente-leitura focado em IAM/Security Groups/segredos nos
  scripts de infra (`scripts/`, `.kiro/rules/infraestrutura.md`).
  Complementa o `devops` (que é consultivo/arquitetura geral) com uma
  lente específica de segurança — sempre calibrada pela filosofia de
  simplicidade do projeto (não sugere Secrets Manager/Multi-AZ como
  "correção", já que a regra do projeto exclui isso de propósito).
- **[`.claude/skills/worktree-task-cycle/SKILL.md`](../.claude/skills/worktree-task-cycle/SKILL.md)**
  — consolida os comandos do ciclo de vida de task (início → finalização
  pelo agent → encerramento pelo PO → cleanup pós-merge) que hoje estão
  duplicados quase verbatim em 4 lugares (`po/especificacao.md`,
  `worktree-steering.md`, `worktree-workflow.md`,
  `task-template-with-worktree.md`). Essas 4 fontes continuam sendo a
  referência conceitual; a skill é só a "cola" executável.
- **Plugin `commit-commands`** instalado (`claude plugin install
  commit-commands@claude-plugins-official`) — dá `/commit`,
  `/commit-push-pr`, `/clean_gone`.

Recomendações que ficaram **de fora de propósito** (envolviam mexer em
`api/`/`client/` ou automatizar o próprio ciclo de dev): hook de rebuild
automático após edição de backend, skill `gen-test`. Podem ser retomadas
mais pra frente, fora do período de aulas.

## 3. Bug de ambiente: MCPs `playwright`/`shadcn` não conectavam no WSL

**Sintoma**: `playwright` e `shadcn` (configurados em `.mcp.json`)
apareciam como `CONNECTION_CLOSED` ao iniciar a sessão.

**Causa raiz**: `~/.bashrc` tem o guard padrão de shell não-interativa
(`case $- in *i*) ;; *) return;; esac` no topo), então `nvm.sh` só
carrega em shell **interativa**. Os subprocessos `npx` que o Claude Code
sobe pra rodar MCP servers são não-interativos — caem no Node do `apt`
(`/usr/bin/node`, v18.19.1), que é velho demais:
- `@playwright/mcp` recusa explicitamente: *"Playwright requires Node.js
  20 or higher"*.
- `shadcn mcp` quebra com `ReferenceError: File is not defined` (a
  dependência `undici` espera o global `File`, só existe por padrão a
  partir do Node 20).

**Correção aplicada** (não exige sudo, não mexe no pacote `nodejs` do
apt): `/home/fabiolima/.local/bin` vem *antes* de `/usr/local/bin` e
`/usr/bin` no `$PATH`, inclusive em shell não-interativa, e é gravável
sem privilégio. Criei symlinks lá apontando pro Node gerenciado pelo nvm:

```bash
ln -sf ~/.nvm/versions/node/v22.23.2/bin/{node,npm,npx,corepack} ~/.local/bin/
```

Depois disso, `bash -c 'node --version'` (shell não-interativa, igual ao
que o Claude Code usa pra subir MCP servers) já resolve pra v22.23.2 sem
precisar de `source ~/.bashrc`.

**Se acontecer de novo** (ambiente WSL novo/reinstalado, ou os symlinks
sumirem): rodar `bash -c 'node --version'` — se cair pra v18, recriar os
symlinks com o comando acima. **A sessão do Claude Code precisa
reiniciar (ou reconectar MCP) depois da correção** — o processo do MCP
server que já subiu com o Node velho não se corrige sozinho.

Detalhe registrado como memória persistente do Claude Code (não fica só
neste doc): `~/.claude/projects/.../memory/node-mcp-nao-interativo-wsl.md`.

## 4. Nota: mudanças em `.kiro/agents/*.json` não são desta sessão

Durante o commit deste trabalho, `.kiro/agents/{dev,devops,po,qa}.json`
apareceram modificados (mais arquivos `.bak`) sem que eu tivesse tocado
neles. Causa: o **Kiro CLI rodando em paralelo em outro terminal**
(`kiro-cli --v3 --agent po`) normaliza/reescreve esses arquivos de config
ao carregar um agente. Ficaram de fora deste commit — são um processo
separado, não relacionado ao trabalho documentado aqui.
