with customers as (
    select * from {{ ref('stg_customers') }}
),

accounts as (
    select * from {{ ref('stg_accounts') }}
),

fct_tx as (
    select * from {{ ref('fct_customer_transactions') }}
    where transaction_status = 'SUCCESS'
),

customer_accounts as (
    select
        customer_id,
        count(account_id) as total_accounts,
        count(case when account_status = 'ACTIVE' then 1 end) as active_accounts
    from accounts
    group by customer_id
),

customer_metrics as (
    select
        customer_id,
        count(transaction_id) as total_successful_transactions,
        coalesce(sum(case when transaction_type = 'CREDIT' then amount else 0 end), 0) as total_credit_amount,
        coalesce(sum(case when transaction_type = 'DEBIT' then amount else 0 end), 0) as total_debit_amount
    from fct_tx
    group by customer_id
),

final as (
    select
        c.customer_id,
        c.customer_name,
        c.email,
        c.kyc_status,
        c.created_at,
        coalesce(ca.total_accounts, 0) as total_accounts,
        coalesce(ca.active_accounts, 0) as active_accounts,
        coalesce(cm.total_successful_transactions, 0) as total_successful_transactions,
        coalesce(cm.total_credit_amount, 0) as total_credit_amount,
        coalesce(cm.total_debit_amount, 0) as total_debit_amount,
        coalesce(cm.total_credit_amount, 0) - coalesce(cm.total_debit_amount, 0) as net_cash_flow
    from customers c
    left join customer_accounts ca on c.customer_id = ca.customer_id
    left join customer_metrics cm on c.customer_id = cm.customer_id
)

select * from final
