﻿## Projeto base para o evento Bootcamp Imersão AWS que irei realizar.

### Período do evento: 05 a 11 de Agosto/2024 (Online e ao Vivo às 20h)

[>> Página de Inscrição do evento](https://org.imersaoaws.com.br/github/readme)

#### Adicionar as dependências VisualStudio ####
.NET.Sdk 8.0
Microsoft.EntityFrameworkCore
Microsoft.EntityFrameworkCore.Design
Npgsql.EntityFrameworkCore.PostgreSQL

#### Para criar o container ####

docker-compose up -d

#### Migrations Create ####

docker exec -it id_container dotnet ef migrations add InitilCreate

#### Migrations Update ####

docker exec -it id_container dotnet ef database update