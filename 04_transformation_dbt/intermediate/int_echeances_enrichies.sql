-- Échéances enrichies avec infos contrat et paiement
select
    e.echeance_id,
    e.contrat_id,
    e.numero_echeance,
    e.date_echeance,
    e.montant_capital,
    e.montant_interet,
    e.montant_total_du,
    e.statut_echeance,
    e.niveau_retard,
    -- Infos paiement associé
    p.paiement_id,
    p.date_paiement,
    p.montant_paye,
    p.mode_paiement,
    p.nb_jours_retard,
    p.categorie_ponctualite,
    -- Infos contrat
    c.client_id,
    c.produit_id,
    c.agence_id,
    c.montant_finance,
    c.mensualite,
    c.statut_contrat,
    c.nom_produit,
    c.categorie_produit,
    c.ville_client,
    c.region_client
from {{ ref('stg_echeances') }} e
left join {{ ref('stg_paiements') }}         p on e.echeance_id = p.echeance_id
left join {{ ref('int_contrats_enrichis') }} c on e.contrat_id  = c.contrat_id
