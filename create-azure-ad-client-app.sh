#!/bin/bash
set -e

# load environment variables
DETECTED_TENANT_ID=$(az account show --query tenantId)

echo "We have found the current tenant automatically $DETECTED_TENANT_ID, continue? y/n"
read tenant_ok
[ $tenant_ok != 'y' ] && exit 0

export RBAC_CLIENT_APP_NAME="$1"
export RBAC_CLIENT_APP_URL="http://$RBAC_CLIENT_APP_NAME"

export RBAC_SERVER_APP_ID="$2"
export RBAC_SERVER_APP_OAUTH2PERMISSIONS_ID="$3"

# generate manifest for client application
cat > ./manifest-client.json << EOF
[
    {
      "resourceAppId": "${RBAC_SERVER_APP_ID}",
      "resourceAccess": [
        {
          "id": "${RBAC_SERVER_APP_OAUTH2PERMISSIONS_ID}",
          "type": "Scope"
        }
      ]
    }
]
EOF

# create client application
az ad app create --display-name ${RBAC_CLIENT_APP_NAME} \
    --native-app \
    --reply-urls "${RBAC_CLIENT_APP_URL}" \
    --homepage "${RBAC_CLIENT_APP_URL}" \
    --required-resource-accesses @manifest-client.json

RBAC_CLIENT_APP_ID=$(az ad app list --display-name ${RBAC_CLIENT_APP_NAME} --query [].appId -o tsv)

# create service principal for the client application
az ad sp create --id ${RBAC_CLIENT_APP_ID}

# remove manifest-client.json
rm ./manifest-client.json

# grant permissions to server application
RBAC_CLIENT_APP_RESOURCES_API_IDS=$(az ad app permission list --id $RBAC_CLIENT_APP_ID --query [].resourceAppId --out tsv | xargs echo)
for RESOURCE_API_ID in $RBAC_CLIENT_APP_RESOURCES_API_IDS;
do
  az ad app permission grant --api $RESOURCE_API_ID --id $RBAC_CLIENT_APP_ID
done

# Output terraform variables
echo "
export TF_VAR_aks_rbac_client_app_id="${RBAC_CLIENT_APP_ID}"
"
