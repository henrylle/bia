# AWS CLI — Caderno de conhecimento (Console → Terminal)

> Documento vivo. O instrutor da imersão mostra no Console web; aqui eu traduzo pro AWS CLI e registro o conceito por trás de cada peça. Vamos preenchendo à medida que a aula avança.

---

## 0. Console vs CLI — não existe "sincronizar"

Console, CLI, CloudShell e SDKs (Python, etc) são só **portas de entrada diferentes pra mesma API da AWS**. Não são cópias separadas do recurso — quando algo é criado no console, o CLI já enxerga exatamente a mesma coisa no instante seguinte, sem delay.

**Pegadinha real que aconteceu:** um recurso criado no console pode "sumir" pro CLI se você consultar na **região errada** — não porque não sincronizou, mas porque literalmente não existe naquela região. Sempre confira qual região está selecionada no canto superior direito do console antes de rodar o comando equivalente no CLI, com `--region` igual.

---

## 1. Rede: "minha rede" vs rede da AWS

| Na sua rede de casa | Na AWS |
|---|---|
| Modem/roteador da operadora | Internet Gateway |
| Wi-Fi de casa (ex: 192.168.0.0/24) | VPC (ex: 10.0.0.0/16) |
| Cômodos/setores com switch próprio | Subnets (uma por Availability Zone) |
| Firewall do roteador (bloqueia entrada por padrão, você libera exceções) | Security Group |
| Cada aparelho conectado (notebook, celular, smart TV) | Instância EC2 |
| Regra "só libero a porta X pra esse app" | Regra de inbound/outbound no Security Group |
| Fora do alcance do seu Wi-Fi = internet aberta | Fora da VPC = internet pública |

**A diferença que mais importa:** seu roteador de casa é *um* firewall pra rede inteira. Na AWS, você tem **duas camadas de firewall independentes**: o Security Group (por instância) e a Network ACL (por subnet inteira — ainda não usamos). É comum uma dessas duas bloquear silenciosamente algo que a outra libera.

---

## 2. Security Group

**O que é:** o firewall virtual de uma instância (ou de um grupo de instâncias). Decide o que pode entrar (`inbound`) e sair (`outbound`).

**Duas regras de comportamento que valem lembrar:**
- Só existe regra de **permitir**. Tudo que não está liberado já está bloqueado por padrão — não existe regra de "negar" explícita.
- É **stateful**: se uma conexão de entrada é permitida, a resposta de saída correspondente é liberada automaticamente, sem precisar de regra separada.

**Onde aparece no Console:** EC2 → Network & Security → Security Groups.

**Checar se já existe** (evita erro de duplicata — já aconteceu com key pair nessa imersão):
```bash
aws ec2 describe-security-groups \
  --region us-east-1 \
  --filters "Name=group-name,Values=bia-dev-sg" \
  --query 'SecurityGroups[0].[GroupId,VpcId]' \
  --output table
```

**Comando de criação (equivalente ao que o instrutor fez no console):**
```bash
aws ec2 create-security-group \
  --group-name bia-dev-sg \
  --description "Security group for BIA-DEV - acesso via SSM, sem SSH" \
  --vpc-id <VPC_ID> \
  --region us-east-1
```

**Por que esse aqui não abre porta 22:** o BIA-DEV usa SSM Session Manager pra acesso remoto, não SSH — então não existe regra de inbound necessária para administração. (Se depois for preciso acessar Frontend/API pelo navegador, aí sim entram regras específicas nas portas 3001/8080.)

---

## 3. Liberar porta da aplicação no Security Group (inbound rule)

**O que é:** uma regra dentro do Security Group que libera tráfego de entrada numa porta específica. Diferente da IAM Role (permissão de identidade), essa regra é puramente de rede: "que tráfego pode bater nessa porta".

**O que o instrutor configurou no console:**
- Porta: 3001 (onde o Frontend React do container escuta)
- Origem: Anywhere (0.0.0.0/0) — qualquer IP da internet
- Descrição: "acesso do bia-dev"

**Comando CLI equivalente** (usa `--ip-permissions` em vez de `--cidr` simples, porque só essa forma aceita anexar a descrição, igual o campo do console):
```bash
aws ec2 authorize-security-group-ingress \
  --group-id <SG_ID> \
  --ip-permissions '[{"IpProtocol":"tcp","FromPort":3001,"ToPort":3001,"IpRanges":[{"CidrIp":"0.0.0.0/0","Description":"acesso do bia-dev"}]}]' \
  --region us-east-1
```

**Trade-off:** abrir pra "Anywhere" numa porta de *aplicação* (frontend) é diferente de abrir a porta 22 (SSH) pra "Anywhere". Faz sentido aqui — o Frontend precisa ser alcançável por qualquer usuário, é o propósito da porta. Em produção, o padrão seria um Load Balancer na frente, sem expor a instância direto; em ambiente de estudo/demo, abrir direto é aceitável.

**Ponto de atenção pra próxima porta (5432, PostgreSQL):** banco de dados exposto direto pra "Anywhere" já é um padrão diferente e mais arriscado — vale reavaliar antes de repetir a mesma regra ali.

---

## 4. Session Manager Plugin — necessário localmente, não na EC2

**O que é:** um binário separado que o AWS CLI precisa pra conseguir de fato *estabelecer* uma sessão SSM. O CLI sozinho sabe pedir a sessão pra API, mas quem monta o túnel é esse plugin — instalado na sua máquina (WSL), não na instância remota.

**Erro que aparece sem ele:**
```
SessionManagerPlugin is not found
```

