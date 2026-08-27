package test

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"reflect"
	"regexp"
	"runtime"
	"sort"
	"testing"

	"github.com/stretchr/testify/require"
)

const (
	v1FixtureCommit    = "895f056322e93c44d51d46547bd90f426b525ed3"
	v1FixtureTag       = "v1.2.2"
	v1FixtureTagObject = "e438758f24ebb4dbb55a9011b884ec8f60b49710"
)

var expectedV1FixtureFiles = map[string]string{
	"LICENSE":                  "312a41e78641004a3f88a41b90f5b549ca0244b2b2d555ca768fe98c3e895f85",
	"codes.aws.regions.tf":     "3354ec836c855328eddb86ad4b2c2cb7acae9cd4312594e6ad0f2826276161b9",
	"codes.aws.resources.tf":   "088e1caf94a7a54e4702a7d24d113401c54224faacc77caed4def25755e28e60",
	"codes.azure.regions.tf":   "4e351a7edbf6fa1f5162c72dd2ade2bcce2e3f0ac9998e56a2bec3bb9c9f7a53",
	"codes.azure.resources.tf": "9f642ef61a71b69a1ce367cd53ee5b94d925e4a69e9166e844dd37839a4a3a4e",
	"codes.environment.tf":     "43e81743a10ef4c147102f49e5ab73301c38bb4e4fa4fab6836b5f70ceb08286",
	"defaults.tf":              "f5b6d24cec30ce5b81b1ba7450888477daad6ec83696d94c414c7869ccb37fae",
	"descriptors.tf":           "da0619345688b93d7dd07c86a74907970f2228be0ac7f60309b5cbac2abff92c",
	"main.tf":                  "51991b9480ce95d70e5855ca2a931502b0c868f5fd76a68f6371a419adf9eb6b",
	"outputs.tf":               "4dcda28e84dbd5e995da828825e88663192232b6e0b953870f2c5d7cd2b7e123",
	"resource-label-rules.tf":  "9c3bcff54c3a7d9ffcfcb394b06a02aefaf748cddd941ef39a9ecd721d23d215",
	"resource-labels.tf":       "a417b9748ceb83d3f227613d116baeb13519ef96ade47906e65f57f343da7794",
	"serialization.tf":         "dfcc66cbf9a16b0225112351c6e670968b9b7838c5578ed06b4bc4592f927ffc",
	"variables.tf":             "4d1253592619bb1d134e4b50af39e3cd78de690ea513826e13e8ae7fbc64de46",
	"versions.tf":              "e014d8a4a98eac13b4d0d657d0bd9d068c7ba6ed1ac4bb2d97de7ef14318af29",
}

type fixtureManifest struct {
	Tag          string            `json:"tag"`
	TagObject    string            `json:"tag_object"`
	Commit       string            `json:"commit"`
	RuntimeFiles map[string]string `json:"runtime_files"`
}

func repositoryRoot(t testing.TB) string {
	t.Helper()

	_, sourceFile, _, ok := runtime.Caller(0)
	require.True(t, ok, "resolve test source path")

	root, err := filepath.Abs(filepath.Join(filepath.Dir(sourceFile), "../.."))
	require.NoError(t, err)

	return root
}

func v1FixtureDirectory(t testing.TB) string {
	t.Helper()

	return filepath.Join(repositoryRoot(t), "test", "fixtures", "v1-module")
}

func v1AzureResourceCodes(t testing.TB) map[string]string {
	t.Helper()

	content, err := os.ReadFile(filepath.Join(v1FixtureDirectory(t), "codes.azure.resources.tf"))
	require.NoError(t, err)

	assignmentPattern := regexp.MustCompile(`(?m)^[\t ]+([a-z0-9_]+)[\t ]+=[\t ]+"([^"]+)"`)
	matches := assignmentPattern.FindAllStringSubmatch(string(content), -1)
	require.Len(t, matches, 226)

	codes := make(map[string]string, len(matches))
	for _, match := range matches {
		key := match[1]
		_, duplicate := codes[key]
		require.False(t, duplicate, "duplicate Azure v1 resource-code key %s", key)
		codes[key] = match[2]
	}

	require.Equal(t, "st", codes["storage_account"])
	require.Equal(t, "amr", codes["azure_managed_redis"])

	return codes
}

func v1AzureResourceCodeKeys(t testing.TB) []string {
	t.Helper()

	return sortedMapKeys(v1AzureResourceCodes(t))
}

func goldenFilePath(t testing.TB, name string) string {
	t.Helper()

	return filepath.Join(repositoryRoot(t), "test", "golden", name)
}

func readJSONFile[T any](t testing.TB, path string) T {
	t.Helper()

	file, err := os.Open(path)
	require.NoError(t, err)
	defer file.Close()

	decoder := json.NewDecoder(file)
	decoder.DisallowUnknownFields()

	var value T
	require.NoError(t, decoder.Decode(&value))

	var trailing any
	err = decoder.Decode(&trailing)
	require.ErrorIs(t, err, io.EOF, "JSON file must contain exactly one value")

	return value
}

