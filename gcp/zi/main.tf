resource "google_logging_project_sink" "incident_sink" {
  name        = "incident-log-sink"
  destination = "storage.googleapis.com/${google_storage_bucket.incident_logs.name}"
  filter      = "severity>=ERROR"

  unique_writer_identity = true
}

resource "google_storage_bucket" "incident_logs" {
  name     = "incident-logs-bucket"
  location = "EU"
}

resource "google_pubsub_topic" "incident_topic" {
  name = "incident-notifications"
}

resource "google_monitoring_alert_policy" "high_error_rate" {
  display_name = "High Error Rate Alert"

  combiner = "OR"
  conditions {
    display_name = "High error rate on API"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/error_count\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 5

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields      = ["resource.label.project_id"]
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.id]
  enabled               = true
}

resource "google_monitoring_notification_channel" "email" {
  display_name = "Incident Response Email"
  type         = "email"
  labels = {
    email_address = "admin@gmail.com"
  }
}

resource "google_project_iam_member" "incident_response_team" {
  project = "yariksvitlytskyi-learning"
  role    = "roles/incidentresponder"
  member  = "group:admin@gmail.com"
}



