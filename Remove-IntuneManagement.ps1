Start-Transcript -Path $env:TEMP\intunejoin.log -NoClobber


function Remove-IntuneMgmt {
    
    #  I ganked this from @philhelming. This function was borrowed from his Intune to WS1 Migration script, which can be found here: https://github.com/helmlingp/apps_WS1UEMWin10Migration/blob/master/IntunetoWS1Win10Migration.ps1
   
   $OMADMPath = "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\*"
    $Account = (Get-ItemProperty -Path $OMADMPath -ErrorAction SilentlyContinue).PSChildname

    $Enrolled = $true
    $EnrollmentPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Enrollments\$Account"
    $EnrollmentUPN = (Get-ItemProperty -Path $EnrollmentPath -ErrorAction SilentlyContinue).UPN
    $ProviderID = (Get-ItemProperty -Path $EnrollmentPath -ErrorAction SilentlyContinue).ProviderID

    if(!($EnrollmentUPN) -or $ProviderID -ne "MS DM Server") {
        $Enrolled = $false
    }

    If($Enrolled){

        # Delete Task Schedule tasks
        Get-ScheduledTask -TaskPath "\Microsoft\Windows\EnterpriseMgmt\$Account\*" | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue

        # Delete reg keys
        Remove-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Enrollments\$Account" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Enrollments\Status\$Account" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked\$Account" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\AdmxInstalled\$Account" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\Providers\$Account" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\$Account" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\OMADM\Logger\$Account" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\OMADM\Sessions\$Account" -Recurse -Force -ErrorAction SilentlyContinue
        
        # Delete Enrollment Certificates
        $UserCerts = get-childitem cert:"CurrentUser" -Recurse
        $IntuneCerts = $UserCerts | Where-Object {$_.Issuer -eq "CN=SC_Online_Issuing"}
        foreach ($Cert in $IntuneCerts) {
            $cert | Remove-Item -Force
        }
        $DeviceCerts = get-childitem cert:"LocalMachine" -Recurse
        $IntuneCerts = $DeviceCerts | Where-Object {$_.Issuer -eq "CN=Microsoft Intune Root Certification Authority" -OR $_.Issuer -eq "CN=Microsoft Intune MDM Device CA"}
        foreach ($Cert in $IntuneCerts) {
            $cert | Remove-Item -Force -ErrorAction SilentlyContinue
        }

        # Delete Intune Company Portal App
        Get-AppxPackage -AllUsers -Name "Microsoft.CompanyPortal" | Remove-AppxPackage -Confirm:$false

    }

}

Write-Output "Writing RunOnce for kicking off Entra join" 
$RunOnceKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"

Set-ItemProperty $RunOnceKey "NextRun" ('C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe -executionPolicy Unrestricted -File ' + "$PsScriptRoot\Enroll-IntuneManagement.ps1")

Remove-IntuneMgmt

