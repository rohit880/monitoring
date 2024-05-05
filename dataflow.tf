# Deploy Google Cloud Dataflow Job
resource "google_dataflow_job" "pubsub_to_datadog" {
  name = "pubsub-to-datadog"
  template_gcs_path = "gs://dataflow-templates/latest/PubSub_to_datadog"
  temp_gcs_location = google_storage_bucket.gcs_dataflow_bucket.url
  parameters = {
    inputTopic = google_pubsub_topic.pubsub_topic.name
    outputTableSpec = "<project-id>:<dataset>.<table>"
  }
  on_delete = "cancel"
}
