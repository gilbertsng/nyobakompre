with source as (
    select * from {{ ref('raw_transactions') }}
),

transformed as (
    select
        trim(transaction_id) as transaction_id,
        trim(account_id) as account_id,
        upper(trim(transaction_type)) as transaction_type,
        cast(amount as decimal(18, 2)) as amount,
        upper(trim(transaction_status)) as transaction_status,
        cast(transaction_timestamp as timestamp) as transaction_timestamp
    from source
)

select * from transformed
