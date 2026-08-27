package test

import (
	"path/filepath"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestRequiredResourceNamesValid(t *testing.T) {
	t.Parallel()

	terraformOptions := requiredResourceNamesTerraformOptions(t, []string{
		"aws_ecr_repository",
		"azure_storage_account",
		"custom_path",
	})
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	normal := terraform.OutputMap(t, terraformOptions, "resource_name")
	hashed := terraform.OutputMap(t, terraformOptions, "resource_name_hashed")
	for _, key := range []string{"aws_ecr_repository", "azure_storage_account", "custom_path"} {
		require.Contains(t, normal, key)
		require.Contains(t, hashed, key)
	}
}

func TestRequiredResourceNamesFailures(t *testing.T) {
	t.Parallel()

	tests := map[string]struct {
		required []string
		errors   []string
	}{
		"unknown": {
			required: []string{"missing_service"},
			errors:   []string{"missing_service: unknown resource name"},
		},
		"non-renderable": {
			required: []string{"aws_vpc"},
			errors:   []string{"aws_vpc: resource is not renderable"},
		},
		"invalid": {
			required: []string{"custom_invalid"},
			errors: []string{
				"custom_invalid: normal candidate fails final regex",
				"hashed candidate fails final regex",
			},
		},
		"combined": {
			required: []string{"missing_service", "custom_invalid", "aws_vpc"},
			errors: []string{
				"aws_vpc: resource is not renderable",
				"custom_invalid: normal candidate fails final regex",
				"hashed candidate fails final regex",
				"missing_service: unknown resource name",
			},
		},
	}

	for name, testCase := range tests {
		t.Run(name, func(t *testing.T) {
			t.Parallel()

			terraformOptions := requiredResourceNamesTerraformOptions(t, testCase.required)
			_, err := terraform.InitAndPlanE(t, terraformOptions)
			require.Error(t, err)
			message := strings.Join(strings.Fields(err.Error()), " ")
			assert.Contains(t, message, "Required resource names failed")
			for _, expected := range testCase.errors {
				assert.Contains(t, message, expected)
			}
		})
	}
}

func requiredResourceNamesTerraformOptions(t testing.TB, required []string) *terraform.Options {
	t.Helper()

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(
		t,
		"../../",
		filepath.ToSlash(filepath.Join("test", "fixtures", "required-resource-names")),
	)

	return &terraform.Options{
		TerraformDir: tempTestFolder,
		NoColor:      true,
		Vars: map[string]any{
			"required_resource_names": required,
		},
	}
}
