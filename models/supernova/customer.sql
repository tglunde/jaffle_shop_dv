with customer as (

    select sk, bk as customer_id from {{ ref('customer_hub') }}

),

main as (

    select sk, ldts, last_name, first_name, email from {{ ref('customer_sat') }}

),

orders as (

    select sk, ldts, first_order, most_recent_order, number_of_orders from {{ ref('customer_sat_order') }}

),

payments as (

    select sk, ldts, total_amount from {{ ref('customer_sat_payment') }}

),

ergebnis as (

    select 
        customer.sk as customer_sk, customer_id, last_name, first_name, email, first_order, most_recent_order, number_of_orders,
        total_amount

    from customer
    left join main on customer.sk=main.sk
    left join orders on customer.sk=orders.sk 
    left join payments on customer.sk=payments.sk

)

select * from ergebnis