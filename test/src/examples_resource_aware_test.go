package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestExamplesResourceAware(t *testing.T) {
	t.Parallel()

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/resource-aware"

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		TerraformDir: tempTestFolder,
		Upgrade:      true,
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	example := requireMap(t, terraform.OutputAll(t, terraformOptions), "example")
	assert.Equal(t, "eg-orders-usw2-p-api", example["base_id"])
	assert.Equal(t, "1496e2c3", example["hash"])

	assertSelectedStringMap(t, map[string]string{
		"aws_bedrockagent_agent": "bedrockagenta",
		"aws_ecr_repository":     "ecr",
		"aws_lambda_function":    "fn",
		"aws_s3_bucket":          "s3",
		"azure_storage_account":  "st",
		"custom_service":         "svc",
	}, requireMap(t, example, "codes"))
	assertSelectedStringMap(t, map[string]string{
		"aws_ecr_repository":    "eg-orders-p-api-ecr",
		"aws_lambda_function":   "eg-orders-p-api-fn",
		"aws_s3_bucket":         "eg-orders-p-api-s3",
		"azure_storage_account": "st-eg-orders-usw2-p-api",
		"custom_service":        "svc-eg-orders-usw2-p-api",
	}, requireMap(t, example, "logical"))
	assert.Equal(t, map[string]any{
		"aws_ecr_repository":    "eg/orders-api",
		"aws_lambda_function":   "eg-orders-p-api-fn",
		"aws_s3_bucket":         "s3-eg-orders-p-api-1496e2c3",
		"azure_storage_account": "stegordersusw2pa1496e2c3",
	}, requireMap(t, example, "normal"))
	assert.Equal(t, map[string]any{
		"aws_ecr_repository":    "eg/orders-api-1496e2c3",
		"aws_lambda_function":   "eg-orders-p-api-fn-1496e2c3",
		"aws_s3_bucket":         "s3-eg-orders-p-api-1496e2c3",
		"azure_storage_account": "stegordersusw2pa1496e2c3",
	}, requireMap(t, example, "hashed"))

	customAbsent, ok := example["custom_physical_name_absent"].(bool)
	require.True(t, ok)
	assert.True(t, customAbsent)
	assert.Empty(t, requireMap(t, example, "errors"))
}
