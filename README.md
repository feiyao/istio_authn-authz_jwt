# Istio authN/Z with JWT

Table of contents
=================
* [Installation](#installation)
    * [Cluster](#install-cluster)
    * [Istio](#install-istio)
* [Setup Auth0](#setup-auth0)

Installation
============
We will install Istio, Istio-Ingressgateway into a local cluster using [K3d](https://k3d.io).

Install Cluster
===============
```
$ ./installation/install-cluster.zsh
...
```

Install Istio
=============
Setup the Istio version
```
$
export ISTIO_VERSION=1.14.1
export ISTIO_VERSION_TAG=1.14.1-distroless
export ISTIO_REVISION=1-14-1
```
Install Istiod
```
$ ./installation/install-istio.zsh
...
```
Install Istio-Ingressgateway
```
$ ./installation/install-gateway.zsh
...
```
