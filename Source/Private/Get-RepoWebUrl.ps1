function Get-RepoWebUrl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$RemoteUrl, 
        [Parameter(Mandatory)]
        [string]$Branch
    )
            
    $url = $RemoteUrl -replace 'git@', 'https://' -replace 'http://', 'https://' -replace 'com:', 'com/' -replace 'org:', 'org/'
    if (-not $url.StartsWith('https://')) {
        $url = "https://$url"
    }
            
    try {
        $uri = [uri]::new($url)
    }
    catch {
        # check for ssh profile alias(es)
        if ($RemoteUrl -match '^git@([^:]+):') {
            $sshAlias = $Matches[1]
            $hostName = Get-SshAliasHostnameUrl -SshAlias $sshAlias
            if ($hostName) {
                $uri = [uri]::new("https://$hostName/$($RemoteUrl -replace '^git@[^:]+:', '')")
            }
            else {
                Write-Error "Could not resolve SSH alias '$sshAlias' to a hostname."
                return $null
            }
        }
        else {
            Write-Error "Invalid remote URL format: $RemoteUrl"
            return $null
        }

    }

    if (-not $uri.Host) {
        Write-Error "Invalid remote URL format: $RemoteUrl"
        return $null
    }

    switch ($uri.Host) {
        'github.com' {
            $path = $uri.AbsolutePath.TrimEnd('.git')
            return "https://github.com$path/tree/$Branch"
        }
        'bitbucket.org' {
            # Bitbucket URL examples:
            # 
            # Default branch:
            # https://bitbucket.org/bbworkspace/customrepo/src/main
            #
            # Secondary branch:
            # https://bitbucket.org/mybbworkspace/mybbrepo/src/acc31fe8745678bc987b123d87d7ac72fec220e52/?at=hotfix%2Fmy-test-branch

            $primaryBranch = Get-PrimaryGitBranch

            if ($primaryBranch -eq $Branch) {
                $path = $uri.AbsolutePath.TrimEnd('.git')
                return "https://bitbucket.org$path/src/$Branch"
            }

            $branchWithHash = Get-GitBranchWithCommitHash 

            $path = $uri.AbsolutePath.TrimEnd('.git')
        
            return "https://bitbucket.org{0}/src/{1}/?at={2}" -f $path, $branchWithHash.CommitHash, $branchWithHash.Branch
        }
        default {
            Write-Error "Unsupported Git provider: $($uri.Host)"
            return $null
        }
    }
}