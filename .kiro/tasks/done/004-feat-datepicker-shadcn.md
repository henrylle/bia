# [004] - Substituir react-datepicker pelo Calendar/Popover do shadcn/ui no campo Data/Prazo

## 🔧 Configuração Inicial (LEIA ANTES DE INICIAR)

### Agent Responsável
**dev** - Este agent deve iniciar a implementação.

### Branch Base
**SEMPRE `ia-main`**

### Worktree
Esta task será implementada em worktree isolado em `.kiro/worktrees/004-feat-datepicker-shadcn/`

---

## ⚠️ CHECKLIST DE INÍCIO (OBRIGATÓRIO)

Antes de começar a implementar, o agent deve:

- [x] **Verificar branch atual:** `git branch --show-current`
  - Se não estiver em `ia-main`, **PERGUNTAR** ao usuário se pode trocar
  - Aguardar autorização
  - Após autorização: `git checkout ia-main && git pull origin ia-main`

- [x] **Mover task para doing:**
  ```bash
  mv .kiro/tasks/004-feat-datepicker-shadcn.md .kiro/tasks/doing/
  git add .kiro/tasks/
  git commit -m "move: task 004 para doing"
  git push origin ia-main
  ```

- [x] **Criar worktree:**
  ```bash
  git worktree add .kiro/worktrees/004-feat-datepicker-shadcn -b feature/004-feat-datepicker-shadcn ia-main
  cd .kiro/worktrees/004-feat-datepicker-shadcn
  git branch --show-current  # Confirmar branch correto
  ```

---

## 📋 Tipo
**feat** - Substituição de componente de UI para alinhar com o design system do projeto (shadcn/ui).

## 📝 Resumo
Trocar o date picker do campo "Data/Prazo" do formulário "Add New Task" — hoje implementado com a
lib externa `react-datepicker` (commit `6f5863f` "feat: implementa calendário no campo Data/Prazo")
— pelo componente nativo `Calendar` + `Popover` do shadcn/ui, que já é o padrão visual/técnico usado
no restante do projeto.

## 📖 Descrição
Como usuário do BIA, eu quero que o seletor de data do campo "Data/Prazo" tenha a mesma cara e
comportamento dos demais componentes da aplicação (shadcn/ui com Tailwind, incluindo suporte a dark
mode), para que a experiência visual seja consistente em toda a tela de tarefas.

Como time de desenvolvimento, queremos remover a dependência `react-datepicker` (biblioteca externa
com CSS customizado próprio, em `client/src/styles/datepicker.css`) e usar o componente de calendário
já integrado ao design system do projeto (shadcn/ui, que internamente usa `react-day-picker` e os
tokens de cor/tema já usados nos demais componentes em `client/src/components/ui/`), reduzindo
inconsistência visual e superfície de manutenção (duas abordagens de estilização convivendo no
mesmo formulário).

**Contexto técnico observado no arquivo atual** (`client/src/components/AddTask.jsx`):
- Import de `DatePicker` do `react-datepicker`, `registerLocale`/`ptBR` do `date-fns/locale/pt-BR`,
  CSS da lib (`react-datepicker/dist/react-datepicker.css`) e CSS customizado próprio
  (`../styles/datepicker.css`).
- Estado `dia` guarda um objeto `Date` (ou `null`); no `onSubmit`, a função `formatDateToString`
  converte esse `Date` para string no formato `dd/MM/yyyy` (via `toLocaleDateString('pt-BR')`) antes
  de montar o payload `dia_atividade` enviado para `onAdd`/API.
- Props hoje usadas no `DatePicker`: `selected`, `onChange`, `locale="pt-BR"`,
  `dateFormat="dd/MM/yyyy"`, `placeholderText="Quando?"`, `isClearable`, `showYearDropdown`,
  `scrollableYearDropdown`, `yearDropdownItemNumber={15}`.
- **Verificado nesta revisão:** a pasta `client/src/components/ui/` hoje só contém `card.jsx` e
  `chart.jsx` — os componentes `calendar` e `popover` do shadcn **ainda não existem** no projeto e
  precisam ser adicionados.

