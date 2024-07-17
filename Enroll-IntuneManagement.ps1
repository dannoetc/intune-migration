Start-Transcript -Path $env:TEMP\intunejoin.log"

$PPKGName = "ITX.ppkg" 

Write-Output "Installing provisioning package..." 
Install-ProvisioningPackage -PackagePath "$PsScriptRoot\$PPKGName" -ForceInstall -QuietInstall

Write-Output "Restarting PC!" 

Restart-Computer
