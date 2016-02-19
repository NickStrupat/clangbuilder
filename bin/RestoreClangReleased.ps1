<#############################################################################
#  RestoreClangReleased.ps1
#  Note: Clang Auto Build Environment
#  Date:2016.01.02
#  Author:Force <forcemz@outlook.com>
##############################################################################>
param(
    [Switch]$LLDB
)

$SelfFolder=$PSScriptRoot;
. "$SelfFolder\RepositoryCheckout.ps1"
$ClangbuilderRoot=Split-Path -Parent $SelfFolder
$BuildFolder="$ClangbuilderRoot\out"
$ReleaseRevFolder="$BuildFolder\release"
Write-Output "Release Folder: $ReleaseRevFolder"
$LLVMRepositoriesRoot="http://llvm.org/svn/llvm-project"
$ReleaseRevision="RELEASE_380/rc2"
$LLVMUrlParent=$LLVMRepositoriesRoot+"/llvm/tags/"+$ReleaseRevision
$Revision=380
$RequireRemove=$FALSE

IF(!(Test-Path $BuildFolder)){
    mkdir -Force $BuildFolder
}

IF(Test-Path "$BuildFolder\release"){
    $rinfo=svn info "$BuildFolder\release"
    #URL: http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_X/X
    if($rinfo[2] -inotlike $LLVMUrlParent){
      Write-Output "Require remove old llvm checkout file !"
      $RequireRemove=$TRUE   
    }
}


Push-Location $PWD
Set-Location $BuildFolder
IF((Test-Path "$BuildFolder\release") -and $RequireRemove){
    Remove-Item -Force -Recurse "$BuildFolder\release"
}
Restore-Repository -URL "$LLVMRepositoriesRoot/llvm/tags/$ReleaseRevision" -Folder "release"
if(!(Test-Path "$BuildFolder\release\tools")){
    Write-Output "Checkout LLVM Failed"
    Exit
}

Set-Location "$BuildFolder\release\tools"
Restore-Repository -URL "$LLVMRepositoriesRoot/cfe/tags/$ReleaseRevision" -Folder "clang"
Restore-Repository -URL "$LLVMRepositoriesRoot/lld/tags/$ReleaseRevision" -Folder "lld"

IF($LLDB){
    Restore-Repository -URL "$LLVMRepositoriesRoot/lldb/tags/$ReleaseRevision" -Folder "lldb"
}else{
    if(Test-Path "$BuildFolder\release\tools\lldb"){
        Remove-Item -Force -Recurse "$BuildFolder\release\tools\lldb"
    }
}

if(!(Test-Path "$BuildFolder/release/tools/clang/tools")){
    Write-Output "Checkout Clang Failed"
    Exit
}

Set-Location "$BuildFolder/release/tools/clang/tools"
Restore-Repository -URL "$LLVMRepositoriesRoot/clang-tools-extra/tags/$ReleaseRevision" -Folder "extra"
Set-Location "$BuildFolder/release/projects"
Restore-Repository -URL "$LLVMRepositoriesRoot/compiler-rt/tags/$ReleaseRevision" -Folder "compiler-rt"

Pop-Location
