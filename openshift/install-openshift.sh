#!/bin/bash

export WORKSPACE=/tmp/openshift
source ${WORKSPACE}/user-custom-exports.sh
## Default variables to use
export INTERACTIVE=true;
export DOMAIN=${DOMAIN:="$(curl -s ipinfo.io/ip).nip.io"}
export USERNAME=${USERNAME:="$(whoami)"}
export PASSWORD=${PASSWORD:=password}
export VERSION=${VERSION:="3.9.0"}
export SCRIPT_REPO=${SCRIPT_REPO:="https://raw.githubusercontent.com/gshipley/installcentos/master"}
export IP=${IP:="$(hostname -I | awk '{print $2}')"}
export API_PORT=${API_PORT:="8443"}

echo "******"
echo "* Your domain is $DOMAIN "
echo "* Your IP is $IP "
echo "* Your username is $USERNAME "
echo "* Your password is $PASSWORD "
echo "* OpenShift version: $VERSION "
echo "******"

[ ! -d ${WORKSPACE}/openshift-ansible ] && git clone https://github.com/openshift/openshift-ansible.git ${WORKSPACE}/openshift-ansible

cd ${WORKSPACE}/openshift-ansible && git fetch && git checkout release-3.9 && cd ..


export METRICS="False"
export LOGGING="False"

ansible-playbook -i ${WORKSPACE}/inventory.ini ${WORKSPACE}/openshift-ansible/playbooks/prerequisites.yml
ansible-playbook -i ${WORKSPACE}/inventory.ini ${WORKSPACE}/openshift-ansible/playbooks/deploy_cluster.yml

sudo htpasswd -b /etc/origin/master/htpasswd ${USERNAME} ${PASSWORD}
oc adm policy add-cluster-role-to-user cluster-admin ${USERNAME}

sudo systemctl restart origin-master-api

echo "******"

echo "* Your console is https://console.$DOMAIN:$API_PORT"
echo "* Your username is $USERNAME "
echo "* Your password is $PASSWORD "
echo "*"
echo "* Login using:"
echo "*"
echo "$ oc login -u ${USERNAME} -p ${PASSWORD} https://console.$DOMAIN:$API_PORT/"
echo "******"

oc login -u ${USERNAME} -p ${PASSWORD} https://console.$DOMAIN:$API_PORT/
