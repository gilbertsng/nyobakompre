# Implementasi Otomatisasi CI/CD dan Validasi dbt Berbasis Maker-Checker-Signer

Repositori ini adalah implementasi praktis untuk proyek kompre/skripsi di bidang **Data Engineering** dan **Data Governance Perbankan** menggunakan alur kerja berbasis tiket (*Ticket-Driven Workflow*).

---

## 🏛️ Konsep Maker-Checker-Signer dalam Data Engineering

Dalam operasional perbankan yang memiliki kepatuhan regulasi ketat (seperti regulasi OJK / Bank Indonesia terkait manajemen risiko TI), perubahan kode pada pipeline data analitik tidak boleh langsung masuk ke lingkungan *Production*.

```
   [ MAKER ]                      [ CI / CD GATEKEEPER ]                   [ CHECKER ]                    [ SIGNER ]
(Data Engineer)                     (GitHub Actions)                  (Lead Data Engineer)          (Data Gov / Manager)
       │                                   │                                    │                              │
       ├─ Ambil Tiket Bisnis              │                                    │                              │
       ├─ Salin Template (.sql & .yml)     │                                    │                              │
       ├─ Buat Folder models/tickets/      │                                    │                              │
       └─ Open Pull Request (PR) ─────────►│                                    │                              │
                                           ├─ dbt debug (Koneksi)               │                              │
                                           ├─ dbt seed  (Database Bank)         │                              │
                                           ├─ dbt compile (Syntax/DAG)          │                              │
                                           ├─ dbt run   (Eksekusi Model Tiket)  │                              │
                                           ├─ dbt test  (Validasi Data Tiket)   │                              │
                                           │                                    │                              │
                                           ├─── GAGAL (Tests Fail) ──► Tolak PR │                              │
                                           │                                    │                              │
                                           └─── SUKSES (All Pass) ─────────────►│                              │
                                                                                ├─ Review Logik & Efisiensi    │
                                                                                └─ Approve PR ────────────────►│
                                                                                                               ├─ Final Approval
                                                                                                               └─ Merge to main
```

---

## 📁 Struktur Repositori

```text
nyobakompre/
├── .github/workflows/
│   └── ci.yml                 # Pipeline CI/CD GitHub Actions (Robot Penguji)
├── seeds/                     # Simulasi Database Core Banking (Tabel Sumber)
│   ├── raw_customers.csv      # Data CIF & KYC Nasabah
│   ├── raw_accounts.csv       # Data Rekening (Tabungan, Giro, Deposito)
│   └── raw_transactions.csv   # Data Mutasi Finansial
├── templates/                 # Template Standar dbt Bank (Di-pull oleh DE)
│   ├── template_query.sql     # Template Penulisan Query SQL
│   └── template_schema.yml    # Template Penulisan Test & Dokumentasi YAML
├── models/
│   └── tickets/               # Folder Tempat DE Menaruh Tiket (query.sql + schema.yml)
├── dbt_project.yml            # Konfigurasi Proyek dbt
├── profiles.yml               # Konfigurasi Koneksi DuckDB (dev & ci)
└── requirements.txt           # Dependensi Python (dbt-duckdb)
```

---

## 💻 Panduan Menjalankan di Lokal (Local Setup)

```bash
# Setup Virtual Environment
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Muat data bank dan uji kompilasi
dbt seed --profiles-dir .
dbt compile --profiles-dir .
```
