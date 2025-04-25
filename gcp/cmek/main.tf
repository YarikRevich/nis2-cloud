resource "google_kms_key_ring" "cmek_ring" {
  name     = "cmek-keyring"
  location = "europe-west3"
  project  = "yariksvitlytskyi-learning"
}

resource "google_kms_crypto_key" "cmek_key" {
  name            = "cmek-key"
  key_ring        = google_kms_key_ring.cmek_ring.id
  rotation_period = "7776000s"

  lifecycle {
    prevent_destroy = true
  }

  version_template {
    algorithm = "GOOGLE_SYMMETRIC_ENCRYPTION"
  }
}

resource "google_storage_bucket" "secure_bucket" {
  name     = "secure-cmek-bucket"
  location = "europe-west3"
  project  = "yariksvitlytskyi-learning"

  encryption {
    default_kms_key_name = google_kms_crypto_key.cmek_key.id
  }
}

resource "google_bigquery_dataset" "secure_dataset" {
  dataset_id = "secure_dataset"
  location   = "europe-west3"
  project    = "yariksvitlytskyi-learning"
  default_encryption_configuration {
    kms_key_name = google_kms_crypto_key.cmek_key.id
  }
}

resource "google_compute_disk" "secure_disk" {
  name    = "secure-disk"
  type    = "pd-ssd"
  zone    = "europe-west3-a"
  size    = 100
  project = "yariksvitlytskyi-learning"

  disk_encryption_key {
    kms_key_self_link = google_kms_crypto_key.cmek_key.id
  }
}

resource "google_sql_database_instance" "secure_sql" {
  name             = "secure-sql-instance"
  region           = "europe-west3"
  database_version = "POSTGRES_15"
  project          = "yariksvitlytskyi-learning"

  encryption_key_name = google_kms_crypto_key.cmek_key.id

  settings {
    tier      = "db-custom-1-3840"
    disk_size = 10
  }
}

resource "google_container_cluster" "secure_cluster" {
  name     = "secure-cluster"
  location = "europe-west3"
  project  = "yariksvitlytskyi-learning"

  database_encryption {
    state    = "ENCRYPTED"
    key_name = google_kms_crypto_key.cmek_key.id
  }
}

resource "google_pubsub_topic" "secure_topic" {
  name    = "secure-topic"
  project = "yariksvitlytskyi-learning"

  kms_key_name = google_kms_crypto_key.cmek_key.id
}

resource "google_logging_project_sink" "kms_logs_sink" {
  name        = "kms-logs-export"
  destination = "storage.googleapis.com/${google_storage_bucket.secure_bucket.name}"
  project     = "yariksvitlytskyi-learning"

  filter = "resource.type=\"kms_crypto_key\""

  depends_on = [google_storage_bucket.secure_bucket]
}

resource "google_kms_crypto_key_iam_member" "crypto_key_admin" {
  crypto_key_id = google_kms_crypto_key.cmek_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "user:yariksvitlitskiy81@gmail.com"
}
