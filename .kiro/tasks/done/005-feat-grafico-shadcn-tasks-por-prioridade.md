# [005] - Migrar gráfico de "Tasks por Prioridade" (Analytics) para o componente de Chart do shadcn/ui

## 🔧 Configuração Inicial (LEIA ANTES DE INICIAR)

### Agent Responsável
**dev** - Este agent deve iniciar a implementação. Ao concluir, deve chamar o
**qa** para validar via Playwright antes de notificar o PO.

### Branch Base
**SEMPRE `ia-main`**

### Worktree
Esta task será implementada em worktree isolado em
`.kiro/worktrees/005-feat-grafico-shadcn-tasks-por-prioridade/`

### Escopo
- **Somente frontend** (`client/`). **Não alterar nada em `api/`.**
- **Já existe** uma tela de Analytics em `client/src/components/Analytics.jsx`
  (roteada em `/analytics`, com link a partir da Home em `App.jsx`) contendo um
  gráfico de barras "Tasks por Prioridade" — mas implementado com os
  componentes **crus do Recharts** (`BarChart`, `XAxis`, `YAxis`, `Tooltip`,
  `Cell`, `ResponsiveContainer`, importados diretamente de `recharts`).
- Esta task **NÃO é uma tela nova**: é a **migração/reescrita do gráfico já
  existente** em `Analytics.jsx` para usar os componentes de chart do
  shadcn/ui (`client/src/components/ui/chart.jsx` — `ChartContainer`,
  `ChartTooltip`, `ChartTooltipContent`, `ChartConfig`, etc.), que também usam
  Recharts por baixo dos panos, mas com a camada de theming/API do shadcn
  (cores via CSS vars `--color-*` a partir de um `ChartConfig`, tooltip
  padronizado, integração nativa com dark mode).
- **Verificado nesta revisão:** o arquivo `client/src/components/ui/chart.jsx`
  **já existe** no projeto (foi adicionado em algum momento anterior, possivelmente
  junto com `card.jsx`) — ou seja, o componente de chart do shadcn **já está
  instalado**, não precisa rodar `npx shadcn add chart` a menos que o dev,
  ao consultar o MCP shadcn, identifique que a versão instalada está
  desatualizada ou incompleta frente ao bloco de referência oficial
  (ex.: `chart-bar-*`). Confirmar isso é o primeiro passo do checklist de
  implementação.
