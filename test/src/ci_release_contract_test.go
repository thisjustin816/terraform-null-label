package test

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestCIPublishingContracts(t *testing.T) {
	t.Run("CI runs the complete matrix with optional gates on the newest Terraform", func(t *testing.T) {
		workflow := readRepositoryText(t, ".github", "workflows", "branch.yml")

		assert.Contains(t, workflow, "terraform-version:\n          - 1.3.2\n          - 1.15.8")
		assert.Contains(t, workflow, "terraform_version: ${{ matrix.terraform-version }}")
		assert.Contains(t, workflow, "if: matrix.terraform-version == '1.15.8'")
		assert.Contains(t, workflow, "uses: cloudposse/github-action-setup-atmos@v3.5.0")
		assert.Contains(t, workflow, "atmos-version: 1.216.0")
		assert.Contains(t, workflow, "RUN_OPTIONAL_GATES: ${{ matrix.terraform-version == '1.15.8' }}")
		assert.Contains(t, workflow, "./scripts/Publish-TerraformModule.ps1")
		assert.Contains(t, workflow, "./scripts/Publish-TerraformModule.ps1 -SkipReadme -SkipTerraformFormat")
	})

	t.Run("publisher runs all tests and restores README before release state validation", func(t *testing.T) {
		script := readRepositoryText(t, "scripts", "Publish-TerraformModule.ps1")

		assert.Contains(t, script, "[switch]$SkipTerraformFormat")
		assert.NotContains(t, script, "'-run'")
		assert.NotContains(t, script, "TestExamplesResourceAware|TestLabelOrderValidation")
		assert.Contains(t, script, "'examples'")
		assert.Contains(t, script, "'exports'")
		assert.Contains(t, script, "Get-ChildItem -LiteralPath $TerraformFixtureRoot -Directory")
		assert.Contains(t, script, "$_.Name -cne 'v1-module'")
		assert.Contains(t, script, "\"test/fixtures/$($_.Name)\"")
		assert.NotContains(t, script, "'test/fixtures/v1-module'")
		assert.Contains(t, script, "$formatArguments = @('fmt', '-check')")
		assert.NotContains(t, script, "@('fmt', '-check', '-recursive')")
		assert.Contains(t, script, "[System.IO.File]::ReadAllBytes($ReadmePath)")
		assert.Contains(t, script, "[System.IO.File]::WriteAllBytes($ReadmePath, $readmeBytes)")
		assert.Contains(t, script, "@('diff', '--exit-code', '--', 'README.md')")
		assert.Contains(t, script, "finally {")
		assert.Contains(t, script, "Publish-ReleaseTags.ps1")

		snapshotIndex := strings.Index(script, "[System.IO.File]::ReadAllBytes($ReadmePath)")
		generateIndex := strings.Index(script, "@('docs', 'generate', 'readme')")
		diffIndex := strings.Index(script, "@('diff', '--exit-code', '--', 'README.md')")
		restoreIndex := strings.Index(script, "[System.IO.File]::WriteAllBytes($ReadmePath, $readmeBytes)")
		cleanTreeIndex := strings.LastIndex(script, "Assert-CleanWorkingTree")
		require.NotEqual(t, -1, snapshotIndex)
		require.NotEqual(t, -1, generateIndex)
		require.NotEqual(t, -1, diffIndex)
		require.NotEqual(t, -1, restoreIndex)
		require.NotEqual(t, -1, cleanTreeIndex)
		assert.Less(t, snapshotIndex, generateIndex)
		assert.Less(t, generateIndex, diffIndex)
		assert.Less(t, diffIndex, restoreIndex)
		assert.Less(t, restoreIndex, cleanTreeIndex)

		fixtureEntries, err := os.ReadDir(filepath.Join(repositoryRoot(t), "test", "fixtures"))
		require.NoError(t, err)
		formatTargets := make([]string, 0, len(fixtureEntries))
		for _, entry := range fixtureEntries {
			if entry.IsDir() && entry.Name() != "v1-module" {
				formatTargets = append(formatTargets, filepath.ToSlash(filepath.Join("test", "fixtures", entry.Name())))
			}
		}

		assert.Contains(t, formatTargets, "test/fixtures/context-v2-to-v2")
		assert.NotContains(t, formatTargets, "test/fixtures/v1-module")
	})

	t.Run("release reruns provision and validate before the optional GitHub Release", func(t *testing.T) {
		workflow := readRepositoryText(t, ".github", "workflows", "release.yml")

		assert.Contains(t, workflow, "RELEASE_MAJOR: 2")
		assert.Contains(t, workflow, "RELEASE_MINOR: 0")
		assert.NotContains(t, workflow, "tag_required")

		terraformStep := workflowStep(t, workflow, "Set up Terraform")
		goStep := workflowStep(t, workflow, "Set up Go")
		atmosStep := workflowStep(t, workflow, "Set up Atmos")
		publishStep := workflowStep(t, workflow, "Validate module and publish tag")
		releaseStep := workflowStep(t, workflow, "Create GitHub Release")

		assert.NotContains(t, terraformStep, "if:")
		assert.NotContains(t, goStep, "if:")
		assert.NotContains(t, atmosStep, "if:")
		assert.NotContains(t, publishStep, "if:")
		assert.Contains(t, atmosStep, "uses: cloudposse/github-action-setup-atmos@v3.5.0")
		assert.Contains(t, atmosStep, "atmos-version: 1.216.0")
		assert.Contains(t, publishStep, "./scripts/Publish-TerraformModule.ps1 -Version $env:VERSION -Push")
		assert.Contains(t, releaseStep, "if: steps.release.outputs.release_required == 'true'")
		assert.Equal(t, 1, strings.Count(workflow, "steps.release.outputs.release_required"))
	})
}

func readRepositoryText(t testing.TB, pathComponents ...string) string {
	t.Helper()

	path := filepath.Join(append([]string{repositoryRoot(t)}, pathComponents...)...)
	content, err := os.ReadFile(path)
	require.NoError(t, err)

	return strings.ReplaceAll(string(content), "\r\n", "\n")
}

func workflowStep(t testing.TB, workflow string, name string) string {
	t.Helper()

	marker := "      - name: " + name
	start := strings.Index(workflow, marker)
	require.NotEqual(t, -1, start, "workflow step %q was not found", name)

	remainder := workflow[start:]
	nextStep := strings.Index(remainder[len(marker):], "\n      - name: ")
	if nextStep >= 0 {
		remainder = remainder[:len(marker)+nextStep]
	}

	return remainder
}
