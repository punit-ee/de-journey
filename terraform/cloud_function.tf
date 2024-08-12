# Generates an archive of the source code compressed as a .zip file.
data "archive_file" "source" {
  type        = "zip"
  source_dir  = "../csv-data-loader"
  output_path = "${path.module}/csv-data-loader.zip"
}

resource "google_storage_bucket" "Cloud_function_bucket" {
    name     = var.cloud_function_bucket_name
    location = var.location
    project  = var.project_id
}

# Add source code zip to the Cloud Function's bucket (Cloud_function_bucket)
resource "google_storage_bucket_object" "zip" {
  source       = data.archive_file.source.output_path
  content_type = "application/zip"
  name         = "src-${data.archive_file.source.output_md5}.zip"
  bucket       = google_storage_bucket.Cloud_function_bucket.name
  depends_on = [
    google_storage_bucket.Cloud_function_bucket,
    data.archive_file.source
  ]
}

# Create the Cloud function triggered by a `Finalize` event on the bucket
resource "google_cloudfunctions_function" "load_csv_to_bigquery" {
  name                  = "load_csv_to_bigquery"
  description           = "Cloud-function will get trigger once file is uploaded in bucket ${var.bucket_name}"
  runtime               = "python312"
  project               = var.project_id
  region                = var.region
  source_archive_bucket = google_storage_bucket.Cloud_function_bucket.name
  source_archive_object = google_storage_bucket_object.zip.name
  entry_point           = "load_csv_to_bigquery"
  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.data-landing-bucket.name
  }
  depends_on = [
    google_storage_bucket.Cloud_function_bucket,
    google_storage_bucket_object.zip,
  ]
}