- **Modelo de dados sem alteração nesta task:** o modelo `Tarefas`
  (`api/models/tarefas.js`) tem apenas `uuid, titulo, dia_atividade,
  importante (BOOLEAN)`. Não existe um campo de prioridade com múltiplos
  níveis (alta/média/baixa) — só o booleano `importante`. Esta task **mantém
  a mesma semântica de agrupamento já usada hoje**: 2 categorias
  ("⭐ Importantes" / "📋 Normais") a partir do campo `importante`. Ver
  decisão de escopo detalhada na seção [📊 Notas Técnicas](#-notas-técnicas).
- **Requisito adicional (acesso pela Home):** a Home deve ter um **link
  visível** levando até a tela do gráfico (`/analytics`). Ao investigar o
  código nesta revisão, esse link **já existe** — um card "Ver Analytics" em
  `client/src/App.jsx` (linhas ~251-260, `<a href="/analytics"
  className="analytics-link-card">`). Ainda assim, este critério permanece
  **explícito** na task (funciona como teste de regressão: garantir que a
  migração do gráfico não quebre nem esconda esse ponto de acesso) e o QA
  deve validar sua presença/funcionamento na Home renderizada via Playwright,
  não apenas no código-fonte — cobrindo o cenário relatado de o link não
  aparecer visualmente no ambiente do usuário (possível build desatualizado
  ou baixa visibilidade do card).

---

## ⚠️ CHECKLIST DE INÍCIO (OBRIGATÓRIO)

Antes de começar a implementar, o agent deve:

- [x] **Verificar branch atual:** `git branch --show-current`
  - Se não estiver em `ia-main`, **PERGUNTAR** ao usuário se pode trocar
  - Aguardar autorização
  - Após autorização: `git checkout ia-main && git pull origin ia-main`

- [x] **Mover task para doing:**
  ```bash
  mv .kiro/tasks/005-feat-grafico-shadcn-tasks-por-prioridade.md .kiro/tasks/doing/
  git add .kiro/tasks/
  git commit -m "move: task 005 para doing"
  git push origin ia-main
  ```

- [x] **Criar worktree:**
  ```bash
  git worktree add .kiro/worktrees/005-feat-grafico-shadcn-tasks-por-prioridade -b feature/005-feat-grafico-shadcn-tasks-por-prioridade ia-main
  cd .kiro/worktrees/005-feat-grafico-shadcn-tasks-por-prioridade
  git branch --show-current  # Confirmar branch correto
  ```

---

## 📋 Tipo
**feat** - Substituição de componente de UI para alinhar com o design system do projeto (shadcn/ui).

## 📝 Resumo
Reescrever o gráfico "Tasks por Prioridade" da tela `/analytics`
(`client/src/components/Analytics.jsx`), hoje implementado com os
componentes crus do Recharts, para usar o componente de **chart do
shadcn/ui** (`ChartContainer`/`ChartConfig`/`ChartTooltip`/
`ChartTooltipContent` de `client/src/components/ui/chart.jsx`), mantendo o
agrupamento por prioridade em 2 categorias a partir do campo booleano
`importante` (Importantes vs. Normais), e garantindo que a Home mantenha um
link visível e funcional até essa tela.

## 📖 Descrição
Como usuário do BIA, eu quero continuar vendo o gráfico de distribuição das
minhas tasks por prioridade na tela de Analytics, agora com a mesma
linguagem visual e de theming (incluindo dark mode) usada nos demais
componentes shadcn/ui do projeto, para que a experiência visual seja
consistente em toda a aplicação — e quero conseguir chegar até essa tela a
partir de um link claramente visível na Home, sem precisar digitar a URL
`/analytics` manualmente.

Como time de desenvolvimento, queremos parar de manter duas abordagens de
estilização de gráfico convivendo no projeto (Recharts "cru" com estilos
inline via CSS vars em `Analytics.jsx` vs. o padrão shadcn já usado em
`chart.jsx`) — reduzindo inconsistência e superfície de manutenção, e usando
o componente de chart shadcn que já está instalado no projeto (verificar via
MCP shadcn se está atualizado/completo frente aos blocos de referência
`chart-bar-*`).

**Contexto técnico observado no arquivo atual** (`client/src/components/Analytics.jsx`):
- Importa `BarChart`, `Bar`, `XAxis`, `YAxis`, `CartesianGrid`, `Cell`,
  `ResponsiveContainer`, `Tooltip` diretamente de `recharts`.
- Define um `CustomTooltip` e um `CustomBarLabel` próprios, estilizados
  manualmente com CSS vars do tema (`var(--bg-card)`, `var(--text-primary)`,
  etc.) em vez de usar `ChartTooltipContent` do shadcn.
- Cores por categoria vêm de uma constante local `COLORS` (`importantes`,
  `normais`) aplicada via `<Cell fill={...}>` — no padrão shadcn, isso deve
  virar um `ChartConfig` (objeto com `label`/`color` por série, usado por
  `ChartContainer` para gerar as CSS vars `--color-*` consumidas pelo
  gráfico).
- Os dados já chegam prontos via prop `tasks` (de `App.jsx`) e são agregados
  com `useMemo` (equivalente a um `groupby` por `importante`) — essa parte
  da lógica de agregação **não muda**, só a camada de renderização do
  gráfico.
- Existe uma nota de estudo detalhando a implementação atual em
  `docs/grafico-tasks-por-prioridade.md` — usar como referência de contexto
  (ela ficará desatualizada após esta task; **não é obrigatório** atualizá-la
  como parte desta task, mas é desejável se o dev tiver tempo — ver Notas
  Técnicas).

**Contexto técnico observado sobre o link de acesso** (`client/src/App.jsx`,
linhas ~251-260): já existe um card `<a href="/analytics"
className="analytics-link-card">` com ícone, texto "Ver Analytics" e seta,
dentro de um `<div className="analytics-link-wrapper">`. Esse trecho não
precisa ser criado do zero, mas **deve ser preservado e validado** como parte
desta task (ver critério de aceitação e checklist de QA abaixo).

## ✅ Critérios de Aceitação

### Funcionalidades Principais
- [x] Verificado via MCP shadcn (`mcp__shadcn__*`) se o componente `chart` já
      está instalado/atualizado em `client/src/components/ui/chart.jsx`
      (nesta revisão do PO, o arquivo já existia) — se precisar atualizar ou
      completar, usar `npx shadcn add chart` / MCP equivalente.
- [x] O gráfico de barras em `Analytics.jsx` reimplementado usando
      `ChartContainer` + `ChartTooltip`/`ChartTooltipContent` (+ `Bar`,
      `BarChart`, `XAxis`, `CartesianGrid` do Recharts, como usado pelos
      blocos de referência `chart-bar-*` do shadcn) no lugar de
      `ResponsiveContainer`/`Tooltip` crus e do `CustomTooltip` manual.
- [x] Um `ChartConfig` definido para as 2 categorias (`importante` /
      `normal`, ou nomes equivalentes), com `label` e `color` — reaproveitando
      as cores já usadas hoje (`COLORS.importantes` = `#f59e0b`,
      `COLORS.normais` = `#10b981`) ou os tokens de cor shadcn
      (`--chart-1`, `--chart-2`, etc.) se já existirem no tema do projeto —
      decisão do dev, desde que o contraste/identidade visual atual seja
      preservada.
- [x] O agrupamento de dados por prioridade continua sendo feito a partir do
      campo `importante` (booleano) das tasks recebidas via prop — **sem
      nenhuma alteração em `api/`, models ou migrations**.
- [x] O gráfico continua mostrando o total de tasks e a contagem por
      categoria (equivalente ao que já existe hoje no `CardDescription` e
      nos cards de estatística abaixo do gráfico) — esses cards de estatística
      (`analytics-stats-grid`) podem ser mantidos como estão (não usam
      Recharts, não fazem parte do escopo do chart em si).
- [x] **A Home (`/`) contém um link visível** levando até a tela do gráfico
      (`/analytics`) — confirmar que o card "Ver Analytics" já existente em
      `App.jsx` continua presente, visível (sem ficar escondido/cortado por
      CSS) e navegável após a migração do gráfico. Se, ao testar a Home
      renderizada, o link não estiver visível ou não funcionar, corrigir
      como parte desta task (não é opcional).

### Interface e UX
- [x] Tooltip ao passar o mouse/tocar em uma barra mostra a categoria e a
      contagem, agora usando `ChartTooltipContent` do shadcn (estilo
      consistente com outros charts shadcn, se houver, e com o restante do
      design system).
- [x] Visual do gráfico consistente com o tema (incluindo **dark mode**) —
      cores e contraste adequados nos dois temas.
- [x] Estado vazio (`tasks.length === 0`) continua funcionando como hoje
      (sem gráfico, com a mensagem/CTA de "Nenhuma tarefa ainda").
- [x] Responsivo: gráfico continua ocupando 100% da largura do card e se
      comporta bem em telas estreitas (mobile), sem overflow ou quebra de
      layout.
- [x] Card/link "Ver Analytics" na Home permanece visualmente claro (ícone,
      texto e seta legíveis) em light e dark mode, e em telas estreitas.

### Integração
- [x] Nenhum arquivo dentro de `api/` é alterado nesta task.
- [x] A rota `/analytics` e a prop `tasks` recebida de `App.jsx` continuam
      funcionando exatamente como hoje (sem mudança de contrato de props do
      componente `Analytics`).
- [x] Testar com dados reais: criar/remover/marcar tasks como
      importantes na Home e confirmar que o gráfico em `/analytics` reflete
      a contagem correta (Importantes vs. Normais).
- [x] Navegar pela Home renderizada (não só ler o código-fonte), clicar no
      link/card "Ver Analytics" e confirmar que ele leva corretamente até
      `/analytics`.

## 🧪 Testes
- [x] Testar funcionalidade localmente (`docker compose up --build`, conforme regra do agent `dev`)
- [x] Validar cenário com tasks variadas (algumas importantes, algumas não) — gráfico exibe as
      contagens corretas
- [x] Validar cenário de lista vazia (sem tasks) — estado vazio preservado
- [x] Validar tooltip ao passar o mouse sobre cada barra
- [x] Validar visual em light e dark mode
- [x] Validar responsividade (mobile/desktop)
- [x] Validar que o link "Ver Analytics" está visível na Home renderizada e
      leva até `/analytics`

## 📚 Definição de Pronto (DoD)
- [x] Código implementado e testado
- [ ] Todos os itens do checklist marcados ✅
- [x] Commits descritivos e frequentes
- [x] Push do branch realizado
- [x] Código segue padrões do projeto (componentes shadcn em
      `client/src/components/ui/`, sem imports crus de `recharts` fora de
      `chart.jsx`)
- [x] Nenhuma alteração em `api/`
- [ ] QA validou via Playwright que o gráfico aparece e reflete corretamente
      as contagens por prioridade (ver seção QA abaixo)
- [ ] QA validou via Playwright que o link "Ver Analytics" está presente e
      funcional na Home renderizada
- [x] Rebuild dos containers realizado conforme regra do dev
      (`.kiro/agents/dev/instrucoes.md`) e `/api/versao` respondendo

---

## 🎯 CHECKLIST DE IMPLEMENTAÇÃO (MARCAR DURANTE O TRABALHO)

### Configuração
- [x] Worktree criado e branch correto confirmado
- [x] Ambiente de desenvolvimento configurado no worktree
- [x] Dependências instaladas (se necessário)

### Desenvolvimento (dev)
- [x] Verificar via MCP shadcn se `client/src/components/ui/chart.jsx` já
      cobre o necessário (`ChartContainer`, `ChartConfig`, `ChartTooltip`,
      `ChartTooltipContent`) frente ao bloco de referência `chart-bar-*`; se
      faltar algo, adicionar/atualizar via `npx shadcn add chart`
- [x] Definir o `ChartConfig` de 2 categorias (importante/normal) com
      `label` e `color`
- [x] Reescrever a renderização do gráfico em `Analytics.jsx` usando
      `ChartContainer` no lugar de `ResponsiveContainer`, e
      `ChartTooltip`/`ChartTooltipContent` no lugar do `CustomTooltip` manual
- [x] Remover (ou simplificar, se ainda fizer sentido) o `CustomBarLabel`
      manual, avaliando se o padrão shadcn/Recharts já cobre a necessidade de
      exibir o valor sobre cada barra
- [x] Manter a lógica de agregação (`useMemo` com `filter` por `importante`)
      sem alterações
- [x] Manter os cards de estatística (`analytics-stats-grid`) como estão,
      apenas confirmando que continuam consistentes com os novos dados do
      gráfico
- [x] Confirmar (e corrigir se necessário) que o card/link "Ver Analytics"
      em `client/src/App.jsx` (~linhas 251-260) está presente, visível e
      navegável na Home renderizada — não só no código-fonte
- [x] Conferir que não sobrou nenhum import cru de `recharts` em
      `Analytics.jsx` fora do que já é reexportado/usado por `chart.jsx`
- [ ] (Opcional, desejável) Atualizar `docs/grafico-tasks-por-prioridade.md`
      para refletir a nova implementação baseada em shadcn — não bloqueia o
      DoD, mas é uma boa prática deixar a nota de estudo atualizada

### Testes
- [x] Testes manuais realizados cobrindo os cenários da seção 🧪 Testes
- [x] Cenários de borda testados (lista vazia, só importantes, só normais)
- [x] Visual conferido em light e dark mode
- [x] Link "Ver Analytics" testado manualmente a partir da Home renderizada

### Finalização (dev)
- [x] Código revisado
- [x] Commits finalizados com mensagens descritivas
- [x] Push do branch realizado
- [x] Rebuild completo dos containers (`docker compose down` → `build` →
      `up`) e confirmação de que `/api/versao` responde
- [x] Notificar o **qa** para validação via Playwright

### Validação (qa)
- [x] Abrir a Home via Playwright e confirmar que o link/card "Ver
      Analytics" está **visível na página renderizada** (não escondido por
      CSS/overflow) e que o clique nele navega até `/analytics`
