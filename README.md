# Dimitri's Homelab

Application Statuses https://monitor-green-apps.dimitrikoshkin.com/status/homelab

This repo contains Kubernetes specs used by [Flux](https://fluxcd.io/flux/installation/).

Its managing the following clutsters and applications:

* green
  * [cert-manager](https://cert-manager.io/)
  * [Traefik](https://github.com/traefik/traefik)
  * [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)
  * [Uptime Kuma](https://uptime.kuma.pet/) - Application monitoring and status pages
  * [CloutNativePG](https://cloudnative-pg.io/)
  * [Teslmate](https://docs.teslamate.org/docs/installation/docker), using a custom [Teslamate Helm Chart](https://github.com/dkoshkin/teslamate-helm-chart)
  * [Grafana](https://github.com/grafana/helm-charts)
