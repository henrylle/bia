# 🔌 Dia 3 — Integração Completa (Frontend + Backend + Banco), explicada para quem vem de Dados

> **Sobre este documento:** é uma reescrita didática do relatório técnico "Day 3: Integração Completa BIA" (27/08/2026), traduzindo cada conceito de Dev/DevOps para algo que já faz sentido pra quem trabalha com Ciência de Dados. O relatório original documenta *o que* foi feito; este aqui foca no *por quê* cada problema aconteceu — porque entender a causa é o que generaliza pro próximo bug, não decorar o comando que resolveu este aqui.
> Complementa [`analise-arquitetura-projeto.md`](./analise-arquitetura-projeto.md) (que explica a arquitetura em repouso) — este documento é sobre o momento em que as 3 camadas passaram a conversar de verdade, em produção, e o que quebrou no caminho.

---

## 1. O que mudou nesse dia, em uma frase

Até aqui, as 3 camadas (frontend, backend, banco) rodavam **juntas, na mesma máquina** (local ou dentro de um único container/EC2). Nesse dia, elas foram **separadas fisicamente**:

| Camada | Onde vivia antes | Onde passou a viver |
|---|---|---|
| Frontend | Servido pelo próprio Express, junto do backend | **Amazon S3** (hospedagem de arquivo estático) |
| Backend | Mesma máquina do frontend | **EC2** (`54.83.241.43`, porta 3001) |
| Banco | Container ao lado do backend | Container Docker, mas agora **alcançado só pelo backend**, nunca diretamente pela internet |

**Por que isso é mais difícil do que parece:** enquanto tudo mora no mesmo lugar, "conversar entre camadas" é só uma chamada de função ou, no máximo, `localhost:porta`. Assim que você separa fisicamente, cada seta do diagrama vira uma **fronteira de rede real** — com IP, porta, firewall e, no caso do frontend, uma etapa de compilação no meio. É exatamente aí que os 3 problemas do dia aconteceram: cada um mora numa fronteira diferente.

```
Navegador do usuário
   │
   │ 1) baixa HTML/CSS/JS pronto (sem executar nada no servidor)
   ▼
S3 (frontend estático, fora da rede privada da AWS)
   │
   │ 2) fetch() para a API — atravessa a internet pública
   ▼
EC2 54.83.241.43:3001 (backend Node/Express, dentro da VPC)
   │
   │ 3) SQL — fica DENTRO da VPC, nunca sai pra internet
   ▼
PostgreSQL (container Docker, porta 5433→5432)
```

---

## 2. Problema 1 — "Mudei a variável, mas o app continua chamando `localhost`"

### O sintoma
`VITE_API_URL=http://54.83.241.43:3001` foi escrito num arquivo `.env.local`, o site foi re-hospedado no S3, e o navegador continuava tentando falar com `localhost:8080`.

### A causa, na linguagem de dados
Pensa num modelo `scikit-learn` que você treina e depois serializa com `pickle`. O `StandardScaler` guarda a média e o desvio-padrão **calculados no momento do treino**, congelados dentro do arquivo `.pkl`. Se você quiser mudar esses valores, não adianta editar uma variável em algum lugar do seu notebook de inferência — você precisa **retreinar e salvar um `.pkl` novo**.

É exatamente isso que o **Vite** faz com variáveis `VITE_*`: ele não lê o `.env.local` toda vez que a página carrega no navegador (isso seria "runtime"). Ele lê o `.env.local` **uma única vez, no momento do `npm run build`**, e substitui `import.meta.env.VITE_API_URL` pelo valor literal, direto no JavaScript compilado — igual o `pickle` "cristaliza" os parâmetros do scaler.

```
Ambiente Python                          Vite
──────────────────────────────────────────────────────────────────
Treinar modelo (fit)              ≈      npm run build
Parâmetros vão pro .pkl           ≈      Variável vira texto fixo no .js
Rodar inferência (predict)        ≈      Navegador executa o .js já pronto
Mudar hiperparâmetro no .pkl?     ≈      Mudar variável já compilada?
  → Não dá. Precisa retreinar.            → Não dá. Precisa rebuildar.
```

