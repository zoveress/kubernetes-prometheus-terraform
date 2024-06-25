variable "prometheus_namespace" {
  default = "prometheus"
}

variable "prometheus_repo" {
  type    = string
  default = "https://prometheus-community.github.io/helm-charts"
}

variable "prometheus_release_name" {
  type    = string
  default = "prometheus"
}

variable "prometheus_name" {
  type    = string
  default = "prometheus"
}

variable "prometheus_hostname" {
  type    = string
  default = "prometheus"
}

variable "main_domain" {
  default = "example.com"
}

variable "prometheus_port" {
  default = 9090
}

variable "nginx_namespace" {
  default = "default"
}

variable "nginx_name" {
  default = "nginx-ingress-controller"
}

variable "prometheus_http_secret_name" {
  default = "http-auth"
}