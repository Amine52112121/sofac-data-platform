-- Nettoyage et typage des contrats de crédit
select
    contrat_id,
    client_id,
    produit_id,
    agence_id,
    safe_cast(montant_finance as float64)              as montant_finance,
    safe_cast(apport_client as float64)                as apport_client,
    safe_cast(taux_interet as float64)                 as taux_interet,
    safe_cast(duree_mois as int64)                     as duree_mois,
    safe_cast(mensualite as float64)                   as mensualite,
    safe.parse_date('%Y-%m-%d', date_deblocage)        as date_deblocage,
    safe.parse_date('%Y-%m-%d', date_fin_prevue)       as date_fin_prevue,
    statut_contrat,
    motif_credit,
    safe_cast(nb_echeances_total as int64)             as nb_echeances_total,
    safe_cast(montant_total_du as float64)             as montant_total_du,
    -- Calcul du montant des intérêts total
    round(
        safe_cast(montant_total_du as float64) - safe_cast(montant_finance as float64),
        2
    )                                                  as total_interets
from {{ source('raw', 'contrats_credit_raw') }}
where contrat_id is not null
