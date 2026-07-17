-- Nettoyage et typage des données clients brutes
select
    client_id,
    cin,
    initcap(prenom)                                    as prenom,
    initcap(nom)                                       as nom,
    genre,
    safe.parse_date('%Y-%m-%d', date_naissance)        as date_naissance,
    date_diff(current_date(), 
        safe.parse_date('%Y-%m-%d', date_naissance), 
        year)                                          as age,
    ville,
    region,
    telephone,
    lower(email)                                       as email,
    situation_professionnelle,
    situation_familiale,
    niveau_education,
    safe_cast(revenu_mensuel as float64)               as revenu_mensuel,
    agence_id,
    safe.parse_date('%Y-%m-%d', date_inscription)      as date_inscription,
    statut_client
from {{ source('raw', 'clients_raw') }}
where client_id is not null
