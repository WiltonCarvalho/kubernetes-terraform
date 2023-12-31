# https://betterprogramming.pub/opentelemetry-sending-traces-from-ingress-nginx-to-multi-tenant-grafana-tempo-e98d482c733
resource "helm_release" "ingress-nginx-private" {
  name             = "ingress-nginx-private"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.8.4"
  namespace        = "ingress-nginx-private"
  create_namespace = true
  values           = [file("values/ingress-nginx-private.yaml")]
  depends_on = [
    helm_release.metrics-server
  ]
  // set {
  //   name  = "controller.hostPort.enabled"
  //   value = "true"
  // }
  // set {
  //   name  = "controller.service.type"
  //   value = "NodePort"
  // }
  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
  set {
    name  = "controller.service.annotations.\"metallb\\.universe\\.tf/loadBalancerIPs\""
    value = "172.19.255.250"
  }
}
