using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using PoC_Vit.Blazor.Models;

namespace PoC_Vit.Blazor.Services;

public class ApiClient
{
    private readonly HttpClient _http;
    private static readonly JsonSerializerOptions _json = new() { PropertyNameCaseInsensitive = true };

    public ApiClient(HttpClient http)
    {
        _http = http;
    }

    public async Task<string> SendChatAsync(string message, Guid conversationId = default)
    {
        try
        {
            var request = new ChatRequest
            {
                Message = message,
                ConversationId = conversationId
            };

            Console.WriteLine($"🔹 Enviando mensaje al chat: {message}");
            Console.WriteLine($"🔹 ConversationId: {conversationId}");

            var response = await _http.PostAsJsonAsync("chat", request);
            
            Console.WriteLine($"🔹 Status de respuesta: {response.StatusCode}");

            if (!response.IsSuccessStatusCode)
            {
                var errorContent = await response.Content.ReadAsStringAsync();
                Console.WriteLine($"❌ Error del servidor: {errorContent}");
                return $"Error del servidor ({response.StatusCode}): {errorContent}";
            }

            // Leer el contenido raw para debugging
            var rawContent = await response.Content.ReadAsStringAsync();
            Console.WriteLine($"🔹 Contenido raw de la respuesta: {rawContent}");
            
            var result = JsonSerializer.Deserialize<ChatResponse>(rawContent, _json);
            
            Console.WriteLine($"🔹 Result es null: {result == null}");
            Console.WriteLine($"🔹 Result.Answer: {result?.Answer ?? "(null)"}");
            Console.WriteLine($"🔹 Longitud del Answer: {result?.Answer?.Length ?? 0} caracteres");
            
            // Si la respuesta está vacía, devolver un mensaje informativo
            if (string.IsNullOrEmpty(result?.Answer))
            {
                Console.WriteLine("⚠️ El modelo devolvió una respuesta vacía");
                return ""; // Devolver vacío para que el componente lo maneje
            }
            
            Console.WriteLine($"✅ Devolviendo respuesta: {result.Answer}");
            return result.Answer;
        }
        catch (HttpRequestException ex)
        {
            Console.WriteLine($"❌ Error de conexión: {ex.Message}");
            return $"Error de conexión: No se pudo conectar con la API. Verifica que Docker esté ejecutándose.";
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Error inesperado: {ex.Message}");
            Console.WriteLine($"❌ StackTrace: {ex.StackTrace}");
            return $"Error: {ex.Message}";
        }
    }

    public async Task<List<Professional>> SearchProfessionalsAsync(string plan, string specialty, string city)
    {
        try
        {
            var query = $"professionals?plan={Uri.EscapeDataString(plan)}&specialty={Uri.EscapeDataString(specialty)}&city={Uri.EscapeDataString(city)}";
            var response = await _http.GetFromJsonAsync<List<Professional>>(query);
            return response ?? new List<Professional>();
        }
        catch (Exception)
        {
            return new List<Professional>();
        }
    }

    public async Task<(bool success, AppointmentResponse? response, string error)> CreateAppointmentAsync(AppointmentRequest req)
    {
        try
        {
            var response = await _http.PostAsJsonAsync("appointments", req);
            
            if (response.IsSuccessStatusCode)
            {
                var result = await response.Content.ReadFromJsonAsync<AppointmentResponse>();
                return (true, result, "");
            }
            else
            {
                var errorContent = await response.Content.ReadAsStringAsync();
                return (false, null, $"Error {response.StatusCode}: {errorContent}");
            }
        }
        catch (Exception ex)
        {
            return (false, null, ex.Message);
        }
    }

    public async Task<List<AppointmentSummary>> GetAppointmentsAsync(string bookedBy)
    {
        try
        {
            var response = await _http.GetFromJsonAsync<List<AppointmentSummary>>($"appointments?bookedBy={Uri.EscapeDataString(bookedBy)}");
            return response ?? new List<AppointmentSummary>();
        }
        catch (Exception)
        {
            return new List<AppointmentSummary>();
        }
    }

    public async Task<bool> DeleteAppointmentAsync(long id)
    {
        try
        {
            var response = await _http.DeleteAsync($"appointments/{id}");
            return response.IsSuccessStatusCode;
        }
        catch (Exception)
        {
            return false;
        }
    }

    public async Task<(long documentId, int chunks)> IngestTextAsync(string title, string content, string type = "faq")
    {
        var payload = JsonSerializer.Serialize(new { title, content, type });
        var res = await _http.PostAsync("ingest/text",
            new StringContent(payload, Encoding.UTF8, "application/json"));

        var body = await res.Content.ReadAsStringAsync();
        if (!res.IsSuccessStatusCode)
            throw new Exception($"ingest/text {res.StatusCode}: {body}");

        using var doc = JsonDocument.Parse(body);
        var id = doc.RootElement.GetProperty("documentId").GetInt64();
        var chunks = doc.RootElement.GetProperty("chunks").GetInt32();
        return (id, chunks);
    }

    public async Task<List<DocumentSummary>> GetDocumentsAsync()
    {
        try
        {
            var response = await _http.GetFromJsonAsync<List<DocumentSummary>>("knowledge/documents");
            return response ?? new List<DocumentSummary>();
        }
        catch (Exception)
        {
            return new List<DocumentSummary>();
        }
    }

    public async Task<bool> DeleteDocumentAsync(long id)
    {
        try
        {
            var response = await _http.DeleteAsync($"knowledge/documents/{id}");
            return response.IsSuccessStatusCode;
        }
        catch (Exception)
        {
            return false;
        }
    }
}

