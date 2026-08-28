# 🚪 Desafio 4 — "Porteiro" para o RDS, explicado antes de começar

> **Sobre este documento:** orientação conceitual, escrita **antes** de resolver o desafio — não é a solução pronta, é o "porquê" de cada peça, pra você não ficar decorando comandos sem entender o que estão fazendo. Fundamentado em dados reais verificados na conta AWS do projeto (RDS, VPC, Security Groups), não em suposição genérica.
> Complementa [`analise-arquitetura-projeto.md`](./analise-arquitetura-projeto.md) e [`dia-3-integracao-completa-explicada.md`](./dia-3-integracao-completa-explicada.md).

---

## 1. O que o desafio pede, em português simples

| Etapa do desafio | O que é, na prática |
|---|---|
| 1. Script que lança uma EC2 "porteiro" na zona B | Uma máquina **descartável**, que só existe pra abrir uma porta de acesso temporária |
| 2. Script que inicia o porteiro com túnel pro RDS (porta local 5433) + insere 1 registro manual | Usar o porteiro como **ponte** até o banco de dados, que não é alcançável diretamente, e escrever um dado direto no banco (sem passar pela API) |
| 3. Túnel pra "bia" na porta 3002 pra ver o registro | Confirmar que o dado que você inseriu **na mão** aparece na aplicação de verdade — prova de que é o mesmo banco |
| 4. Script que para o porteiro | Desligar a máquina-ponte depois de usar — ela não deveria ficar ligada o tempo todo |

**Por que "porteiro" é um bom nome:** ele não faz nada com o dado, não roda a aplicação, não guarda nada — só **abre e fecha a porta** pra você chegar em algo que, de outro jeito, é inacessível. Em inglês esse padrão se chama **bastion host** (ou *jump box*): uma máquina cuja única função é ser intermediária de acesso.

---

## 2. Por que existe um "porteiro", pra começo de conversa

Fato verificado na conta AWS do projeto:

```
RDS "bia" (PostgreSQL)
  Endpoint: bia.csl22kw6cnmi.us-east-1.rds.amazonaws.com:5432
  PubliclyAccessible: false          ← sem IP público, não existe pra internet
  Security Group: bia-db
    Regra de entrada: só aceita porta 5432 vindo do Security Group "bia-web-sg"
```

Traduzindo: o banco **não tem endereço na internet**, e mesmo dentro da AWS, só aceita conexão de máquinas que estejam no grupo de segurança certo. É uma escolha de design deliberada — o mesmo motivo por trás de nunca deixar um banco de produção com IP público: só quem **precisa** conversar com ele, consegue.

Isso significa que rodar `psql -h bia.csl22kw6cnmi.us-east-1.rds.amazonaws.com ...` do seu notebook local **nunca vai funcionar**, não importa a senha — não é sobre credencial, é sobre **rota de rede**. O porteiro existe exatamente pra abrir essa rota, de forma temporária e controlada.

### Analogia com Ciência de Dados
Pensa num data warehouse corporativo que só aceita conexão vindo de dentro da rede da empresa (VPN), nunca direto da internet — mesmo que você tenha usuário e senha válidos. O bastion host é o equivalente a "logar na VPN": ele não é o destino, é o que te coloca **dentro da rede certa** pra então alcançar o destino.

---

## 3. O mecanismo: túnel via SSM (não é SSH, mas resolve o mesmo problema)

O desafio pede um "túnel", que aqui significa **SSM Port Forwarding** — uma funcionalidade do AWS Systems Manager que redireciona uma porta da sua máquina local para uma porta de dentro da rede privada da AWS, **sem abrir porta nenhuma pra internet** e **sem chave SSH**.

Existem dois tipos de sessão de encaminhamento de porta no SSM, e o desafio usa os dois, em papéis diferentes:

| Tipo de sessão SSM | Pra onde a porta aponta | Usado em qual etapa |
|---|---|---|
| `AWS-StartPortForwardingSession` | Pra dentro da **própria** instância alvo | Não é o caso aqui |
| `AWS-StartPortForwardingSessionToRemoteHost` | Pra **outra máquina**, alcançável a partir da instância alvo (o porteiro atua de ponte) | As duas etapas de túnel do desafio (RDS e "bia") |

