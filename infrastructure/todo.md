# TODO

- [x] Get things running with a mix of automation and doing stuff by hand
    - [ ] DNS automation
    - [ ] k3s cluster
    - [ ] Nginx Proxy Manager

## General

- [ ] add hlvm-nfs to Terraform / Ansible automation
    - [ ] prepare a cloud-init VM template with an Alpine Linux image (Ansible)
    - [ ] prepare specified drive for use with hlvm-nfs (Ansible)
    - [ ] setup the VM from a cloud-init image (Terraform)
    - [ ] mapping nfs mounts to Proxmox hosts (Ansible)

## Ansible

- [ ] a PVE section for quick Proxmox setup
    - [ ] downloading of ISOs and LXC/OCI images that are needed by Terraform
    - [ ] create a template VM with a cloud-init image that can be used with Terraform

## Terraform

