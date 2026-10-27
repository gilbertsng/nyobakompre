with source as (
    select * from {{ ref('raw_accounts') }}
),

transformed as (
    select
        trim(account_id) as account_id,
        trim(customer_id) as customer_id,
        upper(trim(account_type)) as account_type,
        upper(trim(account_status)) as account_status,
        cast(open_date as date) as open_date
    from source
)

select * from transformed
