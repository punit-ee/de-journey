import logging
import io
import pandas as pd
from google.cloud import bigquery
from google.cloud import storage
from google.cloud.bigquery import SchemaField

PROJECT = "ee-india-se-data"
DATASET_ID = "movies_data_punit"


def load_excel_to_bigquery(data, context):
    file_name = data["name"]
    bucket_name = data["bucket"]

    if file_name.endswith(".xlsx") or file_name.endswith(".xls"):
        client = bigquery.Client()
        table_id = get_table_id(file_name)

        if table_id is None:
            logging.warning(f"File {file_name} is not supported")
            return

        # Read Excel into DataFrame
        df = read_excel_from_gcs(bucket_name, file_name)
        headers = list(df.columns)
        logging.info(f"Excel headers: {headers}")

        # Create schema dynamically
        schema = schema_from_headers(headers)

        # Load job config
        job_config = bigquery.LoadJobConfig(
            schema=schema,
            source_format=bigquery.SourceFormat.PARQUET,  # recommended for dataframes
            write_disposition=bigquery.WriteDisposition.WRITE_APPEND,
        )

        # Write DataFrame to BigQuery directly
        table_details = f"{PROJECT}.{DATASET_ID}.{table_id}"
        logging.info(f"Loading Excel file into {table_details}")

        load_job = client.load_table_from_dataframe(df, table_details, job_config=job_config)
        load_job.result()

        logging.info(f"File {file_name} loaded into BigQuery table {table_id}")
    else:
        logging.warning(f"Unsupported file format: {file_name}")


def get_table_id(file_name: str):
    """Decide which table to load into based on file prefix."""
    if file_name.startswith("movies"):
        return "movies_raw"
    elif file_name.startswith("rating"):
        return "rating_raw"
    return None


def read_excel_from_gcs(bucket_name: str, file_name: str) -> pd.DataFrame:
    """Download Excel file from GCS and return as pandas DataFrame."""
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(file_name)

    data_bytes = blob.download_as_bytes()
    df = pd.read_excel(io.BytesIO(data_bytes))

    return df


def schema_from_headers(headers):
    """Default schema: treat all fields as STRING."""
    return [SchemaField(header, "STRING") for header in headers]
