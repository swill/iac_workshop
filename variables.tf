# Required variables
variable "api_url" {
    default = "https://compute-east.cloud.ca/client/api"
}
variable "api_key" {}
variable "organization" {
    default = "swill"
}
variable "admin_role" {
    type = "list"
    default = ["workshop"]
}

# default for swill/compute-qc
variable "allow_all_acl" {
    default = "9ba3ec65-2e1d-11e4-8e05-42a29a39fc92"
}

# default network offering w/ LB
variable "network_offering" {
    default = "Load Balanced Tier"
}

# default instance number
variable "instance_count" {
    default = 2
}

# default template type
variable "template" {
    default = "CoreOS Stable"
}

# default compute offering
variable "compute_offering" {
    default = "1vCPU.1GB"
}

# default application port
variable "app_port" {
    default = 8080
}

