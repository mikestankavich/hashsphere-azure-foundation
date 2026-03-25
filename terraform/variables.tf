variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "region" {
  description = "Azure region for all resources"
  type        = string
  default     = "southcentralus"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project" {
  description = "Project name used in resource naming"
  type        = string
  default     = "hashsphere"
}

variable "location" {
  description = "Location short name for resource naming"
  type        = string
  default     = "ussc"
}

variable "node_image" {
  description = "Container image for simulated Hedera node"
  type        = string
  default     = "ghcr.io/mikestankavich/hsphere-node-simulator:latest"
}

variable "prometheus_image" {
  description = "Container image for Prometheus with baked-in config"
  type        = string
  default     = "ghcr.io/mikestankavich/hsphere-prometheus:latest"
}

variable "grafana_image" {
  description = "Container image for Grafana with baked-in provisioning"
  type        = string
  default     = "ghcr.io/mikestankavich/hsphere-grafana:latest"
}
