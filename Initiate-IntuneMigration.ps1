### Intune Migration Script for ITX ###########################
### Created by Dan Nelson - dnelson@bensingerconsulting.com ###
### Rev. 01 7/17/2024 #########################################
#########################


# Define variables 
$DeploymentURL = "https://github.com/dannoetc/intune-migration/raw/main/IntuneMigration.zip"
$DeploymentFilename = "IntuneMigration" 

# Download the deployment zip file 
Write-Output "Downloading deployment package from https://github.com/dannoetc/intune-migration/raw/main/IntuneMigration.zip and saving to temp" 

Invoke-WebRequest -Uri $DeploymentURL -Outfile $env:temp\$DeploymentFileName.zip

Expand-Archive $env:TEMP\$DeploymentFileName.zip -Force

# Kick off removal of existing Intune management 

& $env:TEMP\$DeploymentFilename\Remove-IntuneManagement.ps1 