- [x] Abrir `/analytics` via Playwright com tasks variadas e confirmar que o
      gráfico exibe as contagens corretas (Importantes vs. Normais)
- [x] Validar tooltip ao interagir com as barras
- [x] Validar estado vazio (sem tasks)
- [x] Validar visual em light e dark mode (print de evidência)
- [x] Validar responsividade (mobile/desktop), incluindo a visibilidade do
      link "Ver Analytics" na Home em telas estreitas
- [x] Registrar evidências (prints/logs do Playwright) e notificar o PO com
      o resultado da validação

**Nota (qa):** Validação end-to-end via Playwright contra o build real da
branch `feature/005-feat-grafico-shadcn-tasks-por-prioridade` (container de
teste isolado `bia-005-test`, porta 3002). Todos os cenários acima cobertos
com sucesso. **Único ponto não-bloqueante encontrado:** o tooltip do gráfico
mostra a categoria duplicada quando há série única — registrado como
sugestão de polimento futuro, **não impede a aprovação** desta task.
Evidências (prints) na raiz do repositório: `005-analytics-dark.png`,
`005-analytics-light-data.png`, `005-analytics-mobile-dark.png`,
`005-analytics-mobile-dark2.png`, `005-analytics-tooltip-dark.png`,
`005-analytics-tooltip-light.png`, `005-home-mobile-dark.png`,
`005-home-mobile-light.png`.

