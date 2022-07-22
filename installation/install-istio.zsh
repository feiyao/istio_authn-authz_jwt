cd "$PWD/installation/tmp"

kubectl wait deployment -n kube-system metrics-server --for condition=Available=True --timeout=90s

echo "-> Download Istio"

curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIO_VERSION sh -
cd "$PWD/istio-$ISTIO_VERSION/"
export PATH=$PWD/bin:$PATH

echo "-> Install Istio"
istioctl install -y -f - <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  namespace: istio-system
  name: $ISTIO_REVISION
spec:
  profile: empty
  hub: docker.io/istio # default
  tag: $ISTIO_VERSION_TAG
  revision: $ISTIO_REVISION

  meshConfig:
    enableAutoMtls: true
    # defaultServiceExportTo: ["."]
    accessLogFile: /dev/stdout
    accessLogFormat: |
      [%START_TIME%] "%REQ(:METHOD)% %REQ(X-ENVOY-ORIGINAL-PATH?:PATH)% %PROTOCOL%" %RESPONSE_CODE% %RESPONSE_FLAGS% %BYTES_RECEIVED% %BYTES_SENT% %DURATION% %RESP(X-ENVOY-UPSTREAM-SERVICE-TIME)% "%REQ(X-FORWARDED-FOR)%" "%REQ(USER-AGENT)%" "requestID=%REQ(X-REQUEST-ID)%" "%REQ(:AUTHORITY)%" "%UPSTREAM_HOST%" "%UPSTREAM_CLUSTER%" "%UPSTREAM_TRANSPORT_FAILURE_REASON%" %REQUESTED_SERVER_NAME% %ROUTE_NAME% traceID=%REQ(X-B3-TRACEID)% attempts=%REQ(X-ENVOY-ATTEMPT-COUNT)%
    enableTracing: true
          
    defaultConfig:
      holdApplicationUntilProxyStarts: true
      terminationDrainDuration: 60s
      proxyMetadata:
        ISTIO_META_DNS_CAPTURE: "true"
        ISTIO_META_DNS_AUTO_ALLOCATE: "true"
        SECRET_TTL: "6h0m0s" # default 24h0m0s
        SECRET_GRACE_PERIOD_RATIO: "0.5" # default 0.5
      tracing:
        sampling: 100
        max_path_tag_length: 256
        zipkin:
          address: otel-collector.monitoring.svc:9411

    localityLbSetting:
      enabled: false

    outboundTrafficPolicy:
      mode: REGISTRY_ONLY

  components:
    base:
      enabled: true
    pilot:
      enabled: true
      k8s:
        env:
        - name: PILOT_SCOPE_GATEWAY_TO_NAMESPACE
          value: "true"
        - name: PILOT_FILTER_GATEWAY_CLUSTER_CONFIG
          value: "true"
        - name: PILOT_ENABLE_PROTOCOL_SNIFFING_FOR_OUTBOUND
          value: "false"
        - name: PILOT_ENABLE_PROTOCOL_SNIFFING_FOR_INBOUND
          value: "false"
        replicaCount: 1
        resources:
          requests:
            cpu: 200m
            memory: 200Mi
        strategy:
          rollingUpdate:
            maxSurge: 100%
            maxUnavailable: 25%
        hpaSpec:
          maxReplicas: 5
          minReplicas: 1
          scaleTargetRef:
            apiVersion: apps/v1
            kind: Deployment
            name: istiod-ISTIO_REVISION
          metrics:
            - resource:
                name: cpu
                targetAverageUtilization: 60
              type: Resource
    cni:
      enabled: false
EOF

echo "-> Wait for Istio to be ready ..."