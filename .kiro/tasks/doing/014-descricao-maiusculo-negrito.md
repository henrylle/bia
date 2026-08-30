# Task 014 - Descrição da Tarefa em Maiúsculo e Negrito

## 🔧 Configuração Inicial (LEIA ANTES DE INICIAR)

### Agent Responsável
**dev** - Este agent deve iniciar a implementação.

### Branch Base
**SEMPRE `ia-main`**

### Worktree
Esta task será implementada em worktree isolado em `.kiro/worktrees/014-descricao-maiusculo-negrito/`

---

## ⚠️ CHECKLIST DE INÍCIO (OBRIGATÓRIO)

Antes de começar a implementar, o agent deve:

- [x] **Verificar branch atual:** `git branch --show-current`
  - Se não estiver em `ia-main`, **PERGUNTAR** ao usuário se pode trocar
  - Aguardar autorização
  - Após autorização: `git checkout ia-main && git pull origin ia-main`

- [x] **Mover task para doing:**
  ```bash
  mv .kiro/tasks/014-descricao-maiusculo-negrito.md .kiro/tasks/doing/
  git add .kiro/tasks/
  git commit -m "move: task 014 para doing"
  git push origin ia-main
  ```

- [x] **Criar worktree:**
  ```bash
  git worktree add .kiro/worktrees/014-descricao-maiusculo-negrito -b feature/014-descricao-maiusculo-negrito ia-main
  cd .kiro/worktrees/014-descricao-maiusculo-negrito
  git branch --show-current  # Confirmar branch correto
  ```

---

## 📋 Descrição da Task
Exibir o texto da descrição (título) de cada tarefa na listagem em letras maiúsculas e negrito.

## 🎯 Critérios de Aceitação
- [x] O título/descrição de cada tarefa deve aparecer em letras maiúsculas
- [x] O título/descrição de cada tarefa deve aparecer em negrito (bold)
- [x] A alteração deve ser apenas visual — o valor salvo no banco **não deve ser alterado**
- [x] Todas as tarefas existentes e novas devem seguir o novo estilo

## ✅ Definição de Pronto (DoD)
- [x] Código implementado no worktree isolado
- [x] Build do frontend realizado sem erros
- [ ] Teste visual confirmado no browser
- [x] Commit e push no branch `feature/014-descricao-maiusculo-negrito`

## 🔧 Observações Técnicas
- **Componente:** `client/src/components/Task.jsx`
- **Abordagem:** aplicar via CSS no elemento que exibe o título da tarefa
- Usar `text-transform: uppercase` para maiúsculas
- Usar `font-weight: bold` ou `font-weight: 700` para negrito
- **Não alterar** o dado enviado para a API nem o estado local

## 💡 Solução Sugerida

### CSS
```css
.task h3,
.task .task-title {
  text-transform: uppercase;
  font-weight: 700;
}
```

> Identificar o seletor correto lendo o componente `Task.jsx` e seu CSS correspondente.

---

## ⚠️ FINALIZAÇÃO DA TASK (OBRIGATÓRIO)

Quando o agent concluir a implementação:

### 1. Verificação Final
```bash
pwd
# Deve estar em: /caminho/.kiro/worktrees/014-descricao-maiusculo-negrito

git branch --show-current
# Deve mostrar: feature/014-descricao-maiusculo-negrito
```

### 2. Commit e Push Final
```bash
git add .
git commit -m "feat: exibe descrição da tarefa em maiúsculo e negrito"
git push -u origin feature/014-descricao-maiusculo-negrito
```

### 3. Voltar para Raiz e Notificar PO
```bash
cd ../../..
```

**NOTIFICAR O PO:**
> "Task 014 concluída. Descrição das tarefas agora aparece em maiúsculo e negrito. Branch `feature/014-descricao-maiusculo-negrito` com push realizado. Aguardando revisão do PO para encerramento e abertura de PR."

**⚠️ NÃO REMOVER O WORKTREE. Apenas o PO faz isso após o PR ser mergeado.**

---

## 🎯 ENCERRAMENTO PELO PO (QUANDO NOTIFICADO)

### 1. Revisão
```bash
cd .kiro/worktrees/014-descricao-maiusculo-negrito
# Revisar código, testar visualmente no browser
```

### 2. Aprovar e Mover para Done
```bash
cd ../../..
mv .kiro/tasks/doing/014-descricao-maiusculo-negrito.md .kiro/tasks/done/
git checkout ia-main
git add .kiro/tasks/
git commit -m "move: task 014 para done"
git push origin ia-main
```

### 3. Abrir Pull Request
```bash
cd .kiro/worktrees/014-descricao-maiusculo-negrito
git branch --show-current
# Deve mostrar: feature/014-descricao-maiusculo-negrito

gh pr create --base ia-main --title "014: Descrição da tarefa em maiúsculo e negrito" --body "Closes task 014"
```

### 4. Após PR Mergeado
```bash
cd ../../..
git worktree remove .kiro/worktrees/014-descricao-maiusculo-negrito
git worktree prune
git branch -d feature/014-descricao-maiusculo-negrito
```

---

## 📚 Referências
- [Worktree Workflow](.kiro/docs/worktree-workflow.md)
- [Worktree Steering](.kiro/docs/worktree-steering.md)
- [Task Template](.kiro/docs/task-template-with-worktree.md)
