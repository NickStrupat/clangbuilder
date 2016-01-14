<#############################################################################
#  ClangBuilderManager.ps1
#  Note: Clang Auto Build TaskScheduler
#  Date:2016 01
#  Author:Force <forcemz@outlook.com>    
##############################################################################>
param (
    [ValidateSet("x86", "x64", "ARM", "ARM64")]
    [String]$Arch="x64",
    
    [ValidateSet("Release", "Debug", "MinSizeRel", "RelWithDebug")]
    [String]$Flavor = "Release",
    
    [ValidateSet("110", "120", "140", "141", "150")]
    [String]$VisualStudio="120",
    [Switch]$LLDB,
    [Switch]$Static,
    [Switch]$NMake,
    [Switch]$Released,
    [Switch]$Install,
    [Switch]$CleanEnv
)

if($PSVersionTable.PSVersion.Major -lt 3)
{
    $PSVersionString=$PSVersionTable.PSVersion.Major
    Write-Output -ForegroundColor Red "Clangbuilder must run under PowerShell 3.0 or later host environment !"
    Write-Output -ForegroundColor Red "Your PowerShell Version:$PSVersionString"
    if($Host.Name -eq "ConsoleHost"){
        [System.Console]::ReadKey()
    }
    Exit
}
$WindowTitlePrefix="Clangbuilder PowerShell Utility"
Write-Output "Clang Auto Builder [PowerShell] Utility tools"
Write-Output "Copyright $([Char]0xA9) 2016. FroceStudio. All Rights Reserved."

$SelfFolder=[System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
$ClangbuilderRoot=Split-Path -Parent $SelfFolder
Import-Module "$SelfFolder/ClangBuilderUtility.ps1"

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
Write-Output  -ForegroundColor Red "Unknown VisualStudio Version: $VisualStudio"
}

if($CleanEnv){
    Clear-Environment
}

Invoke-Expression -Command "$SelfFolder/Model/VisualStudioSub$VisualStudio.ps1 $Arch"
Invoke-Expression -Command "$SelfFolder/DiscoverToolChain.ps1"

if($LLDB){
## Do fuck Restore LLDB Build Environment

if(!(Test-Path "$SelfFolder/Required/Python/python.exe")){
$LLDB=$False
}
}

if($Install){
$SourcesDir="release"
if($LLDB){
Invoke-Expression -Command "$SelfFolder/RestoreClangReleased.ps1 --with-lldb"
}else{
Invoke-Expression -Command "$SelfFolder/RestoreClangReleased.ps1"
}
}else{
$SourcesDir="mainline"
if($LLDB){
Invoke-Expression -Command "$SelfFolder/RestoreClangMainline.ps1 --with-lldb"
}else{
Invoke-Expression -Command "$SelfFolder/RestoreClangMainline.ps1"
}
}

if(!(Test-Path "$ClangbuilderRoot/out/workdir")){
mkdir "$ClangbuilderRoot/out/workdir"
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


if($NMake){
Invoke-Expression -Command  "cmake ..\$SourcesDir -G`"NMake Makefiles`" -DCMAKE_CONFIGURATION_TYPES=$Configuration -DCMAKE_BUILD_TYPE=$Configuration -DLLVM_USE_CRT_DEBUG=$CRTLinkDebug -DLLVM_USE_CRT_RELEASE=$CRTLinkRelease -DLLVM_USE_CRT_MINSIZEREL=$CRTLinkRelease -DLLVM_USE_CRT_RELWITHDBGINFO=$CRTLinkRelease    -DLLVM_APPEND_VC_REV:BOOL=ON "  

if(Test-Path "Makefile"){
Invoke-Expression -Command "nmake"
}

}else{

if($Arch -eq "x64"){
Invoke-Expression -Command "cmake ..\$SourcesDir -G`"Visual Studio $VSTools Win64`" -DCMAKE_CONFIGURATION_TYPES=$Configuration -DCMAKE_BUILD_TYPE=$Configuration -DLLVM_USE_CRT_DEBUG=$CRTLinkDebug -DLLVM_USE_CRT_RELEASE=$CRTLinkRelease -DLLVM_USE_CRT_MINSIZEREL=$CRTLinkRelease -DLLVM_USE_CRT_RELWITHDBGINFO=$CRTLinkRelease    -DLLVM_APPEND_VC_REV:BOOL=ON " 

if(Test-Path "LLVM.sln"){
Invoke-Expression -Command "msbuild /nologo LLVM.sln /t:Rebuild /p:Configuration=$Configuration /p:Platform=x64 /t:ALL_BUILD"
}

}elseif($Arch -eq "ARM"){

Invoke-Expression -Command "cmake ..\$SourcesDir -G`"Visual Studio $VSTools ARM`" -DCMAKE_CONFIGURATION_TYPES=$Flavor -DCMAKE_BUILD_TYPE=$Configuration -DLLVM_USE_CRT_DEBUG=$CRTLinkDebug -DLLVM_USE_CRT_RELEASE=$CRTLinkRelease -DLLVM_USE_CRT_MINSIZEREL=$CRTLinkRelease -DLLVM_USE_CRT_RELWITHDBGINFO=$CRTLinkRelease    -DLLVM_APPEND_VC_REV:BOOL=ON "  

if(Test-Path "LLVM.sln"){
Invoke-Expression -Command "msbuild /nologo LLVM.sln /t:Rebuild /p:Configuration=$Flavor /p:Platform=ARM /t:ALL_BUILD"
}

}elseif($Arch -eq "ARM64" -and $VisualStudio -ge 141){

Invoke-Expression -Command "cmake ..\$SourcesDir -G`"Visual Studio $VSTools ARM64`" -DCMAKE_CONFIGURATION_TYPES=$Flavor -DCMAKE_BUILD_TYPE=$Configuration -DLLVM_USE_CRT_DEBUG=$CRTLinkDebug -DLLVM_USE_CRT_RELEASE=$CRTLinkRelease -DLLVM_USE_CRT_MINSIZEREL=$CRTLinkRelease -DLLVM_USE_CRT_RELWITHDBGINFO=$CRTLinkRelease    -DLLVM_APPEND_VC_REV:BOOL=ON "  

if(Test-Path "LLVM.sln"){
Invoke-Expression -Command "msbuild /nologo LLVM.sln /t:Rebuild /p:Configuration=$Flavor /p:Platform=ARM64 /t:ALL_BUILD"
}
}else{

Invoke-Expression -Command "cmake ..\$SourcesDir -G`"Visual Studio $VSTools`" -DCMAKE_CONFIGURATION_TYPES=$Flavor -DCMAKE_BUILD_TYPE=$Configuration -DLLVM_USE_CRT_DEBUG=$CRTLinkDebug -DLLVM_USE_CRT_RELEASE=$CRTLinkRelease -DLLVM_USE_CRT_MINSIZEREL=$CRTLinkRelease -DLLVM_USE_CRT_RELWITHDBGINFO=$CRTLinkRelease    -DLLVM_APPEND_VC_REV:BOOL=ON "  

if(Test-Path "LLVM.sln"){
Invoke-Expression -Command "msbuild /nologo LLVM.sln /t:Rebuild /p:Configuration=$Flavor /p:Platform=win32 /t:ALL_BUILD"
}
#
}
#
}

if($? -eq $True -and $CreateInstallPkg){
if(Test-Path "$PWD/LLVM.sln"){
Invoke-Expression -Command "cpack -C $Flavor"
}
}




