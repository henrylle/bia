# Task 010 - Demo Worktree B - Adicionar Timestamp de Última Atualização

## 🔧 Configuração Inicial (LEIA ANTES DE INICIAR)

### Agent Responsável
**dev** - Este agent deve iniciar a implementação.

### Branch Base
**SEMPRE `ia-main`**

### Worktree
Esta task será implementada em worktree isolado em `.kiro/worktrees/010-feat-demo-worktree-b/`

---

## ⚠️ CHECKLIST DE INÍCIO (OBRIGATÓRIO)

Antes de começar a implementar, o agent deve:

- [ ] **Verificar branch atual:** `git branch --show-current`
  - Se não estiver em `ia-main`, **PERGUNTAR** ao usuário se pode trocar
  - Aguardar autorização
  - Após autorização: `git checkout ia-main && git pull origin ia-main`

- [ ] **Mover task para doing:**
  ```bash
  mv .kiro/tasks/010-feat-demo-worktree-b.md .kiro/tasks/doing/
  git add .kiro/tasks/
  git commit -m "move: task 010 para doing"
  git push origin ia-main
  ```

- [ ] **Criar worktree:**
  ```bash
  git worktree add .kiro/worktrees/010-feat-demo-worktree-b -b feature/010-feat-demo-worktree-b ia-main
  cd .kiro/worktrees/010-feat-demo-worktree-b
  git branch --show-current  # Confirmar branch correto
  ```

---

## 📋 Descrição da Task
Adicionar timestamp mostrando quando foi a última atualização dos dados da API na tela de versão.

## 🎯 Critérios de Aceitação
- [ ] Adicionar estado no componente para armazenar timestamp
- [ ] Exibir "Última atualização: [horário]" abaixo dos dados
- [ ] Formato: "DD/MM/YYYY HH:mm:ss"
- [ ] Atualizar timestamp quando clicar em "Atualizar"

## ✅ Definição de Pronto (DoD)
- [ ] Código implementado no worktree isolado
- [ ] Build do frontend realizado
- [ ] Teste visual confirmado
- [ ] Commit e push no branch `feature/010-feat-demo-worktree-b`

## 🔧 Observações Técnicas
- **Arquivo:** `client/src/pages/Versao.jsx`
- **Estado:** Usar useState para armazenar timestamp
- **Biblioteca:** Pode usar Date nativo do JavaScript
- **Posição:** Rodapé da card de informações

---

## ⚠️ FINALIZAÇÃO DA TASK (OBRIGATÓRIO)

Quando o agent concluir a implementação:

### 1. Verificação Final
```bash
# Garantir que está no worktree correto
pwd
# Deve estar em: /caminho/.kiro/worktrees/010-feat-demo-worktree-b

# Verificar branch
git branch --show-current
# Deve mostrar: feature/010-feat-demo-worktree-b
```

### 2. Commit e Push Final
```bash
git add .
git commit -m "feat: adiciona timestamp de última atualização na tela de versão"
git push -u origin feature/010-feat-demo-worktree-b
```

### 3. Voltar para Raiz e Notificar PO
```bash
cd ../../..  # Voltar para raiz do projeto
```

**NOTIFICAR O PO:**
> "Task 010 concluída. Todos os itens do checklist marcados. Branch `feature/010-feat-demo-worktree-b` com push realizado. Aguardando revisão do PO para encerramento e abertura de PR."

**⚠️ NÃO REMOVER O WORKTREE. Apenas o PO faz isso após o PR ser mergeado.**

---

## 🎯 ENCERRAMENTO PELO PO (QUANDO NOTIFICADO)

### 1. Revisão
```bash
# Entrar no worktree para revisar
cd .kiro/worktrees/010-feat-demo-worktree-b

# Revisar código, testar funcionalidade
# Verificar se todos os itens estão ✅
```

### 2. Aprovar e Mover para Done
```bash
# Voltar para raiz
cd ../../..

# Mover task para done
mv .kiro/tasks/doing/010-feat-demo-worktree-b.md .kiro/tasks/done/

# Commit e push no ia-main
git checkout ia-main
git add .kiro/tasks/
git commit -m "move: task 010 para done"
git push origin ia-main
```

### 3. Abrir Pull Request
```bash
# ANTES de abrir PR: confirmar que está no branch da feature
cd .kiro/worktrees/010-feat-demo-worktree-b
git branch --show-current
# Deve mostrar: feature/010-feat-demo-worktree-b

# Abrir PR contra ia-main
gh pr create --base ia-main --title "010: Adiciona timestamp de última atualização" --body "Closes task 010"
```

### 4. Após PR Mergeado
```bash
# Voltar para raiz
cd ../../..

# Remover worktree
git worktree remove .kiro/worktrees/010-feat-demo-worktree-b

# Ou com força se necessário:
# git worktree remove --force .kiro/worktrees/010-feat-demo-worktree-b

# Limpar registros
git worktree prune

# (Opcional) Deletar branch local
git branch -d feature/010-feat-demo-worktree-b

# Notificar conclusão
```

---

## 📚 Referências
- [Worktree Workflow](.kiro/docs/worktree-workflow.md)
- [Worktree Steering](.kiro/docs/worktree-steering.md)
- [Task Template](.kiro/docs/task-template-with-worktree.md)
