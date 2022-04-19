## Projeto base para o evento Bootcamp Imersão AWS com Docker que irei realizar no meu canal do Youtube.

### Período do evento: 02 a 05 de Maio/2022 (Online e ao vivo às 20h)

[>> Página de Inscrição do evento](https://inscricao.imersaoaws.com.br)


#### Para rodar as migrations no container ####
```
docker-compose exec server bash -c 'npx sequelize db:migrate'
```