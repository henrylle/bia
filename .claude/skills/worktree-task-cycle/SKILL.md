---
name: worktree-task-cycle
description: Executa os comandos do ciclo de vida de uma task do projeto BIA (início por um agent, finalização pelo agent, encerramento/PR pelo PO) seguindo o padrão de git worktree isolado. Use quando um agent (dev/devops/qa/po) for iniciar, finalizar ou encerrar uma task em .kiro/tasks/.
---

# Worktree Task Cycle

Consolida em um único lugar executável o fluxo de worktree por task que hoje está
descrito em prosa (e duplicado quase verbatim) em `.kiro/agents/po/especificacao.md`,
`.kiro/docs/worktree-steering.md`, `.kiro/docs/worktree-workflow.md` e
`.kiro/docs/task-template-with-worktree.md`. Essas quatro fontes continuam sendo a
referência conceitual (leia-as se algo aqui parecer ambíguo) — esta skill é a
"cola" prática pra não ter que copiar comandos manualmente toda vez.

Convenção de nomes usada abaixo: `XXX` = número da task com 3 dígitos (ex. `003`),
`tipo` = `feat`/`fix`/`test`, `resumo` = resumo curto separado por hífen. O nome
completo da task/branch/worktree é sempre `XXX-tipo-resumo`.

## Quando usar cada fase

Pergunte (ou infira do contexto) em qual fase a task está antes de rodar qualquer
comando:

1. **Início** — um agent (dev/devops/qa) foi acionado numa task nova em
   `.kiro/tasks/XXX-tipo-resumo.md` (ainda não está em `doing/`).
2. **Finalização pelo agent** — a implementação terminou, checklist marcado, falta
   avisar o PO.
3. **Encerramento pelo PO** — o PO foi notificado que uma task está pronta e precisa
   revisar, mover pra `done/` e abrir o PR.
4. **Pós-merge (só PO)** — o PR foi mergeado e o worktree precisa ser removido.

**Regra crítica que vale para todas as fases**: só o **PO** remove worktree e abre
PR. Um agent implementador (dev/devops/qa) nunca roda `git worktree remove` nem
`gh pr create`.

## Fase 1 — Início da task (agent dev/devops/qa)

```bash
# 1. Confirmar que está em ia-main — se não estiver, PARE e pergunte ao usuário
#    se pode trocar antes de prosseguir. Não troque de branch sem autorização.
git branch --show-current

# 2. Após autorização (ou se já estava em ia-main), atualizar:
git checkout ia-main
git pull origin ia-main

# 3. Mover a task para doing/:
mv .kiro/tasks/XXX-tipo-resumo.md .kiro/tasks/doing/
git add .kiro/tasks/
git commit -m "move: task XXX para doing"
git push origin ia-main

# 4. Criar o worktree isolado (SEMPRE a partir de ia-main):
git worktree add .kiro/worktrees/XXX-tipo-resumo -b feature/XXX-tipo-resumo ia-main
# (use fix/XXX-... ou test/XXX-... se o tipo da task for fix/test)

# 5. Entrar no worktree e confirmar o branch antes de tocar em qualquer arquivo:
cd .kiro/worktrees/XXX-tipo-resumo
git branch --show-current   # deve mostrar exatamente feature/XXX-tipo-resumo
```

A partir daqui, trabalhe normalmente **dentro do worktree**: implemente, faça
commits frequentes e descritivos, e marque os itens do checklist da task conforme
forem concluídos.

⚠️ **Gotcha conhecido** (documentado em `docs/paralelo-kiro-cli-vs-claude-code.md`):
cada worktree novo tem seu **próprio volume Docker do Postgres**, isolado do
worktree principal — se a task envolver banco, rode as migrations dentro do
worktree (`npx sequelize db:migrate`) antes de assumir que os dados/schema já
existem.

## Fase 2 — Finalização pelo agent implementador

```bash
# Ainda dentro do worktree — confirmar de novo antes do commit final:
pwd                        # deve estar em .../.kiro/worktrees/XXX-tipo-resumo
git branch --show-current  # deve mostrar feature/XXX-tipo-resumo

git add .
git commit -m "tipo: finaliza implementação da task XXX"
git push -u origin feature/XXX-tipo-resumo

cd ../../..  # voltar para a raiz do projeto
```

Depois, **notifique o PO** com uma mensagem no formato:

> "Task XXX concluída. Todos os itens do checklist marcados. Branch
> `feature/XXX-tipo-resumo` com push realizado. Aguardando revisão do PO para
> encerramento e abertura de PR."

Não remova o worktree. Não abra PR. Essa fase termina aqui para o agent.

## Fase 3 — Encerramento pelo PO

```bash
# 1. Revisar dentro do worktree
cd .kiro/worktrees/XXX-tipo-resumo
# conferir que todos os itens do checklist da task estão marcados [x]
cd ../../..

# 2. Mover a task para done/ e registrar em ia-main
mv .kiro/tasks/doing/XXX-tipo-resumo.md .kiro/tasks/done/
git checkout ia-main
git add .kiro/tasks/
git commit -m "move: task XXX para done"
git push origin ia-main

# 3. ANTES de abrir o PR — confirmar branch dentro do worktree (nunca abrir
#    PR estando em ia-main por engano):
cd .kiro/worktrees/XXX-tipo-resumo
git branch --show-current
# Se a saída não for exatamente feature/XXX-tipo-resumo, PARE — investigue
# antes de continuar (ex.: pode estar rodando da raiz em vez do worktree).

# 4. Abrir o PR — sempre da feature contra ia-main, nunca contra main:
gh pr create --base ia-main --title "XXX: <resumo>" --body "Closes task XXX"
```

## Fase 4 — Pós-merge (só PO, depois que o PR foi mergeado)

```bash
cd ../../..  # garantir que está na raiz, fora de qualquer worktree

git worktree remove .kiro/worktrees/XXX-tipo-resumo
# se necessário: git worktree remove --force .kiro/worktrees/XXX-tipo-resumo

git worktree prune
git branch -d feature/XXX-tipo-resumo   # opcional
```

Notifique: "Task XXX finalizada. Worktree removido. PR #<número> mergeado com
sucesso."

## Referências

- `.kiro/agents/po/especificacao.md` — fonte original completa desta skill
- `.kiro/docs/worktree-steering.md`, `.kiro/docs/worktree-workflow.md`,
  `.kiro/docs/task-template-with-worktree.md` — contexto/explicações adicionais
- `docs/panorama-agentes-e-worktrees.md` — visão geral do time de agentes
- `docs/paralelo-kiro-cli-vs-claude-code.md` — gotcha do volume Docker por worktree
