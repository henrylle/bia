# [XXX] - [Título da Task]

## 🔧 Configuração Inicial (LEIA ANTES DE INICIAR)

### Agent Responsável
**[dev/devops/qa]** - Este agent deve iniciar a implementação.

### Branch Base
**SEMPRE `ia-main`**

### Worktree
Esta task será implementada em worktree isolado em `.kiro/worktrees/XXX-tipo-resumo/`

---

## ⚠️ CHECKLIST DE INÍCIO (OBRIGATÓRIO)

Antes de começar a implementar, o agent deve:

- [ ] **Verificar branch atual:** `git branch --show-current`
  - Se não estiver em `ia-main`, **PERGUNTAR** ao usuário se pode trocar
  - Aguardar autorização
  - Após autorização: `git checkout ia-main && git pull origin ia-main`

- [ ] **Mover task para doing:**
  ```bash
  mv .kiro/tasks/XXX-tipo-resumo.md .kiro/tasks/doing/
  git add .kiro/tasks/
  git commit -m "move: task XXX para doing"
  git push origin ia-main
  ```

- [ ] **Criar worktree:**
  ```bash
  git worktree add .kiro/worktrees/XXX-tipo-resumo -b feature/XXX-tipo-resumo ia-main
  cd .kiro/worktrees/XXX-tipo-resumo
  git branch --show-current  # Confirmar branch correto
  ```

---

## 📋 Tipo
**[feat/fix/test]** - [Descrição do tipo]

## 📝 Resumo
[Resumo curto da tarefa]

## 📖 Descrição
Como [usuário/stakeholder], eu quero [objetivo], para que [benefício].

## ✅ Critérios de Aceitação

### Funcionalidades Principais
- [ ] [Critério 1]
- [ ] [Critério 2]
- [ ] [Critério 3]

### Interface e UX (se aplicável)
- [ ] [Critério de interface 1]
- [ ] [Critério de interface 2]

### Integração (se aplicável)
- [ ] [Critério de integração 1]
- [ ] [Critério de integração 2]

## 🧪 Testes
- [ ] Testar funcionalidade localmente
- [ ] Validar cenários de sucesso
- [ ] Validar tratamento de erros
- [ ] Testar responsividade (se aplicável)

## 📚 Definição de Pronto (DoD)
- [ ] Código implementado e testado
- [ ] Todos os itens do checklist marcados ✅
- [ ] Commits descritivos e frequentes
- [ ] Push do branch realizado
- [ ] Código segue padrões do projeto
- [ ] Documentação atualizada (se necessário)

---

## 🎯 CHECKLIST DE IMPLEMENTAÇÃO (MARCAR DURANTE O TRABALHO)

### Configuração
- [ ] Worktree criado e branch correto confirmado
- [ ] Ambiente de desenvolvimento configurado no worktree
- [ ] Dependências instaladas (se necessário)

### Desenvolvimento
- [ ] [Atividade de desenvolvimento 1]
- [ ] [Atividade de desenvolvimento 2]
- [ ] [Atividade de desenvolvimento 3]

### Testes
- [ ] Testes unitários implementados (se aplicável)
- [ ] Testes de integração implementados (se aplicável)
- [ ] Testes manuais realizados
- [ ] Cenários de erro testados

### Finalização
- [ ] Código revisado
- [ ] Commits finalizados com mensagens descritivas
- [ ] Push do branch realizado
- [ ] Todos os itens acima marcados ✅

---

## ⚠️ FINALIZAÇÃO DA TASK (OBRIGATÓRIO)

Quando o agent concluir a implementação:

### 1. Verificação Final
```bash
# Garantir que está no worktree correto
pwd
# Deve estar em: /caminho/do/projeto/.kiro/worktrees/XXX-tipo-resumo

# Verificar branch
git branch --show-current
# Deve mostrar: feature/XXX-tipo-resumo
```

### 2. Commit e Push Final
```bash
git add .
git commit -m "tipo: finaliza implementação da task XXX"
git push origin feature/XXX-tipo-resumo
```

### 3. Voltar para Raiz e Notificar PO
```bash
cd ../../..  # Voltar para raiz do projeto
```

**NOTIFICAR O PO:**
> "Task XXX concluída. Todos os itens do checklist marcados. Branch `feature/XXX-tipo-resumo` com push realizado. Aguardando revisão do PO para encerramento e abertura de PR."

**⚠️ NÃO REMOVER O WORKTREE. Apenas o PO faz isso após o PR ser mergeado.**

---

## 🎯 ENCERRAMENTO PELO PO (QUANDO NOTIFICADO)

### 1. Revisão
```bash
# Entrar no worktree para revisar
cd .kiro/worktrees/XXX-tipo-resumo

# Revisar código, testar funcionalidade
# Verificar se todos os itens estão ✅
```

### 2. Aprovar e Mover para Done
```bash
# Voltar para raiz
cd ../../..

# Mover task para done
mv .kiro/tasks/doing/XXX-tipo-resumo.md .kiro/tasks/done/

# Commit e push no ia-main
git checkout ia-main
git add .kiro/tasks/
git commit -m "move: task XXX para done"
git push origin ia-main
```

### 3. Abrir Pull Request
```bash
# ANTES de abrir PR: confirmar que está no branch da feature
cd .kiro/worktrees/XXX-tipo-resumo
git branch --show-current
# Deve mostrar: feature/XXX-tipo-resumo

# Abrir PR contra ia-main
gh pr create --base ia-main --title "XXX: [Resumo]" --body "Closes task XXX"
```

### 4. Após PR Mergeado
```bash
# Voltar para raiz
cd ../../..

# Remover worktree
git worktree remove .kiro/worktrees/XXX-tipo-resumo

# Ou com força se necessário:
# git worktree remove --force .kiro/worktrees/XXX-tipo-resumo

# Limpar registros
git worktree prune

# (Opcional) Deletar branch local
git branch -d feature/XXX-tipo-resumo

# Notificar conclusão
```

---

## 📊 Notas Técnicas
[Informações técnicas relevantes]

## 💼 Valor de Negócio
**[Alto/Médio/Baixo]** - [Justificativa do valor]

## 🎯 Estimativa
**X Story Points** - [Justificativa da complexidade]

## 🔗 Dependências
[Listar dependências ou "Nenhuma"]

---

## 📚 Referências
- [Worktree Workflow](.kiro/docs/worktree-workflow.md)
- [Worktree Steering](.kiro/docs/worktree-steering.md)
