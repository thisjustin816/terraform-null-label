package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestAzureCatalogAliases(t *testing.T) {
	t.Parallel()

	outputs := applyAzureCatalogFixture(t, nil)
	rules := requireMap(t, outputs, "resource_label_rules")
	names := requireMap(t, outputs, "resource_name")
	hashedNames := requireMap(t, outputs, "resource_name_hashed")

	for alias, canonical := range azureCompatibilityAliases() {
		assert.Equal(t, rules[canonical], rules[alias], alias)
		assert.Equal(t, names[canonical], names[alias], alias)
		assert.Equal(t, hashedNames[canonical], hashedNames[alias], alias)
	}
}

func TestAzureCatalogRegionComposition(t *testing.T) {
	t.Parallel()

	outputs := applyAzureCatalogFixture(t, map[string]any{
		"region":      "us-west-2",
		"environment": "prod",
	})
	names := requireMap(t, outputs, "resource_name")

	assert.Equal(t, "asplatformordersusw2papi", names["azure_analysis_services_server"])
	assert.Equal(t, "asp-Platform-Orders-usw2-p-API", names["azure_app_service_plan"])
	assert.Equal(t, "gal_Platform_Orders_usw2_p_API", names["azure_gallery"])
}

func TestAzureCatalogRepresentativeRendering(t *testing.T) {
	t.Parallel()

	outputs := applyAzureCatalogFixture(t, nil)
	assert.Equal(t, "745beb9e", outputs["resource_hash"])
	names := requireMap(t, outputs, "resource_name")
	hashedNames := requireMap(t, outputs, "resource_name_hashed")

	expected := map[string]string{
		"azure_ai_search":                  "srch-platform-orders-api-745beb9e",
		"azure_analysis_services_server":   "asplatformordersapi",
		"azure_app_service_plan":           "asp-Platform-Orders-API",
		"azure_container_registry":         "crplatformordersapi745beb9e",
		"azure_frontdoor_firewall_policy":  "fdfpPlatformOrdersAPI",
		"azure_gallery":                    "gal_Platform_Orders_API",
		"azure_key_vault":                  "kv-platform-ord-745beb9e",
		"azure_postgresql_flexible_server": "pgsql-platform-orders-api-745beb9e",
		"azure_sql_server":                 "sql-platform-orders-api-745beb9e",
		"azure_storage_account":            "stplatformorders745beb9e",
		"azure_subnet":                     "snet-Platform-Orders-API",
	}
	for key, expectedName := range expected {
		assert.Equal(t, expectedName, names[key], key)
	}

	assert.Equal(t, "asplatformordersapi745beb9e", hashedNames["azure_analysis_services_server"])
	assert.Equal(t, "asp-Platform-Orders-API-745beb9e", hashedNames["azure_app_service_plan"])
	assert.Equal(t, "gal_Platform_Orders_API_745beb9e", hashedNames["azure_gallery"])
	assert.Equal(t, "snet-Platform-Orders-API-745beb9e", hashedNames["azure_subnet"])
	for _, key := range []string{
		"azure_ai_search", "azure_container_registry", "azure_key_vault",
		"azure_postgresql_flexible_server", "azure_sql_server", "azure_storage_account",
	} {
		assert.Equal(t, names[key], hashedNames[key], key)
	}

	for _, key := range []string{
		"azure_content_moderator", "azure_custom_vision_prediction",
		"azure_custom_vision_training", "azure_redis_cache",
	} {
		require.Contains(t, names, key)
	}
	for _, key := range []string{
		"azure_managed_redis", "azure_aks_system_node_pool", "azure_aks_user_node_pool",
		"azure_enclave", "azure_virtual_machine", "azure_virtual_machine_scale_set",
		"azure_blueprint_definition", "azure_blueprint_assignment",
	} {
		require.NotContains(t, names, key)
	}
}

