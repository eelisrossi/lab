# TODO

## Basics

- [ ] Get k3s cluster working manually
    - [ ] Networking should work between nodes
    - [ ] kubectl should work at least through VPN from gargbit
        - [ ] eventually should work through VPN from zarquon too
- [ ] Get k3s cluster working with Ansible
    - [ ] Setup and tear down of k3s with Ansible


### Sidequest: Make something to deploy on the cluster

- [ ] The software should have some sort of a database and GUI
- [ ] CI/CD pipeline for automated deployment after changes to the code
    - [ ] Dockerized?


## Advanced

- [ ] Get setup working from a freshly installed machine to a working k3s cluster
    - [ ] distro agnostic, so should work with debian/ubuntu and RHEL based
- [ ] Updates with Ansible


## Expert

- [ ] Learning Azure -> Set up VM's with Bicep
    - [ ] Set up k3s with the same Ansible playbook as before
    - [ ] Edit things to work more in the Azure paradigm

- [ ] Learning Terraform -> Set up VM's in Azure/AWS with TF
    - [ ] Set up k3s with the same Ansible playbook as before
