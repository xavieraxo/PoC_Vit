# Instrucciones para Ejecutar PoC Vit - Blazor

## 📋 Resumen del Proyecto

Se ha creado un proyecto Blazor WebAssembly (.NET 9) integrado con el backend API existente, que incluye:

- **Chat con IA**: Interfaz de chat tipo burbuja para interactuar con el asistente Ollama
- **Búsqueda de Profesionales**: Formulario de búsqueda con tabla de resultados
- **Gestión de Turnos**: Formulario para crear turnos médicos
- **UI Moderna**: Basada en Radzen.Blazor con colores Indigo/Blue (#5A67D8, #667EEA)

## 🚀 Opción 1: Ejecutar con Docker (Recomendado)

### Paso 1: Agregar el servicio Blazor al docker-compose.yml

Agrega el siguiente servicio al archivo `docker-compose.yml`:

```yaml
  blazor:
    build: ./src/PoC_Vit.Blazor
    container_name: poc_blazor
    expose:
      - "8080"
    networks: [poc_net]
    restart: unless-stopped
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.blazor.rule=PathPrefix(`/`)"
      - "traefik.http.routers.blazor.entrypoints=web"
      - "traefik.http.services.blazor.loadbalancer.server.port=8080"
```

### Paso 2: Crear Dockerfile para Blazor

Crea el archivo `src/PoC_Vit.Blazor/Dockerfile`:

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

COPY ["PoC_Vit.Blazor.csproj", "./"]
RUN dotnet restore

COPY . .
RUN dotnet publish -c Release -o /app/publish

FROM nginx:alpine
COPY --from=build /app/publish/wwwroot /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 8080
```

### Paso 3: Crear archivo nginx.conf

Crea el archivo `src/PoC_Vit.Blazor/nginx.conf`:

```nginx
events { }
http {
    include mime.types;
    types {
        application/wasm wasm;
    }

    server {
        listen 8080;
        
        location / {
            root /usr/share/nginx/html;
            try_files $uri $uri/ /index.html =404;
        }
    }
}
```

### Paso 4: Ejecutar el stack completo

```bash
docker-compose up --build
```

Accede a la aplicación en: `http://localhost` (puerto 80 por defecto)

---

## 🛠️ Opción 2: Ejecutar en Modo Desarrollo Local

### Requisitos previos
- .NET 9 SDK instalado
- Backend API corriendo (vía Docker o local)

### Paso 1: Navegar al proyecto Blazor

```bash
cd src/PoC_Vit.Blazor
```

### Paso 2: Restaurar paquetes (si no se hizo antes)

```bash
dotnet restore
```

### Paso 3: Ejecutar en modo desarrollo

```bash
dotnet watch run
```

o simplemente:

```bash
dotnet run
```

La aplicación se abrirá automáticamente en el navegador (generalmente `https://localhost:5001` o `http://localhost:5000`).

### Nota importante sobre CORS

Si ejecutas Blazor localmente y el backend en Docker, necesitarás configurar CORS en el backend. Agrega en `src/Api/Program.cs`:

```csharp
// Después de var builder = WebApplication.CreateBuilder(args);
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowBlazor", policy =>
    {
        policy.WithOrigins("http://localhost:5000", "https://localhost:5001")
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

// Antes de app.Run();
app.UseCors("AllowBlazor");
```

---

## 🧪 Verificación de Funcionalidades

### 1. Chat
1. Navega a la página "Chat" desde el menú
2. Escribe un mensaje (ej: "¿Qué planes médicos ofrecen?")
3. Haz clic en "Enviar" o presiona Enter
4. Verifica que aparezca la respuesta del asistente Ollama

**Endpoint usado**: `POST http://localhost/api/chat`

### 2. Profesionales
1. Ve a "Profesionales"
2. Ingresa criterios de búsqueda:
   - Plan: `PLAN_300` (o vacío para todos)
   - Especialidad: `Cardio` (o vacío)
   - Ciudad: `Buenos` (o vacío)
3. Haz clic en "Buscar"
4. Verifica que se muestren resultados en la tabla

**Endpoint usado**: `GET http://localhost/api/professionals?plan=PLAN_300&specialty=Cardio&city=Buenos`

### 3. Turnos
1. Navega a "Turnos"
2. Completa el formulario:
   - ID Profesional: `1` (o el ID de un profesional existente)
   - Fecha: selecciona una fecha futura
   - Hora: selecciona una hora
   - Paciente: `dni:12345678`
   - Notas: `control general` (opcional)
3. Haz clic en "Crear Turno"
4. Verifica el mensaje de confirmación con el ID del turno y fecha de creación

**Endpoint usado**: `POST http://localhost/api/appointments`

---

## 📁 Estructura Creada

```
src/PoC_Vit.Blazor/
├── Models/
│   ├── Professional.cs
│   ├── AppointmentRequest.cs
│   ├── AppointmentResponse.cs
│   ├── ChatRequest.cs
│   └── ChatResponse.cs
├── Services/
│   └── ApiClient.cs
├── Pages/
│   ├── Home.razor          (página de inicio con cards)
│   ├── Chat.razor          (chat con burbujas)
│   ├── Professionals.razor (búsqueda + tabla)
│   └── Appointments.razor  (formulario de turnos)
├── Layout/
│   ├── MainLayout.razor    (con RadzenComponents)
│   └── NavMenu.razor       (menú actualizado)
├── wwwroot/
│   ├── css/
│   │   └── custom.css      (estilos personalizados)
│   └── index.html          (con referencias a Radzen)
├── Program.cs              (configuración de servicios)
├── _Imports.razor          (importaciones globales)
└── README.md               (documentación del proyecto)
```

---

## 🎨 Características Implementadas

### Diseño
- ✅ Colores principales: #5A67D8 y #667EEA (Indigo/Blue)
- ✅ Interfaz responsive con Radzen.Blazor
- ✅ Burbujas de chat (izquierda usuario, derecha asistente)
- ✅ Cards con hover effects
- ✅ Spinners de carga durante peticiones

### Funcionalidades
- ✅ Chat persistente con conversationId
- ✅ Búsqueda de profesionales con filtros
- ✅ Creación de turnos con validaciones
- ✅ Mensajes de confirmación/error
- ✅ Tabla paginada con RadzenDataGrid
- ✅ DatePicker + TimePicker para turnos

### Extras Implementados
- ✅ Spinner de carga en todas las páginas
- ✅ Colores suaves Indigo/Blue
- ✅ Fecha de creación del turno en confirmación
- ✅ Página de inicio con cards navegables
- ✅ Estilos CSS personalizados
- ✅ README completo del proyecto

---

## 🐛 Solución de Problemas

### El chat no responde
- Verifica que Ollama esté corriendo: `docker ps | grep ollama`
- Verifica que el modelo esté descargado: `docker exec poc_ollama ollama list`
- Revisa los logs del backend: `docker logs poc_api -f`

### No aparecen profesionales
- Verifica que la base de datos tenga datos de prueba
- Revisa el endpoint: `curl "http://localhost/api/professionals"`
- Verifica la conexión a PostgreSQL

### Error al crear turno
- Asegúrate de que exista el profesional con el ID ingresado
- Verifica que haya slots disponibles para esa fecha/hora
- Revisa los logs del backend

### Estilos de Radzen no cargan
- Verifica que `_content/Radzen.Blazor/css/material-base.css` esté accesible
- Limpia y reconstruye: `dotnet clean && dotnet build`
- Verifica que el paquete Radzen.Blazor esté instalado: `dotnet list package`

---

## 📞 Endpoints del Backend

El frontend consume estos endpoints:

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/api/chat` | Envío de mensajes al asistente |
| GET | `/api/professionals` | Búsqueda de profesionales (query params: plan, specialty, city) |
| POST | `/api/appointments` | Creación de turnos |
| GET | `/api/health` | Health check del backend |

---

## ✅ Checklist de Verificación

- [ ] Backend API corriendo en `http://localhost/api/`
- [ ] Base de datos PostgreSQL con datos de prueba
- [ ] Ollama corriendo con modelo cargado
- [ ] Blazor compilando sin errores (`dotnet build`)
- [ ] Navegación entre páginas funciona
- [ ] Chat devuelve respuestas
- [ ] Búsqueda de profesionales retorna datos
- [ ] Creación de turnos retorna confirmación

---

## 🎯 Próximos Pasos (Opcional)

- Agregar autenticación de usuarios
- Implementar listado de turnos existentes
- Agregar filtros avanzados en profesionales
- Implementar historial de chat
- Agregar tests unitarios
- Configurar CI/CD para despliegue automático

---

**¡El proyecto está listo para usar!** 🎉

Para cualquier consulta, revisa el README en `src/PoC_Vit.Blazor/README.md` o los logs de los contenedores Docker.

