data "http" "metallb-config" {
  url = "https://kind.sigs.k8s.io/examples/loadbalancer/metallb-config.yaml"
  request_headers = {
    Accept = "text/plain"
  }
}

locals {
  yamls = [for data in split("---", data.http.metallb-config.response_body): yamldecode(data)]
}

resource "kubernetes_manifest" "metallb-config" {
  count = length(local.yamls)
  manifest = local.yamls[count.index]
}

// locals {
//   yamls = [for data in split("---", data.http.crd.body): yamldecode(data)]
// }

// resource "kubernetes_manifest" "install-crd" {
//   count = length(local.yamls)
//   manifest = local.yamls[count.index]
// }

// data "kubernetes_resources" "prometheus-operator" {
//   api_version = "apiextensions.k8s.io/v1"
//   kind = "CustomResourceDefinition"
//   field_selector = "metadata.name==prometheuses.monitoring.coreos.com"
// }

// resource "kubernetes_manifest" "service-monitors" {
//   for_each = fileset("", "manifests/service-monitors/*.yaml")
//   manifest = yamldecode(file(each.value))
//   depends_on = [
//     data.kubernetes_namespace.monitoring,
//     data.kubernetes_resources.prometheus-operator
//   ]
// }