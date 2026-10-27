with customers as (
    select * from {{ ref('stg_customers') }}
),

accounts as (
    select * from {{ ref('stg_accounts') }}
),

transactions as (
    select * from {{ ref('stg_transactions') }}
),

final as (
    select
        t.transaction_id,
        t.transaction_timestamp,
        t.account_id,
        a.customer_id,
        c.customer_name,
        c.kyc_status,
        a.account_type,
        a.account_status,
        t.transaction_type,
        t.amount,
        t.transaction_status
    from transactions t
    left join accounts a on t.account_id = a.account_id
    left join customers c on a.customer_id = c.customer_id
)

select * from final
