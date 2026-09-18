# 📚 Documentação

## 🏗️ Arquitetura AWS
- [Diagrama ECS + EC2](./architecture/aws-ecs-diagram.html) - Visualização de uma das arquiteturas propostas para iniciar no treinamento e evoluir na Formação AWS
- [Análise de Arquitetura do Projeto](./analise-arquitetura-projeto.md) - Overview completo do projeto (frontend, backend, banco, Docker, deploy ECS) escrito como material de estudo
- [Dia 3: Integração Completa, explicada](./dia-3-integracao-completa-explicada.md) - Por que os 3 bugs da integração S3+EC2+Docker aconteceram, com analogias pra quem vem de Ciência de Dados
- [Desafio 4: Porteiro para o RDS, orientação](./desafio-4-porteiro-rds-orientacao.md) - Bastion host, túnel SSM e o gotcha de Security Group verificado antes de começar o desafio

## 🤖 Time de Agentes de IA
- [Panorama: Agentes e Worktrees](./panorama-agentes-e-worktrees.md) - Visão geral de como o time de agentes (po, dev, devops, qa) trabalha e como funciona o fluxo de tasks com worktrees isolados
- [Migrar Time de Agentes para Claude Code](./migrar-time-agentes-para-claude-code.md) - Como recriar os mesmos 4 agentes (po, dev, devops, qa) usando subagentes do Claude Code em vez do Kiro CLI
- [Roteiro Prático: Construindo o Time de Agentes com Claude Code](./roteiro-pratico-agentes-claude-code.md) - Tutorial passo a passo com conceitos, checkpoints e exercícios de fixação, para praticar hands-on o que foi visto nas aulas do módulo (com Kiro CLI) agora usando Claude Code
- [Mesmo Desafio, Dois Motores: Kiro CLI vs Claude Code](./paralelo-kiro-cli-vs-claude-code.md) - Paralelo real (não hipotético) entre o processo entregue com Kiro CLI e a réplica com Claude Code, com prós/contras tirados da prática, incluindo o bug de infra real encontrado pelo `qa` na task 001
- [Plugins e Automações do Claude Code](./plugins-e-automacoes-claude-code.md) - Plugins instalados (remember, cartographer, headroom, commit-commands), o mapa gerado do codebase, o novo subagente `security-reviewer` e a skill `worktree-task-cycle`, e a correção de um bug de Node/nvm que quebrava MCPs no WSL
