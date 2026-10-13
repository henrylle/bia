# 003 - Tornar o check "Testes Unitários" obrigatório no branch `ia-main`

## 🔧 Configuração Inicial (LEIA ANTES DE INICIAR)

### Agent Responsável
**dev** - Este agent deve iniciar e concluir a implementação sozinho.

> ⚠️ **Fluxo desta task é apenas `dev → po`, sem `qa` e sem `devops`.**
> - O **qa** não tem papel útil aqui: não é uma mudança de UI/browser testável
>   via Playwright, é configuração de repositório GitHub.
> - O **devops** também não entra: não envolve infraestrutura AWS (o
>   `devops` só tem acesso somente-leitura via `aws-mcp`, sem `gh`).
> - O único agent do time com `Bash` liberado o suficiente para rodar `gh
>   api`/`gh` de configuração de repositório é o **dev** (o `po` só tem `gh
>   pr create` na allowlist; o `devops` não tem `gh` de forma alguma).
> - Ao concluir e validar, o **dev** notifica diretamente o **po** para
>   revisão e fechamento — não há etapa intermediária de qa/devops nesta
>   task.

### Branch Base
**SEMPRE `ia-main`**

### Worktree
Esta task será implementada em worktree isolado em
`.kiro/worktrees/003-feat-branch-protection-testes-obrigatorios/`

### Escopo
- **Somente configuração do repositório GitHub** (`FabioCLima/bia`, é o
  fork do usuário configurado como `origin`). Nenhuma alteração de código
  de aplicação (`api/`, `client/`) nem do workflow em si
  (`.github/workflows/testes-pr.yml`) é esperada — a menos que, durante a
  validação, se descubra algo genuinamente quebrado no workflow (nesse
  caso, documentar e avisar o po antes de alterar).
- Para o teste de bloqueio (PR com teste quebrado), pode ser necessário um
  branch/PR descartável — nunca commitar um teste quebrado de forma
  definitiva contra `ia-main`.

---

## ⚠️ CHECKLIST DE INÍCIO (OBRIGATÓRIO)

Antes de começar a implementar, o agent (dev) deve:

- [x] **Verificar branch atual:** `git branch --show-current`
  - Já estava em `ia-main` (confirmado com o usuário antes de iniciar)

- [x] **Mover task para doing:**
  ```bash
  mv .kiro/tasks/003-feat-branch-protection-testes-obrigatorios.md .kiro/tasks/doing/
  git add .kiro/tasks/
  git commit -m "move: task 003 para doing"
  git push origin ia-main
  ```

- [x] **Criar worktree:**
  ```bash
  git worktree add .kiro/worktrees/003-feat-branch-protection-testes-obrigatorios -b feature/003-feat-branch-protection-testes-obrigatorios ia-main
  cd .kiro/worktrees/003-feat-branch-protection-testes-obrigatorios
  git branch --show-current  # Confirmar branch correto
  ```

---

## 📋 Tipo
**feat** - Habilitar proteção de branch para tornar um check de CI
obrigatório antes do merge.

## 📝 Resumo
Configurar o branch `ia-main` do repositório `FabioCLima/bia` para exigir
que o check "Testes Unitários" (workflow
`.github/workflows/testes-pr.yml`) passe com sucesso antes que um Pull
Request possa ser mergeado, fechando um gap deixado em aberto por uma task
legada do time anterior.

## 📖 Descrição
Como time de desenvolvimento do BIA, eu quero que o GitHub **bloqueie o
merge** de qualquer PR contra `ia-main` cujo check "Testes Unitários"
esteja falhando (ou ainda não tenha rodado), para que testes quebrados
nunca cheguem ao branch principal por descuido — hoje isso não acontece:
o workflow roda e reporta status, mas nada impede o merge mesmo com testes
vermelhos.

## Contexto (leia antes de implementar)

O workflow de testes a cada PR **já existe e já funciona**:
`.github/workflows/testes-pr.yml` (nome do job: **"Testes Unitários"**).
Ele:
- Dispara em `pull_request` contra `ia-main`;
- Roda `npm install` + `npm test` (Jest, `tests/unit/`, testes unitários
  mockados, sem dependência de banco);
- Já rodou com sucesso em dois PRs reais (PR #1 e PR #2, ambos
  `success`).

