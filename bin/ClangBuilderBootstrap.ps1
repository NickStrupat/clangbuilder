<#############################################################################
#  ClangBuilderBootstrap.ps1
#  Note: Clang Auto Build TaskScheduler
#  Date:2016 02
#  Author:Force <forcemz@outlook.com>
##############################################################################>
param (
    [ValidateSet("x86", "x64")]
    [String]$Arch="x64",

    [ValidateSet("Release", "Debug", "MinSizeRel", "RelWithDebug")]
    [String]$Flavor = "Release",

    [ValidateSet("110", "120", "140", "141", "150")]
    [String]$VisualStudio="120",
    [Switch]$Static,
    [Switch]$Released,
    [Switch]$Install,
    [Switch]$Clear
)

if($PSVersionTable.PSVersion.Major -lt 3)
{
    $PSVersionString=$PSVersionTable.PSVersion.Major
    Write-Error "Clangbuilder must run under PowerShell 3.0 or later host environment !"
    Write-Error "Your PowerShell Version:$PSVersionString"
    if($Host.Name -eq "ConsoleHost"){
        [System.Console]::ReadKey()
    }
    Exit
}

$Host.UI.RawUI.WindowTitle="Clangbuilder PowerShell Utility"
Write-Output "Clang Auto Builder [PowerShell] Utility tools"
Write-Output "Copyright $([Char]0xA9) 2016. FroceStudio. All Rights Reserved."

$SelfFolder=$PSScriptRoot;
$ClangbuilderRoot=Split-Path -Parent $SelfFolder
. "$SelfFolder/ClangBuilderUtility.ps1"

$VSTools="12"
if($VisualStudio -eq "110"){
    $VSTools="11"
}elseif($VisualStudio -eq "120"){
    $VSTools="12"
}elseif($VisualStudio -eq "140"){
    $VSTools="14"
}elseif($VisualStudio -eq "141"){
    $VSTools="14"
}elseif($VisualStudio -eq "150"){
    $VSTools="15"
}ELSE{
    Write-Error "Unknown VisualStudio Version: $VisualStudio"
}

if($Clear){
    Reset-Environment
}

Invoke-Expression -Command "$SelfFolder/Model/VisualStudioSub$VisualStudio.ps1 $Arch"
Invoke-Expression -Command "$SelfFolder/DiscoverToolChain.ps1"

if($Released){
    $SourcesDir="release"
    Invoke-Expression -Command "$SelfFolder/RestoreClangReleased.ps1"
}else{
    $SourcesDir="mainline"
    Invoke-Expression -Command "$SelfFolder/RestoreClangMainline.ps1"
}

if(!(Test-Path "$ClangbuilderRoot/out/workdir")){
    mkdir -Force "$ClangbuilderRoot/out/workdir"
}else{
    Remove-Item -Force -Recurse "$ClangbuilderRoot/out/workdir/*"
}

Set-Location "$ClangbuilderRoot/out/workdir"

if($Static){
    $CRTLinkRelease="MT"
    $CRTLinkDebug="MTd"
}else{
    $CRTLinkRelease="MD"
    $CRTLinkDebug="MDd"
}

#stage0
if(!(Test-Path build_stage0)){
    mkdir -Force build_stage0
}
Set-Location build_stage0

&cmake "..\..\$SourcesDir" -GNinja -DCMAKE_CONFIGURATION_TYPES="$Flavor" -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON -DLLVM_ENABLE_ASSERTIONS=ON -DCMAKE_BUILD_TYPE="$Flavor" -DLLVM_USE_CRT_RELEASE="$CRTLinkRelease" -DLLVM_USE_CRT_MINSIZEREL="$CRTLinkRelease" -DLLVM_APPEND_VC_REV=ON || exit /b
&ninja all || exit /b
&ninja check || exit /b
&ninja check-clang || exit /b

Set-Location ..

if(!(Test-Path build)){
    mkdir build
}
$env:CC="..\build_stage0\bin\clang-cl"
$env:CXX="..\build_stage0\bin\clang-cl"
&cmake "..\..\$SourcesDir" -GNinja -DCMAKE_CONFIGURATION_TYPES="$Flavor" -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON -DLLVM_ENABLE_ASSERTIONS=ON -DCMAKE_BUILD_TYPE="$Flavor" -DLLVM_USE_CRT_RELEASE="$CRTLinkRelease" -DLLVM_USE_CRT_MINSIZEREL="$CRTLinkRelease" -DLLVM_APPEND_VC_REV=ON || exit /b
&ninja all || exit /b
&ninja check || exit /b
&ninja check-clang || exit /b
&ninja package ||exit /b
Set-Location ..
