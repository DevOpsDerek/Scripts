az network vnet create \
    --name vnet \
    --resource-group learn-281a2e15-440d-4482-a90d-d6ebd691e7ad \
    --address-prefix 10.0.0.0/16 \
    --subnet-name publicsubnet \
    --subnet-prefix 10.0.0.0/24

az network vnet subnet create \
    --name privatesubnet \
    --vnet-name vnet \
    --resource-group learn-281a2e15-440d-4482-a90d-d6ebd691e7ad \
    --address-prefix 10.0.1.0/24

az network vnet subnet create \
    --name dmzsubnet \
    --vnet-name vnet \
    --resource-group learn-281a2e15-440d-4482-a90d-d6ebd691e7ad \
    --address-prefix 10.0.2.0/24

az network vnet subnet list \
    --resource-group learn-281a2e15-440d-4482-a90d-d6ebd691e7ad \
    --vnet-name vnet \
    --output table