# Open-GitRepo

A simple cross-platform PowerShell tool to open Git repositories in your browser directly from the command line.

Works seamlessly on Windows, macOS, and Linux.

## Features

- Open the current Git repository's web interface with a single command
- Automatically detects and opens your current branch (for local repos)
- Supports GitHub and Bitbucket repositories
- Handles both HTTPS and SSH remote URL formats
- Accepts a local path, a remote URL, or pipeline input
- Works identically across Windows, macOS, and Linux

## Installation

Install the `Open-GitRepo` module from the PowerShell Gallery:

```powershell
Install-Module -Name Open-GitRepo
```

## Usage

Import the module within your current PowerShell session:

```powershell
Import-Module Open-GitRepo
```

### Open the current repository (default)

```powershell
Open-GitRepo
```

### Open a repository by local path

To open a repository using a local file path, use the `-Path` parameter:

```powershell
Open-GitRepo -Path /path/to/otherrepo
```

You can also use pipeline input to specify the path:

```powershell
'/path/to/otherrepo' | Open-GitRepo
```

### Open a repository by remote URL

To open a repository using a remote URL, use the `-Url` parameter:

```powershell
Open-GitRepo -Url 'https://github.com/user/repo.git'
```

For SSH URLs, simply provide the URL as you would in Git:

```powershell
Open-GitRepo -Url 'git@bitbucket.org:user/repo.git'
```

Pipeline input can also be used for remote URLs:

```powershell
'git@bitbucket.org:user/repo.git' | Open-GitRepo
```

### Use the alias (works on all platforms)

Or, you can use the `git-open` alias

> likely more familiar to those in the \*nix world - tip of the hat to [bash's git-open](https://github.com/jeffreyiacono/git-open)

_from within a repository on your local machine:_

```powershell
git-open
```

\_or pipe to it

```powershell
'https://github.com/user/repo.git' | git-open
```

## Automatic Import/Add to PowerShell Profile

To use `Open-GitRepo` without importing it every time, add it to your PowerShell profile:

1. Ensure your PowerShell profile exists:

```powershell
if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force
}
```

2. Open your profile file in any editor:

```powershell
code $PROFILE
```

3. Add this to your profile:

```powershell
Import-Module Open-GitRepo
```

## Supported Git Providers

- GitHub (github.com)
- Bitbucket (bitbucket.org)

## Requirements

- PowerShell 7.0 or later
- Git must be installed and available in your PATH
- For local paths, you must run the command from within a Git repository with an 'origin' remote configured

## Troubleshooting

If you encounter issues:

1. Ensure you're inside a Git repository: `git status` (for local paths)
2. Verify the 'origin' remote exists: `git remote -v`
3. Check that Git is installed and in your PATH: `Get-Command git`
4. For remote URLs, ensure the URL is valid and public (or you have access)

For more detailed help, see the module documentation with:

```powershell
Get-Help Open-GitRepo -Full
```
