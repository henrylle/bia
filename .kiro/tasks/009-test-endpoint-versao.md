# Task 009 - Implementar e Executar Testes do Endpoint /api/versao

## 🔧 Configuração Inicial (LEIA ANTES DE INICIAR)

### Agent Responsável
**qa** - Este agent deve iniciar a implementação.

### Branch Base
**SEMPRE `ia-main`**

### Worktree
Esta task será implementada em worktree isolado em `.kiro/worktrees/009-test-endpoint-versao/`

---

## ⚠️ CHECKLIST DE INÍCIO (OBRIGATÓRIO)

Antes de começar a implementar, o agent deve:

- [ ] **Verificar branch atual:** `git branch --show-current`
  - Se não estiver em `ia-main`, **PERGUNTAR** ao usuário se pode trocar
  - Aguardar autorização
  - Após autorização: `git checkout ia-main && git pull origin ia-main`

- [ ] **Mover task para doing:**
  ```bash
  mv .kiro/tasks/009-test-endpoint-versao.md .kiro/tasks/doing/
  git add .kiro/tasks/
  git commit -m "move: task 009 para doing"
  git push origin ia-main
  ```

- [ ] **Criar worktree:**
  ```bash
  git worktree add .kiro/worktrees/009-test-endpoint-versao -b test/009-test-endpoint-versao ia-main
  cd .kiro/worktrees/009-test-endpoint-versao
  git branch --show-current  # Confirmar branch correto
  ```

---

## 📋 Descrição da Tarefa

Revisar, expandir e executar os testes unitários do endpoint `/api/versao` para garantir cobertura completa e qualidade do código.

### Contexto
Atualmente existe o arquivo `tests/unit/controllers/versao.test.js` com testes básicos. Esta task visa:
- Revisar os testes existentes
- Expandir a cobertura de testes
- Garantir que todos os cenários estão cobertos
- Executar os testes e validar resultados
- Documentar a execução dos testes

---

## 🎯 Objetivos

1. **Revisar testes existentes** em `tests/unit/controllers/versao.test.js`
2. **Expandir cobertura de testes** com novos casos
3. **Garantir que testes seguem padrão** do projeto (jest)
4. **Executar testes e documentar resultados**
5. **Validar funcionamento do endpoint** na prática

---

## 📐 Especificação Técnica

### 1. Arquivo de Testes

**Localização:** `tests/unit/controllers/versao.test.js`

**Framework:** Jest (já configurado no projeto)

### 2. Controller Testado

**Localização:** `api/controllers/versao.js`

**Método:** `get(req, res)`

**Comportamento:**
```javascript
controller.get = async (req, res) => {
  const responseString = `Bia ${process.env.VERSAO_API || "4.2.0"}`;
  res.send(responseString);
};
```

### 3. Cenários de Teste

#### 3.1 Testes Existentes (Revisar)
- ✅ Retorna string correta com versão padrão
- ✅ Retorna versão padrão quando `VERSAO_API` não está definida
- ✅ Retorna versão customizada quando `VERSAO_API` está definida

#### 3.2 Novos Testes a Implementar

**Teste 1: Verificar formato da resposta**
```javascript
test('get deve retornar string no formato "Bia X.X.X"', () => {
  const { get } = versaoController();
  get(req, res);
  
  expect(res.send).toHaveBeenCalled();
  const response = res.send.mock.calls[0][0];
  expect(response).toMatch(/^Bia \d+\.\d+\.\d+$/);
});
```

**Teste 2: Método assíncrono**
```javascript
test('get deve ser uma função assíncrona', async () => {
  const { get } = versaoController();
  const result = get(req, res);
  
  // Verifica que retorna uma Promise
  expect(result).toBeInstanceOf(Promise);
  await result;
});
```

**Teste 3: Variáveis de ambiente com valores vazios**
```javascript
test('get deve usar versão padrão quando VERSAO_API é string vazia', () => {
  process.env.VERSAO_API = '';
  
  const { get } = versaoController();
  get(req, res);
  
  expect(res.send).toHaveBeenCalledWith('Bia 4.2.0');
});
```

**Teste 4: Variáveis de ambiente com valores inválidos**
```javascript
test('get deve usar valor de VERSAO_API mesmo que seja inválido', () => {
  process.env.VERSAO_API = 'versao-invalida';
  
  const { get } = versaoController();
  get(req, res);
  
  expect(res.send).toHaveBeenCalledWith('Bia versao-invalida');
});
```

