cd "$PWD/installation/tmp"

cd "$PWD/istio-$ISTIO_VERSION/"
export PATH=$PWD/bin:$PATH

echo "-> Create istio-gateway namespace"
kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: istio-gateway
EOF

echo "-> Install Istio IngressGateway"

istioctl install -y -f - <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: ingress-gateway-$ISTIO_REVISION
  namespace: istio-gateway
spec:
  profile: empty
  hub: docker.io/istio
  tag: $ISTIO_VERSION_TAG
  revision: $ISTIO_REVISION
  components:
    ingressGateways:
    - name: istio-ingressgateway-$ISTIO_REVISION
      namespace: istio-gateway
      enabled: true
      label:
        istio: ingressgateway
        version: $ISTIO_VERSION
        app: istio-ingressgateway
      k8s:
        resources:
          requests:
            cpu: 100m
            memory: 64Mi
#    egressGateways:
#      - name: istio-egressgateway-$ISTIO_REVISION
#        namespace: istio-gateway
#        enabled: true
#        label:
#          istio: egressgateway
#          version: $ISTIO_VERSION
#          app: istio-egressgateway
#        k8s:
#          resources:
#            requests:
#              cpu: 100m
#              memory: 64Mi
  values:
    gateways:
      istio-ingressgateway:
        injectionTemplate: gateway
        autoscaleEnabled: false
#      istio-egressgateway:
#        injectionTemplate: gateway
#        autoscaleEnabled: false
EOF

echo "-> Wait for Istio IngressGateway to be ready ..."