package test

import (
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestExportContextContract(t *testing.T) {
	t.Parallel()

	root := repositoryRoot(t)
	rootVariables := readTextFile(t, filepath.Join(root, "variables.tf"))
	exportContext := readTextFile(t, filepath.Join(root, "exports", "context.tf"))

	const sectionStart = "# Copy contents of this fork's variables.tf here"
	const sectionEnd = "#### End of copy of this fork's variables.tf"
	start := strings.Index(exportContext, sectionStart)
	end := strings.Index(exportContext, sectionEnd)
	require.GreaterOrEqual(t, start, 0)
	require.Greater(t, end, start)
	copiedVariables := strings.TrimSpace(exportContext[start+len(sectionStart) : end])
	assert.Equal(t, strings.TrimSpace(rootVariables), copiedVariables)

	variablePattern := regexp.MustCompile(`(?m)^variable "([^"]+)"`)
	rootNames := regexpCaptureSet(variablePattern, rootVariables)
	exportNames := regexpCaptureSet(variablePattern, copiedVariables)
	assert.Len(t, rootNames, 25)
	assert.Equal(t, rootNames, exportNames)

	moduleEnd := strings.Index(exportContext, "\n}\n\n# Copy contents")
	require.Greater(t, moduleEnd, 0)
	moduleText := exportContext[:moduleEnd]
	forwardPattern := regexp.MustCompile(`(?m)^\s+([a-z_]+)\s+=\s+var\.([a-z_]+)\s*$`)
	forwarded := make(map[string]struct{})
	for _, match := range forwardPattern.FindAllStringSubmatch(moduleText, -1) {
		assert.Equal(t, match[1], match[2])
		forwarded[match[1]] = struct{}{}
	}
	assert.Equal(t, rootNames, forwarded)

	assert.Contains(t, exportContext, "git::https://github.com/thisjustin816/terraform-null-label.git?ref=v2.0.0")
	assert.NotContains(t, exportContext, "ref=main")
	assert.NotContains(t, exportContext, "id_resource")
	assert.NotContains(t, exportContext, "id_resource_unique")
}

func TestRemovedV1ResourceNamingSurface(t *testing.T) {
	t.Parallel()

	root := repositoryRoot(t)
	patterns := []string{"id_resource", "id_resource_unique", "globally_unique", "include_region"}
	detector := regexp.MustCompile(`\b(?:` + strings.Join(patterns, "|") + `)\b`)
	for _, pattern := range patterns {
		assert.True(t, detector.MatchString("probe "+pattern+" probe"), pattern)
	}

	paths := make([]string, 0)
	rootFiles, err := filepath.Glob(filepath.Join(root, "*.tf"))
	require.NoError(t, err)
	paths = append(paths, rootFiles...)
	for _, directory := range []string{"examples", "exports"} {
		err = filepath.WalkDir(filepath.Join(root, directory), func(path string, entry os.DirEntry, walkErr error) error {
			if walkErr != nil {
				return walkErr
			}
			if !entry.IsDir() && filepath.Ext(path) == ".tf" {
				paths = append(paths, path)
			}
			return nil
		})
		require.NoError(t, err)
	}

	for _, path := range paths {
		content := readTextFile(t, path)
		assert.Empty(t, detector.FindAllString(content, -1), path)
	}
}

func v1AWSResourceCodes(t testing.TB) map[string]string {
	t.Helper()

	content := readTextFile(t, filepath.Join(v1FixtureDirectory(t), "codes.aws.resources.tf"))
	assignmentPattern := regexp.MustCompile(`(?m)^\s+(aws_[a-z0-9_]+)\s+=\s+"([^"]+)"`)
	matches := assignmentPattern.FindAllStringSubmatch(content, -1)
	require.Len(t, matches, 74)

	codes := make(map[string]string, len(matches))
	for _, match := range matches {
		require.NotContains(t, codes, match[1])
		codes[match[1]] = match[2]
	}

	return codes
}

func readTextFile(t testing.TB, path string) string {
	t.Helper()

	content, err := os.ReadFile(path)
	require.NoError(t, err)

	return strings.ReplaceAll(string(content), "\r\n", "\n")
}

func regexpCaptureSet(pattern *regexp.Regexp, value string) map[string]struct{} {
	result := make(map[string]struct{})
	for _, match := range pattern.FindAllStringSubmatch(value, -1) {
		result[match[1]] = struct{}{}
	}

	return result
}
