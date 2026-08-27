package test

import (
	"fmt"
	"regexp"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestAwsCatalogContract(t *testing.T) {
	t.Parallel()

	terraformOptions := resourceRendererTerraformOptions(t, nil)
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	outputs := terraform.OutputAll(t, terraformOptions)
	names := requireMap(t, outputs, "resource_name")
	hashedNames := requireMap(t, outputs, "resource_name_hashed")
	rules := requireMap(t, outputs, "resource_label_rules")
	errorsByKey := requireMap(t, outputs, "resource_name_errors")

	for key, rawName := range names {
		if !strings.HasPrefix(key, "aws_") {
			continue
		}

		rawHashedName, exists := hashedNames[key]
		require.True(t, exists, key)
		rule := requireMap(t, rules, key)
		assertRuleSatisfiesSamples(t, key, rule, rawName.(string), rawHashedName.(string))
		require.NotContains(t, errorsByKey, key)
	}
	for key := range hashedNames {
		if strings.HasPrefix(key, "aws_") {
			require.Contains(t, names, key)
		}
	}

	assert.Equal(t, "745beb9e", outputs["resource_hash"])
	assertAwsLiteralOutputs(t, names, hashedNames)
	assertAwsForbiddenContracts(t, rules)
	assertModuleIsProviderless(t, terraformOptions)
}

func TestAwsCatalogRegionAndEnvironmentComponents(t *testing.T) {
	t.Parallel()

	outputs := resourceRendererOutputs(t, map[string]any{
		"region":      "us-west-2",
		"environment": "prod",
	})
	names := requireMap(t, outputs, "resource_name")
	expected := map[string]string{
		"aws_ecr_repository": "platform/orders-api",
		"aws_rds_cluster":    "rds-platform-orders-p-api",
		"aws_sns_topic":      "Platform-Orders-p-API-sns",
	}
	for key, expectedName := range expected {
		assert.Equal(t, expectedName, names[key], key)
		assert.NotContains(t, strings.ToLower(names[key].(string)), "usw2", key)
	}
}

func TestAwsEcrHashTruncationTrimsPathBoundary(t *testing.T) {
	t.Parallel()

	outputs := resourceRendererOutputs(t, map[string]any{
		"namespace":   strings.Repeat("a", 246),
		"application": "b",
		"attributes":  []string{},
	})
	hashedNames := requireMap(t, outputs, "resource_name_hashed")
	errorsByKey := requireMap(t, outputs, "resource_name_errors")
	hashedName, exists := hashedNames["aws_ecr_repository"].(string)
	require.True(t, exists)
	assert.Equal(t, strings.Repeat("a", 246)+"-"+outputs["resource_hash"].(string), hashedName)
	assert.NotContains(t, hashedName, "/-")
	require.NotContains(t, errorsByKey, "aws_ecr_repository")
}

func TestAwsLaunchTemplateProviderBoundary(t *testing.T) {
	t.Parallel()

	tests := map[string]struct {
		namespaceLength int
		hashRequired    bool
	}{
		"provider maximum": {
			namespaceLength: 122,
			hashRequired:    false,
		},
		"candidate exceeds provider maximum": {
			namespaceLength: 123,
			hashRequired:    true,
		},
	}

	for name, testCase := range tests {
		t.Run(name, func(t *testing.T) {
			outputs := resourceRendererOutputs(t, map[string]any{
				"namespace":   strings.Repeat("a", testCase.namespaceLength),
				"application": "",
				"attributes":  []string{},
			})
			names := requireMap(t, outputs, "resource_name")
			hashedNames := requireMap(t, outputs, "resource_name_hashed")
			launchTemplateName := names["aws_launch_template"].(string)

			require.Len(t, launchTemplateName, 125)
			assert.Regexp(t, `^[A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]$`, launchTemplateName)
			if testCase.hashRequired {
				assert.Regexp(t, `-[0-9a-f]{8}$`, launchTemplateName)
				assert.Equal(t, hashedNames["aws_launch_template"], launchTemplateName)
			} else {
				assert.Equal(t, strings.Repeat("a", 122)+"-lt", launchTemplateName)
				assert.NotEqual(t, hashedNames["aws_launch_template"], launchTemplateName)
			}
		})
	}
}

func assertRuleSatisfiesSamples(
	t testing.TB,
	resourceKey string,
	rule map[string]any,
	name string,
	hashedName string,
) {
	t.Helper()

	minLength := int(rule["min_length"].(float64))
	maxLength := int(rule["max_length"].(float64))
	require.LessOrEqual(t, minLength, maxLength, resourceKey)
	hashLength := int(rule["hash_length"].(float64))
	require.GreaterOrEqual(t, hashLength, 4, resourceKey)
	require.LessOrEqual(t, hashLength, 32, resourceKey)
	require.LessOrEqual(
		t,
		hashLength+len(rule["required_prefix"].(string))+len(rule["required_suffix"].(string)),
		maxLength,
		resourceKey,
	)

	validationPattern := rule["validation_regex"].(string)
	require.True(t, strings.HasPrefix(validationPattern, "^"), resourceKey)
	require.True(t, strings.HasSuffix(validationPattern, "$"), resourceKey)
	validationRegex := regexp.MustCompile(validationPattern)
	assert.True(t, validationRegex.MatchString(name), resourceKey+" normal")
	assert.True(t, validationRegex.MatchString(hashedName), resourceKey+" hashed")
	assert.GreaterOrEqual(t, len(name), minLength, resourceKey+" normal")
	assert.LessOrEqual(t, len(name), maxLength, resourceKey+" normal")
	assert.GreaterOrEqual(t, len(hashedName), minLength, resourceKey+" hashed")
	assert.LessOrEqual(t, len(hashedName), maxLength, resourceKey+" hashed")

	for _, pattern := range interfaceListStrings(t, rule["forbidden_regexes"]) {
		forbidden := regexp.MustCompile(pattern)
		assert.False(t, forbidden.MatchString(name), fmt.Sprintf("%s normal matches %s", resourceKey, pattern))
		assert.False(t, forbidden.MatchString(hashedName), fmt.Sprintf("%s hashed matches %s", resourceKey, pattern))
	}
}

func assertAwsLiteralOutputs(t testing.TB, names map[string]any, hashedNames map[string]any) {
	t.Helper()

	expectedNormal := map[string]string{
		"aws_ecr_repository":                "platform/orders-api",
		"aws_elasticache_replication_group": "cacherg-platform-orders-api",
		"aws_kms_alias":                     "alias/Platform-Orders-API-kmsalias",
		"aws_rds_cluster":                   "rds-platform-orders-api",
		"aws_s3_bucket":                     "s3-platform-orders-api-745beb9e",
		"aws_sns_fifo_topic":                "Platform-Orders-API-sns.fifo",
		"aws_sqs_fifo_queue":                "Platform-Orders-API-sqs.fifo",
	}
	expectedHashed := map[string]string{
		"aws_ecr_repository":                "platform/orders-api-745beb9e",
		"aws_elasticache_replication_group": "cacherg-platform-orders-api-745beb9e",
		"aws_kms_alias":                     "alias/Platform-Orders-API-kmsalias-745beb9e",
		"aws_rds_cluster":                   "rds-platform-orders-api-745beb9e",
		"aws_s3_bucket":                     "s3-platform-orders-api-745beb9e",
		"aws_sns_fifo_topic":                "Platform-Orders-API-sns-745beb9e.fifo",
		"aws_sqs_fifo_queue":                "Platform-Orders-API-sqs-745beb9e.fifo",
	}

	for key, expected := range expectedNormal {
		assert.Equal(t, expected, names[key], key+" normal")
	}
	for key, expected := range expectedHashed {
		assert.Equal(t, expected, hashedNames[key], key+" hashed")
	}
}

func assertAwsForbiddenContracts(t testing.TB, rules map[string]any) {
	t.Helper()

	expected := map[string][]string{
		"aws_db_subnet_group": {"--", "^default$"},
		"aws_kms_alias":       {"^alias/aws/"},
		"aws_lb":              {"^internal-"},
		"aws_s3_bucket": {
			"^xn--",
			"^sthree-",
			"^amzn-s3-demo-",
			"-s3alias$",
			"--ol-s3$",
			"\\.mrap$",
			"--x-s3$",
			"--table-s3$",
			"-an$",
			"\\.\\.",
			"^[0-9]{1,3}(\\.[0-9]{1,3}){3}$",
		},
		"aws_security_group": {"(?i)^sg-"},
	}

	for key, patterns := range expected {
		rule, ok := rules[key].(map[string]any)
		require.True(t, ok, key)
		assert.Equal(t, patterns, interfaceListStrings(t, rule["forbidden_regexes"]), key)
	}
}

func assertModuleIsProviderless(t testing.TB, terraformOptions *terraform.Options) {
	t.Helper()

	providers, err := terraform.RunTerraformCommandAndGetStdoutE(t, terraformOptions, "providers")
	require.NoError(t, err)
	assert.NotContains(t, providers, "registry.terraform.io/")

	state, err := terraform.RunTerraformCommandAndGetStdoutE(t, terraformOptions, "state", "list")
	require.NoError(t, err)
	assert.Empty(t, strings.TrimSpace(state))
}

func interfaceListStrings(t testing.TB, value any) []string {
	t.Helper()

	values, ok := value.([]any)
	require.True(t, ok, "value must be a list, got %T", value)
	result := make([]string, 0, len(values))
	for _, item := range values {
		stringValue, stringOK := item.(string)
		require.True(t, stringOK, "list item must be a string, got %T", item)
		result = append(result, stringValue)
	}

	return result
}
