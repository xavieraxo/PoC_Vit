# 📋 Scripts para Insertar Profesionales Médicos

Esta carpeta contiene scripts para insertar datos de profesionales médicos en la base de datos del proyecto PoC Vit.

## 📊 Datos que se Insertan

- **120 profesionales médicos** distribuidos en 10 provincias argentinas
- **12 especialidades** diferentes por provincia
- **10 provincias**: Buenos Aires, Córdoba, Santa Fe, Misiones, Mendoza, San Juan, San Luis, La Pampa, Neuquén, Tucumán

## 🚀 Scripts Disponibles

### 1. `insert_professionals.ps1` ⭐ (Recomendado)
Script completo con verificaciones y estadísticas detalladas.

```powershell
.\scripts\insert_professionals.ps1
```

**Características:**
- ✅ Verifica que Docker esté corriendo
- ✅ Verifica que la base de datos esté disponible
- ✅ Muestra estadísticas antes y después
- ✅ Distribución por ciudad
- ✅ Manejo de errores

### 2. `insert_professionals.sql`
Archivo SQL con todos los INSERT statements.

**Contenido:**
- 120 INSERT statements
- Direcciones específicas por provincia
- Consultas de verificación al final

### 3. `quick_insert.ps1` ⚡ (Rápido)
Script simplificado para inserción rápida de 10 profesionales.

```powershell
.\scripts\quick_insert.ps1
```

**Ideal para:**
- Pruebas rápidas
- Desarrollo
- Verificación básica

### 4. `verify_data.ps1` 🔍
Script para verificar que los datos se insertaron correctamente.

```powershell
.\scripts\verify_data.ps1
```

**Verifica:**
- ✅ Total de profesionales
- ✅ Distribución por ciudad
- ✅ Especialidades disponibles
- ✅ Integridad de datos
- ✅ Ejemplos de registros

### 5. `MANUAL_INSERT.md`
Guía completa con comandos manuales alternativos.

## 🎯 Uso Recomendado

### Primera vez (Datos completos)
```powershell
cd E:\Proyectos\PoC_Vit
.\scripts\insert_professionals.ps1
```

### Verificar inserción
```powershell
.\scripts\verify_data.ps1
```

### Prueba rápida (10 profesionales)
```powershell
.\scripts\quick_insert.ps1
```

## 📋 Prerrequisitos

1. **Docker corriendo**:
   ```powershell
   docker-compose up db
   ```

2. **Base de datos inicializada**:
   - La tabla `professionals` debe existir
   - Ejecutar `docker/db/init.sql` si es necesario

## 🔍 Verificación Manual

### Conectar a la base de datos
```powershell
docker exec -it poc_db psql -U app -d salud_poc
```

### Comandos SQL útiles
```sql
-- Contar profesionales
SELECT COUNT(*) FROM professionals;

-- Ver distribución por ciudad
SELECT city, COUNT(*) FROM professionals GROUP BY city ORDER BY city;

-- Ver especialidades
SELECT specialty, COUNT(*) FROM professionals GROUP BY specialty ORDER BY specialty;

-- Buscar por especialidad
SELECT * FROM professionals WHERE specialty = 'Cardiología' LIMIT 5;

-- Buscar por ciudad
SELECT * FROM professionals WHERE city = 'Buenos Aires' LIMIT 5;
```

## 🧪 Prueba en la Aplicación

Después de insertar los datos:

1. **Ejecuta la aplicación**:
   ```powershell
   docker-compose up
   ```

2. **Abre Blazor**: http://localhost

3. **Ve a "Profesionales"**:
   - Haz clic en "Buscar" (sin filtros)
   - Deberías ver 120 profesionales

4. **Prueba filtros**:
   - Especialidad: "Cardiología" → 20 resultados
   - Ciudad: "Buenos Aires" → 12 resultados
   - Combinado: "Cardiología" + "Buenos Aires" → 2 resultados

## 🗑️ Limpiar Datos

Si necesitas empezar de nuevo:

```powershell
# Eliminar todos los profesionales
docker exec poc_db psql -U app -d salud_poc -c "DELETE FROM professionals;"

# Reiniciar secuencia de IDs
docker exec poc_db psql -U app -d salud_poc -c "ALTER SEQUENCE professionals_id_seq RESTART WITH 1;"
```

## 📊 Estructura de Datos

### Tabla `professionals`
```sql
CREATE TABLE professionals (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    specialty VARCHAR(255) NOT NULL,
    city VARCHAR(255) NOT NULL,
    address TEXT
);
```

### Ejemplo de registro
```sql
INSERT INTO professionals (name, specialty, city, address) 
VALUES ('Dr. Juan Pérez', 'Cardiología', 'Buenos Aires', 'Av. Corrientes 1234');
```

## 🐛 Solución de Problemas

### Error: "base de datos no existe"
```powershell
# Verificar contenedores
docker ps | Select-String "poc_db"

# Iniciar base de datos
docker-compose up db
```

### Error: "tabla no existe"
```powershell
# Verificar tablas
docker exec poc_db psql -U app -d salud_poc -c "\dt"

# Inicializar base de datos
docker exec -i poc_db psql -U app -d salud_poc < docker/db/init.sql
```

### Error: "permisos denegados"
```powershell
# Verificar conexión
docker exec poc_db psql -U app -d salud_poc -c "SELECT 1;"
```

## 📞 Comandos de Emergencia

```powershell
# Ver estado general
docker ps
docker exec poc_db psql -U app -d salud_poc -c "SELECT COUNT(*) FROM professionals;"

# Reiniciar todo limpio
docker-compose down -v
docker-compose up --build
```

---

**¡Los scripts están listos para usar!** 🚀

Para cualquier problema, consulta `MANUAL_INSERT.md` o ejecuta `verify_data.ps1` para diagnosticar.
