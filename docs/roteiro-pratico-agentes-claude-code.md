# 🎓 Roteiro Prático: Construindo o Time de Agentes com Claude Code

> **Para quem é este documento:** você já assistiu as 10 aulas do módulo
> "Agentes de IA & Multi Agentic" (Desafio Labs 3.0) usando o **Kiro CLI**.
> Este roteiro é a **prática guiada** para fixar o conteúdo — refazendo o
> mesmo processo, passo a passo, agora com **Claude Code**. Cada módulo tem:
> um conceito explicado do zero (você não precisa ter bagagem de DevOps),
> uma ação prática, um checkpoint objetivo pra saber se deu certo, e um
> exercício de fixação pra fazer sozinho antes de seguir em frente.
>
> **Pré-requisito:** ter lido `docs/migrar-time-agentes-para-claude-code.md`
> — este roteiro usa os blocos de configuração de lá; aqui o foco é o
> **passo a passo de execução + prática**, não a definição de cada campo.

---

## ⚠️ Correção importante antes de começar

Na conversa anterior, eu afirmei que "o Amazon Q Developer não foi
descontinuado". **Isso estava errado** — você estava certo em pedir
verificação. Confirmei agora em três fontes oficiais da AWS/Kiro:

- **15/mai/2026:** novos cadastros no Amazon Q Developer (Free Tier e
  assinaturas pagas) foram bloqueados.
- **29/mai/2026:** o modelo Opus 4.6 saiu do Q Developer Pro — modelos novos
  (Opus 4.7+) passaram a ficar disponíveis **só no Kiro**.
- **30/abr/2027:** fim total de suporte dos plugins de IDE e assinaturas
  pagas do Amazon Q Developer.
- **O que continua igual:** Amazon Q no Console AWS, na documentação, no app
  mobile e no Slack/Teams **não foram afetados** — o que saiu de cena foi
  especificamente o **CLI e os plugins de IDE**, que é exatamente a peça que
  o seu curso usa.
- **A CLI em si "virou" o Kiro CLI** — é um rebrand, não uma ferramenta nova
  do zero: comandos antigos (`q`, `q chat`) continuam funcionando, e agentes
  customizados, `mcp.json` e regras são **copiados automaticamente** de
  `~/.aws/amazonq/` para `~/.kiro/` na primeira execução. Nomes de
  ferramentas também mudaram (`fs_read`→`read`, `execute_bash`→`shell`,
  `use_aws`→`aws`), mas os nomes antigos continuam funcionando por
  compatibilidade.

Isso explica por que a aula **"02.1 — Migrando do AmazonQ para o KIRO-CLI"**
existe no seu curso, e por que o histórico do projeto BIA tem o commit
`chore: migra .amazonq para .kiro (Amazon Q → Kiro)` — vocês estavam
literalmente acompanhando essa transição oficial da AWS em tempo real.

