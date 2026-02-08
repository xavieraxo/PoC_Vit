using System.Net.Http.Json;
using System.Text.Json;
using Npgsql;
using Microsoft.AspNetCore.Mvc;
using NpgsqlTypes;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using System.Security.Claims;
using System.IdentityModel.Tokens.Jwt;
using BCrypt.Net;
using StackExchange.Redis;


// ===================== Config / Setup =====================
var builder = WebApplication.CreateBuilder(args);

// Ollama
var ollamaBaseUrl = builder.Configuration["AI:Ollama:BaseUrl"] ?? "http://ollama:11434";
var modelName     = builder.Configuration["AI:ModelName"]       ?? "mistral:7b-instruct";

// DB
var connString = builder.Configuration.GetConnectionString("Default")
                 ?? "Host=db;Port=5432;Username=app;Password=app123;Database=salud_poc;Ssl Mode=Disable";

// Servicios
builder.Services.AddEndpointsApiExplorer();

// JWT Config
var jwtKey = builder.Configuration["JWT:Key"] ?? "super_secret_key_poc_vit_2025_long_enough";
var jwtIssuer = builder.Configuration["JWT:Issuer"] ?? "PoC_Vit";

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtIssuer,
            ValidAudience = jwtIssuer,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
        };
    });

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("AdminOnly", policy => policy.RequireRole("Admin"));
});

// Configurar CORS para permitir peticiones desde Blazor
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowBlazor", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

builder.Services.AddHttpClient<IOllamaClient, OllamaClient>(client =>
{
    client.BaseAddress = new Uri(ollamaBaseUrl);
});
builder.Services.AddSingleton(new OllamaSettings { Model = modelName });

builder.Services.AddSingleton<NpgsqlDataSource>(_ =>
{
    var b = new NpgsqlDataSourceBuilder(connString);
    return b.Build();
});

// Notificaciones (Mock)
builder.Services.AddSingleton<INotificationService, MockNotificationService>();

// Redis Caching
var redisConnString = builder.Configuration.GetConnectionString("Redis") ?? "localhost:6379";
try {
    var redis = ConnectionMultiplexer.Connect(redisConnString);
    builder.Services.AddSingleton<IConnectionMultiplexer>(redis);
    builder.Services.AddSingleton<ICacheService, RedisCacheService>();
} catch {
    // Si Redis no está disponible (ej: desarrollo local sin docker), usar mock en memoria
    builder.Services.AddSingleton<ICacheService, InMemoryCacheService>();
}

var app = builder.Build();

// Habilitar CORS
app.UseCors("AllowBlazor");

app.UseAuthentication();
app.UseAuthorization();

// ===================== Endpoints base =====================
app.MapGet("/api/health", () => Results.Ok(new { status = "ok", timestamp = DateTime.UtcNow }));

// Diagnóstico conexión API → Ollama
app.MapGet("/api/ollama/tags", async (IOllamaClient ollamaClient) =>
{
    using var http = new HttpClient { BaseAddress = new Uri(ollamaClient.BaseUrl()) };
    var res = await http.GetAsync("/api/tags");
    var text = await res.Content.ReadAsStringAsync();
    return Results.Content(text, "application/json");
});

app.MapGet("/api/professionals", async (
    [FromQuery] string? plan,
    [FromQuery] string? specialty,
    [FromQuery] string? city,
    NpgsqlDataSource db) =>
{
    var planP = plan ?? string.Empty;
    var specP = specialty ?? string.Empty;
    var cityP = city ?? string.Empty;

    const string sql = @"
      SELECT DISTINCT p.id, p.name, p.specialty, p.city, p.address
      FROM professionals p
      LEFT JOIN professional_plans pp ON pp.professional_id = p.id
      LEFT JOIN plans pl ON pl.id = pp.plan_id
      WHERE (@plan = '' OR pl.code = @plan)
        AND (@spec = '' OR p.specialty ILIKE '%' || @spec || '%')
        AND (@city = '' OR p.city ILIKE '%' || @city || '%')
      ORDER BY p.name
      LIMIT 200";

    try
    {
        await using var conn = await db.OpenConnectionAsync();
        await using var cmd = new NpgsqlCommand(sql, conn);

        // Tipamos explícitamente como TEXT para evitar ambigüedad con NULL
        cmd.Parameters.Add("plan", NpgsqlDbType.Text).Value = planP;
        cmd.Parameters.Add("spec", NpgsqlDbType.Text).Value = specP;
        cmd.Parameters.Add("city", NpgsqlDbType.Text).Value = cityP;

        var list = new List<object>();
        await using var rd = await cmd.ExecuteReaderAsync();
        while (await rd.ReadAsync())
        {
            list.Add(new {
                id        = rd.GetInt64(0),
                name      = rd.GetString(1),
                specialty = rd.GetString(2),
                city      = rd.GetString(3),
                address   = rd.GetString(4)
            });
        }

        return Results.Ok(list);
    }
    catch (Exception ex)
    {
        // Mientras depuramos, devolvemos detalle para ver el problema
        return Results.Problem(title: "Error en /api/professionals", detail: ex.Message, statusCode: 500);
    }
})
.WithName("ListProfessionals");

