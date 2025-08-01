# Automation for Glance LXC

My very first IaC project that spins up an LXC on my Proxmox host with Terraform, and then configures it with Ansible.

Since the LXC template I'm using does not come with OpenSSH Server preinstalled, I also created a small Ansible playbook to install it with Ansible's Proxmox collection. This ended up being a bit unnecessary, since I can just use the Proxmox collection for all of the Ansible playbooks, but it is nice to be able to SSH to the LXC too.

## TODO:

- [ ] Add a script that does the initialisation from scratch
    * terraform apply
    * run both playbooks

- [ ] CI/CD pipeline for when the code in the Glance config gets changed
    * update config on LXC
    * restart glance.service
