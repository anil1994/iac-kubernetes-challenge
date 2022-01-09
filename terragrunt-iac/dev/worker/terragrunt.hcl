# Indicate where to source the terraform module from.
# The URL used here is a shorthand for
# notation.

# Indicate what region to deploy the resources into
include "root" {
  path = find_in_parent_folders()
}

dependency "master" {
  config_path = "../master"
}



# Indicate the input values to use for the variables of the module.
inputs = {

  machine_count = 1

  machine_type = "n1-standard-1"

  zone_name = "europe-central2-a"

  image_name = "ubuntu-1804-bionic-v20211214"

  network_name = "default"
  
  master-public-ip = dependency.master.outputs.public-ip
  
}

dependencies {
  paths = ["../infra", "../master"]
}
