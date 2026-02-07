# PoC Vit - Blazor WebAssembly

Sistema de gestión de salud desarrollado en Blazor WebAssembly (.NET 9) con integración a backend API.

## 🚀 Características

- **Chat con IA**: Asistente virtual impulsado por Ollama para consultas sobre la obra social
- **Búsqueda de Profesionales**: Sistema de búsqueda por plan, especialidad y ciudad
- **Gestión de Turnos**: Creación y reserva de citas médicas
- **UI Moderna**: Interfaz basada en Radzen.Blazor con diseño responsive
- **Integración API**: Conexión directa con backend .NET 9

## 📋 Requisitos

- .NET 9 SDK
- Backend API corriendo en `http://localhost/api/`
- Docker (para ejecutar el stack completo con docker-compose)

## 🛠️ Instalación

```bash
# Restaurar paquetes
dotnet restore

# Compilar el proyecto
dotnet build

# Ejecutar en modo desarrollo
dotnet run
```

## 🌐 Ejecución

### Modo desarrollo local
```bash
dotnet watch run
```

La aplicación se abrirá en `http://localhost:5000` (o el puerto que configure el sistema).

### Con Docker (Stack completo)
Desde la raíz del proyecto:
```bash
docker-compose up
```

## 📁 Estructura del Proyecto

```
PoC_Vit.Blazor/
├── Models/              # Modelos de datos
│   ├── Professional.cs
│   ├── AppointmentRequest.cs
│   ├── AppointmentResponse.cs
│   ├── ChatRequest.cs
│   └── ChatResponse.cs
├── Services/            # Servicios de la aplicación
│   └── ApiClient.cs     # Cliente HTTP para el backend
├── Pages/               # Páginas Razor
│   ├── Home.razor       # Página de inicio
│   ├── Chat.razor       # Chat con asistente
│   ├── Professionals.razor  # Búsqueda de profesionales
│   └── Appointments.razor   # Gestión de turnos
├── Layout/              # Layouts y navegación
│   ├── MainLayout.razor
│   └── NavMenu.razor
└── wwwroot/             # Archivos estáticos
```

## 🔧 Configuración

### HttpClient Base URL
El cliente HTTP está configurado en `Program.cs` para conectarse al backend:

```csharp
builder.Services.AddScoped(sp => 
    new HttpClient { BaseAddress = new Uri("http://localhost/api/") });
```

Para cambiar la URL del backend, modifica esta línea en `Program.cs`.

## 📚 Endpoints Utilizados

- `POST /api/chat` - Envío de mensajes al asistente
- `GET /api/professionals` - Búsqueda de profesionales
- `POST /api/appointments` - Creación de turnos

## 🎨 Componentes Radzen

El proyecto utiliza [Radzen.Blazor](https://blazor.radzen.com/) para los componentes de UI:

- RadzenCard
- RadzenButton
- RadzenTextBox
- RadzenTextArea
- RadzenDataGrid
- RadzenDatePicker
- RadzenNumeric
- RadzenAlert
- RadzenProgressBarCircular

## 🧪 Pruebas

1. **Chat**: Navega a `/chat` y envía un mensaje para verificar la conexión con Ollama
2. **Profesionales**: Busca por plan, especialidad o ciudad (ej: plan="PLAN_300", specialty="Cardio")
3. **Turnos**: Crea un turno ingresando ID de profesional, fecha, hora y datos del paciente

## 📝 Notas

- La aplicación requiere que el backend esté corriendo y accesible
- Los colores principales son Indigo/Blue (#5A67D8, #667EEA)
- La interfaz es completamente responsive (mobile-first)
- Todos los textos están en español

## 🐛 Solución de Problemas

### Error de conexión al backend
Verifica que:
1. El backend API esté corriendo
2. La URL en `Program.cs` sea correcta
3. No haya problemas de CORS en el backend

### Componentes Radzen no se muestran
Asegúrate de que:
1. El paquete Radzen.Blazor esté instalado
2. Los estilos CSS estén referenciados en `index.html`
3. `RadzenComponents` esté agregado en `MainLayout.razor`

## 📄 Licencia

PoC - Prueba de Concepto

