locals {
  # The default value of labels_as_tags cannot be included in this
  # defaults` map because it creates a circular dependency
  default_labels_as_tags = keys(local.tags_context)
  # Unlike other inputs, the first setting of `labels_as_tags` cannot be later overridden. However,
  # we still have to pass the `input` map as the context to the next module. So we need to distinguish
  # between the first setting of var.labels_as_tags == null as meaning set the default and do not change
  # it later, versus later settings of var.labels_as_tags that should be ignored. So, we make the
  # default value in context be "unset", meaning it can be changed, but when it is unset and
  # var.labels_as_tags is null, we change it to "default". Once it is set to "default" we will
  # not allow it to be changed again, but of course we have to detect "default" and replace it
  # with local.default_labels_as_tags when we go to use it.
  #
  # We do not want to use null as default or unset, because Terraform has issues with
  # the value of an object field being null in some places and [] in others.
  # We do not want to use [] as default or unset because that is actually a valid setting
  # that we want to have override the default.
  #
  # To determine whether that context.labels_as_tags is not set,
  # we have to cover 2 cases: 1) context does not have a labels_as_tags key, 2) it is present and set to ["unset"]
  context_labels_as_tags_is_unset = try(contains(local.input_context.labels_as_tags, "unset"), true)

  # So far, we have decided not to allow overriding replacement or id_hash_length
  replacement    = local.defaults.replacement
  id_hash_length = local.defaults.id_hash_length

  input_context = merge(local.defaults, jsondecode(base64decode(var.context)))

  # The values provided by variables supersede the values inherited from the context object,
  # except for tags and attributes which are merged.
  input = {
    # It would be nice to use coalesce here, but we cannot, because it
    # is an error for all the arguments to coalesce to be empty.
    enabled     = var.enabled == null ? local.input_context.enabled : var.enabled
    namespace   = var.namespace == null ? local.input_context.namespace : var.namespace
    region      = var.region == null ? local.input_context.region : var.region
    environment = var.environment == null ? local.input_context.environment : var.environment
    application = var.application == null ? local.input_context.application : var.application
    delimiter   = var.delimiter == null ? local.input_context.delimiter : var.delimiter
    # modules tack on attributes (passed by var) to the end of the list (passed by context)
    attributes = compact(distinct(concat(coalesce(local.input_context.attributes, []), coalesce(var.attributes, []))))
    tags       = merge(local.input_context.tags, var.tags)

    additional_tag_map   = merge(local.input_context.additional_tag_map, var.additional_tag_map)
    label_order          = var.label_order == null ? local.input_context.label_order : var.label_order
    resource_codes       = merge(local.input_context.resource_codes, coalesce(var.resource_codes, {}))
    resource_label_rules = var.resource_label_rules == null ? local.input_context.resource_label_rules : merge(local.input_context.resource_label_rules, var.resource_label_rules)
    resource_hash_length = var.resource_hash_length == null ? local.input_context.resource_hash_length : var.resource_hash_length
    resource_hash_values = var.resource_hash_values == null ? local.input_context.resource_hash_values : var.resource_hash_values
    aws_resource_types   = var.aws_resource_types == null ? local.input_context.aws_resource_types : var.aws_resource_types
    region_codes         = merge(local.input_context.region_codes, coalesce(var.region_codes, {}))
    environment_codes    = merge(local.input_context.environment_codes, coalesce(var.environment_codes, {}))
    regex_replace_chars  = var.regex_replace_chars == null ? local.input_context.regex_replace_chars : var.regex_replace_chars
    id_length_limit      = var.id_length_limit == null ? local.input_context.id_length_limit : var.id_length_limit
    label_key_case       = var.label_key_case == null ? lookup(local.input_context, "label_key_case", null) : var.label_key_case
    label_value_case     = var.label_value_case == null ? lookup(local.input_context, "label_value_case", null) : var.label_value_case

    descriptor_formats = merge(lookup(local.input_context, "descriptor_formats", {}), var.descriptor_formats)
    labels_as_tags     = local.context_labels_as_tags_is_unset ? var.labels_as_tags : local.input_context.labels_as_tags
  }


  enabled             = local.input.enabled
  regex_replace_chars = coalesce(local.input.regex_replace_chars, local.defaults.regex_replace_chars)

  # string_label_names are names of inputs that are strings (not list of strings) used as labels
  string_label_names = ["namespace", "region", "environment", "application"]
  normalized_labels = { for k in local.string_label_names : k =>
    local.input[k] == null ? "" : replace(local.input[k], local.regex_replace_chars, local.replacement)
  }
  normalized_attributes = compact(distinct([for v in local.input.attributes : replace(v, local.regex_replace_chars, local.replacement)]))

  formatted_labels = { for k in local.string_label_names : k => local.label_value_case == "none" ? local.normalized_labels[k] :
    local.label_value_case == "title" ? title(lower(local.normalized_labels[k])) :
    local.label_value_case == "upper" ? upper(local.normalized_labels[k]) : lower(local.normalized_labels[k])
  }

  attributes = compact(distinct([
    for v in local.normalized_attributes : (local.label_value_case == "none" ? v :
      local.label_value_case == "title" ? title(lower(v)) :
    local.label_value_case == "upper" ? upper(v) : lower(v))
  ]))

  namespace        = local.formatted_labels["namespace"]
  region           = local.formatted_labels["region"]
  region_code      = try(local.region_codes[local.region], "")
  environment      = local.formatted_labels["environment"]
  environment_code = try(local.environment_codes[local.environment], "")
  application      = local.normalized_labels["application"]

  delimiter   = local.input.delimiter == null ? local.defaults.delimiter : local.input.delimiter
  label_order = local.input.label_order == null ? local.defaults.label_order : coalescelist(local.input.label_order, local.defaults.label_order)
  # Auto-generated codes from `aws_resource_types` are the lowest precedence, so the curated
  # catalog and any explicit `resource_codes` overrides win for resources that appear in both.
  resource_codes       = merge(local.requested_aws_resource_codes, local.input.resource_codes)
  resource_label_rules = local.input.resource_label_rules == null ? local.defaults.resource_label_rules : local.input.resource_label_rules
  resource_hash_length = local.input.resource_hash_length == null ? local.defaults.resource_hash_length : local.input.resource_hash_length
  resource_hash_values = local.input.resource_hash_values == null ? local.defaults.resource_hash_values : local.input.resource_hash_values
  aws_resource_types   = local.input.aws_resource_types == null ? local.defaults.aws_resource_types : local.input.aws_resource_types
  environment_codes    = local.input.environment_codes == null ? local.defaults.environment_codes : local.input.environment_codes
  region_codes         = local.input.region_codes == null ? local.defaults.region_codes : local.input.region_codes
  id_length_limit      = local.input.id_length_limit == null ? local.defaults.id_length_limit : local.input.id_length_limit
  label_key_case       = local.input.label_key_case == null ? local.defaults.label_key_case : local.input.label_key_case
  label_value_case     = local.input.label_value_case == null ? local.defaults.label_value_case : local.input.label_value_case

  # labels_as_tags is an exception to the rule that input vars override context values (see above)
  labels_as_tags = contains(local.input.labels_as_tags, "default") ? local.default_labels_as_tags : local.input.labels_as_tags

  # Just for standardization and completeness
  descriptor_formats = local.input.descriptor_formats

  additional_tag_map = merge(local.input_context.additional_tag_map, var.additional_tag_map)

  tags = merge(local.input_context.tags, local.generated_tags, var.tags)

  tags_as_list_of_maps = flatten([
    for key in keys(local.tags) : merge(
      {
        key   = key
        value = local.tags[key]
    }, local.additional_tag_map)
  ])

  tags_context = {
    namespace   = local.namespace
    region      = local.region
    application = local.application
    environment = local.environment
    # For AWS we need `Application` to be disambiguated since it has a special meaning
    id         = local.id
    attributes = local.id_context.attributes
  }

  generated_tags = {
    for l in setintersection(keys(local.tags_context), local.labels_as_tags) :
    local.label_key_case == "upper" ? upper(l) : (
      local.label_key_case == "lower" ? lower(l) : title(lower(l))
    ) => local.tags_context[l] if length(local.tags_context[l]) > 0
  }

  id_context = {
    namespace        = local.namespace
    region           = local.region
    region_code      = local.region_code
    environment      = local.environment
    environment_code = local.environment_code
    application      = local.application
    attributes       = join(local.delimiter, local.attributes)
  }

  labels = [for l in local.label_order : local.id_context[l] if length(local.id_context[l]) > 0]

  id_full = join(local.delimiter, local.labels)

  id_context_without_region = merge(local.id_context, {
    region      = ""
    region_code = ""
  })
  labels_without_region  = [for l in local.label_order : local.id_context_without_region[l] if length(local.id_context_without_region[l]) > 0]
  id_without_region_full = join(local.delimiter, local.labels_without_region)

  # Create a truncated ID if needed
  delimiter_length = length(local.delimiter)
  # Calculate length of normal part of ID, leaving room for delimiter and hash
  id_truncated_length_limit = local.id_length_limit - (local.id_hash_length + local.delimiter_length)
  # Truncate the ID and ensure a single (not double) trailing delimiter
  id_truncated = local.id_truncated_length_limit <= 0 ? "" : "${trimsuffix(substr(local.id_full, 0, local.id_truncated_length_limit), local.delimiter)}${local.delimiter}"
  # Support usages that disallow numeric characters. Would prefer tr 0-9 q-z but Terraform does not support it.
  # Probably would have been better to take the hash of only the characters being removed,
  # so identical removed strings would produce identical hashes, but it is not worth breaking existing IDs for.
  id_hash_plus = "${md5(local.id_full)}qrstuvwxyz"
  id_hash_case = local.label_value_case == "title" ? title(local.id_hash_plus) : local.label_value_case == "upper" ? upper(local.id_hash_plus) : local.label_value_case == "lower" ? lower(local.id_hash_plus) : local.id_hash_plus
  id_hash      = replace(local.id_hash_case, local.regex_replace_chars, local.replacement)
  # Create the short ID by adding a hash to the end of the truncated ID
  id_short = substr("${local.id_truncated}${local.id_hash}", 0, local.id_length_limit)
  id       = local.id_length_limit != 0 && length(local.id_full) > local.id_length_limit ? local.id_short : local.id_full

  id_without_region_truncated_length_limit = local.id_length_limit - (local.id_hash_length + local.delimiter_length)
  id_without_region_truncated              = local.id_without_region_truncated_length_limit <= 0 ? "" : "${trimsuffix(substr(local.id_without_region_full, 0, local.id_without_region_truncated_length_limit), local.delimiter)}${local.delimiter}"
  id_without_region_hash_plus              = "${md5(local.id_without_region_full)}qrstuvwxyz"
  id_without_region_hash_case              = local.label_value_case == "title" ? title(local.id_without_region_hash_plus) : local.label_value_case == "upper" ? upper(local.id_without_region_hash_plus) : local.label_value_case == "lower" ? lower(local.id_without_region_hash_plus) : local.id_without_region_hash_plus
  id_without_region_hash                   = replace(local.id_without_region_hash_case, local.regex_replace_chars, local.replacement)
  id_without_region_short                  = substr("${local.id_without_region_truncated}${local.id_without_region_hash}", 0, local.id_length_limit)
  id_without_region                        = local.id_length_limit != 0 && length(local.id_without_region_full) > local.id_length_limit ? local.id_without_region_short : local.id_without_region_full

  id_with_resource_codes = local.resource_label_ids
  id_for_storage_account = try(local.resource_label_unique_ids["storage_account"], "")
  id_for_keyvault        = try(local.resource_label_unique_ids["key_vault"], "")


  # Context of this label to pass to other label modules
  output_context = {
    enabled            = local.enabled
    namespace          = local.namespace
    region             = local.region
    region_code        = local.region_code
    environment        = local.environment
    environment_code   = local.environment_code
    application        = local.application
    delimiter          = local.delimiter
    attributes         = local.attributes
    tags               = local.tags
    additional_tag_map = local.additional_tag_map
    label_order        = local.label_order
    region_codes       = local.region_codes
    resource_codes     = local.resource_codes
    # Chain the raw user rules, not the normalized ones. Serializing normalized rules
    # bakes in resolved codes, which would override a downstream module's own
    # `resource_codes` for the same resource type when context is chained.
    resource_label_rules = local.resource_label_rules
    resource_hash_length = local.resource_hash_length
    resource_hash_values = local.resource_hash_values
    aws_resource_types   = local.aws_resource_types
    environment_codes    = local.environment_codes
    regex_replace_chars  = local.regex_replace_chars
    id_length_limit      = local.id_length_limit
    label_key_case       = local.label_key_case
    label_value_case     = local.label_value_case
    labels_as_tags       = local.labels_as_tags
    descriptor_formats   = local.descriptor_formats
  }

}
