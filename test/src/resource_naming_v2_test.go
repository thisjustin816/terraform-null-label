package test

import (
	"path/filepath"
	"regexp"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type resourceNamingV2Golden struct {
	Codes                   map[string]string             `json:"codes"`
	Logical                 map[string]string             `json:"logical"`
	Normal                  map[string]string             `json:"normal"`
	Hashed                  map[string]string             `json:"hashed"`
	Errors                  map[string][]string           `json:"errors"`
	Rules                   map[string]resourceRuleGolden `json:"rules"`
	AbsentFromPhysicalNames []string                      `json:"absent_from_physical_names"`
	Aliases                 map[string]string             `json:"aliases"`
	LegacyAliases           map[string]string             `json:"legacy_aliases"`
}

type resourceRuleGolden struct {
	Code         string `json:"code"`
	CodePosition string `json:"code_position"`
	HashPolicy   string `json:"hash_policy"`
}

func TestResourceNamingV2Integration(t *testing.T) {
	t.Parallel()

	terraformOptions := resourceNamingV2TerraformOptions(t)
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	contract := requireMap(t, terraform.OutputAll(t, terraformOptions), "contract")
	golden := readJSONFile[resourceNamingV2Golden](t, goldenFilePath(t, "resource-names-v2.json"))

	assert.Equal(t, "platform-Orders-api", contract["base_id"])
	assert.Equal(t, "745beb9e", contract["hash"])

	assert.Equal(t, true, contract["physical_name_key_sets_equal"])

	codes := requireMap(t, contract, "codes")
	logical := requireMap(t, contract, "logical")
	normal := requireMap(t, contract, "normal")
	hashed := requireMap(t, contract, "hashed")
	errorsByKey := requireMap(t, contract, "errors")
	rules := requireMap(t, contract, "rules")

	assert.Equal(t, stringMapToAny(golden.Codes), codes)
	assert.Equal(t, stringMapToAny(golden.Logical), logical)
	assert.Equal(t, stringMapToAny(golden.Normal), normal)
	assert.Equal(t, stringMapToAny(golden.Hashed), hashed)

	for key, expected := range golden.Errors {
		assert.Equal(t, expected, interfaceListStrings(t, errorsByKey[key]), key)
	}
	absentFromPhysicalNames := requireMap(t, contract, "absent_from_physical_names")
	for _, key := range golden.AbsentFromPhysicalNames {
		assert.Equal(t, true, absentFromPhysicalNames[key], key)
	}

	for key, expected := range golden.Rules {
		rule := requireMap(t, rules, key)
		assert.Equal(t, expected.Code, rule["code"], key)
		assert.Equal(t, expected.CodePosition, rule["code_position"], key)
		assert.Equal(t, expected.HashPolicy, rule["hash_policy"], key)
	}

	aliases := requireMap(t, contract, "aliases")
	assertSelectedStringMap(t, golden.Aliases, aliases)
	assert.Equal(t, hashed["azure_key_vault"], aliases["key_vault"])
	assert.Equal(t, hashed["azure_storage_account"], aliases["storage_account"])
	assert.NotEqual(t, normal["azure_key_vault"], aliases["key_vault"])
	assert.NotEqual(t, normal["azure_storage_account"], aliases["storage_account"])

	legacy := requireMap(t, contract, "legacy")
	legacyAliases := requireMap(t, legacy, "aliases")
	assertSelectedStringMap(t, golden.LegacyAliases, legacyAliases)
	assert.Equal(t, "eec9d15d", legacy["hash"])
	assert.NotEqual(t, legacy["hash"], contract["hash"])
	for key := range golden.Aliases {
		assert.Equal(t, stripFinalHexHash(t, golden.LegacyAliases[key]), stripFinalHexHash(t, golden.Aliases[key]), key)
	}
}

func resourceNamingV2TerraformOptions(t testing.TB) *terraform.Options {
	t.Helper()

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(
		t,
		"../../",
		filepath.ToSlash(filepath.Join("test", "fixtures", "resource-naming-v2")),
	)

	return &terraform.Options{TerraformDir: tempTestFolder, NoColor: true}
}

func assertSelectedStringMap(t testing.TB, expected map[string]string, actual map[string]any) {
	t.Helper()

	for key, value := range expected {
		assert.Equal(t, value, actual[key], key)
	}
}

func stripFinalHexHash(t testing.TB, value string) string {
	t.Helper()

	pattern := regexp.MustCompile(`[0-9a-f]{8}$`)
	require.True(t, pattern.MatchString(value), value)

	return pattern.ReplaceAllString(value, "")
}

func stringMapToAny(values map[string]string) map[string]any {
	result := make(map[string]any, len(values))
	for key, value := range values {
		result[key] = value
	}

	return result
}
