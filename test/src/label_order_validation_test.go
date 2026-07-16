package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestLabelOrderValidation(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name       string
		labelOrder []string
		wantError  bool
	}{
		{
			name:       "supported labels",
			labelOrder: []string{"application", "namespace"},
		},
		{
			name:       "empty list preserves fallback behavior",
			labelOrder: []string{},
		},
		{
			name:       "unsupported label",
			labelOrder: []string{"namespace", "unsupported"},
			wantError:  true,
		},
		{
			name:       "duplicate label",
			labelOrder: []string{"namespace", "namespace"},
			wantError:  true,
		},
	}

	for _, testCase := range testCases {
		t.Run(testCase.name, func(t *testing.T) {
			t.Parallel()

			tempTestFolder := test_structure.CopyTerraformFolderToTemp(
				t,
				"../../",
				"test/fixtures/label-order-validation",
			)
			terraformOptions := &terraform.Options{
				TerraformDir: tempTestFolder,
				Vars: map[string]interface{}{
					"label_order": testCase.labelOrder,
				},
			}

			_, err := terraform.InitAndPlanE(t, terraformOptions)
			if testCase.wantError {
				require.Error(t, err)
				assert.Contains(t, err.Error(), "The label_order may contain only supported labels, without duplicates")
				return
			}

			require.NoError(t, err)
		})
	}
}
