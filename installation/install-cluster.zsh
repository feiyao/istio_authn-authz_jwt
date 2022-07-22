k3d cluster create istio --k3s-arg "--disable=traefik@server:0" \
    --port 8080:80@loadbalancer \
    --port 8443:443@loadbalancer