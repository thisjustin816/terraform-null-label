package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// Test the provider-aware naming behavior added in this fork.
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

	assert.Equal(t, "eg-orders-usw2-p-api", terraform.Output(t, terraformOptions, "base_id"))
	assert.Equal(t, "3b525d61", terraform.Output(t, terraformOptions, "resource_hash"))

	assert.Equal(t, "eg-orders-p-api-lambda", terraform.Output(t, terraformOptions, "aws_lambda_function"))
	assert.Equal(t, "eg-orders-p-api-lambda-3b525d61", terraform.Output(t, terraformOptions, "aws_lambda_function_unique"))
	assert.Equal(t, "eg-orders-usw2-p-api-log", terraform.Output(t, terraformOptions, "aws_cloudwatch_log_group"))
	assert.Equal(t, "s3-eg-orders-p-api-3b525d61", terraform.Output(t, terraformOptions, "aws_s3_bucket"))
	assert.Equal(t, "eg-orders-p-api-sqs.fifo", terraform.Output(t, terraformOptions, "aws_sqs_fifo_queue"))
	assert.Equal(t, "eg-orders-p-api-bedrockagenta", terraform.Output(t, terraformOptions, "aws_dynamic_resource"))

	assert.Equal(t, "kv-eg-orders-us-3b525d61", terraform.Output(t, terraformOptions, "azure_key_vault"))
	assert.Equal(t, "stegordersusw2pa3b525d61", terraform.Output(t, terraformOptions, "azure_storage_account"))

	// resource_codes extends the curated catalog instead of replacing it.
	assert.Equal(t, "s3-eg-orders-p-api-3b525d61", terraform.Output(t, terraformOptions, "override_s3_preserved"))
	assert.Equal(t, "eg-orders-p-api-sqs.fifo", terraform.Output(t, terraformOptions, "override_sqs_preserved"))
	assert.Equal(t, "kv-eg-orders-us-3b525d61", terraform.Output(t, terraformOptions, "override_kv_preserved"))
	// Explicit codes win over both the catalog and auto-generated codes.
	assert.Equal(t, "eg-orders-p-api-fn", terraform.Output(t, terraformOptions, "override_lambda"))
	assert.Equal(t, "eg-orders-p-api-agent", terraform.Output(t, terraformOptions, "override_agent"))

	// Context chaining: inherited code override + catalog persist, the child's own
	// override is not clobbered by inherited rules, and explicit parent rules chain.
	assert.Equal(t, "eg-orders-p-api-fn", terraform.Output(t, terraformOptions, "chain_child_lambda"))
	assert.Equal(t, "eg-orders-p-api-q", terraform.Output(t, terraformOptions, "chain_child_sqs"))
	assert.Equal(t, "s3-eg-orders-p-api-99eac3e5", terraform.Output(t, terraformOptions, "chain_child_s3"))
	assert.Equal(t, "eg-orders-usw2-p-api-log", terraform.Output(t, terraformOptions, "chain_child_log"))
	assert.Equal(t, "billing", terraform.Output(t, terraformOptions, "chain_child_application_tag"))
	assert.Equal(t, "eg-billing-usw2-p-api", terraform.Output(t, terraformOptions, "chain_child_id_tag"))
}
