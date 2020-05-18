{{ 
    config (
        materialized='incremental', 
        unique_key='pk'
    ) 
}}
{%- set ldts=dbt_utils.pretty_time(format='%Y-%m-%d %H:%M:%S') -%}
{%- set bks=['customer_id','order_id'] -%}
{%- set sks=['customer_sk','order_sk'] -%}
{%- set rsrc='SAP' -%}
{%- set src_rel='stg_orders' -%}


with src as (

	select distinct 
        cast({{ dbt_utils.surrogate_key(['customer_id']) }} as char(32)) as customer_sk,
        cast({{ dbt_utils.surrogate_key(['order_id']) }} as char(32)) as order_sk

    from {{ ref(src_rel) }}

{% if is_incremental() -%}
),

tgt as (

	select customer_sk,order_sk from {{ this }}

{% endif %}
)

select 
    {{ dbt_utils.concat(['src.customer_sk','src.order_sk']) }} as pk,
	cast(timestamp'{{ldts}}' as timestamp) as ldts,
    '{{rsrc}}' as rsrc,
    src.customer_sk,
    src.order_sk

from src

{% if is_incremental() -%}
    left join tgt on src.customer_sk=tgt.customer_sk and src.order_sk=tgt.order_sk
    where tgt.customer_sk is null
{% endif %}