app.MapGet("/api/_routes", (IEnumerable<EndpointDataSource> sources) =>
{
    var routes = sources
        .SelectMany(s => s.Endpoints)
        .OfType<RouteEndpoint>()
        .Select(e => new {
            Route = e.RoutePattern.RawText,
            Methods = string.Join(",", e.Metadata.OfType<HttpMethodMetadata>().FirstOrDefault()?.HttpMethods ?? Array.Empty<string>())
        });
    return Results.Ok(routes);
});

// ===================== Auth =====================

app.MapPost("/api/auth/register", async (RegisterRequest req, NpgsqlDataSource db) =>
{
    if (string.IsNullOrWhiteSpace(req.Username) || string.IsNullOrWhiteSpace(req.Password))
        return Results.BadRequest(new { error = "Username y password requeridos" });

    var hash = BCrypt.Net.BCrypt.HashPassword(req.Password);
    const string sql = "INSERT INTO users(username, password_hash, role, full_name) VALUES(@u, @h, @r, @f) RETURNING id";
    
    try
    {
        await using var conn = await db.OpenConnectionAsync();
        await using var cmd = new NpgsqlCommand(sql, conn);
        cmd.Parameters.AddWithValue("u", req.Username);
        cmd.Parameters.AddWithValue("h", hash);
        cmd.Parameters.AddWithValue("r", req.Role ?? "Patient");
        cmd.Parameters.AddWithValue("f", (object?)req.FullName ?? DBNull.Value);
        
        var id = await cmd.ExecuteScalarAsync();
        return Results.Ok(new { id, message = "Usuario registrado correctamente" });
    }
    catch (Exception ex)
    {
        return Results.BadRequest(new { error = "Usuario ya existe o error en DB", detail = ex.Message });
    }
});

app.MapPost("/api/auth/login", async (LoginRequest req, NpgsqlDataSource db, IConfiguration config) =>
{
    const string sql = "SELECT id, username, password_hash, role, full_name FROM users WHERE username = @u";
    await using var conn = await db.OpenConnectionAsync();
    await using var cmd = new NpgsqlCommand(sql, conn);
    cmd.Parameters.AddWithValue("u", req.Username);
    
    await using var rd = await cmd.ExecuteReaderAsync();
    if (!await rd.ReadAsync()) return Results.Unauthorized();
    
    var hash = rd.GetString(2);
    if (!BCrypt.Net.BCrypt.Verify(req.Password, hash)) return Results.Unauthorized();
    
    var userIdString = rd.GetGuid(0).ToString();
    var username = rd.GetString(1);
    var role = rd.GetString(3);
    
    var claims = new[]
    {
        new Claim(ClaimTypes.NameIdentifier, userIdString),
        new Claim(ClaimTypes.Name, username),
        new Claim(ClaimTypes.Role, role)
    };

    var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));
    var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
    var token = new JwtSecurityToken(
        issuer: jwtIssuer,
        audience: jwtIssuer,
        claims: claims,
        expires: DateTime.Now.AddDays(1),
        signingCredentials: creds
    );

    return Results.Ok(new {
        token = new JwtSecurityTokenHandler().WriteToken(token),
        username = username,
        role = role
    });
});

// Crea conversación y devuelve su id
app.MapPost("/api/conversations", async (NpgsqlDataSource db) =>
{
    var sql = "INSERT INTO conversations DEFAULT VALUES RETURNING id;";
    await using var conn = await db.OpenConnectionAsync();
    await using var cmd = new NpgsqlCommand(sql, conn);
    var id = (Guid)(await cmd.ExecuteScalarAsync() ?? throw new InvalidOperationException("No se pudo crear conversación"));
    return Results.Ok(new { conversationId = id });
});

// ===================== Chat (persistente) =====================

