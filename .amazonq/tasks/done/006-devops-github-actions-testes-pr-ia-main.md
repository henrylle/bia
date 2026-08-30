# 006-devops-github-actions-testes-pr-ia-main

## Descrição

Atualizar o workflow de GitHub Actions para executar automaticamente os testes unitários do backend a cada Pull Request aberto contra a branch `ia_main`.

Atualmente, o arquivo `.github/workflows/testes-pr.yml` está configurado para disparar em PRs contra a branch `main`. O objetivo é ajustar o target branch para `ia_main`, que é a branch base de integração das tasks do projeto.

O projeto possui testes unitários com Jest em `tests/unit/controllers/`, cobrindo os controllers `versao` e `tarefas`. O comando de execução está configurado no `package.json` como `npm test` (executa `jest tests/unit`).

## Critérios de aceitação

- [x] Atualizar `.github/workflows/testes-pr.yml` para disparar em PRs com destino à branch `ia_main`
- [x] O workflow deve continuar utilizando Node.js 24.x (versão alinhada ao projeto)
- [x] Deve executar `npm ci` para instalação das dependências
- [x] Deve executar `npm test` para rodar os testes unitários (`tests/unit/controllers/versao.test.js` e `tests/unit/controllers/tarefas.test.js`)
- [x] O PR deve ser bloqueado (status check obrigatório) caso algum teste falhe
- [x] O workflow deve rodar apenas no diretório raiz (backend), não no `client/`
- [x] Validar localmente com `npm test` que todos os testes passam antes de aplicar

## Contexto técnico

- Arquivo modificado: `.github/workflows/testes-pr.yml`
- Branch base anterior (errada): `main`
- Branch base correta: `ia_main`
- Testes validados:
  - `tests/unit/controllers/versao.test.js` — 3 testes ✅
  - `tests/unit/controllers/tarefas.test.js` — 13 testes ✅
- Resultado: 16/16 testes passando

## Correções adicionais aplicadas

Durante a validação foram encontradas regressões pré-existentes das tasks anteriores:

1. **versao.test.js**: versão esperada atualizada de `4.2.0` para `4.2.3` (alinhada ao `versao.js`)
2. **tarefas.test.js**: mock de `initializeModels` atualizado para incluir `TarefaVersoes` (introduzido na task 002)
3. **api/controllers/tarefas.js**: removida chamada a `refreshCache()` que não estava definida (bug da task 002)

## Agente responsável

@devops
