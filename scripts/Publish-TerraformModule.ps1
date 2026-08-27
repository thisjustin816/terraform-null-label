<#
.SYNOPSIS
Validates this Terraform module and optionally publishes release tags.

.DESCRIPTION
Checks README generation, Terraform formatting, Terraform validation, and the complete Go test
suite. README generation is compared with the tracked file and restored before release state is
validated. When Version is provided, the script delegates exact and moving tag reconciliation to
Publish-ReleaseTags.ps1 after all checks pass and the working tree is clean.

.PARAMETER Version
Exact release tag in vMAJOR.MINOR.PATCH form, such as v2.0.0.

.PARAMETER Push
Pushes reconciled release tags to origin in one atomic operation.

.PARAMETER SkipReadme
Skips README generation and drift validation.

.PARAMETER SkipTerraformFormat
Skips Terraform formatting validation.

.EXAMPLE
./scripts/Publish-TerraformModule.ps1

.EXAMPLE
./scripts/Publish-TerraformModule.ps1 -Version v2.0.0 -Push
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidatePattern('^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$')]
    [string]$Version,

    [switch]$Push,

    [switch]$SkipReadme,

    [switch]$SkipTerraformFormat
)

begin {
    $ErrorActionPreference = 'Stop'

    $RepoRoot = Split-Path -Path $PSScriptRoot -Parent
    $TestRoot = Join-Path -Path $RepoRoot -ChildPath 'test/src'
    $TerraformFixtureRoot = Join-Path -Path $RepoRoot -ChildPath 'test/fixtures'
    $ReadmePath = Join-Path -Path $RepoRoot -ChildPath 'README.md'
    $ReleaseTagScriptPath = Join-Path -Path $PSScriptRoot -ChildPath 'Publish-ReleaseTags.ps1'
    $TerraformFormatTargets = @(
        '.'
        'examples'
        'exports'
    )
    $TerraformFormatTargets += Get-ChildItem -LiteralPath $TerraformFixtureRoot -Directory |
        Where-Object -FilterScript { $_.Name -cne 'v1-module' } |
        Sort-Object -Property Name |
        ForEach-Object -Process { "test/fixtures/$($_.Name)" }

    <#
    .SYNOPSIS
    Internal: Verifies that required commands are available on PATH.
    #>
    function Assert-CommandAvailable {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $true)]
            [string[]]$Name
        )

        foreach ($commandName in $Name) {
            if (-not (Get-Command -Name $commandName -CommandType Application -ErrorAction SilentlyContinue)) {
                throw "Required command '$commandName' was not found on PATH."
            }
        }
    }

    <#
    .SYNOPSIS
    Internal: Runs a native command and throws when it exits with an error.
    #>
    function Invoke-NativeCommand {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $true)]
            [string]$FilePath,

            [Parameter(Mandatory = $true)]
            [string[]]$ArgumentList,

            [Parameter(Mandatory = $true)]
            [string]$WorkingDirectory
        )

        $workingDirectoryName = Split-Path -Path $WorkingDirectory -Leaf
        $arguments = $ArgumentList -join ' '
        Write-Host "[$workingDirectoryName] $FilePath $arguments"

        Push-Location -LiteralPath $WorkingDirectory
        try {
            & $FilePath @ArgumentList
            $exitCode = $LASTEXITCODE

            if ($exitCode -ne 0) {
                throw "'$FilePath $($ArgumentList -join ' ')' failed with exit code $exitCode."
            }
        }
        finally {
            Pop-Location
        }
    }

    <#
    .SYNOPSIS
    Internal: Runs a Git command and emits normalized output lines.
    #>
    function Invoke-GitOutput {
        [CmdletBinding()]
        [OutputType([string[]])]
        param(
            [Parameter(Mandatory = $true)]
            [string[]]$ArgumentList
        )

        $output = @(& git -C $RepoRoot @ArgumentList 2>&1)
        $exitCode = $LASTEXITCODE

        if ($exitCode -ne 0) {
            $details = $output -join [Environment]::NewLine
            throw "'git $($ArgumentList -join ' ')' failed with exit code $exitCode. $details"
        }

        $output | ForEach-Object { "$_" }
    }

    <#
    .SYNOPSIS
    Internal: Verifies that the Git working tree has no uncommitted changes.
    #>
    function Assert-CleanWorkingTree {
        [CmdletBinding()]
        param()

        $status = @(Invoke-GitOutput -ArgumentList @('status', '--porcelain'))

        if ($status.Count -gt 0) {
            $details = $status -join [Environment]::NewLine
            $message = @(
                'The working tree must be clean before tagging.'
                'Regenerate docs, review changes, and commit them first.'
                $details
            ) -join [Environment]::NewLine
            throw $message
        }
    }

    <#
    .SYNOPSIS
    Internal: Regenerates README.md, checks for drift, and restores its original bytes.
    #>
    function Assert-ReadmeCurrent {
        [CmdletBinding()]
        param()

        if (-not (Test-Path -LiteralPath $ReadmePath -PathType Leaf)) {
            throw "Expected generated README '$ReadmePath' was not found."
        }

        # The .NET byte APIs preserve exact contents and remain available under PowerShell 5.1.
        [byte[]]$readmeBytes = [System.IO.File]::ReadAllBytes($ReadmePath)
        try {
            Invoke-NativeCommand `
                -FilePath 'atmos' `
                -ArgumentList @('docs', 'generate', 'readme') `
                -WorkingDirectory $RepoRoot
            Invoke-NativeCommand `
                -FilePath 'git' `
                -ArgumentList @('diff', '--exit-code', '--', 'README.md') `
                -WorkingDirectory $RepoRoot
        }
        finally {
            [System.IO.File]::WriteAllBytes($ReadmePath, $readmeBytes)
        }
    }
}

