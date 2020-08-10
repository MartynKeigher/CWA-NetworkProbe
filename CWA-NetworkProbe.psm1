<#PSScriptInfo
.Version
    1.0
.Author
    Martyn T. Keigher (@martynkeigher)
.Tags
    automate network probe networkprobe 
.Github URL
    https://github.com/MartynKeigher
.ReleaseNotes 
    1.0 - Initial Release.
        Get-DeviceCount
        Get-ProbeStatus
        Get-TemplateCount
        Remove-IgnoredDevices
        Reset-Templates
        

.Description
    A collection of Powershell functions that can be ran against an Automate agent to perform Network Probe related tasks.
#>

#Ignore SSL errors
Add-Type -Debug:$False @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

#Enable TLS, TLS1.1, TLS1.2, TLS1.3 in this session if they are available
IF([Net.SecurityProtocolType]::Tls) {[Net.ServicePointManager]::SecurityProtocol=[Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls}
IF([Net.SecurityProtocolType]::Tls11) {[Net.ServicePointManager]::SecurityProtocol=[Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls11}
IF([Net.SecurityProtocolType]::Tls12) {[Net.ServicePointManager]::SecurityProtocol=[Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12}
IF([Net.SecurityProtocolType]::Tls13) {[Net.ServicePointManager]::SecurityProtocol=[Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls13}


##[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

function Get-DeviceCount {

    $DeviceCount = (gci -Path HKLM:\Software\LabTech\ProbeService\NetworkDevices).count

    Write-Output "Device Count: $DeviceCount."

}


function Get-ProbeStatus {

    $LastSuccessStatus = (gp -Path 'HKLM:\SOFTWARE\LabTech\Service' -Name LastSuccessStatus).LastSuccessStatus;
    $ProbeStatus = (gp -Path 'HKLM:\SOFTWARE\LabTech\Service' -Name Probe).Probe;
        If($ProbeStatus -eq 1){"Status: Enabled; Agent's Last Success Status: $LastSuccessStatus."}
            Else{"Status: Not a probe!; Agent's Last Success Status: $LastSuccessStatus."};

}


function Get-TemplateCount {


    $DetectionTemplateCount = (gci -Path HKLM:\Software\LabTech\ProbeService\DetectionTemplates).count
    $DeviceLibraryCount = (gci -Path HKLM:\Software\LabTech\ProbeService\DeviceLibrary).count

    Write-Output "Detection Templates: $DetectionTemplateCount; Device Libraries: $DeviceLibraryCount."

}


function Remove-IgnoredDevices {

    $IgnoredDeviceCountBefore = (gci -Path HKLM:\Software\LabTech\Probe\Network).count
    Remove-ItemProperty -Path 'HKLM:\Software\LabTech\Probe\Network' -Name "*" -Force
    $IgnoredDeviceCountAfter = (gci -Path HKLM:\Software\LabTech\Probe\Network).count
        If($IgnoredDeviceCountAfter -lt $IgnoredDeviceCountBefore){"Success: $IgnoredDeviceCountBefore devices un-ignored."}
            Else{"Error: Please check the code. Needs moar work! :("}

}

function Reset-Templates {

    $DetectionTemplateCountBefore = (gci -Path HKLM:\Software\LabTech\ProbeService\DetectionTemplates).count
    Write-Output "Detection Templates found: $DetectionTemplateCountBefore. Resetting Templates, please wait..."

    Stop-Service -Name LTSvcMon,LTService -Force -wa SilentlyContinue
    Remove-Item -Path 'HKLM:\SOFTWARE\LabTech\ProbeService\CollectionTemplates\*' -Recurse -Force
    Remove-Item -Path 'HKLM:\SOFTWARE\LabTech\ProbeService\DetectionTemplates\*' -Recurse -Force
    Remove-Item -Path 'HKLM:\SOFTWARE\LabTech\ProbeService\DeviceLibrary\*' -Recurse -Force

    Remove-Item -Path 'HKLM:\SOFTWARE\LabTech\Service\CollectionTemplates' -Recurse -Force
    Remove-Item -Path 'HKLM:\SOFTWARE\LabTech\Service\DetectionTemplates' -Recurse -Force
    Remove-Item -Path 'HKLM:\SOFTWARE\LabTech\Service\DeviceLibrary' -Recurse -Force

    Start-Service -Name LTService,LTSvcMon

    $DetectionTemplateCountAfter = (gci -Path HKLM:\Software\LabTech\ProbeService\DetectionTemplates).count
        If($DetectionTemplateCountAfter -le $DetectionTemplateCountBefore){"Success: Detection Templates reset."}
            Else{"Error: Please check the code. Needs moar work! :("}

}