**Instalar no WSL (Ubuntu 64-bit):**
```bash
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb
session-manager-plugin --version
```

Depois disso, `aws ssm start-session --target <instance-id> --region <regiao>` funciona normalmente.

---

## 5. Nem toda EC2 é Ubuntu — confira antes de usar apt-get

**O que aconteceu:** a instância criada pelo script `lancar_ec2_zona_a.sh` da imersão não é Ubuntu (como a `training_aws` que criamos manualmente) — é **Amazon Linux**, reconhecível pelo prompt `sh-5.2$` numa sessão SSM. Amazon Linux usa `dnf` (AL2023) ou `yum` (AL2), não `apt-get`.

**Sempre que entrar numa instância nova e não tiver certeza da distro:**
```bash
cat /etc/os-release
```

**Equivalente Ubuntu → Amazon Linux 2023:**
| Ubuntu/Debian | Amazon Linux 2023 |
|---|---|
| `apt-get update && apt-get install -y pacote` | `dnf install -y pacote` |
| `apt-get remove pacote` | `dnf remove pacote` |

---

## 6. /tmp pode ser RAM, não disco — cuidado em instâncias pequenas

**O que aconteceu:** um `curl` de instalação falhou com `curl: (23) Failure writing output to destination`, mesmo com o disco raiz (`/`) tendo bastante espaço livre. Causa: no Amazon Linux 2023 (e outras distros systemd modernas), `/tmp` é montado como `tmpfs` — ou seja, é RAM, não disco. Numa instância pequena, esse `tmpfs` pode ser minúsculo (ex: 460M) e encher rápido, mesmo o disco de verdade tendo espaço de sobra.

**Diagnóstico:**
```bash
df -h
```
Se `/tmp` aparecer como `tmpfs` e `Use%` estiver em 100%, é isso.

**Correção — redirecionar downloads pra uma pasta no disco real:**
```bash
mkdir -p ~/tmp_install
export TMPDIR=~/tmp_install
```
A maioria dos instaladores (curl | bash) respeita `$TMPDIR` em vez de usar `/tmp` fixo.

---

## 7. localhost vs IP público — mesma app, dois lugares diferentes

**O que aconteceu:** o instrutor testou com `localhost:3001` no navegador dele e funcionou; a mesma URL no navegador do Fabio deu `ERR_CONNECTION_REFUSED`.

**Por quê:** `localhost` significa "essa mesma máquina, sem sair pra rede". O instrutor provavelmente estava rodando o Docker na própria máquina local naquele momento da demo. No nosso caso, o Docker roda dentro da EC2 — uma máquina diferente do notebook que abre o navegador. `localhost` no Windows nunca vai enxergar o que está rodando dentro da AWS.

| | `localhost:3001` | IP público `:3001` |
|---|---|---|
| De onde parte o pedido | Da própria máquina | De fora, pela internet |
| Passa pelo Security Group? | Não — loopback ignora regras de rede | Sim |
| Serve pra | Testar se o container está saudável, rodando de dentro da EC2 | Acesso real, de qualquer lugar |

**Diagnóstico útil:** dentro da sessão SSM da EC2, `curl localhost:3001` — se responder, o container está bem e qualquer problema de acesso é de rede (Security Group, IP, instância desligada). Se não responder, o problema é no próprio container.

**Se quiser usar `localhost:3001` no navegador do Windows mesmo assim** (sem depender do Security Group público), dá pra abrir um túnel via SSM port forwarding:
```bash
aws ssm start-session \
  --target i-074bcbdb1642ec026 \
  --region us-east-1 \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["3001"],"localPortNumber":["3001"]}'
```
Com essa sessão aberta, `localhost:3001` no navegador local passa a funcionar, redirecionado até a EC2.

---

## 8. Túnel SSM na prática — conectando ferramentas gráficas (DBeaver e além)

**O padrão, generalizado:** qualquer serviço rodando dentro da EC2 (Postgres, Redis, um segundo app) pode ser acessado por uma ferramenta local — DBeaver, RedisInsight, navegador — sem nunca abrir a porta no Security Group. Basta abrir um túnel SSM apontando pra porta certa:
```bash
aws ssm start-session \
  --target <instance-id> \
  --region us-east-1 \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["PORTA_REMOTA"],"localPortNumber":["PORTA_LOCAL"]}'
```
Depois, a ferramenta local conecta em `localhost:PORTA_LOCAL` normalmente, como se o serviço estivesse na própria máquina.

**Implicações pro fluxo de trabalho:**
- O túnel é um processo que fica rodando em primeiro plano — a janela do terminal precisa continuar aberta enquanto a ferramenta gráfica estiver em uso. Fechar a janela derruba a conexão.
- Na prática, mexer no banco via DBeaver significa manter 2-3 janelas abertas ao mesmo tempo: a sessão SSM normal, o túnel, e a ferramenta gráfica em si.
- Os dados vistos são os dados reais e ao vivo do ambiente — não uma cópia. Alterações feitas pela aplicação e pelo DBeaver se refletem uma na outra.

---

## 9. Adicionando SSH numa instância já existente (sem recriar)

**Por quê:** um par de chaves EC2 (`--key-name`) só pode ser associado no momento do `run-instances`. Pra dar acesso SSH a uma instância que já está rodando (como a `bia-dev`, criada só com SSM), o caminho é injetar a chave pública manualmente, usando o próprio acesso SSM que já se tem.

**Passo a passo:**