Essa automação veio de uma task legada do time anterior (Kiro CLI):
`.kiro/tasks/done/_legado-henrylle/006-feat-github-actions-testes-pr.md`.
Essa task legada já apontava exatamente o gap que esta task 003 resolve,
mas nunca foi fechada:
```
- [ ] O status do workflow aparece como check obrigatório no PR (visível na interface do GitHub)
```

**O gap real (escopo desta task):** o check do workflow **não é
obrigatório**. Uma consulta a
`gh api repos/FabioCLima/bia/branches/ia-main/protection` retornou:
```json
{ "message": "Branch not protected" }
```
(HTTP 404 — sem nenhuma regra de proteção configurada). Ou seja, hoje um
PR **pode ser mergeado mesmo que os testes falhem** — nada bloqueia isso
no GitHub.

> **⚠️ Achado durante a implementação:** o nome usado para identificar o
> check nas regras de proteção **não é "Testes Unitários"** (esse é o
> `name:` do *workflow*, exibido como título na aba Actions). O contexto
> real do check (o que aparece em `check-runs`/`statusCheckRollup`, e que
> deve ser referenciado como "required status check") é o **nome do job**
> dentro do workflow — no arquivo `.github/workflows/testes-pr.yml` o job
> se chama `testes` (sem um `name:` explícito), então o check reportado é
> literalmente `testes`. Confirmado consultando os check-runs dos PRs #1 e
> #2 já mergeados:
> ```
> $ gh api repos/FabioCLima/bia/commits/<sha-pr1>/check-runs --jq '.check_runs[] | {name, conclusion}'
> {"name":"testes","conclusion":"success"}
> ```
> A regra de proteção foi configurada exigindo o contexto `testes` (não
> `"Testes Unitários"`), que é o valor que o GitHub de fato casa contra o
> check reportado pelo Actions. Nenhuma alteração foi feita no workflow —
> apenas documentando aqui o nome correto do contexto para não gerar uma
> regra "obrigatória" que nunca casa com nenhum check real (bug comum
> nesse tipo de configuração).

## ⚠️ Ponto de atenção CRÍTICO — leia antes de aplicar qualquer configuração

O material de curso original (Kiro CLI, ~2025) sobre esse tópico pode
estar **desatualizado** — hoje já estamos bem depois disso, e o GitHub
pode ter mudado a forma recomendada de configurar proteção de branch (ex.:
"Rulesets" como sucessor mais novo e flexível das "Branch protection
rules" clássicas, mudanças na API/CLI). Portanto, o **dev DEVE**:

- **NÃO assumir sintaxe de comando de memória/curso.** Verificar a
  documentação oficial atual do GitHub antes de aplicar qualquer mudança
  — via `gh api` introspection (ex.: `gh api repos/{owner}/{repo} --jq
  '.default_branch'`, explorar os endpoints disponíveis), `gh help api`,
  `gh help ruleset` (se existir no `gh` instalado), ou documentação oficial
  do GitHub (docs.github.com) sobre "branch protection rules" e
  "repository rulesets".
- **Confirmar qual mecanismo está disponível/recomendado no momento da
  execução:**
  - Branch protection clássica: `gh api repos/{owner}/{repo}/branches/{branch}/protection` com `PUT` (endpoint que já foi consultado nesta task, retornou 404 = não configurado);
  - Ou Rulesets: `gh api repos/{owner}/{repo}/rulesets` (mecanismo mais novo).
- **Documentar na task qual mecanismo foi usado e por quê** (ex.:
  disponibilidade no plano do repositório, simplicidade, recomendação
  atual do GitHub, permissões do fork, etc.).
- **Testar de verdade a trava** (não basta o check aparecer como
  obrigatório na tela de configurações — precisa comprovar o bloqueio na
  prática):
  1. Abrir um PR de teste contra `ia-main` com um teste unitário
     **propositalmente quebrado** (ex.: alterar temporariamente uma
     asserção em `tests/unit/`);
  2. Confirmar que o check "Testes Unitários" falha nesse PR;
  3. Confirmar que o **botão de merge fica desabilitado/bloqueado** pelo
     GitHub (não apenas que o check aparece como failed — o merge em si
     precisa estar impedido);
  4. **Reverter o teste quebrado** (o PR de teste não deve ser mergeado
     com o teste quebrado; feche-o ou corrija antes de decidir o que
     fazer com ele — nunca deixe um teste quebrado definitivo em
     qualquer branch, nem mesmo um branch descartável que fique aberto).

## ✅ Critérios de Aceitação

### Funcionalidades Principais
- [x] Branch `ia-main` protegido/com regra exigindo que o check "Testes
      Unitários" passe antes do merge (via branch protection clássica ou
      via ruleset — o mecanismo escolhido deve ser documentado com
      justificativa na seção "Notas Técnicas" desta task).
