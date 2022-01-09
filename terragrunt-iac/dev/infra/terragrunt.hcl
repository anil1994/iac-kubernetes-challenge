# Indicate where to source the terraform module from.
# The URL used here is a shorthand for
# notation.

# Indicate what region to deploy the resources into
include "root" {
  path = find_in_parent_folders()
}
# Indicate the input values to use for the variables of the module.
inputs = {

  network_name = "default"
 
  firewall_name = "k3s-firewall"


}
