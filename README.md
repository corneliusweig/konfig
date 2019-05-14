# konfig
konfig helps to merge, split or import kubeconfig files

## Usage

### Import a kubeconfig
```bash
konfig import --save new-cfg
```
Imports the config file `new-cfg` into the default kubeconfig at `~/.kube/config`.
To show the result without changing your kubeconfig, do
```bash
konfig import new-cfg
```

CAVEAT: due to how shells work, the following will lose your current `~/.kube/config`
```bash
# WRONG, don't do this!
konfig import new-cfg > ~/.kube/config
```

### Merge several kubeconfig files
```bash
konfig merge config1 config2 > merged-config
```
This variant creates a self-contained kubeconfig where all credentials are stored inline in the kubeconfig.
If you want to preserve the structure and keep credentials separate, use `--preserve-structure`.

### Extract a minimal kubeconfig for one or several contexts
This will extract a minimal kubeconfig with a single context `minikube`:
```bash
# extract context minikube from the default kubeconfig
konfig extract minikube > minikube.config

# extract context minikube and docker-for-desktop from two input configs
konfig extract minikube docker-for-desctop -k ~/.kube/other,~/dockercfg > local
```

## Installation
There are several ways to install `konfig`.
<!--
The recommended installation method is via `krew`.

### Via krew
Krew is the `kubectl` plugin manager. If you have not yet installed `krew`, get it at
[https://github.com/GoogleContainerTools/krew](https://github.com/GoogleContainerTools/krew).
Then installation is as simple as
```bash
kubectl krew install konfig
```
The plugin will be available as `kubectl get-all`, see [doc/USAGE](doc/USAGE.md) for further details.
-->

### Manual
When using the binaries for installation, also have a look at [USAGE](#Usage).

#### OSX & Linux
```bash
curl -Lo konfig https://github.com/corneliusweig/konfig/raw/v0.2.0/konfig \
  chmod +x konfig && sudo mv -i konfig /usr/local/bin
```
Feel free to change the `sudo mv` to put `konfig` in some other location from your `$PATH` variable.

#### Windows
Download [konfig](https://github.com/corneliusweig/konfig/raw/v0.2.0/konfig) and put it in your PATH as `konfig.exe`.
