local vars = import '../vars.libsonnet';

{
  "apiVersion": "networking.istio.io/v1alpha3",
  "kind": "VirtualService",
  "metadata": {
    "name": "landing-page"
  },
  "spec": {
    "hosts": [
      vars.domain
    ],
    "gateways": [
      "istio-system/ingressgateway"
    ],
    "http": [
      {
        "route": [
          {
            "destination": {
              "port": {
                "number": 80
              },
              "host": "landing-page.web.svc.cluster.local"
            }
          }
        ]
      }
    ]
  }
}
