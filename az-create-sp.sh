AZ_SP_NAME=$1
AZ_SP_PASSWORD="`echo $(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c40)`"

AZ_SP_ID=$(az ad sp create-for-rbac --name $AZ_SP_NAME --password $AZ_SP_PASSWORD --query "appId" --output tsv)

# Lower the Permissions of the SP
az role assignment delete --assignee $AZ_SP_ID --role Contributor

echo "app id: $AZ_SP_ID"
echo "app secret: $AZ_SP_PASSWORD"
