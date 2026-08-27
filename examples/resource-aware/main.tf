module "label" {
  source = "../.."

  namespace   = "eg"
  application = "orders"
  region      = "us-west-2"
  environment = "prod"
  attributes  = ["api"]

  aws_resource_types = ["bedrockagent_agent"]
  resource_codes = {
    aws_lambda_function = "fn"
    custom_service      = "svc"
  }
  resource_hash_values = [
    "aws",
    "123456789012",
    "us-west-2",
  ]
  required_resource_names = [
    "aws_ecr_repository",
    "aws_lambda_function",
    "aws_s3_bucket",
    "azure_storage_account",
  ]
}

output "example" {
  value = {
    base_id = module.label.id
    hash    = module.label.resource_hash
    codes = {
      aws_bedrockagent_agent = module.label.resource_codes.aws_bedrockagent_agent
      aws_ecr_repository     = module.label.resource_codes.aws_ecr_repository
      aws_lambda_function    = module.label.resource_codes.aws_lambda_function
      aws_s3_bucket          = module.label.resource_codes.aws_s3_bucket
      azure_storage_account  = module.label.resource_codes.azure_storage_account
      custom_service         = module.label.resource_codes.custom_service
    }
    logical = {
      aws_ecr_repository    = module.label.id_with_resource_code.aws_ecr_repository
      aws_lambda_function   = module.label.id_with_resource_code.aws_lambda_function
      aws_s3_bucket         = module.label.id_with_resource_code.aws_s3_bucket
      azure_storage_account = module.label.id_with_resource_code.azure_storage_account
      custom_service        = module.label.id_with_resource_code.custom_service
    }
    normal = {
      aws_ecr_repository    = module.label.resource_name.aws_ecr_repository
      aws_lambda_function   = module.label.resource_name.aws_lambda_function
      aws_s3_bucket         = module.label.resource_name.aws_s3_bucket
      azure_storage_account = module.label.resource_name.azure_storage_account
    }
    hashed = {
      aws_ecr_repository    = module.label.resource_name_hashed.aws_ecr_repository
      aws_lambda_function   = module.label.resource_name_hashed.aws_lambda_function
      aws_s3_bucket         = module.label.resource_name_hashed.aws_s3_bucket
      azure_storage_account = module.label.resource_name_hashed.azure_storage_account
    }
    custom_physical_name_absent = (
      !contains(keys(module.label.resource_name), "custom_service") &&
      !contains(keys(module.label.resource_name_hashed), "custom_service")
    )
    errors = module.label.resource_name_errors
  }
}
