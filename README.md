# 🏦 Sofac Data Platform — Pipeline ELT

> Projet de fin de stage réalisé à **ENSA Berrechid** en collaboration avec **SOFAC**
> 
> **Réalisé par** : Amine Machal | **Encadré par** : Mr. Elyusufi

---

## 📋 Description du projet

Ce projet consiste à concevoir et implémenter une **plateforme data moderne** pour Sofac, société de financement au Maroc. L'objectif est d'automatiser l'ingestion, la transformation et la gouvernance des données provenant de plusieurs sources hétérogènes.

---

## 🏗️ Architecture globale

```
┌─────────────────────────────────────────────────────────────────────┐
│                         SOURCES DE DONNÉES                          │
│  PostgreSQL (CRM) │ CSV Legacy │ JSON Bureau Crédit │ CSV Référentiels│
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                         Apache NiFi
                    (Extraction & Chargement)
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      GOOGLE BIGQUERY (raw)                          │
│  clients_raw │ contrats_credit_raw │ echeances_raw │ paiements_raw  │
│  scoring_credit_raw │ incidents_paiement_raw │ agences_raw │ ...    │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                             dbt
                       (Transformation)
                               │
              ┌────────────────┼────────────────┐
              ▼                ▼                 ▼
           staging        intermediate         marts
         (nettoyage)       (jointures)     (indicateurs)
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    BIGQUERY MARTS (tables finales)                   │
│  dim_clients │ fct_portefeuille_credit │ fct_performance_remboursement│
└─────────────────────────────────────────────────────────────────────┘
                               │
                        Apache Airflow
                      (Orchestration 2h/nuit)
```

---

## 🛠️ Stack technique

| Composant | Outil | Rôle |
|---|---|---|
| **Extraction & Chargement** | Apache NiFi 2.10 | Ingestion multi-sources vers BigQuery |
| **Data Warehouse** | Google BigQuery | Stockage colonnaire cloud |
| **Transformation** | dbt 1.4.9 + BigQuery | Modélisation en couches |
| **Orchestration** | Apache Airflow 2.5.1 | Planification automatique |
| **Conteneurisation** | Docker Compose | Déploiement Airflow |
| **Base source** | PostgreSQL 18 | Système CRM source |

---

## 📁 Structure du dépôt

```
sofac-data-platform/
├── 01_infrastructure/        → Configuration Docker/Airflow
├── 02_ingestion_nifi/        → Flux NiFi et documentation
├── 03_data_warehouse_bigquery/ → Scripts SQL BigQuery
├── 04_transformation_dbt/    → Modèles dbt (staging/intermediate/marts)
├── 05_orchestration_airflow/ → DAGs Airflow
├── 06_donnees_templates/     → Données de test Sofac (645 000+ enregistrements)
├── 07_gouvernance/           → Tests qualité et documentation
└── 08_documentation/         → Document d'installation PDF
```

---

## 📊 Données templates Sofac

| Source | Fichier | Lignes | Type |
|---|---|---|---|
| CRM Sofac | `clients.csv` | 10 000 | PostgreSQL |
| CRM Sofac | `contrats_credit.csv` | 25 000 | PostgreSQL |
| Système legacy | `echeances.csv` | 326 982 | CSV |
| Système legacy | `paiements.csv` | 264 887 | CSV |
| Bureau de crédit | `scoring_credit.json` | 10 000 | JSON |
| Bureau de crédit | `incidents_paiement.json` | 9 089 | JSON |
| Référentiel | `agences.csv` | 21 | CSV |
| Référentiel | `produits_financiers.csv` | 8 | CSV |
| **TOTAL** | | **645 987** | |

---

## 🗂️ Modélisation dbt (4 couches)

```
raw → staging (8 modèles) → intermediate (2 modèles) → marts (3 modèles)
```

### Tables finales (marts)
- **`dim_clients`** : Profil enrichi de chaque client avec scoring et segmentation
- **`fct_portefeuille_credit`** : KPIs par contrat (encours, taux remboursement, retards)
- **`fct_performance_remboursement`** : Performance par agence et produit financier

---

## ✅ Gouvernance des données

- **27 tests qualité** dbt (`not_null`, `unique`)
- **Documentation automatique** via `dbt docs`
- **Catalogage** des tables dans BigQuery (descriptions + étiquettes)
- **Lineage graph** complet (raw → staging → intermediate → marts)

---

## 🚀 Installation et configuration

Voir le document complet dans `08_documentation/`.

---

## 📸 Captures d'écran

### DAG Airflow (pipeline complet)
> *(Voir dossier `08_documentation/`)*

### Lineage Graph dbt
> *(Voir dossier `08_documentation/`)*

---

*Projet réalisé dans le cadre du stage de fin d'études — ENSA Berrechid / Sofac — 2026*
