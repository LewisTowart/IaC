# Infrastructure as Code (IaC)

Helps us codify all things related to infrastructure. Can write a language we can read that can instruct the machines and execute tasks accordingly.

An example is being to automate the process of SSHing into the VM and installing packages or running commands like update and upgrade.

## Ansible - Configuration Management

Ansible and configuration management is responsible for being able to ping instances and install what ever packages you specify on them.

We are going to be doing this using AWS EC2 instances on Ubuntu 18.04. I am doing this because it will automate the process of having to install packages on my instances manually. Imagine if you had to SSH into 200 instances to run an update and upgrade command, well Ansible can automate that process for you.

Benefits of Ansible:
* Open source
* Powerful
* Simple yaml human readable
* Agentless

![alt text](Markdown-Images/Ansible-arch.png)

I am going to need to create one instance for the Ansible controller to be installed on and two more instances which will act as agent nodes.

For the controller to ping these instances I am going to need to make sure it has SSH access and that the ports on the agent nodes allow incoming SSH port 22 connections. I am also going to need to submit the IP addresses so that the controller knows what instance to ping.

On the controller I can create playbooks.yml that will tell it what packages to install. and 

The host file (inventory) is located here etc/ansible/ (default location). I have to run the playbooks from this directory.

