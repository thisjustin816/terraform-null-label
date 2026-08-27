package test

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"regexp"
	"sort"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestResourceRenderer(t *testing.T) {
	t.Parallel()

	terraformOptions := resourceRendererTerraformOptions(t, map[string]any{
		"required_resource_names": []string{"structured"},
	})
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	firstOutputs := terraform.OutputAll(t, terraformOptions)
	terraform.Apply(t, terraformOptions)
	secondOutputs := terraform.OutputAll(t, terraformOptions)
	assert.Equal(t, firstOutputs, secondOutputs, "renderer output must be deterministic across reruns")

	names := requireMap(t, firstOutputs, "resource_name")
	hashedNames := requireMap(t, firstOutputs, "resource_name_hashed")
	errorsByKey := requireMap(t, firstOutputs, "resource_name_errors")

	require.ElementsMatch(t, mapKeys(names), mapKeys(hashedNames), "normal and forced-hash maps must have one joint key set")
	assert.Equal(t, "platform-Orders-api", firstOutputs["base_id"], "base ID remains on the v1 normalization path")

	digest := rendererHashDigest(t)
	hash8 := digest[:8]
	hash4 := digest[:4]
	assert.Equal(t, hash8, firstOutputs["resource_hash"])

	expectedNormal := map[string]string{
		"structured":         "platform/orders-api",
		"code_prefix":        "svc-platform-orders-api",
		"code_suffix":        "platform-orders-api-svc",
		"code_none":          "platform-orders-api",
		"empty_delimiters":   "svcplatformordersapi",
		"alias_prefix":       "alias/platform-orders-api",
		"fifo_suffix":        "platform-orders-api.fifo",
		"policy_never":       "platform-orders-api",
		"policy_when_needed": "platform-orders-api",
		"policy_always":      "platform-orders-api-" + hash8,
		"minimum_recovery":   hash8,
		"truncation_retrim":  "platform-" + hash4,
		"global_hash_fit":    hash8,
		"per_rule_hash_fit":  hash4,
		"hash_seed_peer":     "othercode-platform-orders-api-" + hash8,
	}
	for resourceKey, expected := range expectedNormal {
		assert.Equal(t, expected, names[resourceKey], resourceKey)
	}

	assert.Equal(t, "platform-orders-api-"+hash8, hashedNames["policy_never"])
	assert.Equal(t, "platform-orders-api-"+hash8, hashedNames["policy_when_needed"])
	assert.Equal(t, "alias/platform-orders-api-"+hash8, hashedNames["alias_prefix"])
	assert.Equal(t, "platform-orders-api-"+hash8+".fifo", hashedNames["fifo_suffix"])
	assert.Equal(t, names["policy_always"], hashedNames["policy_always"])
	assert.Equal(t, names["minimum_recovery"], hashedNames["minimum_recovery"])
	assert.Equal(t, names["truncation_retrim"], hashedNames["truncation_retrim"])
	assert.Equal(t, hash8, rendererHashSuffix(t, hashedNames["hash_seed_peer"].(string)))
	assert.Equal(t, hash8, rendererHashSuffix(t, hashedNames["policy_always"].(string)))

	filteredHash := regexp.MustCompile(`[^A-F]`).ReplaceAllString(strings.ToUpper(digest[:32]), "")
	require.NotEmpty(t, filteredHash)
	assert.Equal(t, filteredHash, names["hash_upper_filtered"])
	assert.Equal(t, filteredHash, hashedNames["hash_upper_filtered"])

	omittedKeys := []string{
		"hash_transformed_empty",
		"forbidden_fail",
		"final_regex_fail",
		"joint_omission",
		"hash_affix_conflict",
		"never_overflow",
	}
	for _, resourceKey := range omittedKeys {
		require.NotContains(t, names, resourceKey)
		require.NotContains(t, hashedNames, resourceKey)
		require.Contains(t, errorsByKey, resourceKey)
	}

	assertErrorContains(t, errorsByKey, "hash_transformed_empty", "hash is empty after transformation")
	assertErrorContains(t, errorsByKey, "forbidden_fail", "forbidden pattern")
	assertErrorContains(t, errorsByKey, "final_regex_fail", "final regex")
	assertErrorContains(t, errorsByKey, "joint_omission", "hashed candidate")
	assertErrorContains(t, errorsByKey, "hash_affix_conflict", "hash and required affixes exceed max_length")
	assertErrorContains(t, errorsByKey, "never_overflow", "normal candidate exceeds max_length")
}

