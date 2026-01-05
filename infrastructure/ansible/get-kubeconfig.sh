#!/usr/bin/env bash

ssh srv-adm@192.168.20.21 "sudo cat /etc/rancher/k3s/k3s.yaml" > ~/.kube/config
sed -i -e "s/127.0.0.1/192.168.20.21/g" ~/.kube/config