### Finalização (qa)
- [x] Todos os itens acima marcados ✅
- [x] Notificar o PO com o resultado da validação (aprovado ou apontando
      ajustes necessários para o dev)

**Resultado:** ✅ **Aprovado em QA** — validado ponta a ponta via Playwright
contra o build real da branch, pronto para revisão de encerramento pelo PO.

---

## ⚠️ FINALIZAÇÃO DA TASK (OBRIGATÓRIO)

Quando o **dev** concluir a implementação:

### 1. Verificação Final
```bash
# Garantir que está no worktree correto
pwd
# Deve estar em: /caminho/do/projeto/.kiro/worktrees/005-feat-grafico-shadcn-tasks-por-prioridade

# Verificar branch
git branch --show-current
# Deve mostrar: feature/005-feat-grafico-shadcn-tasks-por-prioridade
```

### 2. Commit e Push Final
```bash
git add .
git commit -m "feat: finaliza implementação da task 005"
git push origin feature/005-feat-grafico-shadcn-tasks-por-prioridade
```

### 3. Chamar o QA
O dev deve notificar o **qa** para que ele valide a funcionalidade no mesmo
worktree/branch (ou branch publicado), seguindo o checklist de "Validação
(qa)" acima.

### 4. Voltar para Raiz e Notificar PO
```bash
cd ../../..  # Voltar para raiz do projeto
```