1. Gerar um par de chaves local, específico pra esse acesso:
```bash
ssh-keygen -t ed25519 -f ~/.ssh/bia-dev-key -C "acesso-bia-dev"
```
2. Copiar a chave pública: `cat ~/.ssh/bia-dev-key.pub`
3. Conectar na instância via SSM (como sempre): `aws ssm start-session --target <instance-id> --region us-east-1`
4. Confirmar qual usuário existe na instância — `ls /home` (Amazon Linux: `ec2-user`; Ubuntu: `ubuntu`).
5. Colar a chave pública na pasta do usuário certo, usando `sudo` (o `ssm-user` da sessão não é dono dessa pasta):
```bash
sudo mkdir -p /home/ec2-user/.ssh
echo "CHAVE_PUBLICA_AQUI" | sudo tee -a /home/ec2-user/.ssh/authorized_keys
sudo chown -R ec2-user:ec2-user /home/ec2-user/.ssh
sudo chmod 700 /home/ec2-user/.ssh
sudo chmod 600 /home/ec2-user/.ssh/authorized_keys
```
*(o `tee` ecoa de volta a linha que acabou de escrever — parece duplicata na tela, mas não é; só aparece uma vez no arquivo.)*
6. Sair da sessão (`exit`) e, **no terminal local**, liberar a porta 22 no Security Group, restrita ao próprio IP:
```bash
MY_IP=$(curl -s https://checkip.amazonaws.com)
aws ec2 authorize-security-group-ingress --group-id <sg-id> --protocol tcp --port 22 --cidr "${MY_IP}/32" --region us-east-1
```
7. Testar: `ssh -i ~/.ssh/bia-dev-key ec2-user@<ip-público>`

**Erros comuns nesse processo:**

- **`sh: sg-xxxx: No such file or directory`** — o valor foi colado com `< >` incluídos. Esses símbolos são operadores de redirecionamento do bash (`<` lê de arquivo, `>` escreve em arquivo), não sintaxe de placeholder — nunca copiar os símbolos junto, só o valor real.
- **Rodar comandos de Security Group/EC2 de dentro da sessão SSM** — a IAM Role da instância só tem permissão pra SSM, não pra gerenciar outros recursos da conta. Esses comandos (`authorize-security-group-ingress`, `describe-instances`, etc quando o objetivo é administrar a conta) precisam rodar no terminal **local**, com as credenciais completas configuradas via `aws configure` — não dentro da sessão remota.
- **`Permission denied` ao criar/editar `authorized_keys`** — o usuário da sessão SSM não é dono da pasta de outro usuário do sistema; sempre usar `sudo` para criar/editar, e depois corrigir o dono com `chown`.

---

## 10. Docker no WSL — o daemon não liga sozinho

**O que aconteceu:** `docker --version` respondia normalmente, mas `docker ps` falhava com `Cannot connect to the Docker daemon` / socket inexistente. O CLI estar instalado não significa que o serviço (daemon) está rodando — são coisas separadas.

**Causa:** esse WSL não roda `systemd` de verdade como PID 1 (confirmado com `cat /proc/1/comm`, que retornou `init`, não `systemd`). Isso significa que serviços como o Docker não sobem automaticamente ao abrir o WSL.

**Correção, mesmo sem systemd completo:**
```bash
sudo systemctl enable --now docker
```
Mesmo aparecendo um erro de D-Bus (`Failed to connect to bus: Host is down`) — esse erro é só da parte "enable pra sempre"; o "start agora" cai num mecanismo de compatibilidade (SysV) e funciona mesmo assim. `docker ps` passa a responder depois disso.

**Implicação prática:** como não é systemd de verdade, o Docker **não volta a ligar sozinho** depois de fechar e reabrir o WSL (ou reiniciar o Windows). Esse comando provavelmente precisa ser rodado de novo no início de cada sessão de trabalho.

**Como confirmar se é o Docker nativo do WSL ou o Docker Desktop do Windows:**
```bash
docker info | grep -i "Operating System"
```
Se aparecer o nome da própria distro (ex: `Ubuntu 24.04.4 LTS`), é o daemon nativo desse WSL. Se aparecer algo referenciando "Docker Desktop", é o daemon do Windows via integração WSL.

**Resolvido:** os containers eram de projetos anteriores e não relacionados (EcoHome, PgAdmin), com reinício automático — sobem sozinhos quando o daemon liga, mas não interferem no trabalho da BIA.

**Atualização (28/08/2026) — isso é específico do WSL, não do Linux em geral:** ao configurar o agendamento automático do porteiro (ver [`dia-4-porteiro-tunel-ssm-tutorial.md`](./dia-4-porteiro-tunel-ssm-tutorial.md)), `cat /proc/1/comm` voltou `systemd` (não `init`) e o `cron.service` já apareceu `enabled` + `active` sozinho. Não é contradição com a nota acima — é porque nessa sessão o trabalho estava rodando na **partição Linux nativa**, não no WSL. A distinção importa na prática: **na partição nativa, systemd é de verdade e serviços habilitados sobem sozinhos no boot** (Docker incluído); **no WSL, não** — o `systemctl enable --now docker` continua precisando ser repetido a cada sessão só quando o ambiente for o WSL. Vale sempre conferir `cat /proc/1/comm` antes de assumir qual dos dois comportamentos vale, se não tiver certeza de qual ambiente está ativo no terminal.

---

## 11. Build da imagem localmente + push para o ECR

**Build local, a partir do clone no WSL:**
```bash
cd ~/Workdir/AWS/bia
docker build -t bia:local .
```
Resultado: imagem `bia:local`, 603MB, 16/16 passos concluídos sem erro. Usa a base `node:24.18.0-slim` (do ECR Public), instala dependências do backend e do client em passos separados (aproveitando cache de camadas — por isso builds seguintes tendem a ser bem mais rápidos), e roda o build do React antes de finalizar.

