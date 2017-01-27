# ansible-openshift-disconnected
Ansible Playbook to create a Proxy-node as preparation for a disconnected installation of OpenShift

# Summary

## Network Layout
<pre>
   Internet Access --> Bastion Host --> Proxy Host        --> OpenShift Nodes
                       * SSH            * Docker-registry
                       * Ansible        * RPM-registry    --> RHEL OS
                                        * RH SSO IdM      --> Identity Provider (SSO)
                                        * NFS Storage     --> PVs
</pre>

# Prerequisites
Bastion host:
* at least 40GB storage in /var/tmp to temporarely store RPM-packages & Docker-Images.
* at least 20GB storage in vg-docker (LVM) to temporarely store Docker-Images.

# Prepare
Set your environment properties in `group_vars/all`.
Set your hosts in `hosts`.

# Proxy Host
Hosting Docker-images (docker-registry) & RPM-Packages (httpd).
Not connected to internet.
Accessable from clients like OpenShift.

## Proqure Atomic Host image
* RHEL: See https://access.redhat.com/downloads/content/271/ver=/rhel---7/7.3.2/x86_64/product-software
* CentOS: See http://www.projectatomic.io/download/ (http://cloud.centos.org/centos/7/atomic/images/CentOS-Atomic-Host-7-GenericCloud.qcow2)
## Install image
* On OpenStack: See https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Installation_Guide/sect-atomic-virtualization-openstack.html
* On Satellite: See https://access.redhat.com/blogs/1169563/posts/1318283


# Bastion Host
This is a normal RHEL machine.
This machine has access to the internet to pull RPM-packages & Docker-images.
It needs a valid Red Hat subscription to pull RPM-packages from Red Hat.
The `ansible-playbook prepare.yml` will:
* register the system with Red Hat
* reposync RPM packages
* docker pull all images
* copy all that data to Proxy Host

## Setup
The ansible playbook needs access to this node, therefore we need to copy the ansible's ssh key onto the node before we execute the playbook.
```
ssh bastion
ssh-keygen
ssh-copy-id atomic

yum -y install git ansible
git clone https://github.com/sterburg/ansible-openshift-disconnected

vi hosts group_vars/all
ansible-playbook -i hosts prepare.yml
```
Optionally install OpenShift (Disconnected mode)
```
ansible-playbook -i hosts disconnected.yml
```