- [x] PR de teste com um teste quebrado propositalmente confirma, na
      prática, que o **merge é bloqueado pelo GitHub** (evidência: print
      ou saída de `gh pr view`/`gh api` mostrando `mergeable_state` ou
      equivalente, e/ou descrição do botão de merge desabilitado na UI).
- [x] Teste quebrado revertido/removido após a validação — nenhum lixo
      (teste quebrado, branch de teste esquecido) deixado no repositório
      ao final da task.
- [x] Mecanismo usado (branch protection clássica ou ruleset) documentado
      na task, com a justificativa da escolha.

### Integração
- [x] Nenhuma alteração de código de aplicação (`api/`, `client/`) — o
      escopo é estritamente configuração de repositório GitHub.
- [x] O workflow `.github/workflows/testes-pr.yml` continua funcionando
      normalmente para PRs com testes passando (não regredir o que já
      funciona).

## 🧪 Testes (dev)
- [x] Confirmar estado inicial: `gh api
      repos/FabioCLima/bia/branches/ia-main/protection` (documentar
      resultado antes da mudança, para comparação).
- [x] Aplicar a configuração de proteção/regra exigindo o check "Testes
      Unitários".
- [x] Confirmar via `gh api` que a proteção está ativa e que o check
      correto está listado como obrigatório.
- [x] Cenário de bloqueio: abrir PR de teste (branch descartável) contra
      `ia-main` com teste unitário quebrado propositalmente, confirmar
      falha do check e bloqueio do merge.
- [x] Reverter o teste quebrado / fechar o PR de teste sem mergeá-lo.
- [x] (Opcional, se viável sem custo/risco) Confirmar que um PR com testes
      passando continua mergeável normalmente após a proteção ativa.

## 📚 Definição de Pronto (DoD)
- [x] Configuração implementada e validada na prática (bloqueio real
      testado, não apenas configuração visual)
- [x] Todos os itens do checklist marcados ✅
- [x] Commits descritivos e frequentes (se houver alteração de arquivos
      versionados; a mudança principal é via `gh api`, fora do controle de
      versão do código, mas qualquer PR de teste usado na validação deve
      ser documentado)
- [x] Push do branch da task realizado (mesmo que o conteúdo principal
      seja a atualização desta própria task com as evidências)
- [x] Nenhum teste quebrado remanescente em qualquer branch do
      repositório
- [x] Documentação atualizada nesta task (mecanismo escolhido, evidências
      de teste, comandos usados)

---

## 🎯 CHECKLIST DE IMPLEMENTAÇÃO (MARCAR DURANTE O TRABALHO)

### Configuração
- [x] Worktree criado e branch correto confirmado
- [x] Confirmado acesso via `gh auth status` ao repositório
      `FabioCLima/bia`

### Investigação (antes de aplicar qualquer mudança)
- [x] Consultado o estado atual de proteção do branch `ia-main` (`gh api
      repos/FabioCLima/bia/branches/ia-main/protection`) e documentado o
      resultado
- [x] Verificada a documentação oficial atual do GitHub sobre proteção de
      branch (branch protection rules clássicas vs. rulesets) — **sem
      assumir sintaxe do material de curso**
- [x] Decidido e justificado qual mecanismo será usado (branch protection
      clássica ou ruleset)

### Desenvolvimento
- [x] Aplicada a configuração escolhida via `gh api` (com `PUT`/`POST`
      conforme o mecanismo), exigindo o check "Testes Unitários" como
      obrigatório para `ia-main`
- [x] Confirmado via `gh api` (`GET`) que a regra está ativa e lista o
      check correto

### Validação do bloqueio real
- [x] Criado branch descartável com um teste unitário propositalmente
      quebrado (ex.: `tests/unit/controllers/...`)
- [x] Aberto PR de teste contra `ia-main` a partir desse branch
- [x] Confirmado que o check "Testes Unitários" falhou no PR
- [x] Confirmado que o GitHub bloqueia o merge (evidência registrada:
      saída de `gh pr view <n> --json mergeable,mergeStateStatus` ou
      equivalente)
