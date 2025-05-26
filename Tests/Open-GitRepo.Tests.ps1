using module ../Output/Open-GitRepo/Open-GitRepo.psd1

BeforeAll {
    Import-Module "$PSScriptRoot/../Output/Open-GitRepo/Open-GitRepo.psm1" -Force
}

Describe 'Open-GitRepo' {
    InModuleScope -ModuleName Open-GitRepo {
        BeforeEach {
            # used to assert the URL that command would open
            $script:openedUrl = $null

            # used to assert error output
            $script:errorOutput = @()
            Mock Write-Error {
                param($message)
                $script:errorOutput += $message
            }

            $actualGetContent = { Get-Content }.GetNewClosure()
            Mock Get-Content {
                param($Path)
                $p = Resolve-NormalizedPath [string]$Path

                $sshConfigPath = Join-Path '*' '.ssh' 'config'

                # if path ends with .ssh/config, return a mock SSH config
                if ($p -like $sshConfigPath) {
                    return @(
                        "Host my_github",
                        "    HostName github.com",
                        "    User git",
                        "Host my_bitbucket",
                        "    HostName bitbucket.org",
                        "    User git"
                    )
                }

                return $actualGetContent.Invoke($Path)
            }

            Mock Start-Process { 
                $script:openedUrl = $args.Count -eq 1 ? $args[0] : $args[1]
            }
        }
        
        Context 'GitHub URLs' {
            It 'handles GitHub HTTPS URL' {
                # For GitHub, it shouldn't matter if we're on the primary branch or not
                # The url conventions are the same (which is greatly appreciated GitHub!)
                Mock Get-GitRemoteUrl { 'https://github.com/testuser/testrepo.git' }
                Mock Get-PrimaryGitBranch { 'main' }
                Mock Get-GitCurrentBranch { 'develop' }

                Open-GitRepo
                $script:openedUrl | Should -Be 'https://github.com/testuser/testrepo/tree/develop'
            }
    
            It 'handles GitHub SSH URL' {
                Mock Get-GitRemoteUrl { 'git@github.com:testuser/anotherrepo.git' }
                Mock Get-PrimaryGitBranch { 'main' }
                Mock Get-GitCurrentBranch { 'feature/new-thing' }

                Open-GitRepo
                $script:openedUrl | Should -Be 'https://github.com/testuser/anotherrepo/tree/feature/new-thing'
            }

            It 'handles GitHub SSH URL with custom alias' {
                Mock Get-GitRemoteUrl { 'git@my_github:testuser/customrepo.git' }
                Mock Get-PrimaryGitBranch { 'main' }
                Mock Get-GitCurrentBranch { 'hotfix/urgent-fix' }

                Open-GitRepo
                $script:openedUrl | Should -Be 'https://github.com/testuser/customrepo/tree/hotfix/urgent-fix'
            }
        }
    
        Context 'Bitbucket URLs' {
            It 'handles Bitbucket HTTPS URL on the primary branch' {
                # when using a 
                Mock Get-PrimaryGitBranch { 'main' }
                Mock Get-GitRemoteUrl { 'https://user@bitbucket.org/bbworkspace/bbrepo.git' }
                Mock Get-GitCurrentBranch { 'main' }

                Open-GitRepo
                $script:openedUrl | Should -Be 'https://bitbucket.org/bbworkspace/bbrepo/src/main'
            }
            
            It 'handles Bitbucket HTTPS URL on a secondary branch' {
                Mock Get-PrimaryGitBranch { 'main' }
                Mock Get-GitRemoteUrl { 'https://user@bitbucket.org/bbworkspace/bbrepo.git' }
                Mock Get-GitCurrentBranch { 'hotfix/my_branch' }
                Mock Get-GitBranchWithCommitHash {
                    [PSCustomObject]@{
                        Branch     = 'hotfix/my_branch'
                        CommitHash = 'acc31fe8745678bc987b123d87d7ac72fec220e52'
                    }
                }

                Open-GitRepo
                $script:openedUrl | Should -Be 'https://bitbucket.org/bbworkspace/bbrepo/src/acc31fe8745678bc987b123d87d7ac72fec220e52/?at=hotfix/my_branch'
            }
    
            It 'handles Bitbucket SSH URL on the primary branch' {
                Mock Get-PrimaryGitBranch { 'main' }
                Mock Get-GitRemoteUrl { 'https://user@bitbucket.org/bbworkspace/bbrepo.git' }
                Mock Get-GitCurrentBranch { 'main' }

                Open-GitRepo
                $script:openedUrl | Should -Be 'https://bitbucket.org/bbworkspace/bbrepo/src/main'
            }
            
            It 'handles Bitbucket SSH URL on a secondary branch' {
                Mock Get-PrimaryGitBranch { 'main' }
                Mock Get-GitRemoteUrl { 'git@bitbucket.org:bbworkspace/bbrepo.git' }
                Mock Get-GitCurrentBranch { 'quickfix/fix_a_typo' }
                Mock Get-GitBranchWithCommitHash {
                    [PSCustomObject]@{
                        Branch     = 'quickfix/fix_a_typo'
                        CommitHash = 'acc31fe8745678bc987b123d87d7ac72fec220e52'
                    }
                }

                Open-GitRepo
                $script:openedUrl | Should -Be 'https://bitbucket.org/bbworkspace/bbrepo/src/acc31fe8745678bc987b123d87d7ac72fec220e52/?at=quickfix/fix_a_typo'
            }

            It 'handles Bitbucket SSH URL with custom alias on the primary branch' {
                Mock Get-PrimaryGitBranch { 'main' }
                Mock Get-GitRemoteUrl { 'git@my_bitbucket:bbworkspace/customrepo.git' }
                Mock Get-GitCurrentBranch { 'main' }

                Open-GitRepo
                $script:openedUrl | Should -Be 'https://bitbucket.org/bbworkspace/customrepo/src/main'
            }
            
            It 'handles Bitbucket SSH URL with custom alias on a secondary branch' {
                Mock Get-PrimaryGitBranch { 'main' }
                Mock Get-GitRemoteUrl { 'git@my_bitbucket:bbworkspace/customrepo.git' }
                Mock Get-GitCurrentBranch { 'hotfix/fix_urgently' }
                Mock Get-GitBranchWithCommitHash {
                    [PSCustomObject]@{
                        Branch     = 'hotfix/fix_urgently'
                        CommitHash = 'acc31fe8745678bc987b123d87d7ac72fec220e52'
                    }
                }

                Open-GitRepo
                $script:openedUrl | Should -Be 'https://bitbucket.org/bbworkspace/customrepo/src/acc31fe8745678bc987b123d87d7ac72fec220e52/?at=hotfix/fix_urgently'
            }
        }
    
        Context 'Error Handling' {
            It 'errors if not a git repository (no remote URL)' {
                Mock Get-GitRemoteUrl { $null }
                Mock Get-GitCurrentBranch { 'main' }

                Open-GitRepo
                $script:errorOutput | Should -BeLike "Could not determine a URL for the remote repository. Have you run 'git remote add origin <url>'?"
            }
    
            It 'errors if current branch cannot be determined' {
                Mock Get-GitRemoteUrl { 'https://github.com/testuser/testrepo.git' }
                Mock Get-GitCurrentBranch { $null }

                Open-GitRepo
                $script:errorOutput | Should -BeLike "Could not determine the current branch. Are you in a git repository?"
            }
    
            It 'errors for unsupported URL format' {
                Mock Get-GitRemoteUrl { 'https://gitlab.com/testuser/testrepo.git' }
                Mock Get-GitCurrentBranch { 'main' }
                Mock Get-GitBranchWithCommitHash { 
                    [PSCustomObject]@{
                        Branch     = 'main'
                        CommitHash = 'abc123'
                    }
                }

                Open-GitRepo
                $script:errorOutput | Should -BeLike "Unsupported Git provider: gitlab.com"
            }
        }

        Context 'Parameter Options' {
            It 'opens repo by -Path parameter' {
                Mock Get-GitRemoteUrl { 'https://github.com/testuser/testrepo.git' }
                Mock Get-GitCurrentBranch { 'main' }

                Open-GitRepo -Path '/some/path/to/repo'
                $script:openedUrl | Should -Be 'https://github.com/testuser/testrepo/tree/main'
            }
            It 'opens repo by -Url parameter (GitHub)' {
                Open-GitRepo -Url 'https://github.com/testuser/testrepo.git'
                $script:openedUrl | Should -Be 'https://github.com/testuser/testrepo/tree/main'
            }
            It 'opens the primary repo by -Url parameter (Bitbucket)' {
                Mock Get-GitRemoteUrl { 'https://github.com/testuser/testrepo.git' }
                Mock Get-PrimaryGitBranch { 'main' }
                Mock Get-GitCurrentBranch { 'main' }
                Mock Get-GitBranchWithCommitHash { 
                    [PSCustomObject]@{
                        Branch     = 'main'
                        CommitHash = 'abc123'
                    }
                }

                Open-GitRepo -Url 'git@bitbucket.org:bbuser/bbrepo.git'
                $script:openedUrl | Should -Be 'https://bitbucket.org/bbuser/bbrepo/src/main'
            }
            
            It 'opens a secondary repo by -Url parameter (Bitbucket)' {
                Mock Get-GitRemoteUrl { 'https://github.com/testuser/testrepo.git' }
                Mock Get-PrimaryGitBranch { 'main' }
                Mock Get-GitCurrentBranch { 'hotfix/fix_me' }
                Mock Get-GitBranchWithCommitHash { 
                    [PSCustomObject]@{
                        Branch     = 'hotfix/fix_me'
                        CommitHash = 'abc123'
                    }
                }

                Open-GitRepo -Url 'git@bitbucket.org:bbuser/bbrepo.git'
                $script:openedUrl | Should -Be 'https://bitbucket.org/bbuser/bbrepo/src/abc123/?at=hotfix/fix_me'
            }

            It 'opens repo by pipeline path' {
                Mock Get-GitRemoteUrl { 'https://github.com/testuser/testrepo.git' }
                Mock Get-GitCurrentBranch { 'main' }

                '/some/path/to/repo' | Open-GitRepo
                $script:openedUrl | Should -Be 'https://github.com/testuser/testrepo/tree/main'
            }
            It 'opens repo by pipeline URL (GitHub)' {
                'https://github.com/testuser/testrepo.git' | Open-GitRepo
                $script:openedUrl | Should -Be 'https://github.com/testuser/testrepo/tree/main'
            }
            It 'opens the primary repo by pipeline URL (Bitbucket)' {
                Mock Get-GitRemoteUrl { 'git@bitbucket.org:bbuser/bbrepo.git' }
                Mock Get-PrimaryGitBranch { 'main' }
                Mock Get-GitCurrentBranch { 'main' }

                'git@bitbucket.org:bbuser/bbrepo.git' | Open-GitRepo
                $script:openedUrl | Should -Be 'https://bitbucket.org/bbuser/bbrepo/src/main'
            }
            
            It 'opens a secondary repo by pipeline URL (Bitbucket)' {
                Mock Get-GitRemoteUrl { 'git@bitbucket.org:bbuser/bbrepo.git' }
                Mock Get-PrimaryGitBranch { 'main' }
                Mock Get-GitCurrentBranch { 'feature/all_out' }
                Mock Get-GitBranchWithCommitHash { 
                    [PSCustomObject]@{
                        Branch     = 'feature/all_out'
                        CommitHash = 'abc123'
                    }
                }

                'git@bitbucket.org:bbuser/bbrepo.git' | Open-GitRepo
                $script:openedUrl | Should -Be 'https://bitbucket.org/bbuser/bbrepo/src/abc123/?at=feature/all_out'
            }

            It 'opens repo by default (current directory)' {
                Mock Get-GitRemoteUrl { 'https://github.com/testuser/testrepo.git' }
                Mock Get-GitCurrentBranch { 'main' }

                Open-GitRepo
                $script:openedUrl | Should -Be 'https://github.com/testuser/testrepo/tree/main'
            }
            It 'errors for invalid input' {
                Mock Get-GitRemoteUrl { 'https://gitlab.com/testuser/testrepo.git' }
                Mock Get-GitCurrentBranch { 'main' }
                
                Open-GitRepo -Url 'https://gitlab.com/testuser/testrepo.git'
                $script:errorOutput | Should -BeLike 'Unsupported Git provider: gitlab.com'
            }
        }
    }
}
