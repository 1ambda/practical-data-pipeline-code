#!/bin/bash

sudo yum -y update
sudo yum -y upgrade

sudo timedatectl set-timezone Asia/Seoul

sudo yum -y groupinstall development
sudo yum -y install curl wget jq htop

sudo sh -c 'echo "fs.inotify.max_user_instances = 8192" > /etc/sysctl.d/98-inotifyfix.conf'
sudo sh -c 'echo "fs.inotify.max_user_watches = 524288" >> /etc/sysctl.d/98-inotifyfix.conf'
sudo sysctl --system

sudo sh -c 'echo "* soft nofile 65536" > /etc/security/limits.d/50-custom.conf'
sudo sh -c 'echo "* hard nofile 65536" >> /etc/security/limits.d/50-custom.conf'
sudo sh -c 'echo "* soft nproc 200000" >> /etc/security/limits.d/50-custom.conf'
sudo sh -c 'echo "* hard nproc 200000" >> /etc/security/limits.d/50-custom.conf'
