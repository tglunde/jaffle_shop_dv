{{ 
    config (
        materialized='incremental', 
        unique_key='pk'
    ) 
}}
{%- set ldts=dbt_utils.pretty_time(format='%Y-%m-%d %H:%M:%S') -%}
{%- set bks=['order_id','payment_id'] -%}
{%- set sks=['order_sk','payment_sk'] -%}
{%- set rsrc='OMS' -%}
{%- set src_rel='stg_payments' -%}


with src as (

	select distinct 
        cast({{ dbt_utils.surrogate_key(['order_id']) }} as char(32)) as order_sk,
        cast({{ dbt_utils.surrogate_key(['payment_id']) }} as char(32)) as payment_sk

    from {{ ref(src_rel) }}

{% if is_incremental() -%}
),

tgt as (

	select {{ sks|join(', ') }} from {{ this }}

{% endif %}
)

select 
    {{ dbt_utils.concat(['src.order_sk','src.payment_sk']) }} as pk,
	cast(timestamp'{{ldts}}' as timestamp) as ldts,
    '{{rsrc}}' as rsrc,
    src.{{ sks|join(', src.') }}

from src

{% if is_incremental() -%}
    left join tgt on src.payment_sk=tgt.payment_sk and src.order_sk=tgt.order_sk
    where tgt.payment_sk is null
{% endif %}
