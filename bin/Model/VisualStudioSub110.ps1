<#############################################################################
#  VisualStudioSub110.ps1
#  Note: Clang Auto Build Environment for Visual Studio 2012 [Windows 8]
#  Date:2016.01.01
#  Author:Force <forcemz@outlook.com>
##############################################################################>
param (
    [ValidateSet("x86", "x64", "ARM", "ARM64")]
    [String]$Arch="x64"
)

IF($null -eq $env:VS120COMNTOOLS -or (Test-Path $env:VS120COMNTOOLS) -eq $false)
{
  Write-Error "Visual Studio 2012 might not be installed"
  return
}


IF($Arch -eq "ARM64"){
    Write-Error "Visual Studio 2012 [Windows 8] not support ARM64"
    Exit
}

. "$PSScriptRoot/VisualStudioShared.ps1"

$RegRouter="HKLM:\SOFTWARE\Microsoft"
#vcpackages
#$NativeAMD64=$False

$IsWindows64=[System.Environment]::Is64BitOperatingSystem

IF($IsWindows64)
{
    $RegRouter="HKLM:\SOFTWARE\Wow6432Node\Microsoft"
}


$VSInstallRoot=Get-RegistryValueEx -Path "$RegRouter\VisualStudio\SxS\VS7" -Key '11.0'
$VisualCRoot=Get-RegistryValueEx -Path "$RegRouter\VisualStudio\SxS\VC7" -Key '11.0'
$SdkRoot=Get-RegistryValueEx -Path "$RegRouter\Microsoft SDKs\Windows\v8.0" -Key 'InstallationFolder'
$MSBuildRoot=Get-RegistryValueEx -Path "$RegRouter\MSBuild\11.0" -Key 'MSBuildOverrideTasksPath'

$FrameworkDIR=""
$WindowsSDK_ExecutablePath=""

if($IsWindows64){
    $FrameworkDIR64=Get-RegistryValueEx -Path "$RegRouter\VisualStudio\SxS\VC7" -Key 'FrameworkDir64'
    $FrameworkVER64=Get-RegistryValueEx -Path "$RegRouter\VisualStudio\SxS\VC7" -Key 'FrameworkVer64'
    $WindowsSDK_ExecutablePath=Get-RegistryValueEx -Path "$RegRouter\Microsoft SDKs\Windows\v8.0A\WinSDK-NetFx40Tools-x64" -Key 'InstallationFolder'
    $FrameworkDIR="$FrameworkDIR64\$FrameworkVER64"
}else{
    $FrameworkDIR32=Get-RegistryValueEx -Path "$RegRouter\VisualStudio\SxS\VC7" -Key 'FrameworkDir32'
    $FrameworkVER32=Get-RegistryValueEx -Path "$RegRouter\VisualStudio\SxS\VC7" -Key 'FrameworkVer32'
    $WindowsSDK_ExecutablePath=Get-RegistryValueEx -Path "$RegRouter\Microsoft SDKs\Windows\v8.0A\WinSDK-NetFx40Tools" -Key 'InstallationFolder'
    $FrameworkDIR="$FrameworkDIR32$FrameworkVER32"
}

#Append Include Directory
Push-Include -Include "${SdkRoot}include\winrt"
Push-Include -Include "${SdkRoot}include\shared"
Push-Include -Include "${SdkRoot}include\um"
Push-Include -Include "${VisualCRoot}atlmfc\include"
Push-Include -Include "${VisualCRoot}include"

Push-LibraryDir -LibDIR "${SdkRoot}Lib\win8\um\$Arch"

Push-PathFront -Path "$WindowsSDK_ExecutablePath"
Push-PathFront -Path "${VSInstallRoot}Common7\Tools"
Push-PathFront -Path "${VSInstallRoot}Common7\IDE"
Push-PathFront -Path "${SdkRoot}bin\x86"
Push-PathFront -Path "${VisualCRoot}vcpackages"
Push-PathFront -Path "$FrameworkDIR"

if(Test-Path "$RegRouter\VisualStudio\11.0\Setup\F#"){
    $FSharpRoot=Get-RegistryValueEx -Path "$RegRouter\VisualStudio\11.0\Setup\F#" -Key 'ProductDir'
    Push-PathFront -Path "$FSharpRoot"
}


if($IsWindows64){
    Push-PathFront -Path "${MSBuildRoot}amd64"
}else{
    Push-PathFront -Path "${MSBuildRoot}"
}

if($Arch -eq "x86"){
    Push-LibraryDir -LibDIR "${VisualCRoot}LIB"
    Push-LibraryDir -LibDIR "${VisualCRoot}atlmfc\LIB"
    Push-PathFront -Path "${VisualCRoot}bin"
}elseif($Arch -eq "x64"){
    Push-PathFront -Path "${SdkRoot}bin\x64"
    Push-LibraryDir -LibDIR "${VisualCRoot}LIB\amd64"
    Push-LibraryDir -LibDIR "${VisualCRoot}atlmfc\LIB\amd64"
    Push-PathFront -Path "${VisualCRoot}bin"
    Push-PathFront -Path "${VisualCRoot}bin\x86_amd64"
}elseif($Arch -eq "ARM"){
    Push-LibraryDir -LibDIR "${VisualCRoot}LIB\arm"
    Push-LibraryDir -LibDIR "${VisualCRoot}atlmfc\LIB\arm"
    if($IsWindows64){
        Push-PathFront -Path "${SdkRoot}bin\x64"
    }
    Push-PathFront -Path "${VisualCRoot}bin"
    Push-PathFront -Path "${VisualCRoot}bin\x86_arm"
}
