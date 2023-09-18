#!/bin/bash
sudo apt-get update
sudo apt-get install -y nfs-common
echo "${efs_ip_address}:/            /data    nfs4    nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0"  | sudo tee -a /etc/fstab
sudo mkdir /mnt/efs
sudo chmod 777 /mnt/efs/
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_ip_address}:/ /mnt/efs