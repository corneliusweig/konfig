<!-- DO NOT MOVE THIS FILE, BECAUSE IT NEEDS A PERMANENT ADDRESS -->

# konfig
konfig helps to merge, split or import kubeconfig files

## Usage

The following assumes that you have installed `konfig` via
```bash
kubectl krew install konfig
```

### Import a kubeconfig
```bash
kubectl konfig import new-cfg > ~/.kube/config
```
Imports the config file `new-cfg` into the default kubeconfig.

### Merge several kubeconfig files
```bash
kubectl konfig merge config1 config2 > merged-config
```
This variant creates a self-contained kubeconfig where all credentials are stored inline in the kubeconfig.
If you want to preserve the structure and keep credentials separate, use `--preserve-structure`.

### Extract a minimal kubeconfig for one or several contexts
This will extract a minimal kubeconfig with a single context `minikube`:
```bash
# extract context minikube from the default kubeconfig
kubectl konfig extract minikube > minikube.config

# extract context minikube and docker-for-desktop from two input configs
kubectl konfig extract minikube docker-for-desctop -k ~/.kube/other,~/dockercfg > local
```
