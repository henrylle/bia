# 001-feat-tela-de-versao

## Descrição

Criar uma página dedicada de versão no frontend da aplicação BIA, acessível pela rota `/versao`.

Atualmente, as informações de versão e status da API estão disponíveis apenas em um tooltip no Header (componente `VersionInfo`). A proposta é criar uma tela completa que centralize essas informações de forma clara e didática, sendo especialmente útil para alunos verificarem o estado do ambiente (local, EC2, ALB) e validarem a conectividade com a API.

A tela deve consumir o endpoint existente `GET /api/versao`, que retorna a string `Bia {VERSAO_API}`, e exibir as informações de forma organizada. O componente `VersionInfo` existente pode ser reaproveitado como base para a lógica de verificação de saúde da API.

**Contexto técnico:**
- Frontend: React 17 com React Router DOM e Vite
- Backend: endpoint `GET /api/versao` já implementado em `api/controllers/versao.js`
- Componente de referência: `client/src/components/VersionInfo.jsx`
- Rota de navegação a ser criada: `/versao`
- Padrão de rota existente: ver `App.jsx` com rotas `/` e `/about`

## Critérios de aceitação

- [x] Existe uma nova rota `/versao` registrada no `App.jsx`
- [x] Existe um novo componente `VersionPage.jsx` em `client/src/components/`
- [x] A tela exibe a versão retornada pelo endpoint `GET /api/versao` (ex: `Bia 4.3.0`)
- [x] A tela exibe o status da API (Online / Offline / Verificando) com indicador visual
- [x] A tela exibe o tipo de ambiente detectado (Local, IP Direto, ALB, Produção)
- [x] A tela exibe a URL da API que está sendo utilizada
- [x] A tela possui um botão para atualizar as informações manualmente (recheca o endpoint)
- [x] A tela possui um link de retorno para a página inicial (`/`)
- [x] O Header ou algum elemento de navegação existente possui um link para acessar a tela `/versao`
- [x] A página segue o padrão visual (CSS) das demais páginas do projeto
