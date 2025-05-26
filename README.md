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
- Test coverage (based on confidence, not line coverage)
- Resolves ssh config aliases ()

## Requirements

- PowerShell 7.0 or later
- Git must be installed and available in your PATH (Windows users can download [here](https://git-scm.com/downloads/win))

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

_To have this module available in all your PowerShell sessions, you'll want to add it to your PowerShell profile. See the [Automatic Import/Add to PowerShell Profile](#automatic-importadd-to-powershell-profile) section below for details._

> **A Note On Bitbucket Usage**

> In other related packages, you'll notice the Bitbucket handling gets a little more complicated, which is because Bitbucket uses commit hashes in their URLs. They also have a different url for the 'default' branch, as opposed to any secondary branches.
> **This module simplifies takes care of all this for you.** > **If it sees your remote URL is a Bitbucket repository, it will resolve the URL by looking up these details for you.**

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

### Command Aliases

`ogr`, `git-open`, `gitopen`, `git-browse`, `gitbrowse`

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

## SSH Config Aliases

If your `~/.ssh/config` has entries that look something like this:

```plaintext
Host gh-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_work

Host gh-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_personal
```

Then you use a git remote that looks something like this: `origin git@gh-work:testuser/customrepo.git`.

This works as you'd expect.

This module knows how to resolve these SSH config aliases while generating the URL to your git repository.

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

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a new branch for your feature or fix
3. Make your changes and commit them
4. Push to your branch
5. Create a pull request with a clear description of your changes
   6, ensure your code has test coverage with passing tests
6. Create a PR to merge into the `main` branch

## License

This project is licensed under the MIT License. See the [LICENSE](./Source/License.txt) file for details.
