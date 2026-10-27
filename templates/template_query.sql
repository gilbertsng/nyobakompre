-- ==============================================================================
-- TEMPLATE QUERY DBT (DATA ENGINEERING PERBANKAN)
-- ==============================================================================
-- Petunjuk DE:
-- 1. Gunakan format CTE (Common Table Expressions) dengan ref() ke staging/marts.
-- 2. Terapkan pembersihan data (trim, casting tipe data yang tepat).
-- 3. Pastikan kolom Primary Key bernilai unik dan tidak null.
-- ==============================================================================

with source_data as (
    -- Ganti dengan model acuan yang dibutuhkan tiket (contoh: stg_customers, stg_accounts, dll)
    select * from {{ ref('stg_customers') }}
),

transformed as (
    select
        -- Deklarasikan kolom-kolom yang diminta tiket bisnis di sini
        customer_id,
        customer_name,
        email,
        kyc_status,
        created_at
    from source_data
)

select * from transformed
