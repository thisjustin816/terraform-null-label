<#
.SYNOPSIS
Runs release checks and optionally tags this Terraform module.

.DESCRIPTION
Runs the generated README step, Terraform formatting, Terraform validation, and the focused
module Go tests. When Version is provided, the script creates an annotated Git tag after the
checks pass and the working tree is clean. Release tags are immutable, so the script fails when
the requested tag already exists. Use Push to check origin and push the new tag.

After the immutable version tag is created, the script also moves the matching major.minor
rolling tag (for example v1.2) to the same commit so consumers can pin a release line
(?ref=v1.2) and pick up patches without updating the ref. The rolling tag is mutable and
force-updated; prerelease versions (such as v1.2.0-rc.1) do not move it.

.PARAMETER Version
Semver release tag to create, such as v1.0.0. If the value omits the leading v, the script adds it.

.PARAMETER Push
Verifies the release tag does not exist on origin, then pushes the new tag.

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
    Internal: Verifies that the release tag does not exist locally or on origin.
    #>
    function Assert-TagAvailable {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $true)]
            [string]$TagName,
            [switch]$CheckOrigin
        )

        $matchingTags = @(Invoke-GitOutput -ArgumentList @('tag', '--list', $TagName))

        if ($matchingTags.Count -gt 0) {
            throw "Git tag '$TagName' already exists. Release tags cannot be reused."
        }

        if ($CheckOrigin) {
            $remoteTags = @(
                Invoke-GitOutput -ArgumentList @('ls-remote', '--tags', 'origin', "refs/tags/$TagName")
            )

            if ($remoteTags.Count -gt 0) {
                throw "Git tag '$TagName' already exists on origin. Release tags cannot be reused."
            }
        }
    }

    <#
    .SYNOPSIS
    Internal: Force-moves a mutable major.minor rolling tag to a commit and optionally pushes it.

    .DESCRIPTION
    Unlike the immutable version tag, the rolling tag (for example v1.2) is expected to move to
    the latest patch on each release, so it is force-created locally and force-pushed to origin.
    #>
    function Update-RollingTag {
        [CmdletBinding(SupportsShouldProcess = $true)]
        param(
            [Parameter(Mandatory = $true)]
            [string]$RollingTag,
            [Parameter(Mandatory = $true)]
            [string]$CommitSha,
            [switch]$Push
        )

        if ($PSCmdlet.ShouldProcess($RollingTag, "Move rolling tag to $CommitSha")) {
            $tagArguments = @(
                'tag'
                '--force'
                '--annotate'
                $RollingTag
                $CommitSha
                '--message'
                "Release line $RollingTag"
            )
            Invoke-NativeCommand -FilePath 'git' -ArgumentList $tagArguments -WorkingDirectory $RepoRoot
            Write-Host "Moved rolling tag $RollingTag to $CommitSha."
        }

        if ($Push -and $PSCmdlet.ShouldProcess('origin', "Force-push rolling tag $RollingTag")) {
            Invoke-NativeCommand -FilePath 'git' `
                -ArgumentList @('push', '--force', 'origin', "refs/tags/$RollingTag") `
                -WorkingDirectory $RepoRoot
            Write-Host "Force-pushed rolling tag $RollingTag to origin."
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
        '-run'
        '^(TestExamplesResourceAware|TestLabelOrderValidation)$'
        '.'
    )
    Invoke-NativeCommand `
        -FilePath 'go' `
        -ArgumentList $goTestArguments `
        -WorkingDirectory $TestRoot

    if (-not $Version) {
        Write-Host 'Checks completed.'
        return
    }

    $tagName = $Version.StartsWith('v', [StringComparison]::OrdinalIgnoreCase) ? $Version : "v$Version"

    Assert-CleanWorkingTree
    Assert-TagAvailable -TagName $tagName -CheckOrigin:$Push

    $headSha = (Invoke-GitOutput -ArgumentList @('rev-parse', 'HEAD') | Select-Object -First 1)
    $shortHeadSha = (Invoke-GitOutput -ArgumentList @('rev-parse', '--short', 'HEAD') | Select-Object -First 1)
    $createdTag = $false

    if ($PSCmdlet.ShouldProcess($tagName, "Create annotated release tag at $shortHeadSha")) {
        Invoke-NativeCommand -FilePath 'git' `
            -ArgumentList @('tag', '--annotate', $tagName, $headSha, '--message', "Release $tagName") `
            -WorkingDirectory $RepoRoot
        $createdTag = $true
        Write-Host "Created release tag $tagName at $shortHeadSha."
    }

    if ($Push -and $createdTag -and $PSCmdlet.ShouldProcess('origin', "Push release tag $tagName")) {
        Invoke-NativeCommand `
            -FilePath 'git' `
            -ArgumentList @('push', 'origin', "refs/tags/$tagName") `
            -WorkingDirectory $RepoRoot
        Write-Host "Pushed release tag $tagName to origin."
    }
    elseif (-not $Push) {
        Write-Host "Tag push skipped. Publish with: git push origin $tagName"
    }

    # Move the major.minor rolling tag to this release. Skip prerelease/build-metadata versions
    # so a line like v1.2 only ever points at a clean patch release.
    if ($tagName -match '^(v\d+)\.(\d+)\.\d+$') {
        $rollingTag = "$($Matches[1]).$($Matches[2])"
        Update-RollingTag -RollingTag $rollingTag -CommitSha $headSha -Push:$Push
    }
}
