# 002 - Ativar Healthcheck do Container `server` no `compose.yml`

## 🔧 Configuração Inicial (LEIA ANTES DE INICIAR)

### Agent Responsável
**dev** - Este agent deve iniciar a implementação (descomentar/ajustar o
healthcheck em `compose.yml` e subir o ambiente local). Ao concluir, deve
chamar o **qa** para validar os cenários de "healthy" e "unhealthy". Depois
da validação do qa, o **devops** entra de forma consultiva (somente
leitura via `aws-mcp`) para comparar os parâmetros propostos com o que já
existe no serviço ECS de produção, **antes** do PO fechar a task.

### Branch Base
**SEMPRE `ia-main`**

### Worktree
Esta task será implementada em worktree isolado em
`.kiro/worktrees/002-feat-healthcheck-container-server/`

### Escopo
- **Somente `compose.yml`** na raiz do projeto. Não alterar `Dockerfile`,
  código de `api/` ou `client/`.
- O `Dockerfile` já instala `curl` (linha 5), então nenhuma mudança de
  imagem é necessária para o healthcheck funcionar.
- O `devops` **não altera nada** — atua só como consultor, com acesso
  somente leitura (`aws-mcp`, conta `formacaoaws`, região `us-east-1`).

---

## ⚠️ CHECKLIST DE INÍCIO (OBRIGATÓRIO)

Antes de começar a implementar, o agent (dev) deve:

- [x] **Verificar branch atual:** `git branch --show-current`
  - Se não estiver em `ia-main`, **PERGUNTAR** ao usuário se pode trocar
  - Aguardar autorização
  - Após autorização: `git checkout ia-main && git pull origin ia-main`

- [x] **Mover task para doing:**
  ```bash
  mv .kiro/tasks/002-feat-healthcheck-container-server.md .kiro/tasks/doing/
  git add .kiro/tasks/
  git commit -m "move: task 002 para doing"
  git push origin ia-main
  ```

- [x] **Criar worktree:**
  ```bash
  git worktree add .kiro/worktrees/002-feat-healthcheck-container-server -b feature/002-feat-healthcheck-container-server ia-main
  cd .kiro/worktrees/002-feat-healthcheck-container-server
  git branch --show-current  # Confirmar branch correto
  ```

---

## 📋 Tipo
**feat** - Habilitar monitoramento de saúde (healthcheck) do container
`server` no ambiente local via Docker Compose.

## 📝 Resumo
Descomentar e validar o bloco `healthcheck` do serviço `server` em
`compose.yml`, usando `curl` contra `/api/versao`, com
intervalo/timeout/retries adequados — hoje esse bloco existe no arquivo
mas está comentado (linhas 21-26).

## 📖 Descrição
Como time de desenvolvimento do BIA, eu quero que o container `server`
tenha um healthcheck ativo no `compose.yml`, para que `docker ps` e
ferramentas de orquestração consigam identificar rapidamente quando a
aplicação está fora do ar (ex.: travada, processo down), e não apenas se
o processo do container ainda existe.

## ✅ Critérios de Aceitação

### Funcionalidades Principais
- [x] O bloco `healthcheck` do serviço `server` em `compose.yml` está
      **ativo** (não comentado), usando `curl -f` contra
      `http://localhost:8080/api/versao` (porta interna do container,
      conforme `EXPOSE 8080` no `Dockerfile`).
- [x] Os parâmetros de `interval`, `timeout`, `retries` e `start_period`
      estão definidos com valores adequados para um ambiente local de
      estudo (sugestão de partida, já presente comentada no arquivo:
      `interval: 10s`, `timeout: 5s`, `retries: 3`, `start_period: 5s`) —
      o dev pode ajustar esses valores se, na prática, o app demorar mais
      para subir, desde que justifique a mudança.
      **Resultado:** valores comentados mantidos sem alteração — na
      prática o app ficou `healthy` no primeiro ciclo (~10s), então não
      houve necessidade de ajuste.
