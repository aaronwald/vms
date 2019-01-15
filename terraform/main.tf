variable "master_username" {
  type="string"
}

variable "master_password" {
  type="string"
}

provider "google" {
  project = "massive-acrobat-227416"
  region  = "us-east1"
  zone    = "us-east1-b"
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

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"

  boot_disk {
	 initialize_params {
		image = "debian-cloud/debian-9"
	 }
  }

  network_interface {
	 network       = "${google_compute_network.vpc_network.self_link}"
	 access_config = {
		// give external ip
	 }
  }

  metadata {
	 sshKeys = "wald:${file("~/.ssh/id_rsa.pub")}"
  }
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


resource "kubernetes_pod" "nginx" {
  metadata {
	 name = "nginx-example"
	 labels {
		App = "nginx"
	 }
  }

  spec {
	 container {
		image = "nginx:1.15.2"
		name  = "example"

		port {
		  container_port = 80
		}
	 }
  }
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

resource "kubernetes_pod" "coypu" {
  metadata {
	 name = "coypu-example"
	 labels {
		App = "coypu"
	 }
  }


  spec {
	 image_pull_secrets =  {
		name =  "docker-registry"
	 }

	 container {
		image = "gcr.io/massive-acrobat-227416/coypu:latest"
		name  = "coypu-ws"

		port {
		  container_port = 8080
		}
	 }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
	 name = "nginx-example"
  }
  spec {
	 selector {
		App = "${kubernetes_pod.nginx.metadata.0.labels.App}"
	 }
	 port {
		port = 80
		target_port = 80
	 }

	 type = "LoadBalancer"
  }
}

resource "kubernetes_service" "coypu" {
  metadata {
	 name = "coypu-example"
  }
  spec {
	 selector {
		App = "${kubernetes_pod.coypu.metadata.0.labels.App}"
	 }
	 port {
		port = 80
		target_port = 8080
	 }

	 type = "LoadBalancer"
  }
}


/* need service account
resource "helm_release" "mydatabase" {
    name      = "nutriadb"
    chart     = "stable/postgresql"

    set {
        name  = "postgresqlUsername"
        value = "foo"
    }

    set {
        name = "postgresqlPassword"
        value = "qux"
    }
}
*/

output "ip" {
  value = "${google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip}"
}

output "client_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.client_certificate}"
}

output "client_key" {
  value = "${google_container_cluster.primary.master_auth.0.client_key}"
}

output "cluster_ca_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
}

output "lb_ip" {
  value = "${kubernetes_service.nginx.load_balancer_ingress.0.ip}"
}

output "coypu_ip" {
  value = "${kubernetes_service.coypu.spec.0.cluster_ip}"
}
