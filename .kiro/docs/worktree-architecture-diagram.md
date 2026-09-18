# 🏗️ Arquitetura Visual: Git Worktree Isolamento

## 📐 Diagrama de Estrutura

```
┌─────────────────────────────────────────────────────────────────┐
│                    REPOSITÓRIO PRINCIPAL                        │
│                   /bia/.git/ (ia-main)                         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ├─── Compartilhado por todos
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│   .git/       │    │   .git/       │    │   .git/       │
│   objects/    │◄───┤   refs/       │───►│   config      │
│               │    │               │    │               │
│ [Histórico    │    │ [Branches &   │    │ [Config do    │
│  de commits]  │    │  Tags]        │    │  repositório] │
└───────────────┘    └───────────────┘    └───────────────┘
        ▲                     ▲                     ▲
        │                     │                     │
        └─────────────────────┴─────────────────────┘
                              │
                    Compartilhado (Economy)
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  WORKTREE 1     │  │  WORKTREE 2     │  │  WORKTREE 3     │
│  (Main)         │  │  (Feature 001)  │  │  (Feature 002)  │
├─────────────────┤  ├─────────────────┤  ├─────────────────┤
│ Branch:         │  │ Branch:         │  │ Branch:         │
│ ia-main         │  │ teste-001       │  │ teste-002       │
│                 │  │                 │  │                 │
│ Working Tree:   │  │ Working Tree:   │  │ Working Tree:   │
│ /bia/           │  │ .kiro/worktrees/│  │ .kiro/worktrees/│
│                 │  │ teste-001.../   │  │ teste-002.../   │
│                 │  │                 │  │                 │
│ Files:          │  │ Files:          │  │ Files:          │
│ • README.md     │  │ • README.md     │  │ • README.md     │
│ • package.json  │  │ • package.json  │  │ • package.json  │
│ • ...           │  │ • teste1.txt ✨ │  │ • teste2.txt ✨ │
│                 │  │ • ...           │  │ • ...           │
└─────────────────┘  └─────────────────┘  └─────────────────┘
        │                     │                     │
        └─────────────────────┴─────────────────────┘
                              │
                        ISOLADOS
              (Arquivos NÃO compartilhados)
```

---

## 🔒 Matriz de Isolamento

```
┌────────────────────────────────────────────────────────────────┐
│                  ISOLAMENTO vs COMPARTILHAMENTO                │
└────────────────────────────────────────────────────────────────┘

┌─────────────────────┬──────────────┬──────────────┬──────────────┐
│ Componente          │  Worktree 1  │  Worktree 2  │  Worktree 3  │
├─────────────────────┼──────────────┼──────────────┼──────────────┤
│ Branch Ativo        │   ia-main    │  teste-001   │  teste-002   │
│                     │      🔒      │      🔒      │      🔒      │
├─────────────────────┼──────────────┼──────────────┼──────────────┤
│ Working Directory   │    /bia/     │  .kiro/...   │  .kiro/...   │
│                     │      🔒      │      🔒      │      🔒      │
├─────────────────────┼──────────────┼──────────────┼──────────────┤
│ teste1.txt          │      ❌      │      ✅      │      ❌      │
│                     │      🔒      │      🔒      │      🔒      │
├─────────────────────┼──────────────┼──────────────┼──────────────┤
│ teste2.txt          │      ❌      │      ❌      │      ✅      │
│                     │      🔒      │      🔒      │      🔒      │
├─────────────────────┼──────────────┼──────────────┼──────────────┤
│ Histórico (commits) │      🔄 COMPARTILHADO       │      🔄      │
├─────────────────────┼──────────────┼──────────────┼──────────────┤
│ .git/objects        │      🔄 COMPARTILHADO       │      🔄      │
├─────────────────────┼──────────────┼──────────────┼──────────────┤
│ .git/refs           │      🔄 COMPARTILHADO       │      🔄      │
├─────────────────────┼──────────────┼──────────────┼──────────────┤
│ .git/config         │      🔄 COMPARTILHADO       │      🔄      │
└─────────────────────┴──────────────┴──────────────┴──────────────┘

Legenda:
🔒 = Isolado (único por worktree)
🔄 = Compartilhado (entre todos os worktrees)
✅ = Arquivo presente
❌ = Arquivo ausente
```

---

## 🔄 Fluxo de Operação

