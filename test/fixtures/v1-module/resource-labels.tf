locals {
  aws_resource_type_keys = toset([
    for resource_type in local.aws_resource_types :
    length(regexall("^aws_", resource_type)) > 0 ? resource_type : "aws_${resource_type}"
  ])

  aws_resource_type_parts = {
    for resource_type in local.aws_resource_type_keys :
    resource_type => split("_", replace(resource_type, "/^aws_/", ""))
  }

  requested_aws_resource_codes = {
    for resource_type, parts in local.aws_resource_type_parts :
    resource_type => lower(join("", concat([parts[0]], [
      for part in slice(parts, 1, length(parts)) : substr(part, 0, 1)
    ])))
  }

  generic_resource_label_rule = {
    code                 = ""
    code_position        = "prefix"
    delimiter            = local.delimiter
    regex_replace_chars  = local.regex_replace_chars
    label_value_case     = local.label_value_case
    id_length_limit      = local.id_length_limit
    globally_unique      = false
    hash_length          = local.resource_hash_length
    include_region       = true
    required_suffix      = ""
    trim_chars           = ""
    collapse_regex       = ""
    collapse_replacement = ""
  }

  resource_label_rule_defaults = {
    for resource_type, code in local.resource_codes :
    resource_type => merge(local.generic_resource_label_rule, {
      code           = code
      code_position  = length(regexall("^aws_", resource_type)) > 0 ? "suffix" : "prefix"
      include_region = length(regexall("^aws_", resource_type)) > 0 ? false : true
    })
  }

  resource_label_rule_keys = setunion(
    keys(local.resource_label_rule_defaults),
    keys(local.default_resource_label_rules),
    keys(local.resource_label_rules),
  )

  normalized_resource_label_rules = {
    for resource_type in local.resource_label_rule_keys :
    resource_type => merge(
      local.generic_resource_label_rule,
      try(local.resource_label_rule_defaults[resource_type], {}),
      try(local.default_resource_label_rules[resource_type], {}),
      try(local.resource_label_rules[resource_type], {}),
    )
  }

  resource_hash_seed = join(":", compact(concat([local.id_full], local.resource_hash_values)))
  resource_hash      = substr(sha256(local.resource_hash_seed), 0, local.resource_hash_length)

  resource_label_id = {
    for resource_type, rule in local.normalized_resource_label_rules :
    resource_type => rule.include_region ? local.id : local.id_without_region
  }

  resource_label_base = {
    for resource_type, rule in local.normalized_resource_label_rules :
    resource_type => join(rule.delimiter, compact(
      rule.code_position == "suffix" ? [local.resource_label_id[resource_type], rule.code] :
      rule.code_position == "none" ? [local.resource_label_id[resource_type]] : [rule.code, local.resource_label_id[resource_type]]
    ))
  }

  resource_label_cased = {
    for resource_type, value in local.resource_label_base :
    resource_type => (
      local.normalized_resource_label_rules[resource_type].label_value_case == "none" ? value :
      local.normalized_resource_label_rules[resource_type].label_value_case == "title" ? title(lower(value)) :
      local.normalized_resource_label_rules[resource_type].label_value_case == "upper" ? upper(value) : lower(value)
    )
  }

  resource_label_sanitized = {
    for resource_type, value in local.resource_label_cased :
    resource_type => replace(value, local.normalized_resource_label_rules[resource_type].regex_replace_chars, local.replacement)
  }

  resource_label_collapsed = {
    for resource_type, value in local.resource_label_sanitized :
    resource_type => (
      local.normalized_resource_label_rules[resource_type].collapse_regex == "" ? value :
      replace(
        value,
        local.normalized_resource_label_rules[resource_type].collapse_regex,
        local.normalized_resource_label_rules[resource_type].collapse_replacement,
      )
    )
  }

  resource_label_trimmed = {
    for resource_type, value in local.resource_label_collapsed :
    resource_type => (
      local.normalized_resource_label_rules[resource_type].trim_chars == "" ? value :
      trim(value, local.normalized_resource_label_rules[resource_type].trim_chars)
    )
  }

  resource_label_hashes = {
    for resource_type, rule in local.normalized_resource_label_rules :
    resource_type => substr(sha256(local.resource_hash_seed), 0, rule.hash_length)
  }

  resource_label_hash_delimiters = {
    for resource_type, rule in local.normalized_resource_label_rules :
    resource_type => rule.delimiter == "" ? "" : rule.delimiter
  }

  resource_label_required_suffix_lengths = {
    for resource_type, rule in local.normalized_resource_label_rules :
    resource_type => length(rule.required_suffix)
  }

  resource_label_needs_hash = {
    for resource_type, value in local.resource_label_trimmed :
    resource_type => (
      local.normalized_resource_label_rules[resource_type].globally_unique ||
      (
        local.normalized_resource_label_rules[resource_type].id_length_limit != 0 &&
        length(value) + local.resource_label_required_suffix_lengths[resource_type] > local.normalized_resource_label_rules[resource_type].id_length_limit
      )
    )
  }

  resource_label_hash_suffix_lengths = {
    for resource_type, needs_hash in local.resource_label_needs_hash :
    resource_type => (
      needs_hash ? length(local.resource_label_hash_delimiters[resource_type]) + local.normalized_resource_label_rules[resource_type].hash_length : 0
    ) + local.resource_label_required_suffix_lengths[resource_type]
  }

  resource_label_prefix_length_raw = {
    for resource_type, value in local.resource_label_trimmed :
    resource_type => (
      local.normalized_resource_label_rules[resource_type].id_length_limit == 0 ?
      length(value) :
      local.normalized_resource_label_rules[resource_type].id_length_limit - local.resource_label_hash_suffix_lengths[resource_type]
    )
  }

  resource_label_prefix_lengths = {
    for resource_type, length_limit in local.resource_label_prefix_length_raw :
    resource_type => length_limit < 0 ? 0 : length_limit
  }

  resource_label_prefixes = {
    for resource_type, value in local.resource_label_trimmed :
    resource_type => substr(value, 0, local.resource_label_prefix_lengths[resource_type])
  }

  resource_label_trimmed_prefixes = {
    for resource_type, value in local.resource_label_prefixes :
    resource_type => (
      local.normalized_resource_label_rules[resource_type].trim_chars == "" ? value :
      trim(value, local.normalized_resource_label_rules[resource_type].trim_chars)
    )
  }

  resource_label_ids = {
    for resource_type, prefix in local.resource_label_trimmed_prefixes :
    resource_type => "${prefix}${local.resource_label_needs_hash[resource_type] ? (
      prefix == "" ? local.resource_label_hashes[resource_type] : "${local.resource_label_hash_delimiters[resource_type]}${local.resource_label_hashes[resource_type]}"
    ) : ""}${local.normalized_resource_label_rules[resource_type].required_suffix}"
  }

  resource_label_unique_hash_suffix_lengths = {
    for resource_type, rule in local.normalized_resource_label_rules :
    resource_type => length(local.resource_label_hash_delimiters[resource_type]) + rule.hash_length + local.resource_label_required_suffix_lengths[resource_type]
  }

  resource_label_unique_prefix_length_raw = {
    for resource_type, value in local.resource_label_trimmed :
    resource_type => (
      local.normalized_resource_label_rules[resource_type].id_length_limit == 0 ?
      length(value) :
      local.normalized_resource_label_rules[resource_type].id_length_limit - local.resource_label_unique_hash_suffix_lengths[resource_type]
    )
  }

  resource_label_unique_prefix_lengths = {
    for resource_type, length_limit in local.resource_label_unique_prefix_length_raw :
    resource_type => length_limit < 0 ? 0 : length_limit
  }

  resource_label_unique_prefixes = {
    for resource_type, value in local.resource_label_trimmed :
    resource_type => substr(value, 0, local.resource_label_unique_prefix_lengths[resource_type])
  }

  resource_label_unique_trimmed_prefixes = {
    for resource_type, value in local.resource_label_unique_prefixes :
    resource_type => (
      local.normalized_resource_label_rules[resource_type].trim_chars == "" ? value :
      trim(value, local.normalized_resource_label_rules[resource_type].trim_chars)
    )
  }

  resource_label_unique_ids = {
    for resource_type, prefix in local.resource_label_unique_trimmed_prefixes :
    resource_type => "${prefix}${prefix == "" ? local.resource_label_hashes[resource_type] : "${local.resource_label_hash_delimiters[resource_type]}${local.resource_label_hashes[resource_type]}"}${local.normalized_resource_label_rules[resource_type].required_suffix}"
  }
}
