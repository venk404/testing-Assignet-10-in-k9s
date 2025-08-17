#!/bin/bash

set -euo pipefail

NAMESPACE="observability"

# Helper function to wait for all pods to be ready in a namespace
wait_for_pods_ready() {
  echo "Waiting for all pods in namespace '$NAMESPACE' to be ready..."
  while true; do
    NOT_READY=$(kubectl get pods -n "$NAMESPACE" --no-headers | \
      awk '
        $3 != "Completed" && $3 != "Running" { exit 1 }
        {
          split($2, a, "/")
          if (a[1] != a[2]) exit 1
        }
      ' && echo "ready" || echo "not_ready")

    if [[ "$NOT_READY" == "ready" ]]; then
      echo "✅ All pods in '$NAMESPACE' are ready."
      break
    fi

    echo "⏳ Pods not ready yet. Checking again in 5 seconds..."
    sleep 5
  done
}
# 2. Create Observability Namespace
echo "Creating namespace: $NAMESPACE"
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# 3. Install kube-prometheus-stack
echo "Installing kube-prometheus-stack..."
helm install prometheus ./kube-prometheus-stack/ --values ./prometheus.yaml -n "$NAMESPACE"
wait_for_pods_ready

# 4. Install Blackbox Exporter
echo "Installing Blackbox Exporter..."
helm install blackbox-exporter ./prometheus-blackbox-exporter/ --values ./blackbox-exportor.yaml -n "$NAMESPACE"
wait_for_pods_ready

# 5. Install Postgres Exporter
echo "Installing Postgres Exporter..."
helm install postgres-exportor ./prometheus-postgres-exporter/ --values ./postgres-exportor.yaml -n "$NAMESPACE"
wait_for_pods_ready

# 6. Deploy PLG Stack (Promtail, Loki, Grafana)
echo "Installing Loki Stack..."
helm install loki ./loki-stack/ --values './Loki values.yaml' -n "$NAMESPACE"
wait_for_pods_ready

echo "✅ All components installedsuccessfully in '$NAMESPACE'."
