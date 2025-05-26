function Get-GitCurrentBranch {
    param([string]$TargetPath, [string]$DefaultBranch)

    if (-not (Test-Path "$TargetPath/.git")) {
        Write-Error "The specified path '$TargetPath' is not a valid git repository."
        return $DefaultBranch
    }

    if ([string]::IsNullOrEmpty($TargetPath)) {
        return git branch --show-current 2>$null
    }

    $currentBranch = git -C $TargetPath rev-parse --abbrev-ref HEAD 2>$null
    if (-not $currentBranch) {
        Write-Error "Could not retrieve current branch. Are you in a git repository?"
        return $DefaultBranch
    }

    return $currentBranch
}