func TestResourceRendererNormalizesCodeLookups(t *testing.T) {
	t.Parallel()

	outputs := resourceRendererOutputs(t, map[string]any{
		"region":      "US-WEST-2",
		"environment": "PROD",
	})

	assert.Equal(t, "usw2", outputs["base_region_code"])
	assert.Equal(t, "p", outputs["base_environment_code"])
	assert.Equal(t, "usw2-p", requireMap(t, outputs, "resource_name")["normalized_codes"])
}

func TestResourceRendererOmitsCodesWhenNormalizedLookupsMiss(t *testing.T) {
	t.Parallel()

	outputs := resourceRendererOutputs(t, map[string]any{
		"region":      "CUSTOM-REGION",
		"environment": "CUSTOM-ENVIRONMENT",
		"region_codes": map[string]any{
			"CUSTOM-REGION": "customregion",
		},
		"environment_codes": map[string]any{
			"CUSTOM-ENVIRONMENT": "customenvironment",
		},
	})

	assert.Empty(t, outputs["base_region_code"])
	assert.Empty(t, outputs["base_environment_code"])
	require.NotContains(t, requireMap(t, outputs, "resource_name"), "normalized_codes")
	require.Contains(t, requireMap(t, outputs, "resource_name_errors"), "normalized_codes")
}

func TestResourceRendererHashSeedRetainsRawRegionWhenRuleOmitsRegion(t *testing.T) {
	t.Parallel()

	outputs := resourceRendererOutputs(t, map[string]any{
		"region": "US-WEST-2",
	})

	expectedHash := rendererHashDigestForLabels(t, "US-WEST-2", "")[:8]
	assert.NotEqual(t, rendererHashDigest(t)[:8], expectedHash)
	assert.Equal(t, expectedHash, outputs["resource_hash"])

	name := requireMap(t, outputs, "resource_name")["policy_always"].(string)
	body := strings.TrimSuffix(name, "-"+expectedHash)
	assert.Equal(t, "platform-orders-api", body)
}

func TestResourceRendererGlobalAndPerRuleHashLengths(t *testing.T) {
	t.Parallel()

	terraformOptions := resourceRendererTerraformOptions(t, map[string]any{
		"resource_hash_length": 16,
	})
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	outputs := terraform.OutputAll(t, terraformOptions)
	names := requireMap(t, outputs, "resource_name")
	errorsByKey := requireMap(t, outputs, "resource_name_errors")

	require.NotContains(t, names, "global_hash_fit")
	require.Contains(t, names, "per_rule_hash_fit")
	assert.Equal(t, rendererHashDigest(t)[:4], names["per_rule_hash_fit"])
	assertErrorContains(t, errorsByKey, "global_hash_fit", "hash and required affixes exceed max_length")
}

func TestResourceRendererIncompleteCallerRule(t *testing.T) {
	t.Parallel()

	terraformOptions := resourceRendererTerraformOptions(t, map[string]any{
		"extra_resource_label_rules": map[string]any{
			"incomplete_service": map[string]any{
				"code_position": "prefix",
			},
		},
	})

	_, err := terraform.InitAndPlanE(t, terraformOptions)
	require.Error(t, err)
	message := strings.Join(strings.Fields(err.Error()), " ")
	assert.Contains(t, message, "Incomplete renderable resource_label_rules")
	assert.Contains(t, message, "incomplete_service")
	assert.Contains(t, message, "min_length")
	assert.Contains(t, message, "max_length")
	assert.Contains(t, message, "validation_regex")
}

