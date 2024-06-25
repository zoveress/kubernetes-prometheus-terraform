data "aws_region" "current" {}

data "aws_secretsmanager_secret" "main_kubernetes" {
  name = "main_kubernetes"
}

data "kubernetes_secret" "prometheus-http" {
  metadata {
    name      = var.prometheus_http_secret_name
    namespace = var.prometheus_namespace
  }
}

data "aws_secretsmanager_secret_version" "main_kubernetes_credentials" {
  secret_id = data.aws_secretsmanager_secret.main_kubernetes.id
}

data "aws_eks_cluster" "cluster" {
  name = jsondecode(data.aws_secretsmanager_secret_version.main_kubernetes_credentials.secret_string)["cluster_id"]
}

data "aws_eks_cluster_auth" "cluster" {
  name = jsondecode(data.aws_secretsmanager_secret_version.main_kubernetes_credentials.secret_string)["cluster_id"]
}

data "aws_route53_zone" "base-domain" {
  name = var.main_domain
}

data "kubernetes_service" "nginx-ingress-controller" {
  metadata {
    name      = var.nginx_name
    namespace = var.nginx_namespace
  }
}

output "nginx-ingress-controller-hostname" {
  value = data.kubernetes_service.nginx-ingress-controller.status.0.load_balancer.0.ingress.0.hostname
}