**NOTIFICAR O PO (após validação do qa):**
> "Task 005 concluída pelo dev e validada pelo qa. Todos os itens do
> checklist marcados. Branch
> `feature/005-feat-grafico-shadcn-tasks-por-prioridade` com push
> realizado. Aguardando revisão do PO para encerramento e abertura de PR."

**⚠️ NÃO REMOVER O WORKTREE. Apenas o PO faz isso após o PR ser mergeado.**

---

## 🎯 ENCERRAMENTO PELO PO (QUANDO NOTIFICADO)

### 1. Revisão
```bash
# Entrar no worktree para revisar
cd .kiro/worktrees/005-feat-grafico-shadcn-tasks-por-prioridade

# Revisar código, testar funcionalidade
# Verificar se todos os itens estão ✅ (incluindo validação do qa)
```

### 2. Aprovar e Mover para Done
```bash
# Voltar para raiz
cd ../../..

# Mover task para done
mv .kiro/tasks/doing/005-feat-grafico-shadcn-tasks-por-prioridade.md .kiro/tasks/done/

# Commit e push no ia-main
git checkout ia-main
git add .kiro/tasks/
git commit -m "move: task 005 para done"
git push origin ia-main
```

### 3. Abrir Pull Request
```bash
# ANTES de abrir PR: confirmar que está no branch da feature (NUNCA em ia-main)
cd .kiro/worktrees/005-feat-grafico-shadcn-tasks-por-prioridade
git branch --show-current
# Comparar a saída com o nome esperado: feature/005-feat-grafico-shadcn-tasks-por-prioridade
# Se não bater (ex.: mostrar "ia-main"), PARAR — NÃO rodar o gh pr create abaixo

# Só prosseguir se o branch confirmado bater com o esperado:
gh pr create --base ia-main --title "005: Migrar gráfico de Tasks por Prioridade para chart do shadcn/ui" --body "Closes task 005"
```

