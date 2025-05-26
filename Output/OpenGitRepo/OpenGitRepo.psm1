#Region './Public/Open-GitRepo.ps1' -1

function Open-GitRepo {
    <#
    .SYNOPSIS
        Opens a Git repository's web interface in your default browser across any platform.

    .DESCRIPTION
        The Open-GitRepo cmdlet opens the web interface for a GitHub or Bitbucket repository in your default browser. 
        It works cross-platform (Windows, macOS, Linux) and supports:
        - The current directory (default behavior)
        - A provided local directory path (looks up the git remote in that directory)
        - A provided git remote URL (parses and opens directly)
        
        The cmdlet can accept input via parameters or from the pipeline, making it easy to use in scripts or with multiple repositories.

    .PARAMETER Path
        The path to a local directory containing a git repository. If specified, the cmdlet will use the git remote and branch from this directory.

    .PARAMETER Url
        A git remote URL (HTTPS or SSH) to open directly. If specified, the cmdlet will parse the URL and open the corresponding web interface.

    .PARAMETER Branch
        The branch name to use when constructing the web URL. If not specified, the cmdlet will attempt to determine the current branch from the repository.

    .INPUTS
        [String] You can pipe a local directory path or git remote URL to this cmdlet.

    .OUTPUTS
        None. This cmdlet does not generate any output.

    .EXAMPLE
        PS C:\MyRepo> Open-GitRepo
        Opens the current repository's web page in your default browser (Windows).

    .EXAMPLE
        PS /home/user/MyRepo> Open-GitRepo -Path /home/user/otherrepo
        Opens the web page for the repository in /home/user/otherrepo (Linux).

    .EXAMPLE
        PS> 'https://github.com/user/repo.git' | Open-GitRepo
        Opens the GitHub repository web page for the provided URL.

    .EXAMPLE
        PS> '/Users/username/anotherrepo' | Open-GitRepo
        Opens the repository web page for the local directory (macOS).

    .EXAMPLE
        PS> Open-GitRepo -Url 'git@bitbucket.org:user/repo.git'
        Opens the Bitbucket repository web page for the provided SSH URL.

    .NOTES
        Author: Jonathan Havens
        Version: 0.0.2
        Cross-platform: Windows, macOS, Linux
        Supports GitHub and Bitbucket repositories.
        Requires PowerShell 7+ and git in PATH.

    .LINK
        https://github.com/jhavenz/OpenGitRepo
    #>
    [Alias('ogr', 'git-open', 'browse-repo')]
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    param(
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [string]$Path,
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Url')]
        [string]$Url,
        [Parameter(Position = 1)]
        [string]$Branch = 'main'
    )

    begin {
        function Get-GitRemoteAndBranch {
            param([string]$TargetPath)
            $remoteUrl = git -C $TargetPath remote get-url origin 2>$null
            if (-not $remoteUrl) {
                Write-Error "Could not retrieve remote 'origin' URL. Are you in a git repository with an 'origin' remote?"
                return $null
            }
            $currentBranch = git -C $TargetPath rev-parse --abbrev-ref HEAD 2>$null
            if (-not $currentBranch) {
                Write-Error "Could not retrieve current branch. Are you in a git repository?"
                return $null
            }
            return @{ Url = $remoteUrl; Branch = $currentBranch }
        }

        function Get-SshAliasHostnameUrl {
            param([string]$SshAlias)
            $location = "$env:HOME/.ssh/config"
            if (Test-Path $location) {
                $sshConfig = Get-Content $location

                $inHostBlock = $false
                foreach ($line in $sshConfig) {
                    if ($line -match '^\s*Host\s+(\S+)') {
                        $inHostBlock = ($Matches[1] -eq $SshAlias)
                    }
                    elseif ($inHostBlock -and $line -match '^\s*HostName\s+(\S+)') {
                        return $Matches[1]
                    }
                    elseif ($line -match '^\s*$') {
                        $inHostBlock = $false
                    }
                }
            }
            return $null
        }

        function Get-RepoWebUrl {
            param([string]$RemoteUrl, [string]$Branch)
            
            $url = $RemoteUrl -replace 'git@', 'https://' -replace 'http://', 'https://' -replace 'com:', 'com/' -replace 'org:', 'org/'
            if (-not $url.StartsWith('https://')) {
                $url = "https://$url"
            }
            
            try {
                $uri = [uri]::new($url)
            }
            catch {
                # check the ssh profiles for an alias used on the remote
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
                    $path = $uri.AbsolutePath.TrimEnd('.git')
                    return "https://bitbucket.org$path/src/$Branch"
                }
                default {
                    Write-Error "Unsupported Git provider: $($uri.Host)"
                    return $null
                }
            }
        }
    }

    process {
        $targetUrl = $null
        $usedBranch = $Branch

        #normalize the input
        $_url, $_path = $null, $null
        if ($Url -is [string] -and (Test-Path $Url)) {
            $_path = $Url
        }
        
        if ($Path -is [string] -and $Path -match '^https?://|git@') {
            $_url = $Path
        }

        if ($null -ne $_url) {
            $Url = $_url
        } 

        if ($null -ne $_path) {
            $Path = $_path
        }

        if ($Url) {
            if (-not $usedBranch) { $usedBranch = 'main' }
            $targetUrl = Get-RepoWebUrl -RemoteUrl $Url -Branch $usedBranch
            if (-not $targetUrl) { return }
        }
        elseif ($Path) {
            $info = Get-GitRemoteAndBranch -TargetPath $Path
            if ($info) {
                $usedBranch = $info.Branch || $usedBranch
                $targetUrl = Get-RepoWebUrl -RemoteUrl $info.Url -Branch $usedBranch
                if (-not $targetUrl) { return }
            }
            else { return }
        }
        elseif ($PSItem) {
            if (Test-Path $PSItem -PathType Container) {
                $info = Get-GitRemoteAndBranch -TargetPath $PSItem
                if ($info) {
                    $usedBranch = $info.Branch || $usedBranch
                    $targetUrl = Get-RepoWebUrl -RemoteUrl $info.Url -Branch $usedBranch
                    if (-not $targetUrl) { return }
                }
                else { return }
            }
            elseif ($PSItem -match '^https?://|git@') {
                if (-not $usedBranch) { $usedBranch = 'main' }
                $targetUrl = Get-RepoWebUrl -RemoteUrl $PSItem -Branch $usedBranch
                if (-not $targetUrl) { return }
            }
            else {
                Write-Error "Unsupported Git provider or unrecognized remote URL format: $PSItem"
                return
            }
        }
        else {
            $info = Get-GitRemoteAndBranch -TargetPath (Get-Location)
            if ($info) {
                $usedBranch = $info.Branch || $usedBranch
                $targetUrl = Get-RepoWebUrl -RemoteUrl $info.Url -Branch $usedBranch
                if (-not $targetUrl) { return }
            }
            else { return }
        }
        if (-not $targetUrl) {
            Write-Error "Could not determine repository URL. Please provide a valid path or URL."
            return
        }
        Start-Process $targetUrl
    }
    end {
    }
}
#EndRegion './Public/Open-GitRepo.ps1' 236
