# Implementasi Otomatisasi CI/CD dan Validasi dbt Berbasis Maker-Checker-Signer

Repositori ini adalah implementasi praktis untuk proyek kompre/skripsi di bidang **Data Engineering** dan **Data Governance Perbankan**. Proyek ini mendemonstrasikan bagaimana skrip transformasi data (`dbt-core`) divalidasi secara otomatis melalui pipeline **GitHub Actions (CI/CD)** menggunakan **DuckDB** sebelum disetujui melalui alur persetujuan hierarkis **Maker-Checker-Signer**.

---

## 🏛️ Konsep Maker-Checker-Signer dalam Data Engineering

Dalam operasional perbankan yang memiliki kepatuhan regulasi ketat (seperti regulasi OJK / Bank Indonesia terkait manajemen risiko TI), perubahan kode pada pipeline data analitik tidak boleh langsung masuk ke lingkungan *Production*.

```
   [ MAKER ]                      [ CI / CD GATEKEEPER ]                   [ CHECKER ]                    [ SIGNER ]
(Data Engineer)                     (GitHub Actions)                  (Lead Data Engineer)          (Data Gov / Manager)
       │                                   │                                    │                              │
       ├─ Buat Feature Branch             │                                    │                              │
       ├─ Tulis Model / Test               │                                    │                              │
       └─ Open Pull Request (PR) ─────────►│                                    │                              │
                                           ├─ dbt debug (Koneksi)               │                              │
                                           ├─ dbt seed  (Mock Data)             │                              │
                                           ├─ dbt compile (Syntax/DAG)          │                              │
                                           ├─ dbt run   (Transformasi)          │                              │
                                           ├─ dbt test  (Data Quality)          │                              │
                                           │                                    │                              │
                                           ├─── GAGAL (Tests Fail) ──► Tolak PR │                              │
                                           │                                    │                              │
                                           └─── SUKSES (All Pass) ─────────────►│                              │
                                                                                ├─ Review Logik & Efisiensi    │
                                                                                └─ Approve PR ────────────────►│
                                                                                                               ├─ Final Approval
                                                                                                               └─ Merge to main
```

1. **Maker (Data Engineer / Analyst)**: Mengembangkan model transformasi data di *feature branch* lokal dan membuat *Pull Request* (PR).
2. **Automated CI Gate (GitHub Actions + DuckDB)**: Sistem otomatis memvalidasi integritas kode dbt (syntax, kompilasi DAG, *run*, dan 30+ pengujian kualitas data). Jika gagal, PR otomatis diblokir.
3. **Checker (Lead / Senior Data Engineer)**: Melakukan *peer-review* terhadap kualitas kode SQL, optimasi performa, dan kesesuaian dokumentasi jika status CI sudah hijau.
4. **Signer (Data Governance Officer / Engineering Manager)**: Memberikan otorisasi akhir untuk menggabungkan (*merge*) kode ke *branch* utama (`main`).

---

## 🏗️ Arsitektur Data Pipeline (Medallion Architecture)

```
[ Seeds (Raw Core Banking) ]
  ├── raw_customers.csv
  ├── raw_accounts.csv
  └── raw_transactions.csv
            │
            ▼
[ Staging Layer (Views) ]
  ├── stg_customers.sql   (Casting tipe data, normalisasi teks email & kyc)
  ├── stg_accounts.sql    (Validasi status rekening & tipe akun)
  └── stg_transactions.sql(Presisi angka desimal & status mutasi)
            │
            ▼
[ Marts Layer (Tables) ]
  ├── fct_customer_transactions.sql (Fakta denormalisasi transaksi lengkap)
  └── dim_customers.sql             (Dimensi nasabah dengan total saldo & ringkasan mutasi)
```

---

## 🧪 Validasi Kualitas Data & Aturan Kepatuhan (Tests)

Proyek ini menerapkan validasi komprehensif:
- **Generic Tests**:
  - `unique` & `not_null` pada seluruh *Primary Key* (`customer_id`, `account_id`, `transaction_id`).
  - `accepted_values` pada status KYC (`VERIFIED`, `PENDING`, `REJECTED`), jenis mutasi (`CREDIT`, `DEBIT`), dan status akun.
  - `relationships` (Integritas Referensial): Memastikan relasi *Foreign Key* antar entitas valid.
- **Singular Tests (Banking Compliance Rule)**:
  - `tests/assert_positive_transaction_amount.sql`: Memastikan tidak ada nominal transaksi bernilai $\le 0$ dalam sistem.

---

## 💻 Panduan Menjalankan di Lokal (Local Setup)

### 1. Kloning & Masuk ke Direktori
```bash
git clone <URL_REPOSITORI_ANDA>
cd nyobakompre
```

### 2. Setup Virtual Environment
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 3. Eksekusi Perintah dbt
```bash
# Uji koneksi DuckDB
dbt debug --profiles-dir .

# Muat data awal (seeds)
dbt seed --profiles-dir .

# Jalankan transformasi model
dbt run --profiles-dir .

# Jalankan seluruh data quality tests
dbt test --profiles-dir .
```
