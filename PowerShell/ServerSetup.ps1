$homeuser = $HomeAdminAccount
$homepassword = $HomeAdminPassword | ConvertTo-SecureString -asPlainText -Force
$homecredential = New-Object System.Management.Automation.PSCredential($homeuser, $homepassword)

$VmIP = Get-VM -Name Octo1 | Select -ExpandProperty NetworkAdapters | Select-Object -ExpandProperty IPAddresses | Select -First 1

Invoke-Command -ComputerName $VmIP -Credential $homecredential -ScriptBlock {
    $localuser = $LocalAdminAccount
    $localpassword = $LocalAdminPassword | ConvertTo-SecureString -asPlainText -Force
    $localcredential = New-Object System.Management.Automation.PSCredential($localuser, $localpassword)
    $domainuser = $DomainAdminAccount
    $domainpassword = $DomainAdminPassword | ConvertTo-SecureString -asPlainText -Force
    $domaincredential = New-Object System.Management.Automation.PSCredential($domainuser, $domainpassword)

    Write-host "Renaming Computer"
    Rename-Computer -NewName $ServerName -LocalCredential $localcredential

    Write-Host "Adding to Domain"
    Add-Computer -ComputerName $ServerName -DomainName $DomainName -Credential $domaincredential
    
    Write-host "Installing Chocolatey"
    
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    
    Write-host "Installing VSCode"
    choco install vscode -y

    Write-host "Installing .NET 4.7.2"
    choco install dotnet4.7.2 -y
    
    Write-host ".NET"
    choco install dotnetfx -y

    Write-Host "Installing Octopus Tentacle"
    choco install OctopusDeploy.Tentacle -y

    cd "C:\Program Files\Octopus Deploy\Tentacle"

    Tentacle.exe create-instance --instance "Tentacle" --config "C:\Octopus\Tentacle.config" --console
    Tentacle.exe new-certificate --instance "Tentacle" --if-blank --console
    Tentacle.exe configure --instance "Tentacle" --reset-trust --console
    Tentacle.exe configure --instance "Tentacle" --home "C:\Octopus" --app "C:\Octopus\Applications" --port "10933" --console
    Tentacle.exe configure --instance "Tentacle" --trust $OctopusThumbPrint --console
    "netsh" advfirewall firewall add rule "name=Octopus Deploy Tentacle" dir=in action=allow protocol=TCP localport=10933
    Tentacle.exe register-with --instance "Tentacle" --server "http://OCTOURK" --apiKey=$OctopusAPIKey --role "VirtualMachines" --environment "VirtualMachines" --comms-style TentaclePassive --console
    Tentacle.exe service --instance "Tentacle" --install --start --console

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module PSWindowsUpdate –Force
    Get-WindowsUpdate 
    Install-WindowsUpdate -AcceptAll -AutoReboot

}
    