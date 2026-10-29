-- =====================================================================
-- Portfolio 2: Query Processing and Optimisation
-- Case study: CarePoint Specialist Hospital, Lagos (simulated)
-- DBMS: PostgreSQL 18, run online in DB Fiddle (db-fiddle.com)
--
-- How to run:
--   Part A (schema + sample data) goes in the "Schema SQL" panel.
--   Part B (queries) goes in the "Query SQL" panel. Then click Run.
-- Evidence: p2-before-index.png and p2-after-index.png in this folder.
-- =====================================================================

-- =========================== PART A ==================================
-- Schema + generated sample data

CREATE TABLE departments (
  dept_id SERIAL PRIMARY KEY,
  dept_name VARCHAR(100) NOT NULL UNIQUE,
  location VARCHAR(100)
);

CREATE TABLE doctors (
  doctor_id SERIAL PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  specialty VARCHAR(100),
  phone VARCHAR(20) UNIQUE,
  email VARCHAR(100) UNIQUE,
  dept_id INT NOT NULL REFERENCES departments(dept_id)
);

CREATE TABLE patients (
  patient_id SERIAL PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  date_of_birth DATE NOT NULL,
  gender VARCHAR(10) CHECK (gender IN ('Male', 'Female')),
  phone VARCHAR(20),
  address VARCHAR(200)
);

CREATE TABLE appointments (
  appt_id SERIAL PRIMARY KEY,
  patient_id INT NOT NULL REFERENCES patients(patient_id),
  doctor_id INT NOT NULL REFERENCES doctors(doctor_id),
  appt_date DATE NOT NULL,
  appt_time TIME NOT NULL,
  status VARCHAR(20) DEFAULT 'Scheduled'
    CHECK (status IN ('Scheduled', 'Completed', 'Cancelled')),
  UNIQUE (doctor_id, appt_date, appt_time)
);

CREATE TABLE payments (
  payment_id SERIAL PRIMARY KEY,
  patient_id INT NOT NULL REFERENCES patients(patient_id),
  appt_id INT REFERENCES appointments(appt_id),
  amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
  method VARCHAR(20) CHECK (method IN ('Cash', 'Card', 'Transfer', 'HMO')),
  payment_date DATE
);

-- 10 departments
INSERT INTO departments (dept_name, location) VALUES
('Cardiology','Block A'), ('Paediatrics','Block B'), ('General Medicine','Block A'),
('Gynaecology','Block C'), ('Orthopaedics','Block D'), ('Dermatology','Block B'),
('Neurology','Block E'), ('ENT','Block C'), ('Ophthalmology','Block D'), ('Laboratory','Block E');

-- 50 doctors
INSERT INTO doctors (first_name, last_name, specialty, phone, email, dept_id)
SELECT 'Doctor' || g, 'Surname' || g, 'Consultant',
       '0800' || lpad(g::text, 7, '0'), 'doctor' || g || '@carepoint.ng', (g % 10) + 1
FROM generate_series(1, 50) g;

-- 20,000 patients
INSERT INTO patients (first_name, last_name, date_of_birth, gender, phone, address)
SELECT (ARRAY['Chinedu','Aisha','Tunde','Ngozi','Emeka','Fatima','Segun','Blessing','Ibrahim','Funmi'])[1 + g % 10],
       (ARRAY['Okafor','Bello','Adeyemi','Eze','Musa','Okonkwo','Balogun','Nwosu','Abubakar','Adebayo'])[1 + (g / 10) % 10],
       DATE '1950-01-01' + (g * 7 % 25000),
       CASE WHEN g % 2 = 0 THEN 'Male' ELSE 'Female' END,
       '0803' || lpad(g::text, 7, '0'), 'Lagos'
FROM generate_series(1, 20000) g;

-- 100,000 appointments (no doctor is double-booked)
INSERT INTO appointments (patient_id, doctor_id, appt_date, appt_time, status)
SELECT (g % 20000) + 1, (g % 50) + 1,
       DATE '2026-01-01' + ((g / 50) / 16),
       TIME '08:00' + ((g / 50) % 16) * INTERVAL '30 minutes',
       (ARRAY['Scheduled','Completed','Cancelled'])[1 + g % 3]
FROM generate_series(0, 99999) g;

-- 33,333 payments (one per completed appointment)
INSERT INTO payments (patient_id, appt_id, amount, method, payment_date)
SELECT patient_id, appt_id, 5000 + (appt_id % 20) * 1000,
       (ARRAY['Cash','Card','Transfer','HMO'])[1 + appt_id % 4], appt_date
FROM appointments WHERE status = 'Completed';

-- Refresh planner statistics
ANALYZE;

-- =========================== PART B ==================================
-- Queries

-- Query 1: Confirm data volume
-- Result: 20000 patients | 100000 appointments | 33333 payments
SELECT (SELECT COUNT(*) FROM patients)     AS patients,
       (SELECT COUNT(*) FROM appointments) AS appointments,
       (SELECT COUNT(*) FROM payments)     AS payments;

-- Query 2: Patient appointment history BEFORE indexing
-- Result: Seq Scan on appointments, 99,995 rows removed by filter,
--         Execution Time: 15.589 ms
EXPLAIN ANALYZE
SELECT a.appt_id, a.appt_date, a.appt_time,
       d.first_name || ' ' || d.last_name AS doctor, a.status
FROM appointments a
JOIN doctors d ON d.doctor_id = a.doctor_id
WHERE a.patient_id = 1234;

-- Query 3: Optimisation - index the frequently searched foreign key
-- (PostgreSQL does not index foreign key columns automatically)
CREATE INDEX idx_appointments_patient ON appointments(patient_id);

-- Query 4: Same query AFTER indexing
-- Result: Bitmap Index Scan on idx_appointments_patient,
--         Execution Time: 0.108 ms (about 144x faster)
EXPLAIN ANALYZE
SELECT a.appt_id, a.appt_date, a.appt_time,
       d.first_name || ' ' || d.last_name AS doctor, a.status
FROM appointments a
JOIN doctors d ON d.doctor_id = a.doctor_id
WHERE a.patient_id = 1234;
