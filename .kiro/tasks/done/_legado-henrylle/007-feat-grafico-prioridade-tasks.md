# Task 007 - Criar Tela de Gráfico de Tasks por Prioridade

## 🔧 Configuração Inicial (LEIA ANTES DE INICIAR)

### Agent Responsável
**dev** - Este agent deve iniciar a implementação.

### Branch Base
**SEMPRE `ia-main`**

### Worktree
Esta task será implementada em worktree isolado em `.kiro/worktrees/007-feat-grafico-prioridade-tasks/`

---

## ⚠️ CHECKLIST DE INÍCIO (OBRIGATÓRIO)

Antes de começar a implementar, o agent deve:

- [ ] **Verificar branch atual:** `git branch --show-current`
  - Se não estiver em `ia-main`, **PERGUNTAR** ao usuário se pode trocar
  - Aguardar autorização
  - Após autorização: `git checkout ia-main && git pull origin ia-main`

- [ ] **Mover task para doing:**
  ```bash
  mv .kiro/tasks/007-feat-grafico-prioridade-tasks.md .kiro/tasks/doing/
  git add .kiro/tasks/
  git commit -m "move: task 007 para doing"
  git push origin ia-main
  ```

- [ ] **Criar worktree:**
  ```bash
  git worktree add .kiro/worktrees/007-feat-grafico-prioridade-tasks -b feature/007-feat-grafico-prioridade-tasks ia-main
  cd .kiro/worktrees/007-feat-grafico-prioridade-tasks
  git branch --show-current  # Confirmar branch correto
  ```

---

## 📋 Descrição

Criar uma nova tela que exiba um gráfico visual mostrando a quantidade de tasks agrupadas por prioridade (Importante vs Não Importante). Adicionar um link na Home que navegue para essa nova tela de analytics.

**Contexto Importante:** 
- Tasks possuem campo `importante` (boolean)
- Agrupamento: **Importantes** (importante = true) vs **Normais** (importante = false)
- Usar componentes shadcn/ui para gráficos
- Seguir o tema visual da aplicação (dark/light mode)

---

## 🎯 Objetivo

Proporcionar aos usuários uma visualização clara e intuitiva da distribuição das suas tarefas por prioridade, facilitando o entendimento do workload e organização das atividades.

---

## 📝 História de Usuário

**Como** usuário da BIA  
**Quero** visualizar um gráfico com a quantidade de tasks por prioridade  
**Para que** eu possa ter uma visão geral da distribuição das minhas tarefas e entender melhor meu workload

---

## ✅ Critérios de Aceitação

1. ✅ Nova rota `/analytics` ou `/graficos` criada
2. ✅ Link de navegação visível na Home levando para a tela de gráficos
3. ✅ Gráfico exibindo 2 categorias: "Importantes" e "Normais"
4. ✅ Contagem correta de tasks em cada categoria
5. ✅ Visual responsivo (mobile e desktop)
6. ✅ Integrado ao tema dark/light mode
7. ✅ Componentes shadcn/ui instalados e configurados
8. ✅ Botão de voltar para a Home
9. ✅ Mensagem amigável quando não houver tasks
10. ✅ Gráfico atualiza dinamicamente conforme tasks mudam

---

## 🛠️ Implementação

### 1. Setup do shadcn/ui

**IMPORTANTE:** shadcn/ui requer configuração inicial no projeto React + Vite

#### 1.1. Instalar dependências base

```bash
cd client

# Instalar Tailwind CSS (requerido pelo shadcn)
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p

# Instalar dependências do shadcn
npm install class-variance-authority clsx tailwind-merge
npm install lucide-react
```

#### 1.2. Configurar Tailwind CSS

**Arquivo:** `client/tailwind.config.js`

```javascript
/** @type {import('tailwindcss').Config} */
export default {
  darkMode: ["class"],
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
```

**Arquivo:** `client/src/index.css` (adicionar no início)

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

#### 1.3. Instalar componentes shadcn necessários

```bash
# Instalar CLI do shadcn (se necessário)
npx shadcn-ui@latest init

# Configurações recomendadas durante init:
# - Style: Default
# - Base color: Slate
# - CSS variables: Yes

# Instalar componente de gráfico
npx shadcn-ui@latest add chart
```

**Alternativa (sem CLI):** Copiar componentes manualmente do site shadcn.

### 2. Criar Componente de Gráfico

