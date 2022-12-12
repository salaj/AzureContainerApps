#!/bin/bash

# az provider register --namespace Microsoft.App
# az provider register --namespace Microsoft.OperationalInsights


RESOURCE_GROUP="jksa-container-apps"
LOCATION="westeurope"
CONTAINERAPPS_ENVIRONMENT="my-environment"
LAW_NAME="workspace-jksacontainerappsoytV"
LAW_ID="de6981c6-35cf-4ead-b86a-b5017924f74a"

az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION 

LAW_KEY=`az monitor log-analytics workspace get-shared-keys \
          -n $LAW_NAME \
          -g $RESOURCE_GROUP \
          | jq -r .primarySharedKey`

echo LAW_KEY: $LAW_KEY

az containerapp env create \
  --name $CONTAINERAPPS_ENVIRONMENT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION 

CONTAINER_IMAGE_NAME="unicornnonproduse2acr.azurecr.io/voting/voting-api/dev:v164706"
REGISTRY_SERVER="unicornnonproduse2acr.azurecr.io"
REGISTRY_USERNAME="unicornnonproduse2acr"
REGISTRY_PASSWORD="JB8/47pkflg4v15aZDPgVauho6se1Md8"

CONTAINER_NAME="my-container-app"

az containerapp create \
  --name $CONTAINER_NAME \
  --resource-group $RESOURCE_GROUP \
  --yaml "app.yaml"
