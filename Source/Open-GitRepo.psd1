@{
    # Script module or binary module file associated with this manifest.
    RootModule             = "Open-GitRepo.psm1"

    # Version number of this module.
    ModuleVersion          = '0.0.9'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    # ID used to uniquely identify this module
    GUID                   = 'e97baff3-c359-4f8e-8e5d-3385914a3052'

    # Author of this module
    Author                 = 'JonathanHavens'

    # Company or vendor of this module
    CompanyName            = 'jhavenz'

    # Copyright statement for this module
    Copyright              = '(c) Jonathan Havens 2025. All rights reserved.'

    # Description of the functionality provided by this module
    Description            = 'Open a browser to the current git repository'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion      = '7.0'

    # Name of the PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the PowerShell host required by this module
    PowerShellHostVersion  = '7.0'

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    DotNetFrameworkVersion = '8.0'

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # ClrVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    ScriptsToProcess       = @(
        #
    )

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    NestedModules          = @(
        #
    )

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport      = @(
        #
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport        = @(
        'Open-GitRepo'
    )

    # Variables to export from this module
    # VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport        = @(
        'ogr',
        'git-open',
        'gitopen',
        'git-browse',
        'gitbrowse'
    )

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    ModuleList             = @(
        #
    )

    # List of all files packaged with this module
    FileList               = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData            = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags                       = @(
                'git',
                'github',
                'bitbucket',
                'git',
                'git-open'
            )

            # A URL to the license for this module.
            LicenseUri                 = 'https://github.com/jhavenz/open-gitrepo/tree/main/Lisense.txt'

            # A URL to the main website for this project.
            ProjectUri                 = 'https://github.com/jhavenz/open-gitrepo/tree/main'

            # A URL to an icon representing this module.
            IconUri                    = 'https://github.com/jhavenz/open-gitrepo/tree/main/icon.png'

            # ReleaseNotes of this module
            ReleaseNotes               = 'Initial release'

            # Prerelease string of this module
            # Prerelease                 = ''

            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            RequireLicenseAcceptance   = $true

            # External dependent modules of this module
            ExternalModuleDependencies = @(
                #
            )

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    HelpInfoURI            = 'https://github.com/jhavenz/open-gitrepo/tree/main/en-US/about_Open-GitRepo.help.txt'

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}
