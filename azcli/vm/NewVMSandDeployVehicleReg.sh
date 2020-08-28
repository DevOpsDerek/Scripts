rg=DerekDemo
sub=01257442-2b50-48b4-8545-6a0ab62fc5e8
location=westeurope

#Login
az login

#select subscription

az account set --subscription $sub

#Create Group
az group create --name $rg --location $location

#Create Network

az network vnet create \
  --resource-group $rg \
  --name vehicleAppVnet \
  --address-prefix 10.0.0.0/16 \
  --subnet-name webServerSubnet \
  --subnet-prefix 10.0.1.0/24

#download the script that creates the virtual machines

git clone https://github.com/MicrosoftDocs/mslearn-load-balance-web-traffic-with-application-gateway module-files

#create virtual machines

az vm create \
  --resource-group $rg \
  --name webServer1 \
  --image UbuntuLTS \
  --admin-username azureuser \
  --generate-ssh-keys \
  --vnet-name vehicleAppVnet \
  --subnet webServerSubnet \
  --public-ip-address "" \
  --nsg "" \
  --custom-data module-files/scripts/vmconfig.sh \
  --no-wait

az vm create \
  --resource-group $rg \
  --name webServer2 \
  --image UbuntuLTS \
  --admin-username azureuser \
  --generate-ssh-keys \
  --vnet-name vehicleAppVnet \
  --subnet webServerSubnet \
  --public-ip-address "" \
  --nsg "" \
  --custom-data module-files/scripts/vmconfig.sh

