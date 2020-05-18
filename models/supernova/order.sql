with orders as (

    select sk, bk as order_id from {{ ref('order_hub') }}

),

order_main as (

    select sk, ldts, order_date, status from {{ ref('order_sat') }}

),

order_payment as (

    select sk, ldts, credit_card_amount,coupon_amount,bank_transfer_amount,gift_card_amount,total_amount from {{ ref('order_sat_payment') }}

),

order_customer as (

    select 
        order_sk,c.customer_sk,c.customer_id 

    from {{ ref('customer_2_order') }} c2o 
    left join {{ ref('customer') }} c on c2o.customer_sk=c.customer_sk

),

ergebnis as (

    select 
        orders.sk as order_sk, order_customer.customer_sk, order_id, customer_id, order_date, status, credit_card_amount,coupon_amount,bank_transfer_amount,gift_card_amount,total_amount

    from orders
    left join order_main on orders.sk=order_main.sk 
    left join order_payment on orders.sk=order_payment.sk
    left join order_customer on orders.sk=order_customer.order_sk

)

select * from ergebnis