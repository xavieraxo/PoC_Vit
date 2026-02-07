-- Script para insertar profesionales médicos en la base de datos
-- Basado en datos de 10 provincias con 12 profesionales cada una
-- Total: 120 profesionales

-- Primero, limpiar datos existentes (opcional - descomenta si quieres empezar limpio)
-- DELETE FROM professionals;

-- Insertar profesionales por provincia
-- ======================================

-- BUENOS AIRES
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Juan Pérez', 'Cardiología', 'Buenos Aires', 'Av. Corrientes 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. María Gómez', 'Cardiología', 'Buenos Aires', 'Av. Santa Fe 5678');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Pablo Ruiz', 'Dermatología', 'Buenos Aires', 'Av. Córdoba 9012');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Laura Fernández', 'Dermatología', 'Buenos Aires', 'Av. Callao 3456');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Carlos López', 'Neumología', 'Buenos Aires', 'Av. 9 de Julio 7890');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Ana Torres', 'Ginecología', 'Buenos Aires', 'Av. Rivadavia 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Martín Castro', 'Pediatría', 'Buenos Aires', 'Av. Cabildo 5678');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Sofía Molina', 'Oftalmología', 'Buenos Aires', 'Av. Scalabrini Ortiz 9012');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Diego Rojas', 'Otorrinolaringología', 'Buenos Aires', 'Av. Santa Fe 3456');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Valeria Silva', 'Neurología', 'Buenos Aires', 'Av. Corrientes 7890');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Ricardo Núñez', 'Urología', 'Buenos Aires', 'Av. Córdoba 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Clara Pérez', 'Traumatología', 'Buenos Aires', 'Av. Callao 5678');

-- CÓRDOBA
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Juan Pérez', 'Cardiología', 'Córdoba', 'Av. Colón 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. María Gómez', 'Cardiología', 'Córdoba', 'Av. Vélez Sarsfield 5678');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Pablo Ruiz', 'Dermatología', 'Córdoba', 'Av. Hipólito Yrigoyen 9012');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Laura Fernández', 'Dermatología', 'Córdoba', 'Av. Duarte Quirós 3456');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Carlos López', 'Neumología', 'Córdoba', 'Av. Gral. Paz 7890');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Ana Torres', 'Ginecología', 'Córdoba', 'Av. San Martín 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Martín Castro', 'Pediatría', 'Córdoba', 'Av. Maipú 5678');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Sofía Molina', 'Oftalmología', 'Córdoba', 'Av. Figueroa Alcorta 9012');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Diego Rojas', 'Otorrinolaringología', 'Córdoba', 'Av. Rafael Núñez 3456');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Valeria Silva', 'Neurología', 'Córdoba', 'Av. 27 de Abril 7890');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Ricardo Núñez', 'Urología', 'Córdoba', 'Av. Olmos 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Clara Pérez', 'Traumatología', 'Córdoba', 'Av. Deodoro Roca 5678');

-- SANTA FE
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Juan Pérez', 'Cardiología', 'Santa Fe', 'Av. General López 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. María Gómez', 'Cardiología', 'Santa Fe', 'Av. Blas Parera 5678');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Pablo Ruiz', 'Dermatología', 'Santa Fe', 'Av. 25 de Mayo 9012');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Laura Fernández', 'Dermatología', 'Santa Fe', 'Av. San Martín 3456');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Carlos López', 'Neumología', 'Santa Fe', 'Av. Rivadavia 7890');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Ana Torres', 'Ginecología', 'Santa Fe', 'Av. Freyre 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Martín Castro', 'Pediatría', 'Santa Fe', 'Av. Aristóbulo del Valle 5678');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Sofía Molina', 'Oftalmología', 'Santa Fe', 'Av. Peatonal San Martín 9012');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Diego Rojas', 'Otorrinolaringología', 'Santa Fe', 'Av. Gral. Paz 3456');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Valeria Silva', 'Neurología', 'Santa Fe', 'Av. Belgrano 7890');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Ricardo Núñez', 'Urología', 'Santa Fe', 'Av. Constituyentes 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Clara Pérez', 'Traumatología', 'Santa Fe', 'Av. Costanera 5678');

