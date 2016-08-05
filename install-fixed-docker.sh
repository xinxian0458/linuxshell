#!/bin/bash

echo "using yum install docker-engine-1.11.1"
yum install -y docker-engine-selinux-1.11.1 docker-engine-1.11.1

echo "disable docker repo"
repofiles=`ls /etc/yum.repos.d/ | grep docker`
for repofile in ${repofiles};do
        sed -i "s/enabled=1/enabled=0/g" /etc/yum.repos.d/${repofile}
done
yum clean all
yum makecache

echo "start docker.service"
systemctl start docker.service

echo "enable docker.service"
systemctl enable docker.service

echo "check docker status"
systemctl status docker.service
docker version
