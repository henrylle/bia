# MCPs dos agentes do BIA — o que cada um faz e teste de carga (31/08/2026)

> Guia de referência: quais MCP servers o time de agentes (`po`/`dev`/`devops`/
> `qa`/`security-reviewer`) usa, pra que serve cada um, e o resultado do teste
> de conectividade feito nesta sessão. Complementa
> [`docs/panorama-agentes-e-worktrees.md`](./panorama-agentes-e-worktrees.md)
> (que explica o fluxo de trabalho entre agentes) — aqui o foco é só a camada
> de ferramentas MCP.

## 0. Onde isso é configurado

Os MCP servers do projeto ficam em [`.mcp.json`](../.mcp.json), na raiz do
repo (não em `~/.claude` — são específicos do bia, não globais da conta).
São só três:

```json
{
  "mcpServers": {
    "aws-mcp": { "command": "uvx", "args": ["mcp-proxy-for-aws@latest", ...] },
    "shadcn":  { "command": "npx",  "args": ["-y", "shadcn@latest", "mcp"] },
    "playwright": { "command": "npx", "args": ["-y", "@playwright/mcp@latest", ...] }
  }
}
```

Cada agente em `.claude/agents/*.md` declara no front-matter `tools:` só o
subconjunto de ferramentas MCP que faz sentido pro seu papel — é assim que
`dev` não consegue chamar `aws-mcp` e `qa` não consegue chamar `shadcn`, por
exemplo. A tabela abaixo cruza os três servers com quem tem acesso a cada um.

| MCP server | Agente(s) com acesso | Não tem acesso |
|---|---|---|
| `shadcn` | `dev` | `po`, `devops`, `qa`, `security-reviewer` |
| `playwright` | `qa` | `po`, `dev`, `devops`, `security-reviewer` |
| `aws-mcp` | `devops`, `security-reviewer` | `po`, `dev`, `qa` |

`po` não tem nenhum MCP — só `Read`/`Write`/`Bash`/`Glob`/`Grep`, e mesmo
assim com `Write`/`Bash` restritos (ver `.claude/agents/po.md`).

> Outros MCPs que aparecem disponíveis nesta sessão do Claude Code (Gmail,
> Google Calendar, Google Drive, Context7, Excalidraw, `ide`) são da **conta
> do usuário**, não do projeto bia — não estão em `.mcp.json` e nenhum agente
> do time (`po`/`dev`/`devops`/`qa`/`security-reviewer`) tem acesso a eles.

## 1. `shadcn` — biblioteca de componentes de UI (agente `dev`)

**Pra que serve**: o frontend (`client/`) usa React + Tailwind com padrão
shadcn/ui (componentes copiados pro repo, não uma lib instalada via npm). O
MCP `shadcn` dá ao `dev` acesso direto ao registry oficial — buscar
componentes, ver exemplos de uso e gerar o comando `npx shadcn add` certo —
sem precisar abrir o navegador ou adivinhar a API do componente.

**Ferramentas expostas pro `dev`** (7): `get_project_registries`,
`list_items_in_registries`, `search_items_in_registries`,
`view_items_in_registries`, `get_item_examples_from_registries`,
`get_add_command_for_items`, `get_audit_checklist`.

**Fluxo típico**: `search_items_in_registries` (achar o componente) →
`view_items_in_registries` (ver o código-fonte) →
`get_item_examples_from_registries` (ver exemplo de uso) →
`get_add_command_for_items` (gerar o `npx shadcn add ...` pra rodar).

**Teste de carga (31/08/2026)**:
- `get_project_registries` → respondeu sem erro. Retornou lista vazia porque
  **o repo não tem `components.json`** na raiz nem em `client/` — isso é uma
  característica do projeto (client não foi inicializado via CLI do shadcn),
  não uma falha do MCP.
- `list_items_in_registries(["@shadcn"])` → **471 itens** retornados do
  registry oficial (`accordion`, `alert`, `alert-dialog`, ...). Confirma que
  a conexão de rede do MCP (via `npx shadcn@latest mcp`) está OK.
- **Conclusão: MCP `shadcn` operante.** O único ponto de atenção é que sem
  `components.json`, comandos que dependem de config local (ex.
  `get_add_command_for_items` apontando pro estilo do projeto) podem pedir
  pra rodar `shadcn init` primeiro — não é um bug do MCP, é o projeto não ter
  esse arquivo.

## 2. `playwright` — automação de navegador (agente `qa`)

