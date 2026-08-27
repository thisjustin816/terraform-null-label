locals {
  normalized_resource_codes = merge(
    local.requested_aws_resource_codes,
    local.default_resource_codes,
    local.resource_code_overrides,
  )

  resource_providers = {
    for resource_type in setunion(
      toset(keys(local.normalized_resource_codes)),
      toset(keys(local.default_resource_label_rules)),
      toset(keys(local.resource_rule_overrides)),
    ) :
    resource_type => (
      startswith(resource_type, "aws_") ? "aws" :
      startswith(resource_type, "azure_") ? "azure" : "other"
    )
  }

  id_with_resource_code = {
    for resource_type, code in local.normalized_resource_codes :
    resource_type => join(local.delimiter, compact(
      local.resource_providers[resource_type] == "aws" ? [local.id_without_region, code] : [code, local.id]
    ))
  }

  resource_rule_overrides = {
    for resource_type, rule in local.input.resource_label_rules :
    resource_type => {
      for attribute, value in rule : attribute => value if value != null
    }
  }

  default_resource_label_rules = merge(
    local.aws_resource_label_rules,
    local.azure_resource_label_rules,
  )

  effective_resource_label_rule_keys = setunion(
    toset(keys(local.default_resource_label_rules)),
    toset(keys(local.resource_rule_overrides)),
  )

  resource_label_rule_defaults = {
    for resource_type in local.effective_resource_label_rule_keys :
    resource_type => {
      code_position        = local.resource_providers[resource_type] == "aws" ? "suffix" : "prefix"
      label_groups         = [local.label_order]
      component_delimiter  = local.delimiter
      group_delimiter      = local.delimiter
      regex_replace_chars  = local.regex_replace_chars
      label_value_case     = local.label_value_case
      trim_chars           = ""
      collapse_regex       = ""
      collapse_replacement = ""
      required_prefix      = ""
      required_suffix      = ""
      min_length           = null
      max_length           = null
      validation_regex     = null
      forbidden_regexes    = []
      hash_policy          = "never"
      hash_length          = null
    }
  }

  resource_label_rules_before_resolved_values = {
    for resource_type in local.effective_resource_label_rule_keys :
    resource_type => merge(
      local.resource_label_rule_defaults[resource_type],
      try(local.default_resource_label_rules[resource_type], {}),
      try(local.resource_rule_overrides[resource_type], {}),
    )
  }

  effective_resource_label_rules = {
    for resource_type, rule in local.resource_label_rules_before_resolved_values :
    resource_type => merge(
      rule,
      {
        code = try(local.normalized_resource_codes[resource_type], "")
        hash_length = (
          try(rule.hash_length, null) == null ? local.resource_hash_length : rule.hash_length
        )
      },
    )
  }

}