**Teste 5: Múltiplas chamadas mantém comportamento**
```javascript
test('get deve manter comportamento consistente em múltiplas chamadas', () => {
  process.env.VERSAO_API = '5.0.0';
  const { get } = versaoController();
  
  // Primeira chamada
  get(req, res);
  expect(res.send).toHaveBeenCalledWith('Bia 5.0.0');
  
  // Limpar mock
  res.send.mockClear();
  
  // Segunda chamada
  get(req, res);
  expect(res.send).toHaveBeenCalledWith('Bia 5.0.0');
});
```

**Teste 6: Verificar que res.send é chamado exatamente uma vez**
```javascript
test('get deve chamar res.send exatamente uma vez', () => {
  const { get } = versaoController();
  get(req, res);
  
  expect(res.send).toHaveBeenCalledTimes(1);
});
```

### 4. Estrutura Esperada do Arquivo de Teste

```javascript
const versaoController = require('../../../api/controllers/versao');

describe('Versao Controller', () => {
  let req, res;

  beforeEach(() => {
    // Setup fresh mocks para cada teste
    req = {};
    res = {
      send: jest.fn(),
    };
    
    // Limpar mocks e variáveis de ambiente
    jest.clearAllMocks();
    delete process.env.VERSAO_API;
  });

  describe('get method', () => {
    // Testes existentes...
    
    // Novos testes...
  });
});
```

---

## ✅ Checklist de Implementação

### Análise Inicial

- [ ] Ler arquivo de teste atual: `tests/unit/controllers/versao.test.js`
- [ ] Ler controller testado: `api/controllers/versao.js`
- [ ] Ler exemplo de teste: `tests/unit/controllers/tarefas.test.js`
- [ ] Verificar configuração do Jest no `package.json`

### Implementação dos Testes

- [ ] Revisar testes existentes:
  - [ ] Verificar se estão funcionando corretamente
  - [ ] Melhorar descrições se necessário
  - [ ] Adicionar comentários explicativos

- [ ] Implementar novos testes:
  - [ ] Teste de formato da resposta (regex)
  - [ ] Teste de função assíncrona
  - [ ] Teste com VERSAO_API vazia
  - [ ] Teste com VERSAO_API inválida
  - [ ] Teste de múltiplas chamadas
  - [ ] Teste de res.send chamado uma vez

- [ ] Melhorar estrutura do arquivo:
  - [ ] Organizar em describes aninhados
  - [ ] Adicionar beforeEach robusto
  - [ ] Adicionar afterEach se necessário

### Execução dos Testes

- [ ] Executar testes localmente:
  ```bash
  npm test tests/unit/controllers/versao.test.js
  ```

- [ ] Verificar que todos os testes passam
- [ ] Verificar cobertura de código (se disponível)
- [ ] Documentar resultado da execução

### Validação Prática

- [ ] Iniciar servidor da API:
  ```bash
  npm start
  ```

- [ ] Testar endpoint manualmente:
  ```bash
  curl http://localhost:8080/api/versao
  ```

- [ ] Testar com variável de ambiente:
  ```bash
  VERSAO_API=5.0.0 npm start
  curl http://localhost:8080/api/versao
  ```

- [ ] Documentar resultados

### Documentação

- [ ] Criar arquivo `tests/unit/controllers/versao.test.results.md`:
  - [ ] Descrever testes implementados
  - [ ] Incluir output da execução
  - [ ] Incluir screenshots ou logs
  - [ ] Documentar casos cobertos

- [ ] Atualizar comentários no código de teste
- [ ] Adicionar exemplos de uso se necessário

---

## 🧪 Critérios de Aceitação

### Testes Unitários
1. ✅ Arquivo `versao.test.js` atualizado com novos testes
2. ✅ Mínimo de **9 testes** implementados (3 existentes + 6 novos)
3. ✅ Todos os testes devem passar com sucesso
4. ✅ Cobertura de cenários positivos e negativos
5. ✅ Testes seguem padrão do projeto (Jest + mocks)
6. ✅ Código de teste limpo e comentado

### Execução
1. ✅ Comando `npm test tests/unit/controllers/versao.test.js` executa sem erros
2. ✅ Todos os testes passam (0 failed)
3. ✅ Tempo de execução razoável (< 5 segundos)
4. ✅ Sem warnings ou erros no console

### Validação Prática
1. ✅ Endpoint `/api/versao` responde corretamente
2. ✅ Testado com e sem variável de ambiente
3. ✅ Resposta no formato esperado: "Bia X.X.X"

### Documentação
1. ✅ Arquivo `versao.test.results.md` criado
2. ✅ Output dos testes documentado
3. ✅ Casos de teste explicados
4. ✅ Testes práticos documentados

---

## 📊 Template de Documentação

Criar arquivo `tests/unit/controllers/versao.test.results.md`:

```markdown
# Resultados dos Testes - Endpoint /api/versao

**Data:** [DATA]
**Executor:** Agent QA
**Branch:** test/009-test-endpoint-versao

---

## 📝 Resumo

- **Total de testes:** X
- **Testes passaram:** X
- **Testes falharam:** 0
- **Cobertura:** XX%

---

## ✅ Testes Implementados

### Testes Existentes (Revisados)
1. ✅ Retorna string de resposta correta
2. ✅ Retorna versão padrão quando VERSAO_API não definida
3. ✅ Retorna versão customizada quando VERSAO_API definida

### Novos Testes
4. ✅ Verifica formato da resposta (regex)
5. ✅ Verifica que é função assíncrona
6. ✅ Usa versão padrão quando VERSAO_API é string vazia
7. ✅ Aceita valores inválidos em VERSAO_API
8. ✅ Mantém comportamento em múltiplas chamadas
9. ✅ Chama res.send exatamente uma vez

---

## 🖥️ Output da Execução

```bash
$ npm test tests/unit/controllers/versao.test.js

[COLAR OUTPUT AQUI]
```

---

## 🔍 Validação Prática

### Teste 1: Versão Padrão
```bash
$ npm start
$ curl http://localhost:8080/api/versao
Bia 4.2.0
```

### Teste 2: Versão Customizada
```bash
$ VERSAO_API=5.0.0 npm start
$ curl http://localhost:8080/api/versao
Bia 5.0.0
```

---

## 📈 Cobertura de Cenários

- [x] Versão padrão
- [x] Versão customizada
- [x] String vazia
- [x] Valor inválido
- [x] Múltiplas chamadas
- [x] Formato correto
- [x] Função assíncrona

---

## ✅ Conclusão

[ESCREVER CONCLUSÃO AQUI]
```

---

## 📚 Referências

### Arquivos do Projeto
- `tests/unit/controllers/versao.test.js` - Arquivo de teste
- `api/controllers/versao.js` - Controller testado
- `tests/unit/controllers/tarefas.test.js` - Exemplo de teste completo
- `package.json` - Configuração do Jest

### Comandos Úteis
```bash
# Executar todos os testes
npm test

# Executar apenas teste de versão
npm test tests/unit/controllers/versao.test.js

# Executar com watch mode
npm test -- --watch

# Executar com cobertura
npm test -- --coverage
```