**Arquivo:** `client/src/components/Analytics.jsx`

- [ ] Criar novo componente funcional
- [ ] Receber `tasks` como prop
- [ ] Processar dados para agrupar por prioridade:
  ```javascript
  const importantesCount = tasks.filter(t => t.importante).length;
  const normaisCount = tasks.filter(t => !t.importante).length;
  ```
- [ ] Implementar gráfico de barras ou pizza usando shadcn Chart
- [ ] Adicionar título da página: "📊 Analytics - Tasks por Prioridade"
- [ ] Adicionar estatísticas complementares:
  - Total de tasks
  - Percentual de importantes
  - Percentual de normais
- [ ] Botão de voltar para Home
- [ ] Estado vazio (quando não há tasks)

**Exemplo de estrutura de dados:**

```javascript
const chartData = [
  {
    category: "Importantes",
    count: importantesCount,
    fill: "hsl(var(--chart-1))"
  },
  {
    category: "Normais", 
    count: normaisCount,
    fill: "hsl(var(--chart-2))"
  }
];
```

### 3. Adicionar Rota no App.jsx

**Arquivo:** `client/src/App.jsx`

- [ ] Importar componente Analytics
- [ ] Adicionar nova rota:
  ```jsx
  <Route path="/analytics" element={<Analytics tasks={tasks} />} />
  ```
- [ ] Passar `tasks` como prop para o componente

### 4. Adicionar Link na Home

**Opção 1: Botão no Header**
- Adicionar botão "📊 Analytics" no componente Header

**Opção 2: Card/Link na HomePage**
- Adicionar card chamativo após o AddTask ou antes do Footer

**Opção 3: Menu de Navegação**
- Criar menu de navegação com links para Home, Analytics, About

**Recomendação:** Opção 2 (card na HomePage) por ser mais visível e intuitivo.

**Implementação sugerida (HomePage):**

```jsx
<div className="analytics-link-card">
  <Link to="/analytics" className="analytics-link">
    <div className="analytics-link-content">
      <span className="analytics-icon">📊</span>
      <div>
        <h3>Ver Analytics</h3>
        <p>Visualize suas tarefas por prioridade</p>
      </div>
    </div>
  </Link>
</div>
```

### 5. Estilização

**Arquivo:** Adicionar ao CSS existente ou criar `client/src/styles/analytics.css`

- [ ] Estilizar página de analytics
- [ ] Garantir responsividade
- [ ] Integrar cores do tema (dark/light)
- [ ] Estilizar card de link na home
- [ ] Adicionar hover states
- [ ] Garantir acessibilidade (contraste, foco)

**Cores sugeridas para o gráfico:**
- Importantes: `#f59e0b` (amber/warning)
- Normais: `#10b981` (green/success)

### 6. Tipo de Gráfico

**Opções:**

1. **Gráfico de Barras** (Recomendado)
   - Mais fácil de comparar valores
   - Melhor para 2 categorias
   - Visualização clara em mobile

2. **Gráfico de Pizza/Donut**
   - Visual atraente
   - Bom para mostrar proporções
   - Pode ter legibilidade reduzida em mobile

3. **Gráfico de Barras Horizontais**
   - Excelente para mobile
   - Labels mais legíveis

**Decisão:** Deixar o agent dev escolher com base na UX, mas recomendar **Barras Verticais** ou **Donut Chart**.

---

## 🔍 Validações Técnicas

### Frontend
- ✅ Tailwind CSS configurado corretamente
- ✅ shadcn/ui componentes funcionando
- ✅ Rota `/analytics` acessível
- ✅ Link na home funcional
- ✅ Contagem de tasks correta
- ✅ Gráfico renderiza sem erros
- ✅ Responsividade em diferentes telas
- ✅ Tema dark/light aplicado

### Performance
- ✅ Renderização eficiente do gráfico
- ✅ Atualização dinâmica quando tasks mudam
- ✅ Sem memory leaks

---

## 📦 Dependências

### Novas dependências:
- `tailwindcss` ^3.x
- `postcss` ^8.x
- `autoprefixer` ^10.x
- `class-variance-authority`
- `clsx`
- `tailwind-merge`
- `lucide-react` (ícones)
- `recharts` (usado internamente pelo shadcn chart)

### Dependências existentes:
- `react-router-dom` (já instalado)

---

## 🎨 UX/UI

### Layout da Página Analytics

