rg=DerekDemo
location=westeurope
APPSERVICE="licenserenewal$RANDOM"
 
 # Create App Gateway Subnet
az network vnet subnet create \
  --resource-group $rg \
  --vnet-name vehicleAppVnet  \
  --name appGatewaySubnet \
  --address-prefixes 10.0.0.0/24


# Create App Gateway IP
az network public-ip create \
  --resource-group $rg \
  --name appGatewayPublicIp \
  --sku Standard \
  --dns-name vehicleapp${RANDOM}

# Create App Gateway
az network application-gateway create \
    --resource-group $rg \
    --name vehicleAppGateway \
    --sku WAF_v2 \
    --capacity 2 \
    --vnet-name vehicleAppVnet \
    --subnet appGatewaySubnet \
    --public-ip-address appGatewayPublicIp \
    --http-settings-protocol Http \
    --http-settings-port 8080 \
    --frontend-port 8080

# Create IP Variables
WEBSERVER1IP="$(az vm list-ip-addresses \
  --resource-group $rg \
  --name webServer1 \
  --query [0].virtualMachine.network.privateIpAddresses[0] \
  --output tsv)"

WEBSERVER2IP="$(az vm list-ip-addresses \
  --resource-group $rg \
  --name webserver2 \
  --query [0].virtualMachine.network.privateIpAddresses[0] \
  --output tsv)"

# Create App Gateway Front End address pool
az network application-gateway address-pool create \
  --gateway-name vehicleAppGateway \
  --resource-group $rg \
  --name vmPool \
  --servers $WEBSERVER1IP $WEBSERVER2IP

# Create back end pool
az network application-gateway address-pool create \
    --resource-group $rg \
    --gateway-name vehicleAppGateway \
    --name appServicePool \
    --servers $APPSERVICE.azurewebsites.net

# Create Frpnt end Port for HTTP
az network application-gateway frontend-port create \
    --resource-group $rg \
    --gateway-name vehicleAppGateway \
    --name port80 \
    --port 80

# Create HTTP Listener
az network application-gateway http-listener create \
    --resource-group $rg \
    --name vehicleListener \
    --frontend-port port80 \
    --gateway-name vehicleAppGateway

# Create Front End Probe
az network application-gateway probe create \
    --resource-group $rg \
    --gateway-name vehicleAppGateway \
    --name customProbe \
    --path / \
    --interval 15 \
    --threshold 3 \
    --timeout 10 \
    --protocol Http \
    --host-name-from-http-settings true

#Use Gateway
az network application-gateway http-settings update \
    --resource-group $rg \
    --gateway-name vehicleAppGateway \
    --name appGatewayBackendHttpSettings \
    --host-name-from-backend-pool true \
    --port 80 \
    --probe customProbe

# Create URL Path map
az network application-gateway url-path-map create \
    --resource-group $rg \
    --gateway-name vehicleAppGateway \
    --name urlPathMap \
    --paths /VehicleRegistration/* \
    --http-settings appGatewayBackendHttpSettings \
    --address-pool vmPool

# Create routing rule
az network application-gateway url-path-map rule create \
    --resource-group $rg \
    --gateway-name vehicleAppGateway \
    --name appServiceUrlPathMap \
    --paths /LicenseRenewal/* \
    --http-settings appGatewayBackendHttpSettings \
    --address-pool appServicePool \
    --path-map-name urlPathMap

#Create routing rule with path map
az network application-gateway rule create \
    --resource-group $rg \
    --gateway-name vehicleAppGateway \
    --name appServiceRule \
    --http-listener vehicleListener \
    --rule-type PathBasedRouting \
    --address-pool appServicePool \
    --url-path-map urlPathMap

# Delete test config
az network application-gateway rule delete \
    --resource-group $rg \
    --gateway-name vehicleAppGateway \
    --name rule1