# CWA-NetworkProbe

Example usage:

"%windir%\system32\WindowsPowerShell\v1.0\powershell.exe" "(new-object Net.WebClient).DownloadString('https://bit.ly/CWANetProbe') | iex; Get-DeviceCount "

Or, if you get an SSL conectivity warning...

"%windir%\system32\WindowsPowerShell\v1.0\powershell.exe" "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;(new-object Net.WebClient).DownloadString('https://bit.ly/CWANetProbe') | iex; Get-DeviceCount "

TODO:
Write about what this does and how it can be leveraged.