func TestAzureCatalogBoundaries(t *testing.T) {
	t.Parallel()

	t.Run("app service plan hashes only after the 60 character boundary", func(t *testing.T) {
		atLimit := applyAzureCatalogFixture(t, map[string]any{
			"namespace":            strings.Repeat("A", 56),
			"application":          "",
			"attributes":           []string{},
			"resource_hash_values": []string{"account-123"},
		})
		atLimitName := requireMap(t, atLimit, "resource_name")["azure_app_service_plan"].(string)
		assert.Equal(t, "asp-"+strings.Repeat("A", 56), atLimitName)

		overLimit := applyAzureCatalogFixture(t, map[string]any{
			"namespace":            strings.Repeat("A", 57),
			"application":          "",
			"attributes":           []string{},
			"resource_hash_values": []string{"account-123"},
		})
		overLimitName := requireMap(t, overLimit, "resource_name")["azure_app_service_plan"].(string)
		assert.Len(t, overLimitName, 60)
		assert.Regexp(t, `^asp-A+-[a-f0-9]{8}$`, overLimitName)
	})

	t.Run("global profiles honor provider maxima", func(t *testing.T) {
		outputs := applyAzureCatalogFixture(t, map[string]any{
			"namespace":            strings.Repeat("Long", 20),
			"application":          strings.Repeat("Name", 20),
			"attributes":           []string{"API"},
			"resource_hash_values": []string{"account-123"},
		})
		names := requireMap(t, outputs, "resource_name")
		assert.Len(t, names["azure_ai_search"].(string), 60)
		assert.LessOrEqual(t, len(names["azure_key_vault"].(string)), 24)
		assert.LessOrEqual(t, len(names["azure_storage_account"].(string)), 24)
		assert.LessOrEqual(t, len(names["azure_postgresql_flexible_server"].(string)), 63)
	})

	t.Run("synapse rejects ondemand anywhere", func(t *testing.T) {
		outputs := applyAzureCatalogFixture(t, map[string]any{
			"namespace":   "foo",
			"application": "ondemand",
			"attributes":  []string{"bar"},
		})
		names := requireMap(t, outputs, "resource_name")
		errorsByKey := requireMap(t, outputs, "resource_name_errors")
		require.NotContains(t, names, "azure_synapse_workspace")
		assert.Contains(t, strings.Join(interfaceListStrings(t, errorsByKey["azure_synapse_workspace"]), " "), "-ondemand")
	})
}

func TestAzureCatalogV1ContextMigration(t *testing.T) {
	t.Parallel()

	v1Codes := v1AzureResourceCodes(t)
	legacyKeys := sortedMapKeys(v1Codes)
	require.Len(t, legacyKeys, 226)
	legacyResourceCodes := make(map[string]string, len(legacyKeys)+2)
	for index, legacyKey := range legacyKeys {
		legacyResourceCodes[legacyKey] = fmt.Sprintf("legacy%03d", index)
	}
	legacyResourceCodes["azure_storage_account"] = "explicit-prefixed"
	legacyResourceCodes["custom_widget"] = "cw"

	terraformOptions := contextTerraformOptions(t, "context-v1-to-v2", map[string]any{
		"legacy_resource_codes": legacyResourceCodes,
	})
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
	outputs := terraform.OutputAll(t, terraformOptions)

	childCodes := requireMap(t, outputs, "child_resource_codes")
	childContext := requireMap(t, outputs, "child_context")
	childContextOverrides := requireMap(t, childContext, "resource_code_overrides")
	childLegacyCodes := requireMap(t, childContext, "resource_codes")
	parentLegacyCodes := requireMap(t, requireMap(t, outputs, "parent_context"), "resource_codes")
	assert.Equal(t, parentLegacyCodes, childLegacyCodes)
	for _, legacyKey := range legacyKeys {
		v2Key := legacyKey
		if !strings.HasPrefix(v2Key, "azure_") {
			v2Key = "azure_" + v2Key
		}

		expectedCode := legacyResourceCodes[legacyKey]
		if v2Key == "azure_storage_account" {
			expectedCode = "explicit-prefixed"
		}
		assert.Equal(t, expectedCode, childCodes[v2Key], v2Key)
		assert.Equal(t, expectedCode, childContextOverrides[v2Key], v2Key)
		if legacyKey != v2Key {
			require.NotContains(t, childCodes, legacyKey)
			require.NotContains(t, childContextOverrides, legacyKey)
		}
	}
	assert.Equal(t, "explicit-prefixed", childContextOverrides["azure_storage_account"])
	require.NotContains(t, childContextOverrides, "azure_azure_storage_account")
	assert.Equal(t, "cw", childContextOverrides["custom_widget"])
}

func applyAzureCatalogFixture(t testing.TB, vars map[string]any) map[string]any {
	t.Helper()

	return resourceRendererOutputs(t, vars)
}

func azureCompatibilityAliases() map[string]string {
	return map[string]string{
		"azure_api_management":                "azure_api_management_service",
		"azure_container_group":               "azure_container_instance",
		"azure_kubernetes_cluster":            "azure_aks_cluster",
		"azure_logic_app_integration_account": "azure_integration_account",
		"azure_shared_image_gallery":          "azure_gallery",
		"azure_user_assigned_identity":        "azure_managed_identity",
	}
}
