with payment as (

    select sk, ldts, bk as payment_id from {{ ref('payment_hub') }}

),

main as (

    select sk, payment_method, amount from {{ ref('payment_sat') }}

),

order_payment as (

    select order_sk,payment_sk from {{ ref('order_2_payment') }}

),

ergebnis as (

    select 
        payment.sk as payment_sk, order_sk, payment_method, amount
        
    from payment

    left join main on payment.sk=main.sk
    left join order_payment on payment.sk=order_payment.payment_sk 

)    

select * from ergebnis