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


# SRE Projects - Deploy REST API & Its Dependent Services Using Helm Charts (Assignment 8)

## Problem Statement / Expectations  
We need to create Helm charts for our REST API and its dependent services. We can use the Kubernetes manifests from the previous milestone as a reference. Moving forward, these Helm charts will be used for deployments.  

## Requirements  
- Docker  
- Kind  
- Kubectl  
- Helm (for installing Vault and ESO)  
- Kubernetes cluster (refer to Assignment 6 for details) and complete the necessary steps to proceed directly with Vault configuration.  

---

## Installation / Quick Start  

### 1) Clone and Navigate:  
```bash
git clone https://github.com/venk404/venk404-Helm-Assignments-k8s.git
cd "Assignment 8"
cd helm/charts 
```

### 2) Setup Helm Releases  
Before installing Vault using Helm, we will create two releases: one for the app, database, and External Secrets Operator charts, and another for the Vault charts. Vault requires specific configurations, such as enabling the password engine and setting up a password for ESO to consume. Due to this setup, we have two separate releases. Let's begin with the Vault release.  

---

## Vault Setup  

### 3) Install the Vault Chart:  
```bash
helm install vault ./Vault/ -n vault --create-namespace
```

### 4) Initialize and Unseal Vault:  
```bash
# Wait for the Vault-0 pod to reach the ready state.

kubectl exec vault-0 -n vault -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json
export VAULT_UNSEAL_KEY=$(jq -r '.unseal_keys_b64[0]' cluster-keys.json)
kubectl exec vault-0 -n vault -- vault operator unseal $VAULT_UNSEAL_KEY
```

### 5) Configure Vault Secrets:  
```bash
# Login to Vault using the root token from cluster-keys.json

kubectl exec -it vault-0 -n vault -- /bin/sh
vault login <token>
vault secrets enable -path=secrets kv-v2
vault kv put secrets/DBSECRETS POSTGRES_PASSWORD=<postgres_password> POSTGRES_DB=<postgres_db> POSTGRES_USER=<postgres_user>
exit
```

### 6) Update the Values File for Vault Authentication:  
Locate the `secret` key in the values file, replace the token with the Base64-encoded value from `cluster-keys.json`, and save the file. Follow the command below:  
```bash
echo -n <encode_token> | base64
cd external-secrets
vi values.yaml
```

---

## Deployments  

### 7) Deploy the External Secrets Operator & CRDS and External-secrets(CR):  
```bash
helm install external-secrets-operator ./External-secrets/external-secrets/ -n external-secrets --create-namespace
# Wait until pods get started
helm install external-secrets-cr ./External-secrets/external-secrets-cr/ -n external-secrets

kubectl get pods -owide -A
```

### 8) Deploy PostgreSQL:  
```bash
helm install postgressql ./Postgressql/ -n student-api --create-namespace
```

### 9) Deploy REST API:  
```bash
helm install restapi ./Restapi/ -n student-api --create-namespace
```

### 10) Check API Documentation:  
```bash
http://127.0.0.1:30007/docs
```

---

## Conclusion  
All expectations were met, though the approach may not have been ideal, but it still works.