## ✅ Critérios de Aceitação

### Funcionalidades Principais
- [x] Componentes shadcn `calendar` e `popover` adicionados em `client/src/components/ui/` via MCP
      shadcn (checar antes se já existem — nesta revisão não existiam).
- [x] Campo "Data/Prazo" em `AddTask.jsx` reimplementado usando `Popover` + `Calendar` do shadcn/ui
      no lugar do `DatePicker` do `react-datepicker`.
- [x] Dependência `react-datepicker` removida do `client/package.json` (e do lockfile) e sem nenhum
      `import` residual dela em qualquer arquivo do projeto.
- [x] Arquivo `client/src/styles/datepicker.css` (ou qualquer CSS exclusivo do react-datepicker)
      removido; se houver import desse CSS em outro arquivo, remover também.
- [x] O valor da data continua sendo convertido/formatado como **string** (`dd/MM/yyyy`, pt-BR) antes
      de ser enviado no payload da tarefa (`dia_atividade`) — mesmo contrato de dados que já existe
      hoje com `formatDateToString`. Nenhuma mudança de schema, migration ou tipo de dado no backend.

### Interface e UX
- [x] Clicar no campo/input de data abre o calendário (via `Popover`).
- [x] Navegação entre meses e anos funcional dentro do `Calendar`.
- [x] Selecionar uma data no calendário preenche o input no formato `dd/MM/yyyy` e fecha o popover.
- [x] Existe uma forma de limpar a data selecionada, equivalente ao `isClearable` que existia na
      implementação anterior (ex.: botão "Limpar" dentro do popover ou ícone de limpar no input).
- [x] Visual do calendário/popover consistente com o tema (incluindo dark mode) usado nos demais
      componentes shadcn do projeto.

### Integração
- [x] Criar uma tarefa nova selecionando uma data pelo novo componente e confirmar que ela é salva
      corretamente (via API) e exibida com a data certa na listagem de tarefas.
- [x] Tarefas já existentes (criadas antes desta mudança) continuam sendo exibidas e editadas
      normalmente — nenhuma regressão no fluxo de listagem/edição por causa da troca do componente.

## 🧪 Testes
- [x] Testar funcionalidade localmente (`docker compose up --build`, conforme regra do agent `dev`)
- [x] Validar cenário de sucesso: criar tarefa com data selecionada via novo calendário
- [x] Validar cenário de "limpar data" e envio sem data preenchida
- [x] Validar responsividade do popover/calendário em telas menores
- [x] Validar visual em light e dark mode

## 📚 Definição de Pronto (DoD)
- [x] Código implementado e testado
- [x] Todos os itens do checklist marcados ✅
- [x] Commits descritivos e frequentes
- [x] Push do branch realizado
- [x] Código segue padrões do projeto (shadcn/ui, Tailwind, componentes em `client/src/components/ui/`)
- [x] Nenhuma referência residual a `react-datepicker` no código-fonte ou em `package.json`/lockfile

---

## 🎯 CHECKLIST DE IMPLEMENTAÇÃO (MARCAR DURANTE O TRABALHO)

### Configuração
- [x] Worktree criado e branch correto confirmado
- [x] Ambiente de desenvolvimento configurado no worktree
- [x] Dependências instaladas (se necessário)

### Desenvolvimento
- [x] Verificar via MCP shadcn se `calendar` e `popover` já existem em `client/src/components/ui/`;
      se não, adicioná-los
- [x] Reimplementar o campo Data/Prazo em `client/src/components/AddTask.jsx` usando
      `Popover` + `Calendar` do shadcn/ui, mantendo locale pt-BR e formato `dd/MM/yyyy`
- [x] Manter a conversão da data para string (`dia_atividade`) antes de enviar para a API — sem
      alterar payload, backend, models ou migrations