- [x] Revertido o teste quebrado / PR de teste fechado sem merge
- [x] Branch de teste descartável removido (local e remoto, se aplicável)

### Finalização
- [x] Código/configuração revisado
- [x] Task atualizada com todas as evidências e decisões
- [x] Commits finalizados com mensagens descritivas
- [x] Push do branch da task realizado
- [x] Todos os itens acima marcados ✅

---

## ⚠️ FINALIZAÇÃO DA TASK (OBRIGATÓRIO)

Quando o **dev** concluir a implementação e a validação:

### 1. Verificação Final
```bash
# Garantir que está no worktree correto
pwd
# Deve estar em: /caminho/do/projeto/.kiro/worktrees/003-feat-branch-protection-testes-obrigatorios

# Verificar branch
git branch --show-current
# Deve mostrar: feature/003-feat-branch-protection-testes-obrigatorios
```

### 2. Commit e Push Final
```bash
git add .
git commit -m "feat: torna o check Testes Unitários obrigatorio no branch ia-main"
git push origin feature/003-feat-branch-protection-testes-obrigatorios
```

### 3. Notificar diretamente o PO (sem qa/devops nesta task)
Não há etapa de qa ou devops nesta task. Ao concluir e validar o
bloqueio real (PR de teste quebrado + merge bloqueado + reversão), o
**dev** notifica diretamente o **po**.

### 4. Voltar para Raiz e Notificar PO
```bash
cd ../../..  # Voltar para raiz do projeto
```

**NOTIFICAR O PO:**
> "Task 003 concluída pelo dev. Proteção de branch aplicada em `ia-main`
> exigindo o check 'Testes Unitários'. Validação real feita: PR de teste
> com teste quebrado confirmou bloqueio de merge pelo GitHub; teste
> quebrado revertido. Mecanismo usado: [branch protection clássica /
> ruleset], justificativa documentada na task. Branch
> `feature/003-feat-branch-protection-testes-obrigatorios` com push
> realizado. Aguardando revisão do PO para encerramento."

**⚠️ NÃO REMOVER O WORKTREE. Apenas o PO faz isso após o PR ser
mergeado.**

**⚠️ Esta task não gera necessariamente um PR de código de aplicação** —
a mudança principal é configuração de repositório via `gh api`. Ainda
assim, siga o fluxo de PR normal para registrar a atualização desta task
(com as evidências) contra `ia-main`, conforme o encerramento abaixo.

---

## 🎯 ENCERRAMENTO PELO PO (QUANDO NOTIFICADO)

### 1. Revisão
```bash
# Entrar no worktree para revisar
cd .kiro/worktrees/003-feat-branch-protection-testes-obrigatorios

# Revisar a task atualizada com evidências
# Confirmar, via gh api, que a proteção do branch ia-main está ativa
gh api repos/FabioCLima/bia/branches/ia-main/protection

# Verificar se todos os itens estão ✅
```

### 2. Aprovar e Mover para Done
```bash
# Voltar para raiz
cd ../../..

# Mover task para done
mv .kiro/tasks/doing/003-feat-branch-protection-testes-obrigatorios.md .kiro/tasks/done/

# Commit e push no ia-main
git checkout ia-main
git add .kiro/tasks/
git commit -m "move: task 003 para done"
git push origin ia-main
```

> **⚠️ Nota de execução real:** o `git push origin ia-main` acima **foi
> rejeitado** pelo próprio ruleset criado por esta task (`GH013:
> Repository rule violations found ... Required status check "testes" is
> expected`). Esse é um efeito colateral correto e esperado da proteção:
> como `bypass_actors` está vazio (`current_user_can_bypass: "never"`), a
> regra bloqueia **qualquer push direto** a `ia-main` — não só merges de
> PR com check falho — incluindo os commits de rotina do PO (mover task
> para `doing/`/`done/`). Isso não é um bug da configuração; é a
> proteção funcionando como projetada, só que agora afeta também o
> fluxo de housekeeping do PO, que historicamente empurrava direto para
> `ia-main`. Adaptação aplicada nesta execução: o commit "move: task 003
> para done" foi movido para dentro do próprio worktree/branch
> `feature/003-feat-branch-protection-testes-obrigatorios` (em vez de um
> push direto a `ia-main`), viajando junto no mesmo Pull Request. Fica
> registrado aqui como ponto de atenção para o time: **a partir de agora,
> toda alteração em `ia-main` — inclusive housekeeping de tasks —
> precisa passar por PR**, e o fluxo documentado no `.kiro/agents/po/especificacao.md`
> (que assume push direto do PO) deveria ser revisado/atualizado em uma
> task futura para refletir essa nova realidade.