```
Sua máquina (WSL)                    Porteiro (EC2, dentro da VPC)         RDS (privado)
─────────────────                    ────────────────────────────         ──────────────
localhost:5433  ───── SSM tunnel ─────▶  (só de passagem)  ─────────────▶  :5432
      │
      └── psql -h localhost -p 5433 ...   (você acha que está falando com "localhost",
                                            mas o tráfego atravessa o porteiro até o RDS)
```

O mesmo mecanismo se repete na etapa 3, só que o destino não é o RDS — é o host onde a aplicação "bia" está rodando, numa porta que você escolhe mapear localmente (3002 no enunciado). O **número da porta local** (3002, 5433) é só uma etiqueta pra você lembrar qual túnel é qual — não precisa ser igual à porta remota real.

**Por que isso substitui o SSH tradicional:** exatamente pela mesma razão do [Desafio 2](./dia-3-integracao-completa-explicada.md) — identidade gerenciada via IAM em vez de chave privada, sem precisar abrir porta de entrada nenhuma no Security Group.

---

## 4. ⚠️ O obstáculo que verifiquei e que provavelmente vai te pegar

Chequei os Security Groups de verdade da conta, e tem uma pegadinha real:

```
Instância        Security Group anexado     Consegue falar com o RDS?
──────────────────────────────────────────────────────────────────────
bia-dev           bia-dev                    ❌ NÃO (SG errado)
ECS (app em prod) bia-web-sg                  ✅ SIM
```

A regra de entrada do RDS só libera quem está no Security Group **`bia-web-sg`** — não o `bia-dev` (que é o SG usado no padrão de script já existente no projeto, `scripts/lancar_ec2_zona_a.sh`). Ou seja: **se você criar o porteiro copiando esse script existente sem ajustar o Security Group, o túnel pro RDS vai simplesmente travar/dar timeout**, sem nenhuma mensagem de erro clara — porque o problema não é o script, é rede/firewall.

Duas formas de resolver (escolha uma ao escrever seu script):
1. **Anexar `bia-web-sg` ao porteiro** (além de ou no lugar do SG `bia-dev`), na hora do `run-instances` (`--security-group-ids sg-xxxx sg-yyyy`, aceita mais de um).
2. **Adicionar uma regra nova** no Security Group `bia-db` liberando a porta 5432 pra partir do Security Group que o porteiro vai usar.

A opção 1 é mais simples e não mexe em nada que já está funcionando em produção.

---

## 5. O que cada um dos 4 scripts precisa fazer (roteiro, não solução)

### Script 1 — Lançar o porteiro
Mesma receita do `scripts/lancar_ec2_zona_a.sh` que já existe no projeto, com 2 ajustes:
- Zona/subnet: **`us-east-1b`** em vez de `us-east-1a` (é a "zona b, subnet default" do enunciado — subnet `subnet-08f39db837b9b79ec`, confirmada como default da AZ).
- Security Group: incluir **`bia-web-sg`** (ver seção 4), senão o túnel pro RDS não vai funcionar.
- Reaproveitar o instance profile **`role-acesso-ssm`** (mesmo usado pela `bia-dev`) — sem ele, a instância nunca aparece "Online" no SSM.

### Script 2 — Iniciar o túnel pro RDS + inserir 1 registro
Duas ações em sequência:
```bash
# 1) Abre o túnel: localhost:5433 -> RDS:5432, através do porteiro
aws ssm start-session \
  --target <ID-DO-PORTEIRO> \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters '{"host":["bia.csl22kw6cnmi.us-east-1.rds.amazonaws.com"],"portNumber":["5432"],"localPortNumber":["5433"]}'
```
Isso **bloqueia o terminal** enquanto o túnel estiver ativo (é uma sessão contínua) — então o `INSERT` precisa rodar **numa segunda janela de terminal**, apontando pro túnel:
```bash
psql -h localhost -p 5433 -U <usuário> -d bia -c "INSERT INTO tarefas (...) VALUES (...);"
```
> As credenciais (`<usuário>`, senha) não estão no Secrets Manager (verifiquei — está vazio); a aplicação usa variáveis de ambiente (`DB_USER`, `DB_PWD`) direto na *task definition* do ECS. Recupere com `aws ecs describe-task-definition --task-definition task-def-bia` e procure a seção `environment` — evite deixar a senha em texto puro em qualquer script que for commitado.

