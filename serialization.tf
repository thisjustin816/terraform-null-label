locals {
  decoded_context = jsondecode(base64decode(var.context))
  default_context = local.defaults
  input_context   = merge(local.default_context, local.decoded_context)

  context_is_empty       = length(keys(local.decoded_context)) == 0
  context_schema_version = try(tonumber(local.decoded_context.schema_version), 1)
  context_is_v2          = !local.context_is_empty && local.context_schema_version >= 2

  decoded_label_source = try(tostring(local.decoded_context.label_source), "")
  label_source = (
    local.context_is_empty ? "raw" :
    local.decoded_label_source == "legacy_fallback" ? "legacy_fallback" :
    local.context_is_v2 ? "raw" : "legacy_fallback"
  )

  decoded_labels_raw = try(local.decoded_context.labels_raw, {})

  decoded_raw_namespace   = try(tostring(local.decoded_labels_raw.namespace), null)
  decoded_raw_region      = try(tostring(local.decoded_labels_raw.region), null)
  decoded_raw_environment = try(tostring(local.decoded_labels_raw.environment), null)
  decoded_raw_application = try(tostring(local.decoded_labels_raw.application), null)
  decoded_raw_attributes = try([
    for value in tolist(local.decoded_labels_raw.attributes) : tostring(value)
  ], null)

  decoded_legacy_namespace   = try(tostring(local.decoded_context.namespace), null)
  decoded_legacy_region      = try(tostring(local.decoded_context.region), null)
  decoded_legacy_environment = try(tostring(local.decoded_context.environment), null)
  decoded_legacy_application = try(tostring(local.decoded_context.application), null)
  decoded_legacy_attributes = try([
    for value in tolist(local.decoded_context.attributes) : tostring(value)
  ], [])

  context_raw_namespace   = local.decoded_raw_namespace == null ? local.decoded_legacy_namespace : local.decoded_raw_namespace
  context_raw_region      = local.decoded_raw_region == null ? local.decoded_legacy_region : local.decoded_raw_region
  context_raw_environment = local.decoded_raw_environment == null ? local.decoded_legacy_environment : local.decoded_raw_environment
  context_raw_application = local.decoded_raw_application == null ? local.decoded_legacy_application : local.decoded_raw_application
  context_raw_attributes  = local.decoded_raw_attributes == null ? local.decoded_legacy_attributes : local.decoded_raw_attributes

  labels_raw = {
    namespace   = var.namespace == null ? local.context_raw_namespace : var.namespace
    region      = var.region == null ? local.context_raw_region : var.region
    environment = var.environment == null ? local.context_raw_environment : var.environment
    application = var.application == null ? local.context_raw_application : var.application
    attributes  = compact(distinct(concat(local.context_raw_attributes, var.attributes)))
  }

  decoded_resource_rules_raw = try({
    for resource_type, rule in local.decoded_context.resource_rules :
    resource_type => rule if local.context_is_v2
  }, {})
  decoded_resource_rules = {
    for resource_type, rule in local.decoded_resource_rules_raw : tostring(resource_type) => merge(
      try(rule.code_position, null) == null ? {} : {
        code_position = tostring(rule.code_position)
      },
      try(rule.label_groups, null) == null ? {} : {
        label_groups = [
          for group in tolist(rule.label_groups) : [
            for label in tolist(group) : tostring(label)
          ]
        ]
      },
      try(rule.component_delimiter, null) == null ? {} : {
        component_delimiter = tostring(rule.component_delimiter)
      },
      try(rule.group_delimiter, null) == null ? {} : {
        group_delimiter = tostring(rule.group_delimiter)
      },
      try(rule.regex_replace_chars, null) == null ? {} : {
        regex_replace_chars = tostring(rule.regex_replace_chars)
      },
      try(rule.label_value_case, null) == null ? {} : {
        label_value_case = tostring(rule.label_value_case)
      },
      try(rule.trim_chars, null) == null ? {} : {
        trim_chars = tostring(rule.trim_chars)
      },
      try(rule.collapse_regex, null) == null ? {} : {
        collapse_regex = tostring(rule.collapse_regex)
      },
      try(rule.collapse_replacement, null) == null ? {} : {
        collapse_replacement = tostring(rule.collapse_replacement)
      },
      try(rule.required_prefix, null) == null ? {} : {
        required_prefix = tostring(rule.required_prefix)
      },
      try(rule.required_suffix, null) == null ? {} : {
        required_suffix = tostring(rule.required_suffix)
      },
      try(rule.min_length, null) == null ? {} : {
        min_length = tonumber(rule.min_length)
      },
      try(rule.max_length, null) == null ? {} : {
        max_length = tonumber(rule.max_length)
      },
      try(rule.validation_regex, null) == null ? {} : {
        validation_regex = tostring(rule.validation_regex)
      },
      try(rule.forbidden_regexes, null) == null ? {} : {
        forbidden_regexes = [
          for pattern in tolist(rule.forbidden_regexes) : tostring(pattern)
        ]
      },
      try(rule.hash_policy, null) == null ? {} : {
        hash_policy = tostring(rule.hash_policy)
      },
      try(rule.hash_length, null) == null ? {} : {
        hash_length = tonumber(rule.hash_length)
      },
    )
  }

  direct_resource_rules = {
    for resource_type, rule in coalesce(var.resource_label_rules, {}) :
    resource_type => {
      for attribute, value in rule : attribute => value if value != null
    }
  }

  merged_resource_rules = {
    for resource_type in setunion(
      toset(keys(local.decoded_resource_rules)),
      toset(keys(local.direct_resource_rules)),
      ) : resource_type => merge(
      try(local.decoded_resource_rules[resource_type], {}),
      try(local.direct_resource_rules[resource_type], {}),
    )
  }

  legacy_resource_label_rules = try(merge({}, local.decoded_context.resource_label_rules), {})

  legacy_resource_codes_present = can(local.decoded_context.resource_codes)
  decoded_legacy_resource_codes = try({
    for resource_type, code in local.decoded_context.resource_codes :
    tostring(resource_type) => tostring(code)
  }, {})

  decoded_resource_code_overrides = local.context_is_v2 ? try({
    for resource_type, code in local.decoded_context.resource_code_overrides :
    tostring(resource_type) => tostring(code)
  }, {}) : {}

  normalized_legacy_azure_resource_codes = {
    for resource_type, code in local.decoded_legacy_resource_codes :
    local.azure_v1_to_v2_resource_key_map[resource_type] => code
    if contains(keys(local.azure_v1_to_v2_resource_key_map), resource_type)
  }

  legacy_resource_codes_without_legacy_azure_keys = {
    for resource_type, code in local.decoded_legacy_resource_codes :
    resource_type => code
    if !contains(keys(local.azure_v1_to_v2_resource_key_map), resource_type)
  }

  normalized_legacy_resource_codes = merge(
    local.normalized_legacy_azure_resource_codes,
    local.legacy_resource_codes_without_legacy_azure_keys,
  )

  v1_default_resource_code_exceptions = {
    aws_elasticache_replication_group = "redis"
  }

  decoded_context_aws_resource_type_keys = toset(try([
    for resource_type in tolist(local.decoded_context.aws_resource_types) :
    startswith(tostring(resource_type), "aws_") ? tostring(resource_type) : "aws_${tostring(resource_type)}"
  ], []))

  decoded_context_aws_resource_type_parts = {
    for resource_type in local.decoded_context_aws_resource_type_keys :
    resource_type => split("_", replace(resource_type, "/^aws_/", ""))
  }

  decoded_context_generated_aws_codes = {
    for resource_type, parts in local.decoded_context_aws_resource_type_parts :
    resource_type => lower(join("", concat([parts[0]], [
      for part in slice(parts, 1, length(parts)) : substr(part, 0, 1)
    ])))
  }

  inherited_resource_code_overrides = local.context_is_v2 ? local.decoded_resource_code_overrides : {
    for resource_type, code in local.normalized_legacy_resource_codes :
    resource_type => code
    if !try(local.default_resource_codes[resource_type] == code, false) &&
    !try(local.decoded_context_generated_aws_codes[resource_type] == code, false) &&
    !try(local.v1_default_resource_code_exceptions[resource_type] == code, false)
  }

  resource_code_overrides = merge(
    local.inherited_resource_code_overrides,
    coalesce(var.resource_codes, {}),
  )

  output_context_base = {
    schema_version          = 2
    label_source            = local.label_source
    labels_raw              = local.labels_raw
    resource_rules          = local.resource_rule_overrides
    enabled                 = local.enabled
    namespace               = local.namespace
    region                  = local.region
    region_code             = local.region_code
    environment             = local.environment
    environment_code        = local.environment_code
    application             = local.application
    delimiter               = local.delimiter
    attributes              = local.attributes
    tags                    = local.tags
    additional_tag_map      = local.additional_tag_map
    label_order             = local.label_order
    region_codes            = local.region_codes
    resource_code_overrides = local.resource_code_overrides
    resource_label_rules    = local.legacy_resource_label_rules
    resource_hash_length    = local.resource_hash_length
    resource_hash_values    = local.resource_hash_values
    aws_resource_types      = local.aws_resource_types
    environment_codes       = local.environment_codes
    regex_replace_chars     = local.regex_replace_chars
    id_length_limit         = local.id_length_limit
    label_key_case          = local.label_key_case
    label_value_case        = local.label_value_case
    labels_as_tags          = local.labels_as_tags
    descriptor_formats      = local.descriptor_formats
  }

  legacy_output_context = {
    for key, value in { resource_codes = try(local.decoded_context.resource_codes, {}) } :
    key => value if local.legacy_resource_codes_present
  }

  output_context = merge(local.output_context_base, local.legacy_output_context)

  output_context_raw        = local.output_context
  output_context_serialized = base64encode(jsonencode(local.output_context_raw))
}
