package test

import (
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestResourceRuleValidation(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name          string
		resourceKey   string
		rule          map[string]any
		errorFragment string
	}{
		{
			name:          "code position enum",
			resourceKey:   "bad_code_position",
			rule:          map[string]any{"code_position": "middle"},
			errorFragment: "Invalid code_position for resource_label_rules keys: bad_code_position",
		},
		{
			name:          "label value case enum",
			resourceKey:   "bad_label_value_case",
			rule:          map[string]any{"label_value_case": "camel"},
			errorFragment: "Invalid label_value_case for resource_label_rules keys: bad_label_value_case",
		},
		{
			name:          "hash policy enum",
			resourceKey:   "bad_hash_policy",
			rule:          map[string]any{"hash_policy": "sometimes"},
			errorFragment: "Invalid hash_policy for resource_label_rules keys: bad_hash_policy",
		},
		{
			name:        "unsupported label group element",
			resourceKey: "bad_group",
			rule: map[string]any{
				"label_groups": [][]string{{"namespace", "unsupported"}},
			},
			errorFragment: "Unsupported label_groups elements for resource_label_rules keys: bad_group",
		},
		{
			name:          "malformed replace regex",
			resourceKey:   "bad_replace_regex",
			rule:          map[string]any{"regex_replace_chars": "/[/"},
			errorFragment: "Invalid regex_replace_chars for resource_label_rules keys: bad_replace_regex",
		},
		{
			name:          "undelimited replace regex",
			resourceKey:   "undelimited_replace_regex",
			rule:          map[string]any{"regex_replace_chars": "[^a-z0-9-]"},
			errorFragment: "Invalid regex_replace_chars for resource_label_rules keys: undelimited_replace_regex",
		},
		{
			name:          "malformed collapse regex",
			resourceKey:   "bad_collapse_regex",
			rule:          map[string]any{"collapse_regex": "/[/"},
			errorFragment: "Invalid collapse_regex for resource_label_rules keys: bad_collapse_regex",
		},
		{
			name:          "undelimited collapse regex",
			resourceKey:   "undelimited_collapse_regex",
			rule:          map[string]any{"collapse_regex": "-{2,}"},
			errorFragment: "Invalid collapse_regex for resource_label_rules keys: undelimited_collapse_regex",
		},
		{
			name:          "malformed validation regex",
			resourceKey:   "bad_validation_regex",
			rule:          map[string]any{"validation_regex": "["},
			errorFragment: "Invalid validation_regex for resource_label_rules keys: bad_validation_regex",
		},
		{
			name:          "unanchored validation regex",
			resourceKey:   "unanchored_validation_regex",
			rule:          map[string]any{"validation_regex": ".+"},
			errorFragment: "Invalid validation_regex for resource_label_rules keys: unanchored_validation_regex",
		},
		{
			name:        "malformed forbidden regex",
			resourceKey: "bad_forbidden_regex",
			rule: map[string]any{
				"forbidden_regexes": []string{"["},
			},
			errorFragment: "Invalid forbidden_regexes for resource_label_rules keys: bad_forbidden_regex",
		},
		{
			name:          "fractional minimum length",
			resourceKey:   "fractional_minimum",
			rule:          map[string]any{"min_length": 1.5},
			errorFragment: "Invalid min_length for resource_label_rules keys: fractional_minimum",
		},
		{
			name:          "negative minimum length",
			resourceKey:   "negative_minimum",
			rule:          map[string]any{"min_length": -1},
			errorFragment: "Invalid min_length for resource_label_rules keys: negative_minimum",
		},
		{
			name:          "fractional maximum length",
			resourceKey:   "fractional_maximum",
			rule:          map[string]any{"max_length": 12.5},
			errorFragment: "Invalid max_length for resource_label_rules keys: fractional_maximum",
		},
		{
			name:          "zero maximum length",
			resourceKey:   "zero_maximum",
			rule:          map[string]any{"max_length": 0},
			errorFragment: "Invalid max_length for resource_label_rules keys: zero_maximum",
		},
		{
			name:          "fractional hash length",
			resourceKey:   "fractional_hash",
			rule:          map[string]any{"hash_length": 7.5},
			errorFragment: "Invalid hash_length for resource_label_rules keys: fractional_hash",
		},
		{
			name:          "short hash length",
			resourceKey:   "short_hash",
			rule:          map[string]any{"hash_length": 3},
			errorFragment: "Invalid hash_length for resource_label_rules keys: short_hash",
		},
		{
			name:          "long hash length",
			resourceKey:   "long_hash",
			rule:          map[string]any{"hash_length": 33},
			errorFragment: "Invalid hash_length for resource_label_rules keys: long_hash",
		},
		{
			name:        "minimum exceeds maximum",
			resourceKey: "inverted_lengths",
			rule: map[string]any{
				"min_length": 20,
				"max_length": 10,
			},
			errorFragment: "min_length exceeds max_length for resource_label_rules keys: inverted_lengths",
		},
	}

	for _, testCase := range testCases {
		t.Run(testCase.name, func(t *testing.T) {
			terraformOptions := resourceRuleTerraformOptions(t, map[string]any{
				"resource_label_rules": map[string]any{
					testCase.resourceKey: testCase.rule,
				},
			})

			_, err := terraform.InitAndPlanE(t, terraformOptions)
			require.Error(t, err)
			assert.Contains(t, strings.Join(strings.Fields(err.Error()), " "), testCase.errorFragment)
		})
	}
}

