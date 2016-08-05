#!/bin/bash

echo "disable docker.service"
systemctl disable docker.service

echo "erase docker-engine docker-engine-selinux"
yum erase docker-engine docker-engine-selinux

echo "clear docker workdir"
rm -rf /etc/docker /etc/systemd/system/docker.service /var/lib/docker /run/docker

echo "delete docker0"
ip link set dev docker0 down
brctl delbr docker0

echo "clear docker done, all files contains docker is:"
find / -name "docker*"
