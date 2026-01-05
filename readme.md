# Eelis' Lab

All of the learning I'm doing.

## Infrastructure

The 'Infrastructure' directory houses all of the different Infrastructure as Code (IaC) services I have set up.
The directory is structured by technology.0

### Currently running:

* Bind9 DNS-server that runs on two nodes
* Nginx Proxy Manager for easy TLS sertificate management
* k3s cluster running with one master node and two workers. It's running the following:
    * glance -> a lightweight dashboard (which I've yet to configure a lot)
    * mumble -> a VoIP solution for me and my partner to have low latency VoIP at home
    * Portainer and Rancher -> for managing the k8s cluster via GUI
    * Vikunja -> a todo app

### To be added soon

* Personal gitlab instance
* Zabbix VM for monitoring my lab

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
