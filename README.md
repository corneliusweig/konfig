# konfig

![Latest GitHub release](https://img.shields.io/github/release/corneliusweig/konfig.svg)
![GitHub workflow status](https://img.shields.io/github/workflow/status/corneliusweig/konfig/konfig%20CI)
![Written in Bash](https://img.shields.io/badge/written%20in-bash-19bb19.svg)
<!--![GitHub stars](https://img.shields.io/github/stars/corneliusweig/konfig.svg?label=github%20stars)-->

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
konfig export minikube > minikube.config

# extract context minikube and docker-for-desktop from two input configs
konfig export minikube docker-for-desktop -k ~/.kube/other,~/dockercfg > local
```

## Installation
There are several ways to install `konfig`.
The recommended installation method is via `krew`.

### Via krew
Krew is the `kubectl` plugin manager. If you have not yet installed `krew`, get it at
[https://github.com/kubernetes-sigs/krew](https://github.com/kubernetes-sigs/krew).
Then installation is as simple as
```bash
kubectl krew install konfig
```
The plugin will be available as `kubectl konfig`, see [doc/USAGE](doc/USAGE.md) for further details. You could also define an alias as well: `alias konfig = 'kubectl konfig'`

### Manual
When using the binaries for installation, also have a look at [USAGE](#Usage).

#### OSX & Linux
```bash
curl -Lo konfig https://github.com/corneliusweig/konfig/raw/v0.2.0/konfig \
  && chmod +x konfig \
  && sudo mv -i konfig /usr/local/bin
```
Feel free to change the `sudo mv` to put `konfig` in some other location from your `$PATH` variable.

#### Windows
Download [konfig](https://github.com/corneliusweig/konfig/raw/v0.2.0/konfig) and put it in your PATH as `konfig.exe`.
