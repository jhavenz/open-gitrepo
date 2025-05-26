function Get-GitRemoteUrl {
    param([string]$TargetPath)

    if ([string]::IsNullOrEmpty($TargetPath)) {
        return git remote get-url origin 2>$null
    }

    return git -C $TargetPath remote get-url origin 2>$null
}