app.MapPost("/api/chat", async (HttpRequest http, IOllamaClient ollama, OllamaSettings settings, NpgsqlDataSource db) =>
{
    ChatRequest? req;
    try
    {
        req = await http.ReadFromJsonAsync<ChatRequest>();
    }
    catch (Exception ex)
    {
        return Results.BadRequest(new { error = "JSON inválido o no UTF-8", detail = ex.Message });
    }

    var msg = req?.Message?.Trim();
    if (string.IsNullOrEmpty(msg))
        return Results.BadRequest(new { error = "message requerido" });

    // Asegurar conversación: usar la enviada o crear una nueva
    var conversationId = req!.ConversationId;
    if (conversationId == Guid.Empty)
    {
        conversationId = await DbHelpers.CreateConversationAsync(db);
    }
    else
    {
        // Verificar que exista
        var exists = await DbHelpers.ConversationExistsAsync(db, conversationId);
        if (!exists) return Results.NotFound(new { error = "conversationId no existe" });
    }

    // Guardar mensaje del usuario
    await DbHelpers.InsertMessageAsync(db, conversationId, "user", msg);

    // Prompt para el modelo
    var system = "Eres un asistente breve y claro. Responde en español.";
    var prompt = $"{system}\n\nUsuario: {msg}\nAsistente:";

    try
    {
        var reply = await ollama.GenerateAsync(new OllamaGenerateRequest
        {
            Model = settings.Model,
            Prompt = prompt,
            Stream = false
        });

        var answer = reply.Response?.Trim() ?? "";

        // Guardar respuesta del asistente
        await DbHelpers.InsertMessageAsync(db, conversationId, "assistant", answer);

        return Results.Ok(new ChatResponse { ConversationId = conversationId, Answer = answer });
    }
    catch (Exception ex)
    {
        return Results.Problem(
            title: "Fallo al invocar Ollama",
            detail: ex.Message,
            statusCode: 502);
    }
});

app.MapPost("/api/ingest/text", async (IngestTextRequest req, NpgsqlDataSource db, IOllamaClient ollama) =>
{
    if (string.IsNullOrWhiteSpace(req.Title) || string.IsNullOrWhiteSpace(req.Content))
        return Results.BadRequest(new { error = "Title y Content son requeridos" });

    // 1) Crear documento
    var docId = await RagHelpers.InsertDocumentAsync(db, req.Title.Trim(), req.SourceUri, req.Type);

    // 2) Chunking
    var chunks = RagHelpers.ChunkText(req.Content, maxChars: 1000, overlap: 200);
    if (chunks.Count == 0) return Results.BadRequest(new { error = "Content vacío tras normalización" });

    // 3) Embeddings por chunk e inserción
    foreach (var (idx, text) in chunks)
    {
        var emb = await RagHelpers.EmbedAsync(new HttpClient(), ollama.BaseUrl(), text);
        await RagHelpers.InsertChunkAsync(db, docId, idx, text, emb);
    }

    // Sugerencia: ANALYZE luego de ingestar lotes grandes
    return Results.Ok(new { documentId = docId, chunks = chunks.Count });
});

app.MapGet("/api/knowledge/documents", async (NpgsqlDataSource db) =>
{
    const string sql = "SELECT id, title, source_uri, type, updated_at FROM documents ORDER BY updated_at DESC";
    try
    {
        await using var conn = await db.OpenConnectionAsync();
        await using var cmd = new NpgsqlCommand(sql, conn);
        var list = new List<object>();
        await using var rd = await cmd.ExecuteReaderAsync();
        while (await rd.ReadAsync())
        {
            list.Add(new {
                id        = rd.GetInt64(0),
                title     = rd.GetString(1),
                sourceUri = rd.IsDBNull(2) ? null : rd.GetString(2),
                type      = rd.IsDBNull(3) ? null : rd.GetString(3),
                updatedAt = rd.GetDateTime(4)
            });
        }
        return Results.Ok(list);
    }
    catch (Exception ex)
    {
        return Results.Problem(title: "Error al listar documentos", detail: ex.Message, statusCode: 500);
    }
});

app.MapDelete("/api/knowledge/documents/{id}", async (long id, NpgsqlDataSource db) =>
{
    // Cascade delete en la BD debería encargarse de los chunks
    const string sql = "DELETE FROM documents WHERE id = @id";
    try
    {
        await using var conn = await db.OpenConnectionAsync();
        await using var cmd = new NpgsqlCommand(sql, conn);
        cmd.Parameters.AddWithValue("id", id);
        var rows = await cmd.ExecuteNonQueryAsync();
        if (rows == 0) return Results.NotFound();
        return Results.Ok(new { message = "Documento y fragmentos eliminados correctamente" });
    }
    catch (Exception ex)
    {
        return Results.Problem(title: "Error al eliminar documento", detail: ex.Message, statusCode: 500);
    }
});

