function Get-SshAliasHostnameUrl {
    param([string]$SshAlias)
    $location = Join-Path $env:HOME ".ssh" "config"
    
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