### 3. Abrir Pull Request
```bash
# ANTES de abrir PR: confirmar que está no branch da feature (NUNCA em ia-main)
cd .kiro/worktrees/003-feat-branch-protection-testes-obrigatorios
git branch --show-current
# Comparar a saída com o nome esperado: feature/003-feat-branch-protection-testes-obrigatorios
# Se não bater (ex.: mostrar "ia-main"), PARAR — NÃO rodar o gh pr create abaixo

# Só prosseguir se o branch confirmado bater com o esperado:
gh pr create --base ia-main --title "003: Tornar check Testes Unitários obrigatorio em ia-main" --body "Closes task 003"
```

### 4. Após PR Mergeado
```bash
# Voltar para raiz
cd ../../..

# Remover worktree
git worktree remove .kiro/worktrees/003-feat-branch-protection-testes-obrigatorios

# Ou com força se necessário:
# git worktree remove --force .kiro/worktrees/003-feat-branch-protection-testes-obrigatorios

# Limpar registros
git worktree prune

# (Opcional) Deletar branch local
git branch -d feature/003-feat-branch-protection-testes-obrigatorios

# Notificar conclusão
```

---

## 📊 Notas Técnicas

### Estado inicial confirmado (na criação desta task)
```bash
$ gh api repos/FabioCLima/bia/branches/ia-main/protection
{
  "message": "Branch not protected",
  ...
}
```
Ou seja, hoje **não existe nenhuma regra de proteção** em `ia-main` — nem
clássica, nem ruleset.

### Mecanismo escolhido: **Repository Ruleset** (não branch protection clássica)

Investigação feita antes de aplicar qualquer mudança (sem assumir sintaxe
de memória/curso):

- `gh --version` → `2.98.0 (2026-08-20)`, uma versão recente do CLI.
- `gh help` lista, entre os subcomandos de topo, um comando **nativo e de
  primeira classe** para rulesets: `gh ruleset` (alias `gh rs`), com
  subcomandos `list`, `view` e `check`. **Não existe** um comando nativo
  equivalente `gh branch-protection` — a única forma de mexer em branch
  protection clássica é via `gh api` genérico (`PUT
  /repos/{owner}/{repo}/branches/{branch}/protection`). O fato de o CLI
  oficial do GitHub, em versão recente, dar suporte de primeira classe a
  rulesets e não a branch protection clássica é um forte indício de que
  rulesets é o mecanismo atualmente promovido/mantido pelo GitHub.
- `gh api repos/FabioCLima/bia/rulesets` (GET) → `[]` (endpoint existe e
  responde normalmente, confirmando que o repositório/plano suporta
  rulesets sem restrição — é um repositório público, e rulesets estão
  disponíveis em qualquer plano para repositórios públicos).
- `gh api repos/FabioCLima/bia/branches/ia-main/protection` (GET) → `404
  Branch not protected` (confirmado antes e depois de checar rulesets:
  nenhum dos dois mecanismos estava configurado).
- `gh api repos/FabioCLima/bia --jq '.permissions'` → `admin: true`
  (permissão suficiente para configurar qualquer um dos dois mecanismos).

**Decisão:** usar **rulesets** (`POST
/repos/{owner}/{repo}/rulesets`), pelos seguintes motivos:
1. É o mecanismo com suporte nativo no `gh` CLI atual (`gh ruleset`),
   indicando ser a via atualmente recomendada/mantida pelo GitHub.
2. Rulesets são explicitamente descritos pelo GitHub como o sucessor mais
   flexível das branch protection rules clássicas (permitem múltiplas
   regras compostas por repositório, "enforcement" ativo/avaliação,
   melhor rastreabilidade de quem/quando criou a regra via API), sem
   nenhuma desvantagem relevante para o caso de uso simples desta task.
3. Repositório é público, então rulesets estão disponíveis sem exigir
   plano pago — nenhuma restrição de acesso encontrada durante a
   investigação.
4. Branch protection clássica continua funcional (não está deprecada),
   mas não haveria ganho em usá-la aqui frente ao ruleset — como o
   mecanismo legado tem menos suporte de tooling (`gh api` cru vs.
   comando nativo), optou-se pelo mais atual.