**Checar e criar o repositório no ECR** (sempre checar primeiro, mesmo hábito de evitar duplicata):
```bash
aws ecr describe-repositories --repository-names bia --region us-east-1
# Retornou RepositoryNotFoundException → não existia, então:
aws ecr create-repository --repository-name bia --region us-east-1
```
Resultado real:
```json
{
    "repositoryArn": "arn:aws:ecr:us-east-1:878919573366:repository/bia",
    "registryId": "878919573366",
    "repositoryName": "bia",
    "repositoryUri": "878919573366.dkr.ecr.us-east-1.amazonaws.com/bia",
    "imageTagMutability": "MUTABLE",
    "encryptionConfiguration": {"encryptionType": "AES256"}
}
```
O `repositoryUri` é o endereço que a imagem vai usar: `<account-id>.dkr.ecr.<região>.amazonaws.com/<nome-do-repositório>`.

**Restante do fluxo (autenticar, marcar a tag, enviar) — executado com sucesso:**
```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com
# → Login Succeeded

docker tag bia:local ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/bia:latest

docker push ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/bia:latest
# → 15 camadas enviadas (Pushed)
# → latest: digest: sha256:2fdea49baadad963b2259b417d497673f5174c2b240626b4758110a61c425dc1 size: 3471
```
**Status: concluído.** Imagem publicada no repositório privado `878919573366.dkr.ecr.us-east-1.amazonaws.com/bia:latest`.

---

## 12. `aws login` — o navegador não abre sozinho no WSL

**O que acontece:** ao rodar `aws login --profile <nome>`, o comando tenta abrir o navegador automaticamente via `xdg-open`, mas o WSL não tem um "abridor de navegador" configurado por padrão — aparece uma lista de tentativas falhas (`firefox: not found`, `google-chrome: not found`, etc) terminando em `xdg-open: no method available for opening`.

**Não é erro fatal.** O comando imprime a URL de autorização completa mesmo assim. Basta copiar essa URL manualmente e colar no navegador do Windows — o processo no terminal continua esperando em segundo plano (um servidor local de callback), e completa sozinho assim que o login no navegador é concluído.

**Cuidado na tela de login:** se aparecer a opção de continuar com uma sessão já ativa marcada como **root**, não escolha essa — clique em "Sign into new session" e entre com o usuário IAM correto (`fabio-admin`), nunca root, mesmo pra credenciais temporárias.

**Confirmar que funcionou:**
```bash
aws sts get-caller-identity --profile formacaoaws
```

**Atenção a uma expectativa errada comum:** o `Arn` retornado aqui continua aparecendo como `user/fabio-admin`, igual ao profile antigo — isso **não** significa que o login falhou ou que voltou a usar a Access Key fixa. O formato `assumed-role/...` só aparece em login via federação/role (ex: IAM Identity Center); logando como usuário IAM direto, a identidade continua sendo `user/...` mesmo com credenciais temporárias — só o mecanismo por trás muda.

**A prova real de que é temporário está no arquivo de config, não no `Arn`:**
```bash
grep -A 2 "profile formacaoaws" ~/.aws/config
```
Resultado esperado:
```
[profile formacaoaws]
login_session = arn:aws:iam::878919573366:user/fabio-admin
region = us-east-1
```
A presença de `login_session` (em vez de `aws_access_key_id` / `aws_secret_access_key`) é o que confirma que esse profile busca credenciais renováveis via login, não uma chave estática salva em disco.

**Resultado final:** as duas formas de autenticação convivem na mesma conta — a Access Key antiga (`aws configure`, sem `--profile`) continua ativa, e o novo fluxo (`aws login --profile formacaoaws`) funciona em paralelo. Basta escolher qual usar em cada comando via `--profile`.

**Confirmação com um comando real, não só `get-caller-identity`:**
```bash
aws s3 ls --profile formacaoaws
```
Funcionou normalmente, listando os buckets da conta — prova que o profile serve pra qualquer operação, não só pra checar identidade.

**Como usar no dia a dia — recomendações:**

| | Profile padrão (Access Key) | `--profile formacaoaws` (login) |
|---|---|---|
| O que fazer antes de usar | Nada — já configurado | Rodar `aws login --profile formacaoaws` |
| Frequência de repetir | Nunca (chave é permanente) | A cada ~12h de sessão, ou quando expirar |
| Como usar nos comandos | Sem flag nenhuma | Adicionar `--profile formacaoaws` |

**Atalho pra não repetir `--profile` em todo comando**, dentro de uma sessão de terminal:
```bash
export AWS_PROFILE=formacaoaws
```
Vale só pra aquela janela aberta — fechando e reabrindo o WSL, volta ao padrão.

**Recomendação prática:** não é preciso escolher um só pra sempre. Uso do dia a dia (scripts, comandos rotineiros) continua com o profile padrão, já configurado em tudo que foi construído até aqui. O `aws login` fica como opção extra, pra praticar o modelo de credenciais temporárias quando fizer sentido — não uma troca obrigatória.

**Confirmação visual — profile vs usuário IAM não são a mesma coisa:**
```bash
cat ~/.aws/config
```
Mostrou 5 profiles configurados (`default`, `FabioLima`, `fcl`, `learning-aws`, `formacaoaws`) — só o `formacaoaws` tem a linha `login_session`; os outros 4 usam o modelo de Access Key fixa (guardada separadamente em `~/.aws/credentials`, por isso não aparece nesse arquivo). O nome do profile é só um rótulo escolhido por quem configurou — não precisa ter relação com o nome do usuário IAM por trás dele.

