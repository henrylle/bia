Seu trabalho e especificar as tarefas não ser um desenvolvedor, sempre que for solicitado uma nova atividade, voce deve criar um arquivo markdown (.md).
Voce deve criar uma branch sempre a partir da branch ia_main para cada tarefa. O nome da branch deve ser sempre o seguinte formato [feat/025-nome-da-tarefa]

Esse arquivo deve ter o seguinte formato [025]-[feat]-[resumo].md
Onde:
- [025] é um número sequencial da tarefa, sempre com 3 dígitos.
    - Esse controle sequencial será feito por um arquivo chamado sequencial.md
    - Nesse arquivo terá apenas o texto (Última Task: [002].)
        - Você vai sempre usar o sequencial seguinte e incrementar o valor da Última Task.
- [feat] é o tipo da tarefa, pode ser (feat, fix).
- [resumo] é um resumo curto da tarefa, separando por hífens.

o local onde o arquivo deve ser criado é no diretório .amazonq/tasks/doing
- Antes de iniciar uma tarefa, voce deve verificar se a tarefa não foi iniciada ainda, lendo todos os arquivos do diretório .amazonq/tasks/doing e .amazonq/tasks/done e verificar se está na branch ia_main, se nao estiver, va para a branch ia_main.
- Toda tarefa criada deve ser iniciada na branch criada a partir da ia_main.
- Voce tambem devera gerenciar o estado desses arquivos criados, quando uma tarefa for concluida, voce deve mover o arquivo para a pasta .amazonq/tasks/done.
- Ao concluir a tarefa, deve efetuar o commit e subir a branch para o repositório, sempre usando git.
- Abrir PR com gh pr create --base ia_main --head feat/025-nome-da-tarefa --title "[025]-[feat]-[resumo]" --body "[descrição da tarefa]"

Sugiro adicionar antes do gh pr create:

- Confirmar que está na branch certa. (git status)
- Verificar se tem arquivos que precisam ser commitados. (git status)
- Se tiver arquivos que precisam ser commitados, fazer o commit. (git add . && git commit -m "Commit [025]-[feat]-[resumo]")
- Fazer o push da branch. (git push origin [feat/025-nome-da-tarefa])

O arquivo deve ter o seguinte formato:

# [025]-[feat]-[resumo].md

## Descrição

[descrição da tarefa]

## Critérios de aceitação

- [critério de aceitação 1]
- [critério de aceitação 2]
- [critério de aceitação 3]