-- Online SQL Editor to Run SQL Online.
-- Use the editor to create new tables, insert data and all other SQL operations.
  
-- 1. Create the database (run this as superuser or skip if you already have one)
-- CREATE DATABASE consultants;

-- 2. Connect to the database
-- \c consultants;

-- 3. Drop custom types safely
DROP TYPE IF EXISTS consultant_specialization CASCADE;
DROP TYPE IF EXISTS consultant_gender CASCADE;
DROP TYPE IF EXISTS appointment_status CASCADE;
DROP TYPE IF EXISTS payment_status CASCADE;
DROP TYPE IF EXISTS payment_method CASCADE;

-- 4. Create ENUM types
CREATE TYPE consultant_specialization AS ENUM ('nutritionist', 'psychologist', 'fitness_trainer', 'general_consultant');
CREATE TYPE consultant_gender AS ENUM ('male', 'female', 'other');
CREATE TYPE appointment_status AS ENUM ('scheduled', 'completed', 'cancelled');
CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'failed');
CREATE TYPE payment_method AS ENUM ('cash', 'card', 'online');

-- 5. Function to generate consultant code
CREATE OR REPLACE FUNCTION generate_consultant_code()
RETURNS TRIGGER AS $$
BEGIN
  NEW.consultant_code := 'CON' || LPAD((SELECT COUNT(*) + 1 FROM consultants)::text, 5, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 6. Function to generate appointment code
CREATE OR REPLACE FUNCTION generate_consultant_appointment_code()
RETURNS TRIGGER AS $$
BEGIN
  NEW.appointment_code := 'APT' || LPAD((SELECT COUNT(*) + 1 FROM consultant_appointments)::text, 5, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 7. Consultants table
CREATE TABLE IF NOT EXISTS consultants (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  phone VARCHAR(15),
  gender consultant_gender,
  specialization consultant_specialization NOT NULL,
  experience_years INT DEFAULT 0,
  consultant_code VARCHAR(10),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. Clients table
CREATE TABLE IF NOT EXISTS clients (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE,
  phone VARCHAR(15),
  gender consultant_gender,
  age INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 9. Consultant Appointments table
CREATE TABLE IF NOT EXISTS consultant_appointments (
  id SERIAL PRIMARY KEY,
  consultant_id INT REFERENCES consultants(id),
  client_id INT REFERENCES clients(id),
  appointment_date TIMESTAMP NOT NULL,
  status appointment_status DEFAULT 'scheduled',
  notes TEXT,
  appointment_code VARCHAR(10),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 10. Payments table
CREATE TABLE IF NOT EXISTS consultant_payments (
  id SERIAL PRIMARY KEY,
  appointment_id INT REFERENCES consultant_appointments(id),
  amount DECIMAL(10,2) NOT NULL,
  method payment_method DEFAULT 'online',
  status payment_status DEFAULT 'pending',
  payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 11. Triggers for automatic codes
CREATE TRIGGER consultant_code_trigger
BEFORE INSERT ON consultants
FOR EACH ROW
EXECUTE PROCEDURE generate_consultant_code();

CREATE TRIGGER consultant_appointment_code_trigger
BEFORE INSERT ON consultant_appointments
FOR EACH ROW
EXECUTE PROCEDURE generate_consultant_appointment_code();

