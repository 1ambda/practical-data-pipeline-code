#!/bin/bash

cd $HOME

# https://forums.aws.amazon.com/thread.jspa?threadID=149117
sudo yum install -y perl-core
sudo yum install -y perl-Sys-Syslog
sudo yum install -y perl-CGI
sudo yum install -y perl-Switch perl-DateTime perl-LWP-Protocol-https perl-Digest-SHA.x86_64 curl zip unzip

curl https://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.2.zip --silent -O
unzip CloudWatchMonitoringScripts-1.2.2.zip

sudo chown -R hadoop:hadoop ./aws-scripts-mon

sudo sh -c "echo '*/1 * * * * /home/hadoop/aws-scripts-mon/mon-put-instance-data.pl --mem-util --mem-avail --disk-path=/ --disk-path=/mnt --disk-space-util --disk-space-avail --memory-units=megabytes --disk-space-units=gigabytes --from-cron' >> /var/spool/cron/hadoop"
sudo chown hadoop:hadoop /var/spool/cron/hadoop
