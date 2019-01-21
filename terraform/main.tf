variable "master_username" {
  type="string"
}

variable "master_password" {
  type="string"
}

variable "coypu_version" {
  type="string"
}

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
  username               = "${var.master_username}"
  password               = "${var.master_password}"
  client_certificate     = "${base64decode(google_container_cluster.primary.master_auth.0.client_certificate)}"
  client_key             = "${base64decode(google_container_cluster.primary.master_auth.0.client_key)}"
  cluster_ca_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
}

provider "helm" {
  kubernetes {
    host                   = "${google_container_cluster.primary.endpoint}"
    username               = "${var.master_username}"
    password               = "${var.master_password}"
    client_certificate     = "${base64decode(google_container_cluster.primary.master_auth.0.client_certificate)}"
    client_key             = "${base64decode(google_container_cluster.primary.master_auth.0.client_key)}"
    cluster_ca_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
  }
}

resource "google_container_cluster" "primary" {
  name               = "coypu-cluster"
  zone               = "us-east1-b"
  initial_node_count = 3
  
  master_auth {
    username = "${var.master_username}"
    password = "${var.master_password}"
  }
  
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

resource "kubernetes_deployment" "coypu_server" {
  metadata {
    name = "coypu-server"
    labels {
      App = "coypu"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels {
        App = "coypu"
      }
    }

    template {
      metadata {
        labels {
          App = "coypu"
        }
      }

      spec {
        container {
          name  = "coypu"
          image = "gcr.io/${var.project_name}/coypu:${var.coypu_version}"

          resources {
            requests {
              cpu = "1" 
              memory = "256Mi"
            }
          }
        
          
          port {
            container_port = 8080
          }
        }

        image_pull_secrets =  {
          name =  "docker-registry"
        }
      }
    }
  }
}

resource "kubernetes_service" "coypu" {
  metadata {
    name = "coypu-example"
  }
  spec {
    selector {
      App = "coypu"
    }
    port {
      port = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}

/*
output "client_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.client_certificate}"
}

output "client_key" {
  value = "${google_container_cluster.primary.master_auth.0.client_key}"
}

output "cluster_ca_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
}
*/

output "coypu_ip" {
  value = "${kubernetes_service.coypu.load_balancer_ingress.0.ip}"
}
