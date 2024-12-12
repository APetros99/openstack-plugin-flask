# OpenStack
# Flask OpenStack Plugin Example

This repository provides an example of how to extend OpenStack functionality with a simple Flask application. It demonstrates how to create and integrate custom plugins into a DevStack environment.

## Prerequisites

To use this plugin, you'll need to have **DevStack** installed. You can download DevStack from the official repository:

- [Guide on how to install DevStack](https://docs.openstack.org/devstack/latest/)

## Setup Instructions

### 1. Add the Plugin to local.conf

Add this repository as an external plugin in your local.conf file by including the following snippet:
```bash
[[local|localrc]]
   ...
enable_plugin openstack-plugin https://github.com/APetros99/OpenStack.git main
```
This will tell DevStack to fetch and enable the flask-openstack-plugin during the installation process.

### 2. Run stack.sh
Run the stack.sh script to install and configure your DevStack environment, including the Flask plugin:
```bash
./stack.sh
```
Once the script completes, your plugin will be set up and the Flask application will be running.

### 3. Test the plugin

You can visit the Flask application at:
```bash
http://<devstack_host>:5234
```
It will display a "Hello, Beautiful People!" message.

This project includes code from the repository [simona2606/openstack-plugin-flask](https://github.com/simona2606/openstack-plugin-flask).  
The original code has been modified to fit the context of the project.
