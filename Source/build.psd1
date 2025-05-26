@{
    ModuleManifest           = "$PSScriptRoot/Open-GitRepo.psd1"
    VersionedOutputDirectory = $false
    CopyDirectories          = @('en-US', 'icon.png', './License.txt')
    Target                   = "CleanBuild"
    SourceDirectories        = @(
        "[Pp]rivate", "[Pp]ublic", "[Ee]nums", "[Cc]lasses"
    )
    PublicFilter             = "[Pp]ublic/*.ps1"
}
