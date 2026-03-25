resource "azurerm_container_app" "consensus" {
  name                         = "hsphere-consensus"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  ingress {
    allow_insecure_connections = true
    external_enabled           = false
    target_port                = 8080
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    min_replicas = 1

    container {
      name   = "node-simulator"
      image  = var.node_image
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "HSPHERE_NODE_ROLE"
        value = "consensus"
      }
      env {
        name  = "HSPHERE_NODE_ID"
        value = "consensus-0"
      }

      liveness_probe {
        transport = "HTTP"
        path      = "/healthz"
        port      = 8080
      }

      readiness_probe {
        transport = "HTTP"
        path      = "/healthz"
        port      = 8080
      }
    }
  }

  tags = local.common_tags
}

resource "azurerm_container_app" "mirror" {
  name                         = "hsphere-mirror"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  ingress {
    allow_insecure_connections = true
    external_enabled           = false
    target_port                = 8080
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    min_replicas = 1

    container {
      name   = "node-simulator"
      image  = var.node_image
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "HSPHERE_NODE_ROLE"
        value = "mirror"
      }
      env {
        name  = "HSPHERE_NODE_ID"
        value = "mirror-0"
      }

      liveness_probe {
        transport = "HTTP"
        path      = "/healthz"
        port      = 8080
      }

      readiness_probe {
        transport = "HTTP"
        path      = "/healthz"
        port      = 8080
      }
    }
  }

  tags = local.common_tags
}
