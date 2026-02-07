FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copiar csproj y restaurar dependencias
COPY ["PoC_Vit.Blazor.csproj", "./"]
RUN dotnet restore

# Copiar todo el código y publicar
COPY . .
RUN dotnet publish -c Release -o /app/publish

# Imagen final con Nginx
FROM nginx:alpine
COPY --from=build /app/publish/wwwroot /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 8080

