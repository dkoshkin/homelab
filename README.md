# Dimitri's Homelab

This repo contains Kubernetes specs used by [Flux](https://fluxcd.io/flux/installation/).

Its managing the following clutsters and applications:

* green
  * [cert-manager](https://cert-manager.io/)
  * [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)
  * [PostgreSQL](https://github.com/bitnami/charts/tree/main/bitnami/postgresql)
  * [Teslmate](https://docs.teslamate.org/docs/installation/docker), using a custom [Teslamate Helm Chart](https://github.com/dkoshkin/teslamate-helm-chart)
  * [Grafana](https://github.com/grafana/helm-charts)