app.MapPost("/api/chat/rag", async (RagChatRequest req, NpgsqlDataSource db, IOllamaClient ollama, OllamaSettings settings, ICacheService cache) =>
{
    var q = req.Message?.Trim();
    if (string.IsNullOrEmpty(q))
        return Results.BadRequest(new { error = "message requerido" });

    // Intentar obtener del caché
    var cacheKey = $"rag:{q.ToLower().GetHashCode()}";
    var cached = await cache.GetAsync(cacheKey);
    if (cached != null) return Results.Ok(JsonSerializer.Deserialize<object>(cached));

    // Asegurar conversación como en /api/chat común
    var conversationId = req.ConversationId;
    if (conversationId == Guid.Empty)
        conversationId = await DbHelpers.CreateConversationAsync(db);
    else if (!await DbHelpers.ConversationExistsAsync(db, conversationId))
        return Results.NotFound(new { error = "conversationId no existe" });

    // Guardar mensaje del usuario
    await DbHelpers.InsertMessageAsync(db, conversationId, "user", q);

    // 1) Embedding de la pregunta
    var qEmb = await RagHelpers.EmbedAsync(new HttpClient(), ollama.BaseUrl(), q);

    // 2) Recuperación por similitud con TOP_K mayor para filtrar después
    var topK = req.TopK <= 0 ? 10 : Math.Min(req.TopK, 20);
    var allHits = await RagHelpers.SearchAsync(db, qEmb, topK);

    // 3) ⭐ NUEVO: Aplicar umbral de confianza (similitud mínima)
    const double MIN_SIMILARITY = 0.80; // Calibrar entre 0.75-0.85
    var hits = allHits.Where(h => (1.0 - h.Score) >= MIN_SIMILARITY).Take(5).ToList();
    
    // Log para calibración
    Console.WriteLine($"🔍 Búsqueda RAG - Total: {allHits.Count}, Después de filtro (>={MIN_SIMILARITY}): {hits.Count}");
    foreach (var h in allHits.Take(5))
    {
        var similarity = 1.0 - h.Score;
        Console.WriteLine($"  📊 Chunk {h.ChunkId}: Similitud={similarity:F3} {(similarity >= MIN_SIMILARITY ? "✅" : "❌")}");
    }

    // 4) Si no hay contexto confiable, responder directamente
    if (hits.Count == 0)
    {
        var noContextAnswer = "No conozco esa respuesta con la información disponible en mi base de conocimientos de SaludPlus.";
        await DbHelpers.InsertMessageAsync(db, conversationId, "assistant", noContextAnswer);
        return Results.Ok(new { conversationId, answer = noContextAnswer, retrieved = 0, items = new List<object>(), threshold = MIN_SIMILARITY });
    }

    // 5) Enriquecer hits con metadatos
    var enriched = new List<object>();
    foreach (var h in hits)
    {
        var (title, source) = await RagHelpers.GetDocumentMetaAsync(db, h.DocumentId);
        enriched.Add(new { 
            h.ChunkId, 
            h.DocumentId, 
            h.Idx, 
            h.Content, 
            Score = h.Score,
            Similarity = 1.0 - h.Score, // Convertir distancia a similitud
            Title = title, 
            Source = source 
        });
    }

    // 6) ⭐ NUEVO: Prompt de sistema con reglas estrictas
    var systemPrompt = @"
Sos un asistente de la obra social SaludPlus.
Reglas estrictas:
- Respondé solo con la información provista en el CONTEXTO.
- Si el contexto no alcanza para responder con seguridad, decí: 'No conozco esa respuesta.'
- No inventes datos, no especules.
- Dominio: cobertura, planes, turnos, autorizaciones, prestadores, contactos de SaludPlus.
- Sé claro y conciso. Si corresponde, mencioná la fuente (p.ej.: 'Según la FAQ SaludPlus').
";

    // 7) Construir prompt de usuario con contexto
    var numbered = enriched.Select((e, i) => new { n = i + 1, e });
    var contextParts = numbered.Select(x => {
        var item = (dynamic)x.e;
        return $"[{x.n}] Fuente: {item.Title}\n{item.Content}";
    });
    var context = string.Join("\n\n", contextParts);

    var userPrompt = $@"PREGUNTA:
{q}

CONTEXTO (relevante):
{context}

INSTRUCCIÓN: Usa únicamente el CONTEXTO para responder. Si no alcanza, decí 'No conozco esa respuesta.'";

    // 8) ⭐ NUEVO: Llamada a Ollama con temperatura baja
    try
    {
        var reply = await ollama.GenerateAsync(new OllamaGenerateRequest
        {
            Model = settings.Model,
            Prompt = $"{systemPrompt}\n\n{userPrompt}",
            Stream = false,
            Options = new { temperature = 0.2, num_ctx = 4096 } // Conservador
        });

        var answer = reply.Response?.Trim() ?? "";
        await DbHelpers.InsertMessageAsync(db, conversationId, "assistant", answer);

        Console.WriteLine($"✅ Respuesta generada - Longitud: {answer.Length} caracteres");

        var result = new { 
            conversationId, 
            answer, 
            retrieved = hits.Count,
            threshold = MIN_SIMILARITY,
            items = enriched 
        };

        // Guardar en caché (30 min)
        await cache.SetAsync(cacheKey, JsonSerializer.Serialize(result), TimeSpan.FromMinutes(30));

        return Results.Ok(result);
    }
    catch (Exception ex)
    {
        Console.WriteLine($"❌ Error al invocar Ollama: {ex.Message}");
        return Results.Problem(title: "Fallo al invocar Ollama", detail: ex.Message, statusCode: 502);
    }
    
});

