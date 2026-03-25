#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="hashsphere-tfstate"
STORAGE_ACCOUNT="hashspheretfstate"
CONTAINER_NAME="tfstate"
LOCATION="southcentralus"

echo "Creating Terraform state backend..."

az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION"

az storage account create \
    --name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --encryption-services blob \
    --kind StorageV2 \
    --access-tier Hot \
    --allow-blob-public-access false \
    --enable-blob-versioning true

az storage container create \
    --account-name "$STORAGE_ACCOUNT" \
    --name "$CONTAINER_NAME" \
    --auth-mode login

echo "State backend ready: $STORAGE_ACCOUNT/$CONTAINER_NAME"