-- MISIONES
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Juan Pérez', 'Cardiología', 'Misiones', 'Av. San Martín 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. María Gómez', 'Cardiología', 'Misiones', 'Av. Quaranta 5678');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Pablo Ruiz', 'Dermatología', 'Misiones', 'Av. Uruguay 9012');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Laura Fernández', 'Dermatología', 'Misiones', 'Av. Rivadavia 3456');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Carlos López', 'Neumología', 'Misiones', 'Av. Libertador 7890');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Ana Torres', 'Ginecología', 'Misiones', 'Av. Sarmiento 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Martín Castro', 'Pediatría', 'Misiones', 'Av. Belgrano 5678');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Sofía Molina', 'Oftalmología', 'Misiones', 'Av. Cabred 9012');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Diego Rojas', 'Otorrinolaringología', 'Misiones', 'Av. López y Planes 3456');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Valeria Silva', 'Neurología', 'Misiones', 'Av. Jauretche 7890');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Ricardo Núñez', 'Urología', 'Misiones', 'Av. Costanera 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Clara Pérez', 'Traumatología', 'Misiones', 'Av. Don Bosco 5678');

-- MENDOZA
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Juan Pérez', 'Cardiología', 'Mendoza', 'Av. San Martín 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. María Gómez', 'Cardiología', 'Mendoza', 'Av. Las Heras 5678');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Pablo Ruiz', 'Dermatología', 'Mendoza', 'Av. Colón 9012');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Laura Fernández', 'Dermatología', 'Mendoza', 'Av. Perú 3456');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Carlos López', 'Neumología', 'Mendoza', 'Av. Mitre 7890');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Ana Torres', 'Ginecología', 'Mendoza', 'Av. Godoy Cruz 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Martín Castro', 'Pediatría', 'Mendoza', 'Av. Belgrano 5678');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Sofía Molina', 'Oftalmología', 'Mendoza', 'Av. Aristides Villanueva 9012');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Diego Rojas', 'Otorrinolaringología', 'Mendoza', 'Av. España 3456');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Valeria Silva', 'Neurología', 'Mendoza', 'Av. Boulogne Sur Mer 7890');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Ricardo Núñez', 'Urología', 'Mendoza', 'Av. Emilio Civit 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Clara Pérez', 'Traumatología', 'Mendoza', 'Av. Libertador 5678');

-- SAN JUAN
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Juan Pérez', 'Cardiología', 'San Juan', 'Av. Libertador 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. María Gómez', 'Cardiología', 'San Juan', 'Av. San Martín 5678');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Pablo Ruiz', 'Dermatología', 'San Juan', 'Av. Rawson 9012');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Laura Fernández', 'Dermatología', 'San Juan', 'Av. Córdoba 3456');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Carlos López', 'Neumología', 'San Juan', 'Av. 25 de Mayo 7890');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Ana Torres', 'Ginecología', 'San Juan', 'Av. Ignacio de la Roza 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Martín Castro', 'Pediatría', 'San Juan', 'Av. Leandro N. Alem 5678');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Sofía Molina', 'Oftalmología', 'San Juan', 'Av. José de San Martín 9012');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Diego Rojas', 'Otorrinolaringología', 'San Juan', 'Av. Mendoza 3456');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Valeria Silva', 'Neurología', 'San Juan', 'Av. Sarmiento 7890');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Ricardo Núñez', 'Urología', 'San Juan', 'Av. España 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Clara Pérez', 'Traumatología', 'San Juan', 'Av. Rivadavia 5678');

-- SAN LUIS
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Juan Pérez', 'Cardiología', 'San Luis', 'Av. Illia 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. María Gómez', 'Cardiología', 'San Luis', 'Av. Justo Daract 5678');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Pablo Ruiz', 'Dermatología', 'San Luis', 'Av. Lafinur 9012');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Laura Fernández', 'Dermatología', 'San Luis', 'Av. España 3456');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Carlos López', 'Neumología', 'San Luis', 'Av. Rivadavia 7890');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Ana Torres', 'Ginecología', 'San Luis', 'Av. San Martín 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Martín Castro', 'Pediatría', 'San Luis', 'Av. Mitre 5678');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Sofía Molina', 'Oftalmología', 'San Luis', 'Av. Libertador 9012');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Diego Rojas', 'Otorrinolaringología', 'San Luis', 'Av. Colón 3456');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Valeria Silva', 'Neurología', 'San Luis', 'Av. Pringles 7890');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Ricardo Núñez', 'Urología', 'San Luis', 'Av. Quintana 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Clara Pérez', 'Traumatología', 'San Luis', 'Av. Belgrano 5678');

