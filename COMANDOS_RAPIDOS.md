# 🚀 Comandos Rápidos - PoC Vit Blazor

## 📦 Compilar todo el proyecto

```powershell
cd E:\Proyectos\PoC_Vit
dotnet build
```

---

## 🐳 Ejecutar con Docker (Stack Completo)

### Levantar todos los servicios
```powershell
cd E:\Proyectos\PoC_Vit
docker-compose up --build
```

### Ver logs en tiempo real
```powershell
# Todos los servicios
docker-compose logs -f

# Solo Blazor
docker logs poc_blazor -f

# Solo API
docker logs -f poc_api

# Solo Ollama
docker logs poc_ollama -f
```

### Detener servicios
```powershell
docker-compose down
```

### Limpiar y reconstruir
```powershell
docker-compose down -v
docker-compose up --build
```

---

## 💻 Ejecutar en Modo Desarrollo Local

### Terminal 1: Blazor
```powershell
cd E:\Proyectos\PoC_Vit\src\PoC_Vit.Blazor
dotnet watch run
```

La aplicación se abrirá automáticamente en el navegador (normalmente `https://localhost:5001`).

### Terminal 2: Verificar API (si está en Docker)
```powershell
# Health check
curl http://localhost/api/health

# Ver rutas disponibles
curl http://localhost/api/_routes

# Test de Ollama
curl http://localhost/api/ollama/tags
```

---

## 🧪 Probar Endpoints desde PowerShell

### 1. Test de Chat
```powershell
$body = @{
    message = "Hola, ¿qué planes médicos ofrecen?"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost/api/chat" -Method POST -Body $body -ContentType "application/json"
```

### 2. Buscar Profesionales
```powershell
# Todos
Invoke-RestMethod -Uri "http://localhost/api/professionals"

# Con filtros
Invoke-RestMethod -Uri "http://localhost/api/professionals?plan=PLAN_300&specialty=Cardio&city=Buenos"
```

### 3. Crear Turno
```powershell
$turno = @{
    professionalId = 1
    startUtc = "2025-10-15T10:00:00Z"
    bookedBy = "dni:12345678"
    notes = "Consulta de control"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost/api/appointments" -Method POST -Body $turno -ContentType "application/json"
```

---

## 🔍 Verificar Estado de Servicios

### Listar contenedores corriendo
```powershell
docker ps
```

### Verificar red
```powershell
docker network inspect poc_net
```

### Verificar base de datos
```powershell
docker exec -it poc_db psql -U app -d salud_poc -c "\dt"
```

### Verificar modelos de Ollama
```powershell
docker exec poc_ollama ollama list
```

### Descargar modelo si no está (ejemplo: mistral)
```powershell
docker exec poc_ollama ollama pull mistral:7b-instruct
```

---

## 🌐 URLs de Acceso

Una vez que todo esté corriendo:

| Servicio | URL | Descripción |
|----------|-----|-------------|
| **Blazor App** | http://localhost | Interfaz web principal |
| **API Health** | http://localhost/api/health | Health check del backend |
| **API Routes** | http://localhost/api/_routes | Lista de endpoints disponibles |
| **Traefik Dashboard** | http://localhost:8080/dashboard/ | (si está configurado) |
| **PostgreSQL** | localhost:5432 | Base de datos |
| **Ollama API** | localhost:11434 | API de Ollama |

---

## 🛠️ Solución Rápida de Problemas

### Problema: No se conecta al backend
```powershell
# Verificar que la API esté corriendo
docker ps | Select-String "poc_api"

# Ver logs de la API
docker logs -f poc_api

# Verificar salud
curl http://localhost/api/health
```

### Problema: Ollama no responde
```powershell
# Verificar estado
docker exec poc_ollama ollama list

# Ver logs
docker logs poc_ollama -f

# Reiniciar solo Ollama
docker restart poc_ollama
```

### Problema: Base de datos no inicia
```powershell
# Ver logs
docker logs poc_db

# Verificar salud
docker exec poc_db pg_isready -U app -d salud_poc
```

### Problema: Blazor no compila
```powershell
# Limpiar y reconstruir
cd E:\Proyectos\PoC_Vit\src\PoC_Vit.Blazor
dotnet clean
dotnet restore
dotnet build
```

### Problema: Puerto ya en uso
```powershell
# Ver qué proceso usa el puerto 80
netstat -ano | Select-String ":80 "

# Detener servicios Docker
docker-compose down

# Cambiar puerto en docker-compose.yml si es necesario
```

---

## 📊 Comandos de Diagnóstico

### Ver uso de recursos
```powershell
docker stats
```

### Inspeccionar un contenedor
```powershell
docker inspect poc_blazor
docker inspect poc_api
```

### Ejecutar comando dentro del contenedor
```powershell
# Bash en contenedor
docker exec -it poc_blazor sh

# Ver archivos publicados
docker exec poc_blazor ls -la /usr/share/nginx/html
```

### Verificar conectividad entre servicios
```powershell
# Desde API hacia Ollama
docker exec poc_api curl http://ollama:11434/api/tags

# Desde API hacia DB
docker exec poc_api ping db
```

---

## 🎯 Flujo de Trabajo Típico

### Primera vez
```powershell
cd E:\Proyectos\PoC_Vit
docker-compose up --build
# Esperar a que todo inicie...
# Abrir navegador en http://localhost
```

### Día a día (desarrollo)
```powershell
# Terminal 1: Mantener backend en Docker
cd E:\Proyectos\PoC_Vit
docker-compose up db ollama api

# Terminal 2: Desarrollo de Blazor
cd src\PoC_Vit.Blazor
dotnet watch run
```

### Antes de hacer commit
```powershell
# Compilar todo
dotnet build

# Verificar linting (si tienes configurado)
dotnet format --verify-no-changes
```

---

## 📝 Notas Importantes

- El primer `docker-compose up` puede tardar varios minutos (descarga imágenes)
- Ollama puede tardar en descargar el modelo la primera vez
- Si cambias código del backend o Blazor, usa `--build` al hacer `docker-compose up`
- Los datos de la DB persisten en volúmenes Docker (para limpiar: `docker-compose down -v`)

---

## 🔗 Referencias Útiles

- **Documentación Blazor**: https://learn.microsoft.com/aspnet/core/blazor/
- **Radzen Components**: https://blazor.radzen.com/
- **Ollama API**: https://github.com/ollama/ollama/blob/main/docs/api.md
- **Docker Compose**: https://docs.docker.com/compose/

---

¡Con estos comandos deberías poder trabajar cómodamente con el proyecto! 🚀