Um segundo erro, comum em quem migra de tutoriais mais antigos: usar o prefixo `REACT_APP_*` (convenção de outra ferramenta, o *Create React App*). O Vite só compila variáveis que começam com `VITE_`. Qualquer outro prefixo é ignorado silenciosamente — sem erro, sem aviso.

### A solução
```bash
cat client/.env.local              # confirma VITE_API_URL=http://54.83.241.43:3001
cd client && npm run build          # "retreina": recompila o valor pra dentro do JS
aws s3 sync build/ s3://bia-frontend-1787854147/ --delete   # "reimplanta o modelo"
```
E `Ctrl+Shift+R` no navegador — porque o navegador também tem seu próprio cache do `.js` antigo, igual um notebook Jupyter que não recarrega uma função depois que você editou o `.py` importado.

### A lição generalizável
**Toda vez que uma configuração é "compilada" (build-time) em vez de "lida" (runtime), mudar o valor de origem não basta — é preciso refazer o passo de compilação e reimplantar o artefato.** Isso vale pra Vite, pra um modelo serializado, pra uma imagem Docker com variável `ARG` (em vez de `ENV`), e pra qualquer cache de segundo nível (CDN, navegador) que ainda esteja servindo a versão anterior.

---

## 3. Problema 2 — "O backend está rodando, mas ninguém de fora consegue falar com ele"

### O sintoma
Configurar `VITE_API_URL=http://172.31.0.186:3001` (o IP **privado** da instância EC2) resultava em `ERR_CONNECTION_TIMEOUT`. Trocar para `http://54.83.241.43:3001` (o IP **público**) resolveu.

### A causa, na linguagem de dados
Toda instância EC2 dentro de uma AWS **VPC** (Virtual Private Cloud) ganha um IP no formato `172.31.x.x` — pensa nisso como o **IP interno de um cluster** (tipo os nós de um cluster Spark ou Dask, que se enxergam entre si por um IP interno que só existe *dentro* da rede do cluster). Um cliente de fora do cluster — seu notebook local, ou nesse caso o **S3**, que fica fora de qualquer VPC — não tem rota nenhuma até esse IP interno. É como tentar `ssh` para o IP interno de um nó de cluster a partir da sua máquina pessoal, sem estar na mesma VPN: a rede simplesmente não sabe como chegar lá.

O **IP público** (`54.83.241.43`) é o equivalente ao endpoint exposto de um cluster — o "load balancer" ou o "gateway" que a AWS coloca na borda, roteável pela internet.

```
Quem está perguntando          IP privado (172.31.x.x)   IP público (54.x.x.x)
─────────────────────────────────────────────────────────────────────────────
Outro EC2 na mesma VPC          ✅ funciona                ✅ funciona
S3 (fora de qualquer VPC)       ❌ sem rota                ✅ funciona
Seu notebook/laptop             ❌ sem rota                ✅ funciona
```

Isso não é "burocracia da AWS por burocracia" — é a mesma lógica de segurança de **nunca expor os nós internos de um cluster de dados diretamente pra internet**: só a borda (gateway/load balancer) é pública; o resto conversa por dentro.

### A solução
Simplesmente apontar `VITE_API_URL` para o IP público, e — como já era esperado pelo Problema 1 — rebuildar e reimplantar.

### A lição generalizável, e um alerta real
**IP privado é só para tráfego dentro da mesma VPC; qualquer coisa que more fora (S3, seu notebook, outra nuvem) precisa do IP público — e do Security Group liberando a porta.**

