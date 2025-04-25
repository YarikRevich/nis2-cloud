resource "google_project_service" "cloudbuild" {
  service = "cloudbuild.googleapis.com"
  project = "yariksvitlytskyi-learning"
}

resource "google_project_iam_member" "cloudbuild_run_admin" {
  project = "yariksvitlytskyi-learning"
  role    = "roles/run.admin"
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "cloudbuild_service_account_user" {
  project = "yariksvitlytskyi-learning"
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_cloudbuild_trigger" "github_trigger" {
  name    = "docker-build-trigger"
  project = "yariksvitlytskyi-learning"

  github {
    owner = "YarikRevich"
    name  = "nis2-cloud"
    push {
      branch = "master"
    }
  }

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", "europe-west3-docker.pkg.dev/yariksvitlytskyi-learning/docker-repo/app", "."]
    }

    artifacts {
      images = [
        "europe-west3-docker.pkg.dev/yariksvitlytskyi-learning/docker-repo/app"
      ]
    }
  }
}



