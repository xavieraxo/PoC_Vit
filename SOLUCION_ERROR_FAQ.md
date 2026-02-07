# 🔧 Solución al Error "Failed to fetch" en Knowledge/FAQ

## 🎯 Problema Resuelto

El error `TypeError: Failed to fetch` ocurría porque Blazor intentaba conectarse a `http://localhost/api/` pero la API estaba ejecutándose en otro puerto.

## ✅ Cambios Realizados

Se actualizó `src/PoC_Vit.Blazor/Program.cs` para **detectar automáticamente** el entorno:

- **🔧 Desarrollo Local**: Se conecta a `http://localhost:52848/api/`
- **🐳 Docker**: Se conecta a `/api/` (a través de Traefik)

## 🚀 ¿Cómo Ejecutar la Aplicación?

### Opción 1: Ejecutar Localmente (Desarrollo)

#### Paso 1: Ejecutar la API
```powershell
# En una terminal de PowerShell
cd E:\Proyectos\PoC_Vit\src\Api
dotnet run
```

La API se ejecutará en: `http://localhost:52848`

#### Paso 2: Ejecutar Blazor
```powershell
# En OTRA terminal de PowerShell
cd E:\Proyectos\PoC_Vit\src\PoC_Vit.Blazor
dotnet watch run
```

Blazor se ejecutará en: `http://localhost:5137`

#### Paso 3: Abrir el Navegador
Abre tu navegador en: `http://localhost:5137`

---

### Opción 2: Ejecutar con Docker (Recomendado para Producción)

#### Paso 1: Crear archivo `.env`

Crea un archivo llamado `.env` en la raíz del proyecto (`E:\Proyectos\PoC_Vit\.env`) con este contenido:

```env
# PostgreSQL
POSTGRES_USER=app
POSTGRES_PASSWORD=app123
POSTGRES_DB=salud_poc
PG_PORT=5432

# Ollama
OLLAMA_PORT=11434
OLLAMA_MODEL=mistral:7b-instruct

# Traefik
TRAEFIK_HTTP_PORT=80
TRAEFIK_HTTPS_PORT=443
```

#### Paso 2: Ejecutar Docker Compose
```powershell
cd E:\Proyectos\PoC_Vit
docker-compose up --build
```

#### Paso 3: Esperar a que todo esté listo
Espera aproximadamente 2-3 minutos para que todos los servicios se inicien.

#### Paso 4: Abrir el Navegador
Abre tu navegador en: `http://localhost`

---

## 🧪 Verificar que Todo Funciona

### Verificar la API (si ejecutas localmente)

Abre tu navegador en: `http://localhost:52848/api/health`

Deberías ver:
```json
{
  "status": "ok",
  "timestamp": "2025-10-18T..."
}
```

### Verificar Blazor

1. Ve a la página "**Knowledge**" (Conocimiento)
2. Ingresa:
   - **Título**: `Prueba FAQ`
   - **Contenido**: `Esta es una prueba del sistema de conocimiento.`
3. Haz clic en "**Ingestar Texto**"
4. Deberías ver: ✅ **Documento ingresado correctamente**

---

## ❌ Solución de Problemas

### Error: "Connection refused" o "ECONNREFUSED"

**Causa**: La API no está ejecutándose.

**Solución**:
```powershell
# Verifica que la API esté corriendo
cd E:\Proyectos\PoC_Vit\src\Api
dotnet run
```

### Error: "404 Not Found"

**Causa**: La ruta del endpoint no es correcta.

**Solución**: Verifica que la API tenga el endpoint `/api/ingest/text` ejecutando:
```powershell
curl http://localhost:52848/api/_routes
```

### Error: "CORS policy"

**Causa**: El CORS no está configurado correctamente.

**Solución**: Ya está solucionado en el código. Si persiste, verifica que `Program.cs` de la API tenga:
```csharp
app.UseCors("AllowBlazor");
```

### La aplicación Blazor no se conecta

**Solución**: 
1. Abre las herramientas de desarrollador del navegador (F12)
2. Ve a la pestaña "Console"
3. Busca el mensaje que dice:
   - `🔧 Modo DESARROLLO LOCAL: Conectando a http://localhost:52848/api/`
   - o `🐳 Modo DOCKER/PRODUCCIÓN: Conectando a /api/`
4. Verifica que la URL sea correcta

---

## 📝 Notas Importantes

### Para Desarrollo Local

- **Necesitas** ejecutar AMBOS proyectos (Api y Blazor) simultáneamente
- La API debe estar en el puerto `52848`
- Blazor debe estar en el puerto `5137`

### Para Docker

- Solo necesitas ejecutar `docker-compose up --build`
- Todo se configura automáticamente
- Accede en `http://localhost` (puerto 80)

---

## 🎉 ¡Listo!

Ahora el sistema detecta automáticamente si estás en desarrollo local o en Docker y se conecta a la URL correcta.

**Características implementadas**:
- ✅ Detección automática de entorno
- ✅ Configuración dinámica de URL de API
- ✅ Soporte para desarrollo local
- ✅ Soporte para Docker
- ✅ Mensajes de consola para debugging

---

## 🆘 ¿Aún tienes problemas?

1. **Reinicia la aplicación Blazor**:
   ```powershell
   # Presiona Ctrl+C para detener
   # Luego ejecuta de nuevo:
   cd E:\Proyectos\PoC_Vit\src\PoC_Vit.Blazor
   dotnet watch run
   ```

2. **Verifica los logs**:
   - Abre el navegador en `http://localhost:5137`
   - Presiona F12 para abrir las herramientas de desarrollador
   - Ve a la pestaña "Console"
   - Busca mensajes de error en rojo

3. **Verifica que la API responde**:
   ```powershell
   curl http://localhost:52848/api/health
   ```

4. **Limpia y reconstruye**:
   ```powershell
   cd E:\Proyectos\PoC_Vit
   dotnet clean
   dotnet build
   ```

---

**¡El error debería estar resuelto! 🎯**

