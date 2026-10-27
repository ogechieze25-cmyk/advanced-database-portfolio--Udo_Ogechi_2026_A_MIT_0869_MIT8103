# MIT 8103 Advanced Database Systems Portfolio

**Student:** Udo Ogechi
**Matric No:** 2026/A/MIT/0869
**Programme:** Master of Information Technology, MIVA Open University
**Course:** MIT 8103 Advanced Database Systems (2026/2027 First Semester)

---

## Selected Case Study: CarePoint Specialist Hospital, Lagos (Simulated)

| Item | Description |
|---|---|
| **Nature of business** | Private hospital offering outpatient consultations, diagnosis, laboratory tests and pharmacy services |
| **Database users** | Receptionists, doctors, nurses, lab scientists, pharmacists, billing staff, administrators |
| **Major data** | Patients, doctors, departments, appointments, diagnoses, prescriptions, medications, lab tests, payments |
| **Key operations** | Register patients, book appointments, record diagnoses, issue prescriptions, record lab results, process payments, retrieve patient history |

The same case study is used consistently across all five portfolio activities.

---

## Portfolio Contents

| Portfolio | Activity | What it contains |
|---|---|---|
| [Portfolio 1](portfolio-1-database-design/) | Database Design and Modelling | Case study, ER diagram, SQL schema (9 tables), keys, constraints, normalisation to 3NF |
| [Portfolio 2](portfolio-2-query-optimisation/) | Query Processing and Optimisation | Query with execution plans before/after indexing; about 144x faster (15.589 ms → 0.108 ms) |
| [Portfolio 3](portfolio-3-transactions-concurrency/) | Transactions and Concurrency | COMMIT, ROLLBACK, failed transaction, double-booking prevention, SERIALIZABLE isolation, row locking |
| [Portfolio 4](portfolio-4-nosql/) | NoSQL and Advanced Data Models | MongoDB document model for patient records, 3 queries incl. aggregation, suitability analysis |
| [Portfolio 5](portfolio-5-distributed-cloud/) | Distributed and Cloud Database | Multi-branch design: replication, sharding, availability, CAP consistency, cloud deployment |

---

## Tools Used

| Tool | Purpose |
|---|---|
| PostgreSQL 18 (via DB Fiddle) | Relational database: Portfolios 1, 2, 3 |
| MongoDB 8.0 (via Mongo Playground) | Document database: Portfolio 4 |
| dbdiagram.io | ER diagram: Portfolio 1 |
| GitHub | Version control and evidence of progressive work |

## Repository Structure

```
├── portfolio-1-database-design/      README, ER diagram, schema.sql
├── portfolio-2-query-optimisation/   README, before/after execution plan screenshots
├── portfolio-3-transactions-concurrency/   README, transaction result screenshots
├── portfolio-4-nosql/                README, query screenshots, patients.json
├── portfolio-5-distributed-cloud/    README with architecture diagram and configuration
└── README.md                         this file
```

---

## AI Use Declaration

- **AI tool used:** Claude (Anthropic)
- **What it was used for:** step-by-step guidance on using GitHub, DB Fiddle and Mongo Playground; drafting SQL and MongoDB code; and drafting explanations in the README files.
- **How the output was reviewed and verified:** I ran all SQL and MongoDB code myself in DB Fiddle (PostgreSQL 18) and Mongo Playground (MongoDB 8.0), checked that every result matched the expected outcome, and captured screenshots of the actual outputs as evidence. I reviewed the explanations against my results and the course brief, and I take responsibility for the accuracy and understanding of all submitted work.
