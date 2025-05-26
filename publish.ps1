[CmdletBinding()]
param([string]$NugetApiKey)

$nugetApiKey = $NugetApiKey || $env:NugetApiKey
if ([string]::IsNullOrEmpty($env:NugetApiKey)) {
    Write-Error "NugetApiKey must be set as an environment variable."
    exit 1
}

$ErrorActionPreference = 'Stop'

if ($PSBoundParameters.ContainsKey('Verbose')) {
    Build-Module "$PSScriptRoot/Source" -Verbose
}
else {
    Build-Module "$PSScriptRoot/Source"
}
Write-Output "Module build succeeded..."

$argz = @{
    NuGetApiKey = $env:NugetApiKey
    Verbose     = $PSBoundParameters.ContainsKey('Verbose')
    Name        = "$PSScriptRoot/Output/Open-GitRepo/Open-GitRepo.psm1"
}


Publish-Module @argz
Write-Output "Published to PowerShell Gallery..."