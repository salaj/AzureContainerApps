#!/bin/bash

# az provider register --namespace Microsoft.App
# az provider register --namespace Microsoft.OperationalInsights


RESOURCE_GROUP="jksa-container-apps"
LOCATION="westeurope"
CONTAINERAPPS_ENVIRONMENT="my-environment"
LAW_ID="a47af782-2f8f-4366-b789-6d60f2edb245"

az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION 

az containerapp env create \
  --name $CONTAINERAPPS_ENVIRONMENT \
  --resource-group $RESOURCE_GROUP \
  --logs-workspace-id $LAW_ID \
  --location $LOCATION

CONTAINER_VOTING_API_IMAGE_NAME="unicornnonproduse2acr.azurecr.io/voting/voting-api/dev:v164706"
CONTAINER_VOTING_APP_IMAGE_NAME="unicornnonproduse2acr.azurecr.io/voting/voting-app/jksa:latest"
REGISTRY_SERVER="unicornnonproduse2acr.azurecr.io"
REGISTRY_USERNAME="unicornnonproduse2acr"
REGISTRY_PASSWORD="JB8/47pkflg4v15aZDPgVauho6se1Md8"

CONTAINER_NAME_VOTING_APP="voting-app"
CONTAINER_NAME_VOTING_API="voting-api"

az containerapp create \
  --name $CONTAINER_VOTING_APP_IMAGE_NAME \
  --resource-group $RESOURCE_GROUP \
  --system-assigned \
  --image $CONTAINER_IMAGE_NAME \
  --environment $CONTAINERAPPS_ENVIRONMENT \
  --registry-server $REGISTRY_SERVER \
  --registry-username $REGISTRY_USERNAME \
  --registry-password $REGISTRY_PASSWORD \
  --target-port 80 \
  --ingress 'external' \
  --query properties.configuration.ingress.fqdn

# To investigate deployment errors we need to audit table ContainerAppConsoleLogs_CL

# In order to add mount volumes we need to manually modify manifest
# https://docs.microsoft.com/en-us/azure/container-apps/storage-mounts?pivots=aca-cli#configuration

# We cannot create configmaps https://samcogan.com/wth-are-azure-container-apps/

# az containerapp show \
#   -n $CONTAINER_NAME \
#   -g $RESOURCE_GROUP -o yaml > app.yaml