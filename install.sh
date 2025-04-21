#!/bin/bash
# deploy-rke2-airgapped.sh
# Usage: ./deploy-rke2-airgapped.sh [proxmox|vmware]

set -euo pipefail

PLATFORM=$1
CLUSTER_NAME="rke2-airgapped"
LOCAL_S3_ENDPOINT="http://local-s3.internal"
RKE2_VERSION="v1.30.0+rke2r1"
S3_BUCKET="rke2-artifacts"

# Download binaries from local S3 bucket
function fetch_binaries() {
  echo "Fetching RKE2 binaries from $LOCAL_S3_ENDPOINT/$S3_BUCKET"
  aws --endpoint-url "$LOCAL_S3_ENDPOINT" s3 cp s3://$S3_BUCKET/rke2-linux-amd64.tar.gz /tmp/rke2.tar.gz
  aws --endpoint-url "$LOCAL_S3_ENDPOINT" s3 cp s3://$S3_BUCKET/install.sh /tmp/install-rke2.sh
  chmod +x /tmp/install-rke2.sh
}

# Provision VMs
function provision_vms() {
  if [[ "$PLATFORM" == "proxmox" ]]; then
    terraform -chdir=terraform/proxmox init
    terraform -chdir=terraform/proxmox apply -auto-approve
  elif [[ "$PLATFORM" == "vmware" ]]; then
    terraform -chdir=terraform/vmware init
    terraform -chdir=terraform/vmware apply -auto-approve
  else
    echo "Invalid platform. Use: proxmox or vmware."
    exit 1
  fi
  terraform -chdir=terraform/$PLATFORM output -json > inventory.json
}

# Configure VMs with Ansible
function configure_rke2() {
  ansible-playbook -i inventory.json ansible/playbooks/install-rke2-airgapped.yml \
    -e local_s3_endpoint=$LOCAL_S3_ENDPOINT \
    -e rke2_version=$RKE2_VERSION
}

fetch_binaries
provision_vms
configure_rke2
