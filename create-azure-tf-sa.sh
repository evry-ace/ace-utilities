#!/bin/bash

# Boostraps a SA and so on for later use with terraform init
NAME=$1

[ -z "$NAME" ] && NAME=common

TF_SA_LOCATION=${TF_SA_LOCATION:-westeurope}
TF_SA_NAME=${TF_SA_NAME:-${NAME}state}
TF_SA_RG=${TF_SA_RG:-ace-$NAME-state}

HAS="$(echo $TF_SA_NAME | wc -c)"
SHOULD=24
NEED=$(($SHOULD - $HAS))
RAND=$(< /dev/urandom tr -dc A-Za-z0-9 | head -c40 | tr [:upper:] [:lower:])

TF_SA_NAME=${TF_SA_NAME}$(echo $RAND | cut -c 1-${NEED})

az group create -n $TF_SA_RG -l $TF_SA_LOCATION
az storage account create -n $TF_SA_NAME -g $TF_SA_RG
az storage container create -n terraform-state --account-name $TF_SA_NAME

AZURE_STORAGE_KEY=$(az storage account keys list -g $TF_SA_RG -n $TF_SA_NAME --query '[?keyName == `key1`].{value:value}' -o tsv)

echo "Result of TF SA:"
echo "export AZURE_STORAGE_KEY=$AZURE_STORAGE_KEY"
echo "export AZURE_STORAGE_ACCOUNT=$TF_SA_NAME"
