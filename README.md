# OpenStack
# Terraform OpenStack Plugin Example

This repository provides an example of how to extend OpenStack functionality using Terraform. It demonstrates how to create and integrate custom plugins into a DevStack environment to manage OpenStack resources like compute instances, networks, and more.

## Prerequisites

To use this plugin, you'll need to have **DevStack** installed. You can download DevStack from the official repository:

- [Guide on how to install DevStack](https://docs.openstack.org/devstack/latest/)

## Setup Instructions

### 1. Add the Plugin to local.conf

Add this repository as an external plugin in your local.conf file by including the following snippet:
```bash
[[local|localrc]]
   ...
enable_plugin openstack-plugin-flask https://github.com/APetros99/openstack-plugin-flask.git master
```
This will tell DevStack to fetch and enable the flask-openstack-plugin during the installation process.

Some of you may need to add your host IP address.

### 2. Run stack.sh

Run the stack.sh script to install and configure your DevStack environment, including the Flask plugin:
```bash
./stack.sh
```
Once the script completes, your plugin will be set up, and the Terraform files will be available.

### 3. Configure Terraform

The Terraform configuration files are located in the plugin's devstack/terraform directory.

Before running Terraform, edit the main.tf file and replace the placeholder values with your actual OpenStack credentials and configuration:

```hcl
Copia codice
provider "openstack" {
  auth_url    = "http://<devstack_host>:5000/v3"  # Replace with your Keystone URL
  tenant_name = "admin"                          # Replace with your project name
  username    = "admin"                          # Replace with your OpenStack username
  password    = "password"                       # Replace with your password
}

resource "openstack_compute_instance_v2" "example_instance" {
  name        = "example-instance"
  image_name  = "ubuntu-24.04"
  flavor_name = "m1.small"
  key_pair    = "your-ssh-key"      # Replace with your SSH key name
  network {
    name = "your-network"           # Replace with the network name
  }
}
```

### 4. Initialize Terraform

Navigate to the Terraform directory where the main.tf file is located and run the following command to initialize Terraform:

```bash
cd /opt/stack/openstack-plugin-terraform/devstack/terraform
terraform init
```
This command will prepare Terraform by downloading the necessary provider plugins.

### 5. Apply Terraform Configuration

To apply the Terraform configuration and create resources in OpenStack, run:

```bash
terraform apply
```
Terraform will display a plan of the resources it will create. Review the plan and type yes to proceed.

### 6. Verify Resources

Once Terraform completes, you can verify the created resources:

Check the OpenStack dashboard (Horizon) at:
```bash
http://<devstack_host>/dashboard
```
Alternatively, use the OpenStack CLI:
```bash
openstack server list
```
You should see the resources, such as a compute instance, listed in your environment.

### 7. Clean Up

To destroy the resources created by Terraform, run:

```
bash
terraform destroy
```
Terraform will delete all resources defined in the main.tf file after confirmation.

### Notes
The main.tf file provided is a basic example. You can customize it to provision other OpenStack resources such as networks, volumes, and security groups.
Ensure your DevStack environment is correctly configured and running before applying the Terraform configuration.
