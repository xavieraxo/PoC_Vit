# Script para verificar que los profesionales se insertaron correctamente

Write-Host "=== Verificación de Datos de Profesionales ===" -ForegroundColor Cyan
Write-Host ""

# Verificar conexión a la base de datos
try {
    $connectionTest = docker exec poc_db psql -U app -d salud_poc -t -c "SELECT 1;" 2>$null
    if ($connectionTest) {
        Write-Host "✅ Conexión a la base de datos: OK" -ForegroundColor Green
    } else {
        Write-Host "❌ Error: No se puede conectar a la base de datos" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Error: Base de datos no disponible" -ForegroundColor Red
    Write-Host "Ejecuta 'docker-compose up db' primero." -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# 1. Contar total de profesionales
Write-Host "📊 1. Total de profesionales:" -ForegroundColor Yellow
try {
    $totalCount = docker exec poc_db psql -U app -d salud_poc -t -c "SELECT COUNT(*) FROM professionals;" 2>$null
    if ($totalCount) {
        $count = $totalCount.Trim()
        Write-Host "   Total: $count profesionales" -ForegroundColor Cyan
        
        if ([int]$count -eq 120) {
            Write-Host "   ✅ Cantidad correcta (120 esperados)" -ForegroundColor Green
        } elseif ([int]$count -gt 0) {
            Write-Host "   ⚠️  Cantidad diferente a la esperada (120)" -ForegroundColor Yellow
        } else {
            Write-Host "   ❌ No hay profesionales en la base de datos" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "   ❌ Error al contar profesionales" -ForegroundColor Red
}

Write-Host ""

# 2. Verificar distribución por ciudad
Write-Host "📍 2. Distribución por ciudad:" -ForegroundColor Yellow
try {
    $cities = docker exec poc_db psql -U app -d salud_poc -c "SELECT city, COUNT(*) as profesionales FROM professionals GROUP BY city ORDER BY city;" 2>$null
    Write-Host $cities -ForegroundColor Cyan
    
    # Verificar que hay 10 ciudades (provincias)
    $cityCount = docker exec poc_db psql -U app -d salud_poc -t -c "SELECT COUNT(DISTINCT city) FROM professionals;" 2>$null
    if ($cityCount) {
        $cityNum = $cityCount.Trim()
        Write-Host "   Ciudades únicas: $cityNum" -ForegroundColor Cyan
        if ([int]$cityNum -eq 10) {
            Write-Host "   ✅ Cantidad correcta de ciudades (10 esperadas)" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Cantidad de ciudades diferente a la esperada (10)" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "   ❌ Error al verificar ciudades" -ForegroundColor Red
}

Write-Host ""

# 3. Verificar especialidades
Write-Host "🩺 3. Especialidades disponibles:" -ForegroundColor Yellow
try {
    $specialties = docker exec poc_db psql -U app -d salud_poc -c "SELECT specialty, COUNT(*) as cantidad FROM professionals GROUP BY specialty ORDER BY specialty;" 2>$null
    Write-Host $specialties -ForegroundColor Cyan
    
    # Verificar que hay 12 especialidades
    $specialtyCount = docker exec poc_db psql -U app -d salud_poc -t -c "SELECT COUNT(DISTINCT specialty) FROM professionals;" 2>$null
    if ($specialtyCount) {
        $specialtyNum = $specialtyCount.Trim()
        Write-Host "   Especialidades únicas: $specialtyNum" -ForegroundColor Cyan
        if ([int]$specialtyNum -eq 12) {
            Write-Host "   ✅ Cantidad correcta de especialidades (12 esperadas)" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Cantidad de especialidades diferente a la esperada (12)" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "   ❌ Error al verificar especialidades" -ForegroundColor Red
}

Write-Host ""

# 4. Mostrar algunos ejemplos
Write-Host "👨‍⚕️ 4. Ejemplos de profesionales:" -ForegroundColor Yellow
try {
    $examples = docker exec poc_db psql -U app -d salud_poc -c "SELECT id, name, specialty, city FROM professionals ORDER BY id LIMIT 5;" 2>$null
    Write-Host $examples -ForegroundColor Cyan
} catch {
    Write-Host "   ❌ Error al mostrar ejemplos" -ForegroundColor Red
}

Write-Host ""

# 5. Verificar integridad de datos
Write-Host "🔍 5. Verificación de integridad:" -ForegroundColor Yellow
try {
    # Verificar que no hay nombres vacíos
    $emptyNames = docker exec poc_db psql -U app -d salud_poc -t -c "SELECT COUNT(*) FROM professionals WHERE name IS NULL OR name = '';" 2>$null
    if ($emptyNames) {
        $empty = $emptyNames.Trim()
        if ([int]$empty -eq 0) {
            Write-Host "   ✅ No hay nombres vacíos" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Hay $empty profesionales con nombres vacíos" -ForegroundColor Yellow
        }
    }
    
    # Verificar que no hay especialidades vacías
    $emptySpecialties = docker exec poc_db psql -U app -d salud_poc -t -c "SELECT COUNT(*) FROM professionals WHERE specialty IS NULL OR specialty = '';" 2>$null
    if ($emptySpecialties) {
        $empty = $emptySpecialties.Trim()
        if ([int]$empty -eq 0) {
            Write-Host "   ✅ No hay especialidades vacías" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Hay $empty profesionales con especialidades vacías" -ForegroundColor Yellow
        }
    }
    
    # Verificar que no hay ciudades vacías
    $emptyCities = docker exec poc_db psql -U app -d salud_poc -t -c "SELECT COUNT(*) FROM professionals WHERE city IS NULL OR city = '';" 2>$null
    if ($emptyCities) {
        $empty = $emptyCities.Trim()
        if ([int]$empty -eq 0) {
            Write-Host "   ✅ No hay ciudades vacías" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Hay $empty profesionales con ciudades vacías" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "   ❌ Error en verificación de integridad" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Resumen ===" -ForegroundColor Cyan
Write-Host "Si todos los checks muestran ✅, los datos están correctos." -ForegroundColor Green
Write-Host "Si ves ⚠️, revisa los datos o ejecuta nuevamente el script de inserción." -ForegroundColor Yellow
Write-Host "Si ves ❌, hay errores que necesitan ser corregidos." -ForegroundColor Red
Write-Host ""
Write-Host "🎯 Próximo paso: Prueba la búsqueda en tu aplicación Blazor" -ForegroundColor Cyan
