using module ../Output/OpenGitRepo/OpenGitRepo.psd1

BeforeAll {
    Import-Module "$PSScriptRoot/../Output/OpenGitRepo/OpenGitRepo.psm1" -Force
}

Describe 'Open-GitRepo' {
    InModuleScope -ModuleName OpenGitRepo {
        BeforeEach {
            $script:remoteUrlToTest = $null
            $script:branchToTest = 'main'
            $script:openedUrl = $null

            $script:errorOutput = @()
            Mock Write-Error {
                param($message)
                $script:errorOutput += $message
            }

            # Mock git command calls
            Mock Get-Command { return $true } # Ensure git is "found"
            Mock git {
                param($command, $subcommand, $param1, $param2, $param3)

                # assume a dir path was given
                if ($command.Contains('/')) {
                    $command = $subcommand
                    $subcommand = $param1
                    $param1 = $param2
                    $param2 = $param3
                    $param3 = $null
                }

                if ($command -eq 'remote' -and $subcommand -eq 'get-url' -and $param1 -eq 'origin') {
                    return $script:remoteUrlToTest
                }
                if ($command -eq 'rev-parse' -and $subcommand -eq '--abbrev-ref' -and $param1 -eq 'HEAD') {
                    return $script:branchToTest
                }
            }

            $actualGetContent = { Get-Content }.GetNewClosure()
            Mock Get-Content {
                param($Path)
                $p = $Path.Replace("\\", "/")

                # if path ends with .ssh\config, return a mock SSH config
                if ($p -like '*/.ssh/config') {
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
                $script:remoteUrlToTest = 'https://github.com/testuser/testrepo.git'
                $script:branchToTest = 'develop'
                Open-GitRepo
                $script:openedUrl | Should -Be 'https://github.com/testuser/testrepo/tree/develop'
            }
    
            It 'handles GitHub SSH URL' {
                $script:remoteUrlToTest = 'git@github.com:testuser/anotherrepo.git'
                $script:branchToTest = 'feature/new-thing'
                Open-GitRepo
                $script:openedUrl | Should -Be 'https://github.com/testuser/anotherrepo/tree/feature/new-thing'
            }

            It 'handles GitHub SSH URL with custom alias' {
                $script:remoteUrlToTest = 'git@my_github:testuser/customrepo.git'
                $script:branchToTest = 'hotfix/urgent-fix'
                Open-GitRepo
                $script:openedUrl | Should -Be 'https://github.com/testuser/customrepo/tree/hotfix/urgent-fix'
            }
        }
    
        Context 'Bitbucket URLs' {
            It 'handles Bitbucket HTTPS URL' {

                $script:remoteUrlToTest = 'https://user@bitbucket.org/bbuser/bbrepo.git'
                $script:branchToTest = 'master'
                # redirect stderr to stdout
                Open-GitRepo
                $script:openedUrl | Should -Be 'https://bitbucket.org/bbuser/bbrepo/src/master'
            }
    
            It 'handles Bitbucket SSH URL' {
                $script:remoteUrlToTest = 'git@bitbucket.org:bbuser/anotherbbrepo.git'
                $script:branchToTest = 'bugfix/fix-it'
                Open-GitRepo
                $script:openedUrl | Should -Be 'https://bitbucket.org/bbuser/anotherbbrepo/src/bugfix/fix-it'
            }

            It 'handles Bitbucket SSH URL with custom alias' {
                $script:remoteUrlToTest = 'git@my_bitbucket:bbuser/customrepo.git'
                $script:branchToTest = 'hotfix/urgent-fix'
                Open-GitRepo
                $script:openedUrl | Should -Be 'https://bitbucket.org/bbuser/customrepo/src/hotfix/urgent-fix'
            }
        }
    
        Context 'Error Handling' {
            It 'errors if not a git repository (no remote URL)' {
                $script:remoteUrlToTest = $null 
                Open-GitRepo
                $script:errorOutput | Should -BeLike "Could not retrieve remote 'origin' URL. Are you in a git repository with an 'origin' remote?"
            }
    
            It 'errors if current branch cannot be determined' {
                $script:remoteUrlToTest = 'https://github.com/testuser/testrepo.git'
                $script:branchToTest = $null 
                Open-GitRepo
                $script:errorOutput | Should -BeLike "Could not retrieve current branch. Are you in a git repository?"
            }
    
            It 'errors for unsupported URL format' {
                $script:remoteUrlToTest = 'https://gitlab.com/testuser/testrepo.git'
                Open-GitRepo
                $script:errorOutput | Should -BeLike "Unsupported Git provider: gitlab.com"
            }
        }

        Context 'Parameter Options' {
            It 'opens repo by -Path parameter' {
                $script:remoteUrlToTest = 'https://github.com/testuser/testrepo.git'
                $script:branchToTest = 'main'
                Open-GitRepo -Path '/some/path/to/repo'
                $script:openedUrl | Should -Be 'https://github.com/testuser/testrepo/tree/main'
            }
            It 'opens repo by -Url parameter (GitHub)' {
                Open-GitRepo -Url 'https://github.com/testuser/testrepo.git'
                $script:openedUrl | Should -Be 'https://github.com/testuser/testrepo/tree/main'
            }
            It 'opens repo by -Url parameter (Bitbucket)' {
                Open-GitRepo -Url 'git@bitbucket.org:bbuser/bbrepo.git'
                $script:openedUrl | Should -Be 'https://bitbucket.org/bbuser/bbrepo/src/main'
            }
            It 'opens repo by pipeline path' {
                $script:remoteUrlToTest = 'https://github.com/testuser/testrepo.git'
                $script:branchToTest = 'main'
                '/some/path/to/repo' | Open-GitRepo
                $script:openedUrl | Should -Be 'https://github.com/testuser/testrepo/tree/main'
            }
            It 'opens repo by pipeline URL (GitHub)' {
                'https://github.com/testuser/testrepo.git' | Open-GitRepo
                $script:openedUrl | Should -Be 'https://github.com/testuser/testrepo/tree/main'
            }
            It 'opens repo by pipeline URL (Bitbucket)' {
                'git@bitbucket.org:bbuser/bbrepo.git' | Open-GitRepo
                $script:openedUrl | Should -Be 'https://bitbucket.org/bbuser/bbrepo/src/main'
            }
            It 'opens repo by default (current directory)' {
                $script:remoteUrlToTest = 'https://github.com/testuser/testrepo.git'
                $script:branchToTest = 'main'
                Open-GitRepo
                $script:openedUrl | Should -Be 'https://github.com/testuser/testrepo/tree/main'
            }
            It 'errors for invalid input' {
                Open-GitRepo -Url 'https://gitlab.com/testuser/testrepo.git'
                $script:errorOutput | Should -Be 'Unsupported Git provider: gitlab.com'
            }
        }
    }
}
