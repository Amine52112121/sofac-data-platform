-- Nettoyage et typage des paiements
select
    paiement_id,
    echeance_id,
    contrat_id,
    safe.parse_date('%Y-%m-%d', date_paiement)         as date_paiement,
    safe_cast(montant_paye as float64)                 as montant_paye,
    mode_paiement,
    reference_paiement,
    safe_cast(nb_jours_retard as int64)                as nb_jours_retard,
    statut_paiement,
    -- Catégorie de ponctualité
    case
        when safe_cast(nb_jours_retard as int64) = 0   then 'À temps'
        when safe_cast(nb_jours_retard as int64) <= 30 then 'Retard léger'
        when safe_cast(nb_jours_retard as int64) <= 60 then 'Retard modéré'
        else 'Retard grave'
    end                                                as categorie_ponctualite
from {{ source('raw', 'paiements_raw') }}
where paiement_id is not null
