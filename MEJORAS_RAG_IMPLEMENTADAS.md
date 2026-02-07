# ✅ Mejoras RAG Implementadas

**Fecha:** 18 de Octubre, 2025  
**Estado:** COMPLETADO Y DESPLEGADO

---

## 🎯 Resumen de Cambios

Se implementaron **guardrails** (barandales de seguridad) para el sistema RAG según las mejores prácticas, asegurando que el asistente:
- ✅ Solo responda con información verificada
- ✅ No invente datos
- ✅ Indique cuando no tiene información suficiente

---

## 📋 Mejoras Implementadas

### 1. ⭐ Umbral de Confianza (Threshold)

**Código:** `src/Api/Program.cs` líneas 251-268

```csharp
const double MIN_SIMILARITY = 0.80; // Calibrar entre 0.75-0.85
var hits = allHits.Where(h => (1.0 - h.Score) >= MIN_SIMILARITY).Take(5).ToList();
```

**Qué hace:**
- Filtra los fragmentos (chunks) de documentos por similitud semántica
- Solo usa fragmentos con similitud >= 0.80 (80%)
- Si no hay fragmentos confiables, responde: "No conozco esa respuesta"

**Calibración:**
- **0.75-0.78:** Más permisivo - incluye más contexto (riesgo: ruido)
- **0.80-0.82:** Balanceado ⭐ **ACTUAL**
- **0.83-0.85:** Estricto - solo contexto muy relevante (riesgo: respuestas cortas)

---

### 2. 📝 Prompt de Sistema con Reglas Estrictas

**Código:** `src/Api/Program.cs` líneas 288-297

```csharp
var systemPrompt = @"
Sos un asistente de la obra social SaludPlus.
Reglas estrictas:
- Respondé solo con la información provista en el CONTEXTO.
- Si el contexto no alcanza para responder con seguridad, decí: 'No conozco esa respuesta.'
- No inventes datos, no especules.
- Dominio: cobertura, planes, turnos, autorizaciones, prestadores, contactos de SaludPlus.
- Sé claro y conciso. Si corresponde, mencioná la fuente (p.ej.: 'Según la FAQ SaludPlus').
";
```

**Beneficios:**
- Define claramente el dominio de conocimiento
- Establece reglas de comportamiento
- Previene alucinaciones (invención de datos)

---

### 3. 🌡️ Temperatura Baja (0.2)

**Código:** `src/Api/Program.cs` línea 323

```csharp
Options = new { temperature = 0.2, num_ctx = 4096 } // Conservador
```

**Qué hace:**
- **Temperature 0.2:** Respuestas más determinísticas y conservadoras
- **num_ctx 4096:** Contexto amplio para procesar fragmentos largos

**Escala de temperatura:**
- **0.0-0.2:** Muy conservador (recomendado para FAQ/datos precisos) ⭐
- **0.3-0.5:** Balanceado
- **0.6-1.0:** Creativo (para escritura, ideas)

---

### 4. 📊 Logging de Similitudes

**Código:** `src/Api/Program.cs` líneas 255-261

```csharp
Console.WriteLine($"🔍 Búsqueda RAG - Total: {allHits.Count}, Después de filtro (>={MIN_SIMILARITY}): {hits.Count}");
foreach (var h in allHits.Take(5))
{
    var similarity = 1.0 - h.Score;
    Console.WriteLine($"  📊 Chunk {h.ChunkId}: Similitud={similarity:F3} {(similarity >= MIN_SIMILARITY ? "✅" : "❌")}");
}
```

**Para qué sirve:**
- Ver qué fragmentos se están usando
- Calibrar el umbral MIN_SIMILARITY
- Debugging de respuestas incorrectas

---

### 5. 🔄 TopK Ampliado y Filtrado

**Código:** `src/Api/Program.cs` líneas 247-253

```csharp
var topK = req.TopK <= 0 ? 10 : Math.Min(req.TopK, 20);  // Buscar más
var allHits = await RagHelpers.SearchAsync(db, qEmb, topK);
var hits = allHits.Where(h => (1.0 - h.Score) >= MIN_SIMILARITY).Take(5).ToList();  // Filtrar y limitar
```