### Documentação
- [Jest Documentation](https://jestjs.io/)
- [Jest Mocking](https://jestjs.io/docs/mock-functions)
- [Worktree Workflow](.kiro/docs/worktree-workflow.md)

---

## 🎯 Exemplo de Teste Completo

```javascript
const versaoController = require('../../../api/controllers/versao');

describe('Versao Controller', () => {
  let req, res;

  beforeEach(() => {
    req = {};
    res = {
      send: jest.fn(),
    };
    jest.clearAllMocks();
    delete process.env.VERSAO_API;
  });

  describe('get method', () => {
    test('deve retornar a string de resposta correta', async () => {
      const { get } = versaoController();
      await get(req, res);

      expect(res.send).toHaveBeenCalledWith('Bia 4.2.0');
    });

    test('deve retornar string no formato "Bia X.X.X"', async () => {
      const { get } = versaoController();
      await get(req, res);
      
      expect(res.send).toHaveBeenCalled();
      const response = res.send.mock.calls[0][0];
      expect(response).toMatch(/^Bia \d+\.\d+\.\d+$/);
    });

    test('deve ser uma função assíncrona', () => {
      const { get } = versaoController();
      const result = get(req, res);
      
      expect(result).toBeInstanceOf(Promise);
    });

    test('deve usar versão padrão quando VERSAO_API não está definido', async () => {
      delete process.env.VERSAO_API;

      const { get } = versaoController();
      await get(req, res);

      expect(res.send).toHaveBeenCalledWith('Bia 4.2.0');
    });

    test('deve retornar versão customizada quando VERSAO_API está definido', async () => {
      process.env.VERSAO_API = '1.0.0';

      const { get } = versaoController();
      await get(req, res);

      expect(res.send).toHaveBeenCalledWith('Bia 1.0.0');
    });

    test('deve usar versão padrão quando VERSAO_API é string vazia', async () => {
      process.env.VERSAO_API = '';
      
      const { get } = versaoController();
      await get(req, res);
      
      expect(res.send).toHaveBeenCalledWith('Bia 4.2.0');
    });

    test('deve usar valor de VERSAO_API mesmo que seja inválido', async () => {
      process.env.VERSAO_API = 'versao-invalida';
      
      const { get } = versaoController();
      await get(req, res);
      
      expect(res.send).toHaveBeenCalledWith('Bia versao-invalida');
    });

    test('deve manter comportamento consistente em múltiplas chamadas', async () => {
      process.env.VERSAO_API = '5.0.0';
      const { get } = versaoController();
      
      await get(req, res);
      expect(res.send).toHaveBeenCalledWith('Bia 5.0.0');
      
      res.send.mockClear();
      
      await get(req, res);
      expect(res.send).toHaveBeenCalledWith('Bia 5.0.0');
    });

    test('deve chamar res.send exatamente uma vez', async () => {
      const { get } = versaoController();
      await get(req, res);
      
      expect(res.send).toHaveBeenCalledTimes(1);
    });
  });
});
```

---

## ⚠️ FINALIZAÇÃO DA TASK (OBRIGATÓRIO)

Quando o agent concluir a implementação:

### 1. Verificação Final
```bash
# Garantir que está no worktree correto
pwd
# Deve estar em: /caminho/do/projeto/.kiro/worktrees/009-test-endpoint-versao

# Verificar branch
git branch --show-current
# Deve mostrar: test/009-test-endpoint-versao
```

### 2. Executar Testes uma Última Vez
```bash
# Executar os testes
npm test tests/unit/controllers/versao.test.js

# Verificar que todos passaram
# Copiar output para documentação
```

### 3. Commit e Push Final
```bash
git add .
git commit -m "test: expande cobertura de testes do endpoint /api/versao"
git push origin test/009-test-endpoint-versao
```

### 4. Voltar para Raiz e Notificar PO
```bash
cd ../../..  # Voltar para raiz do projeto
```

**NOTIFICAR O PO:**
> "Task 009 concluída. Todos os itens do checklist marcados. Branch `test/009-test-endpoint-versao` com push realizado. 
> 
> **Resultados:**
> - ✅ 9 testes implementados
> - ✅ Todos os testes passando
> - ✅ Cobertura expandida com 6 novos casos
> - ✅ Documentação criada em `versao.test.results.md`
> - ✅ Validação prática realizada
> 
> Aguardando revisão do PO para encerramento e abertura de PR."

**⚠️ NÃO REMOVER O WORKTREE. Apenas o PO faz isso após o PR ser mergeado.**

---

## 🎯 ENCERRAMENTO PELO PO (QUANDO NOTIFICADO)

### 1. Revisão
```bash
# Entrar no worktree para revisar
cd .kiro/worktrees/009-test-endpoint-versao

# Executar os testes
npm test tests/unit/controllers/versao.test.js

# Verificar arquivo de resultados
cat tests/unit/controllers/versao.test.results.md

# Revisar código dos testes
cat tests/unit/controllers/versao.test.js

# Testar endpoint manualmente
npm start &
sleep 3
curl http://localhost:8080/api/versao
pkill -f "node server"
```

### 2. Aprovar e Mover para Done
```bash
# Voltar para raiz
cd ../../..

# Mover task para done
mv .kiro/tasks/doing/009-test-endpoint-versao.md .kiro/tasks/done/

# Commit e push no ia-main
git checkout ia-main
git add .kiro/tasks/
git commit -m "move: task 009 para done"
git push origin ia-main
```

### 3. Abrir Pull Request
```bash
# ANTES de abrir PR: confirmar que está no branch de teste
cd .kiro/worktrees/009-test-endpoint-versao
git branch --show-current
# Deve mostrar: test/009-test-endpoint-versao

# Abrir PR contra ia-main
gh pr create --base ia-main --title "009: Expande testes do endpoint /api/versao" --body "Closes task 009

## Implementações
- ✅ Revisão dos testes existentes
- ✅ 6 novos casos de teste implementados
- ✅ Total de 9 testes cobrindo endpoint
- ✅ Documentação completa criada
- ✅ Todos os testes passando

## Novos Testes
1. ✅ Formato da resposta (regex)
2. ✅ Função assíncrona
3. ✅ VERSAO_API vazia
4. ✅ VERSAO_API inválida
5. ✅ Múltiplas chamadas
6. ✅ res.send chamado uma vez

## Validação
- ✅ Testes unitários: 9/9 passando
- ✅ Testes práticos realizados
- ✅ Documentação completa"
```

### 4. Após PR Mergeado
```bash
# Voltar para raiz
cd ../../..

# Remover worktree
git worktree remove .kiro/worktrees/009-test-endpoint-versao

# Ou com força se necessário:
# git worktree remove --force .kiro/worktrees/009-test-endpoint-versao

# Limpar registros
git worktree prune

# (Opcional) Deletar branch local
git branch -d test/009-test-endpoint-versao

# Notificar conclusão
```

**Notificar:** "Task 009 finalizada. Worktree removido. PR #<número> mergeado com sucesso. Testes do endpoint /api/versao expandidos e documentados." ✅
