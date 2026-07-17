from datetime import datetime, timedelta
import time
import requests
import urllib3

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

NIFI_BASE_URL    = "https://DESKTOP-QV50A8V:8443/nifi-api"
NIFI_USERNAME    = "2161b11b-a2d9-4f44-81e2-17dcdc3ba826"
NIFI_PASSWORD    = "McLc5VKXJ6kgQowKIZFEwlEkcXysq5yy"
NIFI_PG_ID       = "60f65ed8-019f-1000-e68f-a71fe4a8ddba" 

DBT_PROJECT_DIR  = "/opt/dbt_project"
DBT_PROFILES_DIR = "/opt/dbt_project"

ALERT_EMAIL      = "machal.amine@gmail.com"
WAIT_SECONDS     = 300  

default_args = {
    "owner"            : "amine",
    "depends_on_past"  : False,
    "retries"          : 2,
    "retry_delay"      : timedelta(minutes=5),
    "email"            : [ALERT_EMAIL],
    "email_on_failure" : True,
    "email_on_retry"   : False,
}


def get_nifi_token(**context):
    resp = requests.post(
        f"{NIFI_BASE_URL}/access/token",
        data={"username": NIFI_USERNAME, "password": NIFI_PASSWORD},
        verify=False,
        timeout=30,
    )
    resp.raise_for_status()
    context["ti"].xcom_push(key="nifi_token", value=resp.text)


def _set_pg_state(token: str, state: str):
    headers = {"Authorization": f"Bearer {token}"}
    body    = {"id": NIFI_PG_ID, "state": state}
    resp = requests.put(
        f"{NIFI_BASE_URL}/flow/process-groups/{NIFI_PG_ID}",
        json=body,
        headers=headers,
        verify=False,
        timeout=30,
    )
    resp.raise_for_status()


def start_nifi_flow(**context):
    token = context["ti"].xcom_pull(key="nifi_token", task_ids="get_nifi_token")
    _set_pg_state(token, "RUNNING")


def wait_for_processing(**context):
    time.sleep(WAIT_SECONDS)


def stop_nifi_flow(**context):
    token = context["ti"].xcom_pull(key="nifi_token", task_ids="get_nifi_token")
    _set_pg_state(token, "STOPPED")


with DAG(
    dag_id="pipeline_elt_sofac",
    description="Orchestration NiFi (8 sources) -> dbt BigQuery (Sofac)",
    default_args=default_args,
    schedule_interval="0 2 * * *",
    start_date=datetime(2026, 1, 1),
    catchup=False,
    tags=["elt", "nifi", "dbt", "bigquery", "sofac"],
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
        "cd /opt/dbt_project && "
        "/home/airflow/.local/bin/dbt run --profiles-dir /opt/dbt_project"
        ),
    )

    t6_dbt_test = BashOperator(
       task_id="dbt_test",
       bash_command=(
        "cd /opt/dbt_project && "
        "/home/airflow/.local/bin/dbt test --profiles-dir /opt/dbt_project"
        ),
    )

    t1_get_token >> t2_start_nifi >> t3_wait >> t4_stop_nifi >> t5_dbt_run >> t6_dbt_test