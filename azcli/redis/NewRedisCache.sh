REDIS_NAME=DerekDemo
rg=DerekDemo

az redis create \
    --name "$REDIS_NAME" \
    --resource-group $rg \
    --location eastus \
    --vm-size C0 \
    --sku Basic