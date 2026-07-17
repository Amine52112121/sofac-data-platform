-- Nettoyage du référentiel produits financiers
select
    produit_id,
    nom_produit,
    categorie,
    safe_cast(taux_min as float64)                     as taux_min,
    safe_cast(taux_max as float64)                     as taux_max,
    safe_cast(montant_min as float64)                  as montant_min,
    safe_cast(montant_max as float64)                  as montant_max,
    safe_cast(duree_min_mois as int64)                 as duree_min_mois,
    safe_cast(duree_max_mois as int64)                 as duree_max_mois,
    safe_cast(apport_min_pct as float64)               as apport_min_pct,
    statut,
    description
from {{ source('raw', 'produits_financiers_raw') }}
where produit_id is not null
