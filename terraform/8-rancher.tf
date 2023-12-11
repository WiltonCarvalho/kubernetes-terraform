// resource "helm_release" "cert-manager" {
//   name = "cert-manager"
//   repository       = "https://charts.jetstack.io"
//   chart            = "cert-manager"
//   namespace        = "cert-manager"
//   create_namespace = true
//   version          = "v1.13.2"
//   set {
//     name  = "installCRDs"
//     value = "true"
//   }
// }

// resource "helm_release" "rancher-stable" {
//   name = "rancher-stable"
//   repository       = "https://releases.rancher.com/server-charts/stable"
//   chart            = "rancher"
//   namespace        = "cattle-system"
//   create_namespace = true
//   version          = "2.7.9"
//   values = [file("values/rancher.yaml")]
//   depends_on = [
//     helm_release.cert-manager,
//     helm_release.ingress-nginx-private
//   ]
// }

# kubectl -n cattle-system get pod
# firefox 'https://rancher.172.19.0.1.sslip.io/dashboard/?setup=admin'