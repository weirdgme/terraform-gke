provider "kubernetes" {
  load_config_file = false

  host                   = "https://${module.gke_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_cluster.ca_certificate)
}

resource "kubernetes_namespace" "gke-demo" {
  metadata {
    name = "gke-demo"
  }
}

resource "kubernetes_deployment" "app-deploy-demo" {
  metadata {
    name      = "app-deploy-demo"
    namespace = kubernetes_namespace.gke-demo.id
    labels = {
      app = "app-deploy-demo"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "app-deploy-demo"
      }
    }

    template {
      metadata {
        labels = {
          app = "app-deploy-demo"
        }
      }

      spec {
        container {
          image = "kserge2001/school"
          name  = "app-deploy-demo"
        }
      }
    }
  }
}

resource "kubernetes_service" "app-deploy-service" {
  metadata {
    name      = "app-deploy-service"
    namespace = kubernetes_namespace.gke-demo.id
  }
  spec {
    selector = {
      app = "${kubernetes_deployment.app-deploy-demo.metadata.0.labels.app}"
    }
    port {
      port        = 8080
      target_port = 8080
    }
    type = "LoadBalancer"
  }
}
