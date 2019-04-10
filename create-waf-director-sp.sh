AZURE_WAF_DIRECTOR_SP_NAME=$1

GENERATED_SECRET="`echo $(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c40)`"
AZURE_WAF_DIRECTOR_SP_PASSWORD=${AZURE_WAF_DIRECTOR_SP_PASSWORD:-$GENERATED_SECRET}

AZURE_WAF_DIRECTOR_WAF_RESOURCE_GROUP=$2
AZURE_WAF_DIRECTOR_WAF_NAME=$3

AZURE_WAF_DIRECTOR_SP_APP_ID=$(az ad sp create-for-rbac --name $AZURE_WAF_DIRECTOR_SP_NAME --password $AZURE_WAF_DIRECTOR_SP_PASSWORD --query "appId" --output tsv)

# Lower the Permissions of the SP
az role assignment delete --assignee $AZURE_WAF_DIRECTOR_SP_APP_ID --role Contributor

# Give Access to DNS Zone
WAF_ID=$(az network application-gateway show --name $AZURE_WAF_DIRECTOR_WAF_NAME --resource-group $AZURE_WAF_DIRECTOR_WAF_RESOURCE_GROUP --query "id" --output tsv)

az role assignment create --assignee $AZURE_WAF_DIRECTOR_SP_APP_ID --role "Owner" --scope $WAF_ID

# Check Permissions
az role assignment list --assignee $AZURE_WAF_DIRECTOR_SP_APP_ID

# Create Secret
kubectl create secret generic -n kube-system ace-waf-director \
  --from-literal="client_id=$AZURE_WAF_DIRECTOR_SP_APP_ID" \
  --from-literal="client_secret=$AZURE_WAF_DIRECTOR_SP_PASSWORD" \
  --from-literal="tenant_id=$AZURE_TENANT_ID" \
  --from-literal="subscription_id=$AZURE_SUBSCRIPTION_ID"