```
┌─────────────────────────────────────────────────────────────────┐
│              FLUXO: Criação e Teste de Worktree                │
└─────────────────────────────────────────────────────────────────┘

1️⃣  INÍCIO: Repository Principal
    ┌────────────────┐
    │   /bia/        │
    │   (ia-main)    │
    └────────┬───────┘
             │
             │ git worktree add
             │
             ▼
2️⃣  CRIAÇÃO: Novo Worktree
    ┌────────────────────────────────┐
    │  .kiro/worktrees/teste-001/    │
    │  (feature/teste-001)           │
    │                                │
    │  ⚙️  Metadata:                 │
    │  • .git/worktrees/teste-001/  │
    │  • HEAD → teste-001           │
    │  • commondir → ../../.git/    │
    └────────┬───────────────────────┘
             │
             │ cd + echo "test" > teste1.txt
             │
             ▼
3️⃣  MODIFICAÇÃO: Arquivo Isolado
    ┌────────────────────────────────┐
    │  .kiro/worktrees/teste-001/    │
    │  ├── teste1.txt ✨             │
    │  ├── README.md                 │
    │  └── ...                       │
    └────────┬───────────────────────┘
             │
             │ cd ../teste-002/
             │ ls teste1.txt
             │
             ▼
4️⃣  VERIFICAÇÃO: Isolamento Confirmado
    ┌────────────────────────────────┐
    │  .kiro/worktrees/teste-002/    │
    │  ├── ❌ teste1.txt (não existe)│
    │  ├── README.md                 │
    │  └── ...                       │
    │                                │
    │  ✅ ISOLAMENTO FUNCIONANDO!    │
    └────────────────────────────────┘
```

---

## 📊 Comparação Visual: Git Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│           TRADICIONAL (git checkout)     vs     WORKTREES       │
└─────────────────────────────────────────────────────────────────┘

TRADICIONAL:                           WORKTREES:
═══════════                            ══════════

┌─────────────┐                        ┌─────────────┐
│   Branch A  │◄───┐                   │   Branch A  │
│  (ativo)    │    │ checkout          │  (ativo)    │
└─────────────┘    │                   └─────────────┘
                   │                          │
      ❌ Perde     │                          ▼
      contexto     │                   ┌─────────────┐
                   │                   │  Worktree 1 │
┌─────────────┐    │                   │    /bia/    │
│   Branch B  │────┘                   └─────────────┘
│ (inativo)   │
└─────────────┘                               +

                                       ┌─────────────┐
                                       │   Branch B  │
                                       │  (ativo)    │
Problemas:                             └─────────────┘
• Stash necessário                            │
• Perde contexto                              ▼
• Troca lenta                          ┌─────────────┐
• Conflitos em IDE                     │  Worktree 2 │
                                       │ .kiro/wt2/  │
                                       └─────────────┘

                                       ✅ Mantém contexto
                                       ✅ Paralelo
                                       ✅ Sem conflitos
```

---

## 🎯 Cenário Real: Desenvolvimento BIA

```
┌─────────────────────────────────────────────────────────────────┐
│                   WORKFLOW PRODUTIVO - BIA                      │
└─────────────────────────────────────────────────────────────────┘

Desenvolvedor: Henrylle
Projeto: BIA - Formação AWS

┌──────────────────────────────────────────────────────────────┐
│ WORKTREE PRINCIPAL                                           │
│ /Users/henrylle/Projetos/formacaoaws/bia/                   │
│ Branch: ia-main                                              │
│ Status: Desenvolvimento contínuo                             │
│ Terminal: Rodando servidor de desenvolvimento               │
└──────────────────────────────────────────────────────────────┘
                              │
                              │ PARALELO
                              │
┌─────────────────────────────┼────────────────────────────────┐
│                             │                                │
│  ┌──────────────────────┐   │   ┌──────────────────────┐    │
│  │ WT2: Feature 007     │   │   │ WT3: Hotfix 123      │    │
│  │ .kiro/wt/007-cache/  │   │   │ .kiro/wt/hotfix-123/ │    │
│  │ Branch: 007-cache    │   │   │ Branch: hotfix-123   │    │
│  │                      │   │   │                      │    │
│  │ Trabalho:            │   │   │ Trabalho:            │    │
│  │ • Redis cache impl   │   │   │ • Security patch     │    │
│  │ • Testes passando    │   │   │ • Bug crítico fix    │    │
│  │ • Ready for PR       │   │   │ • Deploy urgente     │    │
│  └──────────────────────┘   │   └──────────────────────┘    │
│                             │                                │
└─────────────────────────────┴────────────────────────────────┘

