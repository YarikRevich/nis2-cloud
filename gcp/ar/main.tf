resource "google_artifact_registry_repository" "test_repo" {
  provider     = google
  location     = "europe-west3"
  project      = "yariksvitlytskyi-learning"

  repository_id = "test-repo"
  format        = "DOCKER"

  docker_config {
    immutable_tags = false
  }
}