app.MapPost("/api/rag/search", async (RagSearchRequest req, NpgsqlDataSource db, IOllamaClient ollama) =>
{
    var q = req.Query?.Trim();
    if (string.IsNullOrEmpty(q))
        return Results.BadRequest(new { error = "Query requerido" });

    // embed de la consulta
    var qEmb = await RagHelpers.EmbedAsync(new HttpClient(), ollama.BaseUrl(), q);

    // búsqueda por similitud
    var topK = req.TopK <= 0 ? 5 : Math.Min(req.TopK, 20);
    var hits = await RagHelpers.SearchAsync(db, qEmb, topK);

    return Results.Ok(new
    {
        query = q,
        retrieved = hits.Count,
        items = hits // { chunkId, documentId, idx, content, score }
    });
});

app.MapPost("/api/appointments", async ([FromBody] CreateAppointmentRequest req, NpgsqlDataSource db) =>
{
    const string getSlot = @"
      SELECT id FROM appointment_slots
      WHERE professional_id = @pid
        AND start_utc = @start
        AND is_booked = false
      LIMIT 1";

    await using var conn = await db.OpenConnectionAsync();

    // 1) Buscar slot exacto
    long slotId;
    await using (var cmd = new NpgsqlCommand(getSlot, conn))
    {
        cmd.Parameters.AddWithValue("pid", req.ProfessionalId);
        var pStart = cmd.Parameters.Add("start", NpgsqlDbType.TimestampTz);
        pStart.Value = req.StartUtc.UtcDateTime; // aseguramos UTC

        var slotIdObj = await cmd.ExecuteScalarAsync();
        if (slotIdObj is null)
            return Results.BadRequest(new { error = "No hay slot disponible" });

        slotId = (long)slotIdObj;
    }

    // 2) Reservar + crear appointment (transacción)
    await using var tx = await conn.BeginTransactionAsync();
    try
    {
        await using (var upd = new NpgsqlCommand(
            "UPDATE appointment_slots SET is_booked = true WHERE id = @id AND is_booked = false",
            conn, tx))
        {
            upd.Parameters.AddWithValue("id", slotId);
            var n = await upd.ExecuteNonQueryAsync();
            if (n == 0)
            {
                await tx.RollbackAsync();
                return Results.BadRequest(new { error = "El slot fue tomado por otro" });
            }
        }

        await using var ins = new NpgsqlCommand(@"
            INSERT INTO appointments(slot_id, booked_by, notes)
            VALUES(@sid, @by, @notes)
            RETURNING id, created_at;", conn, tx);

        ins.Parameters.AddWithValue("sid", slotId);
        ins.Parameters.AddWithValue("by", req.BookedBy);
        ins.Parameters.AddWithValue("notes", (object?)req.Notes ?? DBNull.Value);

        await using var rd = await ins.ExecuteReaderAsync();
        await rd.ReadAsync();
        var apptId = rd.GetInt64(0);
        var created = rd.GetDateTime(1);
        await rd.DisposeAsync();

        await tx.CommitAsync();

        return Results.Ok(new { appointmentId = apptId, slotId, createdAt = created, professionalId = req.ProfessionalId });
    }
    catch (Exception ex)
    {
        await tx.RollbackAsync();
        return Results.Problem(title: "No se pudo crear turno", detail: ex.Message, statusCode: 500);
    }
    finally
    {
        // Notificar al paciente (fuera de la transacción por simplicidad)
        var notifier = app.Services.GetRequiredService<INotificationService>();
        _ = notifier.SendAsync(req.BookedBy, $"Confirmación de Turno", $"Tu turno ha sido reservado para el {req.StartUtc:dd/MM/yyyy HH:mm} hs.");
    }
})
.WithName("CreateAppointment");

app.MapGet("/api/appointments", async ([FromQuery] string bookedBy, NpgsqlDataSource db) =>
{
    if (string.IsNullOrWhiteSpace(bookedBy))
        return Results.BadRequest(new { error = "bookedBy es requerido" });

    const string sql = @"
      SELECT a.id, a.booked_by, a.notes, a.created_at, 
             s.start_utc, p.name as professional_name, p.specialty, s.id as slot_id
      FROM appointments a
      JOIN appointment_slots s ON a.slot_id = s.id
      JOIN professionals p ON s.professional_id = p.id
      WHERE a.booked_by = @by
      ORDER BY s.start_utc DESC";

    try
    {
        await using var conn = await db.OpenConnectionAsync();
        await using var cmd = new NpgsqlCommand(sql, conn);
        cmd.Parameters.AddWithValue("by", bookedBy);

        var list = new List<object>();
        await using var rd = await cmd.ExecuteReaderAsync();
        while (await rd.ReadAsync())
        {
            list.Add(new {
                id               = rd.GetInt64(0),
                bookedBy         = rd.GetString(1),
                notes            = rd.IsDBNull(2) ? null : rd.GetString(2),
                createdAt        = rd.GetDateTime(3),
                startUtc         = rd.GetDateTime(4),
                professionalName = rd.GetString(5),
                specialty        = rd.GetString(6),
                slotId           = rd.GetInt64(7)
            });
        }
        return Results.Ok(list);
    }
    catch (Exception ex)
    {
        return Results.Problem(title: "Error al listar turnos", detail: ex.Message, statusCode: 500);
    }
})
.WithName("ListAppointments");

app.MapDelete("/api/appointments/{id}", async (long id, NpgsqlDataSource db) =>
{
    const string getSlot = "SELECT slot_id FROM appointments WHERE id = @id";
    const string delAppt = "DELETE FROM appointments WHERE id = @id";
    const string updSlot = "UPDATE appointment_slots SET is_booked = false WHERE id = @sid";

    await using var conn = await db.OpenConnectionAsync();
    await using var tx = await conn.BeginTransactionAsync();

    try
    {
        long slotId;
        await using (var cmd = new NpgsqlCommand(getSlot, conn, tx))
        {
            cmd.Parameters.AddWithValue("id", id);
            var result = await cmd.ExecuteScalarAsync();
            if (result is null) return Results.NotFound(new { error = "Turno no encontrado" });
            slotId = (long)result;
        }

        await using (var cmd = new NpgsqlCommand(delAppt, conn, tx))
        {
            cmd.Parameters.AddWithValue("id", id);
            await cmd.ExecuteNonQueryAsync();
        }

        await using (var cmd = new NpgsqlCommand(updSlot, conn, tx))
        {
            cmd.Parameters.AddWithValue("sid", slotId);
            await cmd.ExecuteNonQueryAsync();
        }

        await tx.CommitAsync();
        return Results.Ok(new { message = "Turno cancelado correctamente" });
    }
    catch (Exception ex)
    {
        await tx.RollbackAsync();
        return Results.Problem(title: "Error al cancelar turno", detail: ex.Message, statusCode: 500);
    }
})
.WithName("DeleteAppointment");




// Inicialización de DB (Users)
await using (var scope = app.Services.CreateAsyncScope())
{
    var db = scope.ServiceProvider.GetRequiredService<NpgsqlDataSource>();
    await using var conn = await db.OpenConnectionAsync();
    const string sqlInit = @"
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'Patient',
        full_name TEXT NULL,
        created_at TIMESTAMPTZ NOT NULL DEFAULT now()
      );";
    await using var cmd = new NpgsqlCommand(sqlInit, conn);
    await cmd.ExecuteNonQueryAsync();

    // Crear admin por defecto si no existe
    const string checkAdmin = "SELECT COUNT(*) FROM users WHERE username = 'admin'";
    await using var cmdCheck = new NpgsqlCommand(checkAdmin, conn);
    var count = (long)(await cmdCheck.ExecuteScalarAsync() ?? 0L);
    if (count == 0)
    {
        const string insertAdmin = "INSERT INTO users(username, password_hash, role, full_name) VALUES('admin', @h, 'Admin', 'Admin PoC')";
        await using var cmdIns = new NpgsqlCommand(insertAdmin, conn);
        cmdIns.Parameters.AddWithValue("h", BCrypt.Net.BCrypt.HashPassword("admin123"));
        await cmdIns.ExecuteNonQueryAsync();
    }
}

