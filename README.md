## Projeto base para o evento Bootcamp Imersão AWS que irei realizar.

### Período do evento: 05 a 11 de Agosto/2024 (Online e ao Vivo às 20h)

[>> Página de Inscrição do evento](https://org.imersaoaws.com.br/github/readme)

#### Adicionar as dependências ####
.NET.Sdk 8.0
Microsoft.EntityFrameworkCore
Microsoft.EntityFrameworkCore.Design
Npgsql.EntityFrameworkCore.PostgreSQL

#### Para criar o container ####
# Guia de Uso do Docker

Este guia fornece instruções sobre como construir e gerenciar imagens Docker usando o Docker CLI. Docker é uma plataforma que permite criar, implantar e executar aplicativos em contêineres.

## Pré-requisitos

1. **Docker**: Certifique-se de que o Docker está instalado no seu sistema. Você pode baixar e instalar o Docker Desktop [aqui](https://www.docker.com/products/docker-desktop) para Windows e macOS, ou seguir as instruções de instalação para Linux [aqui](https://docs.docker.com/engine/install/).

2. **Docker Compose** (opcional): Se o seu projeto usar `docker-compose`, você pode instalar o Docker Compose [aqui](https://docs.docker.com/compose/install/).

## Estrutura do Projeto

Certifique-se de que seu projeto inclui um arquivo `Dockerfile`, que define como a imagem Docker deve ser construída. Exemplo básico de um `Dockerfile`:



#### Para subir os serviços ####
docker-compose up -d

#### Para rodar as migrations no container ####


```

# Gerenciamento de Migrações com Entity Framework Core (EF Core)

Este documento fornece uma visão geral sobre como utilizar as migrações do Entity Framework Core em um projeto .NET. As migrações são uma ferramenta essencial para gerenciar mudanças no esquema do banco de dados ao longo do ciclo de vida do desenvolvimento.

## Pré-requisitos

1. **.NET SDK**: Certifique-se de que o SDK do .NET está instalado. Você pode baixar a versão mais recente [aqui](https://dotnet.microsoft.com/download).

2. **Entity Framework Core Tools**: As ferramentas EF Core devem estar instaladas. Para instalá-las globalmente, use o comando:
   ```bash
   dotnet tool install --global dotnet-ef

3. Comandos
dotnet ef migrations add InitialCreate --context MeuDbContext
dotnet ef database update --context MeuDbContext