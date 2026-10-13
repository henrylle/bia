# 🔀 Mesmo Desafio, Dois Motores: Kiro CLI vs Claude Code

> **Ponto de partida:** o texto real do
> [post no LinkedIn](https://www.linkedin.com/feed/update/urn:li:share:7497789644806377472/)
> anunciando a entrega do Desafio Labs 3.0 (mentoria Henrylle Maia):
>
> > "Nesse desafio montei um time de agentes para atuar no fluxo de
> > desenvolvimento: um agente de PO, responsável por especificar as tasks e
> > manter o contexto do produto, e um agente de desenvolvimento, que
> > implementa. Trabalhei com o KIRO CLI e aprendi na prática o papel de
> > Tools, Resources e do invoke inline. Como exercício, implementei uma
> > feature inteira com o agente dev seguindo o modelo de feature branch, e
> > treinei o PO para descrever as características de cada nova task."
>
> Este documento registra o **paralelo real** — não hipotético — de replicar
> esse mesmo processo com **Claude Code**, focado nos três conceitos que o
> post nomeia (Tools, Resources, invoke inline), e tira as conclusões
> honestas de prós/contras a partir do que de fato aconteceu.

---

## 1. O que o desafio original cobriu (Kiro CLI)

| Elemento | Como estava no Kiro CLI |
|---|---|
| Agentes montados | só `po` (especifica tasks, mantém contexto do produto) e `dev` (implementa) — `qa` e `devops` vieram depois, numa prática posterior |
| Conceitos-chave aprendidos | **Tools** (o que o agente pode fazer), **Resources** (contexto carregado automaticamente) e **invoke inline** (chamar um agente a partir de outro sem trocar de sessão inteira) |
| Exercício prático | uma feature inteira implementada pelo `dev`, seguindo o modelo de feature-branch |
| Treino do PO | ensinar o `po` a descrever as características de cada task nova (ou seja, praticar o formato/qualidade da especificação, não só criar o arquivo) |

Isso é o núcleo do processo documentado em
[Panorama: Agentes e Worktrees](./panorama-agentes-e-worktrees.md). O time
de 4 agentes completo (`qa`+`devops` incluídos) é uma evolução posterior
desse mesmo projeto — tratada à parte na seção 3 abaixo, não como parte do
desafio original.

---

## 2. Os três conceitos do post, traduzidos pro Claude Code

| Conceito (nome usado na aula) | No Kiro CLI | No Claude Code | O que muda na prática |
|---|---|---|---|
| **Tools** | campo `tools` + `allowedTools` + `toolsSettings` + `permissions.rules` no JSON do agente — granularidade fina (ex.: `po` só escreve em `.kiro/**`, só roda uma lista fechada de comandos git/gh) | um campo só, `tools:`, no frontmatter do `.md` — lista simples, sem granularidade por pasta/comando | a trava de "só pode escrever aqui, só pode rodar esses comandos" deixa de ser imposta pelo sistema e vira instrução escrita no prompt (soft, não hard) — ver [Roteiro Prático, Módulo 5](./roteiro-pratico-agentes-claude-code.md#módulo-5--criando-o-agente-po) |
| **Resources** | campo `resources: [...]` — arquivos carregados automaticamente a cada sessão daquele agente | não existe campo equivalente — o prompt do subagente precisa **instruir explicitamente** "leia X antes de agir" | o comportamento final pode ser idêntico, mas a garantia muda de "o sistema sempre carrega" pra "o texto do prompt manda ler, e o modelo segue" |
| **Invoke inline** | chamar um agente a partir de outro **sem trocar de sessão inteira** (ex.: o `po` aciona o `dev` sem você precisar sair do terminal do `po` e abrir `--agent dev`) | pedir "use o subagente `dev` para..." dentro da mesma conversa da sessão principal — a sessão principal nunca "vira" outra persona, ela **delega e recebe de volta** | a ideia central (não precisar reabrir sessão pra trocar de papel) é a mesma; a diferença é que no Claude Code a sessão principal nunca desaparece — ela orquestra, os subagentes é que são temporários |

**Registrar o MCP** (parte do setup, mesmo que o post não cite MCP
explicitamente) também mudou de lugar: no Kiro, cada agente declarava seu
próprio `mcpServers` no JSON; no Claude Code, é um `.mcp.json` único na
raiz do projeto, compartilhado — qualquer subagente pode usar qualquer MCP
registrado ali, desde que liste as ferramentas certas no seu `tools:` (ver
[Migrar Time de Agentes](./migrar-time-agentes-para-claude-code.md#3-passo-1--completar-o-mcpjson-com-os-mcp-que-faltam)).

**Fricção real encontrada nesse setup:** o assistente interativo `/agents`
foi removido nesta versão do Claude Code — a verificação de que um
subagente foi carregado teve que mudar de "rode `/agents` e veja a lista"
pra "pergunte direto ou invoque o subagente e veja se ele responde com a
persona certa".

---

## 3. Onde este projeto foi além do desafio original

O post fala só de `po` + `dev`. Nesta sessão de estudo, o time foi
completado com `qa` e `devops`, e rodou um ciclo de verdade — task
`001-feat-contador-tasks-pendentes-concluidas` (`po` especifica, `dev`
implementa um contador de tasks pendentes/concluídas na Home, `qa` valida
ponta a ponta via Playwright). Não é parte do desafio que o post descreve,
mas é uma boa demonstração extra do padrão **Tools** aplicado a um papel
mais restrito:

O `qa` encontrou um bug de infraestrutura real, não do código — o worktree
sobe seu **próprio volume de Postgres** (Docker Compose deriva o nome do
volume do diretório onde roda, e o worktree fica em
`.kiro/worktrees/001-.../`, diferente da raiz), então o banco estava sem
migração (`relation "Tarefas" does not exist`). O `qa` diagnosticou
corretamente com um `curl` reproduzindo o erro, contornou com *network
mocking* no Playwright pra validar a lógica mesmo assim, e sinalizou o
bloqueio. Resolvido rodando `docker exec bia npx sequelize-cli db:migrate`
— confirmado com `curl http://localhost:3001/api/tarefas` voltando
`200 []`.

Esse achado é uma boa demonstração prática de **Tools** levado ao extremo
restrito: o `qa` não tinha `Bash` pra corrigir nada, mas tinha as
ferramentas certas pra **diagnosticar com precisão** e devolver pra quem
podia agir — exatamente o desenho descrito na seção 6 do documento de
migração.

---

## 4. Prós e contras — o que se confirmou na prática

| Aspecto | Kiro CLI | Claude Code | Veredito |
|---|---|---|---|
| **Trava de permissão** | `permissions.rules` + `toolsSettings` dão restrição técnica de fábrica (pasta, comando) | `tools:` é tudo-ou-nada por categoria; restrição fina vira texto no prompt (soft) | **Kiro ganha** — mais seguro por padrão, sem esforço extra |
| **Contexto automático** | `resources` carrega arquivos sozinho a cada sessão | precisa instruir explicitamente "leia X antes de agir" | **Kiro ganha** — menos chance do agente "esquecer" de ler uma regra |
| **Continuidade de sessão** | trocar de persona = fechar terminal, abrir outro com `--agent X` | mesma sessão delega pra vários subagentes em sequência, sem reabrir nada | **Claude Code ganha** — fluxo mais fluido pro padrão po→dev→qa→po |
| **Delegação automática** | sempre manual (`--agent X`) | Claude Code pode decidir sozinho, pela `description:` de cada subagente | **Claude Code ganha** — mais conveniente no dia a dia |
| **Dependência de fornecedor** | acoplado ao ciclo de vida do Kiro/Amazon Q (que já foi descontinuado e rebatizado uma vez neste mesmo projeto) | roda no motor Anthropic, não depende de decisão de roadmap da AWS | **Claude Code ganha** — risco de lock-in medido, não teórico |
| **Portabilidade do conhecimento** | sintaxe (`allowedTools`, `permissions.rules`) só existe no ecossistema Kiro/Q | MCP é protocolo aberto; `.claude/agents/*.md` é um padrão simples, replicável em qualquer projeto | **Claude Code ganha** — o aprendizado sai do curso com você |
| **Maturidade da interface de setup** | assistente de criação de agente disponível | `/agents` (wizard) foi removido na versão testada — criação é só editar `.md` ou pedir pro Claude escrever | **Kiro ligeiramente à frente** aqui, embora editar o `.md` direto não seja mais difícil |

**Conclusão honesta:** não existe um "vencedor" absoluto — existe uma troca
consciente. O Kiro CLI entrega **mais trava técnica de fábrica** (melhor
para um ambiente de treino, onde você quer errar com rede de segurança). O
Claude Code entrega **mais fluidez de sessão e menos risco de ficar refém
de um fornecedor só** — e essa segunda vantagem deixou de ser abstrata
quando o próprio Amazon Q Developer CLI foi descontinuado e virou Kiro
durante este mesmo módulo do curso (ver a correção em
[Roteiro Prático](./roteiro-pratico-agentes-claude-code.md#-correção-importante-antes-de-começar)).

---

## 5. Testando a trava de permissão na prática, de verdade

A linha "Kiro ganha" na tabela acima não é opinião — foi testada. Pedimos
ao `po` do Kiro CLI pra apertar sua própria permissão de escrita, de
`.kiro/**` pra só `.kiro/tasks/**`. Ele editou dois campos técnicos do
`po.json` (`toolsSettings.write.allowedPaths` e `permissions.rules`) — uma
trava de sistema, real.

Tentamos replicar no `po.md` do Claude Code. O primeiro passo — reescrever
a instrução de escopo no prompt — foi trivial, mas é soft (texto, não
trava). Pra chegar numa trava de verdade, a hipótese era um hook
`PreToolUse` em `Write|Edit` barrando qualquer caminho fora de
`.kiro/tasks/**`.

**Testamos empiricamente antes de implementar** (e não só assumimos que
funcionaria): montamos um hook de diagnóstico que loga o payload real que o
Claude Code manda pro hook antes de um `Write`. Resultado:

```json
{
  "session_id": "...", "cwd": "...", "permission_mode": "acceptEdits",
  "hook_event_name": "PreToolUse", "tool_name": "Write",
  "tool_input": { "file_path": "...", "content": "..." }
}
```

**Não existe campo `agent`/`subagent_name` nesse payload.** O hook enxerga
qual ferramenta foi chamada e com quais argumentos — não enxerga **qual
subagente** pediu. Ou seja: um hook de `Write|Edit` restringindo caminho
pra `.kiro/tasks/**` bloquearia o `po` (que é o que queríamos) **e também
o `dev`** tentando escrever em `api/`/`client/` — cego a quem chama, ele
quebraria o time inteiro, não só apertaria um agente.

Existe um caminho mais complexo (usar os eventos `SubagentStart`/
`SubagentStop` pra gravar "qual subagente está ativo" num arquivo de
estado, e o hook de escrita ler esse estado antes de decidir), mas não é
trivial nem foi validado. Decisão tomada: aceitar a restrição soft como o
teto real do Claude Code hoje pra esse caso de uso, e registrar isso como
achado — não como suposição.

**Atualização da linha da tabela, com essa evidência:** "Kiro ganha" na
trava de permissão não é só porque o Kiro tem mais campos no JSON — é
porque o modelo de permissão dele é **por agente**, enquanto o hook do
Claude Code, pelo menos pelo payload observado, é **por ferramenta**,
sem visibilidade de quem a está chamando.

---

## 6. O que levar disso

O post no LinkedIn celebra o *processo* — agentes com escopo definido,
modelo de feature-branch, PO treinado a especificar bem — não uma
ferramenta específica. E é isso que se confirma aqui: **o processo
sobreviveu intacto a uma troca completa de motor**. Isso é o argumento mais
forte a favor de aprender o *conceito* (agente = persona + escopo de
ferramentas; MCP = conexão externa registrada uma vez, usada por quem tiver
permissão) antes da sintaxe de uma CLI específica — que, como este próprio
módulo mostrou duas vezes (Amazon Q → Kiro, e agora Kiro → Claude Code),
pode mudar de nome de novo no futuro.

## 📚 Referências
- [Post original no LinkedIn](https://www.linkedin.com/feed/update/urn:li:share:7497789644806377472/)
- [Panorama: Agentes e Worktrees](./panorama-agentes-e-worktrees.md) — o processo original, Kiro CLI
- [Migrar Time de Agentes para Claude Code](./migrar-time-agentes-para-claude-code.md) — tradução campo a campo
- [Roteiro Prático com Claude Code](./roteiro-pratico-agentes-claude-code.md) — passo a passo + correções encontradas na prática
- `.kiro/tasks/done/001-feat-contador-tasks-pendentes-concluidas.md` — o ciclo completo citado na seção 3