app.Run();

// ===================== Tipos y helpers =====================
public record RegisterRequest(string Username, string Password, string? Role = "Patient", string? FullName = null);
public record LoginRequest(string Username, string Password);
public record CreateAppointmentRequest(long ProfessionalId, DateTimeOffset StartUtc, string BookedBy, string? Notes);
public record ChatRequest(string Message, Guid ConversationId = default);
public record ChatResponse
{
    public Guid ConversationId { get; set; }
    public string Answer { get; set; } = "";
}

public class OllamaSettings { public string Model { get; set; } = "mistral:7b-instruct"; }

public record OllamaGenerateRequest
{
    public string Model { get; init; } = "mistral:7b-instruct";
    public string Prompt { get; init; } = "";
    public bool Stream { get; init; } = false;
    public object? Options { get; init; } = null;
}

public record OllamaGenerateResponse
{
    public string? Model { get; init; }
    public string? Response { get; init; }
    public bool? Done { get; init; }
}

public interface IOllamaClient
{
    Task<OllamaGenerateResponse> GenerateAsync(OllamaGenerateRequest req, CancellationToken ct = default);
    string BaseUrl();
}

public class OllamaClient : IOllamaClient
{
    private readonly HttpClient _http;
    private static readonly JsonSerializerOptions _jsonOptions = new() { PropertyNameCaseInsensitive = true };
    
    public OllamaClient(HttpClient http) => _http = http;

