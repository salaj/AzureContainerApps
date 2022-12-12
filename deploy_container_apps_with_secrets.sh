#!/bin/bash

# az provider register --namespace Microsoft.App
# az provider register --namespace Microsoft.OperationalInsights


RESOURCE_GROUP="jksa-container-apps"
LOCATION="westeurope"
CONTAINERAPPS_ENVIRONMENT="voting-environment"
LAW_NAME="jksacontainerappseuwlaw"
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION 
az monitor log-analytics workspace create \
  --resource-group $RESOURCE_GROUP \
  --workspace-name $LAW_NAME
LAW_ID=`az monitor log-analytics workspace show \
  --query customerId \
  -g $RESOURCE_GROUP \
  -n $LAW_NAME \
  | xargs`
LAW_KEY=`az monitor log-analytics workspace get-shared-keys \
          --query primarySharedKey \
          -g $RESOURCE_GROUP \
          -n $LAW_NAME \
          | xargs`
az containerapp env create \
  --name $CONTAINERAPPS_ENVIRONMENT \
  --resource-group $RESOURCE_GROUP \
  --logs-workspace-id 02c6b23c-fd2c-4c20-903e-ff06b0c84f15 \
  --logs-workspace-key $LAW_KEY \
  --location $LOCATION
CONTAINER_VOTING_API_IMAGE_NAME="unicornnonproduse2acr.azurecr.io/voting/voting-api/jksa:latest"
CONTAINER_VOTING_APP_IMAGE_NAME="unicornnonproduse2acr.azurecr.io/voting/voting-app/jksa:latest"
REGISTRY_SERVER="unicornnonproduse2acr.azurecr.io"
REGISTRY_USERNAME="unicornnonproduse2acr"
REGISTRY_PASSWORD="JB8/47pkflg4v15aZDPgVauho6se1Md8"
CONTAINER_NAME_VOTING_APP="voting-app"
CONTAINER_NAME_VOTING_API="voting-api"
APPINSIGHTS_INSTRUMENTATIONKEY="6b73010d-7ee5-4691-8b3c-bc26b1b6682e"
# we need to provide LAW, if not it will create new one with each deployment
az containerapp create \
  --name $CONTAINER_NAME_VOTING_APP \
  --resource-group $RESOURCE_GROUP \
  --image $CONTAINER_VOTING_APP_IMAGE_NAME \
  --environment $CONTAINERAPPS_ENVIRONMENT \
  --registry-server $REGISTRY_SERVER \
  --registry-username $REGISTRY_USERNAME \
  --registry-password $REGISTRY_PASSWORD \
  --env-vars APPINSIGHTS_INSTRUMENTATIONKEY=$APPINSIGHTS_INSTRUMENTATIONKEY \
  --target-port 80 \
  --ingress 'external' \
  --dapr-app-id voting-app-dapr \
  --dapr-app-port 80 \
  --enable-dapr

# for now there is an open issue regarding the probes which fail the revision deployment
# https://github.com/microsoft/azure-container-apps/issues/448
az containerapp create \
  --name $CONTAINER_NAME_VOTING_API \
  --resource-group $RESOURCE_GROUP \
  --user-assigned /subscriptions/ec0308fb-8d6e-497a-9dd6-99c7d9ab7962/resourcegroups/unicorn-nonprod-use2-identity-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/voting-nonprod-dev \
  --image $CONTAINER_VOTING_API_IMAGE_NAME \
  --environment $CONTAINERAPPS_ENVIRONMENT \
  --registry-server $REGISTRY_SERVER \
  --registry-username $REGISTRY_USERNAME \
  --registry-password $REGISTRY_PASSWORD \
  --env-vars APPINSIGHTS_INSTRUMENTATIONKEY=$APPINSIGHTS_INSTRUMENTATIONKEY \
  CosmosDb__DatabaseName="voting" \
  CosmosDb__ContainerNamePrefix="dev-" \
  CosmosDb__Account="unicorn-nonprod-use2-cosmosdb" \
  CosmosDb__CollectionId="votes" \
  --target-port 80 \
  --ingress 'internal' \
  --dapr-app-id voting-api-dapr \
  --dapr-app-port 80 \
  --enable-dapr true
