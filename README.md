# Dimitri's Homelab

This repo contains Kubernetes specs used by [Flux](https://fluxcd.io/flux/installation/).

Its managing the following infrastructure and applications:

* Infrastructure
  * [cert-manager](https://cert-manager.io/) - TLS certificate management with Cloudflare DNS challenge
  * [Traefik](https://github.com/traefik/traefik) - Ingress controller
  * [MetalLB](https://metallb.universe.tf/) - Bare-metal load balancer
  * [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets) - Encrypted secret management stored in git
  * [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/) - Secure tunneling with Cloudflare
  * [local-path-provisioner](https://github.com/rancher/local-path-provisioner) - Automated local storage CSI
  * Observability
    * [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) - Prometheus, Alertmanager, and node exporters
    * [Grafana](https://github.com/grafana/helm-charts) - Dashboards and visualization
    * [Loki](https://grafana.com/oss/loki/) - Log aggregation
    * [Alloy](https://grafana.com/oss/alloy-opentelemetry-collector/) - Telemetry collector
    * [Prometheus Adapter](https://github.com/kubernetes-sigs/prometheus-adapter) - Exposes Prometheus metrics for HPA, replacing the [metrics-server](https://kubernetes-sigs.github.io/metrics-server/)
    * [Uptime Kuma](https://uptime.kuma.pet/) - Application monitoring and status pages
    * [Flux Dashboard](https://github.com/fluxcd/flux2) - GitOps workflow visualization
* Applications
  * [CloudNativePG](https://cloudnative-pg.io/) - PostgreSQL operator
  * [Teslamate](https://docs.teslamate.org/docs/installation/docker) - Tesla vehicle data logging, using a custom [Teslamate Helm Chart](https://github.com/dkoshkin/teslamate-helm-chart)
  * [ASP Fantasy](https://github.com/dkoshkin/asp-fantasy) - Custom application with image automation
  * [Lovenotes](https://github.com/dkoshkin/lovenotes) - Custom application with image automation