⚠️ **Verifiquei agora (27/08/2026) e essa instância NÃO tem um Elastic IP associado.** O IP público `54.83.241.43` só continua o mesmo porque a instância não foi desligada desde então. Na AWS, **o IP público de uma EC2 comum muda toda vez que ela é parada e ligada de novo** — e como o `VITE_API_URL` fica *compilado, fixo, dentro do JavaScript* (Problema 1!), um simples restart da instância quebra o frontend em produção sem nenhuma mudança de código. Isso vale registrar como próximo item técnico: associar um **Elastic IP** (IP público fixo) à instância antes de mexer nela de novo.

---

## 4. Problema 3 — "A tarefa foi criada no banco, mas a tela quebra com `e is not iterable`"

### O sintoma
O `POST` retornava `200` com o UUID da tarefa criada — o dado chegou certinho no Postgres — mas a interface travava com o erro `e is not iterable`, e a lista de tarefas nunca aparecia.

### A causa, na linguagem de dados
Pensa em um pipeline que espera sempre receber um `pandas.DataFrame`, mas em algum branch do código um retorno inesperado devolve um `dict` solto ou um `None`. Se o próximo passo do pipeline faz `for row in resultado:` ou `resultado.iterrows()` sem checar o tipo antes, o erro só aparece **na hora de iterar**, longe de onde o dado "errado" foi produzido — exatamente como aconteceu aqui.

```javascript
// Versão frágil: assume que "response" é sempre um array
const getTasks = async () => {
    const response = await fetchTasks();
    setTasks(response.data ? response.data : response);  // pode não ser array!
};
```

Mais adiante, um componente fazia `tasks.map(...)` pra desenhar a lista na tela. Se `tasks` não for de fato uma lista (por exemplo, veio um objeto de erro, ou `undefined`), `.map()` explode com "`e` não é iterável" — `e` sendo o nome interno que o motor JS deu pra essa variável durante a minificação do build.

**A analogia direta em Python:** é o mesmo tipo de bug que `assert isinstance(df, pd.DataFrame)` existe pra prevenir — validar o **formato dos dados na fronteira de entrada** (assim que a resposta chega da API), em vez de deixar o erro estourar silenciosamente lá na frente, no código que só *usa* o dado.

### A solução
```javascript
const getTasks = async () => {
  try {
    const response = await fetchTasks();
    let tarefas = [];                                  // valor padrão seguro
    if (Array.isArray(response)) {
      tarefas = response;                               // formato "cru": array direto
    } else if (response && Array.isArray(response.data)) {
      tarefas = response.data;                          // formato "envelopado": {data: [...]}
    }
    setTasks(tarefas);                                  // daqui pra frente, SEMPRE array
  } catch (error) {
    addLog('ERROR', 'Falha ao carregar tarefas', error.message);
  }
};
```
`Array.isArray(x)` é o `isinstance(x, list)` do JavaScript: valida o tipo antes de qualquer operação que assuma aquele tipo.

### Um detalhe de linguagem que vale entender (não é bug, é ordem de execução)
O código também reorganizou `getTasks` para ser declarada **antes** do `useEffect` que a chama. Isso não é sobre tipo de dado, é sobre como o **JavaScript executa um arquivo de cima pra baixo**: uma função guardada com `const nome = () => {...}` só existe a partir da linha em que é declarada (diferente de `function nome() {...}`, que "sobe" — *hoisting* — pro topo do arquivo antes de tudo rodar). Em Python o equivalente seria tentar chamar uma função num módulo antes da linha `def nome(): ...` ter sido executada — dá `NameError`. Como o `useEffect` só *executa* seu conteúdo depois que o componente inteiro já rodou uma vez (não no momento em que é declarado), na prática isso quase nunca quebra de verdade — mas declarar na ordem "primeiro defino, depois uso" evita qualquer ambiguidade e é mais fácil de ler.

### A lição generalizável
**Sempre que uma resposta externa (API, arquivo, banco) entra no seu código, valide o formato antes de operar sobre ela** — `Array.isArray()` em JS, `isinstance()` em Python, `df.shape`/`df.dtypes` antes de um `merge`. O custo de checar é uma linha; o custo de não checar é um bug que aparece longe da causa raiz.

---

