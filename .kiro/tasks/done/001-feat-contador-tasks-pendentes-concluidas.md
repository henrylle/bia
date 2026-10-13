# 001 - Contador de Tasks Pendentes vs. Concluídas na Home

## 🔧 Configuração Inicial (LEIA ANTES DE INICIAR)

### Agent Responsável
**dev** - Este agent deve iniciar a implementação. Ao concluir, deve chamar o
**qa** para validar via Playwright antes de notificar o PO.

### Branch Base
**SEMPRE `ia-main`**

### Worktree
Esta task será implementada em worktree isolado em
`.kiro/worktrees/001-feat-contador-tasks-pendentes-concluidas/`

### Escopo
- **Somente frontend** (`client/`). **Não alterar nada em `api/`.**
- Não existe hoje, no modelo de dados da API, um campo de "conclusão" de
  task (o modelo atual de `Tarefa` tem `uuid`, `titulo`, `dia_atividade` e
  `importante` — este último é usado para a estrela de prioridade, não
  para status de conclusão). Ver decisão de escopo na seção
  [📊 Notas Técnicas](#-notas-técnicas) antes de implementar.

---

## ⚠️ CHECKLIST DE INÍCIO (OBRIGATÓRIO)

Antes de começar a implementar, o agent deve:

- [x] **Verificar branch atual:** `git branch --show-current`
  - Se não estiver em `ia-main`, **PERGUNTAR** ao usuário se pode trocar
  - Aguardar autorização
  - Após autorização: `git checkout ia-main && git pull origin ia-main`

- [x] **Mover task para doing:**
  ```bash
  mv .kiro/tasks/001-feat-contador-tasks-pendentes-concluidas.md .kiro/tasks/doing/
  git add .kiro/tasks/
  git commit -m "move: task 001 para doing"
  git push origin ia-main
  ```

- [x] **Criar worktree:**
  ```bash
  git worktree add .kiro/worktrees/001-feat-contador-tasks-pendentes-concluidas -b feature/001-feat-contador-tasks-pendentes-concluidas ia-main
  cd .kiro/worktrees/001-feat-contador-tasks-pendentes-concluidas
  git branch --show-current  # Confirmar branch correto
  ```

---

## 📋 Tipo
**feat** - Nova funcionalidade de interface (indicador visual) na Home.

## 📝 Resumo
Adicionar um pequeno indicador na Home, acima ou ao lado da lista de tasks,
mostrando a contagem de tasks pendentes e concluídas (ex.: "3 pendentes · 5
concluídas"), atualizando dinamicamente conforme tasks são criadas,
marcadas como concluídas/pendentes ou removidas.

## 📖 Descrição
Como usuário do BIA, eu quero ver rapidamente quantas das minhas tasks
ainda estão pendentes e quantas já concluí, para que eu tenha uma noção
imediata do meu progresso sem precisar contar manualmente os itens da
lista.

## ✅ Critérios de Aceitação

### Funcionalidades Principais
- [x] Existe um indicador textual na Home, posicionado acima ou ao lado da
      lista de tasks (ex.: entre o formulário `AddTask` e a lista
      `Tasks`), exibindo a contagem no formato "X pendentes · Y
      concluídas" (separador e wording podem ser ajustados levemente,
      desde que a informação de pendentes e concluídas fique clara).
- [x] Cada task passa a ter uma forma de marcar/desmarcar como
      **concluída** na interface (ex.: um checkbox no componente `Task`,
      distinto da estrela de "importante" já existente).
- [x] O contador reflete corretamente o estado local das tasks: task nova
      entra como pendente; ao marcar/desmarcar como concluída, o contador
      atualiza; ao remover uma task, o contador também atualiza.
- [x] Quando não há tasks (lista vazia), o contador não é exibido — ou
      exibe "0 pendentes · 0 concluídas" —, mantendo consistência com o
      `empty-state` já existente na Home.

### Interface e UX
- [x] O indicador segue o padrão visual já existente no projeto
      (`client/src/index.css`), sem introduzir bibliotecas novas de UI.
- [x] O checkbox/controle de "concluída" tem contraste e área de clique
      adequados, e não conflita visualmente com os botões já existentes
      de "importante" (estrela) e "excluir" (X) no componente `Task`.
- [x] Responsivo: o indicador continua legível em telas estreitas
      (mobile), sem quebrar o layout da Home.

### Integração
- [x] Nenhum arquivo dentro de `api/` é alterado nesta task.
- [x] O estado de "concluída" é tratado no client (estado do React em
      `App.jsx`/`Tasks.jsx`/`Task.jsx`, conforme decisão de implementação
      do dev) — **não é necessário persistir via API** (ver Notas
      Técnicas).

## 🧪 Testes
- [x] Testar funcionalidade localmente (build/dev do client)
- [ ] Validar cenário: criar task nova → contador de pendentes incrementa
- [ ] Validar cenário: marcar task como concluída → contador de
      concluídas incrementa e pendentes decrementa
- [ ] Validar cenário: desmarcar task concluída → volta para pendente
- [ ] Validar cenário: remover task (pendente e concluída) → contador
      correspondente decrementa
- [ ] Validar cenário de lista vazia (sem tasks)
- [ ] Testar responsividade (mobile/desktop)

## 📚 Definição de Pronto (DoD)
- [x] Código implementado e testado
- [ ] Todos os itens do checklist marcados ✅ (pendente validação do qa)
- [x] Commits descritivos e frequentes
- [x] Push do branch realizado
- [x] Código segue padrões do projeto (React funcional, hooks, CSS
      existente em `client/src/index.css`)
- [x] Nenhuma alteração em `api/`
- [ ] QA validou via Playwright que o contador aparece e atualiza
      corretamente (ver seção QA abaixo)
- [x] Rebuild dos containers realizado conforme regra do dev
      (`.kiro/agents/dev/instrucoes.md`) e `/api/versao` respondendo

---

## 🎯 CHECKLIST DE IMPLEMENTAÇÃO (MARCAR DURANTE O TRABALHO)

### Configuração
- [x] Worktree criado e branch correto confirmado
- [x] Ambiente de desenvolvimento configurado no worktree
- [x] Dependências instaladas (se necessário)

### Desenvolvimento (dev)
- [x] Definir onde o estado de "concluída" será mantido (sugestão: junto
      ao array `tasks` em `App.jsx`, como campo client-only, ex.
      `concluida: false` por padrão ao criar a task)
- [x] Implementar handler de toggle de conclusão (ex. `toggleConcluida`),
      análogo ao `toggleReminder` já existente, porém sem chamada à API
- [x] Adicionar controle visual (checkbox) no componente `Task.jsx` para
      marcar/desmarcar conclusão
- [x] Criar componente (ou trecho) do indicador/contador na Home,
      calculando pendentes/concluídas a partir do array `tasks`
- [x] Posicionar o indicador acima ou ao lado da lista (`Tasks.jsx`) na
      `HomePage` de `App.jsx`
- [x] Estilizar o indicador em `client/src/index.css`, reaproveitando
      padrões visuais existentes (cores, espaçamento, cards)
- [x] Garantir que criar, concluir/desconcluir e remover tasks atualiza o
      contador dinamicamente (sem reload de página)

### Testes
- [x] Testes manuais realizados cobrindo os cenários da seção 🧪 Testes
      (validação de código/lógica + build/dev server pelo dev; validação
      interativa completa via Playwright a cargo do qa)
- [x] Cenários de borda testados (lista vazia, todas pendentes, todas
      concluídas) — via revisão de código (`tasks.length === 0` oculta o
      contador; contagens usam `filter` sobre o array completo)

### Finalização (dev)
- [x] Código revisado
- [x] Commits finalizados com mensagens descritivas
- [x] Push do branch realizado
- [x] Rebuild completo dos containers (`docker compose down` → `build` →
      `up`) e confirmação de que `/api/versao` responde
- [x] Notificar o **qa** para validação via Playwright

### Validação (qa)
- [x] Abrir a Home via Playwright e confirmar que o contador aparece com
      a contagem correta ao carregar a página
- [x] Criar uma nova task via UI e validar que "pendentes" incrementa
- [x] Marcar uma task como concluída via UI e validar que o contador
      atualiza ("pendentes" decrementa, "concluídas" incrementa)
- [x] Desmarcar a task concluída e validar que o contador volta ao estado
      anterior
- [x] Remover uma task (pendente e concluída, em execuções separadas) e
      validar que o contador correspondente decrementa
- [x] Validar comportamento com lista vazia (sem tasks)
- [x] Registrar evidências (prints/logs do Playwright) e notificar o PO
      com o resultado da validação

**Nota (qa):** Primeira rodada encontrou `GET /api/tarefas` retornando
500 (`relation "Tarefas" does not exist"`) por migrações ausentes no
banco do worktree — não era bug desta task (client-only, `api/` intacto,
confirmado byte-a-byte igual a `ia-main`). Após a correção das
migrações, **revalidado integralmente contra API/banco reais (sem
mock)**: todos os 7 cenários acima confirmados via chamadas reais
`GET/POST/DELETE` (200), toggle de conclusão confirmado client-only (sem
chamada à API), banco limpo ao final (`GET /api/tarefas` → `[]`).
Evidências: `mobile-counter.png`, `desktop-counter.png`,
`dark-counter.png` (raiz do repo) e log de console
`.playwright-mcp/console-2026-08-31T13-26-01-544Z.log`.

### Finalização (qa)
- [x] Todos os itens acima marcados ✅
- [x] Notificar o PO com o resultado da validação (aprovado ou apontando
      ajustes necessários para o dev)

**Resultado:** ✅ **Aprovado em QA** — validado ponta a ponta com API e
banco reais (revalidação sem mock), pronto para revisão de encerramento
pelo PO.

---

## ⚠️ FINALIZAÇÃO DA TASK (OBRIGATÓRIO)

Quando o **dev** concluir a implementação:

### 1. Verificação Final
```bash
# Garantir que está no worktree correto
pwd
# Deve estar em: /caminho/do/projeto/.kiro/worktrees/001-feat-contador-tasks-pendentes-concluidas

# Verificar branch
git branch --show-current
# Deve mostrar: feature/001-feat-contador-tasks-pendentes-concluidas
```

### 2. Commit e Push Final
```bash
git add .
git commit -m "feat: finaliza implementação da task 001"
git push origin feature/001-feat-contador-tasks-pendentes-concluidas
```

### 3. Chamar o QA
O dev deve notificar o **qa** para que ele valide a funcionalidade no
mesmo worktree/branch (ou branch publicado), seguindo o checklist de
"Validação (qa)" acima.

### 4. Voltar para Raiz e Notificar PO
```bash
cd ../../..  # Voltar para raiz do projeto
```

**NOTIFICAR O PO (após validação do qa):**
> "Task 001 concluída pelo dev e validada pelo qa. Todos os itens do
> checklist marcados. Branch
> `feature/001-feat-contador-tasks-pendentes-concluidas` com push
> realizado. Aguardando revisão do PO para encerramento e abertura de
> PR."

**⚠️ NÃO REMOVER O WORKTREE. Apenas o PO faz isso após o PR ser
mergeado.**

---

## 🎯 ENCERRAMENTO PELO PO (QUANDO NOTIFICADO)

### 1. Revisão
```bash
# Entrar no worktree para revisar
cd .kiro/worktrees/001-feat-contador-tasks-pendentes-concluidas

# Revisar código, testar funcionalidade
# Verificar se todos os itens estão ✅ (incluindo validação do qa)
```

### 2. Aprovar e Mover para Done
```bash
# Voltar para raiz
cd ../../..

# Mover task para done
mv .kiro/tasks/doing/001-feat-contador-tasks-pendentes-concluidas.md .kiro/tasks/done/

# Commit e push no ia-main
git checkout ia-main
git add .kiro/tasks/
git commit -m "move: task 001 para done"
git push origin ia-main
```

### 3. Abrir Pull Request
```bash
# ANTES de abrir PR: confirmar que está no branch da feature
cd .kiro/worktrees/001-feat-contador-tasks-pendentes-concluidas
git branch --show-current
# Deve mostrar: feature/001-feat-contador-tasks-pendentes-concluidas

# Abrir PR contra ia-main
gh pr create --base ia-main --title "001: Contador de tasks pendentes vs. concluídas na Home" --body "Closes task 001"
```

### 4. Após PR Mergeado
```bash
# Voltar para raiz
cd ../../..

# Remover worktree
git worktree remove .kiro/worktrees/001-feat-contador-tasks-pendentes-concluidas

# Ou com força se necessário:
# git worktree remove --force .kiro/worktrees/001-feat-contador-tasks-pendentes-concluidas

# Limpar registros
git worktree prune

# (Opcional) Deletar branch local
git branch -d feature/001-feat-contador-tasks-pendentes-concluidas

# Notificar conclusão
```

---

## 📊 Notas Técnicas

### Decisão de escopo: status de "concluída" é client-only nesta task
O modelo atual de `Tarefa` na API (`api/`) não possui um campo de
conclusão — apenas `importante` (usado para a estrela de prioridade, já
consumida pelo endpoint `PUT /api/tarefas/update_priority/:uuid`). Como
esta task é **estritamente frontend** (não deve alterar `api/`), a
marcação de "concluída"/"pendente" deve ser implementada como **estado
local do client** (ex.: campo adicional no objeto de task dentro do
estado do React, inicializado como `false` ao carregar/criar tasks),
**sem persistência no backend**. Isso significa que o status de conclusão
não sobrevive a um reload de página — comportamento aceitável para o
escopo desta task.

Uma eventual task futura (`feat`, fora deste escopo) poderia propor
adicionar um campo `concluida` real no modelo `Tarefa` da API + migração
de banco, para persistir esse status entre sessões. Isso NÃO faz parte
desta task e deve ser sinalizado como sugestão de backlog, não
implementado aqui.

### Pontos de referência no código atual
- `client/src/App.jsx` — estado `tasks`, handlers `addTask`,
  `deleteTask`, `toggleReminder` e componente `HomePage`.
- `client/src/components/Tasks.jsx` — lista paginada de tasks.
- `client/src/components/Task.jsx` — card individual de task, já possui
  botões de "importante" (estrela) e "excluir" (X).
- `client/src/index.css` — estilos existentes para reaproveitar padrão
  visual (cards, `analytics-link-wrapper`, `empty-state`, etc.).

## 💼 Valor de Negócio
**Médio** - Melhora a percepção de progresso do usuário na Home sem
exigir navegação até a tela de Analytics, aumentando o valor percebido do
app de tasks com baixo esforço de implementação.

## 🎯 Estimativa
**3 Story Points** - Envolve novo estado no client, um novo controle de
UI por task, um componente/indicador de contagem e validação de QA via
Playwright; sem complexidade de backend.

## 🔗 Dependências
Nenhuma.

---

## 📚 Referências
- [Worktree Workflow](.kiro/docs/worktree-workflow.md)
- [Worktree Steering](.kiro/docs/worktree-steering.md)
- [Task Template](.kiro/docs/task-template-with-worktree.md)
- [Especificação do PO](.kiro/agents/po/especificacao.md)
