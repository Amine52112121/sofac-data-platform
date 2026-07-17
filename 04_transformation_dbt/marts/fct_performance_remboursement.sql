{{ config(materialized='view') }}

-- Table finale : performance de remboursement par agence et produit
select
    e.agence_id,
    e.region_client                                    as region,
    e.nom_produit,
    e.categorie_produit,
    -- Volume
    count(distinct e.contrat_id)                       as nb_contrats,
    count(e.echeance_id)                               as nb_echeances,
    -- Performance paiements
    countif(e.statut_echeance = 'Payée')               as nb_payes,
    countif(e.statut_echeance like '%Retard%')         as nb_retards,
    countif(e.statut_echeance = 'Retard >60j')         as nb_retards_graves,
    -- Taux de recouvrement
    round(
        countif(e.statut_echeance = 'Payée') * 100.0
        / nullif(count(e.echeance_id), 0),
        2
    )                                                  as taux_recouvrement_pct,
    -- Montants
    round(sum(e.montant_total_du), 2)                  as montant_total_du,
    round(sum(coalesce(e.montant_paye, 0)), 2)         as montant_total_recouvre,
    round(sum(
        case when e.statut_echeance != 'Payée'
        then e.montant_total_du else 0 end
    ), 2)                                              as montant_total_encours,
    -- Retard moyen
    round(avg(coalesce(e.nb_jours_retard, 0)), 1)      as retard_moyen_jours
from {{ ref('int_echeances_enrichies') }} e
group by
    e.agence_id, e.region_client,
    e.nom_produit, e.categorie_produit
