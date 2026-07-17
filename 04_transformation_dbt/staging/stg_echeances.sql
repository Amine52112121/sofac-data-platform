-- Nettoyage et typage des échéances
select
    echeance_id,
    contrat_id,
    safe_cast(numero_echeance as int64)                as numero_echeance,
    safe.parse_date('%Y-%m-%d', date_echeance)         as date_echeance,
    safe_cast(montant_capital as float64)              as montant_capital,
    safe_cast(montant_interet as float64)              as montant_interet,
    safe_cast(montant_total_du as float64)             as montant_total_du,
    statut_echeance,
    -- Indicateur de retard
    case
        when statut_echeance = 'Payée'        then 0
        when statut_echeance = 'En attente'   then 0
        when statut_echeance = 'Retard 1-30j' then 1
        when statut_echeance = 'Retard 31-60j' then 2
        when statut_echeance = 'Retard >60j'  then 3
        else 0
    end                                                as niveau_retard
from {{ source('raw', 'echeances_raw') }}
where echeance_id is not null
