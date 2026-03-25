# HashSphere Azure Foundation Automation
# Requires: just, terraform, az cli, docker

set dotenv-load

# Default recipe - show available commands
default:
    @just --list

# Validate environment and dependencies
validate:
    #!/usr/bin/env bash
    echo "Validating environment and dependencies..."
    command -v terraform >/dev/null 2>&1 || { echo "ERROR: terraform not found"; exit 1; }
    command -v az >/dev/null 2>&1 || { echo "ERROR: az cli not found"; exit 1; }
    command -v docker >/dev/null 2>&1 || { echo "ERROR: docker not found"; exit 1; }

    if [ ! -f .env.local ]; then
        echo "ERROR: .env.local not found. Copy from .env.local.example and configure."
        exit 1
    fi

    echo "Testing Azure connectivity..."
    az account show --query name --output tsv || { echo "ERROR: Azure auth failed. Run 'az login'"; exit 1; }

    echo "Validating Terraform configuration..."
    cd terraform && terraform validate

    echo "SUCCESS: Environment validation complete!"

# Bootstrap state backend (run once)
bootstrap-state:
    #!/usr/bin/env bash
    echo "Bootstrapping Terraform state backend..."
    cd terraform && bash init.sh
    echo "State backend ready. Run 'just init' next."

# Initialize Terraform
init:
    cd terraform && terraform init

# Show planned changes
plan:
    cd terraform && terraform plan

# Apply infrastructure
apply:
    cd terraform && terraform apply

# Destroy infrastructure (with confirmation)
destroy:
    #!/usr/bin/env bash
    echo "WARNING: This will destroy ALL infrastructure!"
    read -p "Type 'destroy' to confirm: " confirm
    if [ "$confirm" = "destroy" ]; then
        cd terraform && terraform destroy
    else
        echo "Cancelled"
    fi

# Format Terraform code
fmt:
    cd terraform && terraform fmt -recursive

# Build all container images
build:
    docker build -t ghcr.io/mikestankavich/hsphere-node-simulator:latest containers/node-simulator/
    docker build -t ghcr.io/mikestankavich/hsphere-prometheus:latest containers/prometheus/
    docker build -t ghcr.io/mikestankavich/hsphere-grafana:latest containers/grafana/

# Push all container images to GHCR
push: build
    #!/usr/bin/env bash
    echo "$GHCR_TOKEN" | docker login ghcr.io -u "$GHCR_USERNAME" --password-stdin
    docker push ghcr.io/mikestankavich/hsphere-node-simulator:latest
    docker push ghcr.io/mikestankavich/hsphere-prometheus:latest
    docker push ghcr.io/mikestankavich/hsphere-grafana:latest

# Show infrastructure status
status:
    #!/usr/bin/env bash
    cd terraform
    if terraform show -json > /dev/null 2>&1; then
        echo "Terraform State: Present"
        echo ""
        terraform output 2>/dev/null || echo "(No outputs yet)"
        echo ""
        resource_count=$(terraform state list 2>/dev/null | wc -l)
        echo "Resources: $resource_count"
    else
        echo "Terraform State: Not found"
        echo "Run 'just bootstrap-state && just init && just apply'"
    fi

# Show debug information
debug:
    #!/usr/bin/env bash
    echo "Debug Information"
    echo "================="
    terraform version
    az version --output table
    docker version --format 'Docker {{.Client.Version}}'
    echo ""
    echo "Azure Account: $(az account show --query name --output tsv 2>/dev/null || echo 'not authenticated')"
    echo "Subscription: $(az account show --query id --output tsv 2>/dev/null || echo 'n/a')"
