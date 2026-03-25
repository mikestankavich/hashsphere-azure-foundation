resource "azurerm_container_app" "prometheus" {
  name                         = "hsphere-prometheus"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  ingress {
    allow_insecure_connections = true
    external_enabled           = false
    target_port                = 9090
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    min_replicas = 1

    container {
      name   = "prometheus"
      image  = var.prometheus_image
      cpu    = 0.5
      memory = "1.0Gi"

      liveness_probe {
        transport = "HTTP"
        path      = "/-/healthy"
        port      = 9090
      }
      readiness_probe {
        transport = "HTTP"
        path      = "/-/ready"
        port      = 9090
      }
    }
  }

  tags = local.common_tags
}

resource "azurerm_container_app" "grafana" {
  name                         = "hsphere-grafana"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 3000
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    min_replicas = 1

    container {
      name   = "grafana"
      image  = var.grafana_image
      cpu    = 0.25
      memory = "0.5Gi"

      liveness_probe {
        transport = "HTTP"
        path      = "/api/health"
        port      = 3000
      }
      readiness_probe {
        transport = "HTTP"
        path      = "/api/health"
        port      = 3000
      }
    }
  }

  tags = local.common_tags
}
