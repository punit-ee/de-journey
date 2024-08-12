
resource "google_storage_bucket" "data-landing-bucket" {
  name          = var.bucket_name
  location      = var.location
  storage_class = "STANDARD"
  public_access_prevention = "enforced"
  uniform_bucket_level_access = true
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = "movies_data_punit"
  friendly_name               = "movies_data"
  description                 = "Movies Data"
  location                    = "US"

  labels = {
    env = "default"
  }

}

resource "google_bigquery_table" "default" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "movies_raw"
  labels = {
    env = "default"
  }

  schema = file("movie_table_schema.json")
}

resource "google_bigquery_table" "rating" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "rating_raw"

  labels = {
    env = "default"
  }

  schema = file("rating_table_schema.json")
}