### Script 3 — Túnel pra "bia" na porta 3002
Mesmo padrão de comando do Script 2, mudando o alvo: em vez do endpoint do RDS, o **host onde a aplicação está rodando** (o IP privado da instância certa — hoje existem duas candidatas: a `bia-dev` e a instância por trás do ECS; qual delas serve a versão que reflete o banco de produção é algo pra você confirmar antes de montar o túnel) e a porta que ela expõe, mapeados para `localPortNumber: 3002`.

### Script 4 — Parar o porteiro
```bash
aws ec2 stop-instances --instance-ids <ID-DO-PORTEIRO>
```
"Parar" (`stop`) preserva a instância (você liga de novo depois, tipo o `connect_bia_dev.sh` já faz com a `bia-dev`); `terminate` apagaria de vez. Como o porteiro é descartável e não guarda estado nenhum, `terminate` também seria defensável — mas `stop` é mais barato de reativar se for usar de novo em breve.

---

## 6. Por que inserir na mão e depois checar na aplicação

Esse é o cerne pedagógico do desafio: provar, na prática, que **o banco é a fonte única de verdade**, e que "a aplicação" e "o banco" são coisas desacopladas.

```
INSERT manual via psql  ──┐
                          ├──▶  mesma tabela no RDS  ──▶  API lê essa tabela  ──▶  aparece na tela
Requisição via frontend ──┘
```

Não importa se o dado entrou pela API (fluxo normal) ou por um `INSERT` direto (fluxo de admin/emergência) — o resultado final na tela é indistinguível, porque os dois caminhos convergem pro mesmo Postgres. Isso é exatamente o motivo de existir a separação em camadas que já documentamos: a "camada de dados" não pertence à API, ela é compartilhada.

---

## 7. Checklist antes de começar

- [x] `session-manager-plugin` instalado localmente (verifiquei: já está em `/usr/local/bin/`)
- [x] RDS `bia` existe e está `available` (verificado)
- [ ] Confirmar/anexar `bia-web-sg` ao porteiro antes do primeiro teste de túnel (seção 4)
- [ ] Recuperar usuário/senha do Postgres via `aws ecs describe-task-definition` (não estão no Secrets Manager)
- [ ] Ter feito os Desafios 1–3 (SSM, IAM, EC2, Docker/ECR já deveriam estar familiares — é literalmente o aviso do próprio enunciado)
- [ ] Lembrar de rodar o Script 4 no final — o porteiro custando parado é desperdício

---

## 8. Glossário rápido

| Termo | O que é | Analogia de dados |
|---|---|---|
| **Bastion host / "porteiro"** | Instância intermediária cuja única função é dar acesso controlado a um recurso privado | Fazer login numa VPN antes de acessar um data warehouse interno |
| **SSM Port Forwarding** | Redireciona uma porta local pra dentro da rede privada da AWS, sem SSH nem porta pública aberta | Um túnel SSH, mas autenticado por IAM em vez de chave privada |
| **`...ToRemoteHost`** | Variante do port forwarding em que o alvo final é **outra** máquina, não a que você conectou | O porteiro não é o destino — é só quem te deixa passar |
| **RDS `PubliclyAccessible: false`** | O banco não tem rota de rede vinda da internet, só de dentro da VPC | Um banco que só aceita conexão vinda da rede corporativa |
| **Security Group como regra de origem** | Uma regra de entrada pode liberar por IP **ou** por "qualquer coisa que esteja nesse outro Security Group" | Uma lista de controle de acesso baseada em "papel/grupo", não em endereço fixo |

---

*Documento gerado em 27/08/2026, antes do início do Desafio 4, com base em consulta direta à conta AWS do projeto (RDS, VPC, Subnets, Security Groups, IAM instance profile e ECS task definition) — não é solução do desafio, é orientação conceitual pra evitar as pegadinhas já identificadas.*
