{{ config(materialized='view') }}

-- Table finale : vue d'ensemble du portefeuille de crédit par contrat
select
    c.contrat_id,
    c.client_id,
    c.prenom,
    c.nom,
    c.agence_id,
    c.nom_agence,
    c.region_agence,
    c.produit_id,
    c.nom_produit,
    c.categorie_produit,
    c.montant_finance,
    c.taux_interet,
    c.duree_mois,
    c.mensualite,
    c.date_deblocage,
    c.date_fin_prevue,
    c.statut_contrat,
    c.taux_effort_pct,
    c.revenu_mensuel,
    -- Indicateurs calculés depuis les échéances
    count(e.echeance_id)                               as nb_echeances_total,
    countif(e.statut_echeance = 'Payée')               as nb_echeances_payees,
    countif(e.statut_echeance like '%Retard%')         as nb_echeances_retard,
    countif(e.statut_echeance = 'En attente')          as nb_echeances_attente,
    -- Montants
    round(sum(coalesce(e.montant_paye, 0)), 2)         as total_paye,
    round(sum(
        case when e.statut_echeance != 'Payée'
        then e.montant_total_du else 0 end
    ), 2)                                              as encours_restant,
    -- Taux de remboursement
    round(
        countif(e.statut_echeance = 'Payée') * 100.0
        / nullif(count(e.echeance_id), 0),
        2
    )                                                  as taux_remboursement_pct,
    -- Retard max observé
    max(coalesce(e.nb_jours_retard, 0))                as retard_max_jours,
    -- Scoring
    s.score_credit,
    s.classe_risque
from {{ ref('int_contrats_enrichis') }} c
left join {{ ref('int_echeances_enrichies') }} e on c.contrat_id = e.contrat_id
left join {{ ref('stg_scoring_credit') }}      s on c.client_id  = s.client_id
group by
    c.contrat_id, c.client_id, c.prenom, c.nom,
    c.agence_id, c.nom_agence, c.region_agence,
    c.produit_id, c.nom_produit, c.categorie_produit,
    c.montant_finance, c.taux_interet, c.duree_mois,
    c.mensualite, c.date_deblocage, c.date_fin_prevue,
    c.statut_contrat, c.taux_effort_pct, c.revenu_mensuel,
    s.score_credit, s.classe_risque
