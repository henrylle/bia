# Task 013 - Botão Add New Task Amarelo com Letra Preta

## 🔧 Configuração Inicial (LEIA ANTES DE INICIAR)

### Agent Responsável
**dev** - Este agent deve iniciar a implementação.

### Branch Base
**SEMPRE `ia-main`**

### Worktree
Esta task será implementada em worktree isolado em `.kiro/worktrees/013-botao-add-new-task-amarelo/`

---

## ⚠️ CHECKLIST DE INÍCIO (OBRIGATÓRIO)

Antes de começar a implementar, o agent deve:

- [ ] **Verificar branch atual:** `git branch --show-current`
  - Se não estiver em `ia-main`, **PERGUNTAR** ao usuário se pode trocar
  - Aguardar autorização
  - Após autorização: `git checkout ia-main && git pull origin ia-main`

- [ ] **Mover task para doing:**
  ```bash
  mv .kiro/tasks/013-botao-add-new-task-amarelo.md .kiro/tasks/doing/
  git add .kiro/tasks/
  git commit -m "move: task 013 para doing"
  git push origin ia-main
  ```

- [ ] **Criar worktree:**
  ```bash
  git worktree add .kiro/worktrees/013-botao-add-new-task-amarelo -b feature/013-botao-add-new-task-amarelo ia-main
  cd .kiro/worktrees/013-botao-add-new-task-amarelo
  git branch --show-current  # Confirmar branch correto
  ```

---

## 📋 Descrição da Task
Alterar a cor do botão "Add New Task" para amarelo com texto preto.

## 🎯 Critérios de Aceitação
- [ ] O botão "Add New Task" deve ter fundo amarelo (`#FFD700`)
- [ ] O texto do botão deve ser preto (`#000000`)
- [ ] O hover do botão deve manter harmonia visual (ex: amarelo mais escuro)
- [ ] Nenhum outro botão da aplicação deve ser afetado

## ✅ Definição de Pronto (DoD)
- [ ] Código implementado no worktree isolado
- [ ] Build do frontend realizado sem erros
- [ ] Teste visual confirmado no browser
- [ ] Commit e push no branch `feature/013-botao-add-new-task-amarelo`

## 🔧 Observações Técnicas
- **Componente:** `client/src/components/AddTask.jsx`
- **CSS:** verificar o arquivo de estilos do botão (provavelmente `client/src/index.css` ou arquivo CSS específico)
- O botão tem a classe `btn btn-block success` — criar estilo específico ou sobrescrever para este botão

## 💡 Solução Sugerida

### CSS
```css
.add-form .btn.success {
  background-color: #FFD700;
  color: #000000;
}

.add-form .btn.success:hover {
  background-color: #e6c200;
  color: #000000;
}
```

---

## ⚠️ FINALIZAÇÃO DA TASK (OBRIGATÓRIO)

Quando o agent concluir a implementação:

### 1. Verificação Final
```bash
pwd
# Deve estar em: /caminho/.kiro/worktrees/013-botao-add-new-task-amarelo

git branch --show-current
# Deve mostrar: feature/013-botao-add-new-task-amarelo
```

### 2. Commit e Push Final
```bash
git add .
git commit -m "feat: altera cor do botão Add New Task para amarelo com texto preto"
git push -u origin feature/013-botao-add-new-task-amarelo
```

### 3. Voltar para Raiz e Notificar PO
```bash
cd ../../..
```

**NOTIFICAR O PO:**
> "Task 013 concluída. Botão 'Add New Task' alterado para amarelo com texto preto. Branch `feature/013-botao-add-new-task-amarelo` com push realizado. Aguardando revisão do PO para encerramento e abertura de PR."

**⚠️ NÃO REMOVER O WORKTREE. Apenas o PO faz isso após o PR ser mergeado.**

---

## 🎯 ENCERRAMENTO PELO PO (QUANDO NOTIFICADO)

### 1. Revisão
```bash
cd .kiro/worktrees/013-botao-add-new-task-amarelo
# Revisar código, testar visualmente no browser
```

### 2. Aprovar e Mover para Done
```bash
cd ../../..
mv .kiro/tasks/doing/013-botao-add-new-task-amarelo.md .kiro/tasks/done/
git checkout ia-main
git add .kiro/tasks/
git commit -m "move: task 013 para done"
git push origin ia-main
```

### 3. Abrir Pull Request
```bash
cd .kiro/worktrees/013-botao-add-new-task-amarelo
git branch --show-current
# Deve mostrar: feature/013-botao-add-new-task-amarelo

gh pr create --base ia-main --title "013: Botão Add New Task amarelo com texto preto" --body "Closes task 013"
```

### 4. Após PR Mergeado
```bash
cd ../../..
git worktree remove .kiro/worktrees/013-botao-add-new-task-amarelo
git worktree prune
git branch -d feature/013-botao-add-new-task-amarelo
```

---

## 📚 Referências
- [Worktree Workflow](.kiro/docs/worktree-workflow.md)
- [Worktree Steering](.kiro/docs/worktree-steering.md)
- [Task Template](.kiro/docs/task-template-with-worktree.md)
