rg=DerekDemo
APPSERVICE="licenserenewal$RANDOM"
location=westeurope

#Create Web App

az appservice plan create \
    --resource-group $rg \
    --name vehicleAppServicePlan \
    --sku S1

#Create Web App

az webapp create \
    --resource-group $rg \
    --name $APPSERVICE \
    --plan vehicleAppServicePlan \
    --deployment-source-url https://github.com/MicrosoftDocs/mslearn-load-balance-web-traffic-with-application-gateway \
    --deployment-source-branch appService