{{ 
    config (
        materialized='incremental', 
        unique_key='bk'
    ) 
}}
{%- set src_rel='stg_payments' -%}
{%- set rsrc='OMS' -%}
{%- set ldts=dbt_utils.pretty_time(format='%Y-%m-%d %H:%M:%S') -%}
{%- set bks=['payment_id'] -%}

with src as (

	select distinct {{ dbt_utils.concat(bks) }} as bk from {{ ref(src_rel) }}

{% if is_incremental() -%}
),

tgt as (

	select bk from {{ this }}

{% endif %}
)

select 

    cast({{ dbt_utils.surrogate_key(['src.bk']) }} as char(32)) as sk,
	cast(timestamp'{{ldts}}' as timestamp) as ldts,
    '{{rsrc}}' as rsrc,
	cast(src.bk as varchar(255)) as bk

from src

{% if is_incremental() -%}
    left join tgt on src.bk=tgt.bk 
    where tgt.bk is null
{% endif %}