# Istio authN/Z with JWT

Table of contents
=================
* [Installation](#installation)
    * [Cluster](#install-cluster)
    * [Istio](#install-istio)
    * [Application](#install-application)
* [Setup Auth0](#setup-auth0)

Installation
============
We will install Istio, Istio-Ingressgateway into a local cluster created by [K3d](https://k3d.io). For the demo purpose we'll also need to install [httpbin service](https://github.com/istio/istio/blob/master/samples/httpbin/httpbin.yaml).

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

Make `default` namespace Istio sidecar auto-injection.
```
$ kubectl label namespace default istio.io/rev=$ISTIO_REVISION --overwrite
```

Install Application
===================
```
% kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.14/samples/httpbin/httpbin.yaml
serviceaccount/httpbin created
service/httpbin created
deployment.apps/httpbin created
```

Install Istio Gateway, VirtualService, PeerAuthentication, RequestAuthentication, AuthorizationPolicy.
```
$ kubectl apply -k ./ 
gateway.networking.istio.io/httpbin-gateway created
virtualservice.networking.istio.io/httpbin created
authorizationpolicy.security.istio.io/require-jwt-httpbin created
authorizationpolicy.security.istio.io/deny-jwt-gw created
authorizationpolicy.security.istio.io/deny-by-default created
peerauthentication.security.istio.io/default created
requestauthentication.security.istio.io/jwt-authn-httpbin created
requestauthentication.security.istio.io/jwt-authn-gw created
```