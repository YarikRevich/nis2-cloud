resource "google_pubsub_topic" "scc_notification" {
  name = "scc_messages"
  project = "yariksvitlytskyi-learning"
}

resource "google_scc_notification_config" "custom_notification_config" {
  config_id    = "my_config"
  organization = "scc_messages"
  description  = "My custom Cloud Security Command Center Finding Notification Configuration"
  pubsub_topic =  google_pubsub_topic.scc_notification.id

  streaming_config {
    filter = "category = \"OPEN_FIREWALL\" AND state = \"ACTIVE\""
  }
}

resource "google_container_cluster" "secure_cluster" {
  name     = "secure-cluster"
  location = "europe-west3"

  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }

  workload_identity_config {
    workload_pool = "your-project-id.svc.id.goog"
  }

  security_posture_config {
    mode = "BASIC"
  }
}

resource "google_storage_bucket" "backup_bucket" {
  name     = "backup-daily"
  location = "EU"
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30
    }
  }
}