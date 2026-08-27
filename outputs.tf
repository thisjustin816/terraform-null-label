output "id" {
  value       = local.enabled ? local.id : ""
  description = "Disambiguated ID string restricted to `id_length_limit` characters in total"
}

output "resource_codes" {
  value       = local.enabled ? local.normalized_resource_codes : {}
  description = "Normalized resource abbreviations keyed by provider-qualified resource type."
}

output "id_with_resource_code" {
  value       = local.enabled ? local.id_with_resource_code : {}
  description = "Logical code-bearing labels. These values do not claim provider naming validity."
}

output "resource_name" {
  value       = local.enabled ? local.resource_name : {}
  description = "Provider-valid physical names produced by complete resource rules."

  precondition {
    condition = !local.enabled || (
      length(local.caller_renderer_completeness_errors) == 0 &&
      length(local.required_resource_name_errors) == 0
    )
    error_message = join(" ", compact([
      length(local.caller_renderer_completeness_errors) == 0 ? "" : "Incomplete renderable resource_label_rules: ${join("; ", [for resource_type in sort(keys(local.caller_renderer_completeness_errors)) : "${resource_type}: ${join(", ", local.caller_renderer_completeness_errors[resource_type])}"])}.",
      length(local.required_resource_name_errors) == 0 ? "" : "Required resource names failed: ${join("; ", [for resource_type in sort(keys(local.required_resource_name_errors)) : "${resource_type}: ${join(", ", local.required_resource_name_errors[resource_type])}"])}.",
    ]))
  }
}

output "resource_name_hashed" {
  value       = local.enabled ? local.resource_name_hashed : {}
  description = "Provider-valid physical names with deterministic hashes applied."

  precondition {
    condition = !local.enabled || (
      length(local.caller_renderer_completeness_errors) == 0 &&
      length(local.required_resource_name_errors) == 0
    )
    error_message = join(" ", compact([
      length(local.caller_renderer_completeness_errors) == 0 ? "" : "Incomplete renderable resource_label_rules: ${join("; ", [for resource_type in sort(keys(local.caller_renderer_completeness_errors)) : "${resource_type}: ${join(", ", local.caller_renderer_completeness_errors[resource_type])}"])}.",
      length(local.required_resource_name_errors) == 0 ? "" : "Required resource names failed: ${join("; ", [for resource_type in sort(keys(local.required_resource_name_errors)) : "${resource_type}: ${join(", ", local.required_resource_name_errors[resource_type])}"])}.",
    ]))
  }
}

output "resource_name_errors" {
  value       = local.enabled ? local.resource_name_errors : {}
  description = "Physical-name validation errors keyed by resource type."
}

output "resource_hash" {
  value       = local.enabled ? local.resource_hash : ""
  description = "Deterministic hash seed used to provide collision-resistant resource-name suffixes."
}

output "resource_label_rules" {
  value = {
    for resource_type, rule in local.effective_resource_label_rules :
    resource_type => rule if local.enabled
  }
  description = "Effective normalized v2 resource rules keyed by resource type."
}

output "id_for_keyvault" {
  value       = local.enabled ? try(local.resource_name_hashed["azure_key_vault"], "") : ""
  description = "Deprecated alias for `resource_name_hashed.azure_key_vault`."
}

output "id_for_storage_account" {
  value       = local.enabled ? try(local.resource_name_hashed["azure_storage_account"], "") : ""
  description = "Deprecated alias for `resource_name_hashed.azure_storage_account`."
}

output "id_full" {
  value       = local.enabled ? local.id_full : ""
  description = "ID string not restricted in length"
}

output "enabled" {
  value       = local.enabled
  description = "True if module is enabled, false otherwise"
}

output "namespace" {
  value       = local.enabled ? local.namespace : ""
  description = "Normalized namespace"
}

output "environment" {
  value       = local.enabled ? local.environment : ""
  description = "Normalized environment"
}

output "region" {
  value       = local.enabled ? local.region : ""
  description = "Normalized region"
}

output "application" {
  value       = local.enabled ? local.application : ""
  description = "Normalized application"
}

output "delimiter" {
  value       = local.enabled ? local.delimiter : ""
  description = "Delimiter between generated ID elements."
}

output "attributes" {
  value       = local.enabled ? local.attributes : []
  description = "List of attributes"
}

output "tags" {
  value       = local.enabled ? local.tags : {}
  description = "Normalized Tag map"
}

output "additional_tag_map" {
  value       = local.additional_tag_map
  description = "The merged additional_tag_map"
}

output "label_order" {
  value       = local.label_order
  description = "The naming order actually used to create the ID"
}

output "regex_replace_chars" {
  value       = local.regex_replace_chars
  description = "The regex_replace_chars actually used to create the ID"
}

output "id_length_limit" {
  value       = local.id_length_limit
  description = "The id_length_limit actually used to create the ID, with `0` meaning unlimited"
}

output "tags_as_list_of_maps" {
  value       = local.tags_as_list_of_maps
  description = <<-EOT
    This is a list with one map for each `tag`. Each map contains the tag `key`,
    `value`, and contents of `var.additional_tag_map`. Used in the rare cases
    where resources need additional configuration information for each tag.
    EOT
}

output "descriptors" {
  value       = local.descriptors
  description = "Map of descriptors as configured by `descriptor_formats`"
}

output "normalized_context" {
  value       = local.output_context_raw
  description = "Normalized context of this module"
}

output "context" {
  value       = local.output_context_serialized
  description = <<-EOT
  Base64-encoded normalized context of this module, to be used as context input to other label modules.
EOT
}