**Nota de higiene, resolvida:** `aws iam list-access-keys --user-name fabio-admin` confirmou apenas **1 Access Key ativa** (criada há 6 dias, batendo com o painel do IAM). Os 4 profiles locais com "chave fixa" provavelmente reutilizam essa mesma chave única, sob nomes diferentes — não é exposição de múltiplas credenciais, só nomenclatura duplicada localmente. Sem ação de segurança necessária.

---

## 13. Exercício prático: persistência de dados + MCP Server de banco

**Propósito:** sair da teoria (o infográfico sobre volumes Docker) e **provar na prática, com as próprias mãos**, dois conceitos: (1) que um volume Docker sobrevive independente do container, e (2) como um agente de IA (Kiro CLI) consulta um banco de dados via MCP, em linguagem natural, sem escrever SQL. Feito num ambiente isolado (`~/Workdir/AWS/pratica-persistencia`), sem tocar no projeto BIA-DEV real.

### Parte A — Persistência, provada na prática

**`docker-compose.yml`** (banco de teste isolado, porta `5544` pra não colidir com o `5433` do BIA-DEV):
```yaml
services:
  postgres:
    image: postgres:17.1
    container_name: pratica-persistencia-db
    environment:
      POSTGRES_USER: pratica
      POSTGRES_PASSWORD: pratica123
      POSTGRES_DB: testedb
    ports:
      - "5544:5432"
    volumes:
      - dados_persistentes:/var/lib/postgresql/data

volumes:
  dados_persistentes:
```

**Sequência do teste:**
```bash
docker compose up -d
docker exec -it pratica-persistencia-db psql -U pratica -d testedb
# dentro do psql:
CREATE TABLE teste_persistencia (id SERIAL PRIMARY KEY, mensagem TEXT);
INSERT INTO teste_persistencia (mensagem) VALUES ('Esse dado precisa sobreviver ao docker compose down');
\q

docker compose down          # remove container E rede por completo
docker ps -a | grep pratica  # confirma: vazio, nada sobrou

docker compose up -d         # recria do zero
sleep 5                      # dá tempo do Postgres iniciar de verdade (ver nota abaixo)
docker exec -it pratica-persistencia-db psql -U pratica -d testedb -c "SELECT * FROM teste_persistencia;"
# → id 1 | Esse dado precisa sobreviver ao docker compose down  (SOBREVIVEU)
```

**Erro comum encontrado:** rodar o `docker exec` logo em seguida do `up -d`, sem pausa, resulta em `FATAL: the database system is starting up`. O container inicia rápido, mas o Postgres dentro dele leva alguns segundos a mais pra aceitar conexões — `sleep 5` (ou checar `docker logs`) resolve.

**Faxina ao final:** `docker compose down -v` (o `-v` remove também o volume, apagando os dados de teste de vez — diferente do `down` sem `-v`, que preserva).

### Parte B — Kiro CLI local + MCP Server de banco

**Instalar o Kiro CLI no WSL** (mesmo instalador usado na EC2, agora local):
```bash
curl -fsSL https://cli.kiro.dev/install | bash
export PATH="$HOME/.local/bin:$PATH"
```

**Configuração MCP** (`~/.kiro/settings/mcp.json`):
```json
{
  "mcpServers": {
    "postgres-pratica": {
      "command": "npx",
      "args": ["mcp-postgres@latest"],
      "env": {
        "DATABASE_URL": "postgresql://pratica:pratica123@localhost:5544/testedb"
      },
      "disabled": false,
      "autoApprove": ["list_tables", "get_schema"]
    }
  }
}
```

**Teste real:** abrindo `kiro-cli` e perguntando em linguagem natural — *"Quais tabelas existem nesse banco, e o que tem dentro da tabela teste_persistencia?"* — o agente encadeou sozinho `list_tables` → `get_table_sample` → `describe_table`, pediu aprovação pra `describe_table` (não estava na lista `autoApprove`), e devolveu a estrutura da tabela + o conteúdo, **interpretando** o propósito da tabela pelo nome e conteúdo (não só executando a query).

### Aprendizagens

- **Container é descartável, volume é o que persiste** — não é mais teoria depois desse teste; foi visto acontecer.
- **`docker compose down` ≠ `docker compose down -v`** — o primeiro preserva volumes, só o segundo apaga de vez.
- **"Container iniciado" ≠ "serviço pronto"** — vale sempre um `sleep` ou checagem de log antes de assumir que algo já está disponível, logo depois de um `up`.
- **Kiro CLI configura MCP via arquivo JSON** (`~/.kiro/settings/mcp.json`), diferente do Claude Code (`claude mcp add` via linha de comando) — mesma ideia, sintaxe diferente por ferramenta.
- **Ferramentas MCP com poder de escrita pedem aprovação individual por padrão** — mesmo princípio de least privilege já visto com IAM: o agente só age livremente no que foi explicitamente pré-aprovado (`autoApprove`); o resto pede confirmação a cada uso.
- **Um agente com MCP não só executa — ele raciocina sobre o resultado**, associando o nome da tabela ao propósito do teste sem ser instruído a fazer isso.
- **Uso do Kiro CLI consome créditos por sessão** (visível no rodapé: `Credits: 0.15 · Time: 1m 7s`) — vale monitorar em uso mais intenso.

---

## 14. Day 3 — Integração completa: Frontend (S3) ↔ Backend (EC2) ↔ Database (PostgreSQL)