    public async Task<OllamaGenerateResponse> GenerateAsync(OllamaGenerateRequest req, CancellationToken ct = default)
    {
        var httpRes = await _http.PostAsJsonAsync("/api/generate", req, ct);
        var text = await httpRes.Content.ReadAsStringAsync(ct);
        if (!httpRes.IsSuccessStatusCode)
            throw new InvalidOperationException($"Ollama error {(int)httpRes.StatusCode}: {text}");

        // Log para debugging
        Console.WriteLine($"📥 Respuesta de Ollama (primeros 200 chars): {(text.Length > 200 ? text.Substring(0, 200) : text)}");
        
        var result = JsonSerializer.Deserialize<OllamaGenerateResponse>(text, _jsonOptions)
                     ?? new OllamaGenerateResponse { Response = "" };
        
        Console.WriteLine($"📤 Response parseado - Longitud: {result.Response?.Length ?? 0}, Done: {result.Done}");
        
        return result;
    }

    public string BaseUrl() => _http.BaseAddress?.ToString() ?? "";
}
public record IngestTextRequest(string Title, string Content, string? SourceUri = null, string? Type = "faq");
public record RagChatRequest(string Message, Guid ConversationId = default, int TopK = 5);
public record RagSearchHit(long ChunkId, long DocumentId, int Idx, string Content, double Score);
public record RagSearchRequest(string Query, int TopK = 5);

// ===== Notificaciones =====
public interface INotificationService
{
    Task SendAsync(string to, string subject, string body);
}

public class MockNotificationService : INotificationService
{
    public Task SendAsync(string to, string subject, string body)
    {
        Console.WriteLine($"\n🔔 NOTIFICACIÓN ENVIADA A: {to}");
        Console.WriteLine($"📧 Asunto: {subject}");
        Console.WriteLine($"📝 Mensaje: {body}\n");
        return Task.CompletedTask;
    }
}

// ===== Caching =====
public interface ICacheService {
    Task<string?> GetAsync(string key);
    Task SetAsync(string key, string value, TimeSpan? expiry = null);
}

public class RedisCacheService : ICacheService {
    private readonly IDatabase _db;
    public RedisCacheService(IConnectionMultiplexer redis) => _db = redis.GetDatabase();
    public async Task<string?> GetAsync(string key) => await _db.StringGetAsync(key);
    public async Task SetAsync(string key, string value, TimeSpan? expiry = null) => await _db.StringSetAsync(key, value, expiry);
}

public class InMemoryCacheService : ICacheService {
    private readonly System.Collections.Concurrent.ConcurrentDictionary<string, (string val, DateTime? exp)> _cache = new();
    public Task<string?> GetAsync(string key) {
        if (_cache.TryGetValue(key, out var entry)) {
            if (entry.exp == null || entry.exp > DateTime.Now) return Task.FromResult<string?>(entry.val);
            _cache.TryRemove(key, out _);
        }
        return Task.FromResult<string?>(null);
    }
    public Task SetAsync(string key, string value, TimeSpan? expiry = null) {
        _cache[key] = (value, expiry.HasValue ? DateTime.Now.Add(expiry.Value) : null);
        return Task.CompletedTask;
    }
}


// ===== DB helpers =====

internal static class DbHelpers
{
    internal static async Task<Guid> CreateConversationAsync(NpgsqlDataSource db)
    {
        const string sql = "INSERT INTO conversations DEFAULT VALUES RETURNING id;";
        await using var conn = await db.OpenConnectionAsync();
        await using var cmd = new NpgsqlCommand(sql, conn);
        var id = (Guid)(await cmd.ExecuteScalarAsync() 
                 ?? throw new InvalidOperationException("No se pudo crear conversación"));
        return id;
    }

    internal static async Task<bool> ConversationExistsAsync(NpgsqlDataSource db, Guid id)
    {
        const string sql = "SELECT 1 FROM conversations WHERE id = @id;";
        await using var conn = await db.OpenConnectionAsync();
        await using var cmd = new NpgsqlCommand(sql, conn);
        cmd.Parameters.AddWithValue("id", id);
        var obj = await cmd.ExecuteScalarAsync();
        return obj is not null;
    }

    internal static async Task InsertMessageAsync(NpgsqlDataSource db, Guid conversationId, string role, string content)
    {
        const string sql = @"INSERT INTO messages(conversation_id, role, content) 
                             VALUES(@cid, @role, @content);";
        await using var conn = await db.OpenConnectionAsync();
        await using var cmd = new NpgsqlCommand(sql, conn);
        cmd.Parameters.AddWithValue("cid", conversationId);
        cmd.Parameters.AddWithValue("role", role);
        cmd.Parameters.AddWithValue("content", content);
        await cmd.ExecuteNonQueryAsync();
    }
}

internal static class RagHelpers
{
    // Chunking simple por caracteres con solapamiento
    internal static List<(int idx, string text)> ChunkText(string content, int maxChars = 1000, int overlap = 200)
    {
        var chunks = new List<(int, string)>();
        if (string.IsNullOrWhiteSpace(content)) return chunks;

        var span = content.AsSpan();
        int i = 0, idx = 0;
        while (i < span.Length)
        {
            var end = Math.Min(i + maxChars, span.Length);
            var piece = span.Slice(i, end - i).ToString().Trim();
            if (!string.IsNullOrWhiteSpace(piece))
                chunks.Add((idx++, piece));
            if (end >= span.Length) break;
            i = end - Math.Min(overlap, end - i); // retroceder overlap
        }
        return chunks;
    }