- [x] Implementar opção de limpar a data selecionada (equivalente ao `isClearable` anterior)
- [x] Remover import e uso de `react-datepicker` e `date-fns/locale/pt-BR` (se exclusivo desse uso)
      em `AddTask.jsx`
- [x] Remover dependência `react-datepicker` de `client/package.json` (e lockfile)
- [x] Remover `client/src/styles/datepicker.css` e qualquer import desse arquivo
- [x] Conferir se não sobrou nenhuma outra referência a `react-datepicker` no repositório
      (`grep -r "react-datepicker" client/`)

### Testes
- [x] Testes manuais realizados (abrir calendário, navegar mês/ano, selecionar data, limpar data)
- [x] Cenário de criação de tarefa com data testado ponta a ponta (UI → API → listagem)
- [x] Cenário de erro/edge case testado (ex.: submeter sem selecionar data)
- [x] Visual conferido em dark mode

### Finalização
- [x] Código revisado
- [x] Commits finalizados com mensagens descritivas
- [x] Push do branch realizado
- [x] Todos os itens acima marcados ✅

---

## ⚠️ FINALIZAÇÃO DA TASK (OBRIGATÓRIO)

Quando o agent concluir a implementação:

### 1. Verificação Final
```bash
# Garantir que está no worktree correto
pwd
# Deve estar em: /caminho/do/projeto/.kiro/worktrees/004-feat-datepicker-shadcn

# Verificar branch
git branch --show-current
# Deve mostrar: feature/004-feat-datepicker-shadcn
```

### 2. Commit e Push Final
```bash
git add .
git commit -m "feat: finaliza implementação da task 004"
git push origin feature/004-feat-datepicker-shadcn
```

### 3. Voltar para Raiz e Notificar PO
```bash
cd ../../..  # Voltar para raiz do projeto
```

**NOTIFICAR O PO:**
> "Task 004 concluída. Todos os itens do checklist marcados. Branch `feature/004-feat-datepicker-shadcn` com push realizado. Aguardando revisão do PO para encerramento e abertura de PR."

**⚠️ NÃO REMOVER O WORKTREE. Apenas o PO faz isso após o PR ser mergeado.**

---

## 🎯 ENCERRAMENTO PELO PO (QUANDO NOTIFICADO)

### 1. Revisão
```bash
# Entrar no worktree para revisar
cd .kiro/worktrees/004-feat-datepicker-shadcn

# Revisar código, testar funcionalidade
# Verificar se todos os itens estão ✅
```

### 2. Aprovar e Mover para Done
```bash
# Voltar para raiz
cd ../../..

# Mover task para done
mv .kiro/tasks/doing/004-feat-datepicker-shadcn.md .kiro/tasks/done/

# Commit e push no ia-main
git checkout ia-main
git add .kiro/tasks/
git commit -m "move: task 004 para done"
git push origin ia-main
```

### 3. Abrir Pull Request
```bash
# ANTES de abrir PR: confirmar que está no branch da feature (NUNCA em ia-main)
cd .kiro/worktrees/004-feat-datepicker-shadcn
git branch --show-current
# Comparar a saída com o nome esperado: feature/004-feat-datepicker-shadcn
# Se não bater (ex.: mostrar "ia-main"), PARAR — NÃO rodar o gh pr create abaixo

# Só prosseguir se o branch confirmado bater com o esperado:
gh pr create --base ia-main --title "004: Substituir react-datepicker pelo Calendar/Popover do shadcn/ui" --body "Closes task 004"
```

### 4. Após PR Mergeado
```bash
# Voltar para raiz
cd ../../..

# Remover worktree
git worktree remove .kiro/worktrees/004-feat-datepicker-shadcn

# Ou com força se necessário:
# git worktree remove --force .kiro/worktrees/004-feat-datepicker-shadcn

# Limpar registros
git worktree prune

# (Opcional) Deletar branch local
git branch -d feature/004-feat-datepicker-shadcn

# Notificar conclusão
```

---

