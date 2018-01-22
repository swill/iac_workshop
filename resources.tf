# Unique ID for the environment (since they must be unique)
# We are using this so each workshop attendee will get a different environment name
resource "random_id" "environment" {
	# set to '5' because the max length of the environment name is 25 chars
	byte_length = 5
}

# Environment for the workshop
resource "cloudca_environment" "workshop_env" {
	name = "terraform-env-${random_id.environment.hex}"
	description = "Environment for terraform workshop"
	service_code = "compute-qc"
	organization_code = "${var.organization}"
	admin_role = ["${var.admin_role}"]
}

# VPC for workshop
resource "cloudca_vpc" "workshop_vpc" {
    name = "terraform-vpc"
	description = "VPC for terraform workshop"
    environment_id = "${cloudca_environment.workshop_env.id}"
    vpc_offering = "Default VPC offering"
}

# Network for the workshop
resource "cloudca_network" "workshop_network" {
	name = "terraform-network"
	description = "Network for terraform workshop"
	environment_id = "${cloudca_environment.workshop_env.id}"
	vpc_id = "${cloudca_vpc.workshop_vpc.id}"
	network_offering = "${var.network_offering}"
	network_acl_id = "${var.allow_all_acl}"
}

# Instances for the workshop
resource "cloudca_instance" "workshop_instance" {
	name = "terraform-instance-${count.index+1}"
	environment_id = "${cloudca_environment.workshop_env.id}"
	network_id = "${cloudca_network.workshop_network.id}"
	template = "${var.template}"
	compute_offering = "${var.compute_offering}"
	user_data = "${element(data.template_file.app_config.*.rendered, count.index)}"
	count = "${var.instance_count}"
}

# The application install details defined in 'cloudinit'
data "template_file" "app_config" {
	template = "${file("templates/app_config.tpl")}"
	count = "${var.instance_count}"

	vars {
		app_port = "${var.app_port}"
		instance_id = "${count.index+1}"
		cloud_label = "cloud.ca"
	}
}

# The public IP for the application
resource "cloudca_public_ip" "app_ip" {
  environment_id = "${cloudca_environment.workshop_env.id}"
  vpc_id = "${cloudca_vpc.workshop_vpc.id}"
}

# The LB rule on the public IP for the application
resource "cloudca_load_balancer_rule" "lbr" {
   environment_id = "${cloudca_environment.workshop_env.id}"

   name="terraform-app-lb"
   network_id = "${cloudca_network.workshop_network.id}"
   public_ip_id = "${cloudca_public_ip.app_ip.id}"
   protocol = "tcp"
   algorithm = "roundrobin"
   public_port = 80
   private_port = "${var.app_port}"
   instance_ids = ["${cloudca_instance.workshop_instance.*.id}"]
}

# Return the public IP that was assigned to the application
output "app_url" {
    value = "http://${cloudca_public_ip.app_ip.ip_address}"
}