process {
    $requiredCommands = @('git', 'terraform', 'go')
    if (-not $SkipReadme) {
        $requiredCommands += 'atmos'
    }
    Assert-CommandAvailable -Name $requiredCommands

    $gitRoot = @(Invoke-GitOutput -ArgumentList @('rev-parse', '--show-toplevel'))[0]
    $resolvedGitRoot = (Resolve-Path -LiteralPath $gitRoot -ErrorAction Stop).Path
    $resolvedRepoRoot = (Resolve-Path -LiteralPath $RepoRoot -ErrorAction Stop).Path

    # PowerShell string comparisons ignore case on every platform, unlike the underlying filesystems.
    $pathComparison = if ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT) {
        [StringComparison]::OrdinalIgnoreCase
    }
    else {
        [StringComparison]::Ordinal
    }
    if (-not [string]::Equals($resolvedGitRoot, $resolvedRepoRoot, $pathComparison)) {
        throw "Script root '$resolvedRepoRoot' does not match Git root '$resolvedGitRoot'."
    }

    if (-not (Test-Path -LiteralPath $TestRoot -PathType Container)) {
        throw "Expected test directory '$TestRoot' was not found."
    }

    if (-not $SkipReadme) {
        Assert-ReadmeCurrent
    }

    if (-not $SkipTerraformFormat) {
        foreach ($formatTarget in $TerraformFormatTargets) {
            $formatArguments = @('fmt', '-check')
            if ($formatTarget -cne '.') {
                $formatArguments += @('-recursive', $formatTarget)
            }

            Invoke-NativeCommand `
                -FilePath 'terraform' `
                -ArgumentList $formatArguments `
                -WorkingDirectory $RepoRoot
        }
    }

    Invoke-NativeCommand `
        -FilePath 'terraform' `
        -ArgumentList @('init', '-backend=false', '-input=false') `
        -WorkingDirectory $RepoRoot
    Invoke-NativeCommand `
        -FilePath 'terraform' `
        -ArgumentList @('validate') `
        -WorkingDirectory $RepoRoot

    $goTestArguments = @(
        'test'
        '-count=1'
        '-timeout'
        '20m'
        '.'
    )
    Invoke-NativeCommand `
        -FilePath 'go' `
        -ArgumentList $goTestArguments `
        -WorkingDirectory $TestRoot

    if ($Version) {
        if (-not (Test-Path -LiteralPath $ReleaseTagScriptPath -PathType Leaf)) {
            throw "Release tag helper '$ReleaseTagScriptPath' was not found."
        }

        Assert-CleanWorkingTree
        $headSha = @(Invoke-GitOutput -ArgumentList @('rev-parse', 'HEAD'))[0]
        $releaseTagParameters = @{
            RepositoryPath = $RepoRoot
            Version        = $Version
            CommitSha      = $headSha
            Push           = $Push
        }

        if ($PSCmdlet.ShouldProcess($Version, "Reconcile exact and moving release tags at $headSha")) {
            & $ReleaseTagScriptPath @releaseTagParameters
        }
    }
    else {
        Write-Host 'Checks completed.'
    }
}