## 5. Como validar que as 3 camadas realmente se falam (teste ponta a ponta)

Isso é, na prática, um **teste de integração**: em vez de testar cada camada isolada (unit test), você testa o caminho completo — do clique do usuário até a linha gravada no banco e de volta.

| Operação | Método + rota | O que confirma |
|---|---|---|
| Listar tarefas | `GET /api/tarefas` → 200 | Backend lê do banco e serializa corretamente |
| Criar tarefa | `POST /api/tarefas` → 200 + UUID | Escrita no banco funciona, e o dado volta com identificador |
| Mudar prioridade | `PUT /api/tarefas/update_priority/:uuid` → 200 | Atualização (não só criação/leitura) funciona |
| Remover tarefa | `DELETE /api/tarefas/:uuid` → 200 | Remoção funciona e reflete na UI |

O jeito mais rápido de checar isso sem depender do navegador é o mesmo `curl` que você já usaria pra testar qualquer API de inferência de ML:
```bash
curl -X GET http://54.83.241.43:3001/api/tarefas
curl -X POST http://54.83.241.43:3001/api/tarefas \
  -H "Content-Type: application/json" \
  -d '{"titulo":"teste","dia_atividade":"28/08/2026","importante":false}'
```
E os **logs estruturados** do frontend (timestamp + nível `INFO`/`SUCCESS`/`ERROR` + payload) cumprem o mesmo papel que um bom `logging.info(...)` estruturado cumpre num pipeline de dados: sem eles, debugar um problema de rede distribuída em 3 camadas seria muito mais lento.

---

## 6. Glossário rápido deste capítulo

| Termo | O que é | Analogia de dados |
|---|---|---|
| **Build-time vs. runtime** | Build-time = compilado uma vez, fixo no artefato final; runtime = lido/calculado a cada execução | Parâmetros de um modelo serializado (`.pkl`) vs. um valor lido de um arquivo de config a cada chamada |
| **VPC** | Rede virtual privada da AWS onde vivem os recursos (EC2, banco) | A rede interna de um cluster (Spark/Dask), invisível de fora |
| **IP privado / IP público** | Privado = só roteável dentro da VPC; público = roteável pela internet | IP interno de um nó de cluster vs. o endpoint público de um load balancer |
| **Elastic IP** | IP público fixo que você associa manualmente a uma instância | Um endpoint de API estável, versus uma URL que muda a cada redeploy |
| **`Array.isArray()`** | Checagem de tipo em JavaScript | `isinstance(x, list)` em Python |
| **Hoisting** | Comportamento do JS de "içar" declarações `function` pro topo do arquivo antes de executar | Não existe exatamente em Python — mais próximo de "ordem de execução top-a-baixo de um script" |
| **Teste de integração** | Testa o caminho completo entre múltiplos componentes, não um só isolado | Testar o pipeline de ETL inteiro, não só uma função de transformação isolada |

---

## 7. O que ficou como próximo passo (do relatório original)

- **Curto prazo:** resolver *Mixed Content* (S3 serve o site em HTTPS, mas o backend responde em HTTP puro — navegadores modernos podem bloquear essa mistura); validação de payload mais robusta no backend (Zod/Joi — o equivalente a usar `pydantic` pra validar o corpo de uma requisição antes de processar).
- **Médio prazo:** autenticação (JWT/OAuth) entre as camadas; tratamento de erro mais granular por status HTTP.
- **Longo prazo:** observabilidade em produção (CloudWatch + alertas), performance (code splitting no React, cache de respostas, índices no banco).
- **Identificado nesta reescrita:** associar um **Elastic IP** à instância `bia-dev` antes do próximo restart, para não repetir o Problema 2 por uma causa nova (IP público mudou).

---

*Documento gerado em 27/08/2026 a partir do relatório técnico "Day 3: Integração Completa BIA", reescrito com foco didático para quem está migrando de Ciência de Dados para AWS/DevOps. Complementa [`analise-arquitetura-projeto.md`](./analise-arquitetura-projeto.md).*