    // Embeddings con Ollama: /api/embeddings { model, prompt }
    internal static async Task<float[]> EmbedAsync(HttpClient http, string baseUrl, string text, string embedModel = "nomic-embed-text", CancellationToken ct = default)
    {
        using var client = new HttpClient { BaseAddress = new Uri(baseUrl) };
        var payload = new { model = embedModel, prompt = text };
        var res = await client.PostAsJsonAsync("/api/embeddings", payload, ct);
        var body = await res.Content.ReadAsStringAsync(ct);
        if (!res.IsSuccessStatusCode)
            throw new InvalidOperationException($"Ollama embeddings error {(int)res.StatusCode}: {body}");

        using var doc = JsonDocument.Parse(body);
        // Respuesta típica: { "embedding": [floats], "model": "...", ... }
        var vec = doc.RootElement.GetProperty("embedding").EnumerateArray().Select(e => (float)e.GetDouble()).ToArray();
        return vec;
    }

    // Inserta documento y devuelve id
    internal static async Task<long> InsertDocumentAsync(NpgsqlDataSource db, string title, string? sourceUri, string? type)
    {
        const string sql = @"INSERT INTO documents(title, source_uri, type) VALUES(@t,@s,@ty) RETURNING id;";
        await using var conn = await db.OpenConnectionAsync();
        await using var cmd = new NpgsqlCommand(sql, conn);
        cmd.Parameters.AddWithValue("t", title);
        cmd.Parameters.AddWithValue("s", (object?)sourceUri ?? DBNull.Value);
        cmd.Parameters.AddWithValue("ty", (object?)type ?? DBNull.Value);
        var id = (long)(await cmd.ExecuteScalarAsync() ?? throw new InvalidOperationException("No se pudo crear documento"));
        return id;
    }

    // Inserta chunk + embedding: importante castear a vector
    internal static async Task InsertChunkAsync(NpgsqlDataSource db, long documentId, int idx, string content, float[] embedding)
    {
        var embedLiteral = "[" + string.Join(",", embedding.Select(f => f.ToString(System.Globalization.CultureInfo.InvariantCulture))) + "]";
        const string sql = @"INSERT INTO chunks(document_id, idx, content, embedding)
                             VALUES(@d, @i, @c, (@e)::vector)";
        await using var conn = await db.OpenConnectionAsync();
        await using var cmd = new NpgsqlCommand(sql, conn);
        cmd.Parameters.AddWithValue("d", documentId);
        cmd.Parameters.AddWithValue("i", idx);
        cmd.Parameters.AddWithValue("c", content);
        cmd.Parameters.AddWithValue("e", embedLiteral); // se castea a vector en SQL
        await cmd.ExecuteNonQueryAsync();
    }

    // Búsqueda vectorial: cosine distance (<->). Menor es mejor.
    internal static async Task<List<RagSearchHit>> SearchAsync(NpgsqlDataSource db, float[] queryEmbedding, int topK = 5)
    {
        var embedLiteral = "[" + string.Join(",", queryEmbedding.Select(f => f.ToString(System.Globalization.CultureInfo.InvariantCulture))) + "]";
        var sql = $@"
           SELECT id, document_id, idx, content, (embedding <-> (@q)::vector) AS score
           FROM chunks
           ORDER BY embedding <-> (@q)::vector
           LIMIT @k;";

        var hits = new List<RagSearchHit>();
        await using var conn = await db.OpenConnectionAsync();
        await using var cmd = new NpgsqlCommand(sql, conn);
        cmd.Parameters.AddWithValue("q", embedLiteral);
        cmd.Parameters.AddWithValue("k", topK);
        await using var rd = await cmd.ExecuteReaderAsync();
        while (await rd.ReadAsync())
        {
            hits.Add(new RagSearchHit(
                rd.GetInt64(0),
                rd.GetInt64(1),
                rd.GetInt32(2),
                rd.GetString(3),
                rd.GetDouble(4)
            ));
        }
        return hits;
    }
    internal static async Task<(string? title, string? source)> GetDocumentMetaAsync(NpgsqlDataSource db, long documentId)
    {
    const string sql = @"SELECT title, source_uri FROM documents WHERE id = @id";
    await using var conn = await db.OpenConnectionAsync();
    await using var cmd = new NpgsqlCommand(sql, conn);
    cmd.Parameters.AddWithValue("id", documentId);
    await using var rd = await cmd.ExecuteReaderAsync();
    if (await rd.ReadAsync())
        return (rd.IsDBNull(0) ? null : rd.GetString(0), rd.IsDBNull(1) ? null : rd.GetString(1));
    return (null, null);
    }

}


