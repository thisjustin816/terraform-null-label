package test

import (
	"path/filepath"
	"regexp"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestMigrationDocumentationContract(t *testing.T) {
	t.Parallel()

	root := repositoryRoot(t)
	migration := readTextFile(t, filepath.Join(root, "docs", "migration-v2.md"))
	readmeSource := readTextFile(t, filepath.Join(root, "README.yaml"))
	readmeTemplate := readTextFile(t, filepath.Join(root, ".github", "README.md.gotmpl"))
	readme := readTextFile(t, filepath.Join(root, "README.md"))

	manifest := readJSONFile[fixtureManifest](t, filepath.Join(v1FixtureDirectory(t), "manifest.json"))
	assert.Equal(t, v1FixtureTag, manifest.Tag)
	assert.Equal(t, v1FixtureTagObject, manifest.TagObject)
	assert.Equal(t, v1FixtureCommit, manifest.Commit)

	for _, required := range []string{
		">= 1.3.2, < 2.0.0",
		"All 226 v1 Azure keys",
		"`resource_metadata`",
		"`resource_code_overrides`",
		"generated AWS codes from `aws_resource_types`, built-in resource codes, and explicit `resource_codes`",
		"rg-platform-orders-ue-p-api",
		"asp-platform-orders-ue-p-api",
		"never released",
		"They remain deprecated throughout v2 and are removed in v3.0.0.",
	} {
		assert.Contains(t, migration, required)
	}
	for _, removed := range []string{
		"BEGIN GENERATED CATALOG MIGRATION MATRIX",
		"Complete catalog migration matrix",
		"code_provenance",
		"constraint_provenance_url",
		"lifecycle_provenance_urls",
		"verified_on",
	} {
		assert.NotContains(t, migration, removed)
	}

	assertMigrationTables(t, migration)
	assertReadmeDocumentationContract(t, readmeSource, readmeTemplate, readme)
	assertExportDocumentationContract(t, root)
}

func assertMigrationTables(t testing.TB, migration string) {
	t.Helper()

	assert.Equal(t, [][]string{
		{"id_resource", "resource_name", "validated physical names"},
		{"id_resource", "id_with_resource_code", "logical labels for every resource code"},
		{"id_resource_unique", "resource_name_hashed", "hashed validated physical names"},
		{"resource_label_rules", "resource_label_rules", "typed v2 rule schema"},
		{"resource_hash", "resource_hash", "structured raw-label seed encoding"},
	}, trimmedMarkedTable(t, migration, "<!-- BEGIN OUTPUT MIGRATIONS -->", "<!-- END OUTPUT MIGRATIONS -->"))

	ruleRows := trimmedMarkedTable(t, migration, "<!-- BEGIN RULE FIELD MIGRATIONS -->", "<!-- END RULE FIELD MIGRATIONS -->")
	require.Len(t, ruleRows, 13)
	assert.Equal(t, []string{"code", "resource_codes", "Move the abbreviation out of the rule object."}, ruleRows[0])
	expectedRuleFields := []string{
		"code",
		"code_position",
		"regex_replace_chars",
		"label_value_case",
		"hash_length",
		"required_suffix",
		"trim_chars",
		"collapse_regex",
		"collapse_replacement",
		"delimiter",
		"globally_unique",
		"include_region",
		"id_length_limit",
	}
	actualRuleFields := make([]string, 0, len(ruleRows))
	for _, row := range ruleRows {
		require.Len(t, row, 3)
		actualRuleFields = append(actualRuleFields, row[0])
	}
	assert.Equal(t, expectedRuleFields, actualRuleFields)

	assert.Equal(t, [][]string{{"aws_elasticache_replication_group", "redis", "cacherg"}},
		trimmedMarkedTable(t, migration, "<!-- BEGIN AWS CODE CORRECTIONS -->", "<!-- END AWS CODE CORRECTIONS -->"))

	assert.Equal(t, [][]string{
		{"azure_enclave", "ve"},
		{"azure_enclave_community", "cmt"},
		{"azure_enclave_community_endpoint", "ce"},
		{"azure_enclave_connection", "ec"},
		{"azure_enclave_dedicated_hub", "dh"},
		{"azure_enclave_endpoint", "ee"},
		{"azure_enclave_transit_hub", "th"},
		{"azure_enclave_workload", "wl"},
		{"azure_postgresql_flexible_server", "pgsql"},
	}, trimmedMarkedTable(t, migration, "<!-- BEGIN AZURE ADDITIONS -->", "<!-- END AZURE ADDITIONS -->"))

	aliasRows := trimmedMarkedTable(t, migration, "<!-- BEGIN AZURE COMPATIBILITY ALIASES -->", "<!-- END AZURE COMPATIBILITY ALIASES -->")
	require.Len(t, aliasRows, 6)
	for index, alias := range []string{
		"azure_api_management",
		"azure_container_group",
		"azure_kubernetes_cluster",
		"azure_logic_app_integration_account",
		"azure_shared_image_gallery",
		"azure_user_assigned_identity",
	} {
		assert.Equal(t, alias, aliasRows[index][0])
		assert.Equal(t, azureCompatibilityAliases()[alias], aliasRows[index][1])
	}

	assert.Equal(t, [][]string{
		{"id_for_keyvault", "azure_key_vault", "resource_name_hashed", "kv-platform-ord-eec9d15d", "kv-platform-ord-745beb9e"},
		{"id_for_storage_account", "azure_storage_account", "resource_name_hashed", "stplatformorderseec9d15d", "stplatformorders745beb9e"},
	}, trimmedMarkedTable(t, migration, "<!-- BEGIN LEGACY ALIAS HASH DELTAS -->", "<!-- END LEGACY ALIAS HASH DELTAS -->"))
}

func trimmedMarkedTable(t testing.TB, document, startMarker, endMarker string) [][]string {
	t.Helper()

	rows := parseMarkedMarkdownTable(t, document, startMarker, endMarker)
	for rowIndex := range rows {
		for columnIndex := range rows[rowIndex] {
			rows[rowIndex][columnIndex] = trimMarkdownCode(rows[rowIndex][columnIndex])
		}
	}

	return rows
}

func parseMarkedMarkdownTable(t testing.TB, document, startMarker, endMarker string) [][]string {
	t.Helper()

	start := strings.Index(document, startMarker)
	end := strings.Index(document, endMarker)
	require.GreaterOrEqual(t, start, 0, startMarker)
	require.Greater(t, end, start, endMarker)

	rows := make([][]string, 0)
	headerSeen := false
	separatorPattern := regexp.MustCompile(`^:?-+:?$`)
	for _, line := range strings.Split(document[start+len(startMarker):end], "\n") {
		line = strings.TrimSpace(line)
		if !strings.HasPrefix(line, "|") || !strings.HasSuffix(line, "|") {
			continue
		}
		cells := strings.Split(strings.Trim(line, "|"), "|")
		for index := range cells {
			cells[index] = strings.TrimSpace(cells[index])
		}
		if len(cells) == 0 || separatorPattern.MatchString(cells[0]) {
			continue
		}
		if !headerSeen {
			headerSeen = true
			continue
		}
		rows = append(rows, cells)
	}

	return rows
}

func trimMarkdownCode(value string) string {
	return strings.Trim(strings.TrimSpace(value), "`")
}

func assertReadmeDocumentationContract(t testing.TB, source, template, generated string) {
	t.Helper()

	for _, document := range []string{source, generated} {
		requireOrderedText(t, document, []string{
			"### Upgrade notice",
			"### Basic usage",
			"### Naming layers",
			"### Physical names and required keys",
			"### Resource rules",
			"### Structured groups",
			"### Deterministic hashing",
			"### Azure naming policy",
			"### AWS naming and tag policy",
			"### Context chaining",
			"### Generated AWS types and custom codes",
			"### Version pinning",
			"### References",
		})
		assert.Contains(t, document, "docs/migration-v2.md")
		assert.Contains(t, document, ">= 1.3.2, < 2.0.0")
		assert.Contains(t, document, "git::https://github.com/thisjustin816/terraform-null-label.git?ref=v2.0.0")
		for _, removed := range []string{"id_resource", "id_resource_unique", "globally_unique", "include_region"} {
			assert.NotContains(t, document, removed)
		}
	}

	for _, removed := range []string{
		"code_provenance",
		"constraint_provenance_url",
		"lifecycle_provenance_urls",
		"provider_constraints",
		"curated_constraints",
		"legacy_rule_ignored",
		"verified_on",
	} {
		assert.NotContains(t, source, removed)
	}

	for _, required := range []string{
		"Microsoft Cloud Adoption Framework",
		"AWS does not publish a single cross-service physical-name convention",
		"resource_code_overrides",
		"resource-group's ARM metadata location",
		"personal, sensitive, or confidential information",
		"https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming",
		"https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/overview#which-location-should-i-use-for-my-resource-group",
		"https://docs.aws.amazon.com/whitepapers/latest/tagging-best-practices/tagging-best-practices.html",
		"https://docs.aws.amazon.com/tag-editor/latest/userguide/best-practices-and-strats.html",
	} {
		assert.Contains(t, source, required)
		assert.Contains(t, generated, required)
	}

	assert.Contains(t, template, "go test -count=1 -timeout 20m .")
	assert.NotContains(t, template, "-run")
	assert.NotContains(t, template, "Focused tests")
	assert.Contains(t, generated, "go test -count=1 -timeout 20m .")
	assert.NotContains(t, generated, "-run")
}

func assertExportDocumentationContract(t testing.TB, root string) {
	t.Helper()

	rootVariables := readTextFile(t, filepath.Join(root, "variables.tf"))
	exportContext := readTextFile(t, filepath.Join(root, "exports", "context.tf"))
	variablePattern := regexp.MustCompile(`(?m)^variable "([^"]+)"`)
	rootNames := regexpCaptureSet(variablePattern, rootVariables)
	assert.Len(t, rootNames, 25)

	moduleEnd := strings.Index(exportContext, "\n}\n\n# Copy contents")
	require.Greater(t, moduleEnd, 0)
	forwardPattern := regexp.MustCompile(`(?m)^\s+([a-z_]+)\s+=\s+var\.([a-z_]+)\s*$`)
	forwarded := make(map[string]struct{})
	for _, match := range forwardPattern.FindAllStringSubmatch(exportContext[:moduleEnd], -1) {
		assert.Equal(t, match[1], match[2])
		forwarded[match[1]] = struct{}{}
	}
	assert.Equal(t, rootNames, forwarded)
	assert.Contains(t, exportContext, "git::https://github.com/thisjustin816/terraform-null-label.git?ref=v2.0.0")
	for _, removed := range []string{"id_resource", "id_resource_unique", "globally_unique", "include_region"} {
		assert.NotContains(t, exportContext, removed)
	}
}

func requireOrderedText(t testing.TB, document string, values []string) {
	t.Helper()

	previous := -1
	for _, value := range values {
		index := strings.Index(document, value)
		require.Greater(t, index, previous, value)
		previous = index
	}
}
