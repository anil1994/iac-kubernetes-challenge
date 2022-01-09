# Indicate where to source the terraform module from.
# The URL used here is a shorthand for
# notation.

# Indicate what region to deploy the resources into
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "google" {
        project = "tenacious-tiger-337418"
        region = "europe-central2"
}
EOF
}



remote_state {
  backend = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket   = "terraform-state-tenacious-tiger-337411"
    prefix   = "${path_relative_to_include()}/terraform.tfstate"
    project  = "tenacious-tiger-337418"
    location = "eu"
  }
}

# Indicate the input values to use for the variables of the module.
inputs = {



  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
