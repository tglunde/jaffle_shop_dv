with payments as (

    select * from {{ ref('stg_payments') }}

),

orders as (

    select * from {{ ref('stg_orders') }}

),

ergebnis as (

    select
        orders.customer_id,
        sum(amount) as total_amount

    from payments

    left join orders on orders.order_id=payments.order_id

    group by 1

)

select * from ergebnis
