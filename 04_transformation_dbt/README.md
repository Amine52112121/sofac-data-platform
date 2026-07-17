# Transformation dbt - Modelisation en 4 couches

## Architecture

```
raw → staging (8 modeles) → intermediate (2 modeles) → marts (3 modeles)
```

## Modeles staging

| Modele | Source | Transformations |
|---|---|---|
| stg_clients | raw.clients_raw | Typage dates, calcul age |
| stg_contrats_credit | raw.contrats_credit_raw | Typage montants, calcul interets |
| stg_echeances | raw.echeances_raw | Indicateur niveau retard |
| stg_paiements | raw.paiements_raw | Categorie ponctualite |
| stg_scoring_credit | raw.scoring_credit_raw | Score normalise 0-100 |
| stg_incidents_paiement | raw.incidents_paiement_raw | Duree resolution |
| stg_agences | raw.agences_raw | Typage dates |
| stg_produits_financiers | raw.produits_financiers_raw | Typage taux et montants |

## Modeles intermediate

| Modele | Description |
|---|---|
| int_contrats_enrichis | Contrat + Client + Agence + Produit + Taux effort |
| int_echeances_enrichies | Echeance + Paiement + Contrat enrichi |

## Tables finales (marts)

| Modele | Lignes | KPIs |
|---|---|---|
| dim_clients | 10 000 | Score credit, segmentation, historique |
| fct_portefeuille_credit | 25 000 | Encours, taux remboursement, retards |
| fct_performance_remboursement | 1 342 | Taux recouvrement par agence/produit |

## Commandes

```bash
dbt run --profiles-dir "C:\Users\AMINE\.dbt"
dbt test --profiles-dir "C:\Users\AMINE\.dbt"
dbt docs generate --profiles-dir "C:\Users\AMINE\.dbt"
dbt docs serve --profiles-dir "C:\Users\AMINE\.dbt"
```
