# Mapa de Estudo — Projeto BIA (AWS Imersão)

> Consolidação de tudo trabalhado até aqui: arquitetura da imagem Docker,
> topologia de containers, acesso à instância EC2, e o fluxo operacional
> completo de retomar o ambiente do zero. Cada item tem o **o quê** e o
> **por quê** — é o porquê que costuma escapar na primeira passada.

---

## 1. Visão geral da arquitetura

```
┌─────────────────────────────────────────────────────────┐
│  Instância EC2 (i-074bcbdb1642ec026)                     │
│  IAM Role: role-acesso-ssm                                │
│                                                             │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐               │
│  │   bia    │──▶│ database │   │  redis   │               │
│  │ (server) │   │postgres17│   │valkey8.1 │               │
│  │  :8080   │   │  :5432   │   │  :6379   │               │
│  └────┬─────┘   └────┬─────┘   └──────────┘               │
│       │              │                                     │
│  host:3001      host:5433 (volume "db" persistente)       │
└───────┼─────────────────────────────────────────────────┘
        │
   Security Group (porta 3001 aberta 0.0.0.0/0)
        │
   Navegador local (http://<IP-público>:3001)
```

**Por quê essa forma:** três containers na mesma rede Docker Compose, cada um
com uma responsabilidade única (app / dados / cache). É o padrão de
"separation of concerns" que facilita trocar ou escalar cada peça
independente — por exemplo, dar mais recursos só ao banco sem afetar a app.

---

## 2. Build da imagem — Dockerfile (single-stage, 11 camadas)

| # | Camada | Por quê |
|---|--------|---------|
| 1 | `FROM node:24.18.0-slim` (ECR Public) | Imagem leve; ECR Public evita rate limit do Docker Hub |
| 2 | `npm install -g npm@11` | Garante versão recente do npm |
| 3 | `apt-get install curl` | Necessário depois para health check em `/api/versao` |
| 4 | `WORKDIR /usr/src/app` | Define onde os comandos seguintes rodam |
| 5 | `COPY package*.json` + `npm install` | **Cache**: só reinstala deps do backend se o `package.json` mudar |
| 6 | `COPY client/package*.json` + `npm install` | **Cache separado** para o frontend, mesma lógica |
| 7 | `COPY . .` | Só agora entra o código-fonte — qualquer mudança aqui invalida daqui pra frente |
| 8 | `npm run build` (client, Vite) | Build do React; `VITE_API_URL` fica **gravada** no bundle estático neste passo |
| 9 | `npm prune --production` | Remove devDependencies do client, reduz tamanho final |
| 10 | `EXPOSE 8080` | Documenta a porta interna (não publica sozinha) |
| 11 | `CMD ["npm", "start"]` | Comando que sobe o servidor quando o container inicia |

**Trade-off explícito — single-stage vs multi-stage:** esse Dockerfile é
single-stage por simplicidade didática. Um multi-stage build separaria o
estágio de build (com todas as devDependencies) do estágio final de execução,
gerando uma imagem final ainda menor e com menos superfície de ataque — é o
próximo nível de otimização a estudar quando o objetivo for produção de
verdade, não só o curso.

**Armadilha identificada:** como o `VITE_API_URL` é gravado no bundle estático
no passo 8, se a URL da API mudar depois (ex: trocar de `localhost:3001` para
um domínio real), é preciso **rebuildar a imagem inteira** — não dá para só
reiniciar o container.

---

## 3. Topologia do compose.yml

- **bia (server)**: porta `3001→8080`, depende de `database` e `redis` (ordem
  de start), variáveis `DB_HOST=database`/`DB_PORT=5432` já ativas; variáveis
  de cache (`CACHE_*`) e de secrets AWS (`DB_SECRET_NAME`, `AWS_ACCESS_KEY_ID`)
  comentadas — é a próxima fase do curso.
- **database (postgres:17.1)**: porta `5433→5432` (5433 escolhida para não
  colidir com um Postgres local); **volume nomeado `db`** — é o único dado que
  sobrevive a um `docker compose down`.
- **redis (valkey:8.1-alpine)**: sem volume — cache não-persistente por
  design; a app ainda não está configurada pra usar (variáveis comentadas).

**Por quê o volume só no banco:** cache é, por definição, dado descartável —
perder o Redis não é um incidente, é o comportamento esperado. Perder o
Postgres sem volume, sim, seria perda de dados real.

---

## 4. Acesso à instância — SSM em vez de SSH

**Descoberta central da sessão:** essa instância não tem par de chaves
(`KeyName: None`). Ela usa a IAM Role `role-acesso-ssm`, o que significa que o
acesso é via **AWS Systems Manager Session Manager**, autenticado pelas suas
credenciais AWS CLI locais — não por um arquivo `.pem`.

