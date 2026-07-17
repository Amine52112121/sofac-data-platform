{{ config(materialized='table') }}

-- Dimension clients enrichie avec scoring et historique crédit
select
    cl.client_id,
    cl.cin,
    cl.prenom,
    cl.nom,
    cl.genre,
    cl.date_naissance,
    cl.age,
    cl.ville,
    cl.region,
    cl.situation_professionnelle,
    cl.situation_familiale,
    cl.niveau_education,
    cl.revenu_mensuel,
    cl.agence_id,
    cl.date_inscription,
    cl.statut_client,
    -- Scoring crédit
    s.score_credit,
    s.classe_risque,
    s.nb_credits_actifs,
    s.encours_total_externe,
    s.nb_incidents_passes,
    -- Historique crédit Sofac
    count(distinct c.contrat_id)                       as nb_contrats_sofac,
    countif(c.statut_contrat = 'En cours')             as nb_contrats_actifs,
    countif(c.statut_contrat = 'Soldé')                as nb_contrats_soldes,
    countif(c.statut_contrat = 'En retard')            as nb_contrats_retard,
    round(sum(c.montant_finance), 2)                   as total_finance_sofac,
    round(avg(c.taux_interet), 2)                      as taux_moyen,
    -- Incidents
    count(distinct i.incident_id)                      as nb_incidents_sofac,
    round(sum(coalesce(i.montant_incident, 0)), 2)     as montant_total_incidents,
    -- Segmentation client
    case
        when s.score_credit >= 750 then 'Premium'
        when s.score_credit >= 650 then 'Standard'
        when s.score_credit >= 550 then 'À surveiller'
        else 'Risqué'
    end                                                as segment_client
from {{ ref('stg_clients') }} cl
left join {{ ref('stg_scoring_credit') }}    s on cl.client_id = s.client_id
left join {{ ref('stg_contrats_credit') }}   c on cl.client_id = c.client_id
left join {{ ref('stg_incidents_paiement') }} i on cl.client_id = i.client_id
group by
    cl.client_id, cl.cin, cl.prenom, cl.nom, cl.genre,
    cl.date_naissance, cl.age, cl.ville, cl.region,
    cl.situation_professionnelle, cl.situation_familiale,
    cl.niveau_education, cl.revenu_mensuel, cl.agence_id,
    cl.date_inscription, cl.statut_client,
    s.score_credit, s.classe_risque, s.nb_credits_actifs,
    s.encours_total_externe, s.nb_incidents_passes
