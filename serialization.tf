locals {
  output_context_raw        = { for k, v in local.input : k => v if k != "name" }
  output_context_serialized = base64encode(jsonencode(local.output_context_raw))
}
