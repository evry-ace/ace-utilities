AZURE_CERT_MANAGER_SP_NAME=$1
AZURE_CERT_MANAGER_SP_PASSWORD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c40)
AZURE_CERT_MANAGER_DNS_RESOURCE_GROUP=$2
AZURE_CERT_MANAGER_DNS_NAME=$3

AZURE_CERT_MANAGER_SP_APP_ID=$(az ad sp create-for-rbac --name $AZURE_CERT_MANAGER_SP_NAME --password $AZURE_CERT_MANAGER_SP_PASSWORD --query "appId" --output tsv)

# Lower the Permissions of the SP
az role assignment delete --assignee $AZURE_CERT_MANAGER_SP_APP_ID --role Contributor

# Give Access to DNS Zone
DNS_ID=$(az network dns zone show --name $AZURE_CERT_MANAGER_DNS_NAME --resource-group $AZURE_CERT_MANAGER_DNS_RESOURCE_GROUP --query "id" --output tsv)

az role assignment create --assignee $AZURE_CERT_MANAGER_SP_APP_ID --role "DNS Zone Contributor" --scope $DNS_ID

# Check Permissions
az role assignment list --assignee $AZURE_CERT_MANAGER_SP_APP_ID

# Create Secret
kubectl create secret generic azuredns-config \
  --from-literal=CLIENT_SECRET=$AZURE_CERT_MANAGER_SP_PASSWORD

# Get the Service Principal App ID for configuration
echo "SP ID > $AZURE_CERT_MANAGER_SP_APP_ID"
echo "SP Secret > $AZURE_CERT_MANAGER_SP_PASSWORD"