**O que é:** o passo decisivo onde as três camadas da arquitetura se falam de verdade — não em diagrama, mas funcionando. Frontend enviando requisições HTTP pro backend, backend consultando o banco, respostas voltando pra UI.

**Tecnologias envolvidas:**
- Frontend: React 18 + Vite 7 (compilado pra S3)
- Backend: Node.js + Express (rodando em EC2, dockerizado)
- Database: PostgreSQL 17.1 (em container Docker)
- Comunicação: HTTP (frontend → backend), SQL (backend → database)

### O cenário

**Aplicação BIA:** gerenciador de tarefas com tres camadas separadas:

```
Navegador (máquina local, S3 estático) 
    ↓ POST /api/tarefas (HTTP)
EC2 (54.83.241.43:3001, Node.js/Express em Docker)
    ↓ INSERT INTO tarefas (SQL)
PostgreSQL (porta 5433, dados persistem em volume)
```

**O que cada camada faz:**
1. **Frontend (S3):** formulário React que envia `POST` com `{titulo, dia_atividade, importante}`
2. **Backend (EC2):** recebe, valida, insere no banco, retorna `{uuid, titulo, ...}` com HTTP 200
3. **Database:** armazena, retorna linhas quando solicitado por `SELECT`

### Problema 1: Variáveis de ambiente Vite não funcionam em runtime

**Sintoma:** depois de criar `.env.local` com `VITE_API_URL=http://54.83.241.43:3001`, o frontend ainda mostra "conectando em `localhost:8080`" após rebuild e upload.

**Causa:** Vite compila variáveis ambientais **durante o build**, não em runtime. Diferente de Create React App (`REACT_APP_*`) que também compila, Vite usa prefixo `VITE_*` (não `REACT_APP_*`). E — parte crítica — **sem rebuild e re-upload, o navegador está vendo a versão anterior compilada**, com `localhost` hardcoded.

**Solução — sequência completa:**
```bash
# 1. Verificar/criar .env.local com VITE_* (não REACT_APP_*)
cat client/.env.local
# esperado: VITE_API_URL=http://54.83.241.43:3001

# 2. Rebuild — isso compila as variáveis DENTRO do JavaScript
cd client
npm run build
# resultado: pasta build/ com index.html + assets/ com variável compilada

# 3. Upload pra S3 (substitui versão antiga)
aws s3 sync build/ s3://bia-frontend-XXXXXXX/ --delete

# 4. Forçar refresh no navegador (Ctrl+Shift+R no Chrome = bypass cache)
```

**Verificação prática no navegador:** DevTools Console mostra:
```
[API] Aplicação iniciada API URL configurada: http://54.83.241.43:3001
```
Se aparecer `localhost`, o build não foi feito com a variável correta.

### Problema 2: IP privado vs IP público — mesma aplicação, dois resultados diferentes

**Sintoma:** tentativa inicial de conectar o frontend ao backend usando IP privado `172.31.0.186:3001` → `ERR_CONNECTION_TIMEOUT`. Mudando pra `54.83.241.43:3001` (IP público) → funciona.

**Causa:** IPs privados (range 172.31.x.x dentro da VPC) só funcionam de máquinas **dentro** da mesma VPC. S3 está na internet pública — fora da VPC. Logo, "entrego dados pro S3 estático" nunca vai poder usar um IP privado pra chamar o backend.

| Origem da requisição | IP privado 172.31.0.186 | IP público 54.83.241.43 |
|---|---|---|
| De outra instância EC2 na mesma VPC | ✅ Funciona | ✅ Funciona (mais lento) |
| De S3 (internet pública) | ❌ Não alcança | ✅ Funciona |
| Do navegador local (sua máquina) | ❌ Não alcança | ✅ Funciona (com Security Group aberto) |

**Aprendizado importante:** "a aplicação está em EC2" não significa que sempre vai funcionar de fora. Sempre testar com IP público quando o cliente está fora da VPC.

### Problema 3: Bug frontend "e is not iterable" ao criar tarefa

**Sintoma:** tarefa criada com HTTP 200 (UUID retornado), mas UI não atualiza + console mostra erro `e is not iterable`, depois `Falha ao criar tarefa`.

**Causa (análise):** backend funciona perfeitamente — o POST retorna `{uuid, titulo, dia_atividade, importante}` (objeto único). Mas em `App.jsx`, a função `getTasks()` assume que qualquer resposta não-objeto é um array direto:

```javascript
// Código ERRADO original:
const getTasks = async () => {
    const response = await fetchTasks();
    if (response.data) {
        setTasks(response.data);
    } else {
        setTasks(response);  // ← Pode ser um objeto não-array, quebrando .map() depois
    }
};
```

Se `response` é um objeto tipo `{erro: "..."}` ou qualquer coisa que não seja array e não tenha `.data`, então `setTasks(response)` coloca um non-array no estado. Resultado: `Tasks.jsx` tenta fazer `currentTasks.map()` e quebra.

**Solução — validar tipo de resposta:**
```javascript
const getTasks = async () => {
  try {
    const response = await fetchTasks();
    
    // Garantir que tasks é SEMPRE um array
    let tarefas = [];
    if (Array.isArray(response)) {
      tarefas = response;
      setFromCache(false);
      setCacheTTL(null);
      setCacheError(false);
    } else if (response && Array.isArray(response.data)) {
      tarefas = response.data;
      setFromCache(response.fromCache || false);
      setCacheTTL(response.cacheTTL || null);
      setCacheError(response.cacheError || false);
    }
    
    setTasks(tarefas);  // sempre um array, seguro pra .map() depois
  } catch (error) {
    addLog('ERROR', 'Falha ao carregar tarefas', error.message);
  }
};
```

