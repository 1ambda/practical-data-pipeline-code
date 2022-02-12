#!/bin/bash

sleep 15s;

ls -al /mnt/var/lib/info/

echo -e ""

export IS_MASTER=$(cat /mnt/var/lib/info/instance.json | jq -r ".isMaster")
export INSTANCE_GROUP_ID=$(cat /mnt/var/lib/info/instance.json | jq -r ".instanceGroupId")
export CLUSTER_ID=$(cat /mnt/var/lib/info/job-flow.json | jq -r ".jobFlowId")
export INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
export INSTANCE_GROUP_TYPE=$(cat /mnt/var/lib/info/job-flow.json | jq -r ".instanceGroups | .[] | select( .instanceGroupId == \"${INSTANCE_GROUP_ID}\") | .instanceRole" | tr a-z A-Z)

echo -e "IS_MASTER: ${IS_MASTER}"
echo -e "INSTANCE_GROUP_ID: ${INSTANCE_GROUP_ID}"
echo -e "CLUSTER_ID: ${CLUSTER_ID}"
echo -e "INSTANCE_ID: ${INSTANCE_ID}"
echo -e "INSTANCE_GROUP_TYPE: ${INSTANCE_GROUP_TYPE}"

export CURRENT_TAG_NAME=$(aws ec2 --region ap-northeast-2 describe-tags --filters Name=resource-id,Values=${INSTANCE_ID} | jq -r ".Tags | .[] | select( .Key == \"Name\") | .Value")
export NEW_TAG_NAME="${CURRENT_TAG_NAME}-${INSTANCE_GROUP_TYPE}"

echo -e "CURRENT_TAG_NAME: ${CURRENT_TAG_NAME}"
echo -e "NEW_TAG_NAME: ${NEW_TAG_NAME}"

echo -e "aws ec2 create-tags --region ap-northeast-2 --resources ${INSTANCE_ID} --tags Key=Name,Value=${NEW_TAG_NAME}"

aws ec2 create-tags --region ap-northeast-2 --resources ${INSTANCE_ID} --tags Key=Name,Value=${NEW_TAG_NAME}

