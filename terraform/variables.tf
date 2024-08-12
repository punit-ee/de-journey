variable "project_id" {
  description = "The Id of GCP project"
  type = string
  default = "ee-india-se-data"
}

variable "region" {
  description = "The GCP region to create and test resources in"
  type = string
  default = "us-central1"
}

variable "location" {
  description = "The GCP location to create and test resources in"
  type = string
  default = "US"
}

variable "bucket_name" {
  description = "bucket name for cloud storage"
  type    = string
  default = "se-data-landing-punit"
}

variable "cloud_function_bucket_name" {
  description = "Name of the bucket which store cloud function code"
  type = string
  default = "cloud-function-storage-punit"
}