func TestResourceRendererRequiredNames(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name          string
		requiredNames []string
		errorKeys     []string
	}{
		{
			name:          "invalid unknown and nonrenderable",
			requiredNames: []string{"final_regex_fail", "missing_service", "custom_tag_only"},
			errorKeys:     []string{"final_regex_fail", "missing_service", "custom_tag_only"},
		},
		{
			name:          "hash affix fit conflict",
			requiredNames: []string{"hash_affix_conflict"},
			errorKeys:     []string{"hash_affix_conflict"},
		},
	}

	for _, testCase := range testCases {
		t.Run(testCase.name, func(t *testing.T) {
			terraformOptions := resourceRendererTerraformOptions(t, map[string]any{
				"required_resource_names": testCase.requiredNames,
			})

			_, err := terraform.InitAndPlanE(t, terraformOptions)
			require.Error(t, err)
			message := strings.Join(strings.Fields(err.Error()), " ")
			assert.Contains(t, message, "Required resource names failed")
			for _, resourceKey := range testCase.errorKeys {
				assert.Contains(t, message, resourceKey)
			}
		})
	}
}

func TestResourceRendererDisabledShortCircuitsPreconditions(t *testing.T) {
	t.Parallel()

	terraformOptions := resourceRendererTerraformOptions(t, map[string]any{
		"enabled":                 false,
		"required_resource_names": []string{"missing_service"},
		"extra_resource_label_rules": map[string]any{
			"incomplete_service": map[string]any{
				"code_position": "prefix",
			},
		},
	})
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	outputs := terraform.OutputAll(t, terraformOptions)
	assert.Empty(t, outputs["base_id"])
	assert.Empty(t, outputs["resource_name"])
	assert.Empty(t, outputs["resource_name_hashed"])
	assert.Empty(t, outputs["resource_name_errors"])
}

func resourceRendererTerraformOptions(t testing.TB, vars map[string]any) *terraform.Options {
	t.Helper()

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(
		t,
		"../../",
		"test/fixtures/resource-renderer",
	)

	return &terraform.Options{
		TerraformDir: tempTestFolder,
		NoColor:      true,
		Vars:         vars,
	}
}

func resourceRendererOutputs(t testing.TB, vars map[string]any) map[string]any {
	t.Helper()

	terraformOptions := resourceRendererTerraformOptions(t, vars)
	terraformOptions.Logger = logger.Discard
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	return terraform.OutputAll(t, terraformOptions)
}

func rendererHashDigest(t testing.TB) string {
	t.Helper()

	return rendererHashDigestForLabels(t, "", "")
}

func rendererHashDigestForLabels(t testing.TB, region string, environment string) string {
	t.Helper()

	seed := map[string]any{
		"labels_raw": map[string]any{
			"application": "Orders",
			"attributes":  []string{"API", "###"},
			"environment": environment,
			"namespace":   "Platform",
			"region":      region,
		},
		"resource_hash_values": []string{"account-123"},
	}
	encoded, err := json.Marshal(seed)
	require.NoError(t, err)
	digest := sha256.Sum256(encoded)

	return hex.EncodeToString(digest[:])
}

func rendererHashSuffix(t testing.TB, value string) string {
	t.Helper()

	parts := strings.Split(value, "-")
	require.NotEmpty(t, parts)

	return parts[len(parts)-1]
}

func assertErrorContains(t testing.TB, errorsByKey map[string]any, resourceKey string, fragment string) {
	t.Helper()

	rawErrors, ok := errorsByKey[resourceKey].([]any)
	require.True(t, ok, "%s errors must be a list", resourceKey)
	parts := make([]string, 0, len(rawErrors))
	for _, rawError := range rawErrors {
		parts = append(parts, rawError.(string))
	}
	sort.Strings(parts)
	assert.Contains(t, strings.Join(parts, " | "), fragment)
}
