#Create Resource Group
New-AzResourceGroup -Name SL-PowershellVM -Location EastUS

#Create Virtual Machine
New-AzVm `
    -ResourceGroupName "SL-PowershellVM" `
    -Name "vmpshell01" `
    -Location "East US" `
    -VirtualNetworkName "pshellVnet" `
    -SubnetName "pshellSubnet" `
    -SecurityGroupName "pshellNetworkSecurityGroup" `
    -PublicIpAddressName "pshellPublicIpAddress" `
    -OpenPorts 80,3389

