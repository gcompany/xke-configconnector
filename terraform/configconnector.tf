
data "google_client_config" "provider" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.provider.access_token
  client_certificate     = base64decode(google_container_cluster.primary.master_auth.0.client_certificate)
  client_key             = base64decode(google_container_cluster.primary.master_auth.0.client_key)
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)

}

// configconnector service account
resource "google_service_account" "cc_sa" {
  account_id   = "configconnector-sa"
  display_name = "Config Connector Service Account"
  project      = google_project.configconnector_project.project_id
}

resource "google_project_iam_member" "cc_sa_iam" {
  project = google_project.configconnector_project.project_id
  role    = "roles/owner"
  member  = google_service_account.cc_sa.member
}


# allow ksa `cnrm-controller-manager` in namespace `cnrm-system` access to gsa `cc_sa`
resource "google_service_account_iam_member" "gce-default-account-iam" {
  service_account_id = google_service_account.cc_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${google_project.configconnector_project.project_id}.svc.id.goog[cnrm-system/cnrm-controller-manager]"
}


# https://cloud.google.com/config-connector/docs/how-to/install-upgrade-uninstall#addon-configuring
resource "kubernetes_manifest" "configconnector_configconnector_core_cnrm_cloud_google_com" {
  manifest = {
    "apiVersion" = "core.cnrm.cloud.google.com/v1beta1"
    "kind" = "ConfigConnector"
    "metadata" = {
      "name" = "configconnector.core.cnrm.cloud.google.com"
    }
    "spec" = {
      "mode" = "cluster"
      "googleServiceAccount" = google_service_account.cc_sa.email
    }
  }
}

resource "kubernetes_namespace" "resources_namespace" {
  metadata {
    annotations = {
      "cnrm.cloud.google.com/project-id" = google_project.configconnector_project.project_id
    }

    name = "resources-namespace"
  }
}


# resource "kubernetes_service_account_v1" "managed_resources_ksa" {
#   metadata {
#     name = "managed-resources-ksa"
#     namespace = kubernetes_namespace.managed_resources.metadata.name
#   }
# }
