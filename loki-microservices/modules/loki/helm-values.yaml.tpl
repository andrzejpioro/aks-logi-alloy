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

deploymentMode: Distributed

# Component replicas
ingester:
  replicas: ${replicas.ingester}
  zoneAwareReplication:
    enabled: false

querier:
  replicas: ${replicas.querier}
  maxUnavailable: 2

queryFrontend:
  replicas: ${replicas.query_frontend}
  maxUnavailable: 1

queryScheduler:
  replicas: ${replicas.query_scheduler}

distributor:
  replicas: ${replicas.distributor}
  maxUnavailable: 2

compactor:
  replicas: ${replicas.compactor}

indexGateway:
  replicas: ${replicas.index_gateway}
  maxUnavailable: 1

ruler:
  replicas: ${replicas.ruler}
  maxUnavailable: 1

gateway:
  service:
    type: LoadBalancer
  basicAuth:
    enabled: true
    existingSecret: ${basic_auth_secret}

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

# Memcached configuration with customizable memory
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

# Disable unused components
minio:
  enabled: false

backend:
  replicas: 0

read:
  replicas: 0

write:
  replicas: 0

singleBinary:
  replicas: 0