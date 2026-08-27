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

}

locals {
  resource_hash_seed = jsonencode({
    labels_raw           = local.labels_raw
    resource_hash_values = local.resource_hash_values
  })
  resource_hash_digest = sha256(local.resource_hash_seed)
  resource_hash        = substr(local.resource_hash_digest, 0, local.resource_hash_length)

  renderer_raw_label_components = {
    namespace   = local.labels_raw.namespace == null ? [] : [tostring(local.labels_raw.namespace)]
    application = local.labels_raw.application == null ? [] : [tostring(local.labels_raw.application)]
    region      = local.labels_raw.region == null ? [] : [tostring(local.labels_raw.region)]
    region_code = local.labels_raw.region == null ? [] : [
      local.region_code
    ]
    environment = local.labels_raw.environment == null ? [] : [tostring(local.labels_raw.environment)]
    environment_code = local.labels_raw.environment == null ? [] : [
      local.environment_code
    ]
    attributes = [for value in local.labels_raw.attributes : tostring(value)]
  }

  renderer_missing_constraints = {
    for resource_type, rule in local.effective_resource_label_rules :
    resource_type => compact([
      try(rule.min_length, null) == null ? "min_length" : "",
      try(rule.max_length, null) == null ? "max_length" : "",
      try(rule.validation_regex, null) == null ? "validation_regex" : "",
    ])
  }

  renderer_completeness_errors = {
    for resource_type, missing in local.renderer_missing_constraints :
    resource_type => [
      for constraint in missing : "missing required constraint ${constraint}"
    ] if length(missing) > 0
  }

  caller_renderer_completeness_errors = {
    for resource_type, errors in local.renderer_completeness_errors :
    resource_type => errors if contains(keys(local.resource_rule_overrides), resource_type)
  }

  renderer_complete_rules = {
    for resource_type, rule in local.effective_resource_label_rules :
    resource_type => rule if length(local.renderer_missing_constraints[resource_type]) == 0
  }

  renderer_rule_configuration_errors = {
    for resource_type, rule in local.renderer_complete_rules :
    resource_type => distinct(concat(
      rule.min_length < 0 || floor(rule.min_length) != rule.min_length ? ["min_length must be a non-negative whole number"] : [],
      rule.max_length < 1 || floor(rule.max_length) != rule.max_length ? ["max_length must be a positive whole number"] : [],
      rule.min_length > rule.max_length ? ["min_length exceeds max_length"] : [],
      rule.hash_length < 4 || rule.hash_length > 32 || floor(rule.hash_length) != rule.hash_length ? ["hash_length must be a whole number from 4 through 32"] : [],
      rule.regex_replace_chars != "" && !can(replace("probe", rule.regex_replace_chars, local.replacement)) ? ["regex_replace_chars is invalid"] : [],
      rule.collapse_regex != "" && !can(replace("probe", rule.collapse_regex, rule.collapse_replacement)) ? ["collapse_regex is invalid"] : [],
      !startswith(rule.validation_regex, "^") || !endswith(rule.validation_regex, "$") || !can(regexall(rule.validation_regex, "")) ? ["validation_regex must be a valid anchored final regex"] : [],
      flatten([
        for pattern in rule.forbidden_regexes :
        can(regexall(pattern, "")) ? [] : ["forbidden regex is invalid: ${pattern}"]
      ]),
    ))
  }

  renderer_configured_rules = {
    for resource_type, rule in local.renderer_complete_rules :
    resource_type => rule if length(local.renderer_rule_configuration_errors[resource_type]) == 0
  }

  renderer_raw_label_groups = {
    for resource_type, rule in local.renderer_configured_rules :
    resource_type => [
      for group in rule.label_groups : flatten([
        for label_name in group : local.renderer_raw_label_components[label_name]
      ])
    ]
  }

  renderer_cased_label_groups = {
    for resource_type, groups in local.renderer_raw_label_groups :
    resource_type => [
      for group in groups : [
        for component in group :
        local.renderer_configured_rules[resource_type].label_value_case == "none" ? component :
        local.renderer_configured_rules[resource_type].label_value_case == "title" ? title(lower(component)) :
        local.renderer_configured_rules[resource_type].label_value_case == "upper" ? upper(component) : lower(component)
      ]
    ]
  }

  renderer_transformed_label_groups = {
    for resource_type, groups in local.renderer_cased_label_groups :
    resource_type => [
      for group in groups : [
        for component in group :
        local.renderer_configured_rules[resource_type].regex_replace_chars == "" ? component :
        replace(component, local.renderer_configured_rules[resource_type].regex_replace_chars, local.replacement)
      ]
    ]
  }

  renderer_nonempty_label_components = {
    for resource_type, groups in local.renderer_transformed_label_groups :
    resource_type => [
      for group in groups : [
        for component in group : component if component != ""
      ]
    ]
  }

  renderer_nonempty_label_groups = {
    for resource_type, groups in local.renderer_nonempty_label_components :
    resource_type => [
      for group in groups : group if length(group) > 0
    ]
  }

  renderer_joined_label_groups = {
    for resource_type, groups in local.renderer_nonempty_label_groups :
    resource_type => [
      for group in groups : join(local.renderer_configured_rules[resource_type].component_delimiter, group)
    ]
  }

  renderer_grouped_bodies = {
    for resource_type, groups in local.renderer_joined_label_groups :
    resource_type => join(local.renderer_configured_rules[resource_type].group_delimiter, groups)
  }

  renderer_cased_codes = {
    for resource_type, rule in local.renderer_configured_rules :
    resource_type => (
      rule.label_value_case == "none" ? rule.code :
      rule.label_value_case == "title" ? title(lower(rule.code)) :
      rule.label_value_case == "upper" ? upper(rule.code) : lower(rule.code)
    )
  }

  renderer_transformed_codes = {
    for resource_type, code in local.renderer_cased_codes :
    resource_type => (
      local.renderer_configured_rules[resource_type].regex_replace_chars == "" ? code :
      replace(code, local.renderer_configured_rules[resource_type].regex_replace_chars, local.replacement)
    )
  }

  renderer_bodies_with_codes = {
    for resource_type, body in local.renderer_grouped_bodies :
    resource_type => join(
      local.renderer_configured_rules[resource_type].component_delimiter,
      compact(
        local.renderer_configured_rules[resource_type].code_position == "prefix" ? [local.renderer_transformed_codes[resource_type], body] :
        local.renderer_configured_rules[resource_type].code_position == "suffix" ? [body, local.renderer_transformed_codes[resource_type]] : [body]
      ),
    )
  }

  renderer_collapsed_bodies = {
    for resource_type, body in local.renderer_bodies_with_codes :
    resource_type => (
      local.renderer_configured_rules[resource_type].collapse_regex == "" ? body :
      replace(
        body,
        local.renderer_configured_rules[resource_type].collapse_regex,
        local.renderer_configured_rules[resource_type].collapse_replacement,
      )
    )
  }

  renderer_trimmed_bodies = {
    for resource_type, body in local.renderer_collapsed_bodies :
    resource_type => (
      local.renderer_configured_rules[resource_type].trim_chars == "" ? body :
      trim(body, local.renderer_configured_rules[resource_type].trim_chars)
    )
  }

  renderer_hash_cased = {
    for resource_type, rule in local.renderer_configured_rules :
    resource_type => (
      rule.label_value_case == "none" ? substr(local.resource_hash_digest, 0, rule.hash_length) :
      rule.label_value_case == "title" ? title(lower(substr(local.resource_hash_digest, 0, rule.hash_length))) :
      rule.label_value_case == "upper" ? upper(substr(local.resource_hash_digest, 0, rule.hash_length)) : lower(substr(local.resource_hash_digest, 0, rule.hash_length))
    )
  }

  renderer_hashes = {
    for resource_type, hash in local.renderer_hash_cased :
    resource_type => (
      local.renderer_configured_rules[resource_type].regex_replace_chars == "" ? hash :
      replace(hash, local.renderer_configured_rules[resource_type].regex_replace_chars, local.replacement)
    )
  }

  renderer_unhashed_candidates = {
    for resource_type, body in local.renderer_trimmed_bodies :
    resource_type => "${local.renderer_configured_rules[resource_type].required_prefix}${body}${local.renderer_configured_rules[resource_type].required_suffix}"
  }

  renderer_normal_needs_hash = {
    for resource_type, candidate in local.renderer_unhashed_candidates :
    resource_type => (
      local.renderer_configured_rules[resource_type].hash_policy == "always" ||
      (
        local.renderer_configured_rules[resource_type].hash_policy == "when_needed" &&
        (
          local.renderer_trimmed_bodies[resource_type] == "" ||
          length(candidate) < local.renderer_configured_rules[resource_type].min_length ||
          length(candidate) > local.renderer_configured_rules[resource_type].max_length
        )
      )
    )
  }

  renderer_candidate_hash_usage = {
    for resource_type, needs_hash in local.renderer_normal_needs_hash :
    resource_type => {
      normal = needs_hash
      hashed = true
    }
  }

  renderer_hash_affix_lengths = {
    for resource_type, hash in local.renderer_hashes :
    resource_type => (
      length(local.renderer_configured_rules[resource_type].required_prefix) +
      length(hash) +
      length(local.renderer_configured_rules[resource_type].required_suffix)
    )
  }

  renderer_candidate_body_lengths = {
    for resource_type, modes in local.renderer_candidate_hash_usage :
    resource_type => {
      for mode, use_hash in modes : mode => (
        !use_hash ? length(local.renderer_trimmed_bodies[resource_type]) :
        local.renderer_hash_affix_lengths[resource_type] > local.renderer_configured_rules[resource_type].max_length ? 0 :
        local.renderer_trimmed_bodies[resource_type] == "" ? 0 :
        (
          length(local.renderer_trimmed_bodies[resource_type]) +
          (local.renderer_hashes[resource_type] == "" ? 0 : length(local.renderer_configured_rules[resource_type].component_delimiter))
        ) <= local.renderer_configured_rules[resource_type].max_length - local.renderer_hash_affix_lengths[resource_type] ?
        length(local.renderer_trimmed_bodies[resource_type]) :
        (
          local.renderer_configured_rules[resource_type].max_length - local.renderer_hash_affix_lengths[resource_type] <= length(local.renderer_configured_rules[resource_type].component_delimiter) ? 0 :
          local.renderer_configured_rules[resource_type].max_length - local.renderer_hash_affix_lengths[resource_type] - length(local.renderer_configured_rules[resource_type].component_delimiter)
        )
      )
    }
  }

  renderer_candidate_bodies = {
    for resource_type, modes in local.renderer_candidate_hash_usage :
    resource_type => {
      for mode, use_hash in modes : mode => (
        !use_hash ? local.renderer_trimmed_bodies[resource_type] :
        local.renderer_configured_rules[resource_type].trim_chars == "" ?
        substr(local.renderer_trimmed_bodies[resource_type], 0, local.renderer_candidate_body_lengths[resource_type][mode]) :
        trim(
          substr(local.renderer_trimmed_bodies[resource_type], 0, local.renderer_candidate_body_lengths[resource_type][mode]),
          local.renderer_configured_rules[resource_type].trim_chars,
        )
      )
    }
  }

  renderer_candidates = {
    for resource_type, modes in local.renderer_candidate_hash_usage :
    resource_type => {
      for mode, use_hash in modes : mode => join("", [
        local.renderer_configured_rules[resource_type].required_prefix,
        local.renderer_candidate_bodies[resource_type][mode],
        use_hash && local.renderer_candidate_bodies[resource_type][mode] != "" && local.renderer_hashes[resource_type] != "" ? local.renderer_configured_rules[resource_type].component_delimiter : "",
        use_hash ? local.renderer_hashes[resource_type] : "",
        local.renderer_configured_rules[resource_type].required_suffix,
      ])
    }
  }

  renderer_candidate_errors = {
    for resource_type, modes in local.renderer_candidates :
    resource_type => {
      for mode, candidate in modes : mode => distinct(concat(
        local.renderer_candidate_hash_usage[resource_type][mode] && local.renderer_hashes[resource_type] == "" ? ["${mode} candidate hash is empty after transformation"] : [],
        local.renderer_candidate_hash_usage[resource_type][mode] && local.renderer_hash_affix_lengths[resource_type] > local.renderer_configured_rules[resource_type].max_length ? ["${mode} candidate hash and required affixes exceed max_length"] : [],
        length(candidate) < local.renderer_configured_rules[resource_type].min_length ? ["${mode} candidate is shorter than min_length"] : [],
        length(candidate) > local.renderer_configured_rules[resource_type].max_length ? ["${mode} candidate exceeds max_length"] : [],
        !can(regexall(local.renderer_configured_rules[resource_type].validation_regex, candidate)) ? ["${mode} candidate final regex is invalid"] :
        length(regexall(local.renderer_configured_rules[resource_type].validation_regex, candidate)) == 0 ? ["${mode} candidate fails final regex"] : [],
        flatten([
          for pattern in local.renderer_configured_rules[resource_type].forbidden_regexes :
          !can(regexall(pattern, candidate)) ? ["${mode} candidate forbidden pattern is invalid: ${pattern}"] :
          length(regexall(pattern, candidate)) > 0 ? ["${mode} candidate matches forbidden pattern: ${pattern}"] : []
        ]),
      ))
    }
  }

  renderer_combined_candidate_errors = {
    for resource_type, modes in local.renderer_candidate_errors :
    resource_type => distinct(concat(modes.normal, modes.hashed))
    if length(concat(modes.normal, modes.hashed)) > 0
  }

  resource_name_errors = merge(
    local.renderer_completeness_errors,
    {
      for resource_type, errors in local.renderer_rule_configuration_errors :
      resource_type => errors if length(errors) > 0
    },
    local.renderer_combined_candidate_errors,
  )

  renderer_joint_valid_keys = toset([
    for resource_type, modes in local.renderer_candidate_errors : resource_type
    if length(modes.normal) == 0 && length(modes.hashed) == 0
  ])

  resource_name = {
    for resource_type in local.renderer_joint_valid_keys :
    resource_type => local.renderer_candidates[resource_type].normal
  }

  resource_name_hashed = {
    for resource_type in local.renderer_joint_valid_keys :
    resource_type => local.renderer_candidates[resource_type].hashed
  }

  required_resource_name_diagnostics = {
    for resource_type in var.required_resource_names :
    resource_type => (
      !contains(keys(local.normalized_resource_codes), resource_type) &&
      !contains(keys(local.effective_resource_label_rules), resource_type) ? ["unknown resource name"] :
      !contains(keys(local.effective_resource_label_rules), resource_type) ? ["resource is not renderable"] :
      contains(keys(local.resource_name_errors), resource_type) ? local.resource_name_errors[resource_type] :
      !contains(local.renderer_joint_valid_keys, resource_type) ? ["normal and hashed names are not both valid"] : []
    )
  }

  required_resource_name_errors = {
    for resource_type, errors in local.required_resource_name_diagnostics :
    resource_type => errors if length(errors) > 0
  }
}
