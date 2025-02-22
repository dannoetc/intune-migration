Start-Transcript -Path $env:TEMP\intunejoin.log"

$PPKGName = "ITX.ppkg" 

Write-Output "Installing provisioning package..." 
Install-ProvisioningPackage -PackagePath "$env:temp\IntuneMigration\$PPKGName" -ForceInstall -QuietInstall

Write-Output "Restarting PC for great justice" 

Restart-Computer
