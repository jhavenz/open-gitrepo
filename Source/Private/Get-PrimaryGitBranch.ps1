function Get-PrimaryGitBranch {
    return git config --list 
    | Where-Object { $_ -like 'branch.*.merge=*' } 
    | ForEach-Object { $_ -replace '^(.+)=(refs/heads/)?', '' } 
    | Select-Object -First 1
}