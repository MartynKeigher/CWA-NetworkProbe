Exmpale usage:

"%windir%\system32\WindowsPowerShell\v1.0\powershell.exe" "(new-object Net.WebClient).DownloadString('https://bit.ly/CWANetProbe') | iex; Get-DeviceCount "

Or, if you get SSL conectivity wraning...

"%windir%\system32\WindowsPowerShell\v1.0\powershell.exe" "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;(new-object Net.WebClient).DownloadString('https://bit.ly/CWANetProbe') | iex; Get-DeviceCount "
