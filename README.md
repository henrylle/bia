# Projeto BIA - Formação AWS

![CI Pipeline](https://github.com/henrylle/bia/workflows/CI%20Pipeline/badge.svg)

## Projeto base para o módulo Agentes de IA e Multi-Agentes da Formação AWS.

### Curso: Formação AWS
### Módulo: Agentes de IA e Multi Agentic

Acompanhe o curso pela área de membros e app do aluno

---

## 🚀 CI/CD Pipeline

Este projeto utiliza GitHub Actions para Integração Contínua (CI). A cada Pull Request ou push na branch `ia-main`, o pipeline executa automaticamente:

### ✅ O que é validado no CI:

1. **Testes Unitários** - Executados em Node.js 18, 20 e 22 (matrix strategy)
2. **Cobertura de Código** - Relatório de coverage gerado pelo Jest
3. **Linting** - Validação de padrões de código (ESLint)
4. **Security Audit** - Verificação de vulnerabilidades nas dependências
5. **Build Validation** - Verifica se a aplicação consegue iniciar

### 📊 Cobertura de Código

Após cada execução do CI, um relatório de cobertura é gerado e disponibilizado como artifact na aba **Actions** do GitHub. O relatório inclui:
- Cobertura de linhas, branches, funções e statements
- Relatório HTML navegável
- Arquivo LCOV para integração com outras ferramentas

### 🔒 Security

O pipeline executa `npm audit` para detectar vulnerabilidades conhecidas nas dependências. Vulnerabilidades de nível moderado ou superior são reportadas, mas não bloqueiam o build (servem como aviso).

### ⚡ Performance

O workflow utiliza cache de dependências do npm, reduzindo o tempo de build de ~2 minutos para ~30 segundos nas execuções subsequentes.

