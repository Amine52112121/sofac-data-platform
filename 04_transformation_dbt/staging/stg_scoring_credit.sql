-- Nettoyage et typage des scores crédit
select
    scoring_id,
    client_id,
    cin,
    safe_cast(score_credit as int64)                   as score_credit,
    classe_risque,
    safe_cast(nb_credits_actifs as int64)              as nb_credits_actifs,
    safe_cast(encours_total_externe as float64)        as encours_total_externe,
    safe_cast(nb_incidents_passes as int64)            as nb_incidents_passes,
    safe.parse_date('%Y-%m-%d', date_derniere_maj)     as date_derniere_maj,
    source_bureau,
    -- Score normalisé entre 0 et 100
    round(
        (safe_cast(score_credit as int64) - 300) / 5.5,
        1
    )                                                  as score_normalise
from {{ source('raw', 'scoring_credit_raw') }}
where client_id is not null
