No seu trabalho de especificar tarefas, desejo que sempre que for pedido uma nova atividade, o resultado
do seu trabalho será a criação de um arquivo markdown (.md).

Esse arquivo deve ter o seguinte formato [025]-[feat]-[resumo].md
Onde:
- [025] é o número sequencial da tarefa, sempre com 3 dígitos
    - Esse controle sequencial será feito por um arquivo chamado sequencial.md.
    - Nesse arquivo terá apenas o texto (Última Task: [002].)
        - Você vai sempre usar o sequencial seguinte e incrementar o valor de Última Task.
- [feat] é o tipo da tarefa (pode ser feat, fix, test)
- [resumo] é um resumo curto da tarefa, separado por hífens


# Sobre a task que vai ser criada
- No início da task, você precisa colocar informações importantes sobre o nosso modelo de trabalho. 
Vamos adotar um modelo feature/branch, ou seja, cada task terá o seu branch. O branch deverá ter o nome das task e SEMPRE derivar do branch ia-main. Ao criar a task, você precisa especificar qual agent deve iniciar ela.
- O agent que iniciar, deverá inicialmente verificar se estamos no branch ia-main. Caso não esteja, deve informar e perguntar se podemos retornar para ele, antes de iniciar a task.
- Após ser autorizado, ele deverá mover a task para .amazonq/tasks/doing, fazer commit e push no branch ia-main e criar o branch para inicar a implementação.
- Você deverá delegar a atividade para inicio de um desses agentes: 
    - dev (.amazonq/cli-agents/dev.json)
    - devops(.amazonq/cli-agents/devops.json)
    - qa (.amazonq/cli-agents/qa.json)
    - po (.amazonq/cli-agents/po.json)

O local que o arquivo deve ser criado, será na pasta .amazonq/tasks
- Você também deverá gerenciar o estado desses arquivos criados, ou seja, quando uma tarefa for finalizada, você vai 
mover esse arquivo para uma pasta na mesma folder acima, chamado done/

- Sempre que você criar uma nova task, você me sinaliza para que eu possa revisar.
- Após eu dizer que está ok a revisão, Você pergunta se já pode ser feito o commit e push dela para o repositório remoto (lembre de fazer commit e push da task e do sequencial).