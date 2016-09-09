#!/bin/bash

# format the block storage /dev/vdb

sudo fdisk /dev/vdb # n then w
sudo mkfs -t ext4 /dev/vdb1 
echo "/dev/vdb1  /media/storage ext4 defaults,noatime,_netdev,nofail 0 2" | sudo tee --append /etc/fstab
sudo mkdir /media/storage
sudo mount -a 

