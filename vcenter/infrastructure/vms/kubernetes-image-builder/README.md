# Kubernetes Image Builder

Used to build templates using https://github.com/kubernetes-sigs/image-builder

1. Export required environment variables (only needed if `vsphere.json` file not updated):

```sh
export VSPHERE_SERVER=
export VSPHERE_USERNAME=
export VSPHERE_PASSWORD=
export VSPHERE_DATACENTER=
export VSPHERE_CLUSTER=
export VSPHERE_NETWORK=
export VSPHERE_DATASTORE=
export VSPHERE_TEMPLATE_FOLDER=
```

2. Update `vsphere.json`:

```sh
envsubst < vsphere.json.tmpl > vsphere.json
```

3. Select the desired Kuberenetes version file:

```sh
export KUBERNETES_VERSION=v1.26.6
docker run -it --rm --net=host \
  --env PACKER_VAR_FILES="/home/imagebuilder/vars/vsphere.json /home/imagebuilder/vars/kubernetes.json" \
  --volume "$(pwd)/vsphere.json":"/home/imagebuilder/vars/vsphere.json" \
  --volume "$(pwd)/kubernetes-$KUBERNETES_VERSION.json":"/home/imagebuilder/vars/kubernetes.json" \
  registry.k8s.io/scl-image-builder/cluster-node-image-builder-amd64:v0.1.16 build-node-ova-vsphere-photon-4
```
