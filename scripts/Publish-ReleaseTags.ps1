<#
.SYNOPSIS
Reconciles exact and moving release tags for one commit.

.DESCRIPTION
Validates an exact vMAJOR.MINOR.PATCH release tag and its moving vMAJOR.MINOR tag in a local
repository and on a configured remote. Exact tags are immutable. A matching remote exact tag is
fetched so its annotated tag object is preserved. The moving tag is reconciled to the intended
commit.

With Push, both refs are sent in one atomic Git push. A remote rejection therefore leaves both
remote refs unchanged.

.PARAMETER RepositoryPath
Path to the root of the working Git repository.

.PARAMETER Version
Exact release tag in vMAJOR.MINOR.PATCH form, such as v2.0.0.

.PARAMETER CommitSha
Full 40-character SHA of the commit the release tags must target.

.PARAMETER RemoteName
Git remote to inspect and update. The default is origin.

.PARAMETER Push
Pushes the exact and moving refs to the remote when reconciliation is required.

.OUTPUTS
None.

.EXAMPLE
./scripts/Publish-ReleaseTags.ps1 -RepositoryPath $PWD -Version v2.0.0 -CommitSha $commitSha -Push
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$RepositoryPath,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$')]
    [string]$Version,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[0-9a-fA-F]{40}$')]
    [string]$CommitSha,

    [ValidatePattern('^(?!-)[^\s]+$')]
    [string]$RemoteName = 'origin',

    [switch]$Push
)

begin {
    $ErrorActionPreference = 'Stop'

    <#
    .SYNOPSIS
    Internal: Runs Git in a repository and emits normalized output lines.
    #>
    function Invoke-GitOutput {
        [CmdletBinding()]
        [OutputType([string[]])]
        param(
            [Parameter(Mandatory = $true)]
            [string]$WorkingDirectory,

            [Parameter(Mandatory = $true)]
            [string[]]$ArgumentList
        )

        $output = @(& git -C $WorkingDirectory @ArgumentList 2>&1)
        $exitCode = $LASTEXITCODE

        if ($exitCode -ne 0) {
            $details = $output -join [Environment]::NewLine
            throw "'git $($ArgumentList -join ' ')' failed with exit code $exitCode. $details"
        }

        $output | ForEach-Object { "$_" }
    }

    <#
    .SYNOPSIS
    Internal: Gets the annotated-tag object and peeled commit for a local tag.
    #>
    function Get-LocalTagState {
        [CmdletBinding()]
        [OutputType([pscustomobject])]
        param(
            [Parameter(Mandatory = $true)]
            [string]$WorkingDirectory,

            [Parameter(Mandatory = $true)]
            [string]$TagName
        )

        $reference = "refs/tags/$TagName"
        $records = @(
            Invoke-GitOutput `
                -WorkingDirectory $WorkingDirectory `
                -ArgumentList @('for-each-ref', '--format=%(objectname)|%(objecttype)', $reference)
        )

        if ($records.Count -gt 1) {
            throw "Git returned multiple local records for tag '$TagName'."
        }

        $exists = $records.Count -eq 1
        $objectId = $null
        $commitId = $null
        $annotated = $false

        if ($exists) {
            $parts = $records[0] -split '\|', 2
            if ($parts.Count -ne 2) {
                throw "Git returned an invalid local record for tag '$TagName': $($records[0])"
            }

            $objectId = $parts[0].ToLowerInvariant()
            $annotated = $parts[1] -ceq 'tag'
            try {
                $commitId = @(
                    Invoke-GitOutput `
                        -WorkingDirectory $WorkingDirectory `
                        -ArgumentList @('rev-parse', '--verify', "$reference^{commit}")
                )[0].ToLowerInvariant()
            }
            catch {
                $tagError = $_
                throw "Local tag '$TagName' cannot be peeled to a commit. $($tagError.Exception.Message)"
            }
        }

        [pscustomobject]@{
            Exists    = $exists
            ObjectId  = $objectId
            CommitId  = $commitId
            Annotated = $annotated
        }
    }

    <#
    .SYNOPSIS
    Internal: Gets the annotated-tag object and peeled commit advertised by a remote.
    #>
    function Get-RemoteTagState {
        [CmdletBinding()]
        [OutputType([pscustomobject])]
        param(
            [Parameter(Mandatory = $true)]
            [string]$WorkingDirectory,

            [Parameter(Mandatory = $true)]
            [string]$Remote,

            [Parameter(Mandatory = $true)]
            [string]$TagName
        )

        $reference = "refs/tags/$TagName"
        $peeledReference = ($reference + '^{}')
        $lines = @(
            Invoke-GitOutput `
                -WorkingDirectory $WorkingDirectory `
                -ArgumentList @('ls-remote', '--tags', $Remote, $reference, $peeledReference)
        )
        $objectId = $null
        $commitId = $null

        foreach ($line in $lines) {
            $parts = $line -split "`t", 2
            if ($parts.Count -ne 2) {
                throw "Git returned an invalid remote record for tag '$TagName': $line"
            }

            if ($parts[1] -ceq $reference) {
                $objectId = $parts[0].ToLowerInvariant()
            }
            elseif ($parts[1] -ceq $peeledReference) {
                $commitId = $parts[0].ToLowerInvariant()
            }
        }

        $exists = $null -ne $objectId
        $annotated = $null -ne $commitId
        if ($exists -and -not $annotated) {
            $commitId = $objectId
        }

        [pscustomobject]@{
            Exists    = $exists
            ObjectId  = $objectId
            CommitId  = $commitId
            Annotated = $annotated
        }
    }

    <#
    .SYNOPSIS
    Internal: Enforces the immutable exact-tag contract for one tag location.
    #>
    function Assert-ExactTagState {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $true)]
            [pscustomobject]$State,

            [Parameter(Mandatory = $true)]
            [string]$Location,

            [Parameter(Mandatory = $true)]
            [string]$TagName,

            [Parameter(Mandatory = $true)]
            [string]$IntendedCommit
        )

        if ($State.Exists -and $State.CommitId -cne $IntendedCommit) {
            throw (
                "$Location exact tag '$TagName' targets commit '$($State.CommitId)', " +
                "but the intended commit is '$IntendedCommit'. Exact tags are immutable."
            )
        }

        if ($State.Exists -and -not $State.Annotated) {
            throw "$Location exact tag '$TagName' is lightweight. Exact release tags must be annotated."
        }
    }
}

