FROM mcr.microsoft.com/playwright/dotnet:v1.40.0-jammy AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
# Nota la ruta: PriceScraperApi/PriceScraperApi.csproj
COPY ["PriceScraperApi/PriceScraperApi.csproj", "PriceScraperApi/"]
RUN dotnet restore "PriceScraperApi/PriceScraperApi.csproj"
COPY . .
WORKDIR "/src/PriceScraperApi"
RUN dotnet build "PriceScraperApi.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "PriceScraperApi.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENV PW_BROWSERS_PATH=/ms-playwright
ENV ASPNETCORE_URLS=http://+:8080
ENTRYPOINT ["dotnet", "PriceScraperApi.dll"]