func writeTestFile(t testing.TB, directory string, name string, content []byte) {
	t.Helper()

	require.NoError(t, os.MkdirAll(directory, 0o755))
	require.NoError(t, os.WriteFile(filepath.Join(directory, name), content, 0o644))
}

func validateV1Fixture(fixtureDirectory string) error {
	manifest, err := readFixtureManifest(filepath.Join(fixtureDirectory, "manifest.json"))
	if err != nil {
		return err
	}

	if manifest.Tag != v1FixtureTag {
		return fmt.Errorf("fixture tag is %q, want %q", manifest.Tag, v1FixtureTag)
	}
	if manifest.TagObject != v1FixtureTagObject {
		return fmt.Errorf("fixture tag object is %q, want %q", manifest.TagObject, v1FixtureTagObject)
	}
	if manifest.Commit != v1FixtureCommit {
		return fmt.Errorf("fixture commit is %q, want %q", manifest.Commit, v1FixtureCommit)
	}
	if !reflect.DeepEqual(manifest.RuntimeFiles, expectedV1FixtureFiles) {
		return fmt.Errorf("fixture manifest runtime file set or checksums differ from the v1.2.2 snapshot")
	}

	actualFiles, err := fixtureRuntimeFiles(fixtureDirectory)
	if err != nil {
		return err
	}

	expectedPaths := sortedMapKeys(expectedV1FixtureFiles)
	for _, path := range expectedPaths {
		if _, ok := actualFiles[path]; !ok {
			return fmt.Errorf("missing runtime file %q", path)
		}
	}

	actualPaths := sortedSetKeys(actualFiles)
	for _, path := range actualPaths {
		if _, ok := expectedV1FixtureFiles[path]; !ok {
			return fmt.Errorf("unexpected runtime file %q", path)
		}
	}

	for _, path := range expectedPaths {
		content, readErr := os.ReadFile(filepath.Join(fixtureDirectory, filepath.FromSlash(path)))
		if readErr != nil {
			return fmt.Errorf("read runtime file %q: %w", path, readErr)
		}

		sum := sha256.Sum256(content)
		actualHash := hex.EncodeToString(sum[:])
		if actualHash != expectedV1FixtureFiles[path] {
			return fmt.Errorf("checksum mismatch for runtime file %q: got %s", path, actualHash)
		}
	}

	return nil
}

func readFixtureManifest(path string) (fixtureManifest, error) {
	file, err := os.Open(path)
	if err != nil {
		return fixtureManifest{}, fmt.Errorf("read fixture manifest: %w", err)
	}
	defer file.Close()

	decoder := json.NewDecoder(file)
	decoder.DisallowUnknownFields()

	var manifest fixtureManifest
	if err = decoder.Decode(&manifest); err != nil {
		return fixtureManifest{}, fmt.Errorf("decode fixture manifest: %w", err)
	}

	var trailing any
	if err = decoder.Decode(&trailing); err != io.EOF {
		return fixtureManifest{}, fmt.Errorf("fixture manifest must contain exactly one JSON value")
	}

	return manifest, nil
}

func fixtureRuntimeFiles(root string) (map[string]struct{}, error) {
	files := make(map[string]struct{})
	err := filepath.WalkDir(root, func(path string, entry fs.DirEntry, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}
		if entry.IsDir() {
			return nil
		}

		relativePath, relativeErr := filepath.Rel(root, path)
		if relativeErr != nil {
			return relativeErr
		}
		relativePath = filepath.ToSlash(relativePath)
		if relativePath != "manifest.json" {
			files[relativePath] = struct{}{}
		}

		return nil
	})
	if err != nil {
		return nil, fmt.Errorf("enumerate fixture runtime files: %w", err)
	}

	return files, nil
}

func copyDirectory(source string, destination string) error {
	return filepath.WalkDir(source, func(path string, entry fs.DirEntry, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}

		relativePath, err := filepath.Rel(source, path)
		if err != nil {
			return err
		}
		targetPath := filepath.Join(destination, relativePath)

		if entry.IsDir() {
			return os.MkdirAll(targetPath, 0o755)
		}

		content, err := os.ReadFile(path)
		if err != nil {
			return err
		}

		return os.WriteFile(targetPath, content, 0o644)
	})
}

func sortedMapKeys(values map[string]string) []string {
	keys := make([]string, 0, len(values))
	for key := range values {
		keys = append(keys, key)
	}
	sort.Strings(keys)

	return keys
}

func sortedSetKeys(values map[string]struct{}) []string {
	keys := make([]string, 0, len(values))
	for key := range values {
		keys = append(keys, key)
	}
	sort.Strings(keys)

	return keys
}
