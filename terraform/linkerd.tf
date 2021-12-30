#resource "tls_private_key" "linkerd_key" {
#  algorithm   = "ECDSA"
#  ecdsa_curve = "P384"
#}
#
#resource "tls_self_signed_cert" "linkerd_cert" {
#  key_algorithm   = "ECDSA"
#  private_key_pem = tls_private_key.linkerd_key.private_key_pem
#
#  subject {
#    common_name  = "happylittlecloud.ca"
#    organization = "Blair Drummond"
#  }
#
#  validity_period_hours = 8760
#
#  allowed_uses = [
#    "key_encipherment",
#    "digital_signature",
#    "server_auth",
#  ]
#}
#
#resource "tls_cert_request" "linkerd_cert_request" {
#  key_algorithm   = "ECDSA"
#  private_key_pem = tls_private_key.linkerd_key.private_key_pem
#
#  subject {
#    common_name  = "happylittlecloud.ca"
#    organization = "Blair Drummond"
#  }
#}
#
#resource "tls_locally_signed_cert" "linkerd_local" {
#  cert_request_pem   = tls_cert_request.linkerd_cert_request.cert_request_pem
#  ca_key_algorithm   = "ECDSA"
#  ca_private_key_pem = tls_private_key.linkerd_key.private_key_pem
#  ca_cert_pem        = tls_self_signed_cert.linkerd_cert.cert_pem
#
#  validity_period_hours = 8760
#
#  allowed_uses = [
#    "key_encipherment",
#    "digital_signature",
#    "server_auth",
#  ]
#}
#
#resource "helm_release" "linkerd" {
#  name       = "linkerd"
#  repository = "https://helm.linkerd.io/stable"
#  chart      = "linkerd2"
#
#  set {
#    name  = "global.identityTrustAnchorsPEM"
#    value = tls_self_signed_cert.linkerd_cert.cert_pem
#  }
#
#  set {
#    name  = "identity.issuer.crtExpiry"
#    value = tls_locally_signed_cert.linkerd_local.validity_end_time
#  }
#
#  set {
#    name  = "identity.issuer.tls.crtPEM"
#    value = tls_locally_signed_cert.linkerd_local.cert_pem
#  }
#
#  set {
#    name  = "identity.issuer.tls.keyPEM"
#    value = tls_private_key.linkerd_key.private_key_pem
#  }
#}
