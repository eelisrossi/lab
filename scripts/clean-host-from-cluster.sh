#!/bin/bash

systemctl stop pve-cluster corosync
pmxcfs -l
rm -f /etc/pve/cluster.conf /etc/pve/corosync.conf
rm -f /etc/cluster/cluster.conf /etc/corosync/corosync.conf
rm /var/lib/pve-cluster/corosync.authkey
rm /var/lib/corosync/*
rm /etc/corosync/*
rm -rf /etc/pve/nodes/*
systemctl stop pve-cluster
rm /var/lib/pve-cluster/.pmxcfs.lockfile
killall pmxcfs
sleep 30
systemctl start pve-cluster
systemctl restart pvedaemon pveproxy pvestatd corosync pve-ha*
