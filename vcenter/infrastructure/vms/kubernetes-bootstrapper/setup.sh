#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

printf "\nInstalling kind https://kind.sigs.k8s.io/docs/user/quick-start/\n"
rm -rf ./kind
sudo rm -rf /usr/local/bin/kind
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind version

printf "\nInstalling kubectl https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/\n"
sudo rm -rf /usr/local/bin/kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
rm -rf kubectl
sudo echo "source <(kubectl completion bash)" >> ~/.bashrc
sudo echo "alias k=kubectl" >> ~/.bashrc

printf "\nInstalling clusterctl https://cluster-api.sigs.k8s.io/user/quick-start.html#install-clusterctl\n"
sudo rm -rf /usr/local/bin/clusterctl
curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.4.4/clusterctl-linux-amd64 -o clusterctl
sudo install -o root -g root -m 0755 clusterctl /usr/local/bin/clusterctl
clusterctl version
rm -rf clusterctl

printf "\nInstalling Flux CLI https://fluxcd.io/flux/cmd/\n"
curl -s https://fluxcd.io/install.sh | sudo bash

printf "\nInstalling Sealed Secret CLI https://github.com/bitnami-labs/sealed-secrets#linux\n"
sudo rm -rf /usr/local/bin/kubeseal
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.22.0/kubeseal-0.22.0-linux-amd64.tar.gz
tar -xvzf kubeseal-0.22.0-linux-amd64.tar.gz kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
rm -rf kubeseal-0.22.0-linux-amd64.tar.gz kubeseal
