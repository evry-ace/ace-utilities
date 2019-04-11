AZ_SP_NAME=$1
AZ_WAF_RG=$2
AZ_WAF_NAME=$3

SP_ID=$(az ad app list | jq -r --arg name $AZ_SP_NAME '.[] | select(.displayName == $name) | .appId')

# Give Access to DNS Zone
WAF_ID=$(az network application-gateway show --name $AZ_WAF_NAME --resource-group $AZ_WAF_RG --query "id" --output tsv)

az role assignment create --assignee $SP_ID --role "Owner" --scope $WAF_ID

# Check Permissions
az role assignment list --assignee $SP_ID
