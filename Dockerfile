FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app
COPY . .

RUN dotnet tool install --global dotnet-ef
ENV PATH="$PATH:/root/.dotnet/tools"

RUN dotnet restore
RUN dotnet build -c Release -o out

EXPOSE 8080
EXPOSE 443

CMD ["dotnet", "out/Bia.dll"]
