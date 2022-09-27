## Projeto base para o evento Bootcamp Imersão AWS com Docker que irei realizar.

### Período do evento: 10 a 16 de Outubro/2022 (Online e ao vivo às 20h)

[>> Página de Inscrição do evento](https://inscricao.imersaoaws.com.br)


#### Para rodar as migrations no container ####
```
docker-compose exec server bash -c 'npx sequelize db:migrate'
```