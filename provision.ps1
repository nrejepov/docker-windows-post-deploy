function Set-LabArtifacts {
    # Use the temporary drive D: which is an SSD for A1 V2 instances
    Remove-Item D:\* -Confirm:$false -Force -Recurse -ErrorAction SilentlyContinue
    $ProgressPreference = 'SilentlyContinue' # Ignore progress updates (100X speedup)
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" # GitHub only supports tls 1.2 now (PS use 1.0 by default)
    Invoke-WebRequest -Uri "https://github.com/nrejepov/docker-windows-post-deploy/archive/master.zip" -OutFile D:\master.zip
    Expand-Archive -Path D:\master.zip -DestinationPath D:\
    Move-Item D:\*-master\* D:\
    Remove-Item D:\master.zip, D:\provision.ps1, D:\*-master
}

function Disable-InternetExplorerESC {
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 -Force
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0 -Force
    Stop-Process -Name Explorer -Force
    Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green
}

function Enable-InternetExplorerESC {
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 1 -Force
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 1 -Force
    Stop-Process -Name Explorer
    Write-Host "IE Enhanced Security Configuration (ESC) has been enabled." -ForegroundColor Green
}

function Disable-UserAccessControl {
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 00000000 -Force
    Write-Host "User Access Control (UAC) has been disabled." -ForegroundColor Green    
}

# Disable Windows Defender real-time monitoring
Set-MpPreference -DisableRealtimeMonitoring $true

# Disable Windows update
Stop-Service -NoWait -displayname "Windows Update"

Set-LabArtifacts
Disable-UserAccessControl
Disable-InternetExplorerESC
