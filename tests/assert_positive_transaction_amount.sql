-- Singular Test: Business Rule Validasi Perbankan
-- Aturan: Semua nominal transaksi yang dicatat harus lebih besar dari 0 (> 0).
-- Jika query ini mengembalikan baris (record), maka test dbt dianggap GAGAL (FAILED).

select
    transaction_id,
    amount
from {{ ref('stg_transactions') }}
where amount <= 0
