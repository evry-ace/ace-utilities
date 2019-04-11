#!/bin/bash

# Boostraps a SA and so on for later use with terraform init
NAME=$1

[ -z "$NAME" ] && NAME=common

TF_SA_LOCATION=${TF_SA_LOCATION:-westeurope}
TF_SA_NAME=${TF_SA_NAME:-ace${NAME}platformstate}
TF_SA_RG=${TF_SA_RG:-ace-$NAME-state}

az group create -n $TF_SA_RG -l $TF_SA_LOCATION
az storage account create -n $TF_SA_NAME -g $TF_SA_RG
az storage container create -n terraform-state --account-name $TF_SA_NAME

AZURE_STORAGE_KEY=$(az storage account keys list -g $TF_SA_RG -n $TF_SA_NAME --query '[?keyName == `key1`].{value:value}' -o tsv)

echo "Result of TF SA:"
echo "export AZURE_STORAGE_KEY=$AZURE_STORAGE_KEY"
echo "export AZURE_STORAGE_ACCOUNT=$TF_SA_NAME"