```
┌─────────────────────────────────────┐
│  ← Voltar                           │
│                                     │
│  📊 Analytics - Tasks por Prioridade│
│                                     │
│  ┌───────────────────────────────┐ │
│  │                               │ │
│  │     [Gráfico de Barras]       │ │
│  │                               │ │
│  │   Importantes │    Normais    │ │
│  │      ▇▇▇      │     ▇▇▇▇      │ │
│  │       5       │       8       │ │
│  │                               │ │
│  └───────────────────────────────┘ │
│                                     │
│  📈 Estatísticas                    │
│  ├─ Total: 13 tasks                │
│  ├─ Importantes: 5 (38%)           │
│  └─ Normais: 8 (62%)               │
│                                     │
└─────────────────────────────────────┘
```

### Estados da Interface

1. **Com dados:** Exibir gráfico + estatísticas
2. **Sem dados:** 
   ```
   📊 Nenhuma tarefa ainda
   
   Adicione tarefas para ver suas estatísticas aqui!
   [Voltar para Home]
   ```

### Link na Home

```
┌─────────────────────────────────────┐
│  [Formulário AddTask]               │
│                                     │
│  ┌───────────────────────────────┐ │
│  │  📊  Ver Analytics             │ │
│  │  Visualize suas tarefas por   │ │
│  │  prioridade                    │ │
│  └───────────────────────────────┘ │
│                                     │
│  [Lista de Tasks]                   │
└─────────────────────────────────────┘
```

---

## 📚 Referências

