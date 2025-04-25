module "ar" {
  source = "./ar"
}

module "cb" {
  source = "./cb"
}

module "cmek" {
  source = "./cmek"
}

module "zi" {
  source = "./zi"
}

module "mb" {
  source = "./mb"
}

provider "google" {
  project = "yariksvitlytskyi-learning"
  region  = "europe-west3"
}


