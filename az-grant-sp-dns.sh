AZ_SP_NAME=$1
AZ_DNS_RG=$2
AZ_DNS_NAME=$3

SP_ID=`az ad app list | jq -r --arg NAME "$AZ_SP_NAME" '.[] | select(.displayName == $NAME) | .appId'`

# Give Access to DNS Zone
DNS_ID=$(az network dns zone show --name $AZ_DNS_NAME --resource-group $AZ_DNS_RG --query "id" --output tsv)

az role assignment create --assignee $SP_ID --role "DNS Zone Contributor" --scope $DNS_ID

# Check Permissions
az role assignment list --assignee $SP_ID
