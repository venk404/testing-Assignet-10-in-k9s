# SRE Project - Setting Up an Observability Stack

## Problem Statement
Implementing a comprehensive observability stack to monitor Kubernetes clusters and applications using Prometheus, Loki, Grafana, and various exporters.

## Prerequisites
- Docker
- Kind
- Kubectl
- Helm
- Kubernetes cluster

## Installation Guide

### 1. Clone the Repository
```bash
git clone https://github.com/venk404/Observabilty-Assignment10.git
cd "Assignment 10"
```

### 2. Create Observability Namespace
```bash
kubectl create namespace observability
```

### 3. Install kube-prometheus-stack
```bash
helm install prometheus ./kube-prometheus-stack/ --values ./prometheus.yaml -n observability
```
#### Ensure all pods are in the 'Ready' state before continuing.

### 4. Install Blackbox Exporter
```bash
helm install blackbox-exporter ./prometheus-blackbox-exporter/ --values ./blackbox-exportor.yaml -n observability
```
#### Ensure all pods are in the 'Ready' state before continuing.
### 5. Install Postgres Exporter
```bash
helm install postgres-exportor ./prometheus-postgres-exporter/ --values ./postgres-exportor.yaml -n observability
```

Note: The installation includes external secret templates that create secrets used by the Postgres exporter.

### 6. Deploy PLG Stack (Promtail, Loki, Grafana)
```bash
helm install loki ./loki-stack/ --values './Loki values.yaml' -n observability
```

### 7. Port Forward Services for Local Access

#### Access Prometheus:
```bash
kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n observability
```
Prometheus URL: http://localhost:9090

#### Access Grafana:
```bash
kubectl port-forward svc/loki-grafana 3000:80 -n observability
```
Grafana URL: http://localhost:3000
Default credentials:
- Username: admin
- Password: (Retrieve with command below)
```bash
kubectl get secret loki-grafana -o jsonpath="{.data.admin-password}" -n observability | base64 --decode
```

### 8. Access the Grafana
```
http://127.0.0.1:3000/login
```

## Conclusion
This stack provides complete visibility into system performance and health across your Kubernetes environment.

![Deploy Observailty Stack](https://www.notion.so/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F9ce3a364-243d-4bf8-803e-331bbc517340%2F9c32853f-89c0-424e-8b04-f7bc12c6d12b%2Fobs-k8s-deployment.drawio.png?table=block&id=50b472ac-1b05-4f82-830f-e3bf1efc7719&cache=v2)