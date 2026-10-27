    with source_data as (                                                                                            
        -- Mengambil data rekening nasabah dari tabel raw_accounts                                                   
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
        -- ⚠️ KESALAHAN DE: Lupa menambahkan filter: where account_status = 'DORMANT'                                
    )                                                                                                                
                                                                                                                     
    select * from transformed                                                                                        