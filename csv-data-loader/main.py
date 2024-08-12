import logging

from google.cloud import bigquery
from google.cloud import storage
from google.cloud.bigquery import SchemaField

PROJECT = "ee-india-se-data"
DATASET_ID = "movies_data_punit"


def load_csv_to_bigquery(data, context):
    file_name = data['name']
    bucket_name = data['bucket']

    if file_name.endswith('.csv'):
        client = bigquery.Client()
        table_id = get_table_id(file_name)
        if table_id is None:
            print(f"File {file_name} is not supported")
            return

        headers = get_csv_headers(bucket_name, file_name)
        print("csv header ", headers)

        # Create job configuration
        job_config = bigquery.LoadJobConfig(
            schema=schema_from_headers(headers),
            skip_leading_rows=1,
            source_format=bigquery.SourceFormat.CSV,
            allow_jagged_rows=True,
            write_disposition=bigquery.WriteDisposition.WRITE_APPEND
        )

        uri = f"gs://{bucket_name}/{file_name}"
        table_details = PROJECT + "." + DATASET_ID + "." + table_id
        print("loading file to " + table_details)
        load_job = client.load_table_from_uri(uri, table_details, job_config=job_config)

        load_job.result()

        logging.info(f"File {file_name} loaded into BigQuery table {table_id}")
    else:
        logging.warning(f"Unsupported file format: {file_name}")


def get_table_id(file_name):
    return "movies_raw" if file_name.startswith("movies") else "rating_raw" if file_name.startswith(
        "rating") else None


def get_csv_headers(bucket_name, file_name):
    storage_client = storage.Client()

    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(file_name)

    start = 0
    end = 1024
    first_line = ""

    while "\n" not in first_line:
        download_bytes = blob.download_as_bytes(start=start, end=end)
        first_line += download_bytes.decode("utf-8")
        start = end
        end += 1024
    first_line = first_line.replace("\r", "")
    headers = first_line.partition("\n")[0].split(",")
    return headers


def schema_from_headers(headers):
    schema = [SchemaField(header, 'STRING') for header in headers]
    return schema
