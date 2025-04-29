resource "kubernetes_service" "helloworld-dart" {
  metadata {
    name      = "helloworld-dart"
    namespace = "helloworld-dart"
    labels = {
      app         = "helloworld-dart"
      environment = "production"
      tenant      = "willianpaixao"
    }
  }

  spec {
    selector = {
      app = "helloworld-dart"
    }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
      name        = "http"
    }

    type = "ClusterIP"
  }
}