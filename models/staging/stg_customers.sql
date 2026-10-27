with source as (
    select * from {{ ref('raw_customers') }}
),

transformed as (
    select
        trim(customer_id) as customer_id,
        trim(customer_name) as customer_name,
        lower(trim(email)) as email,
        upper(trim(kyc_status)) as kyc_status,
        cast(created_at as timestamp) as created_at
    from source
)

select * from transformed
