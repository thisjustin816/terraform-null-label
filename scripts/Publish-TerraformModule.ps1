<#
.SYNOPSIS
Runs release checks and optionally tags this Terraform module.

.DESCRIPTION
Runs the generated README step, Terraform formatting, Terraform validation, and the focused
resource-aware Go test. When Version is provided, the script creates an annotated Git tag after
the checks pass and the working tree is clean. Use Push to push the tag to origin.

.PARAMETER Version
Semver release tag to create, such as v1.0.0. If the value omits the leading v, the script adds it.

.PARAMETER Push
Pushes the release tag to origin after creating it.

.PARAMETER SkipReadme
Skips README generation with Atmos.

.EXAMPLE
./scripts/Publish-TerraformModule.ps1

.EXAMPLE
./scripts/Publish-TerraformModule.ps1 -Version v1.0.0 -Push
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidatePattern('^v?\d+\.\d+\.\d+(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$')]
    [string]$Version,
    [switch]$Push,
    [switch]$SkipReadme
)

begin {
    $ErrorActionPreference = 'Stop'

    $RepoRoot = Split-Path -Path $PSScriptRoot -Parent
    $TestRoot = Join-Path -Path $RepoRoot -ChildPath 'test/src'

    <#
    .SYNOPSIS
    Internal: Verifies that required commands are available on PATH.
    #>
    function Assert-CommandExists {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $true)]
            [string[]]$Name
        )

        foreach ($commandName in $Name) {
            if (-not (Get-Command -Name $commandName -ErrorAction SilentlyContinue)) {
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
            [string] $WorkingDirectory
        )

        $workingDirectoryName = Split-Path -Path $WorkingDirectory -Leaf
        $arguments = $ArgumentList -join ' '

        Write-Host "[$workingDirectoryName] $FilePath $arguments"

        Push-Location -LiteralPath $WorkingDirectory
        try {
            & $FilePath @ArgumentList

            if ($LASTEXITCODE -ne 0) {
                throw "'$FilePath $($ArgumentList -join ' ')' failed with exit code $LASTEXITCODE."
            }
        }
        finally {
            Pop-Location
        }
    }

    <#
    .SYNOPSIS
    Internal: Runs a Git command and emits its output.
    #>
    function Invoke-GitOutput {
        [CmdletBinding()]
        [OutputType([string[]])]
        param(
            [Parameter(Mandatory = $true)]
            [string[]]$ArgumentList
        )

        Push-Location -LiteralPath $RepoRoot
        try {
            $output = & git @ArgumentList 2>&1

            if ($LASTEXITCODE -ne 0) {
                throw "'git $($ArgumentList -join ' ')' failed: $output"
            }

            $output
        }
        finally {
            Pop-Location
        }
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
    Internal: Verifies that the release tag does not already exist.
    #>
    function Assert-TagAvailable {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $true)]
            [string]$TagName
        )

        $matchingTags = @(Invoke-GitOutput -ArgumentList @('tag', '--list', $TagName))

        if ($matchingTags.Count -gt 0) {
            throw "Git tag '$TagName' already exists."
        }
    }
}

process {
    $requiredCommands = @('git', 'terraform', 'go')

    if (-not $SkipReadme) {
        $requiredCommands += 'atmos'
    }

    Assert-CommandExists -Name $requiredCommands

    $gitRoot = (Invoke-GitOutput -ArgumentList @('rev-parse', '--show-toplevel') | Select-Object -First 1)
    $resolvedGitRoot = (Resolve-Path -LiteralPath $gitRoot).Path
    $resolvedRepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path

    if ($resolvedGitRoot -ne $resolvedRepoRoot) {
        throw "Script root '$resolvedRepoRoot' does not match Git root '$resolvedGitRoot'."
    }

    if (-not (Test-Path -LiteralPath $TestRoot -PathType Container)) {
        throw "Expected test directory '$TestRoot' was not found."
    }

    if (-not $SkipReadme) {
        Invoke-NativeCommand `
            -FilePath 'atmos' `
            -ArgumentList @('docs', 'generate', 'readme') `
            -WorkingDirectory $RepoRoot
    }

    Invoke-NativeCommand `
        -FilePath 'terraform' `
        -ArgumentList @('fmt', '-check', '-recursive') `
        -WorkingDirectory $RepoRoot
    Invoke-NativeCommand `
        -FilePath 'terraform' `
        -ArgumentList @('init', '-backend=false') `
        -WorkingDirectory $RepoRoot
    Invoke-NativeCommand `
        -FilePath 'terraform' `
        -ArgumentList @('validate') `
        -WorkingDirectory $RepoRoot
    Invoke-NativeCommand `
        -FilePath 'go' `
        -ArgumentList @('test', '-count=1', '-timeout', '20m', '-run', '^TestExamplesResourceAware$', '.') `
        -WorkingDirectory $TestRoot

    if (-not $Version) {
        Write-Host 'Checks completed.'
        return
    }

    $tagName = $Version.StartsWith('v', [StringComparison]::OrdinalIgnoreCase) ? $Version : "v$Version"

    Assert-CleanWorkingTree
    Assert-TagAvailable -TagName $tagName

    $headSha = (Invoke-GitOutput -ArgumentList @('rev-parse', '--short', 'HEAD') | Select-Object -First 1)
    $createdTag = $false

    if ($PSCmdlet.ShouldProcess($tagName, "Create annotated release tag at $headSha")) {
        Invoke-NativeCommand -FilePath 'git' `
            -ArgumentList @('tag', '-a', $tagName, '-m', "Release $tagName") `
            -WorkingDirectory $RepoRoot
        $createdTag = $true
        Write-Host "Created release tag $tagName at $headSha."
    }

    if ($Push -and $createdTag -and $PSCmdlet.ShouldProcess('origin', "Push release tag $tagName")) {
        Invoke-NativeCommand -FilePath 'git' -ArgumentList @('push', 'origin', $tagName) -WorkingDirectory $RepoRoot
        Write-Host "Pushed release tag $tagName to origin."
    }
    elseif (-not $Push) {
        Write-Host "Tag push skipped. Publish with: git push origin $tagName"
    }
}
