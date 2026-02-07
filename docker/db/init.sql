CREATE EXTENSION IF NOT EXISTS vector;
/* Más adelante pegamos acá tu DDL (faqs, documents, chunks, etc.) */
-- Conversaciones
CREATE TABLE IF NOT EXISTS conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  user_id TEXT NULL,
  channel TEXT NULL
);

-- Mensajes
CREATE TABLE IF NOT EXISTS messages (
  id BIGSERIAL PRIMARY KEY,
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('system','user','assistant')),
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Índices útiles
CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);

-- ===== RAG: documentos y chunks =====
-- (ya tenés CREATE EXTENSION vector en el init)

-- Documentos de conocimiento (FAQs, PDFs, cartilla, etc.)
CREATE TABLE IF NOT EXISTS documents (
  id           BIGSERIAL PRIMARY KEY,
  title        TEXT NOT NULL,
  source_uri   TEXT NULL,
  type         TEXT NULL,                            -- faq | pdf | db | otro
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Chunks de texto + embedding
-- IMPORTANTE: definimos dim=768 (nomic-embed-text). Si usás otro modelo, confirmá la dimensión y ajustá.
CREATE TABLE IF NOT EXISTS chunks (
  id            BIGSERIAL PRIMARY KEY,
  document_id   BIGINT NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
  idx           INT NOT NULL,
  content       TEXT NOT NULL,
  embedding     vector(768) NOT NULL
);

-- Índices para búsqueda vectorial
-- Nota: ivfflat requiere ANALYZE antes de ser usado eficientemente
CREATE INDEX IF NOT EXISTS idx_chunks_doc ON chunks(document_id);
CREATE INDEX IF NOT EXISTS idx_chunks_embedding ON chunks USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- Plans (obras / productos)
CREATE TABLE IF NOT EXISTS plans (
  id    BIGSERIAL PRIMARY KEY,
  code  TEXT UNIQUE NOT NULL,
  name  TEXT NOT NULL
);

-- Profesionales
CREATE TABLE IF NOT EXISTS professionals (
  id         BIGSERIAL PRIMARY KEY,
  name       TEXT NOT NULL,
  specialty  TEXT NOT NULL,
  city       TEXT NOT NULL,
  address    TEXT NOT NULL
);

-- Relación N:N profesional ↔ plan
CREATE TABLE IF NOT EXISTS professional_plans (
  professional_id BIGINT NOT NULL REFERENCES professionals(id) ON DELETE CASCADE,
  plan_id         BIGINT NOT NULL REFERENCES plans(id) ON DELETE CASCADE,
  PRIMARY KEY (professional_id, plan_id)
);

-- Slots de agenda
CREATE TABLE IF NOT EXISTS appointment_slots (
  id               BIGSERIAL PRIMARY KEY,
  professional_id  BIGINT NOT NULL REFERENCES professionals(id) ON DELETE CASCADE,
  start_utc        TIMESTAMPTZ NOT NULL,
  end_utc          TIMESTAMPTZ NOT NULL,
  is_booked        BOOLEAN NOT NULL DEFAULT FALSE
);

-- Turnos reservados
CREATE TABLE IF NOT EXISTS appointments (
  id        BIGSERIAL PRIMARY KEY,
  slot_id   BIGINT NOT NULL REFERENCES appointment_slots(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  booked_by TEXT NOT NULL,
  notes     TEXT NULL
);

-- Índices útiles
CREATE INDEX IF NOT EXISTS idx_prof_specialty ON professionals(specialty);
CREATE INDEX IF NOT EXISTS idx_prof_city ON professionals(city);
CREATE INDEX IF NOT EXISTS idx_slot_prof_time ON appointment_slots(professional_id, start_utc);


INSERT INTO plans(code,name) VALUES ('PLAN_A','Plan A') ON CONFLICT DO NOTHING;
INSERT INTO plans(code,name) VALUES ('PLAN_B','Plan B') ON CONFLICT DO NOTHING;

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
--SELECT COUNT(*) as total_professionals FROM professionals;
--SELECT city, COUNT(*) as professionals_per_city FROM professionals GROUP BY city ORDER BY city;

ON CONFLICT DO NOTHING;

-- vincular plan B con cardiología
INSERT INTO professional_plans(professional_id,plan_id)
SELECT p.id, pl.id
FROM professionals p, plans pl
WHERE p.specialty='Cardiología' AND pl.code='PLAN_B'
ON CONFLICT DO NOTHING;

-- slots (ejemplo: hoy a +3h, +4h)
INSERT INTO appointment_slots(professional_id,start_utc,end_utc,is_booked)
SELECT p.id, now() AT TIME ZONE 'UTC' + interval '3 hours', now() AT TIME ZONE 'UTC' + interval '3 hours 20 minutes', false
FROM professionals p WHERE p.specialty='Cardiología';

INSERT INTO appointment_slots(professional_id,start_utc,end_utc,is_booked)
SELECT p.id, now() AT TIME ZONE 'UTC' + interval '4 hours', now() AT TIME ZONE 'UTC' + interval '4 hours 20 minutes', false
FROM professionals p WHERE p.specialty='Cardiología';
