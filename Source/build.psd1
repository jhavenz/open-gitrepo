@{
    ModuleManifest           = "$PSScriptRoot/OpenGitRepo.psd1"
    VersionedOutputDirectory = $false
    CopyDirectories          = @('en-US')
    Target                   = "CleanBuild"
    SourceDirectories        = @(
        "[Pp]rivate", "[Pp]ublic", "[Ee]nums", "[Cc]lasses"
    )
    PublicFilter             = "[Pp]ublic/*.ps1"
}
