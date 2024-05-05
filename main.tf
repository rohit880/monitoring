resource "google_service_account" "datadog-svc" {
  account_id   = "datadog-svc"
  display_name = "Service Account"
}

resource "google_project_iam_member" "datadog-roles" {
  for_each = toset([
    "roles/dataflow.admin",
    "roles/dataflow.worker",
    "roles/pubsub.viewer",
    "roles/pubsub.subscriber",
    "roles/secretmanager.secretAccessor",
    "roles/storage.objectAdmin",
  ])
  role = each.key
  member = "serviceAccount:${google_service_account.datadog-svc.email}"
  project = my_project_id
}

resource "google_pubsub_topic" "datadog-db-topic" {
  name = "db-logs"
}

resource "google_pubsub_subscription" "datadog-db-s" {
  name  = "datadog-db-s"
  topic = google_pubsub_topic.datadog-db.id

  labels = {
    SQL = "Postgress"
  }

  # 20 minutes
  message_retention_duration = "1200s"
  retain_acked_messages      = true

  ack_deadline_seconds = 20

  expiration_policy {
    ttl = "300000.5s"
  }
  retry_policy {
    minimum_backoff = "10s"
  }

  enable_message_ordering    = false
}

resource "google_logging_project_sink" "datadog-db-sink" {
  name = "datadog-db-sink"

  # Can export to pubsub, cloud storage, bigquery, log bucket, or another project
  destination = "pubsub.googleapis.com/projects/stoplight-dojo-integration/topics/db-logs"

  # Log all WARN or higher severity messages relating to instances
  filter = "resource.type="cloudsql_database" AND resource.labels.database_id="stoplight-dojo-integration:dojo-stg-postgres""

  # Use a unique writer (creates a unique service account used for writing)
  unique_writer_identity = true
}
