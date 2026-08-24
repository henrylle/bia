# 004-feat-aba-versao-tela-principal.md

## Descrição

Adicionar uma aba de "Versão" no topo da tela principal da aplicação BIA, que exiba as informações de status da API diretamente na página inicial — sem precisar navegar para `/versao`.

Além disso, criar um novo endpoint `GET /api/versao/info` que retorne as informações de versão em formato JSON (em vez de apenas texto), facilitando o consumo pelo frontend e por ferramentas externas.

**Contexto técnico:**
- O endpoint atual `GET /api/versao` retorna apenas uma string de texto (ex: `Bia 4.2.3`)
- A página `/versao` já existe (`VersionPage.jsx`), mas está isolada como rota separada
- A tela principal (`/`) utiliza abas implícitas (Tarefas / Histórico) definidas no `HomePage` do `App.jsx`
- O novo endpoint deve retornar um objeto JSON com `versao`, `nome` e `timestamp`

## Critérios de aceitação

- [x] Criar o endpoint `GET /api/versao/info` no backend, retornando JSON com os campos: `versao`, `nome` (ex: "BIA"), `timestamp` (ISO 8601)
- [x] O endpoint existente `GET /api/versao` deve continuar funcionando sem alterações (retrocompatibilidade)
- [x] Criar um novo componente `VersaoTab.jsx` em `client/src/components/`
- [x] O componente `VersaoTab.jsx` deve exibir: versão da API, status (Online/Offline/Verificando) com indicador visual, ambiente detectado e URL da API
- [x] O componente deve buscar os dados do novo endpoint `GET /api/versao/info`
- [x] Adicionar uma aba "Versão" no topo da tela principal (`HomePage` no `App.jsx`), ao lado ou acima das demais seções
- [x] A aba deve alternar a exibição entre o conteúdo de tarefas e o painel de versão
- [x] O painel de versão na aba deve ser uma versão compacta (não duplicar a página `/versao` completa)
- [x] A implementação segue o padrão visual (CSS) dos demais componentes do projeto
- [x] A rota `/versao` existente deve continuar funcionando normalmente

## Conclusão

✅ Implementado em:
- `api/controllers/versao.js` — adicionado método `info` com resposta JSON
- `api/routes/versao.js` — registrada rota `GET /api/versao/info`
- `client/src/components/VersaoTab.jsx` — novo componente compacto criado
- `client/src/App.jsx` — aba "Versão" adicionada ao `HomePage` com alternância de conteúdo
- `client/src/index.css` — estilos para `.home-tabs`, `.home-tab-btn` e `.versao-tab`
