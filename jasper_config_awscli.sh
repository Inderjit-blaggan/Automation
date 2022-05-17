#!/bin/bash
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" >> /home/ssm-user/cli.log
sudo chmod 700  "$(pwd)/jasper_config_awscli.sh"
sudo apt-get install unzip -y  >> /home/ssm-user/cli.log
sudo unzip awscliv2.zip >> /home/ssm-user/cli.log
sudo ./aws/install >> /home/ssm-user/cli.log
sudo aws --version >> /home/ssm-user/cli.log
sudo mkdir -p /home/ssm-user/.aws/ >> /home/ssm-user/cli.log
sudo echo "" > /home/ssm-user/.aws/config
sudo echo  "[profile snowflake_s3_bucket]" >> /home/ssm-user/.aws/config
sudo  echo   "role_arn =  arn:aws:iam::381203884180:role/snowflake_assume_role_for_multiaccount" >>  /home/ssm-user/.aws/config
sudo  echo  "credential_source = Ec2InstanceMetadata" >>  /home/ssm-user/.aws/config

sudo cat /home/ssm-user/.aws/config >> /home/ssm-user/cli.log
sudo cat  /home/ssm-user/cli.log