**Ponto crítico na implementação:** `getTasks` precisa ser definida **antes** do `useEffect` que a chama. Em React, funções `const` não sofrem hoisting como `function` faria — ordem no arquivo importa.

```javascript
function AppContent() {
  // ... states ...
  
  // ✅ Definir ANTES
  const getTasks = async () => { ... };
  
  // ✅ Chamar DEPOIS
  useEffect(() => {
    getTasks();
  }, []);
}
```

### Validação End-to-End — todos os endpoints

Confirmado funcionando via console:

```javascript
// GET — retorna array de tarefas
[18:38:27] SUCCESS: API GET - 200
Response: [{"uuid":"c6788ab0-a24b-11f1-9cea-b7d3cd6e7173","titulo":"terminar de estudar os..."}]

// POST — retorna objeto tarefa criada
[18:44:06] SUCCESS: API POST - 200
Response: {"uuid":"6db5b0e0-a260-11f1-9cea-b7d3cd6e7173","titulo":"terminar os desafios fundamentais"}

// DELETE — retorna vazio (200 OK é sucesso)
[18:43:36] SUCCESS: API DELETE - 200
Response: Sem dados
```

**Fluxo completo na UI:**
1. Usuário clica "Add New Task" → formulário envia POST
2. Backend processa → INSERT na tabela `tarefas` → retorna novo registro
3. Frontend recebe → `setTasks([...tasks, novaTask])` → React re-renderiza `<Tasks>`
4. Nova linha aparece na lista com UUID, titulo, data, prioridade

### Aprendizagens práticas

- **Variáveis Vite compiladas:** não mudar `.env.local` e esperar "sincronizar" — rebuild + re-upload são obrigatórios.
- **IP privado é só dentro da VPC:** fácil esquecer quando testando localmente (CLI funciona, porque está na mesma VPC via EC2); UI em S3 fica fora.
- **Type safety em React:** validar `Array.isArray()` antes de chamar `.map()` salva horas de debug depois. TypeScript ajudaria, mas JS puro também funciona com cuidado.
- **Ordem de funções em React:** `const` vs `function` comportam-se diferente — ordem importa.
- **Logs são amigos:** os logs estruturados no `LogContext` mostraram exatamente onde o erro estava acontecendo — "e is not iterable" num `.map()` invisível, não no código que escrevi diretamente.

### Tecnologias em prática

| Camada | Tecnologia | Porta | O que faz |
|---|---|---|---|
| Frontend | React + Vite | S3 (HTTPS) | Compila em build-time, serve HTML/CSS/JS estático |
| Backend | Node.js + Express | EC2:3001 | Recebe HTTP, valida, fala com database |
| Database | PostgreSQL | EC2:5433 (mapeado) | Persiste dados em volume Docker |

**Próximos passos nessa arquitetura:**
- [ ] Resolver HTTPS + Mixed Content (S3 em HTTPS, backend em HTTP)
- [ ] Autenticação entre frontend e backend (JWT, OAuth)
- [ ] Validações mais robustas (constraints SQL, Zod/Joi no backend)
- [ ] Monitoramento (CloudWatch logs, alertas)

---

## 15. Day 4, Parte 1 — Tela Preta: zip/unzip, tail -f, command substitution e a leitura do `lancar_ec2_zona_a.sh`

**O que é:** a virada pra dentro do terminal puro — depois de três dias operando via Console/CLI da AWS, esse bloco é sobre as ferramentas de shell que sustentam os scripts de automação já usados nos dias anteriores (o próprio `lancar_ec2_zona_a.sh` que criou a `bia-dev`). Não é AWS CLI novo, é entender o "cimento" em bash que already estava sendo usado sem explicação.

### zip / unzip

```bash
zip -r pacote.zip pasta/          # compacta a pasta inteira (recursivo)
zip arquivo.zip a.txt b.txt       # compacta arquivos soltos
unzip pacote.zip                  # descompacta no diretório atual
unzip -o pacote.zip -d /destino   # -o sobrescreve sem perguntar; -d define destino
unzip -l pacote.zip               # só lista o conteúdo, sem extrair
```

**Onde já apareceu, sem eu ter notado:** linha 12 do `user_data_ec2_zona_a.sh` — `unzip awscliv2.zip`. O instalador oficial da AWS CLI v2 é distribuído como `.zip`; o `unzip` extrai o pacote antes do script rodar o instalador de dentro dele. Só fazia sentido depois de olhar com atenção pro que o user-data realmente faz no primeiro boot.

### tail -f

`tail` mostra o final de um arquivo; `-f` ("follow") mantém o processo vivo acompanhando novas linhas em tempo real — ideal pra logs que continuam sendo escritos.

```bash
tail -n 20 arquivo.log     # últimas 20 linhas, e sai
tail -f arquivo.log        # fica "grudado" mostrando novas linhas conforme chegam (Ctrl+C sai)
tail -F arquivo.log        # como -f, mas reabre se o arquivo for rotacionado/recriado
```

**Uso prático ligado à EC2:** depois que a instância sobe, o user-data roda em boot e grava log em `/var/log/cloud-init-output.log`. Conectando por SSM, `sudo tail -f /var/log/cloud-init-output.log` deixa acompanhar ao vivo a instalação do Docker/Node/etc acontecendo — em vez de esperar cega e só checar depois se deu certo.

### Command substitution

