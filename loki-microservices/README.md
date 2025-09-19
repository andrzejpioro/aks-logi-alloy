# Loki Multi-Tenant Monitoring Stack on Azure Kubernetes Service

[![Terraform](https://img.shields.io/badge/Terraform-1.0+-blue.svg)](https://terraform.io)
[![Azure](https://img.shields.io/badge/Azure-AKS-blue.svg)](https://azure.microsoft.com/services/kubernetes-service/)
[![Loki](https://img.shields.io/badge/Loki-Latest-orange.svg)](https://grafana.com/oss/loki/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A production-ready, multi-tenant logging solution built with Grafana Loki, deployed on Azure Kubernetes Service (AKS) using Terraform. Features automatic log collection with Grafana Alloy, secure Azure storage integration, and workload identity authentication.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Azure Subscription                       │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                    Resource Group                            │ │
│  │                                                             │ │
│  │  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │ │
│  │  │     AKS      │    │   Storage    │    │   Azure AD   │  │ │
│  │  │   Cluster    │◄──►│   Account    │    │     App      │  │ │
│  │  │              │    │              │    │              │  │ │
│  │  │ ┌──────────┐ │    │ ┌──────────┐ │    │ ┌──────────┐ │  │ │
│  │  │ │   Loki   │ │    │ │  Chunks  │ │    │ │Workload  │ │  │ │
│  │  │ │ Gateway  │ │    │ │Container │ │    │ │Identity  │ │  │ │
│  │  │ └──────────┘ │    │ └──────────┘ │    │ └──────────┘ │  │ │
│  │  │ ┌──────────┐ │    │ ┌──────────┐ │    └──────────────┘  │ │
│  │  │ │  Alloy   │ │    │ │  Ruler   │ │                      │ │
│  │  │ │DaemonSet │ │    │ │Container │ │                      │ │
│  │  │ └──────────┘ │    │ └──────────┘ │                      │ │
│  │  │ ┌──────────┐ │    └──────────────┘                      │ │
│  │  │ │   App1   │ │                                          │ │
│  │  │ │Log Gen   │ │    Multi-Tenant Log Flow:                │ │
│  │  │ └──────────┘ │    ┌─────────────────────────────────────┤ │
│  │  └──────────────┘    │ Namespace → Tenant ID → Loki       │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## 🚀 Features

### Core Components
- **🏢 Multi-Tenant Loki**: Distributed deployment with namespace-based tenant isolation
- **🔍 Grafana Alloy**: Efficient log collection across all cluster namespaces  
- **☁️ Azure Storage**: Secure blob storage for logs with lifecycle management
- **🔐 Workload Identity**: Password-less authentication using Azure AD
- **📊 Sample App**: Log generator for testing and demonstration

### Security & Authentication
- **Basic Authentication**: Gateway protection with auto-generated passwords
- **RBAC**: Minimal required permissions for all components
- **TLS**: Encrypted communication and storage
- **Network Security**: Private containers and cluster-internal communication

### Operational Features
- **Configurable Retention**: Automatic log cleanup (default: 28 days)
- **High Availability**: Multi-replica deployment for all components
- **Resource Management**: Optimized memory and CPU allocations
- **Health Monitoring**: Built-in health checks and monitoring endpoints

## 📋 Prerequisites

Before you begin, ensure you have:

- **Azure CLI** installed and authenticated (`az login`)
- **Terraform** >= 1.0 installed
- **kubectl** installed for Kubernetes management
- **SSH key pair** for AKS node access:
  ```bash
  ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa
  ```
- **Azure Subscription** with sufficient permissions for:
  - Resource Group creation
  - AKS cluster deployment
  - Storage Account management
  - Azure AD application registration

## 🎯 Quick Start

### 1. Clone and Setup
```bash
git clone <your-repository>
cd loki-monitoring-terraform
```

### 2. Configure Variables
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your configuration:
```hcl
# Project Configuration
project_name = "loki-monitoring"
environment  = "dev"
location     = "Poland Central"

# AKS Configuration  
node_count = 3
node_vm_size = "Standard_B2s"

# Loki Configuration
loki_username = "admin"
loki_password = ""  # Auto-generated if empty
loki_retention_days = 28
```

### 3. Deploy Infrastructure
```bash
# Initialize Terraform
terraform init

# Review the deployment plan
terraform plan

# Deploy the infrastructure
terraform apply
```

### 4. Configure kubectl
```bash
# Get AKS credentials
az aks get-credentials --resource-group rg-loki-monitoring-dev --name loki-monitoring-aks-dev

# Verify connection
kubectl get nodes
```

### 5. Access Loki
```bash
# Get the auto-generated password
terraform output -raw loki_password

# Port forward to access Loki locally
kubectl port-forward -n loki-monitoring-dev service/loki-gateway 3100:80

# Access Loki at http://localhost:3100
# Username: admin (or your configured username)
# Password: (from terraform output above)
```

## 📁 Project Structure

```
├── main.tf                      # Root module orchestration
├── variables.tf                 # Input variables and validation
├── outputs.tf                   # Project outputs
├── locals.tf                   # Computed values and naming
├── versions.tf                 # Provider requirements
├── terraform.tfvars.example   # Configuration template
├── .gitignore                  # Git exclusions
└── modules/                    # Modular components
    ├── aks/                   # AKS cluster module
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── versions.tf
    ├── storage/               # Azure Storage module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── loki/                  # Loki deployment module
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── versions.tf
    │   ├── helm-values.yaml.tpl
    │   └── identity/          # Azure AD identity sub-module
    │       ├── main.tf
    │       ├── variables.tf
    │       ├── outputs.tf
    │       └── versions.tf
    ├── alloy/                 # Log collection module
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── versions.tf
    │   └── config.river.tpl
    └── log-generator/         # Sample application module
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── versions.tf
```

## ⚙️ Configuration Options

### Core Settings

| Variable | Description | Default | Options |
|----------|-------------|---------|---------|
| `project_name` | Resource name prefix | `"loki-monitoring"` | Any string |
| `environment` | Environment name | `"dev"` | `dev`, `staging`, `prod` |
| `location` | Azure region | `"Poland Central"` | Any Azure region |

### AKS Configuration

| Variable | Description | Default | Recommended |
|----------|-------------|---------|-------------|
| `kubernetes_version` | K8s version | `"1.27"` | Latest stable |
| `node_count` | Node pool size | `3` | 3-5 for production |
| `node_vm_size` | VM size | `"Standard_B2s"` | `Standard_D2s_v3` for prod |

### Loki Scaling

| Component | Default Replicas | Production Recommended |
|-----------|------------------|------------------------|
| Ingester | 3 | 3-5 |
| Querier | 3 | 3-5 |
| Query Frontend | 2 | 2-3 |
| Distributor | 3 | 3-5 |
| Compactor | 1 | 1-2 |

### Multi-Tenant Setup

Configure tenant isolation by customizing `tenant_configs`:
```hcl
tenant_configs = {
  production = {
    namespace = "prod-apps"
    tenant_id = "production"
  }
  development = {
    namespace = "dev-apps"  
    tenant_id = "development"
  }
  monitoring = {
    namespace = "monitoring"
    tenant_id = "platform"
  }
}
```

## 🔧 Usage Examples

### Querying Logs

#### Using curl
```bash
# Query all logs for a specific tenant
curl -u "admin:password" \
  -H "X-Scope-OrgID: app1" \
  "http://localhost:3100/loki/api/v1/query_range?query={namespace=\"app1\"}"

# Query specific application logs
curl -u "admin:password" \
  -H "X-Scope-OrgID: app1" \
  "http://localhost:3100/loki/api/v1/query_range?query={app=\"log-generator\"}"

# Query by log level
curl -u "admin:password" \
  -H "X-Scope-OrgID: app1" \
  "http://localhost:3100/loki/api/v1/query_range?query={namespace=\"app1\"} |= \"ERROR\""
```


### Kubernetes Operations

```bash
# Check Loki pods status
kubectl get pods -n loki-monitoring-dev -l app.kubernetes.io/name=loki

# View Loki logs
kubectl logs -n loki-monitoring-dev deployment/loki-querier

# Check Alloy status
kubectl get pods -n loki-monitoring-dev -l app.kubernetes.io/name=alloy

# View collected logs
kubectl logs -n app1 pod/log-generator

# Scale Loki components
kubectl scale deployment loki-querier --replicas=5 -n loki-monitoring-dev
```

### Troubleshooting Commands

```bash
# Check Loki gateway external IP
kubectl get service loki-gateway -n loki-monitoring-dev

# View Alloy configuration
kubectl get configmap alloy-config -o yaml -n loki-monitoring-dev

# Check workload identity setup
kubectl describe serviceaccount loki-monitoring-loki-sa -n loki-monitoring-dev

# View storage account details
az storage account list --resource-group rg-loki-monitoring-dev

# Check Azure AD application
az ad app list --display-name "loki-loki-monitoring-dev"
```

# Restart Alloy to pick up config changes
kubectl rollout restart daemonset alloy -n loki-monitoring-dev
```

#### Monitor Resource Usage
```bash
# Check storage usage
kubectl top nodes
kubectl top pods -n loki-monitoring-dev

# View storage account metrics in Azure portal
az monitor metrics list --resource <storage-account-id>
```

# Export Kubernetes configs
kubectl get all -n loki-monitoring-dev -o yaml > k8s-backup-$(date +%Y%m%d).yaml
```

### Scaling Operations

#### Scale Loki Components
```hcl
# In terraform.tfvars
loki_replicas = {
  ingester        = 5
  querier         = 5
  query_frontend  = 3
  query_scheduler = 3
  distributor     = 5
  compactor       = 2
  index_gateway   = 3
  ruler           = 2
}
```

Then apply:
```bash
terraform apply
```

## 🔍 Monitoring and Alerting

### Health Checks

#### Loki Health
```bash
# Check Loki ready status
curl http://localhost:3100/ready

# Check Loki metrics
curl http://localhost:3100/metrics

# Check individual component health
kubectl get pods -n loki-monitoring-dev -l app.kubernetes.io/component=querier
```

### Performance Monitoring

#### Key Metrics to Monitor
- **Ingestion Rate**: `loki_ingester_samples_received_total`
- **Query Performance**: `loki_query_duration_seconds`
- **Storage Usage**: Azure Storage metrics
- **Memory Usage**: Pod memory consumption
- **Error Rates**: `loki_request_duration_seconds{status_code!~"2.."}`

#### Grafana Dashboard
Import the official Loki dashboard (ID: 13407) in Grafana:
1. Add Loki as a data source: `http://loki-gateway.loki-monitoring-dev.svc.cluster.local`
2. Import dashboard with ID: 13407
3. Configure alerts for high error rates and storage usage




### Development Guidelines
- Follow Terraform best practices
- Update documentation for new features
- Test changes in development environment
- Ensure backward compatibility
- Add appropriate tags and labels


## 🙏 Acknowledgments

- [Grafana Team](https://grafana.com/) for Loki and Alloy
- [HashiCorp](https://www.hashicorp.com/) for Terraform
- [Microsoft Azure](https://azure.microsoft.com/) for cloud infrastructure
- [Kubernetes Community](https://kubernetes.io/) for container orchestration

---

**⭐ If this project helps you, please consider giving it a star!**

For questions, issues, or contributions, please visit our [GitHub repository](https://github.com/your-org/loki-monitoring-terraform).
