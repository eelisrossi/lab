# Eelis' Lab

All of the learning I'm doing.

## Infrastructure

The 'Infrastructure' directory houses all of the different Infrastructure as Code (IaC) services I have set up.

### Currently running:

* Bind9 DNS-server that runs on two nodes

### To be added soon

* Personal gitlab instance
* Zabbix VM for monitoring my lab
* A reverse proxy for easier usage of different web services that I self-host

## Lab environment

My lab consists of two Proxmox hosts:

### HP ProDesk 600 G3 Mini
4 x Intel(R) Core(TM) i5-7500T CPU @ 2.70GHz
16 GB RAM

### Fujitsu Esprimo Q556/2
4 x Intel(R) Core(TM) i5-7400T CPU @ 2.40GHz
8 GB RAM

It is still a quite small lab, but it has enough resources for my tinkering for now.
Most of my services will run in Linux Containers (LXC), but for Docker or Kubernetes I will probably use real VMs.
