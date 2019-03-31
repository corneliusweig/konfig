# konfig-merge
A kubectl plugin to ease merging of kubeconfig files

## Usage

#### Merge several kubeconfig files
```bash
konfig-merge config1 config2 > merged-config
```
This variant creates a self-contained kubeconfig where all credentials are stored inline in the kubeconfig.
If you want to preserve the structure and keep credentials separate, see `--preserve-structure`.

#### Merge several kubeconfig files
```bash
konfig-merge --preserve-structure config1 config2 > merged-config
# or
konfig-merge -p config1 config2 > merged-config
```
This variant preserves the structure of your kubeconfig files.
For example, if credentials were stored in separate files, they are still kept separate.

**Caveat** If you merge kubeconfigs from different directories, referencing credentials in relative local paths, theses file links will break.
Use the `--flatten` option for these cases.

#### Extract a minimal kubeconfig for some context
This will extract a minimal kubeconfig with a single context `minikube`:
```bash
# extract context minikube from the default kubeconfig
konfig-merge --extract minikube > minikube.config

# extract context minikube from the given kubeconfig
konfig-merge -e minikube ~/.kube/other > minikube.config
```
