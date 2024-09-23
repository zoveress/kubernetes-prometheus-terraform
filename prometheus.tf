resource "helm_release" "prometheus" {
  name       = var.prometheus_name
  chart      = var.prometheus_release_name
  repository = var.prometheus_repo
  namespace  = var.prometheus_namespace

  set {
    name  = "affinity"
    value = jsonencode({
      nodeAffinity = {
        requiredDuringSchedulingIgnoredDuringExecution = {
          nodeSelectorTerms = [{
            matchExpressions = [{
              key      = "small_node"
              operator = "In"
              values   = ["true"]
            }]
          }]
        }
      }
    })
  }
}

resource "kubernetes_ingress_v1" "prometheus-ingress" {
  wait_for_load_balancer = true
  metadata {
    name      = "${var.prometheus_name}-ingress"
    namespace = var.prometheus_namespace
    annotations = {
      "cert-manager.io/cluster-issuer"          = "letsencrypt-prod"
      "kubernetes.io/tls-acme"                  = "true"
      "nginx.ingress.kubernetes.io/auth-type"   = "basic"
      "nginx.ingress.kubernetes.io/auth-secret" = data.kubernetes_secret.prometheus-http.metadata[0].name
      "nginx.ingress.kubernetes.io/auth-realm"  = "Authentication Required - Prometheus"
    }
  }

  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = ["${var.prometheus_hostname}.${var.main_domain}"]
      secret_name = "${var.prometheus_hostname}.${var.main_domain}.tls"
    }
    rule {
      host = "${var.prometheus_hostname}.${var.main_domain}"
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.prometheus-service.metadata.0.name
              port {
                number = var.prometheus_port
              }
            }
          }

          path = "/"
        }

      }
    }

  }
}

resource "kubernetes_service_v1" "prometheus-service" {
  metadata {
    name      = "${var.prometheus_name}-service"
    namespace = var.prometheus_namespace
  }
  spec {
    selector = {
      "app.kubernetes.io/name" = "prometheus"
    }
    port {
      port = var.prometheus_port
    }
  }
}

resource "aws_route53_record" "prometheus-cname-record" {
  zone_id = data.aws_route53_zone.base-domain.zone_id
  name    = "${var.prometheus_hostname}.${var.main_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = [data.kubernetes_service.nginx-ingress-controller.status.0.load_balancer.0.ingress.0.hostname]
}