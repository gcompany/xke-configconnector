resource "google_project" "configconnector_project" {
  name            = "xke demo cc"
  project_id      = "xke-configconn-demo"
  folder_id       = local.folder_id
  billing_account = local.billing_account_id
}

// node service account
resource "google_service_account" "cluster_sa" {
  account_id   = "cluster-sa"
  display_name = "GKE Nodes Service Account"
  project      = google_project.configconnector_project.project_id
}

resource "google_project_iam_member" "project" {
  project = google_project.configconnector_project.project_id
  role    = "roles/editor"
  member  = google_service_account.cluster_sa.member
}


resource "google_project_service" "services" {
  count              = length(local.services)
  project            = google_project.configconnector_project.id
  service            = element(local.services, count.index)
  depends_on         = [google_project.configconnector_project]
  disable_on_destroy = false
}

