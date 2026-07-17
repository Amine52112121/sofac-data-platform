-- Nettoyage du référentiel agences
select
    agence_id,
    nom_agence,
    ville,
    region,
    adresse,
    telephone,
    safe.parse_date('%Y-%m-%d', date_ouverture)        as date_ouverture,
    responsable,
    statut
from {{ source('raw', 'agences_raw') }}
where agence_id is not null
