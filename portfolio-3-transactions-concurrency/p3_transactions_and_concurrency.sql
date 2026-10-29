-- =====================================================================
-- Portfolio 3: Transactions and Concurrency
-- Case study: CarePoint Specialist Hospital, Lagos (simulated)
-- DBMS: PostgreSQL 18, run online in DB Fiddle (db-fiddle.com)
--
-- How to run:
--   Part A (schema + sample data) goes in the "Schema SQL" panel.
--   Part B (tests) goes in the "Query SQL" panel. Then click Run.
-- Evidence: p3-commit-rollback.png, p3-failed-dispense-double-booking.png
--           and p3-isolation-locking.png in this folder.
-- =====================================================================

-- =========================== PART A ==================================
-- Schema + sample data

CREATE TABLE departments (
  dept_id SERIAL PRIMARY KEY,
  dept_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE doctors (
  doctor_id SERIAL PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  dept_id INT NOT NULL REFERENCES departments(dept_id)
);

CREATE TABLE patients (
  patient_id SERIAL PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL
);

CREATE TABLE appointments (
  appt_id SERIAL PRIMARY KEY,
  patient_id INT NOT NULL REFERENCES patients(patient_id),
  doctor_id INT NOT NULL REFERENCES doctors(doctor_id),
  appt_date DATE NOT NULL,
  appt_time TIME NOT NULL,
  status VARCHAR(20) DEFAULT 'Scheduled',
  UNIQUE (doctor_id, appt_date, appt_time)
);

CREATE TABLE medications (
  med_id SERIAL PRIMARY KEY,
  med_name VARCHAR(100) NOT NULL UNIQUE,
  stock_qty INT NOT NULL CHECK (stock_qty >= 0)
);

CREATE TABLE payments (
  payment_id SERIAL PRIMARY KEY,
  appt_id INT REFERENCES appointments(appt_id),
  amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
  method VARCHAR(20)
);

INSERT INTO departments (dept_name) VALUES ('Cardiology'), ('General Medicine');
INSERT INTO doctors (first_name, last_name, dept_id) VALUES
  ('Adaeze', 'Okafor', 1), ('Musa', 'Bello', 2);
INSERT INTO patients (first_name, last_name) VALUES
  ('Chinedu', 'Eze'), ('Aisha', 'Musa'), ('Tunde', 'Adeyemi');
INSERT INTO medications (med_name, stock_qty) VALUES
  ('Paracetamol', 100), ('Amoxicillin', 5);

-- =========================== PART B ==================================
-- Transaction tests

-- TEST 1: COMMIT (book an appointment and record payment together)
-- Result: appointment 1 for Chinedu and a 15000.00 card payment both saved
BEGIN;
INSERT INTO appointments (patient_id, doctor_id, appt_date, appt_time)
VALUES (1, 1, '2026-11-02', '09:00');
INSERT INTO payments (appt_id, amount, method)
VALUES (currval('appointments_appt_id_seq'), 15000, 'Card');
COMMIT;
SELECT 'Test 1: after COMMIT' AS test, a.appt_id, p.first_name AS patient,
       a.appt_date, a.appt_time, pay.amount
FROM appointments a
JOIN patients p ON p.patient_id = a.patient_id
JOIN payments pay ON pay.appt_id = a.appt_id;

-- TEST 2: ROLLBACK (cancel a mistaken stock update)
-- Result: stock shows 70 inside the transaction, back to 100 after ROLLBACK
BEGIN;
UPDATE medications SET stock_qty = stock_qty - 30 WHERE med_name = 'Paracetamol';
SELECT 'Test 2: inside transaction' AS test, med_name, stock_qty
FROM medications WHERE med_name = 'Paracetamol';
ROLLBACK;
SELECT 'Test 2: after ROLLBACK' AS test, med_name, stock_qty
FROM medications WHERE med_name = 'Paracetamol';

-- TEST 3: Failed dispense (10 Amoxicillin requested, only 5 in stock)
-- Result: amoxicillin_stock = 5, aisha_appointments = 0 (nothing half-saved)
BEGIN;
INSERT INTO appointments (patient_id, doctor_id, appt_date, appt_time)
VALUES (2, 2, '2026-11-02', '10:00');
UPDATE medications SET stock_qty = stock_qty - 10
WHERE med_name = 'Amoxicillin' AND stock_qty >= 10
RETURNING med_name, stock_qty;   -- returns 0 rows: not enough stock
ROLLBACK;
SELECT 'Test 3: after failed dispense' AS test,
       (SELECT stock_qty FROM medications WHERE med_name = 'Amoxicillin') AS amoxicillin_stock,
       (SELECT COUNT(*) FROM appointments WHERE patient_id = 2) AS aisha_appointments;

-- TEST 4: Concurrency issue (two receptionists book Dr Okafor at the same slot)
-- Result: second booking returns no appt_id; only Tunde holds the 11:00 slot
-- Receptionist A
INSERT INTO appointments (patient_id, doctor_id, appt_date, appt_time)
VALUES (3, 1, '2026-11-03', '11:00');
-- Receptionist B (same doctor, date and time)
INSERT INTO appointments (patient_id, doctor_id, appt_date, appt_time)
VALUES (2, 1, '2026-11-03', '11:00')
ON CONFLICT (doctor_id, appt_date, appt_time) DO NOTHING
RETURNING appt_id;
SELECT 'Test 4: bookings for this slot' AS test, a.appt_id, p.first_name AS patient,
       a.appt_date, a.appt_time
FROM appointments a
JOIN patients p ON p.patient_id = a.patient_id
WHERE a.doctor_id = 1 AND a.appt_date = '2026-11-03' AND a.appt_time = '11:00';

-- TEST 5: Isolation level and row locking
-- Result: transaction_isolation = serializable; row locked at 100; final stock 98
BEGIN ISOLATION LEVEL SERIALIZABLE;
SHOW transaction_isolation;
SELECT med_name, stock_qty FROM medications WHERE med_name = 'Paracetamol' FOR UPDATE;
UPDATE medications SET stock_qty = stock_qty - 2 WHERE med_name = 'Paracetamol';
COMMIT;
SELECT 'Test 5: after locked update' AS test, med_name, stock_qty
FROM medications WHERE med_name = 'Paracetamol';
