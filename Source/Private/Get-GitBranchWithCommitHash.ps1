function Get-GitBranchWithCommitHash {
    param([string]$TargetPath)

    $startingLocation = Get-Location

    if (Test-Path ($TargetPath || "") -PathType Container) {
        Set-Location -Path $TargetPath
    }
    elseif (![string]::IsNullOrEmpty($TargetPath)) {
        Write-Error "The specified path '$TargetPath' is not a valid directory."
        return $null
    }

    try {
        $targetBranch = (git for-each-ref --format='%(refname:short)|%(objectname)' refs/heads/ 2>$null || @()) | ForEach-Object {
            $parts = $_ -split '\|'
            if ($parts.Count -eq 2) {
                [PSCustomObject]@{ Branch = $parts[0]; CommitHash = $parts[1] }
            }

            return [PSCustomObject]@{
                Branch     = $null
                CommitHash = $null
            }
        } | Where-Object { $_.Branch -eq $Branch } | Select-Object -First 1

        if ($null -eq $targetBranch -or -not $targetBranch.CommitHash) {
            Write-Error "Branch '$Branch' not found for this repository."
            return $null
        }

        return $targetBranch
    }
    finally {
        if ($startingLocation -ne (Get-Location)) {
            Set-Location -Path $startingLocation
        }
    }  
}