### 4. Após PR Mergeado
```bash
# Voltar para raiz
cd ../../..

# Remover worktree
git worktree remove .kiro/worktrees/005-feat-grafico-shadcn-tasks-por-prioridade

# Ou com força se necessário:
# git worktree remove --force .kiro/worktrees/005-feat-grafico-shadcn-tasks-por-prioridade

# Limpar registros
git worktree prune

# (Opcional) Deletar branch local
git branch -d feature/005-feat-grafico-shadcn-tasks-por-prioridade

# Notificar conclusão
```

---

## 📊 Notas Técnicas

### Decisão de escopo 1: migração do gráfico existente, não uma tela nova
A demanda original pedia "criar uma tela" com um gráfico de tasks por
prioridade usando chart do shadcn. Ao investigar o código, constatou-se que
**a tela e o gráfico já existem** (`client/src/components/Analytics.jsx`,
rota `/analytics`) — só não usam o componente de chart do shadcn/ui, e sim
Recharts puro. Por isso, esta task foi definida como uma **migração/reescrita
da camada de renderização do gráfico já existente**, e não como uma tela
nova do zero. Isso evita duplicar tela/rota e mantém uma única fonte de
verdade para "gráfico de tasks por prioridade" no projeto.

### Decisão de escopo 2: "prioridade" continua sendo o booleano `importante`
O modelo `Tarefas` (`api/models/tarefas.js`) tem apenas `uuid, titulo,
dia_atividade, importante (BOOLEAN)` — não existe hoje um campo de
prioridade com múltiplos níveis (alta/média/baixa). Por isso, "agrupar por
prioridade" nesta task continua significando agrupar pelo booleano
`importante` em 2 categorias (Importante/Normal), exatamente como a
implementação atual já faz — apenas trocando a biblioteca/API de
renderização do gráfico, não o modelo de dados nem a lógica de agregação.

Uma eventual task futura (`feat`, fora deste escopo) poderia propor uma
prioridade "de verdade" (ex.: Alta/Média/Baixa), o que exigiria alterar o
campo `importante` (BOOLEAN) para algo como `prioridade` (ENUM/STRING) no
modelo Sequelize, uma migração de banco, ajuste do endpoint
`PUT /api/tarefas/update_priority/:uuid`, troca do toggle binário (estrela)
na UI por um seletor de N níveis, e o gráfico passaria a agrupar por N
categorias em vez de 2. Isso **não faz parte desta task** e deve ser
sinalizado como sugestão de backlog futuro, não implementado aqui.

