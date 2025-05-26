function Resolve-NormalizedPath {
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [string]$BasePath = (Get-Location).Path
    )

    # Expand tilde to home directory
    if ($Path -like '~*') {
        $Path = $Path -replace '^~', $env:HOME
    }

    if (-not [System.IO.Path]::IsPathRooted($Path)) {
        $Path = [System.IO.Path]::Combine($BasePath, $Path)
    }

    try {
        $resolved = [System.IO.Path]::GetFullPath($Path)
    }
    catch {
        $resolved = $Path
    }
    return $resolved
}