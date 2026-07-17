-- Contrats enrichis avec infos client, agence et produit
select
    c.contrat_id,
    c.client_id,
    c.produit_id,
    c.agence_id,
    -- Infos contrat
    c.montant_finance,
    c.apport_client,
    c.taux_interet,
    c.duree_mois,
    c.mensualite,
    c.date_deblocage,
    c.date_fin_prevue,
    c.statut_contrat,
    c.motif_credit,
    c.nb_echeances_total,
    c.montant_total_du,
    c.total_interets,
    -- Infos client
    cl.prenom,
    cl.nom,
    cl.genre,
    cl.age,
    cl.ville                                           as ville_client,
    cl.region                                          as region_client,
    cl.situation_professionnelle,
    cl.situation_familiale,
    cl.revenu_mensuel,
    cl.statut_client,
    -- Ratio mensualité / revenu (taux d'effort)
    round(c.mensualite / nullif(cl.revenu_mensuel, 0) * 100, 2) as taux_effort_pct,
    -- Infos agence
    a.nom_agence,
    a.ville                                            as ville_agence,
    a.region                                           as region_agence,
    -- Infos produit
    p.nom_produit,
    p.categorie                                        as categorie_produit
from {{ ref('stg_contrats_credit') }} c
left join {{ ref('stg_clients') }}            cl on c.client_id  = cl.client_id
left join {{ ref('stg_agences') }}            a  on c.agence_id  = a.agence_id
left join {{ ref('stg_produits_financiers') }} p  on c.produit_id = p.produit_id
