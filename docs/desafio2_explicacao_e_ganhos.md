# Desafio 2 — O que foi feito, por que, e quais os ganhos

> Este documento existe pra responder uma pergunta específica: "explica o que você fez e por quê". Detalhes técnicos de comando ficam em `aws_cli_conhecimento.md` — aqui o foco é justificativa e valor.

## O objetivo original

Conectar a instância `bia-dev` à conta AWS por dois métodos de acesso (SSH e SSM), fazer o build da aplicação **localmente**, e publicar a imagem resultante no Amazon ECR.

## O que foi feito, resumido

| Peça | O que foi feito |
|---|---|
| SSH + SSM | Instância que só tinha SSM ganhou também acesso SSH, sem ser recriada — chave injetada manualmente via sessão SSM |
| Build local | Imagem Docker (`bia:local`, 603MB) construída no WSL, não na EC2 |
| ECR | Repositório criado, imagem marcada (tag) e publicada — 15 camadas enviadas com sucesso |

## Por que cada peça, e o que ela resolve de verdade

### 1. SSH e SSM na mesma máquina

**Por que isso foi pedido:** não é sobre "qual é melhor" — é sobre entender dois **modelos de confiança** diferentes, na prática, na mesma instância.
- SSH prova que você sabe o modelo clássico: um segredo (chave privada) que autentica diretamente.
- SSM prova que você sabe o modelo moderno: uma identidade (IAM Role) que autoriza, sem segredo trafegando.

**O ganho real:** em qualquer entrevista técnica de Cloud/DevOps, "qual a diferença entre autenticação por segredo e por identidade gerenciada" é pergunta recorrente. Ter feito os dois, na mesma máquina, de propósito, é diferente de só ter lido a respeito — dá pra falar de trade-off com propriedade (superfície exposta, revogação, auditoria), porque você sentiu cada um na mão.

### 2. Build local, não na nuvem

**Por que isso foi pedido:** força a separação de dois papéis que, até aqui, estavam misturados na `bia-dev` — a mesma máquina que constrói também é a que roda.

**O ganho real:** essa separação é o alicerce de **qualquer pipeline de CI/CD** que existe no mercado. GitHub Actions, GitLab CI, Jenkins — todos seguem exatamente esse padrão: uma máquina (ou runner) builda, empurra pra um registro, e outra máquina (ou várias) puxa e roda. Ter feito isso manualmente uma vez é o que permite entender o que está acontecendo quando, no futuro, isso for automatizado.

### 3. Amazon ECR

**Por que isso foi pedido:** provar que a imagem construída localmente pode ser **compartilhada e versionada** de forma centralizada, sem depender de copiar arquivos manualmente entre máquinas.

**O ganho real:** qualquer outra instância, qualquer colega de time, qualquer pipeline automatizado, com a permissão certa, agora consegue rodar exatamente essa mesma versão da aplicação — sem precisar do código-fonte, sem precisar repetir o build. É o que torna possível escalar de "uma pessoa rodando na própria máquina" para "um time inteiro rodando a mesma coisa, de forma confiável".

## Se precisar explicar em poucas frases (ex: entrevista, post)

> "Peguei uma instância que já tinha acesso seguro via SSM (sem porta aberta, sem chave) e adicionei também acesso SSH, pra comparar os dois modelos na prática — um por segredo, outro por identidade gerenciada. Depois, separei onde a aplicação é construída de onde ela roda: fiz o build da imagem Docker localmente e publiquei no Amazon ECR, o registro privado da AWS. Isso é literalmente o primeiro elo de qualquer pipeline de CI/CD — build, registro, deploy."

## Onde estão os detalhes técnicos, se alguém pedir para ver

- `aws_cli_conhecimento.md`, seções 9, 10 e 11 — comandos exatos, erros encontrados, e como foram resolvidos.
- `verificar_desafio2.sh` — relatório reproduzível, prova em texto de que cada peça funciona.