process {
    if (-not (Get-Command -Name 'git' -CommandType Application -ErrorAction SilentlyContinue)) {
        throw "Required command 'git' was not found on PATH."
    }

    if (-not (Test-Path -LiteralPath $RepositoryPath -PathType Container)) {
        throw "RepositoryPath '$RepositoryPath' does not identify an existing directory."
    }

    $resolvedRepositoryPath = (Resolve-Path -LiteralPath $RepositoryPath -ErrorAction Stop).Path
    $gitRoot = @(
        Invoke-GitOutput `
            -WorkingDirectory $resolvedRepositoryPath `
            -ArgumentList @('rev-parse', '--show-toplevel')
    )[0]
    $resolvedGitRoot = (Resolve-Path -LiteralPath $gitRoot -ErrorAction Stop).Path

    # PowerShell string comparisons ignore case on every platform, unlike the underlying filesystems.
    $pathComparison = if ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT) {
        [StringComparison]::OrdinalIgnoreCase
    }
    else {
        [StringComparison]::Ordinal
    }
    if (-not [string]::Equals($resolvedRepositoryPath, $resolvedGitRoot, $pathComparison)) {
        throw "RepositoryPath '$resolvedRepositoryPath' must be the Git root '$resolvedGitRoot'."
    }

    $remoteNames = @(Invoke-GitOutput -WorkingDirectory $resolvedRepositoryPath -ArgumentList @('remote'))
    if ($remoteNames -cnotcontains $RemoteName) {
        throw "Git remote '$RemoteName' does not exist in '$resolvedRepositoryPath'."
    }

    $normalizedCommitSha = $CommitSha.ToLowerInvariant()
    try {
        $commitObjectType = @(
            Invoke-GitOutput `
                -WorkingDirectory $resolvedRepositoryPath `
                -ArgumentList @('cat-file', '-t', $normalizedCommitSha)
        )[0]
    }
    catch {
        $commitError = $_
        throw (
            "CommitSha '$normalizedCommitSha' does not exist in '$resolvedRepositoryPath'. " +
            $commitError.Exception.Message
        )
    }

    if ($commitObjectType -cne 'commit') {
        throw "CommitSha '$normalizedCommitSha' identifies a '$commitObjectType' object, not a commit."
    }

    $versionComponents = $Version.Substring(1).Split('.')
    $movingTag = "v$($versionComponents[0]).$($versionComponents[1])"
    $exactReference = "refs/tags/$Version"
    $movingReference = "refs/tags/$movingTag"

    $remoteExact = Get-RemoteTagState `
        -WorkingDirectory $resolvedRepositoryPath `
        -Remote $RemoteName `
        -TagName $Version
    $remoteMoving = Get-RemoteTagState `
        -WorkingDirectory $resolvedRepositoryPath `
        -Remote $RemoteName `
        -TagName $movingTag
    $localExact = Get-LocalTagState -WorkingDirectory $resolvedRepositoryPath -TagName $Version
    $localMoving = Get-LocalTagState -WorkingDirectory $resolvedRepositoryPath -TagName $movingTag

    Assert-ExactTagState `
        -State $remoteExact `
        -Location "Remote '$RemoteName'" `
        -TagName $Version `
        -IntendedCommit $normalizedCommitSha
    Assert-ExactTagState `
        -State $localExact `
        -Location 'Local' `
        -TagName $Version `
        -IntendedCommit $normalizedCommitSha

    $localTagsReady = $true
    if ($remoteExact.Exists -and $localExact.ObjectId -cne $remoteExact.ObjectId) {
        $fetchAction = "Fetch annotated exact tag object $($remoteExact.ObjectId) from '$RemoteName'"
        if ($PSCmdlet.ShouldProcess($exactReference, $fetchAction)) {
            $exactFetchRefspec = "${exactReference}:${exactReference}"
            $null = Invoke-GitOutput `
                -WorkingDirectory $resolvedRepositoryPath `
                -ArgumentList @('fetch', '--force', '--no-tags', $RemoteName, $exactFetchRefspec)
            $localExact = Get-LocalTagState -WorkingDirectory $resolvedRepositoryPath -TagName $Version
        }
        else {
            $localTagsReady = $false
        }
    }
    elseif (-not $localExact.Exists) {
        if ($PSCmdlet.ShouldProcess($exactReference, "Create annotated exact tag at $normalizedCommitSha")) {
            $null = Invoke-GitOutput `
                -WorkingDirectory $resolvedRepositoryPath `
                -ArgumentList @(
                'tag',
                '--annotate',
                $Version,
                $normalizedCommitSha,
                '--message',
                "Release $Version"
            )
            $localExact = Get-LocalTagState -WorkingDirectory $resolvedRepositoryPath -TagName $Version
        }
        else {
            $localTagsReady = $false
        }
    }

    $remoteMovingIsCurrent = (
        $remoteMoving.Exists -and
        $remoteMoving.Annotated -and
        $remoteMoving.CommitId -ceq $normalizedCommitSha
    )
    $localMovingIsCurrent = (
        $localMoving.Exists -and
        $localMoving.Annotated -and
        $localMoving.CommitId -ceq $normalizedCommitSha
    )

    if ($remoteMovingIsCurrent -and $localMoving.ObjectId -cne $remoteMoving.ObjectId) {
        $fetchAction = "Fetch annotated moving tag object $($remoteMoving.ObjectId) from '$RemoteName'"
        if ($PSCmdlet.ShouldProcess($movingReference, $fetchAction)) {
            $movingFetchRefspec = "${movingReference}:${movingReference}"
            $null = Invoke-GitOutput `
                -WorkingDirectory $resolvedRepositoryPath `
                -ArgumentList @('fetch', '--force', '--no-tags', $RemoteName, $movingFetchRefspec)
            $localMoving = Get-LocalTagState -WorkingDirectory $resolvedRepositoryPath -TagName $movingTag
        }
        else {
            $localTagsReady = $false
        }
    }
    elseif (-not $remoteMovingIsCurrent -and -not $localMovingIsCurrent) {
        if ($PSCmdlet.ShouldProcess($movingReference, "Reconcile annotated moving tag at $normalizedCommitSha")) {
            $null = Invoke-GitOutput `
                -WorkingDirectory $resolvedRepositoryPath `
                -ArgumentList @(
                'tag',
                '--force',
                '--annotate',
                $movingTag,
                $normalizedCommitSha,
                '--message',
                "Release line $movingTag"
            )
            $localMoving = Get-LocalTagState -WorkingDirectory $resolvedRepositoryPath -TagName $movingTag
        }
        else {
            $localTagsReady = $false
        }
    }

    if ($localTagsReady) {
        Assert-ExactTagState `
            -State $localExact `
            -Location 'Local' `
            -TagName $Version `
            -IntendedCommit $normalizedCommitSha

        $localMovingIsCurrent = (
            $localMoving.Exists -and
            $localMoving.Annotated -and
            $localMoving.CommitId -ceq $normalizedCommitSha
        )
        if (-not $localMovingIsCurrent) {
            throw "Local moving tag '$movingTag' was not reconciled to commit '$normalizedCommitSha'."
        }
    }

    if ($Push) {
        $pushRequired = (
            $localTagsReady -and
            (
                $remoteExact.ObjectId -cne $localExact.ObjectId -or
                $remoteMoving.ObjectId -cne $localMoving.ObjectId
            )
        )

        if ($pushRequired) {
            $pushAction = "Atomically publish $Version and $movingTag"
            if ($PSCmdlet.ShouldProcess($RemoteName, $pushAction)) {
                $exactPushRefspec = "${exactReference}:${exactReference}"
                $movingPushRefspec = "+${movingReference}:${movingReference}"
                $null = Invoke-GitOutput `
                    -WorkingDirectory $resolvedRepositoryPath `
                    -ArgumentList @(
                    'push',
                    '--atomic',
                    $RemoteName,
                    $exactPushRefspec,
                    $movingPushRefspec
                )

                $remoteExact = Get-RemoteTagState `
                    -WorkingDirectory $resolvedRepositoryPath `
                    -Remote $RemoteName `
                    -TagName $Version
                $remoteMoving = Get-RemoteTagState `
                    -WorkingDirectory $resolvedRepositoryPath `
                    -Remote $RemoteName `
                    -TagName $movingTag
                if (
                    $remoteExact.ObjectId -cne $localExact.ObjectId -or
                    $remoteMoving.ObjectId -cne $localMoving.ObjectId
                ) {
                    throw "Remote '$RemoteName' did not advertise the expected release tag objects after push."
                }
            }
        }
        elseif ($localTagsReady) {
            Write-Verbose "Remote '$RemoteName' already has the intended exact and moving tag objects."
        }
    }
}