- [x] Ao subir o ambiente (`docker compose up`), o container `server`
      atinge o status **healthy** em `docker ps` dentro de um tempo
      razoável após o start.
      **Evidência:** `docker ps` → `bia   Up 15 seconds (healthy)`, e
      `docker inspect --format='{{json .State.Health}}' bia` → primeiro
      ciclo já com `"Status":"healthy"`.

### Integração
- [x] Nenhuma alteração em `Dockerfile`, `api/` ou `client/` — mudança
      restrita a `compose.yml`. Confirmado via `git diff compose.yml`
      (único arquivo modificado, apenas o bloco `healthcheck`).
- [x] `/api/versao` continua respondendo normalmente após a mudança
      (checagem padrão de qualquer alteração de infraestrutura local do
      projeto). Confirmado: `curl -s http://localhost:3001/api/versao`
      → `Bia 4.2.0`.

### Consultivo (devops, antes do fechamento pelo PO)
- [x] O **devops** confirmou, via `aws-mcp` (somente leitura), que o
      serviço ECS ativo em produção é `service-bia` (sem ALB —
      `loadBalancers: []`, `launchType: EC2`, cluster `cluster-bia`),
      rodando `task-def-bia:2`. O container `bia` dessa Task Definition
      **não possui `healthCheck` configurado** (campo ausente no
      `DescribeTaskDefinition`).
- [x] N/A — não há healthcheck em produção para comparar parâmetros.
- [x] Achado registrado: ECS de produção (`task-def-bia`) não tem
      `healthCheck` no container nem health check de ALB (não há ALB).
      Recomendação de backlog futuro (não bloqueia esta task): caso o
      time queira alinhar prod ↔ local, os valores já usados no
      `compose.yml` (`interval: 10s`, `timeout: 5s`, `retries: 3`,
      `start_period: 5s`) são compatíveis com os limites aceitos pelo
      ECS `healthCheck` (interval 5–300s, timeout 2–60s, retries 1–10,
      startPeriod 0–300s), adaptando apenas o formato do `test` para
      `CMD-SHELL` (ex.: `["CMD-SHELL", "curl -f
      http://localhost:8080/api/versao || exit 1"]`).

## 🧪 Testes (qa)
- [x] **Cenário 1 — Healthy:** Subir o ambiente
      (`docker compose up -d --build`) e, via `docker ps`, confirmar que o
      container `server` (nome `bia`) atinge o status `healthy` (não
      apenas `Up`).
      **Resultado:** `bia   Up 11 minutes (healthy)`. `docker inspect
      --format='{{json .State.Health}}' bia` → `"Status":"healthy"`,
      `"FailingStreak":0`, todos os ciclos com `ExitCode:0` e saída
      `Bia 4.2.0`.
- [x] **Cenário 2 — Caminho de falha (banco indisponível):** Parar o
      container do banco (`docker stop database`) e observar, via
      `docker ps` / `docker inspect --format='{{json .State.Health}}' bia`,
      o que acontece com o status do container `server` ao longo de
      alguns ciclos de healthcheck.
  - ⚠️ **Ver nota técnica obrigatória abaixo** antes de rodar este
    cenário — o resultado esperado **não é necessariamente
    "unhealthy"**, dado o comportamento atual do endpoint `/api/versao`.
    O qa deve **documentar o resultado real observado**, não forçar um
    resultado específico.
    **Resultado real observado:** com `database` parado, o container
    `server` **permaneceu `healthy`** ao longo de 5 ciclos consecutivos
    (~50s, `interval: 10s`), todos com `ExitCode:0` e saída `Bia 4.2.0`
    — confirma exatamente o comportamento previsto na nota técnica, já
    que `/api/versao` não consulta o banco. Nenhuma transição para
    `unhealthy` ocorreu.
  - [x] Religar o banco (`docker start database`) ao final do teste e
        confirmar que o ambiente volta ao estado normal.
        **Resultado:** `docker start database` → `database   Up 5
        seconds`, `bia` seguiu `healthy` durante toda a interrupção e
        depois dela, sem qualquer degradação.

