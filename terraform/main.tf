
variable "project_name" {
  type="string"
}

provider "google" {
  project = "${var.project_name}"
  region  = "us-east1"
  zone    = "us-east1-b"
}

provider "kubernetes" {
  host                   = "${google_container_cluster.primary.endpoint}"
  client_certificate     = "${base64decode(google_container_cluster.primary.master_auth.0.client_certificate)}"
  client_key             = "${base64decode(google_container_cluster.primary.master_auth.0.client_key)}"
  cluster_ca_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
}

resource "google_container_cluster" "primary" {
  name               = "coypu-cluster"
  zone               = "us-east1-b"
  initial_node_count = 3
  
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]

    machine_type       = "n1-standard-2"
  }
  
  network = "${google_compute_network.vpc_network.name}"
}

resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = "${google_compute_network.vpc_network.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }
}

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = "true"
}

resource "kubernetes_secret" "docker-registry" {
  metadata {
    name = "docker-registry"
  }

  data {
    ".dockerconfigjson" = "${file("pull-container.json")}"
  }

  type = "kubernetes.io/dockerconfigjson"
}

