"""
DAG d'orchestration du pipeline ELT :
1. Authentification NiFi (token)
2. Démarrage du flux NiFi (root process group)
3. Attente d'un cycle de traitement
4. Arrêt du flux NiFi (pour ne pas le laisser tourner en continu)
5. dbt run
6. dbt test
7. Alerte email en cas d'échec de n'importe quelle étape
"""

from datetime import datetime, timedelta
import time
import requests
import urllib3

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator

# Désactive les warnings liés au certificat auto-signé de NiFi (test only)
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# =========================================================
# CONFIGURATION — à adapter à votre environnement
# =========================================================
NIFI_BASE_URL = "https://DESKTOP-QV50A8V:8443/nifi-api"
NIFI_USERNAME = "2161b11b-a2d9-4f44-81e2-17dcdc3ba826"
NIFI_PASSWORD = "McLc5VKXJ6kgQowKIZFEwlEkcXysq5yy"

DBT_PROJECT_DIR = "/opt/dbt_project"
DBT_PROFILES_DIR = "/opt/dbt_project"  # là où se trouve profiles.yml

ALERT_EMAIL = "machalamine61@gmail.com"

# Durée d'attente après démarrage de NiFi pour laisser le temps
# à l'extraction + chargement de se terminer (à ajuster selon le
# volume réel de données)
WAIT_SECONDS = 60


default_args = {
    "owner": "amine",
    "depends_on_past": False,
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
    "email": [ALERT_EMAIL],
    "email_on_failure": True,
    "email_on_retry": False,
}


def get_nifi_token(**context):
    """Authentifie sur NiFi et récupère un token JWT, stocké en XCom."""
    resp = requests.post(
        f"{NIFI_BASE_URL}/access/token",
        data={"username": NIFI_USERNAME, "password": NIFI_PASSWORD},
        verify=False,
        timeout=30,
    )
    resp.raise_for_status()
    token = resp.text
    context["ti"].xcom_push(key="nifi_token", value=token)


def _set_nifi_state(token: str, state: str):
    """Démarre (RUNNING) ou arrête (STOPPED) le process group racine."""
    headers = {"Authorization": f"Bearer {token}"}
    body = {"id": "root", "state": state}
    resp = requests.put(
        f"{NIFI_BASE_URL}/flow/process-groups/root",
        json=body,
        headers=headers,
        verify=False,
        timeout=30,
    )
    resp.raise_for_status()


def start_nifi_flow(**context):
    token = context["ti"].xcom_pull(key="nifi_token", task_ids="get_nifi_token")
    _set_nifi_state(token, "RUNNING")


def wait_for_processing(**context):
    time.sleep(WAIT_SECONDS)


def stop_nifi_flow(**context):
    token = context["ti"].xcom_pull(key="nifi_token", task_ids="get_nifi_token")
    _set_nifi_state(token, "STOPPED")


with DAG(
    dag_id="pipeline_elt_nifi_dbt",
    description="Orchestration NiFi -> dbt (extraction, transformation)",
    default_args=default_args,
    schedule_interval="0 2 * * *",  # tous les jours à 2h du matin
    start_date=datetime(2026, 1, 1),
    catchup=False,
    tags=["elt", "nifi", "dbt"],
) as dag:

    t1_get_token = PythonOperator(
        task_id="get_nifi_token",
        python_callable=get_nifi_token,
    )

    t2_start_nifi = PythonOperator(
        task_id="start_nifi_flow",
        python_callable=start_nifi_flow,
    )

    t3_wait = PythonOperator(
        task_id="wait_for_processing",
        python_callable=wait_for_processing,
    )

    t4_stop_nifi = PythonOperator(
        task_id="stop_nifi_flow",
        python_callable=stop_nifi_flow,
    )

    t5_dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=(
            f"cd {DBT_PROJECT_DIR} && "
            f"dbt run --profiles-dir {DBT_PROFILES_DIR}"
        ),
    )

    t6_dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=(
            f"cd {DBT_PROJECT_DIR} && "
            f"dbt test --profiles-dir {DBT_PROFILES_DIR}"
        ),
    )

    t1_get_token >> t2_start_nifi >> t3_wait >> t4_stop_nifi >> t5_dbt_run >> t6_dbt_test