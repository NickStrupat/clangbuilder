<####################################################################################################################
# Clangbuilder Environment Install
# WebInstall Standalone
# Date:2016.01.03
# Author:Force <forcemz@outlook.com>
####################################################################################################################>
<#
# https://raw.githubusercontent.com/fstudio/clangbuilder/master/bin/Installer/WebInstall.ps1 Internet Installer.
# Run PowerShell IEX
#>

Set-StrictMode -Version latest
Import-Module -Name BitsTransfer

Function Global:Get-RegistryValue($key, $value) {
    (Get-ItemProperty $key $value).$value
}

Function Global:Create-UnCompressZip
{
    param(
        [Parameter(Position=0,Mandatory=$True,HelpMessage="Unzip sources")]
        [ValidateNotNullorEmpty()]
        [String]$ZipSource,
        [Parameter(Position=1,Mandatory=$True,HelpMessage="Output Directory")]
        [ValidateNotNullorEmpty()]
        [String]$Destination
    )
    if(!(Test-Path $ZipSource)){
        Write-Error "Cannot found $ZipSource"
        Exit
    }
    [System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')|Out-Null
    Write-Output "Use System.IO.Compression.ZipFile Unzip `nPackage: $ZipSource`nOutput: $Destination"
    [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipSource, $Destination)
}


Function Global:Get-DownloadFile
{
    param
    (
        [Parameter(Position=0,Mandatory=$True,HelpMessage="Enter a Internet File Full Url")]
        [ValidateNotNullorEmpty()]
        [String]$FileUrl,
        [String]$FileSavePath
    )

    IF($FileSavePath -eq $null)
    {
        $NposIndex=$FileUrl.LastIndexOf("/")+1
        IF($NposIndex -eq $FileUrl.Length)
        {
            return $Fase
        }
        $DownloadFd=Get-RegistryValue 'HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders' '{374DE290-123F-4565-9164-39C4925E467B}'
        $FileSigName=$FileUrl.Substring($NposIndex,$FileUrl.Length - $NposIndex)
        $FileSavePath="{0}\{1}" -f $DownloadFd,$FileSigName
    }
    Start-BitsTransfer $FileUrl  $FileSavePath
}

<#
FOLDERID_Downloads
GUID	{374DE290-123F-4565-9164-39C4925E467B}
Display Name	Downloads
Folder Type	PERUSER
Default Path 	%USERPROFILE%\Downloads
CSIDL Equivalent	None
Legacy Display Name	Not applicable
Legacy Default Path 	Not applicable
#>

#HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\{374DE290-123F-4565-9164-39C4925E467B}
###Default ,Your Should Input

$ClangBuilderInstallRoot=""

Function Get-InstallPrefix{
    param(
        [Parameter(Position=0,Mandatory=$True,HelpMessage="Enter Install Prefix:")]
        [ValidateNotNullorEmpty()]
        [String]$Prefix
    )
    $ClangBuilderInstallRoot=$Prefix
}

Get-InstallPrefix

$DownloadInstallPackage="${env:TEMP}\clangbuilder.zip"
$OfficaUrl="https://github.com/fstudio/clangbuilder/archive/master.zip"

Get-DownloadFile -FileUrl $OfficaUrl -FileSavePath $DownloadInstallPackage

if(!(Test-Path $DownloadInstallPackage)){
    Write-Error "Download $OfficaUrl Failed !"
    Exit
}

Unblock-File $DownloadInstallPackage
Create-UnCompressZip -ZipSource $DownloadInstallPackage -Destination "${env:TEMP}\clangbuilder"

IF(!$(Test-Path "${env:TEMP}\clangbuilder"))
{
    Write-Error "Un Compress Error,Please Retry!"
    [System.Console]::ReadKey()
    return
}

 IF(!(Test-Path $ClangBuilderInstallRoot))
 {
     mkdir -Force $ClangBuilderInstallRoot
 }

 Copy-Item -Path "${Env:TEMP}\clangbuilder\clangbuilder-master\*" "$ClangBuilderInstallRoot"  -Force -Recurse
 Remove-Item -Force -Recurse "$env:TEMP\clangbuilder.zip"
 Remove-Item -Force -Recurse "$env:TEMP\clangbuilder"

 &PowerShell -NoLogo -NoExit -File "$ClangBuilderInstallRoot\bin\Installer\Install.ps1"

 Write-Output "Process done"