## 📚 Definição de Pronto (DoD)
- [x] Código implementado e testado (bloco `healthcheck` ativo em
      `compose.yml`)
- [x] Todos os itens do checklist marcados ✅
- [x] Commits descritivos e frequentes
- [x] Push do branch realizado
- [x] Rebuild dos containers realizado (`docker compose down` → `build`
      → `up`) e `/api/versao` respondendo, conforme
      `.kiro/agents/dev/instrucoes.md`
- [x] QA validou os dois cenários (healthy e caminho de falha) e
      registrou o resultado observado
- [x] Devops registrou a comparação com o ECS de produção (achado +
      recomendação), de forma somente leitura

---

## 🎯 CHECKLIST DE IMPLEMENTAÇÃO (MARCAR DURANTE O TRABALHO)

### Configuração
- [x] Worktree criado e branch correto confirmado
- [x] Ambiente de desenvolvimento configurado no worktree

### Desenvolvimento (dev)
- [x] Descomentar o bloco `healthcheck` do serviço `server` em
      `compose.yml` (linhas 21-26 no arquivo atual)
- [x] Revisar/ajustar os valores de `interval`, `timeout`, `retries`,
      `start_period` se necessário, justificando qualquer mudança em
      relação ao valor comentado original — **nenhum ajuste necessário**,
      valores comentados originais mantidos (`10s`/`5s`/`3`/`5s`).
- [x] Confirmar que o comando do healthcheck usa a porta interna correta
      (`8080`, conforme `EXPOSE 8080` do `Dockerfile`) e o caminho
      `/api/versao`
- [x] Subir o ambiente local (`docker compose up -d --build`)
- [x] Confirmar via `docker ps` que o container `server` (nome `bia`)
      aparece como `healthy`
- [x] Rebuild completo dos containers (`docker compose down` → `build` →
      `up`) e confirmação de que `/api/versao` responde (regra padrão do
      dev)
- [x] Notificar o **qa** para validação dos dois cenários

> **Nota para o qa (achado de ambiente, não relacionado ao código):**
> Nesta máquina/WSL existe um container `my-postgres` (não pertence ao
> projeto BIA, network `postgressql_my-network-sql`) que já ocupa a
> porta host `5433` continuamente. Isso gera conflito de porta com o
> serviço `database` deste projeto (`ports: - 5433:5432`), impedindo o
> `docker compose up` "puro" de subir o container `database` enquanto
> `my-postgres` estiver rodando — **esse conflito é pré-existente e não
> foi introduzido por esta task** (a porta 5433 já estava mapeada assim
> antes da mudança; `git diff compose.yml` mostra alteração restrita ao
> bloco `healthcheck`).
> Para validar, foi usado um `compose.override.yml` **local e não
> versionado** (removido ao final) apenas remapeando a porta host do
> `database` (ex.: `5555:5432`) via `docker compose -f compose.yml -f
> compose.override.yml up -d --build`. O qa pode usar a mesma estratégia
> se `my-postgres` ainda estiver ocupando a 5433, ou parar
> temporariamente esse container manualmente (fora do escopo desta
> task).

### Validação (qa)
- [x] Confirmar via `docker ps` que `server` está `healthy` após subir o
      ambiente (Cenário 1)
- [x] Rodar o Cenário 2 (parar `database`, observar `server` via
      `docker ps`/`docker inspect`) e **documentar o resultado real**
      (pode ser que o container continue `healthy`, dado que
      `/api/versao` não depende do banco — ver Notas Técnicas)
- [x] Religar o `database` e confirmar retorno ao estado normal
- [x] Registrar evidências (saída de `docker ps`/`docker inspect`,
      prints/logs) e notificar o **devops** para a etapa consultiva de
      comparação com produção

