-- Nettoyage et typage des incidents de paiement
select
    incident_id,
    client_id,
    cin,
    type_incident,
    safe_cast(montant_incident as float64)             as montant_incident,
    safe.parse_date('%Y-%m-%d', date_incident)         as date_incident,
    safe.parse_date('%Y-%m-%d', date_regularisation)   as date_regularisation,
    statut_incident,
    etablissement_declarant,
    -- Durée de résolution en jours
    case
        when date_regularisation is not null
        then date_diff(
            safe.parse_date('%Y-%m-%d', date_regularisation),
            safe.parse_date('%Y-%m-%d', date_incident),
            day
        )
        else null
    end                                                as duree_resolution_jours
from {{ source('raw', 'incidents_paiement_raw') }}
where incident_id is not null
