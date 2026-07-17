# Ingestion NiFi - 8 flux vers BigQuery

## Architecture des flux

```
PG_SOFAC (Process Group)
├── Flux 1 : PostgreSQL → clients_raw          (ExecuteSQL → PutBigQuery)
├── Flux 2 : PostgreSQL → contrats_credit_raw  (ExecuteSQL → PutBigQuery)
├── Flux 3 : CSV → echeances_raw               (ListFile → FetchFile → PutBigQuery)
├── Flux 4 : CSV → paiements_raw               (ListFile → FetchFile → PutBigQuery)
├── Flux 5 : JSON → scoring_credit_raw         (ListFile → FetchFile → PutBigQuery)
├── Flux 6 : JSON → incidents_paiement_raw     (ListFile → FetchFile → PutBigQuery)
├── Flux 7 : CSV → agences_raw                 (ListFile → FetchFile → PutBigQuery)
└── Flux 8 : CSV → produits_financiers_raw     (ListFile → FetchFile → PutBigQuery)
```

## Controller Services

| Service | Role |
|---|---|
| DBCPConnectionPool | Connexion JDBC PostgreSQL (sofac_db) |
| GCPCredentialsControllerService | Authentification Google Cloud |
| AvroReader | Lecture sorties PostgreSQL |
| CSVReader | Lecture fichiers CSV (String Fields From Header) |
| JsonTreeReader | Lecture fichiers JSON |

## Configuration PutBigQuery

- Project ID : my-project-sofac
- Dataset : raw
- Toutes colonnes en STRING dans raw (conversion dans dbt)

## Note importante

Ne jamais committer bigquery-key.json sur GitHub.
