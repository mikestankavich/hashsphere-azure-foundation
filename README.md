# HashSphere Azure Foundation

Infrastructure-as-code for deploying a simulated Hedera Hashgraph network on Azure Container Apps, with Prometheus + Grafana observability built in.

## Architecture

```
Internet
  |
  v
[Grafana :3000]  <-- external ingress (HTTPS)
  |
  v
[Prometheus :9090]  <-- internal, scrapes nodes every 15s
  |
  +---> [Consensus Node :8080]  <-- simulated HCS
  +---> [Mirror Node :8080]     <-- simulated mirror
```

All containers run in an Azure Container Apps environment on a delegated VNet subnet (`10.0.0.0/23`). Internal services communicate over ACA's built-in DNS.

## Components

| Component | Image | Description |
|-----------|-------|-------------|
| `hsphere-consensus` | `ghcr.io/mikestankavich/hsphere-node-simulator` | Go service simulating Hedera consensus rounds with Prometheus metrics |
| `hsphere-mirror` | `ghcr.io/mikestankavich/hsphere-node-simulator` | Same image in mirror role, simulating transaction indexing |
| `hsphere-prometheus` | `ghcr.io/mikestankavich/hsphere-prometheus` | Prometheus with baked-in scrape config for both nodes |
| `hsphere-grafana` | `ghcr.io/mikestankavich/hsphere-grafana` | Grafana with provisioned Prometheus datasource and dashboard |

### Node Simulator Metrics

The Go node simulator exposes `/metrics` on port 8080 with:

- `hashsphere_consensus_time_seconds` - time to consensus per round (histogram)
- `hashsphere_transactions_total` - total transactions by service type
- `hashsphere_transactions_per_second` - current TPS gauge
- `hashsphere_round_number` - current consensus round
- `hashsphere_active_accounts` / `hashsphere_peer_count` / `hashsphere_node_status`
- Health endpoint at `/healthz`

## Prerequisites

- [Terraform](https://www.terraform.io/) >= 1.5
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/) (`az login` authenticated)
- [Docker](https://www.docker.com/) (for building images)
- [just](https://just.systems/) (command runner)
- [direnv](https://direnv.net/) (optional, auto-loads `.env.local`)

## Quick Start

```bash
# 1. Configure environment
cp .env.local.example .env.local
# Edit .env.local with your Azure subscription ID and tenant ID

# 2. Authenticate
az login

# 3. Bootstrap Terraform state backend (one-time)
just bootstrap-state

# 4. Initialize and deploy
just init
just plan   # review changes
just apply  # deploy infrastructure
```

## Available Commands

Run `just` to see all commands:

| Command | Description |
|---------|-------------|
| `just validate` | Check dependencies and Azure connectivity |
| `just bootstrap-state` | Create Azure Storage for Terraform state (run once) |
| `just init` | Initialize Terraform |
| `just plan` | Preview infrastructure changes |
| `just apply` | Deploy infrastructure |
| `just destroy` | Tear down all infrastructure |
| `just build` | Build all container images locally |
| `just push` | Build and push images to GHCR |
| `just status` | Show current infrastructure state |
| `just debug` | Print tool versions and Azure account info |
| `just fmt` | Format Terraform files |

## Infrastructure

Managed by Terraform (`terraform/`):

- **Resource Group** with consistent naming (`rg-hashsphere-dev-ussc`)
- **VNet** (`10.0.0.0/16`) with ACA-delegated subnet and NSG
- **Container Apps Environment** with Log Analytics workspace
- **4 Container Apps** (consensus, mirror, prometheus, grafana)
- **State backend** in Azure Blob Storage

Provider: `azurerm ~> 4.0` with remote state in `hashsphere-tfstate` storage account.

## Project Structure

```
.
├── containers/
│   ├── node-simulator/    # Go simulated Hedera node
│   ├── prometheus/        # Custom Prometheus with scrape config
│   └── grafana/           # Custom Grafana with provisioned dashboards
├── terraform/
│   ├── provider.tf        # Azure provider + state backend
│   ├── main.tf            # Resource group + naming
│   ├── variables.tf       # Input variables
│   ├── network.tf         # VNet, subnet, NSG
│   ├── container-app.tf   # ACA environment + Log Analytics
│   ├── hedera-node.tf     # Consensus + mirror container apps
│   ├── observability.tf   # Prometheus + Grafana container apps
│   ├── outputs.tf         # Grafana URL, resource names
│   └── init.sh            # State backend bootstrap script
├── justfile               # Task runner commands
├── .env.local.example     # Environment template
└── .envrc                 # direnv auto-loader
```

## License

[MIT](LICENSE)
