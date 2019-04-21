#!/bin/bash

set -eux

RG_NAME=$1
RESOURCE_PREFIX=$2

NODE_RG=MC_${RG_NAME}_ace_cluster_westeurope

RT_ID=$(az resource list --resource-group $NODE_RG --resource-type Microsoft.Network/routeTables --query '[].{ID:id}' -o tsv)
RT_NAME=$(az resource list --resource-group $NODE_RG --resource-type Microsoft.Network/routeTables --query '[].{Name:name}' -o tsv)
NODE_NSG=$(az network nsg list -g ${NODE_RG} --query "[].id | [0]" -o tsv)

# jq -n --arg id "$ID" '{"id":$id}'

# This AKS RT forces traffic to flow through the AZ FW
#az network route-table route create -g $NODE_RG --route-table-name $RT_NAME --name default-hub --next-hop-type VirtualAppliance --address-prefix 0.0.0.0/0 --next-hop-ip-address 10.201.0.4

# Temp fix for the bug with byo vnet to aks
az network vnet subnet update -n ${RESOURCE_PREFIX}-subnet -g $RG_NAME --vnet-name ${RESOURCE_PREFIX}-net --route-table ${RT_ID} --network-security-group $NODE_NSG
