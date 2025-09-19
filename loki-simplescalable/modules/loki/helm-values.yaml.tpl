loki:
  podLabels:
    "azure.workload.identity/use": "true"
  
  schemaConfig:
    configs:
      - from: "2024-04-01"
        store: tsdb
        object_store: azure
        schema: v13
        index:
          prefix: loki_index_
          period: 24h

  storage_config:
    azure:
      account_name: ${storage_account_name}
      container_name: ${chunks_container}
      use_federated_token: true

  ingester:
    chunk_encoding: snappy

  pattern_ingester:
    enabled: true

  limits_config:
    allow_structured_metadata: true
    volume_enabled: true
    retention_period: "${retention_hours}h"

  compactor:
    retention_enabled: true
    delete_request_store: azure

  ruler:
    enable_api: true
    storage:
      type: azure
      azure:
        account_name: ${storage_account_name}
        container_name: ${ruler_container}
        use_federated_token: true
    alertmanager_url: "http://prom:9093"

  querier:
    max_concurrent: 4

  storage:
    type: azure
    bucketNames:
      chunks: ${chunks_container}
      ruler: ${ruler_container}
    azure:
      accountName: ${storage_account_name}
      useFederatedToken: true

serviceAccount:
  name: ${service_account_name}
  annotations:
    "azure.workload.identity/client-id": ${app_client_id}
  labels:
    "azure.workload.identity/use": "true"

# Simple Scalable Architecture Configuration
deploymentMode: SimpleScalable

# Backend component (compactor, ruler, scheduler, index-gateway)
backend:
  replicas: ${replicas.backend}
  persistence:
    enabled: true
    size: 10Gi

# Read component (query-frontend + querier)
read:
  replicas: ${replicas.read}
  autoscaling:
    enabled: true
    minReplicas: ${replicas.read}
    maxReplicas: ${replicas.read * 2}
    targetCPUUtilizationPercentage: 70

# Write component (distributor + ingester)
write:
  replicas: ${replicas.write}
  persistence:
    enabled: true
    size: 150Gi
  autoscaling:
    enabled: true
    minReplicas: ${replicas.write}
    maxReplicas: ${replicas.write * 2}
    targetCPUUtilizationPercentage: 70

# Gateway configuration
gateway:
  replicas: ${replicas.gateway}
  service:
    type: LoadBalancer
  basicAuth:
    enabled: true
    existingSecret: ${basic_auth_secret}
  autoscaling:
    enabled: true
    minReplicas: ${replicas.gateway}
    maxReplicas: ${replicas.gateway * 2}
    targetCPUUtilizationPercentage: 70

# Canary configuration
lokiCanary:
  extraArgs:
    - "-pass=$(LOKI_PASS)"
    - "-user=$(LOKI_USER)"
  extraEnv:
    - name: LOKI_PASS
      valueFrom:
        secretKeyRef:
          name: ${canary_auth_secret}
          key: password
    - name: LOKI_USER
      valueFrom:
        secretKeyRef:
          name: ${canary_auth_secret}
          key: username

# Memcached configuration
memcached:
  enabled: true
  allocatedMemory: ${memcached_memory.main}

memcachedChunks:
  enabled: true
  allocatedMemory: ${memcached_memory.chunks}
  extraArgs:
    - "-I"
    - "2m"

memcachedFrontend:
  enabled: true
  allocatedMemory: ${memcached_memory.frontend}

memcachedIndexQueries:
  enabled: true
  allocatedMemory: ${memcached_memory.index_queries}

memcachedIndexWrites:
  enabled: true
  allocatedMemory: ${memcached_memory.index_writes}

# Disable unused components for Simple Scalable mode
minio:
  enabled: false

# Disable individual distributed components since we're using Simple Scalable
singleBinary:
  replicas: 0
ingester:
  replicas: 0
querier:
  replicas: 0
queryFrontend:
  replicas: 0
queryScheduler:
  replicas: 0
distributor:
  replicas: 0
compactor:
  replicas: 0
indexGateway:
  replicas: 0
ruler:
  replicas: 0