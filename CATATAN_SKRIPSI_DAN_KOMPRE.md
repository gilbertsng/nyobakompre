# PANDUAN LENGKAP & CATATAN PROYEK KOMPRE / SKRIPSI
**Topik:** Implementasi Otomatisasi Continuous Integration / Continuous Deployment (CI/CD) dan Validasi dbt Berbasis Maker-Checker-Signer  
**Studi Kasus:** Operasional Data Engineering Perbankan (*Ticket-Driven Data Transformation Workflow*)  
**Repositori GitHub:** [github.com/gilbertsng/nyobakompre](https://github.com/gilbertsng/nyobakompre)  

---

## 🏛️ 1. Posisi dbt dalam Arsitektur Data Perbankan

Banyak orang mengira dbt itu visualisasi data (BI). Padahal posisinya ada di **tengah-tengah pipeline**:

```
[ Core Banking / Database Utama ] (Data mentah nasabah & transaksi)
               │
               ▼ (Ditarik oleh pipeline EL/Data Engineer)
[ Data Warehouse / Database ] (DuckDB / Snowflake / BigQuery)
               │
               ▼
┌─────────────────────────────────────────────────────────────┐
│                 DI SINI POSISI dbt BEKERJA!                 │
│  - Membaca query SQL transformasi                           │
│  - Menjalankan uji kualitas data (Data Quality Testing)     │
│  - Menghasilkan tabel fisik baru yang bersih & teruji       │
└─────────────────────────────────────────────────────────────┘
               │
               ▼
[ Tabel Data Marts / Analitik ] (Tabel siap pakai di database)
               │
               ▼
[ Business Intelligence (BI) ] (Power BI, Tableau, Metabase)
```

---

## 💡 2. Konsep Fundamental: "Apa Sebenarnya Fungsi & Output dbt?"

### A. Apa itu Script dbt?
Script dbt adalah gabungan antara:
1. **Query SQL (`SELECT ...`)**: Logika pembersihan, filtering, dan join data.
2. **Fungsi Jinja (`{{ ref(...) }}`)**: Penghubung antar tabel yang pintar (otomatis tahu silsilah dependensi tabel).
3. **File Aturan (`.yml`)**: Polisi penguji kualitas data (`unique`, `not_null`, `accepted_values`).

### B. Bedanya "SQL Biasa" vs "dbt"
| Fitur | SQL Tradisional | dbt (*Data Build Tool*) |
| :--- | :--- | :--- |
| **Penulisan Kode** | Harus ngetik `CREATE TABLE AS SELECT ...` manual | Cuma nulis `SELECT ...`, dbt yang urus pembuatan tabel |
| **Pengecekan Kualitas** | Manual / sering terlewat | Otomatis via file YAML (`dbt test`) |
| **Pencegahan Data Kotor** | Data salah tetap masuk ke dashboard BI | Data salah langsung diblokir (*fail*) sebelum ke BI |
| **Version Control** | Susah ditrack | Standar Git, branch, dan Pull Request |

### C. Apa OUTPUT dari dbt?
> **Output nyata dbt adalah: SEBUAH TABEL / VIEW FISIK BARU DI DALAM DATABASE.**
> 
> *Contoh:* Dari file `7777.sql` dan `7777.yml`, dbt menciptakan tabel bernama **`7777`** di dalam database yang isinya khusus rekening berstatus `DORMANT`. Tabel inilah yang ditarik oleh tim BI ke dashboard Tableau/Power BI.

---

## 🔄 3. Alur Kerja Maker-Checker-Signer Berbasis Tiket

Di bank, Data Engineer tidak bekerja sembarangan, melainkan berdasarkan **tiket tugas**:

```
   [ MAKER ]                      [ CI / CD GATEKEEPER ]                   [ CHECKER ]                    [ SIGNER ]
(Data Engineer)                     (GitHub Actions)                  (Lead Data Engineer)          (Data Gov / Manager)
       │                                   │                                    │                              │
       ├─ Ambil Tiket (misal: 7777)        │                                    │                              │
       ├─ Buat branch ticket/DE-101        │                                    │                              │
       ├─ Tulis query.sql & schema.yml     │                                    │                              │
       └─ Open Pull Request (PR) ─────────►│                                    │                              │
                                           ├─ dbt debug (Koneksi)               │                              │
                                           ├─ dbt seed  (Database Bank)         │                              │
                                           ├─ dbt compile (Syntax)              │                              │
                                           ├─ dbt run   (Bikin Tabel)           │                              │
                                           ├─ dbt test  (Uji Kualitas Data)     │                              │
                                           │                                    │                              │
                                           ├─── GAGAL (Ada Data Salah) ──► TOLAK│                              │
                                           │    (Kunci tombol merge)            │                              │
                                           │                                    │                              │
                                           └─── SUKSES (Data Bersih) ──────────►│                              │
                                                                                ├─ Review Logika Query SQL     │
                                                                                └─ Approve PR ────────────────►│
                                                                                                               ├─ Otorisasi Akhir
                                                                                                               └─ Merge to main
```

---

## 🧪 4. Bukti Hasil Pengujian Empiris (Untuk Bab 4 Skripsi)

Siklus pengujian pada proyek ini telah dibuktikan secara riil di repositori GitHub:

### Skenario 1: Maker Membuat Kesalahan (Error Handling Berhasil Terbukti)
* **Tindakan Maker:** Menulis query di `7777.sql` tanpa filter `where account_status = 'DORMANT'`.
* **Aturan di YAML:** Wajib `accepted_values: ['DORMANT']`.
* **Hasil di GitHub Actions:** 
  ```text
  [ERROR]: in test accepted_values_7777_account_status__DORMANT (models/tickets/7777.yml)
  Got 2 results, configured to fail if != 0
  Done. PASS=3 WARN=0 ERROR=1 TOTAL=4
  ```
* **Dampak Tata Kelola:** PR otomatis berstatus **Silang Merah ❌ (Failed)**. Tombol *Merge* terkunci. Checker & Signer terlindungi dari data cacat.

### Skenario 2: Maker Memperbaiki Kode (Automated Re-test Berhasil)
* **Tindakan Maker:** Menambahkan filter `where account_status = 'DORMANT'`.
* **Tindakan Git:** Maker hanya perlu `git push` revisi ke cabang yang sama.
* **Hasil di GitHub Actions:** CI otomatis melakukan pengujian ulang tanpa perlu bikin PR baru.
* **Status Akhir:** Berubah menjadi **Centang Hijau ✅ (All checks have passed)**.

### Skenario 3: Otorisasi & Merge
* PR disetujui dan di-merge ke branch **`main`** (Status: **`MERGED`**).

---

## 🎤 5. Panduan Menjelaskan ke Dosen / Mentor (Pitching Script)

> *"Bapak/Ibu Dosen/Mentor, ide kompre saya ini mengambil studi kasus nyata operasional Data Engineering di perbankan.*
>
> *Masalah di industri saat ini: Ketika Data Engineer mengerjakan tiket transformasi data yang hasilnya akan dikonsumsi oleh dashboard Business Intelligence (BI), sering kali validasi query dan data masih bergantung pada review manual, sehingga data cacat atau anomali rawan lolos ke dashboard pimpinan.*
>
> *Solusi yang saya rancang dan implementasikan:*
> 1. *Menerapkan **dbt (data build tool)** untuk standarisasi transformasi data dan pengujian kualitas data otomatis (Data Quality Testing).*
> 2. *Membangun pipeline **CI/CD menggunakan GitHub Actions** sebagai Gatekeeper otomatis.*
> 3. *Menerapkan prinsip **Maker-Checker-Signer**: Maker (DE) mengajukan kode via Pull Request. Sistem CI/CD otomatis menguji data terlebih dahulu. Jika gagal, PR langsung diblokir. Hanya jika CI berstatus hijau, Checker (Lead DE) dan Signer (Manager) melakukan review dan otorisasi akhir.*
>
> *Proyek ini sudah saya buktikan secara end-to-end mulai dari simulasi database DuckDB lokal, penangkapan error otomatis di cloud runner GitHub Actions, hingga penggabungan kode ke branch produksi.*"

---
*Dokumen ini dibuat otomatis sebagai arsip pembelajaran dan dokumentasi resmi proyek kompre Gilbert Sinaga.*
