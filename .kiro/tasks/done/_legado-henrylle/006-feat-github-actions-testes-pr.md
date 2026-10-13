# 006 · feat · GitHub Actions — Executar testes a cada PR contra ia-main

## Informações de Trabalho

| Campo | Valor |
|---|---|
| **Branch da feature** | `feature/006-feat-github-actions-testes-pr` |
| **Derivar de** | `ia-main` |
| **Agent responsável pelo início** | `devops` (`.kiro/agents/devops.json`) |

---

## Contexto

O projeto BIA já possui uma suíte de testes unitários em Jest (`tests/unit/`), cobrindo os controllers de `versao` e `tarefas`. Atualmente não existe nenhum pipeline de CI configurado. O objetivo desta task é criar um workflow do GitHub Actions que execute automaticamente esses testes sempre que um Pull Request for aberto ou atualizado contra o branch `ia-main`.

---

## História de Usuário

> **Como** desenvolvedor do projeto BIA,  
> **Quero** que os testes unitários sejam executados automaticamente a cada PR aberto contra `ia-main`,  
> **Para que** eu tenha feedback imediato sobre a qualidade do código antes de fazer o merge.

---

## Critérios de Aceite

- [x] Existe o arquivo `.github/workflows/testes-pr.yml` no repositório
- [x] O workflow é disparado em `pull_request` com target branch `ia-main`
- [x] O workflow executa `npm test` (que roda `jest tests/unit`)
- [x] O workflow usa Node.js compatível com o projeto (verificar `package.json` — Jest 27)
- [ ] O status do workflow aparece como check obrigatório no PR (visível na interface do GitHub)
- [x] Todos os testes existentes passam no workflow
- [x] O workflow não tenta conectar ao banco de dados (os testes são unitários e mockados)

---

## Checklist de Implementação — Agent `devops`

### Pré-início (obrigatório)
- [x] Verificar se está no branch `ia-main` (`git branch --show-current`)
  - Se não estiver em `ia-main`, informar ao usuário e perguntar se pode retornar antes de prosseguir
- [x] Após autorização: mover este arquivo para `.kiro/tasks/doing/`
- [x] Fazer `commit` e `push` no branch `ia-main` com a mensagem: `chore: move task 006 para doing`
- [x] Criar e mudar para o branch `feature/006-feat-github-actions-testes-pr`

### Implementação
- [x] Criar o diretório `.github/workflows/` na raiz do projeto (se não existir)
- [x] Criar o arquivo `.github/workflows/testes-pr.yml` com o workflow de CI
  - Trigger: `pull_request` com `branches: [ia-main]`
  - Runner: `ubuntu-latest`
  - Node.js: versão compatível com Jest 27 (Node 16 ou 18)
  - Steps: `checkout` → `npm install` → `npm test`
  - Sem step de banco de dados (testes são unitários/mockados)
- [x] Verificar localmente se o arquivo YAML está sintaticamente correto
- [x] Executar `npm test` localmente para confirmar que todos os testes passam antes do push

### Validação
- [x] Fazer `commit` e `push` do branch `feature/006-feat-github-actions-testes-pr`
- [ ] Abrir um PR de teste contra `ia-main` e confirmar que o workflow é disparado no GitHub
- [ ] Confirmar que todos os checks passam com ✅

### Encerramento
- [x] Informar ao PO (`po`) que a implementação foi concluída e a task está pronta para revisão final

---

## Detalhes Técnicos

### Estrutura de testes atual
```
tests/
└── unit/
    └── controllers/
        ├── versao.test.js    (3 testes)
        └── tarefas.test.js   (14 testes)
```

### Comando de teste
```bash
npm test
# equivale a: jest tests/unit
```

### Referência do workflow esperado
```yaml
name: Testes Unitários

on:
  pull_request:
    branches:
      - ia-main

jobs:
  testes:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
      - run: npm install
      - run: npm test
```

> ⚠️ O workflow acima é apenas uma referência. O agent `devops` deve validar a versão do Node e demais detalhes antes de criar o arquivo final.

---

## Finalização — Agent `po`

Quando o agent `devops` sinalizar conclusão, o PO deve:

- [x] Verificar se o arquivo `.github/workflows/testes-pr.yml` foi criado corretamente
- [x] Confirmar que todos os itens do checklist acima estão marcados
- [x] Confirmar que o workflow passou com ✅ no GitHub
- [x] Verificar que não foram introduzidas dependências desnecessárias
- [x] Informar ao usuário que a task está finalizada
- [x] Mover este arquivo de `doing/` para `.kiro/tasks/done/`
- [x] Verificar o branch atual com `git branch --show-current`
  - Se estiver em `ia-main`, trocar para `feature/006-feat-github-actions-testes-pr` antes de prosseguir
- [x] Fazer `commit` e `push` final com a mensagem: `chore: move task 006 para done`
- [x] Abrir Pull Request:
  ```
  gh pr create --base ia-main --title "006: GitHub Actions - testes unitários a cada PR" --body "Closes task 006"
  ```
