# 🔧 Instrucciones para Probar el Chat - ACTUALIZADO

## ⚠️ MUY IMPORTANTE: Limpiar Caché del Navegador

El navegador puede estar usando una versión antigua de la aplicación. **Debes limpiar el caché:**

### Opción 1: Recarga Forzada (Más Rápida)
```
Ctrl + Shift + R
```
O:
```
Ctrl + F5
```

### Opción 2: Limpiar Todo el Almacenamiento (Más Seguro)
1. Abre http://localhost
2. Presiona **F12** (Herramientas de Desarrollador)
3. Ve a la pestaña **Application** (Chrome) o **Storage** (Firefox)
4. En el panel izquierdo, haz clic derecho en **http://localhost**
5. Selecciona **"Clear site data"** o **"Limpiar datos del sitio"**
6. Cierra el navegador completamente
7. Vuelve a abrir y ve a http://localhost

---

## 🧪 Pasos para Probar

### Paso 1: Abrir la Consola del Navegador

1. Abre http://localhost
2. Presiona **F12**
3. Ve a la pestaña **Console**

### Paso 2: Verificar la URL Configurada

Cuando la página cargue, deberías ver UNO de estos mensajes en la consola:

✅ **CORRECTO:**
```
⚙️ URL configurada: http://localhost/api/
```

❌ **INCORRECTO (si ves esto, el caché no se limpió):**
```
🐳 Modo DOCKER/PRODUCCIÓN: Conectando a http://localhost/api/
```
o
```
🔧 Modo DESARROLLO LOCAL: Conectando a http://localhost:52848/api/
```

### Paso 3: Ir al Chat

1. Haz clic en **"Chat"** en el menú lateral
2. La consola sigue abierta (F12)

### Paso 4: Enviar un Mensaje de Prueba

Escribe:
```
Hola
```

### Paso 5: Observar los Logs

**En la consola del navegador deberías ver:**

✅ **SI FUNCIONA:**
```
🔹 Enviando mensaje al chat: Hola
🔹 ConversationId: 00000000-0000-0000-0000-000000000000
🔹 Status de respuesta: 200
🔹 Respuesta recibida - Longitud: XX caracteres
```

❌ **SI FALLA:**
```
❌ Error de conexión: ...
```

---

## 🔍 Si Sigue Dando Error

### Diagnóstico 1: Ver la Petición en Network

1. Con F12 abierto, ve a la pestaña **Network**
2. Envía un mensaje en el chat
3. Busca la petición que dice **"chat"**
4. Haz clic en ella
5. Mira:
   - **Request URL:** ¿A qué URL está intentando conectarse?
   - **Status Code:** ¿Qué código devuelve?
   - **Response:** ¿Qué dice la respuesta?

**Toma una captura de pantalla y compártela.**

### Diagnóstico 2: Probar la API Manualmente

Abre una nueva pestaña en el navegador y ve a:
```
http://localhost/api/health
```

**Resultado esperado:**
```json
{"status":"ok","timestamp":"..."}
```

Si NO ves esto, hay un problema con Traefik o la red de Docker.

### Diagnóstico 3: Verificar CORS

Si en la consola (F12) ves un error que menciona **CORS** o **"has been blocked by CORS policy"**, entonces necesitamos ajustar la configuración de CORS en la API.

---

## 🐛 Posibles Errores y Soluciones

### Error 1: "Failed to fetch"
**Causa:** El navegador no puede conectarse a la API.

**Solución:**
1. Verifica que puedes acceder a http://localhost/api/health
2. Limpia el caché del navegador completamente
3. Cierra y reabre el navegador

### Error 2: "CORS policy"
**Causa:** La API está bloqueando peticiones desde el navegador.

**Solución:** Ya está configurado, pero verifica que la API tenga:
```csharp
app.UseCors("AllowBlazor");
```

### Error 3: "Error de conexión"
**Causa:** HttpClient no puede hacer la petición.

**Solución:**
1. Verifica la URL en la consola
2. Asegúrate de que dice: `⚙️ URL configurada: http://localhost/api/`
3. Si no, limpia el caché

---

## 📊 Checklist de Verificación

Antes de probar, asegúrate de:

- [ ] Docker está corriendo: `docker ps`
- [ ] Todos los contenedores están "Up"
- [ ] Limpiaste el caché del navegador: **Ctrl + Shift + R**
- [ ] Cerraste y reabriste el navegador
- [ ] Abriste la consola (F12) → Console
- [ ] Ves el mensaje `⚙️ URL configurada: http://localhost/api/`

---

## 🎯 ¿Qué Cambió?

Agregué un archivo de configuración (`appsettings.json`) que fuerza la URL de la API a:
```
http://localhost/api/
```

Esto elimina la detección automática que podría estar fallando.

---

## 💡 Tip: Modo Incógnito

Si todo falla, prueba en **modo incógnito/privado**:

- **Chrome:** Ctrl + Shift + N
- **Edge:** Ctrl + Shift + P  
- **Firefox:** Ctrl + Shift + P

Luego ve a http://localhost y prueba el chat.

El modo incógnito no tiene caché, así que verás la versión más reciente.

---

## 📞 Información para Reportar

Si sigue fallando, necesito que compartas:

1. **Mensaje exacto del error** (copia y pega)
2. **Captura de la consola** (F12 → Console)
3. **Captura de Network** (F12 → Network → petición "chat")
4. **URL que muestra la consola** cuando carga la página
5. **Navegador y versión** que estás usando

---

**¡Pruébalo ahora con el caché limpio!** 🚀

