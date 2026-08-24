# 003-feat-github-actions-testes-pr.md

## Descrição

Configurar um workflow de GitHub Actions para executar automaticamente os testes unitários do backend a cada Pull Request aberto contra a branch `main`. O objetivo é garantir que nenhuma task quebre os testes existentes antes de ser integrada.

O projeto já possui testes unitários com Jest localizados em `tests/unit/controllers/`, cobrindo os controllers `versao` e `tarefas`. O comando de execução já está configurado no `package.json` como `npm test` (que executa `jest tests/unit`).

## Critérios de aceitação

- [x] Criar o arquivo `.github/workflows/testes-pr.yml`
- [x] O workflow deve ser disparado em Pull Requests com destino à branch `main`
- [x] Deve utilizar Node.js 24.x (versão alinhada ao projeto)
- [x] Deve executar `npm ci` para instalação das dependências
- [x] Deve executar `npm test` para rodar os testes unitários (`tests/unit/controllers/versao.test.js` e `tests/unit/controllers/tarefas.test.js`)
- [x] O PR deve ser bloqueado (status check obrigatório) caso algum teste falhe
- [x] O workflow deve rodar apenas no diretório raiz (backend), não no `client/`

## Conclusão

✅ Implementado em `.github/workflows/testes-pr.yml`