> **Nota de execução:** o agente `qa` (acesso `fs_read` + Playwright, sem
> Docker/Bash) validou via UI/HTTP que `/api/versao` responde `Bia 4.2.0`
> e revisou o `compose.yml`/branch, mas não tem ferramentas para rodar
> `docker ps`/`docker inspect`/`docker stop`. Os comandos Docker dos dois
> cenários acima (evidências registradas nesta seção e na seção "🧪
> Testes (qa)") foram executados pelo **po**, a pedido do usuário, para
> fechar essa lacuna estrutural do agente qa. Achado do qa fora do
> escopo desta task: `GET /api/tarefas` retorna 500 (`relation
> "Tarefas" does not exist`) — banco local sem migrations aplicadas;
> registrar como item de backlog futuro.

### Consulta (devops — somente leitura, antes do fechamento)
- [x] Consultado via `aws-mcp`: cluster `cluster-bia`, serviço
      `service-bia` (sem ALB), task definition `task-def-bia:2`.
      Container `bia` **sem** `healthCheck` configurado.
- [x] N/A — não há healthcheck em produção para comparar.
- [x] Achado registrado como observação de backlog (não bloqueia): ECS
      sem healthcheck nativo; sugestão de parâmetros compatíveis
      documentada acima, para avaliação futura do time (fora do escopo
      desta task).
- [x] PO notificado.

### Finalização
- [x] Código revisado
- [x] Commits finalizados com mensagens descritivas
- [x] Push do branch realizado
- [x] Todos os itens acima marcados ✅

---

## ⚠️ FINALIZAÇÃO DA TASK (OBRIGATÓRIO)

Quando o **dev** concluir a implementação:

### 1. Verificação Final
```bash
# Garantir que está no worktree correto
pwd
# Deve estar em: /caminho/do/projeto/.kiro/worktrees/002-feat-healthcheck-container-server

# Verificar branch
git branch --show-current
# Deve mostrar: feature/002-feat-healthcheck-container-server
```

### 2. Commit e Push Final
```bash
git add .
git commit -m "feat: ativa healthcheck do container server no compose.yml"
git push origin feature/002-feat-healthcheck-container-server
```

### 3. Chamar o QA, depois o Devops
O dev notifica o **qa** para validar os dois cenários (healthy/falha) no
mesmo worktree/branch. Após a validação do qa (com evidências
registradas), o **qa** notifica o **devops** para a etapa consultiva de
comparação com o ECS de produção (somente leitura, sem alterar nada).

### 4. Voltar para Raiz e Notificar PO
```bash
cd ../../..  # Voltar para raiz do projeto
```

**NOTIFICAR O PO (após validação do qa e consulta do devops):**
> "Task 002 concluída pelo dev, validada pelo qa (cenários healthy e de
> falha documentados) e revisada pelo devops (comparação com ECS de
> produção registrada). Branch
> `feature/002-feat-healthcheck-container-server` com push realizado.
> Aguardando revisão do PO para encerramento e abertura de PR."

**⚠️ NÃO REMOVER O WORKTREE. Apenas o PO faz isso após o PR ser
mergeado.**

---

## 🎯 ENCERRAMENTO PELO PO (QUANDO NOTIFICADO)

### 1. Revisão
```bash
# Entrar no worktree para revisar
cd .kiro/worktrees/002-feat-healthcheck-container-server

# Revisar código, testar funcionalidade
# Verificar se todos os itens estão ✅ (incluindo validação do qa e
# consulta do devops)
```

### 2. Aprovar e Mover para Done
```bash
# Voltar para raiz
cd ../../..

# Mover task para done
mv .kiro/tasks/doing/002-feat-healthcheck-container-server.md .kiro/tasks/done/

# Commit e push no ia-main
git checkout ia-main
git add .kiro/tasks/
git commit -m "move: task 002 para done"
git push origin ia-main
```

### 3. Abrir Pull Request
```bash
# ANTES de abrir PR: confirmar que está no branch da feature (NUNCA em ia-main)
cd .kiro/worktrees/002-feat-healthcheck-container-server
git branch --show-current
# Comparar a saída com o nome esperado: feature/002-feat-healthcheck-container-server (mesmo nome da task)
# Se não bater (ex.: mostrar "ia-main"), PARAR — NÃO rodar o gh pr create abaixo

# Só prosseguir se o branch confirmado bater com o esperado:
gh pr create --base ia-main --title "002: Ativar healthcheck do container server no compose.yml" --body "Closes task 002"
```