## 📊 Notas Técnicas
- Arquivo principal a alterar: `client/src/components/AddTask.jsx`.
- Remover: `client/src/styles/datepicker.css` e dependência `react-datepicker` do
  `client/package.json`.
- Adicionar via MCP shadcn (se ainda não existirem em `client/src/components/ui/`): `calendar.jsx`,
  `popover.jsx`. O componente `Calendar` do shadcn usa `react-day-picker` internamente — confirmar
  que essa dependência (ou equivalente) já está disponível/instalada no client ao adicionar o
  componente via shadcn CLI/MCP.
- Manter locale pt-BR (o `Calendar` do shadcn aceita prop `locale`, ex. via `date-fns/locale/ptBR`)
  e o formato de exibição `dd/MM/yyyy` no input.
- O payload enviado para a API (`dia_atividade`) deve continuar como string, sem qualquer alteração
  em `api/controllers`, `api/models` ou `database/migrations`.
- Escopo estritamente frontend (`client/`) — nenhuma alteração de backend.

### Nota técnica adicional (achado durante a implementação)
- O `client/src/index.css` usava diretivas legadas do Tailwind v3 (`@tailwind base/components/utilities`)
  mesmo com `tailwindcss@4` instalado. Nesse modo, o Tailwind v4 não carregava o tema padrão completo
  (faltavam utilities básicas como `rounded-md`, `shadow-sm`/`shadow-md`, `bg-popover`, `border-input`
  etc.), o que já deixava os componentes shadcn existentes (`card.jsx`, `chart.jsx`) sem estilo real
  (não percebido antes porque não estavam em uso visível). Isso quebrava a aceitação de "visual
  consistente com o tema" do `Calendar`/`Popover` novos.
- Corrigido substituindo as diretivas antigas por `@import "tailwindcss";` + `@config
  "../tailwind.config.js";` em `client/src/index.css` (sintaxe de compatibilidade oficial do Tailwind
  v4 para reaproveitar `tailwind.config.js` existente). Validado visualmente (light/dark) via
  Playwright antes/depois do ajuste — screenshots comparativos confirmaram o antes (sem
  radius/shadow/cores do tema) e depois (visual shadcn correto). Esse ajuste também beneficia
  `card.jsx`/`chart.jsx` e qualquer componente shadcn futuro no projeto.
- Também foram adicionados `client/components.json` e `client/jsconfig.json` (baseUrl "." com alias
  `@/*`) para permitir o uso do CLI/MCP `shadcn` no projeto (não existiam antes). Os componentes
  gerados (`calendar.jsx`, `popover.jsx`, `button.jsx` — este último é dependência do `calendar`) foram
  ajustados para usar imports relativos (`../../lib/utils`, `./button`), seguindo o padrão já usado em
  `card.jsx`/`chart.jsx` no projeto (ao invés do alias `@/...` gerado por padrão pelo CLI).

## 💼 Valor de Negócio
**Médio** - Não é uma nova funcionalidade para o usuário final, mas reduz dívida técnica e
inconsistência visual, facilitando manutenção futura e reforçando o padrão de design system
(shadcn/ui) já adotado no restante da aplicação.

## 🎯 Estimativa
**3 Story Points** - Troca de componente já mapeada, escopo restrito a um único arquivo principal
(`AddTask.jsx`) mais remoção de dependência/CSS, mas exige atenção a comportamento (clearable,
navegação de mês/ano, formatação pt-BR) e testes ponta a ponta.

## 🔗 Dependências
Nenhuma. (Task independente; não depende de nenhuma outra task em andamento no backlog.)

---

## 📚 Referências
- [Worktree Workflow](.kiro/docs/worktree-workflow.md)
- [Worktree Steering](.kiro/docs/worktree-steering.md)
- [Task Template](.kiro/docs/task-template-with-worktree.md)
- Commit de referência da implementação atual: `6f5863f` ("feat: implementa calendário no campo Data/Prazo")
- Arquivo atual do formulário: `client/src/components/AddTask.jsx`
- CSS a remover: `client/src/styles/datepicker.css`
