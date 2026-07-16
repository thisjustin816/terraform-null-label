terraform {
  required_version = ">= 0.13.0"
}

variable "label_order" {
  type = list(string)
}

module "label" {
  source = "../../.."

  namespace   = "eg"
  application = "orders"
  label_order = var.label_order
}