Pegar a saída de um comando e usar como valor de uma variável ou dentro de outro comando.

```bash
data=$(date +%F)          # forma moderna, preferida
data=`date +%F`           # forma antiga (crase), evite: não aninha bem
echo "Hoje é $data"
```

Pode aninhar: `echo "$(echo interno)"`. É o padrão que domina o `lancar_ec2_zona_a.sh` inteiro — cada variável usada no `run-instances` final vem de um `$(aws ec2 describe-...)` anterior.

### Interpretando o `lancar_ec2_zona_a.sh`

```bash
vpc_id=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true \
  --query "Vpcs[0].VpcId" --output text)
```
- `aws ec2 describe-vpcs` lista VPCs; o filtro pega só a VPC default da conta.
- `--query` usa JMESPath pra extrair só o campo `VpcId` do primeiro resultado.
- `--output text` devolve texto puro (sem aspas/JSON), fácil de guardar em variável.
- `$(...)` captura essa saída e joga em `vpc_id`. Sem isso, `vpc_id` teria o JSON inteiro ou nada.

```bash
subnet_id=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$vpc_id \
  Name=availabilityZone,Values=us-east-1a --query "Subnets[0].SubnetId" --output text)
```
- Mesma lógica: agora busca, dentro daquela VPC (`$vpc_id`, usando a variável recém-criada), a subnet que está na AZ `us-east-1a` — daí o nome do script, "zona_a".
- Repare a dependência em cadeia: a 2ª chamada só funciona porque a 1ª já preencheu `vpc_id`.

```bash
security_group_id=$(aws ec2 describe-security-groups --group-names "bia-dev" \
  --query "SecurityGroups[0].GroupId" --output text 2>/dev/null)
```
- Busca o SG chamado `bia-dev` pelo nome.
- `2>/dev/null` redireciona o stderr (descritor 2) pro "buraco negro" — se o SG não existir, o erro da AWS CLI não aparece na tela, ficando silencioso (propositalmente, porque o erro vai ser tratado a seguir).

```bash
if [ -z "$security_group_id" ]; then
    echo ">[ERRO] Security group bia-dev não foi criado na VPC $vpc_id"
    exit 1
fi
```
- `-z` = "string vazia?". Se o `describe-security-groups` falhou (SG não existe), `security_group_id` fica vazio → cai aqui.
- `exit 1` interrompe o script com código de erro, evitando lançar a EC2 sem SG válido (é aqui que o `2>/dev/null` de cima faz sentido: o script prefere dar sua própria mensagem de erro, mais clara, em vez do erro cru da AWS CLI).

```bash
aws ec2 run-instances --image-id ami-02f3f602d23f1659d --count 1 --instance-type t3.micro \
--security-group-ids $security_group_id --subnet-id $subnet_id --associate-public-ip-address \
--block-device-mappings '[{"DeviceName":"/dev/xvda","Ebs":{"VolumeSize":15,"VolumeType":"gp2"}}]' \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=bia-dev}]' \
--iam-instance-profile Name=role-acesso-ssm --user-data file://user_data_ec2_zona_a.sh
```
- As três variáveis calculadas por command substitution são finalmente usadas pra criar a instância.
- `--user-data file://user_data_ec2_zona_a.sh` injeta o segundo script pra rodar automaticamente no primeiro boot (é ele que faz o `unzip` visto na seção acima) — mostrando como os dois scripts se encaixam: um decide **onde** lançar (VPC/subnet/SG via command substitution), o outro decide **o que** instalar dentro da máquina.
- `\` no fim das linhas é só continuação de linha (o comando é um só, quebrado por legibilidade).
- **Ponto de atenção:** não há tratamento de erro depois desse `run-instances` — se ele falhar (ex: AMI errada, quota), o script termina sem avisar nada, diferente do cuidado que teve com o SG logo acima.

**Resumo do fluxo do script:**
1. Descobre VPC default → `vpc_id`
2. Descobre subnet na zona A dentro dela → `subnet_id`
3. Descobre SG `bia-dev`, com fallback de erro se não existir
4. Lança a EC2 usando essas três variáveis + injeta o script de instalação como user-data

### Aprendizagens

- **`zip`/`unzip` não é só utilitário avulso** — é peça de infraestrutura: o instalador oficial da AWS CLI v2 chega compactado, e todo `user_data` que o instala depende de um `unzip` silencioso rodando no boot.
- **`tail -f` transforma "espera cega" em observação ao vivo** — em vez de esperar um tempo arbitrário e torcer, dá pra ver exatamente em que passo do user-data a instância está, com `/var/log/cloud-init-output.log`.
- **Command substitution (`$(...)`) é o que permite scripts "descobrirem sozinhos" o ambiente** — em vez de hardcodar `vpc-0123abc`, o script pergunta pra API da AWS qual é a VPC default *no momento em que roda*, o que o torna portável entre contas/regiões sem editar nada.
- **Dependência em cadeia entre variáveis é frágil por natureza** — se a 1ª chamada (`vpc_id`) vier vazia por qualquer motivo, a 2ª (`subnet_id`) já herda o problema silenciosamente, porque só o SG teve tratamento de erro explícito nesse script.
- **`2>/dev/null` + checagem manual com `-z` é um padrão intencional**, não descuido: o script prefere calar o erro técnico da CLI e mostrar uma mensagem própria, mais clara pra quem está operando.
- **Nem todo passo crítico tem tratamento de erro** — o próprio `run-instances` final não tem, o que é uma lacuna real do script (contraste direto com o cuidado tomado só algumas linhas antes, no bloco do security group).
