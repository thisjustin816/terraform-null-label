package test

import (
	"fmt"
	"path/filepath"
	"sort"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestContextV2ToV2(t *testing.T) {
	t.Parallel()

	terraformOptions := contextTerraformOptions(t, "context-v2-to-v2", nil)
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	outputs := terraform.OutputAll(t, terraformOptions)
	parentContext := requireMap(t, outputs, "parent_context")
	childContext := requireMap(t, outputs, "child_context")
	emptyContext := requireMap(t, outputs, "empty_context")

	assert.Equal(t, float64(2), parentContext["schema_version"])
	assert.Equal(t, "raw", parentContext["label_source"])
	assert.Equal(t, "Eg", requireMap(t, parentContext, "labels_raw")["namespace"])
	assert.Equal(t, "Orders.API", requireMap(t, parentContext, "labels_raw")["application"])
	assert.Equal(t, []any{"API_Gateway"}, requireMap(t, parentContext, "labels_raw")["attributes"])
	assert.Equal(t, map[string]any{
		"aws_elasticache_replication_group": "redis",
		"custom_service":                    "svc",
		"custom_widget":                     "parent",
	}, requireMap(t, parentContext, "resource_code_overrides"))
	require.NotContains(t, parentContext, "resource_codes")
	assert.Empty(t, requireMap(t, parentContext, "resource_label_rules"))

	parentRules := requireMap(t, parentContext, "resource_rules")
	require.ElementsMatch(t, []string{"custom_service"}, mapKeys(parentRules))
	parentCustomRule := requireMap(t, parentRules, "custom_service")
	assert.Equal(t, "", parentCustomRule["component_delimiter"])
	assert.Equal(t, []any{}, parentCustomRule["forbidden_regexes"])
	assert.Equal(t, float64(0), parentCustomRule["min_length"])
	require.NotContains(t, parentCustomRule, "classification")
	require.NotContains(t, parentCustomRule, "code")
	require.NotContains(t, parentCustomRule, "trim_chars")

	childRawLabels := requireMap(t, childContext, "labels_raw")
	assert.Equal(t, "Eg", childRawLabels["namespace"])
	assert.Equal(t, "Child.API", childRawLabels["application"])
	assert.Equal(t, []any{"API_Gateway"}, childRawLabels["attributes"])
	assert.Equal(t, "raw", childContext["label_source"])
	assert.Equal(t, map[string]any{
		"aws_elasticache_replication_group": "redis",
		"custom_service":                    "",
		"custom_widget":                     "child",
	}, requireMap(t, childContext, "resource_code_overrides"))
	require.NotContains(t, childContext, "resource_codes")
	assert.Empty(t, requireMap(t, childContext, "resource_label_rules"))

	childRules := requireMap(t, childContext, "resource_rules")
	require.ElementsMatch(t, []string{"custom_service"}, mapKeys(childRules))
	childCustomRule := requireMap(t, childRules, "custom_service")
	require.NotContains(t, childCustomRule, "classification")
	require.NotContains(t, childCustomRule, "code")
	assert.Equal(t, "", childCustomRule["component_delimiter"])
	assert.Equal(t, "", childCustomRule["group_delimiter"])
	assert.Equal(t, float64(0), childCustomRule["min_length"])
	assert.Equal(t, float64(64), childCustomRule["max_length"])
	assert.Equal(t, []any{}, childCustomRule["forbidden_regexes"])

	assert.Equal(t, float64(2), emptyContext["schema_version"])
	assert.Equal(t, "raw", emptyContext["label_source"])
	assert.Empty(t, requireMap(t, emptyContext, "resource_code_overrides"))
	require.NotContains(t, emptyContext, "resource_codes")
	assert.Empty(t, requireMap(t, emptyContext, "resource_rules"))
	assert.Empty(t, requireMap(t, emptyContext, "resource_label_rules"))
	assert.Equal(t, "", outputs["empty_id"])
	assert.Equal(t, "eg-OrdersAPI-usw2-p-apigateway", outputs["parent_id"])
	assert.Equal(t, "eg-ChildAPI-usw2-p-apigateway", outputs["child_id"])
}

func TestContextV1ToV2(t *testing.T) {
	t.Parallel()

	legacyAzureKeys := v1AzureResourceCodeKeys(t)
	legacyResourceCodes := make(map[string]string, len(legacyAzureKeys)+1)
	for index, resourceKey := range legacyAzureKeys {
		legacyResourceCodes[resourceKey] = fmt.Sprintf("legacy%03d", index)
	}
	legacyResourceCodes["custom_widget"] = "cw"

	terraformOptions := contextTerraformOptions(t, "context-v1-to-v2", map[string]any{
		"legacy_resource_codes": legacyResourceCodes,
	})
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	outputs := terraform.OutputAll(t, terraformOptions)
	parentContext := requireMap(t, outputs, "parent_context")
	childContext := requireMap(t, outputs, "child_context")
	legacyChildContext := requireMap(t, outputs, "legacy_child_context")
	childResourceCodes := requireMap(t, outputs, "child_resource_codes")

	assert.Equal(t, float64(2), childContext["schema_version"])
	assert.Equal(t, "legacy_fallback", childContext["label_source"])
	assert.Equal(t, "egname", requireMap(t, childContext, "labels_raw")["namespace"])
	assert.Equal(t, "OrdersAPI", requireMap(t, childContext, "labels_raw")["application"])
	assert.Equal(t, []any{"apigateway"}, requireMap(t, childContext, "labels_raw")["attributes"])
	assert.Equal(t, outputs["parent_id"], outputs["child_id"])

	legacyRules := requireMap(t, parentContext, "resource_label_rules")
	assert.Equal(t, legacyRules, requireMap(t, childContext, "resource_label_rules"))
	assert.Equal(t, legacyRules, requireMap(t, legacyChildContext, "resource_label_rules"))
	assert.Empty(t, requireMap(t, childContext, "resource_rules"))
	childResourceRules := requireMap(t, outputs, "child_resource_rules")
	lambdaRule := requireMap(t, childResourceRules, "aws_lambda_function")
	assert.Equal(t, "lambda", lambdaRule["code"])
	assert.Equal(t, "-", lambdaRule["component_delimiter"])

	parentLegacyCodes := requireMap(t, parentContext, "resource_codes")
	assert.Equal(t, parentLegacyCodes, requireMap(t, childContext, "resource_codes"))
	assert.Equal(t, parentLegacyCodes, requireMap(t, legacyChildContext, "resource_codes"))
	assert.Equal(t, outputs["parent_id_resource"], outputs["legacy_child_id_resource"])

	contextOverrides := requireMap(t, childContext, "resource_code_overrides")
	require.Len(t, contextOverrides, len(legacyResourceCodes))
	require.NotContains(t, contextOverrides, "aws_elasticache_replication_group")
	assert.Equal(t, "cacherg", childResourceCodes["aws_elasticache_replication_group"])
	for _, legacyKey := range legacyAzureKeys {
		expectedKey := legacyKey
		if !strings.HasPrefix(expectedKey, "azure_") {
			expectedKey = "azure_" + expectedKey
		}

		assert.Equal(t, legacyResourceCodes[legacyKey], childResourceCodes[expectedKey], expectedKey)
		assert.Equal(t, legacyResourceCodes[legacyKey], contextOverrides[expectedKey], expectedKey)
		if expectedKey != legacyKey {
			require.NotContains(t, childResourceCodes, legacyKey)
			require.NotContains(t, contextOverrides, legacyKey)
		}
	}
	assert.Equal(t, "cw", childResourceCodes["custom_widget"])
}

func TestContextV1CodeCollisionPrecedence(t *testing.T) {
	t.Parallel()

	terraformOptions := contextTerraformOptions(t, "context-v1-to-v2", map[string]any{
		"legacy_resource_codes": map[string]string{
			"storage_account":       "legacy-unprefixed",
			"azure_storage_account": "legacy-prefixed",
		},
	})
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	outputs := terraform.OutputAll(t, terraformOptions)
	parentContext := requireMap(t, outputs, "parent_context")
	childContext := requireMap(t, outputs, "child_context")
	parentLegacyCodes := requireMap(t, parentContext, "resource_codes")
	childLegacyCodes := requireMap(t, childContext, "resource_codes")
	childOverrides := requireMap(t, childContext, "resource_code_overrides")
	childResourceCodes := requireMap(t, outputs, "child_resource_codes")

	assert.Equal(t, "legacy-unprefixed", parentLegacyCodes["storage_account"])
	assert.Equal(t, "legacy-prefixed", parentLegacyCodes["azure_storage_account"])
	assert.Equal(t, parentLegacyCodes, childLegacyCodes)
	assert.Equal(t, "legacy-prefixed", childOverrides["azure_storage_account"])
	require.NotContains(t, childOverrides, "storage_account")
	assert.Equal(t, "legacy-prefixed", childResourceCodes["azure_storage_account"])
}

func TestContextV1ToV2ToV2(t *testing.T) {
	t.Parallel()

	terraformOptions := contextTerraformOptions(t, "context-v1-to-v2-to-v2", nil)
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	outputs := terraform.OutputAll(t, terraformOptions)
	parentContext := requireMap(t, outputs, "parent_context")
	bridgeContext := requireMap(t, outputs, "bridge_context")
	descendantContext := requireMap(t, outputs, "descendant_context")

	assert.Equal(t, "legacy_fallback", bridgeContext["label_source"])
	assert.Equal(t, "legacy_fallback", descendantContext["label_source"])
	assert.Equal(t, requireMap(t, bridgeContext, "labels_raw"), requireMap(t, descendantContext, "labels_raw"))
	assert.Equal(t, requireMap(t, parentContext, "resource_label_rules"), requireMap(t, bridgeContext, "resource_label_rules"))
	assert.Equal(t, requireMap(t, bridgeContext, "resource_label_rules"), requireMap(t, descendantContext, "resource_label_rules"))
	assert.Empty(t, requireMap(t, bridgeContext, "resource_rules"))
	assert.Empty(t, requireMap(t, descendantContext, "resource_rules"))
	parentLegacyCodes := requireMap(t, parentContext, "resource_codes")
	assert.Equal(t, parentLegacyCodes, requireMap(t, bridgeContext, "resource_codes"))
	assert.Equal(t, parentLegacyCodes, requireMap(t, descendantContext, "resource_codes"))
	assert.Equal(t, map[string]any{"azure_storage_account": "legacy-storage"}, requireMap(t, bridgeContext, "resource_code_overrides"))
	assert.Equal(t, map[string]any{"azure_storage_account": "legacy-storage"}, requireMap(t, descendantContext, "resource_code_overrides"))
	assert.Equal(t, "legacy-storage", requireMap(t, outputs, "descendant_resource_codes")["azure_storage_account"])
	assert.Equal(t, outputs["parent_id"], outputs["bridge_id"])
	assert.Equal(t, outputs["bridge_id"], outputs["descendant_id"])
	assert.Equal(t, outputs["parent_id_resource"], outputs["legacy_descendant_id_resource"])
}

func TestContextV2ToV1(t *testing.T) {
	t.Parallel()

	terraformOptions := contextTerraformOptions(t, "context-v2-to-v1", nil)
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	outputs := terraform.OutputAll(t, terraformOptions)
	parentContext := requireMap(t, outputs, "parent_context")
	childContext := requireMap(t, outputs, "child_context")
	baselineContext := requireMap(t, outputs, "baseline_context")

	assert.Equal(t, float64(2), parentContext["schema_version"])
	require.NotContains(t, parentContext, "resource_codes")
	assert.Equal(t, map[string]any{"custom_widget": "widget"}, requireMap(t, parentContext, "resource_code_overrides"))
	require.Contains(t, requireMap(t, parentContext, "resource_rules"), "custom_widget")
	assert.Empty(t, requireMap(t, parentContext, "resource_label_rules"))
	assert.Empty(t, requireMap(t, childContext, "resource_label_rules"))
	assert.Equal(t, requireMap(t, baselineContext, "resource_codes"), requireMap(t, childContext, "resource_codes"))
	require.NotContains(t, requireMap(t, childContext, "resource_codes"), "custom_widget")
	assert.Equal(t, outputs["baseline_id_resource"], outputs["child_id_resource"])
	assert.Equal(t, outputs["parent_id"], outputs["child_id"])
}

func contextTerraformOptions(t testing.TB, fixtureName string, vars map[string]any) *terraform.Options {
	t.Helper()

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(
		t,
		"../../",
		filepath.ToSlash(filepath.Join("test", "fixtures", fixtureName)),
	)

	return &terraform.Options{
		TerraformDir: tempTestFolder,
		NoColor:      true,
		Vars:         vars,
	}
}

func requireMap(t testing.TB, values map[string]any, key string) map[string]any {
	t.Helper()

	value, ok := values[key].(map[string]any)
	require.True(t, ok, "%s must be an object, got %T", key, values[key])

	return value
}

func mapKeys(values map[string]any) []string {
	keys := make([]string, 0, len(values))
	for key := range values {
		keys = append(keys, key)
	}
	sort.Strings(keys)

	return keys
}
