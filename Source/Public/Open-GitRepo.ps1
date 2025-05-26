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
        https://github.com/jhavenz/open-gitrepo
        https://github.com/jhavenz/open-gitrepo/blob/main/Source/en-US/about_Open-GitRepo.help.txt

    #>
    [Alias('ogr', 'git-open', 'gitopen', 'git-browse', 'gitbrowse')]
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    param(
        [Parameter(Position = 0, ParameterSetName = 'Path', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$Path,
        [Parameter(Position = 0, ParameterSetName = 'Url', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$Url,
        [Parameter(Position = 1)]
        [string]$Branch
    )

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
            $branch = Get-GitCurrentBranch -DefaultBranch $usedBranch

            $targetUrl = Get-RepoWebUrl -RemoteUrl $Url -Branch $Branch
            if (-not $targetUrl) { return }
        }
        elseif ($Path) {
            $branch = Get-GitCurrentBranch -TargetPath $Path -DefaultBranch $Branch
            $url = Get-GitRemoteUrl -TargetPath $Path
            
            if ($branch -and $url) {
                $usedBranch = $info.Branch || $usedBranch
                $targetUrl = Get-RepoWebUrl -RemoteUrl $url -Branch $branch
                if (-not $targetUrl) { return }
            }
        }
        elseif ($PSItem) {
            if (Test-Path $PSItem -PathType Container) {
                $url = Get-GitRemoteUrl -TargetPath $PSItem
                $branch = Get-GitCurrentBranch -TargetPath $PSItem -DefaultBranch $usedBranch
                if ($url -and $branch) {
                    $targetUrl = Get-RepoWebUrl -RemoteUrl $url -Branch $branch
                }
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
            $url = Get-GitRemoteUrl -TargetPath (Get-Location).Path
            $branch = Get-GitCurrentBranch -TargetPath (Get-Location).Path -DefaultBranch $usedBranch

            if ([string]::IsNullOrEmpty($url)) {
                Write-Error "Could not determine a URL for the remote repository. Have you run 'git remote add origin <url>'?"
                return
            }

            if ([string]::IsNullOrEmpty($branch)) {
                Write-Error "Could not determine the current branch. Are you in a git repository?"
                return
            }
            
            $targetUrl = Get-RepoWebUrl -RemoteUrl $url -Branch $branch
            if (-not $targetUrl) {return}
        }
        if (-not $targetUrl) {
            Write-Error "Could not determine repository URL. Please provide a valid path or URL."
            return
        }
        Start-Process $targetUrl
    }
}
