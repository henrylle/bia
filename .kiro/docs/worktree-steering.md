# Regras de Worktree - Projeto BIA (Steering File para Agents)

## 📍 Padrão Adotado
Seguimos o **padrão Claude/Codex** de worktrees dentro do projeto.

## 🎯 Localização
- **Pasta de worktrees:** `.kiro/worktrees/`
- **Gitignore:** Pasta `.kiro/worktrees/` está no `.gitignore`
- **Branch base:** SEMPRE `ia-main`

## 🔄 Workflow para Agents (Dev/DevOps/QA)

### Quando receber uma task para implementar:

#### 1. Verificação Inicial (OBRIGATÓRIO)
```bash
# Verificar branch atual
git branch --show-current

# Se NÃO estiver em ia-main:
# - PERGUNTAR ao usuário se pode trocar para ia-main
# - Aguardar autorização
# - Após autorização:
git checkout ia-main
git pull origin ia-main
```

#### 2. Movimentação da Task
```bash
# Mover task de .kiro/tasks/ para .kiro/tasks/doing/
mv .kiro/tasks/<nome-da-task>.md .kiro/tasks/doing/

# Commit e push no ia-main
git add .kiro/tasks/
git commit -m "move: task <número> para doing"
git push origin ia-main
```

#### 3. Criação do Worktree
```bash
# Sintaxe obrigatória:
git worktree add .kiro/worktrees/<nome-da-task> -b <nome-do-branch> ia-main

# Exemplo para task 006-feat-nova-funcionalidade:
git worktree add .kiro/worktrees/006-feat-nova-funcionalidade -b feature/006-feat-nova-funcionalidade ia-main

# Nomenclatura do branch:
# - feat: feature/<número>-<tipo>-<resumo>
# - fix: fix/<número>-<tipo>-<resumo>
# - test: test/<número>-<tipo>-<resumo>
```

#### 4. Entrar no Worktree e Trabalhar
```bash
# Navegar para o worktree
cd .kiro/worktrees/<nome-da-task>

# Confirmar branch
git branch --show-current

# Implementar as atividades da task
# Marcar itens do checklist conforme conclusão

# Fazer commits frequentes
git add .
git commit -m "tipo: descrição da mudança"

# Push do branch
git push -u origin <nome-do-branch>
```

#### 5. Durante a Implementação
- **Marcar** itens da task à medida que são concluídos
- **Fazer commits** descritivos e frequentes
- **Testar** localmente antes de finalizar
- **Manter** contexto da task atualizado

#### 6. Finalização (IMPORTANTE)
```bash
# Garantir que todos os itens da task estão marcados ✅
# Fazer commit e push final
git add .
git commit -m "tipo: finaliza implementação da task <número>"
git push origin <nome-do-branch>

# Voltar para o diretório principal
cd ../../..

# NOTIFICAR O PO
# "Task <número> concluída. Aguardando revisão do PO para encerramento."
```

**⚠️ CRÍTICO:** O agent **NÃO** remove o worktree. Apenas o PO faz isso após PR mergeado.

## 🎯 Workflow para PO

### Quando notificado de task concluída:

#### 1. Revisão
```bash
# Entrar no worktree para revisar
cd .kiro/worktrees/<nome-da-task>

# Revisar código
# Verificar checklist completo ✅
# Testar funcionalidade
```

#### 2. Movimentação para Done
```bash
# Voltar para raiz
cd ../../..

# Mover task para done
mv .kiro/tasks/doing/<nome-da-task>.md .kiro/tasks/done/

# Commit e push no ia-main
git checkout ia-main
git add .kiro/tasks/
git commit -m "move: task <número> para done"
git push origin ia-main
```

#### 3. Abertura de Pull Request
```bash
# ANTES de abrir PR: confirmar que está no branch da feature
cd .kiro/worktrees/<nome-da-task>
git branch --show-current
# Deve mostrar: feature/<número>-<tipo>-<resumo>

# Abrir PR contra ia-main
gh pr create --base ia-main --title "<número>: <resumo>" --body "Closes task <número>"

# Exemplo:
# gh pr create --base ia-main --title "006: Nova funcionalidade" --body "Closes task 006"
```

**⚠️ NUNCA abrir PR contra `main` ou outro branch. SEMPRE contra `ia-main`.**

#### 4. Após PR Mergeado (ETAPA FINAL)
```bash
# Voltar para raiz (se estiver no worktree)
cd ../../..

# Remover worktree
git worktree remove .kiro/worktrees/<nome-da-task>

# Se houver arquivos não commitados, usar força:
git worktree remove --force .kiro/worktrees/<nome-da-task>

# Limpar registros
git worktree prune

# (Opcional) Deletar branch local
git branch -d <nome-do-branch>

# Notificar conclusão
# "Task <número> finalizada. Worktree removido. PR #<número> mergeado com sucesso."
```

## 📋 Comandos de Referência

### Listar Worktrees
```bash
git worktree list
```

### Verificar Branch Atual
```bash
git branch --show-current
```

### Remover Worktree (PO apenas)
```bash
git worktree remove .kiro/worktrees/<nome>
# Ou com força:
git worktree remove --force .kiro/worktrees/<nome>
```

### Limpar Registros (PO apenas)
```bash
git worktree prune
```

## ⚠️ Regras Críticas

### ✅ Obrigatório
- Branch base SEMPRE `ia-main`
- Worktrees SEMPRE em `.kiro/worktrees/`
- Verificar branch antes de iniciar task
- Perguntar autorização para trocar de branch
- Mover task para doing antes de criar worktree
- Commit e push da movimentação no ia-main
- Marcar itens da task durante implementação
- Notificar PO quando concluir
- PO abre PR do branch da feature
- PO remove worktree APENAS após PR mergeado

### ❌ Proibido
- Criar worktree fora de `.kiro/worktrees/`
- Partir de branch diferente de `ia-main`
- Agent remover worktree (só PO pode)
- Abrir PR contra `main` (sempre contra `ia-main`)
- Remover worktree antes do PR ser mergeado
- Esquecer de fazer push do branch

## 🔧 Troubleshooting

### "Worktree já existe"
```bash
git worktree list
git worktree remove .kiro/worktrees/<nome>
```

### "Branch já existe"
```bash
git branch -a
git branch -d <nome-do-branch>
```

### "Não estou no branch correto"
```bash
git branch --show-current
# Se não for ia-main (para início) ou feature/* (para trabalho):
# Perguntar ao usuário o que fazer
```

## 📊 Estados da Task

```
.kiro/tasks/           → Task criada (aguardando início)
       ↓
.kiro/tasks/doing/     → Task em andamento (agent trabalhando)
       ↓
.kiro/tasks/done/      → Task concluída (PR mergeado, worktree removido)
```

## 🎓 Lembretes para Agents

1. **SEMPRE** verificar branch atual antes de iniciar
2. **SEMPRE** perguntar antes de trocar de branch
3. **SEMPRE** mover task para doing antes de criar worktree
4. **SEMPRE** criar worktree em `.kiro/worktrees/`
5. **SEMPRE** partir de `ia-main`
6. **SEMPRE** notificar PO quando concluir
7. **NUNCA** remover worktree (só PO pode)
8. **NUNCA** abrir PR (só PO pode)

---

**Este documento deve ser consultado por todos os agents (dev, devops, qa) ao receber uma nova task.**
