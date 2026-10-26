-- CarePoint Specialist Hospital: Database Schema (PostgreSQL)

CREATE TABLE departments (
  dept_id    SERIAL PRIMARY KEY,
  dept_name  VARCHAR(100) NOT NULL UNIQUE,
  location   VARCHAR(100)
);

CREATE TABLE doctors (
  doctor_id   SERIAL PRIMARY KEY,
  first_name  VARCHAR(50) NOT NULL,
  last_name   VARCHAR(50) NOT NULL,
  specialty   VARCHAR(100),
  phone       VARCHAR(20) UNIQUE,
  email       VARCHAR(100) UNIQUE,
  dept_id     INT NOT NULL REFERENCES departments(dept_id)
);

CREATE TABLE patients (
  patient_id     SERIAL PRIMARY KEY,
  first_name     VARCHAR(50) NOT NULL,
  last_name      VARCHAR(50) NOT NULL,
  date_of_birth  DATE NOT NULL,
  gender         VARCHAR(10) CHECK (gender IN ('Male', 'Female')),
  phone          VARCHAR(20),
  address        VARCHAR(200)
);

CREATE TABLE appointments (
  appt_id     SERIAL PRIMARY KEY,
  patient_id  INT NOT NULL REFERENCES patients(patient_id),
  doctor_id   INT NOT NULL REFERENCES doctors(doctor_id),
  appt_date   DATE NOT NULL,
  appt_time   TIME NOT NULL,
  status      VARCHAR(20) DEFAULT 'Scheduled'
              CHECK (status IN ('Scheduled', 'Completed', 'Cancelled')),
  UNIQUE (doctor_id, appt_date, appt_time)
);

CREATE TABLE diagnoses (
  diagnosis_id  SERIAL PRIMARY KEY,
  appt_id       INT NOT NULL REFERENCES appointments(appt_id),
  description   TEXT NOT NULL
);

CREATE TABLE medications (
  med_id      SERIAL PRIMARY KEY,
  med_name    VARCHAR(100) NOT NULL UNIQUE,
  unit_price  DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
  stock_qty   INT NOT NULL CHECK (stock_qty >= 0)
);

CREATE TABLE prescriptions (
  presc_id  SERIAL PRIMARY KEY,
  appt_id   INT NOT NULL REFERENCES appointments(appt_id),
  med_id    INT NOT NULL REFERENCES medications(med_id),
  dosage    VARCHAR(100),
  quantity  INT NOT NULL CHECK (quantity > 0)
);

CREATE TABLE lab_tests (
  test_id     SERIAL PRIMARY KEY,
  patient_id  INT NOT NULL REFERENCES patients(patient_id),
  doctor_id   INT REFERENCES doctors(doctor_id),
  test_type   VARCHAR(100) NOT NULL,
  result      TEXT,
  test_date   DATE
);

CREATE TABLE payments (
  payment_id    SERIAL PRIMARY KEY,
  patient_id    INT NOT NULL REFERENCES patients(patient_id),
  appt_id       INT REFERENCES appointments(appt_id),
  amount        DECIMAL(10,2) NOT NULL CHECK (amount > 0),
  method        VARCHAR(20) CHECK (method IN ('Cash', 'Card', 'Transfer', 'HMO')),
  payment_date  DATE
);