**Fontes:**
[Amazon Q Developer end-of-support announcement (AWS Blog)](https://aws.amazon.com/blogs/devops/amazon-q-developer-end-of-support-announcement/) ·
[Upgrade to Kiro (AWS Docs)](https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/upgrade-to-kiro.html) ·
[Upgrading from Q CLI (Kiro Docs)](https://kiro.dev/docs/upgrade-guides/migrating-from-q/)

Isso **não muda nada** no seu roteiro de prática abaixo — só explica o
contexto. E reforça por que faz sentido você também praticar com uma
ferramenta *fora* do ecossistema AWS (Claude Code): entender o *conceito* de
agente/MCP/permissões, que é portável entre ferramentas, é mais valioso do
que decorar a sintaxe de uma CLI que pode ser rebatizada de novo no futuro.

---

## ⚠️ Correção: o assistente `/agents` foi removido

Nos Módulos 3, 5 e 8 abaixo, o checkpoint original pedia pra rodar `/agents`
e conferir o subagente numa lista. Isso não existe mais — versões recentes
do Claude Code (confirmado na v2.1.251) removeram esse assistente
interativo. Rodar `/agents` agora só devolve isto:

```
The /agents wizard has been removed.

Ask Claude to create or update subagents for you (e.g. "create a code-reviewer subagent that ..."),
or edit the files directly:
  • .claude/agents/       (this project)
  • ~/.claude/agents/     (all projects)
```

**Não é erro — o mecanismo de subagente (arquivo `.md` em `.claude/agents/`)
continua idêntico.** Só mudou *como você confirma* que ele foi carregado.
Troque o passo "rode `/agents`" de qualquer módulo abaixo por um destes dois:

1. **Perguntar direto:** `"quais subagentes existem nesse projeto?"` — o
   Claude Code lê `.claude/agents/*.md` na hora e responde.
2. **Invocar de vez:** `"Use o subagente <nome>: como você pode me ajudar?"`
   — se o arquivo estiver certo, ele já responde com a persona certa; se não
   existir, o Claude avisa que não achou esse subagente.

A mensagem também revela um atalho que vale usar: dá pra **pedir pro Claude
criar o arquivo do subagente pra você**, em vez de copiar/colar manualmente
os blocos deste roteiro — ele escreve o `.md` sozinho, no formato certo.

---

## 📖 Glossário mínimo (leia antes do Módulo 1)

Se algum desses termos aparecer nas aulas e ainda não estiver 100% claro:

| Termo | O que é, em uma frase | Analogia (Ciência de Dados) |
|---|---|---|
| **Agente de IA** | Um LLM configurado com uma persona fixa (prompt), um conjunto específico de ferramentas e um nível de permissão — não é "um chat a mais", é um papel com escopo definido | Como instanciar a mesma classe Python com parâmetros diferentes: mesmo "motor" (o modelo), configuração e dados de entrada diferentes |
| **CLI** | Command Line Interface — programa que você usa digitando comandos no terminal, em vez de clicar em uma interface gráfica | O terminal `bash`/`ipython` que você já usa, só que a "sessão" conversa com um LLM |
| **MCP (Model Context Protocol)** | Protocolo padrão que permite um agente chamar uma ferramenta externa (banco de dados, API, navegador) como se fosse uma função | Registrar uma `tool`/`function` num agente LangChain — só que MCP é um padrão aberto, funciona igual em qualquer cliente compatível |
| **System prompt** | Instrução fixa que define quem o agente "é" antes de qualquer pergunta do usuário | O `system=` de uma chamada de API de LLM, ou o "prefixo fixo" de um prompt template |
| **Tool / permissão** | Uma capacidade específica que o agente pode ou não usar (ler arquivo, escrever arquivo, rodar comando shell, chamar um MCP) | Como escopos de uma API key — uma key "read-only" vs uma "read-write" |
| **Least privilege (menor privilégio)** | Princípio de segurança: dar a cada agente **só** o acesso que ele precisa pro seu papel, nada a mais | Dar a um analista acesso de leitura ao data warehouse, não de `DROP TABLE` |
| **Branch** | Uma "linha do tempo" separada de código dentro do mesmo repositório git | Uma cópia de um notebook onde você testa uma ideia sem estragar o original |
| **Worktree** | Uma pasta extra ligada ao mesmo repositório, mas com um branch diferente já "aberto" nela — permite trabalhar em duas branches ao mesmo tempo, em pastas diferentes | Ter dois ambientes virtuais Python apontando pro mesmo projeto, cada um numa versão de dependência diferente |
| **Pull Request (PR)** | Pedido formal de "juntar" o código de um branch de volta ao branch principal, geralmente revisado antes de aceitar | Um "merge request" de revisão de código — pense num code review antes de subir pra produção |
| **Subagente (Claude Code)** | O equivalente do Claude Code a um "agente" do Kiro: uma definição de persona+ferramentas em `.claude/agents/*.md`, chamada por delegação a partir da sessão principal | — |

---

## 🗺️ Mapa do roteiro (o que cada módulo replica da aula)

| Módulo | Replica a aula | O que você vai fazer |
|---|---|---|
| 1 | 02.1 + 02.2 | Configurar os MCP servers e entender "tools/resources/invoke" no Claude Code |
| 2 | 02 | Ler a config dos 4 agentes do Kiro e preencher uma tabela de próprio punho |
| 3 | 04 | Criar o subagente `dev` no Claude Code |
| 4 | 05 | Implementar uma primeira feature de verdade com o `dev` |
| 5 | 03 | Criar o subagente `po` |
| 6 | 06 | PO cria a task + worktree (modelo feature branch) |
| 7 | 07 + 08 | PO refina critérios de aceite + dev implementa a partir da task |
| 8 | (extra — completa o time) | Criar `devops` e `qa` |
| 9 | (extra — capstone) | Ciclo completo PO → Dev → QA → PO → PR |

---

## Módulo 1 — MCP: preparando o terreno

**🎯 Objetivo:** entender o que é MCP na prática e deixar os 3 servidores
(`aws-mcp`, `shadcn`, `playwright`) registrados no projeto.

**📖 Conceito:** um agente sozinho só sabe "conversar". MCP é o que permite
ele **fazer** algo fora da conversa — consultar a AWS de verdade, gerar um
componente de UI, controlar um navegador. Cada MCP server é um processo
separado que expõe um conjunto de "ferramentas" com nomes próprios. No Kiro,
isso é declarado dentro do `.json` de cada agente (campo `mcpServers`); no
Claude Code, é declarado uma vez em `.mcp.json` na raiz do projeto e cada
subagente escolhe, no seu `tools:`, quais dessas ferramentas pode usar.

Essa é provavelmente a mesma ideia da aula **02.2 "Tools, Resources e invoke
inline do agente"** — "invoke inline" no Kiro é chamar um agente a partir de
outro sem trocar de sessão inteira; no Claude Code o equivalente é pedir
"use o subagente X para..." dentro da mesma conversa (você vai praticar isso
a partir do Módulo 3).

**🛠️ Passo a passo:**

1. Abra `.mcp.json` na raiz do projeto. Hoje ele só tem o `aws-mcp`.
2. Adicione `shadcn` e `playwright`, copiando o bloco JSON da seção 3 de
   `docs/migrar-time-agentes-para-claude-code.md`.
3. Salve o arquivo.
4. Dentro do Claude Code, rode `/mcp`.

**✅ Checkpoint:** o comando `/mcp` deve listar os **três** servidores como
conectados (`aws-mcp`, `shadcn`, `playwright`). Se algum aparecer com erro,
normalmente é porque falta `npx`/`uvx` instalado no ambiente — resolva isso
antes de seguir.

**✍️ Exercício de fixação:**
Sem copiar de lugar nenhum, escreva num bloco de notas (ou peça pro Claude
"me listar", mas **tente escrever de memória primeiro**) a resposta para:
> "Se eu quisesse dar ao agente `qa` acesso ao `aws-mcp` também, o que eu
> precisaria mudar — no `.mcp.json` ou no arquivo do agente `qa`?"
>
> *(Resposta esperada: nada no `.mcp.json` — ele já está registrado pro
> projeto inteiro. Só precisaria adicionar os nomes das tools do `aws-mcp`
> na lista `tools:` do `qa.md`.)*

---

## Módulo 2 — Entendendo o papel de cada agente (releitura ativa)

**🎯 Objetivo:** consolidar o que a aula 02 ensinou, mas através de **leitura
ativa** dos arquivos reais do projeto — que é mais eficaz pra fixação do que
só assistir de novo.

**📖 Conceito:** cada agente do time BIA (`po`, `dev`, `devops`, `qa`) tem
três dimensões que sempre valem a pena checar: **o que ele pode fazer**
(ferramentas/MCP), **o que ele NÃO pode fazer** (a ausência de uma
ferramenta é tão importante quanto a presença) e **o que ele deve ler antes
de agir** (contexto/regras).

**🛠️ Passo a passo:** abra, um de cada vez, e leia com atenção:
- `.kiro/agents/po.json` + `.kiro/agents/po/especificacao.md`
- `.kiro/agents/dev.json` + `.kiro/agents/dev/instrucoes.md`
- `.kiro/agents/devops.json` + `.kiro/agents/devops/instrucoes.md`
- `.kiro/agents/qa.json` + `.kiro/agents/qa/instrucoes.md`

**✍️ Exercício de fixação — preencha esta tabela sem consultar o documento
da sessão anterior** (só os arquivos `.kiro/agents/` acima):

| Agente | MCP que usa | Pode escrever código? | Pode rodar shell? | Uma regra obrigatória exclusiva dele |
|---|---|---|---|---|
| po | ? | ? | ? (quais comandos?) | ? |
| dev | ? | ? | ? | ? |
| devops | ? | ? | ? | ? |
| qa | ? | ? | ? | ? |

**✅ Checkpoint:** depois de preencher, compare com a tabela da seção 3 do
documento `docs/analise-arquitetura-projeto.md` (busque pela palavra
"Agente") ou com `docs/panorama-agentes-e-worktrees.md`, seção 3. Se você
errou "pode rodar shell?" para o `devops` ou o `qa` — releia
`devops/instrucoes.md` e `qa/instrucoes.md`, é o ponto mais importante do
desenho de permissões do time.

---

## Módulo 3 — Criando o agente DEV no Claude Code

**🎯 Objetivo:** replicar a aula 04 ("Criando agent de desenvolvimento"),
agora no Claude Code.

**🛠️ Passo a passo:**

1. Crie a pasta `.claude/agents/` (se ainda não existir).
2. Crie o arquivo `.claude/agents/dev.md` copiando o bloco da seção 4 de
   `docs/migrar-time-agentes-para-claude-code.md`.
3. Rode `/agents` no Claude Code e confirme que `dev` aparece na lista.
4. Teste com uma pergunta simples, **igual ao que aparece no slide do
   curso** (página 5 do PDF, print do terminal do Kiro):
   ```
   Use o subagente dev: como você pode me ajudar?
   ```

**✅ Checkpoint:** a resposta deve descrever o escopo dele (implementar
backend Node/Express e frontend React, seguir as regras do projeto) — **não**
uma resposta genérica de "sou um assistente de programação". Se vier
genérica, o subagente provavelmente não foi carregado corretamente (confira
o nome do arquivo e o frontmatter).

**💡 Compare com o Kiro:** no print do curso, a resposta do `dev` do Kiro
lista tópicos como "Desenvolvimento", "Infraestrutura & DevOps",
"Qualidade". A resposta do seu subagente Claude deve cobrir esses mesmos
temas — porque o *prompt* que você copiou foi adaptado do mesmo `dev.json`.
Isso é uma boa forma de verificar, na prática, que "o motor mudou mas a
persona é a mesma".

**✍️ Exercício de fixação:**
Edite a `description:` do `dev.md` para ficar mais específica (ex.: mencionar
"Vite" e "Sequelize" explicitamente). Rode `/agents` de novo e veja se o
Claude Code passa a descrever o subagente de forma diferente quando você
pergunta "o que o agente dev faz?". Isso fixa a diferença entre `description`
(usada pelo Claude pra **decidir quando chamar** o subagente) e o corpo do
prompt (usado **depois de já ter decidido chamar**).

---

## Módulo 4 — Implementando a primeira feature com o dev

**🎯 Objetivo:** replicar a aula 05 ("Implementando primeira feature com o
dev") com uma mudança pequena e segura, de ponta a ponta.

**📖 Conceito:** este é o módulo mais importante pra "sentir na pele" o que
significa um agente ter ferramentas de escrita/execução de verdade — ele não
só sugere código, ele **edita o arquivo, builda e testa**.

**🛠️ Passo a passo:**

1. Escolha uma mudança pequena e de baixo risco. Sugestão: alterar o texto
   de um botão ou label em `client/src/components/` (algo puramente visual,
   fácil de reverter com `git checkout`).
2. Peça:
   ```
   Use o subagente dev para alterar o texto do botão "X" para "Y" em
   client/src/components/<arquivo>. Ao terminar, siga o processo obrigatório
   de rebuild e valide /api/versao.
   ```
3. Acompanhe: o subagente deve editar o arquivo, rodar
   `docker compose down && docker compose build server && docker compose up -d`,
   e no final rodar `curl -s http://localhost:3001/api/versao`.

**✅ Checkpoint:** o comando `curl` deve devolver algo como
`Bia {VERSAO_API}` (igual ao print da página 7 do PDF, `http://localhost:3001/api/versao`
mostrando `Status: Online`). Se o container não subir, o subagente deve
reportar o erro — não deve "dizer que terminou" com o container quebrado.

**✍️ Exercício de fixação:**
Depois que funcionar, rode `git diff` você mesmo e leia a mudança feita.
Depois desfaça com `git checkout -- <arquivo>` (sem pedir ajuda do agente) —
esse passo é pra você praticar o comando git de reversão sozinho, uma
habilidade independente de qualquer agente.

---

## Módulo 5 — Criando o agente PO

**🎯 Objetivo:** replicar a aula 03 ("Especificação dos agentes + contexto
do PO") — e entender, campo a campo, o que muda quando o `po` deixa de ser
um JSON do Kiro e vira um `.md` do Claude Code.

**📖 Conceito — o "container" mudou de formato:** no Kiro, um agente é um
arquivo JSON com campos técnicos separados: `tools`, `allowedTools`,
`permissions.rules`, `toolsSettings`. No Claude Code, um agente é **um único
Markdown**: um cabeçalho YAML curto (o "frontmatter", entre `---`) seguido
do prompt em texto corrido. É a diferença entre um `config.yaml` de pipeline
com várias seções tipadas e um notebook com uma célula de metadata no topo e
o resto em texto — mesmo conteúdo, forma mais enxuta.

O `.kiro/agents/po.json` real deste projeto tem **quatro campos** cuidando
só de permissão (`tools`, `allowedTools`, `toolsSettings`, `permissions.rules`).
No `po.md` do Claude Code, isso tudo colapsa num campo só, `tools:`, sem a
granularidade fina de comando-a-comando ou pasta-a-pasta que o Kiro tinha:

| No `po.json` | Vira o quê no `po.md` | O que se perde na tradução |
|---|---|---|
| `name` | `name:` no frontmatter | nada |
| `description` | `description:` no frontmatter | ganha um uso novo: é o texto que o Claude usa pra decidir **sozinho** quando chamar esse subagente |
| `prompt` | corpo do `.md`, após o frontmatter | nada — só troca de campo JSON pra texto solto |
| `model` | `model: sonnet` no frontmatter | nada |
| `tools` + `allowedTools` + `toolsSettings` + `permissions.rules` (4 campos) | **um campo só**: `tools: Read, Write, Bash, Glob, Grep` | granularidade — vira tudo-ou-nada por categoria de ferramenta |
| `resources` (carregado automático) | não existe campo equivalente | vira instrução no prompt: "antes de agir, leia X, Y, Z" |
| `mcpServers` | nada — fica de fora | resolvido pelo `.mcp.json` do projeto, compartilhado por todos os agentes |

**A diferença prática que mais importa:** o `po.json` tem
`toolsSettings.write.allowedPaths: [".kiro/**"]` e
`toolsSettings.shell.allowedCommands: [...]` com `denyByDefault: true` — ou
seja, o **sistema** do Kiro barra tecnicamente qualquer escrita fora de
`.kiro/` e qualquer comando de shell fora da lista branca. No Claude Code,
`tools: Bash` é tudo-ou-nada: não existe campo pra dizer "pode `git commit`,
não pode `npm install`". Essa regra só sobrevive se você **escrever no
prompt** — "seu uso do Bash deve se limitar a `git add`, `git commit`...".
É uma trava que virou pedido: o modelo segue por instrução (*soft*), não
porque a ferramenta foi tecnicamente removida (*hard*, como acontece com
`Write`/`Edit`/`Bash` no `devops` e no `qa`, que nem aparecem no `tools:`
deles).

**🛠️ Passo a passo:**

1. Crie `.claude/agents/po.md` (bloco da seção 4 de
   `docs/migrar-time-agentes-para-claude-code.md` — ele já traduz o
   `po.json` real, incluindo a lista de comandos de shell permitidos e a
   restrição de escrita em `.kiro/**`).
2. Teste, igual ao print do curso (página 6 do PDF):
   ```
   Use o subagente po: como você pode me ajudar?
   ```
   (ver a correção logo acima — não use mais `/agents` pra confirmar que ele
   foi carregado; pergunte direto ou invoque, como descrito ali.)

**✅ Checkpoint:** a resposta deve mencionar: gestão de tarefas em
`.kiro/tasks/`, formato `[seq]-[tipo]-[resumo].md`, `sequencial.md`, e que
ele **não escreve código de aplicação**.

**✍️ Exercício de fixação:**
Abra `.kiro/tasks/sequencial.md` e confira manualmente qual é o próximo
número de task. Depois pergunte ao subagente `po` "qual vai ser o número da
próxima task?" — a resposta dele deve bater com o que você leu. Se não
bater, é sinal de que ele não seguiu a instrução de ler `sequencial.md`
antes de responder — volte no prompt do `po.md` e reforce essa instrução.

Em seguida, sem consultar nada, responda de memória: *"se eu pedisse pro
`po` rodar `npm install`, o que aconteceria — ele recusaria por estar
tecnicamente impedido, ou porque o prompt manda ele não fazer isso?"* (a
resposta é a segunda opção — é soft, não hard; compare com o `devops` no
Módulo 8, onde é a primeira opção).

---

## Módulo 6 — PO cria a task + worktree (modelo feature branch)

**🎯 Objetivo:** replicar a aula 06 ("Implementando modelo feature branch —
etapa do PO").

**🛠️ Passo a passo:**

1. Peça ao `po` para criar uma task de teste, pequena e de baixo risco. Ex.:
   ```
   Use o subagente po para criar uma nova task: "adicionar um comentário de
   versão no rodapé da tela de tarefas". Depois de eu revisar e aprovar,
   mova para doing/ e crie o worktree seguindo o fluxo obrigatório.
   ```
2. Confirme cada etapa do fluxo obrigatório (documentado em
   `.kiro/agents/po/especificacao.md`, que o `po.md` foi instruído a ler):
   - Task criada em `.kiro/tasks/NNN-feat-resumo.md`
   - `sequencial.md` incrementado
   - Após sua aprovação: task movida para `.kiro/tasks/doing/`
   - `git worktree add .kiro/worktrees/NNN-feat-resumo -b feature/NNN-feat-resumo ia-main`

**✅ Checkpoint:** rode no terminal, você mesmo (não peça pro agente):
```bash
git worktree list
```
Deve aparecer uma linha nova apontando para `.kiro/worktrees/NNN-...` no
branch `feature/NNN-...`.

**✍️ Exercício de fixação:**
Entre manualmente na pasta do worktree (`cd .kiro/worktrees/NNN-.../`) e
rode `git branch --show-current`. Confirme que mostra `feature/NNN-...` — e
que se você voltar pra raiz do projeto (`cd -` ou `cd ../../..`) e rodar o
mesmo comando lá, mostra `ia-main`. Esse é o "clique" mental de entender
worktree: **duas pastas, dois branches, ao mesmo tempo, sem stash**.

---

## Módulo 7 — PO refina critérios + dev implementa a task

**🎯 Objetivo:** replicar as aulas 07 ("Treinando o PO para definir as novas
características da task") e 08 ("Implementando as tasks com o agente dev").

**🛠️ Passo a passo:**

1. Peça ao `po` para detalhar critérios de aceite claros na task criada no
   Módulo 6 (ex.: "o rodapé deve mostrar `Bia {versão}` centralizado, com a
   mesma fonte do resto da tela").
2. Revise a task junto com o `po` (peça pra ele te mostrar o conteúdo do
   arquivo antes de seguir).
3. Chame o `dev`:
   ```
   Use o subagente dev para implementar a task NNN que está em
   .kiro/tasks/doing/, dentro do worktree .kiro/worktrees/NNN-.../
   ```

**✅ Checkpoint:** o `dev` deve: entrar no worktree correto (confirme com
`pwd` que ele reporta), implementar, marcar os itens do checklist da task, e
rodar o rebuild+curl (Módulo 4) **dentro daquele worktree**.

**✍️ Exercício de fixação:**
Leia o arquivo da task depois que o `dev` terminou. Confira se os itens do
checklist foram de fato marcados (`- [x]`) e não só "esquecidos" — essa é
uma responsabilidade que, no time real, cabe ao `qa`/`po` fiscalizar, não só
confiar na palavra do `dev`. Pratique esse ceticismo saudável agora.

---

## Módulo 8 — Completando o time: DevOps e QA

**🎯 Objetivo:** os dois agentes que faltam pro time ficar completo,
consolidando o padrão "somente leitura" (não coberto diretamente pelas 10
aulas assistidas, mas essencial pra fechar a arquitetura de 4 papéis).

**🛠️ Passo a passo:**

1. Crie `.claude/agents/devops.md` e `.claude/agents/qa.md` (blocos da
   seção 4 do documento anterior).
2. Teste o `devops` com uma pergunta **só de leitura**:
   ```
   Use o subagente devops: existe algum cluster ECS na conta formacaoaws,
   região us-east-1?
   ```
3. Teste o `qa` pedindo pra ele abrir `http://localhost:3001` no navegador
   (via Playwright) e confirmar que a tela carrega.

**✅ Checkpoint:** para o `devops` — se você pedir pra ele **criar** ou
**apagar** algo na AWS, ele deve recusar ou simplesmente não conseguir
(porque `Write`/`Edit`/`Bash` não estão no `tools:` dele). Teste isso de
propósito: peça "crie um bucket S3 de teste" e confirme que ele não
consegue executar — só sugerir que você faça manualmente.

**✍️ Exercício de fixação:**
Releia a seção 6 do documento anterior (tabela de diferenças honestas). Sem
consultar, responda: *"de onde vem, na prática, a garantia de que o `devops`
não consegue alterar a AWS de verdade — da lista `tools:` do subagente, ou
de outra camada?"* — a resposta certa envolve o **IAM do perfil
`formacaoaws`**, não só a config local. Se quiser confirmar de verdade, peça
ao `devops` para listar as permissões do perfil (via `aws-mcp`).

---

## Módulo 9 — Capstone: ciclo completo PO → Dev → QA → PO → PR

**🎯 Objetivo:** rodar o fluxo inteiro, do início ao fim, numa task nova e
real (pequena, mas real — não um teste descartável), consolidando tudo.

**🛠️ Passo a passo (resumo — os detalhes de cada etapa você já praticou
nos módulos 5 a 8):**

1. `po` cria a task com critérios de aceite claros.
2. Você aprova → `po` move pra `doing/` e cria o worktree.
3. `dev` implementa dentro do worktree, roda rebuild+curl.
4. `dev` sinaliza pro `po` que terminou → `po` aciona o `qa`.
5. `qa` valida os critérios de aceite via Playwright + confere `/api/versao`.
6. Se aprovado: `qa` sinaliza pro `po` → `po` move a task pra `done/`, faz
   commit/push no `ia-main`, e abre o PR (`gh pr create --base ia-main`).
7. **Você** revisa o PR no GitHub antes de mergear (esse passo não é
   delegável a nenhum agente do time — é o seu papel como humano no loop).
8. Depois do merge: peça ao `po` para remover o worktree
   (`git worktree remove .kiro/worktrees/NNN-...`).

**✅ Checkpoint final:** `git worktree list` não deve mais mostrar a task
NNN, e `.kiro/tasks/done/NNN-....md` deve existir.

**✍️ Exercício de fixação (reflexão escrita):**
Escreva, com suas palavras, 3 a 5 frases respondendo: *"Se eu tivesse feito
esse mesmo ciclo com o Kiro CLI em vez do Claude Code, o que teria sido
literalmente idêntico, e o que teria sido diferente?"* — se você conseguir
responder isso sem consultar nenhum documento, o objetivo deste roteiro foi
alcançado: você entende o **processo** (que é o que vale a pena aprender)
independente da ferramenta (que muda com o tempo — como o próprio Amazon Q
→ Kiro acabou de provar).

---

## 📚 Referências

- [Recriando o Time de Agentes no Claude Code](./migrar-time-agentes-para-claude-code.md) — os blocos de configuração completos usados neste roteiro
- [Panorama de Agentes e Worktrees](./panorama-agentes-e-worktrees.md) — processo original em detalhe
- [Análise de Arquitetura do Projeto](./analise-arquitetura-projeto.md) — como o app BIA em si funciona (útil pro Módulo 4)
- `.kiro/agents/po/especificacao.md`, `.kiro/rules/*.md` — regras que os subagentes devem seguir
- `desafio_labs_agents.pdf` — slides originais do módulo do curso
- [Amazon Q Developer end-of-support announcement (AWS Blog)](https://aws.amazon.com/blogs/devops/amazon-q-developer-end-of-support-announcement/)
- [Upgrade to Kiro (AWS Docs)](https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/upgrade-to-kiro.html)
- [Upgrading from Q CLI (Kiro Docs)](https://kiro.dev/docs/upgrade-guides/migrating-from-q/)
