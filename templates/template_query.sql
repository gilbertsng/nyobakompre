-- ==============================================================================
-- TEMPLATE QUERY DBT (DATA ENGINEERING PERBANKAN)
-- ==============================================================================
-- Petunjuk DE:
-- 1. Gunakan ref() untuk mengambil tabel sumber (contoh: raw_accounts, raw_customers).
-- 2. Terapkan logika query sesuai kebutuhan tiket.
-- 3. Pastikan kolom Primary Key unik dan tidak bernilai NULL.
-- ==============================================================================

with source_data as (
    -- Ganti nama tabel sumber yang dibutuhkan tiket di sini
    select * from {{ ref('raw_accounts') }}
),

transformed as (
    select
        account_id,
        customer_id,
        account_type,
        account_status,
        open_date
    from source_data
    -- Tambahkan filter atau transformasi sesuai tiket
)

select * from transformed
