resource "google_storage_bucket" "datadog-bucket" {
    name          = postgress-bucket
    location      = "us-central1a"
    force_destroy = true

}