func TestResourceRulePublicAPI(t *testing.T) {
	t.Parallel()

	terraformOptions := resourceRuleTerraformOptions(t, map[string]any{
		"resource_codes": map[string]string{
			"aws_custom_widget":   "aw",
			"azure_custom_widget": "az",
			"custom_complete":     "complete",
			"custom_empty":        "empty",
			"custom_nulls":        "null",
			"custom_widget":       "cw",
		},
		"resource_label_rules": map[string]any{
			"azure_storage_account": map[string]any{
				"hash_policy": "never",
			},
			"custom_complete": completeCustomResourceRule(),
			"custom_empty": map[string]any{
				"component_delimiter":  "",
				"group_delimiter":      "",
				"trim_chars":           "",
				"required_prefix":      "",
				"required_suffix":      "",
				"min_length":           0,
				"max_length":           64,
				"validation_regex":     "^.+$",
				"forbidden_regexes":    []string{},
				"collapse_regex":       "",
				"collapse_replacement": "",
			},
			"custom_nulls": map[string]any{
				"code_position":       nil,
				"component_delimiter": nil,
				"label_groups":        nil,
				"hash_length":         nil,
				"min_length":          1,
				"max_length":          64,
				"validation_regex":    "^.+$",
			},
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
	outputs := terraform.OutputAll(t, terraformOptions)

	assert.Equal(t, "eg-orders-usw2-p-api", outputs["base_id"])
	assert.Equal(t, map[string]any{
		"short": "eg-orders",
	}, outputs["descriptors"])
	tags := outputs["tags"].(map[string]any)
	assert.Equal(t, "orders", tags["Application"])
	assert.Equal(t, "eg-orders-usw2-p-api", tags["Id"])

	resourceCodes := outputs["resource_codes"].(map[string]any)
	assert.Equal(t, "aw", resourceCodes["aws_custom_widget"])
	assert.Equal(t, "az", resourceCodes["azure_custom_widget"])
	assert.Equal(t, "cw", resourceCodes["custom_widget"])
	assert.Equal(t, "complete", resourceCodes["custom_complete"])
	require.NotContains(t, resourceCodes, "storage_account")
	require.Contains(t, resourceCodes, "azure_storage_account")
	require.Contains(t, resourceCodes, "azure_managed_redis")
	require.NotContains(t, resourceCodes, "azure_azure_managed_redis")

	logicalNames := outputs["id_with_resource_code"].(map[string]any)
	assert.Equal(t, "eg-orders-p-api-aw", logicalNames["aws_custom_widget"])
	assert.Equal(t, "az-eg-orders-usw2-p-api", logicalNames["azure_custom_widget"])
	assert.Equal(t, "cw-eg-orders-usw2-p-api", logicalNames["custom_widget"])

	resourceNames := outputs["resource_name"].(map[string]any)
	assert.Equal(t, "complete-eg/orders-api", resourceNames["custom_complete"])
	assert.Equal(t, "emptyegordersusw2papi", resourceNames["custom_empty"])
	assert.Equal(t, "null-eg-orders-usw2-p-api", resourceNames["custom_nulls"])
	resourceNamesHashed := outputs["resource_name_hashed"].(map[string]any)
	assert.Equal(t, "complete-eg/orders-api-2f73c42d", resourceNamesHashed["custom_complete"])
	assert.Equal(t, "emptyegordersusw2papi2f73c42d", resourceNamesHashed["custom_empty"])
	assert.Equal(t, "null-eg-orders-usw2-p-api-2f73c42d", resourceNamesHashed["custom_nulls"])
	assert.Empty(t, outputs["resource_name_errors"])
	assert.Equal(t, resourceNamesHashed["azure_key_vault"], outputs["key_vault_alias"])
	assert.Equal(t, resourceNamesHashed["azure_storage_account"], outputs["storage_account_alias"])
	require.NotContains(t, outputs, "id_resource")
	require.NotContains(t, outputs, "id_resource_unique")

	precedence := outputs["precedence"].(map[string]any)
	assert.Equal(t, "lambda", precedence["builtin"])
	assert.Equal(t, "lambda", precedence["generated"])
	assert.Equal(t, "fn", precedence["explicit"])

	rules := outputs["resource_label_rules"].(map[string]any)
	nullRule := rules["custom_nulls"].(map[string]any)
	assert.Equal(t, "prefix", nullRule["code_position"])
	assert.Equal(t, "-", nullRule["component_delimiter"])
	assert.Equal(t, float64(8), nullRule["hash_length"])
	assert.NotEmpty(t, nullRule["label_groups"])

	emptyRule := rules["custom_empty"].(map[string]any)
	assert.Equal(t, "", emptyRule["component_delimiter"])
	assert.Equal(t, "", emptyRule["group_delimiter"])
	assert.Equal(t, float64(0), emptyRule["min_length"])
	assert.Empty(t, emptyRule["forbidden_regexes"])
	assert.Equal(t, "never", rules["azure_storage_account"].(map[string]any)["hash_policy"])
}

func resourceRuleTerraformOptions(t testing.TB, vars map[string]any) *terraform.Options {
	t.Helper()

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(
		t,
		"../../",
		"test/fixtures/resource-rule-validation",
	)

	return &terraform.Options{
		TerraformDir: tempTestFolder,
		NoColor:      true,
		Vars:         vars,
	}
}

func completeCustomResourceRule() map[string]any {
	return map[string]any{
		"code_position":        "prefix",
		"label_groups":         [][]string{{"namespace"}, {"application", "attributes"}},
		"component_delimiter":  "-",
		"group_delimiter":      "/",
		"regex_replace_chars":  "/[^a-z0-9-]/",
		"label_value_case":     "lower",
		"trim_chars":           "-",
		"collapse_regex":       "/-{2,}/",
		"collapse_replacement": "-",
		"required_prefix":      "",
		"required_suffix":      "",
		"min_length":           1,
		"max_length":           63,
		"validation_regex":     "^[a-z][a-z0-9/-]{0,62}$",
		"forbidden_regexes":    []string{"--", "//"},
		"hash_policy":          "when_needed",
		"hash_length":          8,
	}
}
