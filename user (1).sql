-- Remove unsupported extensions (you don't have superuser access)
-- CREATE EXTENSION cube;

-- Safely drop custom types if they exist
DROP TYPE IF EXISTS user_role CASCADE;
DROP TYPE IF EXISTS gender_type CASCADE;
DROP TYPE IF EXISTS appointment_status CASCADE;
DROP TYPE IF EXISTS payment_method CASCADE;
DROP TYPE IF EXISTS payment_status CASCADE;
DROP TYPE IF EXISTS document_type CASCADE;
DROP TYPE IF EXISTS notification_type CASCADE;

-- Recreate types
CREATE TYPE user_role AS ENUM ('doctor', 'patient', 'admin');
CREATE TYPE gender_type AS ENUM ('male', 'female', 'other');
CREATE TYPE appointment_status AS ENUM ('scheduled', 'completed', 'cancelled');
CREATE TYPE payment_method AS ENUM ('cash', 'card', 'online');
CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'failed');
CREATE TYPE document_type AS ENUM ('prescription', 'report', 'invoice');
CREATE TYPE notification_type AS ENUM ('email', 'sms', 'push');

-- Function to generate unique user codes
CREATE OR REPLACE FUNCTION generate_user_code()
RETURNS TRIGGER AS $$
BEGIN
  NEW.user_code := 'USR' || LPAD((SELECT COUNT(*) + 1 FROM users)::text, 5, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to generate appointment codes
CREATE OR REPLACE FUNCTION generate_appointment_code()
RETURNS TRIGGER AS $$
BEGIN
  NEW.appointment_code := 'APT' || LPAD((SELECT COUNT(*) + 1 FROM appointments)::text, 5, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Example table: users
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  role user_role NOT NULL,
  gender gender_type,
  user_code VARCHAR(10)
);

-- Example table: appointments
CREATE TABLE IF NOT EXISTS appointments (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(id),
  date TIMESTAMP NOT NULL,
  status appointment_status DEFAULT 'scheduled',
  appointment_code VARCHAR(10)
);

-- Trigger for user code generation
CREATE TRIGGER user_code_trigger
BEFORE INSERT ON users
FOR EACH ROW
EXECUTE PROCEDURE generate_user_code();

-- Trigger for appointment code generation
CREATE TRIGGER appointment_code_trigger
BEFORE INSERT ON appointments
FOR EACH ROW
EXECUTE PROCEDURE generate_appointment_code();
