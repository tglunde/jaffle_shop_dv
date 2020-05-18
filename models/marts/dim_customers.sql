with customers as (

    select * from {{ ref('customer') }}

),

ergebnis as (

    select
        customer_id,
        first_order,
        most_recent_order,
        number_of_orders,
        total_amount as customer_lifetime_value

    from customers

)

select * from ergebnis
