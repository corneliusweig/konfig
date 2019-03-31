# konfig-merge
A kubectl plugin to ease merging of kubeconfig files

## Usage

### Merge several kubeconfig files
```bash
konfig-merge config1 config2 > merged-config
```
This variant creates a self-contained kubeconfig where all credentials are stored inline in the kubeconfig.
If you want to preserve the structure and keep credentials separate, see `--preserve-structure`.

### Merge several kubeconfig files
```bash
konfig-merge --preserve-structure config1 config2 > merged-config
# or
konfig-merge -p config1 config2 > merged-config
```
This variant preserves the structure of your kubeconfig files.
For example, if credentials were stored in separate files, they are still kept separate.

**Caveat** If you merge kubeconfigs from different directories, referencing credentials in relative local paths, theses file links will break.
Remove the `--preserve-structure` option for these cases.

### Extract a minimal kubeconfig for some context
This will extract a minimal kubeconfig with a single context `minikube`:
```bash
# extract context minikube from the default kubeconfig
konfig-merge --extract minikube > minikube.config

# extract context minikube from the given kubeconfig
konfig-merge -e minikube ~/.kube/other > minikube.config
```

## Installation
There are several ways to install `konfig-merge`.
<!--
The recommended installation method is via `krew`.

### Via krew
Krew is the `kubectl` plugin manager. If you have not yet installed `krew`, get it at
[https://github.com/GoogleContainerTools/krew](https://github.com/GoogleContainerTools/krew).
Then installation is as simple as
```bash
kubectl krew install config-merge
```
The plugin will be available as `kubectl get-all`, see [doc/USAGE](doc/USAGE.md) for further details.
-->

### Manual
When using the binaries for installation, also have a look at [USAGE](#Usage).

#### OSX & Linux
```bash
curl -Lo konfig-merge https://github.com/corneliusweig/konfig-merge/raw/v0.1.0/konfig-merge \
  chmod +x konfig-merge && sudo mv -i konfig-merge /usr/local/bin
```
Feel free to change the `sudo mv` to put `konfig-merge` in some other location from your `$PATH` variable.

#### Windows
Download [konfig-merge](https://github.com/corneliusweig/konfig-merge/raw/v0.1.0/konfig-merge) and put it in your PATH as `konfig-merge.exe`.
