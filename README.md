# Dimitri's Homelab

This repo contains Kubernetes specs used by [Flux](https://fluxcd.io/flux/installation/).

Its managing the following clutsters and applications:

* microk8s
  * [cert-manager](https://cert-manager.io/)
  * [NGINX Ingress](https://github.com/kubernetes/ingress-nginx)
  * [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)
  * [PostgreSQL](https://github.com/bitnami/charts/tree/main/bitnami/postgresql)
  * [Teslmate](https://docs.teslamate.org/docs/installation/docker), using a custom [Teslamate Helm Chart](https://github.com/dkoshkin/teslamate-helm-chart)
  * [Grafana](https://github.com/grafana/helm-charts)

* blue
  * [kube-vip](https://github.com/kube-vip/kube-vip)
  * [cert-manager](https://cert-manager.io/)
  * [NGINX Ingress](https://github.com/kubernetes/ingress-nginx)
  * [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)
  * [PostgreSQL](https://github.com/bitnami/charts/tree/main/bitnami/postgresql)
  * [Teslmate](https://docs.teslamate.org/docs/installation/docker), using a custom [Teslamate Helm Chart](https://github.com/dkoshkin/teslamate-helm-chart)
  * [Grafana](https://github.com/grafana/helm-charts)
