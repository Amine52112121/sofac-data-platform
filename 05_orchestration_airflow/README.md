# Orchestration Airflow - Pipeline automatise

## DAG : pipeline_elt_sofac

```
get_nifi_token → start_nifi_flow → wait_for_processing → stop_nifi_flow → dbt_run → dbt_test
```

| Tache | Type | Duree | Description |
|---|---|---|---|
| get_nifi_token | PythonOperator | ~2 sec | Authentification NiFi JWT |
| start_nifi_flow | PythonOperator | ~2 sec | Demarrage PG_SOFAC |
| wait_for_processing | PythonOperator | 5 min | Attente ingestion NiFi |
| stop_nifi_flow | PythonOperator | ~2 sec | Arret PG_SOFAC |
| dbt_run | BashOperator | ~5 min | 13 modeles dbt |
| dbt_test | BashOperator | ~2 min | 27 tests qualite |

## Schedule : chaque nuit a 2h du matin

## Installation

```bash
cd C:\materiels
docker compose up -d
```

Interface : http://localhost:8080
