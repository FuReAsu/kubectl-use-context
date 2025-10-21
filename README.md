# Kubectl Use Context

[kuc]</br>
A script to quickly switch kubectl contexts.</br>
kuc uses KUBECONFIG environment variable to switch kubectl contexts.</br>
This allows the user to use multiple kubectl contexts in multiple shell sessions at the same time.</br>
This is different from using `kubectl config use-context` which sets the context for the whole machine.

kuc is also intended to import kubectl config files for new clulsters more easily rather than using `kubectl config set-cluster|set-credentials|set-context` commands for every new cluster.

## Working Shells

This is intended for `bash` and any `bash-based` shells like `zsh`. On linux systems including WSL. 

## How to install

Clone the repo
```
git clone --depth 1 https://github.com/FuReAsu/kubectl-use-context.git 
```
Go into the directory
```
cd kubectl-use-context
```
Run Install
```
./kuc.sh install
```
You can then start using kuc
```
kuc --help
```

## Options

|option|description|input-value|example|
|---|---|---|---|
|--help|shows the help prompt|none|`kuc --help`|
|import|copy config files into the config dir at $HOME/.kube/config.d.|space separated file paths (relative or absolute)|`kuc import ./test.yaml /tmp/dev.yaml`|
|install|copies the script to $HOME/.local/bin and add a kuc(){} line in shell rc file.|none|`./kuc.sh install`|
|current|shows the current config file being used|none|`kuc current`|
|latest|shows the latest config file being used|none|`kuc latest`|
|1-999|choose which config file to use|integer (valid-range)|`kuc 3`
|none|don't use any kubectl config (use this if you want to disable kubectl)|none|`kuc none`|
