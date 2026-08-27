locals {
  output_context_raw        = local.output_context
  output_context_serialized = base64encode(jsonencode(local.output_context_raw))
}