| Método | Precisa de | Nossa instância usa? |
|---|---|---|
| SSH tradicional | par de chaves `.pem`, porta 22 aberta no SG | Não |
| EC2 Instance Connect | chave temporária de 60s, porta 22 aberta | Não configurado |
| **SSM Session Manager** | IAM Role com `AmazonSSMManagedInstanceCore`, agente SSM ativo | **Sim** |

**Por quê isso importa:** SSM não exige nenhuma porta de entrada aberta no
Security Group — a conexão é iniciada de dentro para fora pelo agente SSM. É
mais seguro (menor superfície de ataque) e elimina o problema de "perdi a
chave `.pem`", que foi exatamente o que te travou no início desta sessão.

**Comando de conexão:**
```bash
aws ssm start-session --target i-074bcbdb1642ec026
```

---

## 5. Fluxo operacional completo (o que fazer sempre que voltar)

```
1. Verificar estado da instância (LOCAL)
   aws ec2 describe-instances --query State.Name

2. Se "stopped" → ligar e esperar (LOCAL)
   aws ec2 start-instances
   aws ec2 wait instance-running
   aws ec2 wait instance-status-ok

3. Esperar o agente SSM ficar "Online" (LOCAL)
   aws ssm describe-instance-information --query PingStatus
   (demora mais que os status checks do EC2 — armadilha comum)

4. Conectar (LOCAL → abre sessão)
   aws ssm start-session --target <instance-id>

5. Dentro da sessão: localizar e entrar na pasta do projeto
   find / -maxdepth 4 -iname "compose.yml"
   cd /home/ssm-user/bia_aws_imersao

6. Subir os containers
   sudo docker compose up -d
   (ssm-user não está no grupo docker por padrão → precisa de sudo,
    ou usermod -aG docker ssm-user + reconectar para resolver de vez)

7. Confirmar
   sudo docker compose ps
   curl http://localhost:3001/api/versao

8. Pegar o IP público atual (LOCAL — muda a cada restart, sem Elastic IP)
   aws ec2 describe-instances --query PublicIpAddress

9. Confirmar que a porta 3001 está liberada no Security Group (LOCAL)
   aws ec2 describe-security-groups --query IpPermissions

10. Abrir no navegador
    http://<IP-público>:3001
```

**Regra de ouro que causou confusão nesta sessão:** comandos `aws ec2
describe-*` e `aws ec2 authorize-*` rodam na sua **máquina local** (terminal
WSL2 com suas próprias credenciais). Comandos `docker compose *` e `curl
localhost` rodam **dentro da sessão SSM**. Misturar os dois terminais foi a
causa de pelo menos três erros nesta sessão (`UnauthorizedOperation` ao rodar
`describe-instances` dentro da instância, `docker ps` sem containers ao rodar
localmente).

---

## 6. Erros reais encontrados — causa raiz

| Erro | Causa raiz |
|---|---|
| `Identity file ... not accessible` | Caminho de `.pem` era só um placeholder de exemplo, e a instância nem usa chave SSH |
| `permission denied ... docker.sock` | `ssm-user` não pertence ao grupo `docker` |
| `UnauthorizedOperation` em `ec2:DescribeInstances` | Comando rodado **dentro** da sessão SSM, usando a IAM Role da instância (só tem permissão de SSM), não suas credenciais locais |
| `InvalidGroupId.Malformed` | Copiou o `sg-xxxxx` de exemplo em vez do ID real retornado pelo comando anterior |
| `docker ps` sem containers, socket inexistente | Rodado na máquina local (WSL2), não dentro da instância — os containers do BIA vivem só na EC2 |

---

## 7. Pontos para revisar com mais calma

- [ ] Diferença prática entre SSH, EC2 Instance Connect e SSM — quando cada
      um faz sentido em produção (não só no lab)
- [ ] Multi-stage build no Dockerfile — como reduziria o tamanho da imagem
      final e por quê isso importa em produção
- [ ] IAM Roles vs usuários/chaves — por que a instância "autentica sozinha"
      via role, sem precisar de credenciais embutidas
- [ ] Elastic IP — como evitaria o IP mudando a cada restart, e o trade-off
      de custo (Elastic IP não usado é cobrado)
- [ ] Security Groups como stateful firewall — por que só precisou liberar
      entrada (inbound) e não saída (outbound)
- [ ] O papel exato do agente SSM dentro da instância (o que ele faz em
      background, por que demora pra ficar "Online")

---

## 8. Glossário rápido

- **IAM Role**: identidade que a própria instância "veste" para ter
  permissões na AWS, sem precisar de chave de acesso fixa.
- **SSM Agent**: processo rodando dentro da instância que "escuta" pedidos de
  sessão vindos do Systems Manager.
- **Security Group**: firewall virtual por instância, controla portas de
  entrada/saída.
- **Volume nomeado (Docker)**: armazenamento gerenciado pelo Docker que
  sobrevive à remoção do container, associado ao serviço `database`.
- **Elastic IP**: IP público fixo que não muda entre restarts (não usado
  ainda neste projeto).


![[mcp_bia_description.png]]