**Achado importante durante a configuração:** o *contexto* do check
usado como "required status check" não é o nome do workflow ("Testes
Unitários"), e sim o **nome do job** dentro do YAML — no arquivo
`.github/workflows/testes-pr.yml` o job é `testes` (sem `name:`
explícito), então o check reportado pelo Actions e usado nas regras de
proteção é `testes`. Confirmado inspecionando os check-runs de PRs reais
já mergeados (PR #1 e #2):
```bash
$ gh api repos/FabioCLima/bia/commits/b76a880a.../check-runs \
    --jq '.check_runs[] | {name, status, conclusion}'
{"conclusion":"success","name":"testes","status":"completed"}
```
A regra foi configurada usando o contexto correto (`testes`), para
garantir que ela realmente "case" com o check reportado pelo GitHub
Actions (usar `"Testes Unitários"` teria criado uma regra "obrigatória"
que nunca seria satisfeita, pois nenhum check reporta exatamente esse
nome como contexto).

**Payload aplicado** (`POST /repos/FabioCLima/bia/rulesets`):
```json
{
  "name": "ia-main-testes-obrigatorios",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": { "include": ["refs/heads/ia-main"], "exclude": [] }
  },
  "rules": [
    {
      "type": "required_status_checks",
      "parameters": {
        "required_status_checks": [ { "context": "testes" } ],
        "strict_required_status_checks_policy": false
      }
    }
  ]
}
```
Resultado (`id: 21956121`, `enforcement: active`), confirmado via GET
(`gh api repos/FabioCLima/bia/rulesets/21956121` e `gh api
repos/FabioCLima/bia/rules/branches/ia-main`) listando corretamente a
regra `required_status_checks` com o contexto `testes`.

> Nota: `gh api repos/FabioCLima/bia/branches/ia-main/protection`
> continua retornando `404 Branch not protected` mesmo após a criação do
> ruleset — isso é esperado, pois esse endpoint só reflete a proteção
> clássica legada, não rulesets. A verificação correta do estado do
> ruleset é via `gh api repos/{owner}/{repo}/rulesets` ou `gh api
> repos/{owner}/{repo}/rules/branches/{branch}`.

### Evidências de validação

**Cenário 1 — bloqueio real com teste quebrado (PR #4, descartável):**
- Branch descartável `test/003-branch-protection-quebrado`, criado a
  partir de `ia-main`, com uma asserção alterada propositalmente em
  `tests/unit/controllers/versao.test.js` (`expect(res.send)...` passou
  a esperar `'valor-propositalmente-errado'`).
- PR aberto: https://github.com/FabioCLima/bia/pull/4 (`ia-main` ←
  `test/003-branch-protection-quebrado`).
- Check falhou como esperado:
  ```
  $ gh pr checks 4
  testes  fail  19s  https://github.com/FabioCLima/bia/actions/runs/33436287360/job/99633414485
  ```
- Estado do PR confirmando bloqueio (não apenas o check vermelho, o
  *merge em si*):
  ```
  $ gh pr view 4 --json number,mergeable,mergeStateStatus,statusCheckRollup \
      --jq '{number, mergeable, mergeStateStatus, checks: [.statusCheckRollup[] | {name, status, conclusion}]}'
  {
    "checks": [{ "conclusion": "FAILURE", "name": "testes", "status": "COMPLETED" }],
    "mergeStateStatus": "BLOCKED",
    "mergeable": "MERGEABLE",
    "number": 4
  }
  ```
- Tentativa real de merge, negada explicitamente pelo GitHub (não apenas
  na UI — a própria API/CLI recusou a operação):
  ```
  $ gh pr merge 4 --squash
  X Pull request FabioCLima/bia#4 is not mergeable: the base branch policy prohibits the merge.
  To have the pull request merged after all the requirements have been met, add the `--auto` flag.
  To use administrator privileges to immediately merge the pull request, add the `--admin` flag.
  ```
  Isso confirma que o ruleset **de fato impede o merge no GitHub**, não
  apenas exibe um check falho informativo.

**Cenário 2 (opcional) — PR com testes passando continua mergeável:**
- No mesmo PR #4, a asserção quebrada foi revertida para o valor
  original (`'Bia 4.2.0'`) e um novo commit foi enviado.
- Check voltou a passar e o estado do PR mudou para "limpo":
  ```
  $ gh pr checks 4
  testes  pass  20s  https://github.com/FabioCLima/bia/actions/runs/33436361340/job/99633663344

  $ gh pr view 4 --json number,mergeable,mergeStateStatus
  { "mergeStateStatus": "CLEAN", "mergeable": "MERGEABLE", "number": 4 }
  ```
  Confirma que a proteção não regride PRs legítimos com testes passando.

**Limpeza (sem lixo remanescente):**
- PR #4 fechado **sem merge**:
  `gh pr close 4 --comment "..." --delete-branch` (mensagem registrada no
  PR explicando que era um PR descartável de validação).
- Branch remoto `test/003-branch-protection-quebrado` removido (o
  `--delete-branch` do `gh pr close` falhou na hora por causa de um
  worktree local ainda ativo; branch remoto removido explicitamente logo
  em seguida com `git push origin --delete
  test/003-branch-protection-quebrado`, confirmado com `git ls-remote
  --heads origin test/003-branch-protection-quebrado` retornando vazio).
- Worktree e branch local de teste removidos (`git worktree remove` +
  `git branch -D test/003-branch-protection-quebrado`).
- Nenhum teste quebrado permanece em nenhum branch do repositório —
  `tests/unit/controllers/versao.test.js` em `ia-main` nunca foi alterado
  (a quebra só existiu no branch descartável, e foi revertida antes do
  fechamento do PR).

### Confirmação final do PO (encerramento)
- `gh api repos/FabioCLima/bia/rulesets/21956121` (executado durante a
  revisão de encerramento) confirma o ruleset ativo:
  `"enforcement":"active"`, `"rules":[{"type":"required_status_checks",
  "parameters":{"required_status_checks":[{"context":"testes"}], ...}}]`.
- `gh pr view 4 --json state,title` confirma `"state":"CLOSED"` (PR
  descartável não mergeado).
- `git ls-remote --heads origin test/003-branch-protection-quebrado`
  retornou vazio — branch descartável não deixou rastro remoto.
- **Efeito colateral descoberto no encerramento:** `git push origin
  ia-main` direto (o passo padrão de housekeeping do PO para mover a
  task para `done/`) foi **rejeitado** pelo próprio ruleset (`GH013:
  Required status check "testes" is expected`), pois
  `bypass_actors` está vazio. Isso confirma, na prática, que a proteção é
  ainda mais abrangente do que o escopo original da task (bloqueia
  qualquer push direto, não só merges de PR com check falho) — um efeito
  correto e desejável de segurança, mas que exige adaptar o processo de
  housekeeping do time (ver nota na seção "🎯 ENCERRAMENTO PELO PO" acima).
  Por isso, o encerramento desta task 003 (mover para `done/`) foi feito
  dentro deste mesmo branch/PR de feature, em vez de um push direto a
  `ia-main`.

### Referências úteis
- Workflow existente: `.github/workflows/testes-pr.yml` (job "Testes
  Unitários")
- Task legada de origem do gap: `.kiro/tasks/done/_legado-henrylle/006-feat-github-actions-testes-pr.md`
- Testes unitários do projeto: `tests/unit/` (Jest, mockados, sem
  dependência de banco)

## 💼 Valor de Negócio
**Alto** - Sem essa proteção, a suíte de testes automatizados (task 006
legada) tem valor apenas informativo: qualquer PR pode ser mergeado com
testes quebrados, e o time só percebe depois. Tornar o check obrigatório
fecha esse gap com esforço técnico baixo, mas impacto direto na qualidade
do branch principal.

## 🎯 Estimativa
**2 Story Points** - A configuração em si é simples (uma chamada de API),
mas a task exige investigação da documentação atual do GitHub (evitar
assumir sintaxe desatualizada) e uma validação prática real (PR de teste
com bloqueio confirmado e revertido), o que adiciona esforço e cuidado
extra.

## 🔗 Dependências
Depende do workflow `.github/workflows/testes-pr.yml` já existir e estar
funcional (confirmado: já funciona, rodou com sucesso nos PRs #1 e #2).

---

## 📚 Referências
- [Worktree Workflow](.kiro/docs/worktree-workflow.md)
- [Worktree Steering](.kiro/docs/worktree-steering.md)
- [Task Template](.kiro/docs/task-template-with-worktree.md)
- [Especificação do PO](.kiro/agents/po/especificacao.md)
- [Task legada 006 (origem do gap)](.kiro/tasks/done/_legado-henrylle/006-feat-github-actions-testes-pr.md)