### Decisão de escopo 3: link "Ver Analytics" na Home é critério de regressão
O usuário sinalizou, a partir de um print da Home (BIA 2026), que não via
nenhum link/card levando até o gráfico de prioridade — só formulário de
nova tarefa, lista de tasks e rodapé. Ao investigar o código-fonte
(`client/src/App.jsx`, linhas ~251-260), esse link **já existe** no
repositório (`<a href="/analytics" className="analytics-link-card">`,
dentro de `analytics-link-wrapper`), então é possível que o ambiente do
usuário estivesse com um build desatualizado, ou que o card estivesse com
baixa visibilidade nas condições em que foi observado. De qualquer forma,
este critério foi mantido **explicitamente** na task (mesmo já existindo no
código) como um teste de regressão: garantir que a migração do gráfico para
shadcn não quebre, esconda ou desestilize esse ponto de acesso, e que o QA
confirme sua presença/funcionamento **na página renderizada** via
Playwright — não apenas por leitura de código-fonte.

### Pontos de referência no código atual
- `client/src/components/Analytics.jsx` — arquivo principal a alterar
  (gráfico + agregação + estado vazio + cards de estatística).
- `client/src/components/ui/chart.jsx` — componente de chart do shadcn/ui
  **já instalado** no projeto (`ChartContainer`, `useChart`, `ChartTooltip`
  = `RechartsPrimitive.Tooltip`, `ChartTooltipContent`, etc.). Confirmar via
  MCP shadcn se está completo/atualizado frente aos blocos de referência
  (`chart-bar-*`) antes de assumir que nada precisa ser adicionado.
- `client/src/App.jsx` — rota `/analytics` (`<Analytics tasks={tasks} />`),
  estado `tasks` (fonte dos dados) e card/link "Ver Analytics" (~linhas
  251-260); este último deve ser **preservado e validado**, mas nenhuma
  outra alteração além do necessário para o critério do link deve ser feita
  em `App.jsx` nesta task.
- `docs/grafico-tasks-por-prioridade.md` — nota de estudo com a explicação
  detalhada da implementação atual (Recharts puro); útil como referência de
  contexto antes de começar, e candidata a atualização opcional ao final.
- `api/models/tarefas.js` — modelo `Tarefas`, **não deve ser alterado** nesta
  task.

## 💼 Valor de Negócio
**Baixo/Médio** - Não é uma nova funcionalidade para o usuário final (o
gráfico já existe e já mostra a informação correta), mas reduz dívida
técnica e inconsistência de design system (duas abordagens de estilização de
gráfico convivendo no projeto), alinhando `Analytics.jsx` ao padrão shadcn/ui
já adotado no restante da aplicação (ver também task 004, que fez a mesma
troca de racional para o date picker). O critério de regressão do link na
Home também protege um caminho de navegação relatado como não-óbvio pelo
usuário.

## 🎯 Estimativa
**3 Story Points** - Escopo restrito a um único arquivo principal
(`Analytics.jsx`) mais a validação/eventual ajuste pontual do link em
`App.jsx`, com componente shadcn já instalado (não deve exigir
`npx shadcn add`), mas exige atenção a paridade visual (cores, tooltip,
dark mode, responsividade) e validação de QA via Playwright.

## 🔗 Dependências
Nenhuma. (Task independente; não depende de nenhuma outra task em andamento no backlog.)

---

## 📚 Referências
- [Worktree Workflow](.kiro/docs/worktree-workflow.md)
- [Worktree Steering](.kiro/docs/worktree-steering.md)
- [Task Template](.kiro/docs/task-template-with-worktree.md)
- [Especificação do PO](.kiro/agents/po/especificacao.md)
- Nota de estudo sobre a implementação atual: `docs/grafico-tasks-por-prioridade.md`
- Arquivo principal a alterar: `client/src/components/Analytics.jsx`
- Componente de chart shadcn já instalado: `client/src/components/ui/chart.jsx`
- Link "Ver Analytics" na Home: `client/src/App.jsx` (~linhas 251-260)
- Task de referência (mesmo racional de migração para shadcn/ui):
  `.kiro/tasks/004-feat-datepicker-shadcn.md` (em andamento no momento da criação desta task)