**Estrategia:**
1. Buscar 10-20 fragmentos iniciales
2. Filtrar por umbral de similitud
3. Tomar solo los top 5 más relevantes

---

### 6. 🛡️ Fallback sin Contexto

**Código:** `src/Api/Program.cs` líneas 263-269

```csharp
if (hits.Count == 0)
{
    var noContextAnswer = "No conozco esa respuesta con la información disponible en mi base de conocimientos de SaludPlus.";
    await DbHelpers.InsertMessageAsync(db, conversationId, "assistant", noContextAnswer);
    return Results.Ok(new { conversationId, answer = noContextAnswer, retrieved = 0, items = new List<object>(), threshold = MIN_SIMILARITY });
}
```

**Beneficio:**
- Honestidad: admite cuando no sabe
- Evita inventar respuestas
- Mantiene la confianza del usuario

---

### 7. 🔧 Debugging Mejorado en Frontend

**Código:** `src/PoC_Vit.Blazor/Services/ApiClient.cs` líneas 42-60

Agregado logging extensivo para ver:
- Contenido raw de la respuesta
- Estado de deserialización
- Longitud de la respuesta

---

## 🧪 Cómo Probar las Mejoras

### Escenario 1: Pregunta con Contexto Suficiente

**Pregunta:** "¿Qué cubre el plan SaludPlus?"

**Resultado esperado:**
- ✅ Busca en la BD
- ✅ Encuentra fragmentos con similitud > 0.80
- ✅ Genera respuesta basada en el contexto
- ✅ Menciona la fuente si es apropiado

**En los logs verás:**
```
🔍 Búsqueda RAG - Total: 10, Después de filtro (>=0.8): 5
  📊 Chunk 123: Similitud=0.92 ✅
  📊 Chunk 124: Similitud=0.87 ✅
  📊 Chunk 125: Similitud=0.85 ✅
✅ Respuesta generada - Longitud: 250 caracteres
```

---

### Escenario 2: Pregunta Fuera del Dominio

**Pregunta:** "¿Cuál es la capital de Francia?"

**Resultado esperado:**
- ✅ Busca en la BD
- ✅ No encuentra fragmentos confiables (similitud < 0.80)
- ✅ Responde: "No conozco esa respuesta con la información disponible..."

**En los logs verás:**
```
🔍 Búsqueda RAG - Total: 10, Después de filtro (>=0.8): 0
  📊 Chunk 45: Similitud=0.32 ❌
  📊 Chunk 67: Similitud=0.28 ❌
```

---

### Escenario 3: Pregunta Parcialmente Relevante

**Pregunta:** "¿Cómo solicito un turno para odontología en Mendoza?"

**Resultado esperado:**
- ✅ Encuentra algunos fragmentos relevantes
- ✅ Si la similitud es baja (0.75-0.79), **no los usa**
- ✅ Responde basándose solo en lo que tiene alta confianza

---

## 📈 Calibración del Umbral

### Cómo Ajustar MIN_SIMILARITY:

1. **Ejecuta 15-20 preguntas de prueba** reales
2. **Observa los logs** de similitud
3. **Ajusta según resultados:**

| Problema | Solución |
|----------|----------|
| Se queda corto / dice "no sé" mucho | Bajar a 0.78 o 0.75 |
| Responde cosas no relacionadas / hace ruido | Subir a 0.83 o 0.85 |
| Responde bien mayormente | Mantener en 0.80 ✅ |

**Ubicación del cambio:** `src/Api/Program.cs` línea 252

```csharp
const double MIN_SIMILARITY = 0.80; // ← Cambiar aquí
```

---

## 🔄 Actualización de FAQ (Sin Cambios de Código)

**¿Qué pasa cuando actualizo la FAQ?**

1. Vas a **Knowledge** → Cargas nuevo contenido
2. Se generan embeddings automáticamente
3. Se guardan en la BD
4. **El chat automáticamente usa la nueva información** ✅
5. **NO necesitas tocar código** ✅

