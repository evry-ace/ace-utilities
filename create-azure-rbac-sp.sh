#!/bin/bash

NAME=$1

SERVER_APP=ace-${NAME}-server
SERVER_SECRET=${AKS_SP_SECRET}

CLIENT_APP=ace-${NAME}-client

[[ -z "$SERVER_SECRET" ]] && {
    SERVER_SECRET="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c40)"
}

# Create AKS AAD sever app
SERVER_ID=$(az ad app create --display-name $SERVER_APP --identifier-uris http://$SERVER_APP --password $SERVER_SECRET --required-resource-accesses azure-server-manifest.json --query appId -o tsv)
az ad app update --id $SERVER_ID --set groupMembershipClaims="All"

# Create AKS AAD client app
CLIENT_PERMS=$(cat <<EOF
[{"resourceAccess": [{"id": "318f4279-a6d6-497a-8c69-a793bda0d54f","type": "Scope"}],"resourceAppId": "$SERVER_ID"}]
EOF
)
CLIENT_ID=$(az ad app create --display-name $CLIENT_APP --native-app --required-resource-accesses "$CLIENT_PERMS" --query appId -o tsv)

# Get tenant ID
TENANT_ID=$(az account list --query '[?isDefault].{tenantId:tenantId}' -o tsv)

echo "export TF_VAR_aks_rbac_server_app_id=$SERVER_ID"
echo "export TF_VAR_aks_rbac_client_app_id=$CLIENT_ID"
echo "export TF_VAR_aks_rbac_server_app_secret=$SERVER_SECRET"
echo "export TF_VAR_tenant_id$TENANT_ID"
