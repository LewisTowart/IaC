# Infrastructure as Code (IaC)

Helps us codify all things related to infrastructure. Can write a language we can read that can instruct the machines and execute tasks accordingly.

An example is being to automate the process of SSHing into the VM and installing packages or running commands like update and upgrade.

## Ansible - Configuration Management

Written in Python, responsible for installing packges likr update and upgrade.

open srouce
powerful
simple yamml human readable
agentless

ansible controller - heklp not have to ssh into each instance
2 agent nodes

minimum 18.04 ubuntu install ansible controller, use this to configure the other two instances we will create. We create playbooks.yml in the controller and the we also host file (inventory) etc/ansible/ (default location). Have to run from this directory.

need ip in host file to allow it to ssh in to the agent. We need to provide the required key pair to the controller.

sg rules for agent 22 open for the controller. end for access available.

controller can ping thr agent node.

## Terraform - Orchastration 

