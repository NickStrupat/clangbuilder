<####################################################################################################################
# ClangSetup Environment Reset Feature
#
#
####################################################################################################################>
IF($PSVersionTable.PSVersion.Major -lt 3)
{
Write-Error "Visual Studio Enviroment vNext Must Run on Windows PowerShell 3 or Later,`nYour PowerShell version Is :
${Host}"
[System.Console]::ReadKey()
return
}
$SelfFolder=$PSScriptRoot;
$SelfParent=Split-Path -Parent $SelfFolder
$ClangbuilderRoot=Split-Path -Parent $SelfParent

Invoke-Expression "$SelfFolder\Update.ps1"
Invoke-Expression "$SelfFolder\Install.ps1 -Reset"