- [shadcn/ui Charts Documentation](https://ui.shadcn.com/docs/components/chart)
- [shadcn/ui Installation Guide](https://ui.shadcn.com/docs/installation/vite)
- [Recharts Documentation](https://recharts.org/)
- [Tailwind CSS Docs](https://tailwindcss.com/docs)
- [React Router v6](https://reactrouter.com/)
- [Worktree Workflow](.kiro/docs/worktree-workflow.md)
- [Worktree Steering](.kiro/docs/worktree-steering.md)

---

## 📊 Estimativa

**Complexidade:** Média  
**Tempo estimado:** 4-6 horas  
**Impacto:** Alto (nova funcionalidade, melhora visualização de dados)

---

## ⚠️ Observações Importantes

1. **Tailwind CSS:** Pode conflitar com CSS existente - testar cuidadosamente
2. **shadcn/ui:** Requer setup inicial - seguir documentação oficial
3. **Bundle size:** Recharts adiciona ~180KB - considerar lazy loading
4. **Acessibilidade:** Garantir que gráficos tenham alt text ou descrições
5. **Mobile:** Testar interatividade touch no gráfico
6. **Tema:** Usar CSS variables do shadcn para integrar com tema existente

---

## 🧪 Testes Manuais

### Cenários de Teste

- [ ] **Teste 1:** Acessar `/analytics` com tasks importantes e normais
  - Verificar contagem correta
  - Verificar renderização do gráfico

- [ ] **Teste 2:** Acessar `/analytics` sem nenhuma task
  - Verificar mensagem de estado vazio
  - Verificar botão voltar funciona

- [ ] **Teste 3:** Criar nova task e verificar atualização
  - Marcar como importante
  - Voltar para analytics
  - Verificar se gráfico atualizou

- [ ] **Teste 4:** Responsividade
  - Testar em mobile (< 768px)
  - Testar em tablet (768px - 1024px)
  - Testar em desktop (> 1024px)

- [ ] **Teste 5:** Tema dark/light
  - Alternar tema
  - Verificar cores do gráfico
  - Verificar contraste e legibilidade

- [ ] **Teste 6:** Navegação
  - Clicar no link da home
  - Ir para analytics
  - Voltar para home
  - Verificar estado preservado

---

## 🔄 Definition of Done (DoD)

- [ ] Tailwind CSS instalado e configurado
- [ ] shadcn/ui instalado e funcional
- [ ] Componente Analytics criado
- [ ] Gráfico renderizando corretamente
- [ ] Rota `/analytics` criada no App.jsx
- [ ] Link visível na Home
- [ ] Navegação entre Home ↔ Analytics funcional
- [ ] Contagem de tasks por prioridade correta
- [ ] Estado vazio tratado
- [ ] Responsividade testada (mobile, tablet, desktop)
- [ ] Tema dark/light integrado
- [ ] Código commitado com mensagens descritivas
- [ ] Push realizado para o branch feature/007-feat-grafico-prioridade-tasks
- [ ] Todos os testes manuais executados com sucesso

---

## ⚠️ FINALIZAÇÃO DA TASK (OBRIGATÓRIO)

Quando o agent concluir a implementação:

### 1. Verificação Final
```bash
# Garantir que está no worktree correto
pwd
# Deve estar em: /Users/henrylle/Projetos/formacaoaws/bia/.kiro/worktrees/007-feat-grafico-prioridade-tasks

# Verificar branch
git branch --show-current
# Deve mostrar: feature/007-feat-grafico-prioridade-tasks
```

### 2. Commit e Push Final
```bash
git add .
git commit -m "feat: implementa tela de analytics com gráfico de prioridade"
git push origin feature/007-feat-grafico-prioridade-tasks
```

### 3. Voltar para Raiz e Notificar PO
```bash
cd ../../..  # Voltar para raiz do projeto
```

**NOTIFICAR O PO:**
> "Task 007 concluída. Todos os itens do checklist marcados. Branch `feature/007-feat-grafico-prioridade-tasks` com push realizado. Tela de analytics implementada com gráfico shadcn/ui mostrando tasks por prioridade. Link adicionado na Home. Responsividade e tema dark/light testados. Aguardando revisão do PO para encerramento e abertura de PR."

**⚠️ NÃO REMOVER O WORKTREE. Apenas o PO faz isso após o PR ser mergeado.**

---

## 🎯 ENCERRAMENTO PELO PO (QUANDO NOTIFICADO)

### 1. Revisão
```bash
# Entrar no worktree para revisar
cd .kiro/worktrees/007-feat-grafico-prioridade-tasks

# Testar a funcionalidade:
# - Executar aplicação: npm run dev (no diretório client)
# - Verificar link na home
# - Acessar /analytics
# - Testar com diferentes quantidades de tasks
# - Testar estado vazio
# - Alternar tema dark/light
# - Testar em mobile e desktop

# Revisar código
# Verificar se todos os itens estão ✅
```

### 2. Aprovar e Mover para Done
```bash
# Voltar para raiz
cd ../../..

# Mover task para done
mv .kiro/tasks/doing/007-feat-grafico-prioridade-tasks.md .kiro/tasks/done/

# Commit e push no ia-main
git checkout ia-main
git add .kiro/tasks/
git commit -m "move: task 007 para done"
git push origin ia-main
```

### 3. Abrir Pull Request
```bash
# ANTES de abrir PR: confirmar que está no branch da feature
cd .kiro/worktrees/007-feat-grafico-prioridade-tasks
git branch --show-current
# Deve mostrar: feature/007-feat-grafico-prioridade-tasks

# Abrir PR contra ia-main
gh pr create --base ia-main --title "007: Criar tela de gráfico de tasks por prioridade" --body "Closes task 007

## Mudanças
- Instalado e configurado Tailwind CSS
- Instalado e configurado shadcn/ui
- Criado componente Analytics com gráfico de prioridades
- Adicionado rota /analytics
- Adicionado link de navegação na Home
- Implementado agrupamento de tasks: Importantes vs Normais
- Integrado tema dark/light mode
- Garantida responsividade mobile/desktop

## Testes realizados
- ✅ Gráfico renderiza corretamente com dados
- ✅ Estado vazio tratado adequadamente
- ✅ Navegação Home ↔ Analytics funcional
- ✅ Contagem de tasks por prioridade precisa
- ✅ Responsividade mobile/tablet/desktop
- ✅ Tema dark/light integrado
- ✅ Performance adequada

## Screenshots
[Adicionar screenshots se disponível]"
```

### 4. Após PR Mergeado
```bash
# Voltar para raiz
cd ../../..

# Remover worktree
git worktree remove .kiro/worktrees/007-feat-grafico-prioridade-tasks

# Ou com força se necessário:
# git worktree remove --force .kiro/worktrees/007-feat-grafico-prioridade-tasks

# Limpar registros
git worktree prune

# (Opcional) Deletar branch local
git branch -d feature/007-feat-grafico-prioridade-tasks

# Notificar conclusão
```

**Notificação:** "Task 007 finalizada. Worktree removido. PR #X mergeado com sucesso. Tela de Analytics implementada com gráfico shadcn/ui mostrando distribuição de tasks por prioridade."