**El sistema es dinámico:**
- Prompt de sistema: Define las reglas (una vez)
- Umbral: Define la confianza (una vez)
- Contenido FAQ: Se actualiza cuando quieras (sin código)

---

## 📊 Métricas en la Respuesta

El endpoint `/api/chat/rag` ahora devuelve:

```json
{
  "conversationId": "...",
  "answer": "Respuesta del asistente...",
  "retrieved": 5,
  "threshold": 0.8,
  "items": [
    {
      "chunkId": 123,
      "documentId": 45,
      "content": "...",
      "similarity": 0.92,
      "title": "FAQ SaludPlus",
      "source": "https://..."
    }
  ]
}
```

**Útil para:**
- Ver qué fragmentos se usaron
- Verificar similitudes
- Debugging de respuestas

---

## 🎯 Checklist de Guardrails Implementados

- [x] ⭐ Prompt de sistema con reglas claras (dominio + "no inventar")
- [x] ⭐ Umbral MIN_SIMILARITY = 0.80
- [x] ⭐ Fallback si no hay contexto confiable
- [x] ⭐ Temperatura baja (0.2) para respuestas conservadoras
- [x] ⭐ TopK en 5 (después de filtrar)
- [x] ⭐ Logging de similitudes para calibración
- [x] ⭐ Enriquecimiento con metadatos (fuentes)
- [x] ⭐ Respuestas honestas cuando no hay información

---

## 🚀 Instrucciones de Uso

### Para Probar el Chat con RAG:

1. **Recarga el navegador** (Ctrl + Shift + R)
2. Presiona **F12** → Console
3. Ve a **Chat**
4. Envía un mensaje sobre la obra social
5. **Observa los logs** en la consola del navegador
6. En otra terminal, ejecuta:
   ```powershell
   docker logs poc_vit-api-1 -f
   ```
7. Verás los logs de similitud y debugging

---

### Ver Logs de Calibración:

```powershell
# Ver logs en tiempo real
docker logs poc_vit-api-1 -f | Select-String "🔍|📊|✅|❌"

# Ver últimas búsquedas
docker logs poc_vit-api-1 --tail 100 | Select-String "Búsqueda RAG"
```

---

## 🎓 Conceptos Clave

### Similitud vs Score
```
Score = distancia coseno (0 = idéntico, 2 = opuesto)
Similitud = 1 - Score (0 = diferente, 1 = idéntico)

Ejemplo:
- Score: 0.15 → Similitud: 0.85 ✅ (muy similar)
- Score: 0.50 → Similitud: 0.50 ❌ (no muy relevante)
```

### TopK vs Filtrado
```
TopK: Cuántos fragmentos buscar inicialmente (10-20)
Filtrado: Cuántos quedan después del umbral (0-5)
Límite final: Top 5 más relevantes
```

---

## 📝 Notas Finales

### Lo que NO cambió:
- ✅ Endpoint `/api/chat` normal sigue funcionando
- ✅ Cargar FAQ (`/api/ingest/text`) sigue igual
- ✅ Búsqueda de profesionales no afectada
- ✅ Turnos no afectados

### Lo que SÍ cambió:
- ⭐ `/api/chat/rag` ahora tiene guardrails
- ⭐ Respuestas más confiables
- ⭐ Logging mejorado
- ⭐ Frontend con debugging extensivo

---

## 🆘 Troubleshooting

### El asistente dice "No conozco" para todo

**Causa:** Umbral muy alto o FAQ no cargada

**Solución:**
1. Verifica que la FAQ esté cargada: `/knowledge`
2. Revisa los logs de similitud
3. Si las similitudes están en 0.75-0.79, baja el umbral

### El asistente responde cosas no relacionadas

**Causa:** Umbral muy bajo

**Solución:**
1. Sube el umbral a 0.83 o 0.85
2. Verifica que la FAQ no tenga contenido irrelevante

### No veo logs de similitud

**Causa:** Logs no se están mostrando

**Solución:**
```powershell
docker logs poc_vit-api-1 -f
```

---

**¡Sistema RAG con Guardrails Implementado y Funcionando!** 🎉

*Desarrollado siguiendo las mejores prácticas de RAG para sistemas de producción.*


