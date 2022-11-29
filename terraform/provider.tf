provider "google" {
  region  = "europe-west1"
  project = "koen-gcompany-demo"
}

provider "google-beta" {
  region  = "europe-west1"
  project = "koen-gcompany-demo"
}

provider "random" {}
