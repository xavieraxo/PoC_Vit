# 📋 Inserción Manual de Profesionales

## 🚀 Opción 1: Script Automático (Recomendado)

```powershell
cd E:\Proyectos\PoC_Vit
.\scripts\insert_professionals.ps1
```

## ⚡ Opción 2: Inserción Rápida (10 profesionales)

```powershell
cd E:\Proyectos\PoC_Vit
.\scripts\quick_insert.ps1
```

## 🔧 Opción 3: Comando Manual

```powershell
# Conectar a la base de datos
docker exec -it poc_db psql -U app -d salud_poc

# Dentro de psql, ejecutar:
\i /scripts/insert_professionals.sql
```

## 📝 Opción 4: Inserción Individual

```powershell
# Insertar un profesional específico
docker exec poc_db psql -U app -d salud_poc -c "
INSERT INTO professionals (name, specialty, city, address) 
VALUES ('Dr. Juan Pérez', 'Cardiología', 'Buenos Aires', 'Av. Corrientes 1234');"
```

## 📊 Verificar Datos

```powershell
# Contar profesionales
docker exec poc_db psql -U app -d salud_poc -c "SELECT COUNT(*) FROM professionals;"

# Ver distribución por ciudad
docker exec poc_db psql -U app -d salud_poc -c "SELECT city, COUNT(*) FROM professionals GROUP BY city;"

# Ver todos los profesionales
docker exec poc_db psql -U app -d salud_poc -c "SELECT * FROM professionals LIMIT 10;"
```

## 🗑️ Limpiar Datos (Opcional)

```powershell
# Eliminar todos los profesionales
docker exec poc_db psql -U app -d salud_poc -c "DELETE FROM professionals;"

# Reiniciar secuencia de IDs
docker exec poc_db psql -U app -d salud_poc -c "ALTER SEQUENCE professionals_id_seq RESTART WITH 1;"
```

## 📋 Datos que se Insertan

El script inserta **120 profesionales** distribuidos así:

- **10 provincias**: Buenos Aires, Córdoba, Santa Fe, Misiones, Mendoza, San Juan, San Luis, La Pampa, Neuquén, Tucumán
- **12 especialidades** por provincia:
  - Cardiología (2 profesionales)
  - Dermatología (2 profesionales)
  - Neumología (1 profesional)
  - Ginecología (1 profesional)
  - Pediatría (1 profesional)
  - Oftalmología (1 profesional)
  - Otorrinolaringología (1 profesional)
  - Neurología (1 profesional)
  - Urología (1 profesional)
  - Traumatología (1 profesional)

## 🎯 Después de Insertar

1. **Verifica en la aplicación Blazor**:
   - Ve a "Profesionales"
   - Haz clic en "Buscar" (sin filtros)
   - Deberías ver 120 profesionales en la tabla

2. **Prueba filtros**:
   - Busca por especialidad: "Cardiología"
   - Busca por ciudad: "Buenos Aires"
   - Busca por plan: "PLAN_300" (si tienes datos de planes)

## 🔍 Troubleshooting

### Error: "base de datos no existe"
```powershell
# Verificar que el contenedor esté corriendo
docker ps | Select-String "poc_db"

# Iniciar solo la base de datos si no está corriendo
docker-compose up db
```

### Error: "tabla professionals no existe"
```powershell
# Verificar estructura de la base de datos
docker exec poc_db psql -U app -d salud_poc -c "\dt"

# Si la tabla no existe, ejecutar el script de inicialización
docker exec -i poc_db psql -U app -d salud_poc < docker/db/init.sql
```

### Error de permisos
```powershell
# Verificar conexión a la base de datos
docker exec poc_db psql -U app -d salud_poc -c "SELECT 1;"
```

## 📞 Comandos de Verificación Rápida

```powershell
# Todo en uno
Write-Host "=== Verificación de Profesionales ===" -ForegroundColor Cyan
docker exec poc_db psql -U app -d salud_poc -c "SELECT COUNT(*) as total FROM professionals;"
docker exec poc_db psql -U app -d salud_poc -c "SELECT specialty, COUNT(*) FROM professionals GROUP BY specialty ORDER BY COUNT(*) DESC;"
docker exec poc_db psql -U app -d salud_poc -c "SELECT city, COUNT(*) FROM professionals GROUP BY city ORDER BY city;"
```
