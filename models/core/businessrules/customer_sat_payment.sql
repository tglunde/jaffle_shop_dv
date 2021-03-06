{{ 
    config (
        materialized='incremental', 
        unique_key='pk'
    ) 
}}
{%- set ldts=dbt_utils.pretty_time(format='%Y-%m-%d %H:%M:%S') -%}
{%- set src_rel='stg_customers' -%}
{%- set bks=['customer_id'] -%}
{%- set fields=['total_amount'] -%}
{%- set rsrc='DWH' -%}

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

),

src as (

	select distinct
        {{ dbt_utils.surrogate_key(bks) }} || cast(timestamp'{{ldts}}' as varchar) as pk,
        cast({{ dbt_utils.surrogate_key(bks) }} as char(32)) as sk,
        cast(timestamp'{{ldts}}' as timestamp) as ldts,
        cast({{ dbt_utils.surrogate_key(fields) }} as char(32)) as hash_diff,
        {{ fields|join(', ') }} 
    
    from ergebnis

{% if is_incremental() -%}
),

tgt_diff as (

	select sk,ldts,hash_diff from {{ this }}

), 

tgt_max as (

    select sk, max(ldts) as ldts from {{ this }} group by sk

),

tgt as (

    select tgt_diff.sk, tgt_diff.ldts, tgt_diff.hash_diff from tgt_diff join tgt_max on tgt_diff.sk=tgt_max.sk and tgt_diff.ldts=tgt_max.ldts
{% endif %}
)

select 
    pk,
    src.sk as sk,
	src.ldts,
    '{{rsrc}}' as rsrc,
    src.hash_diff,
	{{ fields|join(', ') }}

from src
{% if is_incremental() -%}
    join tgt on src.sk=tgt.sk and src.hash_diff!=tgt.hash_diff 
{% endif %}


