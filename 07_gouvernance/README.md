# Gouvernance des donnees

## 1. Qualite - Tests dbt (27 tests)

- 20 tests not_null sur colonnes critiques
- 7 tests unique sur identifiants de reference

## 2. Documentation - dbt docs

```bash
dbt docs generate
dbt docs serve
```

Contient : descriptions, SQL compile, Lineage Graph

## 3. Catalogage BigQuery

Labels sur chaque table :
- couche : raw / staging / intermediate / marts
- domaine : clients / credit / echeances / performance
- source : postgres / csv / json
- criticite : haute / normale

## 4. Controle acces IAM (a configurer)

| Role | Dataset | Permissions |
|---|---|---|
| Data Engineer | Tous | Lecture/Ecriture |
| Data Analyst | marts | Lecture seule |
| Auditeur | marts | Lecture seule |