-- LA PAMPA
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Juan Pérez', 'Cardiología', 'La Pampa', 'Av. San Martín 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. María Gómez', 'Cardiología', 'La Pampa', 'Av. España 5678');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Pablo Ruiz', 'Dermatología', 'La Pampa', 'Av. Rivadavia 9012');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Laura Fernández', 'Dermatología', 'La Pampa', 'Av. 9 de Julio 3456');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Carlos López', 'Neumología', 'La Pampa', 'Av. Luro 7890');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Ana Torres', 'Ginecología', 'La Pampa', 'Av. Mitre 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Martín Castro', 'Pediatría', 'La Pampa', 'Av. Belgrano 5678');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Sofía Molina', 'Oftalmología', 'La Pampa', 'Av. 25 de Mayo 9012');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Diego Rojas', 'Otorrinolaringología', 'La Pampa', 'Av. Donado 3456');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Valeria Silva', 'Neurología', 'La Pampa', 'Av. Colón 7890');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Ricardo Núñez', 'Urología', 'La Pampa', 'Av. San Martín 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Clara Pérez', 'Traumatología', 'La Pampa', 'Av. Centenario 5678');

-- NEUQUÉN
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Juan Pérez', 'Cardiología', 'Neuquén', 'Av. Olascoaga 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. María Gómez', 'Cardiología', 'Neuquén', 'Av. Argentina 5678');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Pablo Ruiz', 'Dermatología', 'Neuquén', 'Av. Roca 9012');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Laura Fernández', 'Dermatología', 'Neuquén', 'Av. San Martín 3456');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Carlos López', 'Neumología', 'Neuquén', 'Av. Argentina 7890');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Ana Torres', 'Ginecología', 'Neuquén', 'Av. Olascoaga 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Martín Castro', 'Pediatría', 'Neuquén', 'Av. Sarmiento 5678');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Sofía Molina', 'Oftalmología', 'Neuquén', 'Av. Rivadavia 9012');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Diego Rojas', 'Otorrinolaringología', 'Neuquén', 'Av. 25 de Mayo 3456');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Valeria Silva', 'Neurología', 'Neuquén', 'Av. Belgrano 7890');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Ricardo Núñez', 'Urología', 'Neuquén', 'Av. España 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Clara Pérez', 'Traumatología', 'Neuquén', 'Av. Libertador 5678');

-- TUCUMÁN
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Juan Pérez', 'Cardiología', 'Tucumán', 'Av. Sarmiento 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. María Gómez', 'Cardiología', 'Tucumán', 'Av. San Martín 5678');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Pablo Ruiz', 'Dermatología', 'Tucumán', 'Av. Rivadavia 9012');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Laura Fernández', 'Dermatología', 'Tucumán', 'Av. 24 de Septiembre 3456');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Carlos López', 'Neumología', 'Tucumán', 'Av. Mitre 7890');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Ana Torres', 'Ginecología', 'Tucumán', 'Av. Colón 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Martín Castro', 'Pediatría', 'Tucumán', 'Av. Belgrano 5678');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Sofía Molina', 'Oftalmología', 'Tucumán', 'Av. España 9012');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Diego Rojas', 'Otorrinolaringología', 'Tucumán', 'Av. 25 de Mayo 3456');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Valeria Silva', 'Neurología', 'Tucumán', 'Av. 9 de Julio 7890');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dr. Ricardo Núñez', 'Urología', 'Tucumán', 'Av. Libertador 1234');
INSERT INTO professionals (name, specialty, city, address) VALUES ('Dra. Clara Pérez', 'Traumatología', 'Tucumán', 'Av. Congreso 5678');

-- Verificar inserción
SELECT COUNT(*) as total_professionals FROM professionals;
SELECT city, COUNT(*) as professionals_per_city FROM professionals GROUP BY city ORDER BY city;
