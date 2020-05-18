{% set payment_methods = ['credit_card', 'coupon', 'bank_transfer', 'gift_card'] %}

with orders as (

    select * from {{ ref('order') }}

),

ergebnis as (

    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.status,

        {% for payment_method in payment_methods -%}

        orders.{{payment_method}}_amount,

        {% endfor -%}

        orders.total_amount as amount

    from orders

)

select * from ergebnis
