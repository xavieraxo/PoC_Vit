using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using PoC_Vit.Blazor;
using PoC_Vit.Blazor.Services;
using Radzen;
using Microsoft.AspNetCore.Components.Authorization;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");

// Configurar HttpClient base para conectar al backend
// Intenta obtener la URL de configuración, si no existe usa la URL local de desarrollo
var apiBaseUrl = builder.Configuration["ApiBaseUrl"];

if (string.IsNullOrEmpty(apiBaseUrl))
{
    // Detectar si estamos en Docker (hostname contiene el puerto de Docker) o local
    var hostName = builder.HostEnvironment.BaseAddress;
    
    if (hostName.Contains("localhost:5137") || hostName.Contains("localhost:7130"))
    {
        // Desarrollo local - conectar a la API local
        apiBaseUrl = "http://localhost:52848/api/";
        Console.WriteLine($"🔧 Modo DESARROLLO LOCAL: Conectando a {apiBaseUrl}");
    }
    else
    {
        // Docker o producción - construir URL absoluta basada en el host
        var baseUri = new Uri(builder.HostEnvironment.BaseAddress);
        apiBaseUrl = new Uri(baseUri, "api/").ToString();
        Console.WriteLine($"🐳 Modo DOCKER/PRODUCCIÓN: Conectando a {apiBaseUrl}");
    }
}
else
{
    Console.WriteLine($"⚙️ URL configurada: {apiBaseUrl}");
}

builder.Services.AddScoped(sp => new HttpClient { BaseAddress = new Uri(apiBaseUrl) });

// Registrar ApiClient
builder.Services.AddScoped<ApiClient>();

// Agregar servicios de Radzen
builder.Services.AddRadzenComponents();

// Autenticación — deshabilitado temporalmente, se restaurará cuando se corrija el login
// builder.Services.AddAuthorizationCore();
// builder.Services.AddScoped<AuthenticationStateProvider, CustomAuthStateProvider>();
// builder.Services.AddScoped<AuthService>();

await builder.Build().RunAsync();
