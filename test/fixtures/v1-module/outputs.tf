output "id" {
  value       = local.enabled ? local.id : ""
  description = "Disambiguated ID string restricted to `id_length_limit` characters in total"
}

output "id_resource" {
  value       = local.enabled ? local.id_with_resource_codes : {}
  description = "Resource-specific ID strings with resource codes, naming restrictions, length limits, and required global hash suffixes applied."
}

output "id_resource_unique" {
  value       = local.enabled ? local.resource_label_unique_ids : {}
  description = "Resource-specific ID strings with deterministic hash suffixes applied, including for resources that do not require global uniqueness."
}

output "resource_hash" {
  value       = local.enabled ? local.resource_hash : ""
  description = "Deterministic hash base used by resource labels that need a global uniqueness suffix."
}

output "resource_label_rules" {
  value       = local.enabled ? local.normalized_resource_label_rules : {}
  description = "Normalized resource naming rules used to produce the resource-specific IDs."
}

output "id_for_keyvault" {
  value       = local.enabled ? local.id_for_keyvault : ""
  description = "Disambiguated ID string generating unique name for Azure Key Vault."
}

output "id_for_storage_account" {
  value       = local.enabled ? local.id_for_storage_account : ""
  description = "Disambiguated ID string generating unique name for Azure Storage Accounts"
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