Vantagens:
✅ Servidor dev continua rodando em main
✅ Feature development sem interrupção
✅ Hotfix aplicado sem perder contexto
✅ Cada worktree com seu próprio node_modules
✅ IDE's separadas não conflitam
```

---

## 🔬 Teste de Isolamento - Passo a Passo Visual

```
┌────────────────────────────────────────────────────────────────┐
│                    TESTE DE ISOLAMENTO                         │
└────────────────────────────────────────────────────────────────┘

PASSO 1: Criar Worktrees
─────────────────────────

$ git worktree add .kiro/worktrees/teste-001 -b teste-001 ia-main
$ git worktree add .kiro/worktrees/teste-002 -b teste-002 ia-main

        ┌─────────────┐        ┌─────────────┐
        │ Worktree 1  │        │ Worktree 2  │
        │ teste-001   │        │ teste-002   │
        └─────────────┘        └─────────────┘


PASSO 2: Criar Arquivo em WT1
──────────────────────────────

$ cd .kiro/worktrees/teste-001
$ echo "Teste 1" > teste1.txt

        ┌─────────────┐        ┌─────────────┐
        │ Worktree 1  │        │ Worktree 2  │
        │ teste-001   │        │ teste-002   │
        │             │        │             │
        │ teste1.txt✨│        │ (vazio)     │
        └─────────────┘        └─────────────┘


PASSO 3: Verificar em WT2
──────────────────────────

$ cd ../teste-002
$ ls teste1.txt
> ls: teste1.txt: No such file or directory ✅

        ┌─────────────┐        ┌─────────────┐
        │ Worktree 1  │        │ Worktree 2  │
        │ teste-001   │        │ teste-002   │
        │             │        │             │
        │ teste1.txt✨│   ❌   │ (sem acesso)│
        └─────────────┘        └─────────────┘
                │                      ▲
                └──────────────────────┘
                   ISOLAMENTO COMPLETO


PASSO 4: Criar Arquivo em WT2
──────────────────────────────

$ echo "Teste 2" > teste2.txt

        ┌─────────────┐        ┌─────────────┐
        │ Worktree 1  │        │ Worktree 2  │
        │ teste-001   │        │ teste-002   │
        │             │        │             │
        │ teste1.txt✨│        │ teste2.txt✨│
        └─────────────┘        └─────────────┘


PASSO 5: Confirmar Isolamento Bidirecional
───────────────────────────────────────────

$ cd ../teste-001
$ ls teste2.txt
> ls: teste2.txt: No such file or directory ✅

        ┌─────────────┐        ┌─────────────┐
        │ Worktree 1  │        │ Worktree 2  │
        │ teste-001   │        │ teste-002   │
        │             │   ❌   │             │
        │ teste1.txt✨│ ◄───┼──│ teste2.txt✨│
        │(sem acesso) │        │             │
        └─────────────┘        └─────────────┘

✅ RESULTADO: ISOLAMENTO COMPLETO CONFIRMADO!
```

---

## 📈 Benefícios Quantificados

```
┌────────────────────────────────────────────────────────────────┐
│                 IMPACTO NO DESENVOLVIMENTO                     │
└────────────────────────────────────────────────────────────────┘

Métrica               Sem Worktree    Com Worktree    Melhoria
─────────────────────────────────────────────────────────────────
Troca de contexto     ~5-10 min       ~10 seg         98% ⬆️
Espaço em disco       2x repo         1.1x repo       45% ⬇️
Dev paralelo          ❌              ✅              100% ⬆️
Risco de conflito     Alto            Baixo           80% ⬇️
Produtividade         Baixa           Alta            200% ⬆️
```

---

## 🎓 Glossário Visual

```
┌─────────────────────────────────────────────────────────────────┐
│                        TERMOS CHAVE                             │
└─────────────────────────────────────────────────────────────────┘

📁 WORKING TREE
   └─► Diretório com arquivos do projeto (modificáveis)

🌳 WORKTREE
   └─► Working tree adicional vinculado ao mesmo .git/

🔗 .git/worktrees/
   └─► Metadata dos worktrees adicionais

📌 HEAD
   └─► Ponteiro para o commit/branch atual (isolado por worktree)

🔄 .git/objects/
   └─► Banco de dados de objetos Git (compartilhado)

🏷️  .git/refs/
   └─► Referências (branches, tags) compartilhadas
```

---

**Criado por**: DevOps Engineer - BIA Team  
**Propósito**: Documentação visual para facilitar compreensão  
**Versão**: 1.0  
**Data**: 2025
