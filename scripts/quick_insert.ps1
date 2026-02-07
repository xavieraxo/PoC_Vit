# Script rápido para insertar profesionales
# Versión simplificada para inserción rápida

Write-Host "🚀 Inserción rápida de profesionales..." -ForegroundColor Yellow

# Ejecutar directamente el SQL
docker exec -i poc_db psql -U app -d salud_poc << 'EOF'
-- Insertar algunos profesionales de ejemplo
INSERT INTO professionals (name, specialty, city, address) VALUES 
('Dr. Juan Pérez', 'Cardiología', 'Buenos Aires', 'Av. Corrientes 1234'),
('Dra. María Gómez', 'Cardiología', 'Buenos Aires', 'Av. Santa Fe 5678'),
('Dr. Pablo Ruiz', 'Dermatología', 'Buenos Aires', 'Av. Córdoba 9012'),
('Dra. Laura Fernández', 'Dermatología', 'Córdoba', 'Av. Colón 1234'),
('Dr. Carlos López', 'Neumología', 'Córdoba', 'Av. Vélez Sarsfield 5678'),
('Dra. Ana Torres', 'Ginecología', 'Santa Fe', 'Av. General López 1234'),
('Dr. Martín Castro', 'Pediatría', 'Santa Fe', 'Av. Blas Parera 5678'),
('Dra. Sofía Molina', 'Oftalmología', 'Mendoza', 'Av. San Martín 1234'),
('Dr. Diego Rojas', 'Otorrinolaringología', 'Mendoza', 'Av. Las Heras 5678'),
('Dra. Valeria Silva', 'Neurología', 'Tucumán', 'Av. Sarmiento 1234');

-- Verificar inserción
SELECT COUNT(*) as total_professionals FROM professionals;
SELECT city, COUNT(*) as profesionales FROM professionals GROUP BY city ORDER BY city;
EOF

Write-Host "✅ Profesionales insertados" -ForegroundColor Green
