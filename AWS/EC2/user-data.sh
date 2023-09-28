#cloud-boothook
#!/bin/bash
export HOME=/home/ubuntu
cd $HOME/reddit-project/production
python3 production-pipeline-category.py > /var/log/userdata.log 2>&1
sleep 30
sudo shutdown -h now