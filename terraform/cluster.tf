
resource "google_container_cluster" "primary" {

  provider = google-beta

  project = google_project.configconnector_project.project_id

  name               = "xke-cc"
  location           = "europe-west1"
  initial_node_count = 1

  private_cluster_config {
    master_ipv4_cidr_block  = "10.0.0.0/28"
    enable_private_nodes    = true
    enable_private_endpoint = false
  }

  node_config {
    preemptible     = false
    machine_type    = "e2-medium"
    service_account = google_service_account.cluster_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/16"
    services_ipv4_cidr_block = "/22"
  }


  addons_config {
    config_connector_config {
      enabled = true
    }
  }

  workload_identity_config {
    workload_pool = "${google_project.configconnector_project.project_id}.svc.id.goog"
  }

  timeouts {
    create = "30m"
    update = "40m"
  }

  depends_on = [
    google_project_service.services
  ]
}

output "gke_endpoint" {
  value = google_container_cluster.primary.endpoint
}

