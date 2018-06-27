# Inspiration from 
# Silent Install 7-Zip
# http://www.7-zip.org/download.html
# https://forum.pulseway.com/topic/1939-install-7-zip-with-powershell/ 

# Check for admin rights
$wid = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$prp = new-object System.Security.Principal.WindowsPrincipal($wid)
$adm = [System.Security.Principal.WindowsBuiltInRole]::Administrator
if (-not $prp.IsInRole($adm)) {
    throw "This script requires elevated rights to install software.. Please run from an elevated shell session."
}

Write-Progress -Activity "Installing dependencies" -Status "Instal ChocolateyGet as a provider"
$provider = ChocolateyGet
Find-PackageProvider $provider | Install-PackageProvider
Import-PackageProvider $provider

Write-Progress -Activity "Installing dependencies" -Status "Installing tools"
Install-Package -ProviderName $provider -Name 7zip git docker kubernetes-cli

Write-Progress -Activity "Installing dependencies" -Status "Installing software"
Install-Package -ProviderName $provider -Name vscode chrome spotify

Write-Progress -Activity "Installing dependencies" -Status "Installing Firefox Developer Edition"
set-location $env:USERPROFILE
Invoke-WebRequest "https://download.mozilla.org/?product=firefox-devedition-stub&os=win&lang=en-US" -OutFile "$env:USERPROFILE\Firefox"
Start-Process -FilePath "$env:USERPROFILE\Firefox" -ArgumentList "/S" -Wait

Write-Progress -Activity "Installing dependencies" -Status "Installing Firefox Developer Edition" -Completed

# Set variable for WSL terminal
$version = "0.8.11"
$wslTerminal = "wsl-terminal-$version.7z"

if (-not (Test-Path -Path "$env:USERPROFILE\wsl-terminal")) {
    Write-Progress -Activity "Get bits for WSL terminal"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri "https://github.com/goreliu/wsl-terminal/releases/download/v$version/$wslTerminal" -OutFile $env:USERPROFILE\$wslTerminal
    
        Write-Progress -Activity "Extract WSL terminal and remove after complete"
    Get-Item $wslTerminal | ForEach-Object {
        $7z_Arguments = @(
            'x'							## eXtract files with full paths
            '-y'						## assume Yes on all queries
            "`"-o$($env:USERPROFILE)`""		## set Output directory
            "`"$($_.FullName)`""				## <archive_name>
        )
        & $7z_Application $7z_Arguments
        If ($LASTEXITCODE -eq 0) {
            Remove-Item -Path $_.FullName -Force
        }
    }
    
    Write-Progress -Activity "Ensure symlink exists"
    $symlink = "$env:USERPROFILE\Desktop\wsl.lnk"
    If (-not (Test-Path -Path $symlink)) {
        New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\Desktop\" -Name "wsl.lnk" -Value "$env:USERPROFILE\wsl-terminal\open-wsl.exe" 
    }
} else {
    Write-Progress -Activity "Wsl terminal already installed."
}
