package test

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestV1FixtureIntegrity(t *testing.T) {
	require.NoError(t, validateV1Fixture(v1FixtureDirectory(t)))
}

func TestV1FixtureIntegrityRejectsDrift(t *testing.T) {
	testCases := []struct {
		name        string
		wantMessage string
		mutate      func(*testing.T, string)
	}{
		{
			name:        "changed runtime file",
			wantMessage: "checksum mismatch",
			mutate: func(t *testing.T, fixtureDirectory string) {
				path := filepath.Join(fixtureDirectory, "LICENSE")
				content, err := os.ReadFile(path)
				require.NoError(t, err)
				content = append(content, byte('\n'))
				require.NoError(t, os.WriteFile(path, content, 0o644))
			},
		},
		{
			name:        "missing runtime file",
			wantMessage: "missing runtime file",
			mutate: func(t *testing.T, fixtureDirectory string) {
				require.NoError(t, os.Remove(filepath.Join(fixtureDirectory, "versions.tf")))
			},
		},
		{
			name:        "extra runtime file",
			wantMessage: "unexpected runtime file",
			mutate: func(t *testing.T, fixtureDirectory string) {
				writeTestFile(t, fixtureDirectory, "extra.tf", []byte("terraform {}\n"))
			},
		},
	}

	for _, testCase := range testCases {
		t.Run(testCase.name, func(t *testing.T) {
			fixtureCopy := filepath.Join(t.TempDir(), "v1-module")
			require.NoError(t, copyDirectory(v1FixtureDirectory(t), fixtureCopy))
			require.NoError(t, validateV1Fixture(fixtureCopy))

			testCase.mutate(t, fixtureCopy)

			err := validateV1Fixture(fixtureCopy)
			require.Error(t, err)
			assert.Contains(t, err.Error(), testCase.wantMessage)
		})
	}
}
