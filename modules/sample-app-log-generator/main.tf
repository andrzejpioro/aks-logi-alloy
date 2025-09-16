# Create namespace for the log generator
resource "kubernetes_namespace" "log_generator" {
  metadata {
    name = var.namespace
    labels = {
      app = var.app_name
    }
  }
}

# Create a simple pod that generates logs
resource "kubernetes_pod" "log_generator" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.log_generator.metadata[0].name
    labels = {
      app = var.app_name
    }
  }

  spec {
    container {
      name    = var.app_name
      image   = "busybox:latest"
      command = ["/bin/sh"]
      args = [
        "-c",
        <<-EOT
        while true; do
          timestamp=$(date '+%Y-%m-%d %H:%M:%S')
          level=$(echo "INFO WARN ERROR DEBUG" | tr ' ' '\n' | shuf -n1)
          case $((RANDOM % 10)) in
            0) message="User login successful" ;;
            1) message="Database connection established" ;;
            2) message="API request processed" ;;
            3) message="Cache miss occurred" ;;
            4) message="File uploaded successfully" ;;
            5) message="Authentication failed" ;;
            6) message="Memory usage high" ;;
            7) message="Service started" ;;
            8) message="Configuration loaded" ;;
            *) message="Backup completed" ;;
          esac
          request_id=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
          echo "[$timestamp] [$level] [RequestID: $request_id] $message"
          sleep 10
        done
        EOT
      ]

      resources {
        requests = {
          memory = "64Mi"
          cpu    = "50m"
        }
        limits = {
          memory = "128Mi"
          cpu    = "100m"
        }
      }
    }

    restart_policy = "Always"
  }
}