**Pra que serve**: o `qa` valida os critérios de aceite de uma task **ponta
a ponta, no navegador real** (não só teste de API) — navega pelas telas do
`client/` (`localhost:5173` ou via nginx do container), clica, preenche
formulário, confere o que apareceu na tela. O MCP `playwright` controla um
Chromium headless para isso.

**Ferramentas expostas pro `qa`** (22): navegação (`browser_navigate`,
`browser_navigate_back`, `browser_tabs`), inspeção
(`browser_snapshot` — árvore de acessibilidade, preferível a screenshot;
`browser_take_screenshot`, `browser_console_messages`,
`browser_network_requests`/`browser_network_request`), interação
(`browser_click`, `browser_type`, `browser_fill_form`, `browser_select_option`,
`browser_hover`, `browser_drag`/`browser_drop`, `browser_press_key`,
`browser_file_upload`, `browser_handle_dialog`), utilitários (`browser_find`,
`browser_wait_for`, `browser_resize`, `browser_run_code_unsafe`,
`browser_evaluate`, `browser_close`).

**Teste de carga (31/08/2026)**: `browser_navigate` para `https://example.com`
→ Chromium abriu, página carregou (`Page Title: Example Domain`), snapshot
gerado com sucesso; `browser_close` encerrou a aba sem erro.
**Conclusão: MCP `playwright` operante**, browser local (`--executable-path`
apontando pro Chromium instalado em `~/.cache/ms-playwright/`) sobe e navega
normalmente no WSL.

## 3. `aws-mcp` — consulta à conta AWS (agentes `devops` e `security-reviewer`)

**Pra que serve**: dá acesso **somente leitura** aos recursos reais da conta
AWS (`878919573366`, perfil `formacaoaws`, região `us-east-1`) — cluster ECS,
task definitions, security groups, roles IAM, etc. — sem que o agente precise
(ou consiga) alterar nada. Repare em `.claude/agents/devops.md` e
`security-reviewer.md` que `Write`/`Edit`/`Bash` ficam de fora de propósito:
o acesso de escrita à infra é feito manualmente pelo usuário via `scripts/`,
nunca por um agente.

**Ferramentas expostas** (7, iguais para os dois agentes):
`call_aws` (chamada genérica equivalente à AWS CLI), `run_script` (script
Python com `boto3` pra consultas multi-chamada/análise), `get_tasks`
(acompanha chamadas assíncronas longas), `get_regional_availability`,
`get_presigned_url`, `list_regions`, `read_documentation`/
`search_documentation`/`retrieve_skill` (docs oficiais da AWS).

**Diferença entre os dois agentes**: mesmo MCP, escopo de uso diferente —
`devops` usa pra troubleshooting geral de arquitetura/pipeline/deploy;
`security-reviewer` usa só pra confirmar o estado real de uma role/policy/SG
antes de opinar sobre um script em `scripts/` (ver `.claude/agents/
security-reviewer.md`).

**Teste de carga (31/08/2026)**, via agente `devops`:
- `sts get-caller-identity` → `arn:aws:iam::878919573366:user/fabio-admin`,
  sem erro de token expirado (essa mesma sessão tinha token expirado mais
  cedo hoje — foi corrigido com reautenticação manual no navegador, ver
  `.remember/now.md`).
- `ecs list-clusters --region us-east-1` → retornou
  `arn:aws:ecs:us-east-1:878919573366:cluster/cluster-bia`, confirmando
  região e acesso de leitura funcionais.
- **Conclusão: MCP `aws-mcp` operante**, sessão válida.

## 4. Resumo do teste (31/08/2026)

| MCP | Chamada de teste | Resultado |
|---|---|---|
| `shadcn` | `list_items_in_registries(["@shadcn"])` | ✅ 471 itens retornados |
| `playwright` | `browser_navigate("https://example.com")` + `browser_close` | ✅ navegou, snapshot ok, fechou sem erro |
| `aws-mcp` | `sts get-caller-identity` + `ecs list-clusters` | ✅ identidade válida, cluster `cluster-bia` retornado |

Os três MCPs configurados em `.mcp.json` estão operantes. Se algum voltar a
falhar, o padrão de diagnóstico é: (1) checar se o comando (`npx`/`uvx`)
resolve no PATH da shell não-interativa — ver
[`node-mcp-nao-interativo-wsl` na memória] sobre o WSL cair no Node do `apt`
fora de shell interativa; (2) pra `aws-mcp`, checar se o perfil
`formacaoaws` está com sessão válida (`aws sts get-caller-identity` local).