### 4. Após PR Mergeado
```bash
# Voltar para raiz
cd ../../..

# Remover worktree
git worktree remove .kiro/worktrees/002-feat-healthcheck-container-server

# Ou com força se necessário:
# git worktree remove --force .kiro/worktrees/002-feat-healthcheck-container-server

# Limpar registros
git worktree prune

# (Opcional) Deletar branch local
git branch -d feature/002-feat-healthcheck-container-server

# Notificar conclusão
```

---

## 📊 Notas Técnicas

### Bloco atual (comentado) em `compose.yml`
```yaml
    # healthcheck:
    #   test: ["CMD", "curl", "-f", "http://localhost:8080/api/versao"]
    #   interval: 10s
    #   timeout: 5s
    #   retries: 3
    #   start_period: 5s
```
A porta `8080` é a porta **interna** do container (`EXPOSE 8080` no
`Dockerfile`), mapeada para `3001` no host (`ports: - 3001:8080`) — o
healthcheck deve continuar usando `localhost:8080` (executa *dentro* do
container), não `3001`.

### ⚠️ Achado importante: `/api/versao` não depende do banco de dados
Ao revisar `api/controllers/versao.js`, o endpoint apenas retorna uma
string estática (`Bia ${process.env.VERSAO_API || "4.2.0"}`) — **não faz
nenhuma consulta ao banco**. Isso significa que, no Cenário 2 de teste
(parar o container `database`), é esperado que o healthcheck **continue
passando** e o container `server` **permaneça `healthy`**, já que o
endpoint monitorado não é afetado pela indisponibilidade do banco.

Isso **não invalida a task** (o objetivo aqui é apenas ativar o
healthcheck existente, com escopo restrito a `compose.yml`), mas é uma
informação importante que o **qa deve documentar como resultado real**
do teste, em vez de assumir que o container ficará `unhealthy`. Se o
time concluir que o healthcheck deveria refletir também a saúde da
conexão com o banco, isso deve virar uma **sugestão de backlog futura**
(alteração em `api/`, fora do escopo desta task) — não deve ser
implementado aqui.

### Sobre o `depends_on` do serviço `server`
O `compose.yml` já tem `depends_on: - database`, mas essa dependência
apenas controla **ordem de start**, não espera o banco ficar saudável
(o `database` não tem `healthcheck` definido). Não é necessário mexer
nisso nesta task — está fora do escopo pedido.

### Referência de nomes de recursos ECS (para o devops)
Conforme `.kiro/rules/infraestrutura.md`: `service-bia` (sem ALB) ou
`service-bia-alb` (com ALB), `task-def-bia`/`task-def-bia-alb`. O devops
deve confirmar qual está ativo em produção antes de consultar o
healthcheck da Task Definition.

## 💼 Valor de Negócio
**Médio** - Melhora a observabilidade do ambiente local (e serve de
referência para alinhar com produção), permitindo identificar
rapidamente containers travados via `docker ps`, com baixíssimo esforço
de implementação (mudança já estava pronta, só comentada).

## 🎯 Estimativa
**1 Story Point** - Alteração pontual em `compose.yml` (descomentar +
validar), sem mudança de código de aplicação; esforço maior está na
validação dos dois cenários pelo qa e na consulta comparativa do devops.

## 🔗 Dependências
Nenhuma.

---

## 📚 Referências
- [Worktree Workflow](.kiro/docs/worktree-workflow.md)
- [Worktree Steering](.kiro/docs/worktree-steering.md)
- [Task Template](.kiro/docs/task-template-with-worktree.md)
- [Especificação do PO](.kiro/agents/po/especificacao.md)
- [Regras de Infraestrutura](.kiro/rules/infraestrutura.md)
- [Regras de Dockerfile](.kiro/rules/dockerfile.md)
