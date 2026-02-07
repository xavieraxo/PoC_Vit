# Script PowerShell para insertar profesionales médicos
# Ejecuta el archivo SQL insert_professionals.sql en la base de datos

Write-Host "=== Script para Insertar Profesionales Médicos ===" -ForegroundColor Cyan
Write-Host ""

# Verificar si Docker está corriendo
$dockerRunning = docker ps 2>$null
if (-not $dockerRunning) {
    Write-Host "❌ Error: Docker no está corriendo." -ForegroundColor Red
    Write-Host "Ejecuta 'docker-compose up' primero." -ForegroundColor Yellow
    exit 1
}

# Verificar si el contenedor de la base de datos está corriendo
$dbContainer = docker ps --filter "name=poc_db" --format "{{.Names}}"
if (-not $dbContainer) {
    Write-Host "❌ Error: El contenedor de la base de datos no está corriendo." -ForegroundColor Red
    Write-Host "Ejecuta 'docker-compose up db' primero." -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Docker está corriendo" -ForegroundColor Green
Write-Host "✅ Contenedor de base de datos encontrado: $dbContainer" -ForegroundColor Green
Write-Host ""

# Verificar que el archivo SQL existe
$sqlFile = "scripts/insert_professionals.sql"
if (-not (Test-Path $sqlFile)) {
    Write-Host "❌ Error: No se encuentra el archivo $sqlFile" -ForegroundColor Red
    exit 1
}

Write-Host "📄 Archivo SQL encontrado: $sqlFile" -ForegroundColor Green
Write-Host ""

# Mostrar estadísticas antes de la inserción
Write-Host "📊 Verificando estado actual de la base de datos..." -ForegroundColor Yellow
try {
    $currentCount = docker exec poc_db psql -U app -d salud_poc -t -c "SELECT COUNT(*) FROM professionals;" 2>$null
    if ($currentCount) {
        Write-Host "Profesionales actuales en la base de datos: $($currentCount.Trim())" -ForegroundColor Cyan
    }
} catch {
    Write-Host "No se pudo obtener el conteo actual (base de datos nueva o tabla vacía)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🚀 Ejecutando script de inserción..." -ForegroundColor Yellow

# Ejecutar el script SQL
try {
    $result = docker exec -i poc_db psql -U app -d salud_poc < $sqlFile 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ ¡Script ejecutado exitosamente!" -ForegroundColor Green
        Write-Host ""
        
        # Mostrar estadísticas después de la inserción
        Write-Host "📊 Verificando resultado..." -ForegroundColor Yellow
        $newCount = docker exec poc_db psql -U app -d salud_poc -t -c "SELECT COUNT(*) FROM professionals;" 2>$null
        if ($newCount) {
            Write-Host "Total de profesionales en la base de datos: $($newCount.Trim())" -ForegroundColor Green
        }
        
        # Mostrar distribución por ciudad
        Write-Host ""
        Write-Host "📍 Distribución por ciudad:" -ForegroundColor Cyan
        docker exec poc_db psql -U app -d salud_poc -c "SELECT city, COUNT(*) as profesionales FROM professionals GROUP BY city ORDER BY city;"
        
        Write-Host ""
        Write-Host "🎉 ¡Profesionales insertados correctamente!" -ForegroundColor Green
        Write-Host "Ahora puedes probar la búsqueda en tu aplicación Blazor." -ForegroundColor Cyan
        
    } else {
        Write-Host "❌ Error al ejecutar el script SQL:" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "❌ Error inesperado: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== Proceso Completado ===" -ForegroundColor Cyan
